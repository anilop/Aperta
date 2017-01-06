import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  affiliations: DS.hasMany('affiliation', { async: false }),
  invitations: DS.hasMany('invitation', {
    inverse: 'invitee',
    async: false
  }),

  orcidAccount: DS.belongsTo('orcidAccount'),

  avatarUrl: DS.attr('string'),
  email: DS.attr('string'),
  firstName: DS.attr('string'),
  lastName: DS.attr('string'),
  fullName: DS.attr('string'),
  siteAdmin: DS.attr('boolean'),
  username: DS.attr('string'),

  name: Ember.computed.alias('fullName'),
  affiliationSort: ['isCurrent:desc', 'endDate:desc', 'startDate:asc'],
  affiliationsByDate: Ember.computed.sort('affiliations', 'affiliationSort'),

  invitationsInvited: Ember.computed.filterBy('invitations', 'invited'),
  invitationsNeedsUserUpdate: Ember.computed.filterBy('invitations', 'needsUserUpdate')
});
