# Export Plugin
module.exports = (BasePlugin) ->
    # Define Plugin
    class AuthenticationPlugin extends BasePlugin
        # Plugin name
        name: 'authentication'

        config:
            #list of urls that will be protected by authentication
            protectedUrls: ['/admin/*','/analytics/*']

            ###
            lookup function to retrieve membership details after
            authentication. Probably want to replace it with
            your own method that will look up a membership by
            some method (json file, db?)
            ###
            findOrCreate: (opts,done) ->
                done opts.profile #make sure this is called and the profile or user data is returned

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

        #class that contains and manages all the login strategys
        socialLoginClass = require("./social-login")
        #need this to persist login/authentication details
        session = require('express-session')

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

       

        serverExtend: (opts) ->
            # Extract the server from the options
            {server} = opts
            docpad = @docpad
            # As we are now running in an event,
            # ensure we are using the latest copy of the docpad configuraiton
            # and fetch our urls from it
            latestConfig = docpad.getConfig()
            siteURL = latestConfig.templateData.site.url

            server.use session
                secret: 'jajabinks&%',
                saveUninitialized: true,
                resave: true

            findOrCreate = @config.findOrCreate
            ensureAuthenticated = @config.ensureAuthenticated
            #this class adds most of the routes that handle
            #the login and redirection process
            socialLogin = new socialLoginClass(
                app: server
                url: siteURL
                context: docpad
                onAuth: (req, type, uniqueProperty, accessToken, refreshToken, profile, done, docpad) ->
  
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
            )


            socialConfig = @getValidStrategies()
            #prior to 2.0.7 docpad would fall over
            #if no strategies were configured
            if socialConfig.count > 0
                #Pass the various settings for the
                #various services to the socialLogin class
                socialLogin.use(socialConfig.strategies)

                #protect the configured URLs
                if @config.protectedUrls.length > 0
                    urls = new RegExp(@config.protectedUrls.join('|'))
                    server.get urls,ensureAuthenticated
            else
                @docpad.log("warn",@name + ": no strategies configured. No pages protected by authentication")


            @
