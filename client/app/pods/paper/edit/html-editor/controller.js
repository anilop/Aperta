import Ember from 'ember';
import PaperBaseMixin from 'tahi/mixins/controllers/paper-base';
import PaperEditMixin from 'tahi/mixins/controllers/paper-edit';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

var HtmlEditorController = Ember.Controller.extend(PaperBaseMixin, PaperEditMixin, DiscussionsRoutePathsMixin, {
  subRouteName: 'edit',

  editorComponent: "tahi-editor-ve",

  // initialized by paper/edit/view
  toolbar: null,
  hasOverlay: false,

  // used to recover a selection when returning from another context (such as figures)
  isEditing: Ember.computed.alias('lockedByCurrentUser'),

  paperBodyDidChange: function() {
    this.updateEditor();
  }.observes('model.body'),

  startEditing: function() {
    this.acquireLock();
    this.connectEditor();
  },

  stopEditing: function() {
    this.disconnectEditor();
    this.releaseLock();
  },

  acquireLock: function() {
    // Note:
    // when the paper is saved, the server knows who acquired the lock
    // (this is required for the heartbeat to work)
    // when the save succeeds, we send the `startEditing` action,
    // which is defined on `paper/edit/route`, which now starts the heartbeat
    // Thus, to acquire the lock it is necessary to
    // 1. set model.lockedBy = this.currentUser
    // 2. save the model, which sends the updated lockedBy to the server
    // 3. let the router know that we are starting editing
    var paper = this.get('model');
    paper.set('lockedBy', this.currentUser);
    // HACK: make sure pending changes are written out
    paper.set('body', this.get('editor').getBodyHtml());
    // HACK: guard to prevent errors during testing
    if (Ember.testing) { return; }
    paper.save().then(()=>{
      this.send('startEditing');
    });
  },

  releaseLock: function() {
    var paper = this.get('model');
    paper.set('lockedBy', null);
    // HACK: guard to prevent errors during testing
    if (Ember.testing) { return; }
    paper.save().then(()=>{
      // FIXME: don't know why but when calling this during willDestroyElement
      // this action will not be handled.
      this.send('stopEditing');
    });
  },

  updateEditorLockState: function() {
    if (this.get('lockedByCurrentUser')) {
      this.connectEditor();
    } else {
      this.disconnectEditor();
    }
  }.observes('lockedByCurrentUser'),

  updateEditor: function() {
    var editor = this.get('editor');
    if (editor) {
      editor.update();
    }
  },

  savePaper: function() {
    if (!this.get('model.editable')) {
      return;
    }
    var editor = this.get('editor');
    var paper = this.get('model');
    if (!editor) { return; }
    var manuscriptHtml = editor.getBodyHtml();
    paper.set('body', manuscriptHtml);
    if (paper.get('isDirty')) {
      return paper.save().then(()=>{
        this.set('saveState', true);
        this.set('isSaving', false);
      });
    } else {
      this.set('isSaving', false);
      return paper.save();
    }
  },

  connectEditor: function() {
    this.get('editor').connect();
  },

  disconnectEditor: function() {
    this.get('editor').disconnect();
  },
});

export default HtmlEditorController;
