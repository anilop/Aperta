import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import DragNDrop from 'tahi/services/drag-n-drop';

const {
  Component,
  computed,
  computed: { equal, reads, and, or }
} = Ember;

/*
 * UI States: closed, show, edit
 *
 */

export default Component.extend(DragNDrop.DraggableMixin, {
  classNameBindings: [
    ':invitation-item',
    'invitationStateClass',
    'uiStateClass',
    'disabled:invitation-item--disabled', 'invitation.isAlternate:invitation-item--alternate'
  ],

  propTypes: {
    invitation: PropTypes.EmberObject.isRequired
  },

  allowAttachments: true,
  currentRound: computed.not('previousRound'),
  changePositionPending: false,

  draggable: computed('previousRound', 'invitation.canReposition', 'changePositionPending', function(){
    if (this.get('previousRound') || this.get('changePositionPending')) { return false; }
    return this.get('invitation.canReposition');
  }),

  uiStateClass: computed('uiState', function() {
    return 'invitation-item--' + this.get('uiState');
  }),

  disabled: computed('activeInvitationState', 'invitation', 'activeInvitation', 'invitationGroupCantSendInvite', function(){
    if ((this.get('activeInvitationState') === 'edit') && (this.get('activeInvitation') !== this.get('invitation'))) {
      return true;
    } else {
      return this.get('invitationGroupCantSendInvite');
    }
  }),

  primary: computed('invitation.primary', function(){
    return this.get('invitation.primary') || this.get('invitation');
  }),

  // This is per APERTA-7395.  Once an invitation in a group of primary/linked alternates has been
  // sent, no invitations in the group can again be sent.  Once the invitee declines, then
  // users can try to send another invite.  If a member of the group has accepted the
  // same is true.
  invitationGroupCantSendInvite: computed(
    'primary.isInvitedOrAccepted',
    'primary.alternates.@each.isInvitedOrAccepted',
    function(){
      return (this.get('primary.isInvitedOrAccepted') ||
              this.get('primary.alternates').isAny('isInvitedOrAccepted', true));
    }
  ),

  model: computed.alias('invitation'),
  dragStart(e) {
    e.dataTransfer.effectAllowed = 'move';
    DragNDrop.set('dragItem', this.get('invitation'));
    // REQUIRED for Firefox to let something drag
    // http://html5doctor.com/native-drag-and-drop
    e.dataTransfer.setData('Text', 'someId');
  },

  dragEnd() {
    DragNDrop.set('dragItem', null);
  },

  invitationStateClass: computed('invitation.state', function() {
    return 'invitation-state--' + this.get('invitation.state');
  }),

  sendButtonClass: computed('sendDisabled', function() {
    return this.get('sendDisabled') ? 'invitation-item-action--disabled' : '';
  }),

  invitee: reads('invitation.invitee'),
  invitationBodyStateBeforeEdit: null,

  displayEditButton: computed('invitation.pending', 'closedState', 'currentRound', function() {
    return this.get('invitation.pending') && !this.get('closedState') && this.get('currentRound');
  }),

  displaySendButton: and('invitation.pending', 'currentRound'),

  displayDestroyButton: computed('invitation.pending', 'closedState', 'currentRound', function() {
    return this.get('invitation.pending') && !this.get('closedState') && this.get('currentRound');
  }),

  displayRescindButton: or('invitation.invited', 'invitation.accepted'),

  uiState: computed('invitation', 'activeInvitation', 'activeInvitationState', function() {
    if (this.get('invitation') !== this.get('activeInvitation')) {
      return 'closed';
    } else {
      return this.get('activeInvitationState');
    }
  }),

  closedState: equal('uiState', 'closed'),
  editState: equal('uiState', 'edit'),

  actions: {
    toggleDetails() {
      if (this.get('uiState') === 'closed') {
        this.get('setRowState')('show');
      } else {
        this.get('setRowState')('closed');
      }
    },

    primarySelected(primary) {
      this.set('potentialPrimary', primary);
    },

    editInvitation(invitation) {
      this.setProperties({
        invitationBodyStateBeforeEdit: invitation.get('body')
      });
      this.get('setRowState')('edit');
    },

    cancelEdit(invitation) {
      this.set('potentialPrimary', null);
      if (this.get('deleteOnCancel') && invitation.get('pending')) {
        invitation.destroyRecord();
      } else {
        invitation.rollbackAttributes();
        invitation.set('body', this.get('invitationBodyStateBeforeEdit'));
        invitation.save();
        this.get('setRowState')('show');
      }
    },

    rescindInvitation(invitation) {
      invitation.rescind();
    },

    saveDuringType(invitation) {
      Ember.run.debounce(invitation, 'save', 500);
    },

    save(invitation) {
      const potentialPrimary = this.get('potentialPrimary');

      this.get('setRowState')('show');
      this.get('saveInvite')(invitation).then(() => {
        let p;
        if(potentialPrimary) {
          if (potentialPrimary === 'cleared') {
            p = null;
          } else {
            p = potentialPrimary.get('id');
          }
          return invitation.updatePrimary(p);
        } else {
          return Ember.RSVP.resolve();
        }
      });
    },

    destroyInvitation(invitation) {
      if (invitation.get('pending')) {
        this.get('destroyInvite')(invitation);
      }
    },

    sendInvitation(invitation) {
      if(this.get('sendDisabled')) { return; }
      invitation.send();
    }
  }
});
