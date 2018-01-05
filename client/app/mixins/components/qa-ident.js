import Ember from 'ember';

export default Ember.Mixin.create({
  classNameBindings: ['qaIdent'],

  QAIdent: Ember.computed('content.ident', function() {
    const ident = this.get('content.ident');
    return ident ? `qa--${ident}` : undefined;
  })
});
