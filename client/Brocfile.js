/* global require, module */

var EmberApp = require('ember-cli/lib/broccoli/ember-app');
var mergeTrees = require('broccoli-merge-trees');
var pickFiles = require('broccoli-static-compiler');

var app = new EmberApp({
  storeConfigInMeta: false,
  emberCliFontAwesome: { includeFontAwesomeAssets: false },
  'ember-cli-bootstrap-sassy': {
    'glyphicons': false
  }
});

app.import('bower_components/underscore/underscore-min.js');
app.import('bower_components/moment/moment.js');

// jQuery UI
app.import('bower_components/jquery-ui/ui/core.js');
app.import('bower_components/jquery-ui/ui/widget.js');
app.import('bower_components/jquery-ui/ui/mouse.js');
app.import('bower_components/jquery-ui/ui/sortable.js');

// FileUpload
// (has jquery.ui.widget.js dependency, imported above with jQuery UI)
app.import('vendor/jquery.iframe-transport.js');
app.import('vendor/jquery.fileupload/jquery.fileupload.css');
app.import('vendor/jquery.fileupload/jquery.fileupload.js');

// Select 2
app.import('bower_components/select2/select2.js');
app.import('bower_components/select2/select2.css');
var select2Assets = pickFiles('bower_components/select2', {
  srcDir: '/',
  files: ['*.gif', '*.png'],
  destDir: 'assets'
});

// Add Ember-cli styles that live in Rails' /app/engines/
var addons = ["tahi_standard_tasks", "plos_authors"];
var addonStyles = addons.map(function(engineName) {
  return pickFiles('../engines/' + engineName + '/client/app/styles', {
    srcDir: '/' + engineName,
    files: ['*'],
    destDir: 'assets'
  });
});

// Bootstrap
app.import('bower_components/bootstrap/js/collapse.js');
app.import('bower_components/bootstrap/js/dropdown.js');
app.import('bower_components/bootstrap/js/tooltip.js');
app.import('bower_components/bootstrap-datepicker/css/datepicker3.css');
app.import('bower_components/bootstrap-datepicker/js/bootstrap-datepicker.js');

if (app.env !== 'production') {
  app.import('bower_components/sinon/index.js', { type: 'test' });
  app.import('bower_components/ember/ember-template-compiler.js', { type: 'test' });
  app.import('vendor/pusher-test-stub.js', { type: 'test' });
}

module.exports = mergeTrees([app.toTree(), select2Assets].concat(addonStyles), {overwrite: true});
