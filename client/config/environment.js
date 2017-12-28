/* jshint node: true */

module.exports = function(environment) {
  var ENV = {
    modulePrefix: 'tahi',
    podModulePrefix: 'tahi/pods',
    environment: environment,
    rootURL: '/',
    locationType: 'auto',
    EmberENV: {
      FEATURES: {
        // Here you can enable experimental features on an ember canary build
        // e.g. 'with-controller': true
      },
      EXTEND_PROTOTYPES: {
        // Prevent Ember Data from overriding Date.parse.
        Date: false
      }
    },
    APP: {
      // pusher configuration is set in initializers/pusher.js

      iHatExportFormats: [
        { type: 'docx', display: 'word' },
        { type: 'pdf', display: 'pdf'}
      ]
    },

    coffeeOptions: {
      blueprints: false
    },

    // Also set in /app/views/downloadable_paper/pdf.html.erb
    'mathjax': {
      url: '//cdnjs.cloudflare.com/ajax/libs/mathjax/2.6.1/MathJax.js?config=MML_HTMLorMML-full'
    },
    'pdfjs': {
      url: '//cdnjs.cloudflare.com/ajax/libs/pdf.js/1.6.319/pdf.min.js'
    },

    contentSecurityPolicy: {
      'default-src': "'none'",
      'script-src': "'self' 'unsafe-eval'", // loading visualEditor via getScript
      'font-src': "'self'",
      'connect-src': "'self'",
      'img-src': "'self'",
      'style-src': "'self' 'unsafe-inline'", // Allow inline styles
      'media-src': "'self'"
    },

    moment: {
      includeTimezone: 'all'
    },

    'ember-prop-types': {
      // Throw errors instead of logging warnings (default is false)
      throwErrors: true,

      // Validate properties (default is true for all environments except "production")
      validate: true,

      // Validate properties when they are updated (default is false)
      validateOnUpdate: true
    }
  };

  if (environment === 'development') {
    if(Error && Error.stackTraceLimit) {
      Error.stackTraceLimit = 25;
    }
    // ENV.APP.LOG_RESOLVER = true;
    // ENV.APP.LOG_ACTIVE_GENERATION = true;
    // ENV.APP.LOG_TRANSITIONS = true;
    // ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS = true;
  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.rootURL = '/';
    ENV.locationType = 'none';

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;

    ENV.APP.rootElement = '#ember-testing';
  }

  if (environment === 'production') {
    ENV['ember-prop-types'].validate = false;
  }

  return ENV;
};
