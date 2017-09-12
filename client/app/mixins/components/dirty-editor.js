import Ember from 'ember';

export default Ember.Mixin.create({
  init() {
    this._super();
    
    let modelName = this.get('dirtyEditorConfig.model');
    let props = this.get('dirtyEditorConfig.properties');
    let joinedProps = props.join(',');

    Ember.defineProperty(this, 'editorIsDirty', 
      Ember.computed(`${modelName}.{${joinedProps}}`, 'dirtyEditorConfig.{model,properties}', function(){
        let model = this.get(modelName);
        let dirtyAndRelevant = props.any((item) => model.changedAttributes()[item]);
        return !!(model.get('hasDirtyAttributes') && dirtyAndRelevant);
      })
    );
  },

  didInsertElement() {
    $(window).on('beforeunload.apertaEditorDirty', () => { 
      if (this.get('editorIsDirty')) { return true; } 
    });
  },

  willDestroyElement() {
    $(window).off('beforeunload.apertaEditorDirty');
  }
});
