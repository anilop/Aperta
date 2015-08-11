import Ember from 'ember';
import RESTless from 'tahi/services/rest-less';

/* Template:
 * {{#auto-suggest endpoint="/api/users"
 *                 inputId="HTML input element id goes here"
 *                 inputName="HTML input element names goes here"
 *                 queryParameter="email"
 *                 placeholder="Search for user by email address"
 *                 parseResponseFunction=parseUserSearchResponse
 *                 itemDisplayTextFunction=something
 *                 itemSelected="userSelected"
 *                 inputChanged="inputChanged"
 *                 as |user|}}
 *   {{user.fullName}} - {{user.email}}
 * {{/auto-suggest}}
 *
 * Controller: {
 *   parseUserSearchResponse(response) {
 *     return response.users;
 *   },
 *
 *   something(user) {
 *     return user.email;
 *   }
 * }
*/

export default Ember.Component.extend({
  classNames: ['form-control', 'auto-suggest-border'],

  // -- attrs:

  /**
   *  Endpoint for HTTP request
   *
   *  @property endpoint
   *  @type String
   *  @default null
   *  @required
   **/
  endpoint: null,

  /**
   *  Query tacked on end of endpoint
   *  /api/users?email=
   *
   *  @property queryParameter
   *  @type String
   *  @default null
   *  @required
   **/
  queryParameter: null,


  /**
   *  Query tacked on end of endpoint
   *  /api/users?email=
   *
   *  @property queryParameter
   *  @type String
   *  @default null
   *  @required
   **/
  queryParameter: null,

  /**
   *  Function called to manipulate data before displaying in component
   *  function(response) { return response.users.sort.map.filter.etc.etc.etc; }
   *
   *  @property queryParameter
   *  @type String
   *  @default null
   *  @required
   *  @param {Object} http request response
   **/
  parseResponseFunction: null,

  /**
   *  When an item is chosen from the list, this function can be used
   *  to display text in the input.
   *
   *  @property itemDisplayTextFunction
   *  @type Function
   *  @default null
   *  @param {Object|Array} A single item from your datasource
   *  @return String
   **/
  itemDisplayTextFunction: null,

  /**
   *  Placeholder text for input
   *
   *  @property placeholder
   *  @type String
   *  @default null
   **/
  placeholder: null,
  // itemSelected (action)
  // unknownItemSelected (action)


  /**
   *  The id for the input element generated by this component.
   *
   *  @property id
   *  @type String
   *  @default null
   **/
  inputId: null,

  /**
   *  The name for the input element generated by this component.
   *
   *  @property name
   *  @type String
   *  @default null
   **/
  inputName: null,

  // -- props:
  debounce: 300,
  highlightedItem: null,
  resultText: null,
  searchAllowed: true,
  searchResults: null,
  selectedItem: null,
  searching: 0,

  search() {
    if (!this.get('resultText')) { return; }

    this.incrementProperty('searching');
    let url = this.get('endpoint');
    let data = {};
    data[this.get('queryParameter')] = this.get('resultText');

    RESTless.get(url, data).then((response) => {
      let results = this.get('parseResponseFunction')(response);
      this.set('searchResults',  results);
      this.decrementProperty('searching');
    },
    () => {
      this.decrementProperty('searching');
    });
  },

  /**
   *  Unique documenet keyup event name for component instance.
   *  Don't use this before the component is in the DOM
   *
   *  @method getKeyupEventName
   *  @return {String}
   *  @public
  **/
  getKeyupEventName() {
    return 'keyup.autosuggest-' + this.$().id;
  },

  _resultTextChanged: Ember.observer('resultText', function() {
    if(this.get('searchAllowed')) {
      Ember.run.debounce(this, this.search, this.get('debounce'));
    }

    this.set('searchAllowed', true);
  }),

  _setupKeybindings: Ember.on('didInsertElement', function() {
    $(document).on(this.getKeyupEventName(), (event) => {
      if (event.which === 27) {
        this.set('highlightedItem', null);
      }

      // return or esc
      if(event.which === 13 || event.which === 27) {
        let highlightedItem = this.get('highlightedItem');

        if(highlightedItem) {
          this.selectItem(highlightedItem);
        }

        this.set('highlightedItem', null);
        this.set('searchResults', null);
      } else {
        this.sendAction('inputChanged', this.get('resultText'));
      }
    });
  }),

  _teardownKeybindings: Ember.on('willDestroyElement', function() {
    $(document).off(this.getKeyupEventName());
  }),

  selectItem(item) {
    this.set('searchAllowed', false);
    this.set('selectedItem', item);
    this.sendAction('itemSelected', item);

    if(this.itemDisplayTextFunction) {
      let textForInput = this.itemDisplayTextFunction(item);
      this.set('resultText', textForInput);
    }

    this.set('searchResults', null);
  },

  actions: {
    selectItem(item) {
      this.selectItem(item);
    }
  }
});
