import Ember from 'ember';
import AnimateOverlay from 'tahi/mixins/animate-overlay';

export default Ember.Controller.extend(AnimateOverlay, {
  overlayClass: 'overlay--fullscreen paper-new-overlay',
  journals: null, // set on controller before rendering overlay
  paperSaving: false,

  journalProxies: function() {
    return this.get('journals').map(function(journal) {
      return {
        id: journal.get('id'),
        text: journal.get('name')
      };
    });
  }.property(),

  // Select-2 requires data to be an object with an id key :\
  paperTypeProxies: function() {
    let paperTypes = this.get('model.journal.paperTypes');
    if(Ember.isEmpty(paperTypes)) { return []; }

    return this.get('model.journal.paperTypes').map(function(paperType) {
      return {
        id: paperType,
        text: paperType
      };
    });
  }.property('model.journal.paperTypes.@each'),

  selectedJournal: function() {
    let journal = this.get('model.journal');
    if(Ember.isEmpty(journal)) { return; }

    return { id:   journal.get('id'),
             text: journal.get('name') };
  }.property('model.journal'),

  selectedPaperType: function() {
    let paperType = this.get('model.paperType');
    if(Ember.isEmpty(paperType)) { paperType = ''; }

    return { id:   paperType,
             text: paperType };
  }.property('model.paperType'),

  actions: {
    createNewPaper() {
      this.set('paperSaving', true);

      this.get('model').save().then((paper)=> {
        this.transitionToRoute('paper.edit', paper);
      }, (response)=> {
        this.flash.displayErrorMessagesFromResponse(response);
      }).finally(()=> {
        this.set('paperSaving', false);
      });
    },

    selectJournal(journalProxy) {
      let journal = this.get('journals').findBy('id', journalProxy.id);
      this.set('model.journal', journal);
      this.set('model.paperType', null);
    },

    selectPaperType(paperTypeProxy) {
      this.set('model.paperType', paperTypeProxy.text);
    }
  }
});
