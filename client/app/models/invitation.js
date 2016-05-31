import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  abstract: DS.attr('string'),
  body: DS.attr('string'),
  createdAt: DS.attr('date'),
  declineReason: DS.attr('string'),
  email: DS.attr('string'),
  information: DS.attr('string'),
  invitationType: DS.attr('string'),
  invitee: DS.belongsTo('user', { inverse: 'invitations', async: true }),
  inviteeRole: DS.attr('string'),
  reviewerSuggestions: DS.attr('string'),
  state: DS.attr('string'),
  task: DS.belongsTo('task', { polymorphic: true, async: false }),
  title: DS.attr('string'),
  updatedAt: DS.attr('date'),

  accepted: Ember.computed('state', function() {
    return this.get('state') === 'accepted';
  }),

  reject() {
    this.set('state', 'rejected');
  },

  accept() {
    this.set('state', 'accepted');
  },

 restless: Ember.inject.service('restless'),
 rescind() {
   return this.get('restless')
    .put(`/api/invitations/${this.get('id')}/rescind`)
    .then((data) => {
      this.unloadRecord();
      return this;
    });
  }
});
