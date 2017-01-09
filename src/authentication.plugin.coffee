# Export Plugin
module.exports = (BasePlugin) ->
    # Define Plugin
    fs = require('fs')
    util = require('util')
    class AuthenticationPlugin extends BasePlugin
        # Plugin name
        name: 'authentication'

        config:
            sessionSecret: 'k%AjPwe9%l;wiYMQd££'+(new Date()).getMilliseconds()
            #list of urls that will be protected by authentication
            protectedUrls: ['/admin/*','/analytics/*']
                        
            ###
            lookup function to retrieve membership details after
            authentication. Probably want to replace it with
            your own method that will look up a membership by
            some method (json file, db?)

            findOrCreate: (opts,done) ->
                done opts.profile #make sure this is called and the profile or user data is returned
            ###

            ###
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
            ###

            ###
            Middleware function to ensure user is authenticated.
            This will be applied to any urls in the protectedUrls config option.
            In this default function, if the request is authenticated (typically via a persistent login session),
            the request will proceed.  Otherwise, the user will be redirected to the
            login page. Substitute your own function (via docpad.config) that will perhaps do
            some more complicated checking (eg for user)
            ###
            ensureAuthenticated: (req, res, next) ->
                if req.isAuthenticated()
                    return next()
                res.redirect('/login')
                
            ###
            If you want your app to be able to retrieve a list of users from the membership list
            then you will need to supply a method to this config option - unless you just rely
            on the default simple membership which populates this method automatically.
            ###
            getUsers: () ->
                return []
            
            forceServerCreation: false


        #class that contains and manages all the login strategys
        socialLoginClass = require("./social-login")
        
        createDocPadServer: () ->
            docpad = @
            plugin = docpad.getPlugin('authentication')
            docpad.log("info","Authentication: creating servers")
            opts = {}
            http = require('http')
            express = require('express')
            if !docpad.serverExpress
                opts.serverExpress = express()
                opts.serverHttp = http.createServer(opts.serverExpress)
                docpad.setServer(opts)
                docpad.log("info","Authentication: servers created")
                plugin.createSocialLoginClass(opts.serverExpress)
                
        setConfig: ->
            super
            plugin = @
            if plugin.getConfig().forceServerCreation
                plugin.docpadReady = plugin.createDocPadServer


        #check all strategies passed to config have values
        #for their clientID or clientSecret. If not, remove
        #those strtegies
        getValidStrategies: ->
            strategies = @config.strategies or {}

            for key, val of strategies
                clientID = strategies[key].settings.clientID
                clientSecret = strategies[key].settings.clientSecret
                if !clientID.length > 0
                    @docpad.log("warn",@name + " : "+key+" - clientID required")
                    strategies[key] = undefined
                else if !clientSecret.length > 0
                    @docpad.log("warn",@name + " : "+key+" - clientSecret required")
                    strategies[key] = undefined

            count = 0
            count += 1 for key of strategies

            return {strategies,count}
        
        simpleMembership: require("./simple-membership")

        setUpMembership: (server) ->
            #if the user hasn't passed findOrCreate to
            #the plugin config then use the default
            #membership system
            if !@config.findOrCreate
                userList = @config.userList or null
                dataPath = @config.dataPath or @docpad.getConfig().rootPath
                @simpleMembership.init(userList,server,dataPath)
                @findOrCreate = @simpleMembership.findOrCreateUser
                @makeAdmin = @simpleMembership.makeAdmin
                @saveNewUser = @simpleMembership.saveNewUser
                @getUsers = @simpleMembership.getUsers
            else
                @findOrCreate = @config.findOrCreate
                @getUsers = @config.getUsers
                
        createSocialLoginClass: (server) ->
            docpad = @docpad
            plugin = @
            
            cfg = docpad.getConfig()
            site = cfg.templateData.site
            siteURL = if site.url then site.url else 'http://127.0.0.1:' + (cfg.port or '9778')
                
            if plugin.config.findOrCreate
                docpad.log('info','Using user supplied membership')
                findOrCreate = plugin.config.findOrCreate
            else
                docpad.log('info','Using simpleMembership')
                findOrCreate = plugin.simpleMembership.findOrCreateUser
                
                
            #need this to persist login/authentication details
            session = require('express-session')

            server.use session
                secret: @config.sessionSecret,
                saveUninitialized: true,
                resave: true
            
            #this class adds most of the routes that handle
            #the login and redirection process
            @socialLogin = new socialLoginClass(
                app: server
                url: siteURL
                context: docpad
                onAuth: (req, type, uniqueProperty, accessToken, refreshToken, profile, done, docpad) ->
                    try
                        findOrCreate {
                            profile: profile
                            property: uniqueProperty
                            type: type
                            docpad: docpad
                        }, (user) ->
                            done null, user
                            # Return the user and continue
                            return
                        return
                    catch err
                        console.log(err)
                        done(err)
            )

            ensureAuthenticated = @getConfig().ensureAuthenticated

            socialConfig = @getValidStrategies()
            #prior to 2.0.7 docpad would fall over
            #if no strategies were configured
            if socialConfig.count > 0
                #Pass the various settings for the
                #various services to the socialLogin class
                @socialLogin.use(socialConfig.strategies)

                #protect the configured URLs
                if @config.protectedUrls.length > 0
                    urls = new RegExp(@config.protectedUrls.join('|'))
                    server.get urls,ensureAuthenticated
            else
                @docpad.log("warn",@name + ": no strategies configured. No pages protected by authentication")
                
                

        serverExtend: (opts) ->
            # Extract the server from the options
            {server} = opts
            docpad = @docpad
            
            if !@socialLogin
                @createSocialLoginClass(server)
              
            @setUpMembership(server)
            @

