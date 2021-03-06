// Generated by CoffeeScript 1.10.0
(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  module.exports = function(BasePlugin) {
    var AuthenticationPlugin, fs, util;
    fs = require('fs');
    util = require('util');
    return AuthenticationPlugin = (function(superClass) {
      var socialLoginClass;

      extend(AuthenticationPlugin, superClass);

      function AuthenticationPlugin() {
        return AuthenticationPlugin.__super__.constructor.apply(this, arguments);
      }

      AuthenticationPlugin.prototype.name = 'authentication';

      AuthenticationPlugin.prototype.config = {
        sessionSecret: 'k%AjPwe9%l;wiYMQd££' + (new Date()).getMilliseconds(),
        protectedUrls: ['/admin/*', '/analytics/*'],

        /*
        lookup function to retrieve membership details after
        authentication. Probably want to replace it with
        your own method that will look up a membership by
        some method (json file, db?)
        
        findOrCreate: (opts,done) ->
            done opts.profile #make sure this is called and the profile or user data is returned
         */

        /*
        configuration parameters for the various authentication
        strategies. You will normally need to create an application
        via the various services developer consoles to get a the
        appropriate clientIDs and clientSecrets (sometimes called things
        like consumer key/secrets or API key/secrets). Recommended that you
        store these values in an environment file (https://docpad.org/docs/config)
        and added to your .gitignore file
        
        strategies:
            facebook:
                settings:
                    clientID: "YOUR_API_ID"
                    clientSecret: "YOUR_API_SECRET"
                    authParameters: scope: 'read_stream,manage_pages'
                url:
                    auth: '/auth/facebook'
                    callback: '/auth/facebook/callback'
                    success: '/'
                    fail: '/login'
            twitter:
                settings:
                    clientID: "YOUR_API_ID"
                    clientSecret: "YOUR_API_SECRET"
                url:
                    auth: '/auth/twitter'
                    callback: '/auth/twitter/callback'
                    success: '/'
                    fail: '/login'
         */

        /*
        Middleware function to ensure user is authenticated.
        This will be applied to any urls in the protectedUrls config option.
        In this default function, if the request is authenticated (typically via a persistent login session),
        the request will proceed.  Otherwise, the user will be redirected to the
        login page. Substitute your own function (via docpad.config) that will perhaps do
        some more complicated checking (eg for user)
         */
        ensureAuthenticated: function(req, res, next) {
          if (req.isAuthenticated()) {
            return next();
          }
          return res.redirect('/login');
        },

        /*
        If you want your app to be able to retrieve a list of users from the membership list
        then you will need to supply a method to this config option - unless you just rely
        on the default simple membership which populates this method automatically.
         */
        getUsers: function() {
          return [];
        },

        /*
        Enable this if you get the `passport.initialize() middleware not in use` error.
        This is caused when another plugin is loaded before the authentication plugin and is
        applying routes before the authentication routes can be applied. This config option
        forces the plugin to manually create the HTTP server and apply the authentication
        routes before any other plugin.
         */
        forceServerCreation: false
      };

      socialLoginClass = require("./social-login");

      AuthenticationPlugin.prototype.createDocPadServer = function() {
        var cfg, docpad, express, http, opts, plugin;
        docpad = this;
        cfg = docpad.getConfig();
        plugin = docpad.getPlugin('authentication');
        docpad.log("info", "Authentication: creating servers");
        opts = {};
        http = require('http');
        express = require('express');
        if (!docpad.serverExpress) {
          opts.serverExpress = express();
          opts.serverHttp = http.createServer(opts.serverExpress);
          if (cfg.middlewareBodyParser !== false) {
            opts.serverExpress.use(express.urlencoded());
            opts.serverExpress.use(express.json());
          }
          docpad.setServer(opts);
          docpad.log("info", "Authentication: servers created");
          return plugin.createSocialLoginClass(opts.serverExpress);
        }
      };

      AuthenticationPlugin.prototype.setConfig = function() {
        var plugin;
        AuthenticationPlugin.__super__.setConfig.apply(this, arguments);
        plugin = this;
        if (plugin.getConfig().forceServerCreation) {
          return plugin.docpadReady = plugin.createDocPadServer;
        }
      };

      AuthenticationPlugin.prototype.getValidStrategies = function() {
        var clientID, clientSecret, count, key, strategies, val;
        strategies = this.config.strategies || {};
        for (key in strategies) {
          val = strategies[key];
          clientID = strategies[key].settings.clientID;
          clientSecret = strategies[key].settings.clientSecret;
          if (!clientID.length > 0) {
            this.docpad.log("warn", this.name + " : " + key + " - clientID required");
            strategies[key] = void 0;
          } else if (!clientSecret.length > 0) {
            this.docpad.log("warn", this.name + " : " + key + " - clientSecret required");
            strategies[key] = void 0;
          }
        }
        count = 0;
        for (key in strategies) {
          count += 1;
        }
        return {
          strategies: strategies,
          count: count
        };
      };

      AuthenticationPlugin.prototype.simpleMembership = require("./simple-membership");

      AuthenticationPlugin.prototype.setUpMembership = function(server) {
        var dataPath, userList;
        if (!this.config.findOrCreate) {
          userList = this.config.userList || null;
          dataPath = this.config.dataPath || this.docpad.getConfig().rootPath;
          this.simpleMembership.init(userList, server, dataPath);
          this.findOrCreate = this.simpleMembership.findOrCreateUser;
          this.makeAdmin = this.simpleMembership.makeAdmin;
          this.saveNewUser = this.simpleMembership.saveNewUser;
          return this.getUsers = this.simpleMembership.getUsers;
        } else {
          this.findOrCreate = this.config.findOrCreate;
          return this.getUsers = this.config.getUsers;
        }
      };

      AuthenticationPlugin.prototype.createSocialLoginClass = function(server) {
        var cfg, docpad, ensureAuthenticated, findOrCreate, plugin, session, site, siteURL, socialConfig, urls;
        docpad = this.docpad;
        plugin = this;
        cfg = docpad.getConfig();
        site = cfg.templateData.site;
        siteURL = site.url ? site.url : 'http://127.0.0.1:' + (cfg.port || '9778');
        if (plugin.config.findOrCreate) {
          docpad.log('info', 'Using user supplied membership');
          findOrCreate = plugin.config.findOrCreate;
        } else {
          docpad.log('info', 'Using simpleMembership');
          findOrCreate = plugin.simpleMembership.findOrCreateUser;
        }
        session = require('express-session');
        server.use(session({
          secret: this.config.sessionSecret,
          saveUninitialized: true,
          resave: true
        }));
        this.socialLogin = new socialLoginClass({
          app: server,
          url: siteURL,
          context: docpad,
          onAuth: function(req, type, uniqueProperty, accessToken, refreshToken, profile, done, docpad) {
            var err, error;
            try {
              findOrCreate({
                profile: profile,
                property: uniqueProperty,
                type: type,
                docpad: docpad
              }, function(user) {
                done(null, user);
              });
            } catch (error) {
              err = error;
              console.log(err);
              return done(err);
            }
          }
        });
        ensureAuthenticated = this.getConfig().ensureAuthenticated;
        socialConfig = this.getValidStrategies();
        if (socialConfig.count > 0) {
          this.socialLogin.use(socialConfig.strategies);
          if (this.config.protectedUrls.length > 0) {
            urls = new RegExp(this.config.protectedUrls.join('|'));
            return server.get(urls, ensureAuthenticated);
          }
        } else {
          return this.docpad.log("warn", this.name + ": no strategies configured. No pages protected by authentication");
        }
      };

      AuthenticationPlugin.prototype.serverExtend = function(opts) {
        var docpad, server;
        server = opts.server;
        docpad = this.docpad;
        if (!this.socialLogin) {
          this.createSocialLoginClass(server);
        }
        this.setUpMembership(server);
        return this;
      };

      return AuthenticationPlugin;

    })(BasePlugin);
  };

}).call(this);
