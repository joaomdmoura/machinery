exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: 'js/app.js'
    },
    stylesheets: {
      joinTo: 'css/app.css'
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to '/web/static/assets'. Files in this directory
    // will be copied to `paths.public`, which is 'priv/static' by default.
    assets: /^(lib\/web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      'lib/web/static'
    ],

    // Where to compile files to
    public: 'priv/static'
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/lib\/web\/static\/vendor/]
    }
  },

  modules: {
    autoRequire: {
      'js/app.js': ['lib/web/static/js/app']
    }
  }
};
