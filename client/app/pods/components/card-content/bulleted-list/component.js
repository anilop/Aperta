import Ember from 'ember';
import listCardContentComponent from 'tahi/mixins/components/list-card-content-component';

export default Ember.Component.extend(listCardContentComponent, {
  classNames: ['card-content-bulleted-list']
});
