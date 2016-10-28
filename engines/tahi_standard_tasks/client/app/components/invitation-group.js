import Ember from 'ember';

export default Ember.Component.extend({
  linkedInvitations: Ember.computed.filter('invitations.@each.primary', function(inv) {
    return inv.get('alternates.length');
  }),

  positionSort: ['position:asc'],
  sortedInvitations: Ember.computed.sort('invitations', 'positionSort'),

  actions: {
    changePosition(newPosition, invitation) {

      let sorted = this.get('sortedInvitations');

      sorted.removeObject(invitation);
      sorted.insertAt(newPosition - 1, invitation);
      this.get('changePosition')(newPosition, invitation);
    }
  }
});
