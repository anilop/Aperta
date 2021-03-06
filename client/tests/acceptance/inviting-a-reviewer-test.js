/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import Ember from 'ember';
import { test } from 'qunit';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';
import { mockFindRecord, mockDelete, make, mockFindAll } from 'ember-data-factory-guy';
import Factory from 'tahi/tests/helpers/factory';
import * as TestHelper from 'ember-data-factory-guy';

let paper, phase, task, inviteeEmail;

moduleForAcceptance('Integration: Inviting a reviewer', {
  beforeEach() {
    phase = make('phase');
    task  = make('paper-reviewer-task', { phase: phase, letter: '"A letter"', viewable: true });
    paper = make('paper', { phases: [phase], tasks: [task] });
    inviteeEmail = window.currentUserData.user.email;

    TestHelper.mockPaperQuery(paper);
    mockFindAll('discussion-topic', 1);

    Factory.createPermission('Paper', 1, ['manage_workflow']);
    Factory.createPermission('PaperReviewerTask', task.id, ['edit']);

    $.mockjax({url: '/api/admin/journals/authorization', status: 204});
    $.mockjax({url: '/api/formats', status: 200, responseText: {
      import_formats: [],
      export_formats: []
    }});
    $.mockjax({url: /\/api\/tasks\/\d+/, type: 'PUT', status: 204, responseText: ''});
    $.mockjax({url: /\/api\/journals/, type: 'GET', status: 200, responseText: { journals: [] }});
    $.mockjax({url: /\/api\/invitations\/1\/rescind/, type: 'PUT', status: 200, responseText: {}});

    $.mockjax({
      url: /api\/tasks\/\d+\/eligible_users\/reviewers/,
      type: 'GET',
      status: 200,
      contentType: 'application/json',
      responseText: {
        users: [{ id: 1, full_name: 'Aaron', email: inviteeEmail }]
      }
    });
  }
});


test('disables the Compose Invite button until a user is selected', function(assert) {
  Ember.run(function(){
    mockFindRecord('paper-reviewer-task').returns({model: task});
    visit(`/papers/${paper.get('shortDoi')}/workflow`);
    click(".card-title:contains('Invite Reviewers')");

    andThen(function(){
      assert.elementFound(
        '.invitation-email-entry-button.button--disabled',
        'Expected to find Compose Invite button disabled'
      );

      fillIn('#invitation-recipient', inviteeEmail);
    });

    andThen(function(){
      click('.auto-suggest-item:first');
    });

    andThen(function(){
      assert.elementFound(
        '.invitation-email-entry-button:not(.button--disabled)',
        'Expected to find Compose Invite button enabled'
      );

      assert.elementFound(
        '.ember-view .error-message',
        'Show an error when email is not right'
      );
    });
  });
});

test('can delete a pending invitation', function(assert) {
  Ember.run(function() {
    let decision = make('decision', 'draft');
    task.set('decisions', [decision]);

    let invitation = make('invitation', {
      email: 'foo@bar.com',
      inviteeRole: 'Reviewer',
      state: 'pending'
    });

    decision.set('invitations', [invitation]);

    mockFindRecord('paper-reviewer-task').returns({model: task});
    mockDelete('invitation', invitation.id);
    mockFindRecord('decision').returns({model: decision});

    visit(`/papers/${paper.get('shortDoi')}/workflow`);
    click(".card-title:contains('Invite Reviewers')");

    andThen(function() {
      let msgEl = find(`.invitation-item:contains('${invitation.get('email')}')`);
      assert.ok(msgEl[0] !== undefined, 'has pending invitation');
    });

    click('.invitation-item-full-name');
    click('.invitation-item-action-delete');

    andThen(function() {
      assert.equal(task.get('invitation'), null, 'invitation deleted');
    });
  });
});

test('can not send or delete a pending invitation from a previous round', function(assert) {
  Ember.run(function() {
    let decision = make('decision', 'draft');
    let oldDecision = make('decision');
    task.set('decisions', [decision, oldDecision]);

    let invitation = make('invitation', {
      email: 'foo@bar.com',
      inviteeRole: 'Reviewer',
      state: 'pending'
    });
    oldDecision.set('invitations', [invitation]);

    mockFindRecord('paper-reviewer-task').returns({model: task});
    mockFindRecord('decision').returns({model: decision});
    $.mockjax({url: /\/api\/decisions\/2/, type: 'GET', status: 200, responseText: {
      decision: $.extend({id: oldDecision.id}, oldDecision.toJSON())
    }});

    visit(`/papers/${paper.get('shortDoi')}/workflow`);
    click('.card-title:contains("Invite Reviewers")');

    andThen(function() {
      assert.elementNotFound('.active-invitations .invitation-item', 'no active invitations');
      assert.elementFound(`.expired-invitations .invitation-item:contains('${invitation.get('email')}')`, 'has an old pending invitation');
    });

    click('.invitation-item-full-name');

    andThen(function() {
      assert.elementNotFound('.invitation-item-action-delete');
      assert.elementNotFound('.invitation-item-action-send');
    });
  });
});
