import Ember from 'ember';
import moment from 'moment';

export default Ember.Component.extend({
  store: Ember.inject.service(),
  restless: Ember.inject.service('restless'),

  classNames: ['report-status'],
  readOnly: false,

  inactiveAdminEdits: Ember.computed('report.adminEdits.[]', function() {
    let edits = this.get('report.adminEdits');
    if (Ember.isPresent(edits)) {
      return edits.filterBy('active', false).sortBy('updated_at');
    }
  }),


  editingClass: Ember.computed('report.activeAdminEdit', function() {
    return this.get('report.activeAdminEdit') ? 'editing' : '';
  }),

  shortStatus: Ember.computed.reads('short'),

  dueDatetime: Ember.computed.alias('report.dueDatetime'),

  statusSubMessage: Ember.computed('report.status','report.revision','statusDate', 'report.originallyDueAt', 'report.dueDatetime.dueAt', function() {
    const status = this.get('report.status');
    var output = '';
    const verbs = {
      'pending': 'accepted',
      'invitation_invited': 'sent on',
      'invitation_accepted': 'accepted',
      'invitation_declined': 'declined',
      'invitation_rescinded': 'rescinded'
    };
    if (['invitation_pending', 'not_invited'].includes(status)) {
      output = 'This candidate has not been invited to ' + this.get('report.revision');
    } else {
      output = `Invitation ${verbs[status]} ${this.get('statusDate')}`;
    }

    const dueDate = this.get('report.dueDatetime.dueAt');
    const originalDueDate = this.get('report.originallyDueAt');
    const format = 'MMMM D';
    const formattedDueDate = moment(dueDate).format(format);
    const formattedOriginalDueDate = moment(originalDueDate).format(format);
    if (dueDate && formattedDueDate !== formattedOriginalDueDate) {
      output += `; original due date was ${formattedOriginalDueDate}.`;
    }
    return output;
  }),

  statusMessage: Ember.computed('report.status','report.revision','reviewDueAt', 'reviewDueMessage', function() {
    const status = this.get('report.status');
    var output = '';

    if (!['invitation_pending', 'not_invited'].includes(status)) {
      output = 'review of ' + this.get('report.revision') + this.get('reviewDueMessage');
    }
    return output;
  }),

  statusDate: Ember.computed('report.statusDatetime', function(){
    const date = this.get('report.statusDatetime');
    const format = 'MMMM D, YYYY';
    return moment(date).format(format);
  }),

  reviewDueMessage: Ember.computed('dueDatetime.dueAt', function(){
    const date = this.get('dueDatetime.dueAt');
    var output = '';
    if (date) {
      const format = 'MMMM D, YYYY h:mm a z';
      const zone = moment.tz.guess();
      output = ' due ' + moment(date).tz(zone).format(format);
    }
    return output;
  }),

  reviewerStatus: Ember.computed('report.status', function() {
    const status = this.get('report.status');
    const statuses = {
      'pending': 'Pending',
      'not_invited': 'Not yet invited',
      'completed': 'Completed',
      'invitation_pending': 'Not yet invited',
      'invitation_invited': 'Invited',
      'invitation_accepted': 'Pending',
      'invitation_declined': 'Declined',
      'invitation_rescinded': 'Rescinded'
    };
    return statuses[status];
  }),

  actions: {
    changeDueDate(newDate) {
      var hours = this.get('dueDatetime.dueAt').getHours();
      newDate.setHours(hours);
      this.get('report').save();
    },

    editReport() {
      let report = this.get('report');
      report.set('editWaiting', true);
      this.get('store').createRecord('admin-edit', {reviewerReport: report}).save().then(function() {
        report.set('editWaiting', false);
        report.set('activeAdminEdit', true);
      });
    }
  }
});
