import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('paper', {
  default: {
    title: '',
    shortTitle: '',
    publishingState: 'unsubmitted',
    relatedAtDate: '2014-09-28T13:54:58.028Z',
    editable: true,
    shortDoi: 'dev.dev10001',
    currentUserRoles: ['Creator']
  },

  paper_with_discussion: {
    title: '',
    shortTitle: '',
    publishingState: 'unsubmitted',
    relatedAtDate: '2014-09-28T13:54:58.028Z',
    editable: true,
    discussionTopics: [{
      id: 1,
      title: 'Tech Check Discussion',
      discussionReplies: [],
      discussionParticipants: []
    }],
    shortDoi: 'dev.dev10001'
  },

  paper_with_file_error: {
    title: '',
    shortTitle: '',
    publishingState: 'unsubmitted',
    relatedAtDate: '2014-09-28T13:54:58.028Z',
    editable: true,
    shortDoi: 'dev.dev10001',
    currentUserRoles: ['Creator'],
    processing: false,
    fileType: 'doc',
    file: {
      status: 'error',
    }
  }
});
