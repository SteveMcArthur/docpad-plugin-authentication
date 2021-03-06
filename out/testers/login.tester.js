// Generated by CoffeeScript 1.10.0
(function() {
  var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  module.exports = function(testers) {
    var LoginTester, expect, fs, request, util;
    expect = require('chai').expect;
    request = require('request');
    fs = require('fs');
    util = require('util');
    return LoginTester = (function(superClass) {
      extend(LoginTester, superClass);

      function LoginTester() {
        return LoginTester.__super__.constructor.apply(this, arguments);
      }

      LoginTester.prototype.testServer = function(next) {
        var forceServer, githubSignInReg, msg, tester;
        tester = this;
        LoginTester.__super__.testServer.apply(this, arguments);
        msg = tester.config.msg + " " || "";
        forceServer = msg !== "" ? true : false;
        githubSignInReg = /<title>(Sign in to GitHub).*<\/title>/;
        return this.suite(msg + 'login', function(suite, test) {
          var baseUrl, outExpectedPath, plugin;
          baseUrl = "http://localhost:" + tester.docpad.config.port;
          outExpectedPath = tester.config.outExpectedPath;
          plugin = tester.docpad.getPlugin('authentication');
          return test('test redirect to github sign in page', function(done) {
            var fileUrl;
            fileUrl = baseUrl + "/auth/github";
            return request(fileUrl, function(err, response, actual) {
              var actualStr, expectedStr, m;
              if (err) {
                return done(err);
              }
              m = actual.match(githubSignInReg);
              actualStr = m ? m[1] : "";
              expectedStr = 'Sign in to GitHub';
              expect(actualStr).to.equal(expectedStr);
              return done();
            });
          });
        });
      };

      return LoginTester;

    })(testers.ServerTester);
  };

}).call(this);
