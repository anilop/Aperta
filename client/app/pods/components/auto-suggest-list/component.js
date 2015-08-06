import Ember from 'ember';
import PositionNearMixin from 'tahi/mixins/components/position-near';

const { computed, on } = Ember;

/*
Block Style:

{{#if userResults}}
  {{#auto-suggest-list positionNearSelector="#search-user-input"
                       selectItem="selectUser"
                       items=userResults as |user|}}
    {{user.fullName}} - {{user.email}}
  {{/auto-suggest-list}}
{{/if}}

Customizing List Items:

Since you are passing a block or partial to the component,
you can display whatever content you want.

To set extra classes on each item in the list by setting the
itemClass property on auto-suggest-list:
{{auto-suggest-list ... itemClass="user-list-item"}}
*/

export default Ember.Component.extend(PositionNearMixin, {
  classNames: ['auto-suggest'],
  positionNearSelector: computed.alias('selector'),

  items: [],

  highlightedItem: null,
  highlightedItemIndex: computed('highlightedItem', function() {
    return this.get('items').indexOf( this.get('highlightedItem') );
  }),

  highlightFirstItem() {
    this.set('highlightedItem', this.get('items.firstObject'));
  },

  highlightlastItem() {
    this.set('highlightedItem', this.get('items.lastObject'));
  },

  highlightPrevious() {
    let index        = this.get('highlightedItemIndex');
    let previousItem = this.get('items').objectAt(--index);

    if(previousItem) {
      this.set('highlightedItem', previousItem);
    } else {
      this.highlightlastItem();
    }
  },

  highlightNext() {
    let index    = this.get('highlightedItemIndex');
    let nextItem = this.get('items').objectAt(++index);

    if(nextItem) {
      this.set('highlightedItem', nextItem);
    } else {
      this.highlightFirstItem();
    }
  },

  _setupKeybindings: on('didInsertElement', function() {
    $(document).on('keyup.autosuggestlist', (event)=> {
      switch(event.which) {
        case 38:
          // arrow up
          this.highlightPrevious();
          break;
        case 40:
          // arrow down
          this.highlightNext();
          break;
      }
    });
  }),

  _teardownKeybindings: on('willDestroyElement', function() {
    $(document).off('keyup.autosuggestlist');
  }),

  actions: {
    selectItem(item) {
      this.sendAction('selectItem', item);
    }
  }
});
