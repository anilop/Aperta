import Ember from 'ember';
import { PropTypes } from 'ember-prop-types';
import DragNDrop from 'tahi/services/drag-n-drop';
import { timeout, task as concurrencyTask } from 'ember-concurrency';

const {
  Component,
  computed,
  computed: { and, equal, not, or, reads }
} = Ember;

/*
 * UI States: closed, show, edit
 *
 */

export default Component.extend(DragNDrop.DraggableMixin, {
  can: Ember.inject.service('can'),

  canManageInvitationsTask: concurrencyTask(function * () {
    let perm = yield this.get('can').can('manage_invitations', this.get('owner'));
    this.set('canManageInvitations', perm);
  }),

  init() {
    this._super(...arguments);
    this.get('canManageInvitationsTask').perform();
  },

  canManageInvitations: false,
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
  invitationsInFlight: false,

  isActiveInvitation: computed('activeInvitation', 'invitation', function() {
    return this.get('activeInvitation') === this.get('invitation');
  }),

  draggable: computed(
    'previousRound',
    'invitation.canReposition',
    'invitationsInFlight',
    'invitationIsExpanded',
    function(){
      if (this.get('previousRound') || this.get('invitationsInFlight') || this.get('invitationIsExpanded')) {
        return false;
      }
      return this.get('invitation.canReposition');
    }
  ),

  uiStateClass: computed('uiState', function() {
    return 'invitation-item--' + this.get('uiState');
  }),

  disabled: computed('activeInvitationState', 'isActiveInvitation', 'invitationGroupCantSendInvite', function(){
    if ((this.get('activeInvitationState') === 'edit') && !this.get('isActiveInvitation')) {
      return true;
    } else {
      return this.get('invitationGroupCantSendInvite');
    }
  }),

  editDisabled: not('isActiveInvitation'),

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
    if (!this.get('draggable')) { return; }
    this.sendAction('startedDragging');
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

  invitee: reads('invitation.invitee'),
  invitationBodyStateBeforeEdit: null,

  notClosedState: not('closedState'),

  displayEditButton: and('invitation.pending', 'notClosedState', 'currentRound'),

  displaySendButton: and('invitation.pending', 'currentRound'),

  displayDestroyButton: and('invitation.pending', 'notClosedState', 'currentRound'),

  displayRescindButton: computed('invitation.{invited,accepted}', 'closedState', 'currentRound','canManageInvitations', function() {
    return this.get('notClosedState') && this.get('currentRound') && this.get('canManageInvitations') && (this.get('invitation.invited') || this.get('invitation.accepted'));
  }),
  // similar to rescind button but only if its for a reviewer and if there's an invitee
  displayAcceptOnBehalfButton: and('invitation.{invited,reviewer}', 'notClosedState', 'currentRound', 'canManageInvitations'),

  notAcceptedByInvitee: not('invitation.isAcceptedByInvitee'),

  destroyDisabled: or('disabled', 'invitation.isPrimary'),

  displayAcceptFields: false,

  invitationLoading: false,

  uiState: computed('invitation', 'activeInvitation', 'activeInvitationState', function() {
    if (this.get('invitation') !== this.get('activeInvitation')) {
      return 'closed';
    } else {
      return this.get('activeInvitationState');
    }
  }),

  closedState: equal('uiState', 'closed'),
  editState: equal('uiState', 'edit'),

  rescindInvitation: concurrencyTask(function * (invitation) {
    try {
      return yield invitation.rescind();
    } catch (e) {
      this.get('displayError')();
    }
  }).drop(),

  sendInvitation: concurrencyTask(function * (invitation) {
    try {
      return yield invitation.invite();
    } catch (e) {
      this.get('displayError')();
    }
  }).drop(),

  rollback: concurrencyTask(function * (invitation) {
    yield invitation.reload();
    invitation.set('body', this.get('invitationBodyStateBeforeEdit'));
    yield invitation.save();
    this.get('setRowState')('show');
  }),

  _updateContents: concurrencyTask(function * (invitation) {
    yield timeout(200); // agreed timeout time for cards
    this.get('saveInvite')(invitation);
  }).restartable(),

  acceptInvitation: concurrencyTask(function * (data) {
    this.set('invitationLoading', true);
    yield this.get('invitation').accept(data);
    this.setProperties({displayAcceptFields: false, invitationLoading: false});
  }).drop(),

  actions: {
    updateContents(contents) {
      let invitation = this.get('invitation');
      invitation.set('body', contents);
      this.get('_updateContents').perform(invitation);
    },

    toggleDetails() {
      if (this.get('uiState') === 'closed') {
        this.get('setRowState')('show');
      } else {
        this.get('setRowState')('closed');
      }
    },

    primarySelected(primary) {
      if(primary === 'cleared') {
        this.set('invitation.primary', null);
      }

      this.set('potentialPrimary', primary);
    },

    editInvitation(invitation) {
      if (this.get('editDisabled')) { return; }

      this.setProperties({
        invitationBodyStateBeforeEdit: invitation.get('body')
      });
      this.get('setRowState')('edit');
    },

    cancelEdit(invitation) {
      this.set('potentialPrimary', null);
      if (this.get('deleteOnCancel') && invitation.get('pending')) {
        this.get('setRowState')('show');
        invitation.destroyRecord();
      } else {
        this.get('rollback').perform(invitation);
      }
    },

    rescindInvitation(invitation) {
      this.get('rescindInvitation').perform(invitation);
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
      if (this.get('disabled')) { return; }

      if (invitation.get('pending')) {
        this.get('destroyInvite')(invitation);
      }
    },

    sendInvitation(invitation) {
      if (this.get('disabled')) { return; }

      this.get('sendInvitation').perform(invitation);
    },

    acceptInvitation() {
      if (this.get('invitee.id')) {
        this.get('acceptInvitation').perform();
      } else {
        this.toggleProperty('displayAcceptFields');
      }
    },
    cancelAccept(){
      this.toggleProperty('displayAcceptFields');
    }
  }
});
