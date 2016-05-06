import Ember from 'ember';
import { test } from 'ember-qunit';
import startApp from '../helpers/start-app';
import setupMockServer from '../helpers/mock-server';
import { paperWithTask } from '../helpers/setups';
import Factory from '../helpers/factory';

import FactoryGuy from 'ember-data-factory-guy';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

var app, paper, server;

app = null;
server = null;
paper = null;

module('Integration: Submitting Paper', {
  afterEach: function() {
    server.restore();
    Ember.run(function() {
      return TestHelper.teardown();
    });
    Ember.run(app, app.destroy);
    $.mockjax.clear();
  },
  beforeEach: function() {
    app = startApp();
    TestHelper.setup();
    server = setupMockServer();

    let journal = FactoryGuy.make('journal');
    let phase = FactoryGuy.make('phase');
    let task  = FactoryGuy.make('task', {
      phase: phase,
      isMetaDataTask: true,
      isSubmissionTask: true,
      completed: true
    });
    paper = FactoryGuy.make('paper', { journal: journal, phases: [phase], tasks: [task] });

    TestHelper.handleFind(paper);

    TestHelper.handleFindAll('discussion-topic', 1);
    TestHelper.handleFindAll('journal', 0);

    Factory.createPermission('Paper', paper.id, ['submit']);
    $.mockjax({url: `/api/papers/${paper.id}`, type: 'put', status: 204 });
    $.mockjax({
      url: `/api/papers/${paper.id}/submit`,
      type: 'put',
      status: 200,
      responseText: {papers: []}
    });
  }
});

test('User can submit a paper', function(assert) {
  visit('/papers/' + paper.id);
  click(".edit-paper button:contains('Submit')");
  click('button.button-submit-paper');
  return andThen(function() {
    return assert.ok(_.findWhere($.mockjax.mockedAjaxCalls(), {
      type: 'PUT',
      url: '/api/papers/' + paper.id + '/submit'
    }), 'It posts to the server');
  });
});
