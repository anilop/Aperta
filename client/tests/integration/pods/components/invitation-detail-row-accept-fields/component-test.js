import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent('invitation-detail-row-accept-fields', 'Integration | Component | invitation detail row accept fields', {
  integration: true,
  beforeEach(){
    this.set('invitation', Ember.Object.create({email: 'foo@bar.com'}));
    this.set('displayAcceptFields', true);
    this.set('cancelAccept', function(){});
    this.set('loading', false);
    this.set('acceptInvitation', function(){});
  }
});

let template = hbs`{{invitation-detail-row-accept-fields
                      invitation=invitation
                      displayAcceptFields=displayAcceptFields
                      cancelAccept=cancelAccept
                      loading=loading
                      acceptInvitation=acceptInvitation}}`;

test('it is disabled by default', function(assert) {
  this.set('displayAcceptFields', false);
  this.render(template);
  assert.elementNotFound('.instructions', 'Does not display anything if displayAcceptFields is false');
});

test('displays instructins for invitation email', function(assert) {
  this.render(template);
  assert.textPresent('.instructions', this.get('invitation.email'), 'Displays email in instruction field');
});

test('it displays validation errors and prevents save', function(assert) {
  assert.expect(1);
  var callback = () => {
    assert.ok(true, 'This should not be called');
  };
  this.set('acceptInvitation', callback);
  this.render(template);
  this.$('.accept').click();
  assert.textPresent('.error', 'This field is required');
});

test('it binds in the stub invitee fields, and the object is passed into the callback', function(assert) {
  assert.expect(2);
  var firstName = 'wat';
  var lastName = 'who';
  var callback = (obj) => {
    assert.equal(obj.get('firstName'), firstName);
    assert.equal(obj.get('lastName'), lastName);
  };
  this.set('acceptInvitation', callback);
  this.render(template);
  this.$("input[id*='fname']").val(firstName).change();
  this.$("input[id*='lname']").val(lastName).change();
  this.$('.accept').click();
});

test('cancel button should clear validation errors, reset fields and invoke callback', function(assert) {
  assert.expect(3);
  var callback = () => { assert.ok(true, 'Callback is called'); };
  var firstName = 'wat';
  this.set('cancelAccept', callback);
  this.render(template);
  this.$("input[id*='fname']").val(firstName).change();
  this.$('.accept').click();
  this.$('.cancel').click();
  assert.ok(!this.$("input[id*='fname']").val()), 'Input field is blank';
  assert.elementNotFound('.error', 'Error fields cleared');
});
