
# Test our plugin using DocPad's Testers
testerConfig =
    pluginPath: __dirname+'/..'
    autoExit: 'safe'
docpadConfig =
    templateData:
        site:
            url: 'http://127.0.0.1'
    plugins:
        authentication:
            protectedUrls: ['/admin.html','/analytics.html']
            ensureAuthenticated: (req, res, next) ->
                if req.isAuthenticated()
                    return next()
                res.redirect('/login.html')
            strategies:
                github:
                    settings:
                        clientID: '123456'
                        clientSecret: 'qwertyuiop1234567890'
                    url:
                        auth: '/auth/github'
                        callback: '/auth/github/callback'
                        success: '/'
                        fail: '/login.html'

require('docpad').require('testers')
    .test(testerConfig,docpadConfig)