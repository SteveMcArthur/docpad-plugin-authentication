
# Test our plugin using DocPad's Testers
pathUtil = require('path')
fs = require('fs')
testerBase =
    pluginPath: __dirname+'/..'
    autoExit: 'safe'
    
getTesterConfig = (name,msg) ->
    config = JSON.parse(JSON.stringify(testerBase))
    config.testerPath = pathUtil.join('out','testers', name+".tester.js")
    config.msg = msg
    return config

ensureAuthenticated = (req, res, next) ->
    if req.isAuthenticated()
        return next()
    res.redirect('/login.html')

docpadConfig =
    templateData:
        site:
            url: 'http://127.0.0.1'
    plugins:
        authentication:
            protectedUrls: ['/admin.html','/analytics.html']
            ensureAuthenticated: ensureAuthenticated
            strategies:
                github:
                    settings:
                        clientID: '123456'
                        clientSecret: 'qwertyuiop1234567890'
                        #clientID: process.env.github_clientID
                        #clientSecret: process.env.github_clientSecret
                    url:
                        auth: '/auth/github'
                        callback: '/auth/github/callback'
                        success: '/login-success.html'
                        fail: '/login-fail.html'
                        
docpadConfig2 = JSON.parse(JSON.stringify(docpadConfig))
docpadConfig2.plugins.authentication.ensureAuthenticated = ensureAuthenticated
docpadConfig2.plugins.authentication.forceServerCreation = true

require('docpad').require('testers')
    .test(getTesterConfig('properties-exist'),docpadConfig)
    .test(getTesterConfig('auth-setup'),docpadConfig)
    .test(getTesterConfig('auth-setup','forceServerCreation: '),docpadConfig2)
    .test(getTesterConfig('login'),docpadConfig)
    .test(getTesterConfig('login','forceServerCreation: '),docpadConfig2)