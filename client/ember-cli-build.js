/* global require, module */
var EmberApp = require('ember-cli/lib/broccoli/ember-app');
var Funnel   = require('broccoli-funnel');

module.exports = function(defaults) {
  var args = {
    hinting: false,
    storeConfigInMeta: false,
    emberCliFontAwesome: { includeFontAwesomeAssets: true },
    'ember-cli-qunit': {
      useLintTree: false
    },
    sourcemaps: {
      enabled: true,
      extensions: ['js']
    },
    babel: {
      includePolyfill: true
    },
    codemirror: {
      modes: ['xml'],
      themes: ['eclipse']
    },
    minifyJS: {
      enabled: EmberApp.env() === 'production'
    },
    fingerprint: {
      exclude: ['skins', 'plugins']
    }
  };

  var app = new EmberApp(defaults, args);

  app.import(app.bowerDirectory + '/underscore/underscore.js');

  // jQuery UI
  app.import(app.bowerDirectory + '/jquery-ui/ui/core.js');
  app.import(app.bowerDirectory + '/jquery-ui/ui/widget.js');
  app.import(app.bowerDirectory + '/jquery-ui/ui/mouse.js');
  app.import(app.bowerDirectory + '/jquery-ui/ui/sortable.js');

  // FileUpload
  // (has jquery.ui.widget.js dependency, imported above with jQuery UI)
  app.import('vendor/jquery.iframe-transport.js');
  app.import('vendor/jquery.fileupload/jquery.fileupload.css');
  app.import('vendor/jquery.fileupload/jquery.fileupload.js');

  // Select 2
  app.import(app.bowerDirectory + '/select2/select2.js');
  app.import(app.bowerDirectory + '/select2/select2.css');
  var select2Assets = new Funnel(app.bowerDirectory + '/select2', {
    srcDir: '/',
    include: ['*.gif', '*.png'],
    destDir: '/assets'
  });

  // JsDiff
  app.import(app.bowerDirectory + '/jsdiff/diff.js');

  // lscache
  app.import(app.bowerDirectory + '/lscache/lscache.js');

  // Bootstrap
  app.import(app.bowerDirectory + '/bootstrap/js/collapse.js');
  app.import(app.bowerDirectory + '/bootstrap/js/dropdown.js');
  app.import(app.bowerDirectory + '/bootstrap/js/tooltip.js');
  app.import(app.bowerDirectory + '/bootstrap/js/tab.js');
  app.import(app.bowerDirectory + '/bootstrap-datepicker/css/datepicker3.css');
  app.import(app.bowerDirectory + '/bootstrap-datepicker/js/bootstrap-datepicker.js');

  // jQuery timepicker
  app.import(app.bowerDirectory + '/jt.timepicker/jquery.timepicker.min.js');
  app.import(app.bowerDirectory + '/jt.timepicker/jquery.timepicker.css');

  // At.js
  app.import(app.bowerDirectory + '/At.js/dist/css/jquery.atwho.css');

  // TinyMCE
  app.import('node_modules/tinymce/tinymce.js', { outputFile: 'assets/tiny_mce.js' });
  app.import('node_modules/tinymce/themes/modern/theme.js', { outputFile: 'assets/tiny_mce.js' });
  app.import('node_modules/tinymce/plugins/code/plugin.js', { outputFile: 'assets/tiny_mce.js' });
  app.import('node_modules/tinymce/plugins/codesample/plugin.js', { outputFile: 'assets/tiny_mce.js' });
  app.import('node_modules/tinymce/plugins/paste/plugin.js', { outputFile: 'assets/tiny_mce.js' });
  app.import('node_modules/tinymce/plugins/table/plugin.js', { outputFile: 'assets/tiny_mce.js' });
  app.import('node_modules/tinymce/plugins/link/plugin.js', { outputFile: 'assets/tiny_mce.js' });
  app.import('node_modules/tinymce/plugins/autoresize/plugin.js', { outputFile: 'assets/tiny_mce.js' });

  var tinymceSkins = new Funnel('node_modules/tinymce/skins/lightgray', {
    srcDir: '/',
    include: ['fonts/*.woff', 'fonts/*.ttf', '*.css'],
    destDir: '/assets/skins/lightgray'
  });

  var prism = new Funnel('node_modules/tinymce/plugins/codesample/css', {
    srcDir: '/',
    include: ['*.css'],
    destDir: '/assets/plugins/codesample/css'
  });

  if (app.env !== 'production') {
    app.import('vendor/pusher-test-stub.js', { type: 'test' });
  }

  return app.toTree([select2Assets, tinymceSkins, prism]);
};
