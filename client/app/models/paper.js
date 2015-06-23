import DS from 'ember-data';

export default DS.Model.extend({
  authors: DS.hasMany('author'),
  collaborations: DS.hasMany('collaboration'),
  commentLooks: DS.hasMany('comment-look', { inverse: 'paper', async: true }),
  decisions: DS.hasMany('decision'),
  editors: DS.hasMany('user'),
  figures: DS.hasMany('figure', { inverse: 'paper' }),
  tables: DS.hasMany('table', { inverse: 'paper' }),
  journal: DS.belongsTo('journal'),
  lockedBy: DS.belongsTo('user'),
  phases: DS.hasMany('phase'),
  reviewers: DS.hasMany('user'),
  supportingInformationFiles: DS.hasMany('supporting-information-file'),
  tasks: DS.hasMany('task', { async: true, polymorphic: true }),

  body: DS.attr('string'),
  doi: DS.attr('string'),
  editable: DS.attr('boolean'),
  editorMode: DS.attr('string', { defaultValue: 'html' }),
  eventName: DS.attr('string'),
  paperType: DS.attr('string'),
  relatedAtDate: DS.attr('date'),
  roles: DS.attr(),
  shortTitle: DS.attr('string'),
  status: DS.attr('string'),
  strikingImageId: DS.attr('string'),
  publishingState: DS.attr('string'),
  title: DS.attr('string'),

  displayTitle: function() {
    return this.get('title') || this.get('shortTitle');
  }.property('title', 'shortTitle'),

  allSubmissionTasks: function() {
    return this.get('tasks').filterBy('isSubmissionTask');
  }.property('tasks.content.@each.isSubmissionTask'),

  collaborators: function() {
    return this.get('collaborations').mapBy('user');
  }.property('collaborations.@each'),

  allSubmissionTasksCompleted: function() {
    return this.get('allSubmissionTasks').everyProperty('completed', true);
  }.property('allSubmissionTasks.@each.completed'),

  roleList: function() {
    return this.get('roles').sort().join(', ');
  }.property('roles.@each', 'roles.[]'),

  latestDecision: function() {
    return this.get('decisions').findBy('isLatest', true);
  }.property('decisions', 'decisions.@each'),

  submittable: function() {
    var state = this.get('publishingState');
    return state === 'unsubmitted' || state === 'in_revision';
  }.property('publishingState')
});
