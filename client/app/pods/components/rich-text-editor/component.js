import Ember from 'ember';

const basicElements    = 'p,br,strong/b,em/i,u,sub,sup,pre';
const basicPlugins     = 'code';
const basicToolbar     = 'bold italic underline | subscript superscript | undo redo | code';

const expandedElements = ',a,div,span,code,ol,ul,li,h1,h2,h3,h4,table,thead,tbody,tfoot,tr,th,td';
const expandedPlugins  = ' codesample link table';
const expandedToolbar  = ' | bullist numlist | table link codesample | formatselect';

const blockFormats     = 'Header 1=h1;Header 2=h2;Header 3=h3;Header 4=h4;Code=pre';

/* some tinymce options are snake_case */
/* eslint-disable camelcase */

export default Ember.Component.extend({
  classNames: ['rich-text-editor'],
  attributeBindings: ['data-editor'],
  'data-editor': Ember.computed.alias('ident'),

  editorStyle: 'expanded',

  editorConfigurations: {
    basic: {
      plugins: basicPlugins,
      statusbar: false,
      toolbar: basicToolbar,
      valid_elements: basicElements
    },

    expanded: {
      plugins: basicPlugins + expandedPlugins,
      block_formats: blockFormats,
      toolbar: basicToolbar + expandedToolbar,
      valid_elements: basicElements + expandedElements
    }
  },

/* eslint-enable camelcase */

  configureCommon(hash) {
    hash['menubar'] = false;
    return hash;
  },

  editorOptions: Ember.computed('editorStyle', 'editorConfigurations', function() {
    let configs = this.get('editorConfigurations');
    let style = this.get('editorStyle') || 'expanded';
    let options = configs[style];
    return this.configureCommon(options);
  }),
});
