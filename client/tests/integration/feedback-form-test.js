import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'tahi/tests/helpers/start-app';
import Factory from '../helpers/factory';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';

let App = null;

moduleForAcceptance('Integration: Feedback Form', {
  afterEach: function() {
    Ember.run(App, 'destroy');
  },

  beforeEach: function() {
    App = startApp();
    $.mockjax({url: '/api/admin/journals/authorization', status: 204});
    $.mockjax({url: '/api/affiliations', status: 304 });

    $.mockjax({
      url: '/api/journals',
      method: 'GET',
      status: 200,
      responseText: { journals: [] }
    });
    $.mockjax({
      url: '/api/feedback',
      method: 'POST',
      status: 201,
      responseText: {}
    });
  }
});

test('clicking the feedback button sends feedback', function(assert) {
  visit('/');
  click('#nav-give-feedback');
  click('a:contains(Feedback)');
  fillIn('.overlay textarea', 'My feedback');
  click('.overlay-footer-content .button-primary');

  andThen(function() {
    assert.elementFound(
      '.feedback-form-thanks',
      'Thank you message visible'
    );
  });
});
