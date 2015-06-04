# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
fs = require('fs')
path = require('path')
util = require('util')
docpadConfig = {

    # =================================
    # Template Data
    # These are variables that will be accessible via our templates
    # To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

    templateData:

        # Specify some site properties
        site:

            #WATCH OUT HERE - URLS WILL CAUSE YOU NO END OF PROBLEMS WHEN DEALING WITH LOGINS
            #Twitter will not accept 'localhost' as a domain when you set up your app up with them.
            #You must set up your local development url as 127.0.0.1.
            #If you then run your application as localhost and then try and login via twitter
            #it will return you to 127.0.0.1 and NOT localhost and your session will be lost and
            #you will get an internal error. Facebook, on the other hand will not accept 127.0.0.1
            #as a URL.
            url: "http://login-stevehome.rhcloud.com" #this will be overriden in our dev environment
            #url: "http://127.0.0.1:9778"


            # Here are some old site urls that you would like to redirect from
            oldUrls: [
                'www.website.com',
                'website.herokuapp.com'
            ]

            # The default title of our website
            title: "My Authentication Website"

            # The website description (for SEO)
            description: """
                Docpad Authentication test website
                """

            # The website keywords (for SEO) separated by commas
            keywords: """
                docpad, node, authentication, plugin, passport, oauth2
                """

            # The website's styles
            styles: [
                '/vendor/normalize.css'
                '/vendor/h5bp.css'
                '/css/styles.css'
            ]

            # The website's scripts
            scripts: [
                '/vendor/log.js'
                '/vendor/modernizr.js'
            ]


        # -----------------------------
        # Helper Functions

        # Get the prepared site/document title
        # Often we would like to specify particular formatting to our page's title
        # we can apply that formatting here
        getPreparedTitle: ->
            # if we have a document title, then we should use that and suffix the site's title onto it
            if @document.title
                "#{@document.title} | #{@site.title}"
            # if our document does not have it's own title, then we should just use the site's title
            else
                @site.title

        # Get the prepared site/document description
        getPreparedDescription: ->
            # if we have a document description, then we should use that, otherwise use the site's description
            @document.description or @site.description

        # Get the prepared site/document keywords
        getPreparedKeywords: ->
            # Merge the document keywords with the site keywords
            @site.keywords.concat(@document.keywords or []).join(', ')

        getPluginSource: ->
            file = path.join('plugins','docpad-plugin-authentication','src','authentication.plugin.coffee')
            try
                return fs.readFileSync(file,'utf-8')
            catch err
                file = path.join('source','authentication.plugin.coffee')
                try
                    return fs.readFileSync(file,'utf-8')
                catch
                    return "can't find authentication.plugin.coffee"
                
        getDocpadSource: ->
            file = path.join('docpad.coffee')
            try
                return fs.readFileSync(file,'utf-8')
            catch err
                console.log(err)
                return "can't find docpad.coffee"
            
        getObjectJSON: (obj) ->
            return util.inspect(obj)
        

        
        




    # =================================
    # Collections

    # Here we define our custom collections
    # What we do is we use findAllLive to find a subset of documents from the parent collection
    # creating a live collection out of it
    # A live collection is a collection that constantly stays up to date
    # You can learn more about live collections and querying via
    # http://bevry.me/queryengine/guide

    collections:

        # Create a collection called posts
        # That contains all the documents that will be going to the out path posts
        posts: ->
            @getCollection('documents').findAllLive({relativeOutDirPath: 'posts'})


    # =================================
    # Environments

    # DocPad's default environment is the production environment
    # The development environment, actually extends from the production environment

    # The following overrides our production url in our development environment with false
    # This allows DocPad's to use it's own calculated site URL instead, due to the falsey value
    # This allows <%- @site.url %> in our template data to work correctly, regardless what environment we are in
    #env: 'development'
    
    environments:
        development:  # default
            # Always refresh from server
            maxAge: false  # default
            templateData:
                site:
                    url: "http://127.0.0.1:9778"
                    
            plugins:
                authentication:
                    strategies:
                        github:
                            settings:
                                #set development ids in env file
                                clientID: process.env.github_devclientID
                                clientSecret: process.env.github_devclientSecret
                        facebook:
                            settings:
                                clientID: process.env.facebook_devclientID
                                clientSecret: process.env.facebook_devclientSecret


            # Listen to port 9778 on the development environment
            #port: process.env.PORT || process.env.OPENSHIFT_NODEJS_PORT || process.env.OPENSHIFT_INTERNAL_PORT || 9778
        production:
            maxAge: false
            # maxAge: false

            hostname: process.env.OPENSHIFT_NODEJS_IP || '127.0.0.1'
            # Listen to port 8082 on the development environment
            port: process.env.PORT || process.env.OPENSHIFT_NODEJS_PORT || process.env.OPENSHIFT_INTERNAL_PORT || 9778
        static:
            maxAge: 86400000
            # maxAge: false

            hostname: process.env.OPENSHIFT_NODEJS_IP || '127.0.0.1'
            # Listen to port 8082 on the development environment
            port: process.env.PORT || process.env.OPENSHIFT_NODEJS_PORT || process.env.OPENSHIFT_INTERNAL_PORT || 9778

    
    #-------------------------------------------------------------------------------------#
    #Membership related code used by the findOrCreate method passed to the authentication plugin
    writeFile: (obj,name) ->
        fs.writeFileSync(name,util.inspect(obj),'utf-8')
        
    users: []
    
    membershipFile: path.join('membership','membership.json')
    
    writeMembershipFile: ->
        jsonString = JSON.stringify(@users,null,2)
        fs.writeFileSync(@membershipFile,jsonString,'utf-8')
    
    makeAdmin: (id,service) ->
        user = @findOne(id,service)
        user.adminUser = true
        @writeMembershipFile()
        return @findOne(id,service)
    
    findOne: (id,service) ->
        for item in @users
            if item.service_id == id && item.service == service
                return item
        return false
    
    saveNewUser: (user) ->
        if user.isNew and !@findOne(user.service_id,user.service)
            user.our_id = @users.length
            user.isNew = false
            @users.push(user)
            @writeMembershipFile()
               
    findOrCreateUser: (opts) ->
        user = @findOne(opts.profile[opts.property],opts.type)
        if !user
            user =
                our_id: null
                service_id: opts.profile[opts.property]
                service: opts.type
                name: opts.profile.name || opts.profile.username || opts.profile.screen_name
                email: opts.profile.email
                adminUser: false
                linked_ids: []
                isNew: true

        return user
    
    #End Membership code
    #-------------------------------------------------------------------------------------#
            
    # Configure Plugins
    # Should contain the plugin short names on the left, and the configuration to pass the plugin on the right
    plugins:
        authentication:
            protectedUrls: ['/admin/*','/analytics/*','/super-secret-url/*']
            findOrCreate: (opts,done) ->
                #Note: reference to docpad context passed
                #as one of the options
                docpad = opts.docpad
                
                if docpad
                    config = docpad.getConfig()
                    #check membership
                    user = config.findOrCreateUser(opts)
                    done(user)
                else
                    #Huston - we have a problem
                    done("User not checked - couldn't get docpad reference",opts.profile)

            strategies:
                facebook:
                    settings:
                        #if you use a .env file to store the clientID and clientSecret
                        #don't wrap them in quotes as that will be counted as extra characters
                        clientID: process.env.facebook_clientID
                        clientSecret: process.env.facebook_clientSecret
                        authParameters: scope: 'read_stream,manage_pages'
                    url:
                        auth: '/auth/facebook'
                        callback: '/auth/facebook/callback'
                        success: '/'
                        fail: '/login'
                twitter:
                    settings:
                        clientID:  process.env.twitter_clientID
                        clientSecret: process.env.twitter_clientSecret
                    url:
                        auth: '/auth/twitter'
                        callback: '/auth/twitter/callback'
                        success: '/'
                        fail: '/login'
                google:
                    settings:
                        clientID: process.env.google_clientID
                        clientSecret: process.env.google_clientSecret
                        authParameters: scope: ['https://www.googleapis.com/auth/userinfo.profile','https://www.googleapis.com/auth/userinfo.email']
                    url:
                        auth: '/auth/google'
                        callback: '/auth/google/callback'
                        success: '/'
                        fail: '/login'
                github:
                    settings:
                        clientID: process.env.github_clientID
                        clientSecret: process.env.github_clientSecret
                    url:
                        auth: '/auth/github'
                        callback: '/auth/github/callback'
                        success: '/'
                        fail: '/login'


    # =================================
    # DocPad Events

    # Here we can define handlers for events that DocPad fires
    # You can find a full listing of events on the DocPad Wiki

    events:
    
        docpadReady: (opts) ->
            # Prepare
           
            docpad = @docpad
            config = docpad.getConfig()
            locale = @locale
            jsonString = "[]"
            try
                jsonString = fs.readFileSync(config.membershipFile,'utf-8')
            catch
                fs.writeFileSync(config.membershipFile,jsonString,'utf-8')
            
            config.users = JSON.parse(jsonString)

            

        # Server Extend
        # Used to add our own custom routes to the server before the docpad routes are added
        serverExtend: (opts) ->
            # Extract the server from the options
            {server} = opts
            docpad = @docpad

            # As we are now running in an event,
            # ensure we are using the latest copy of the docpad configuraiton
            # and fetch our urls from it
            latestConfig = docpad.getConfig()
            oldUrls = latestConfig.templateData.site.oldUrls or []
            newUrl = latestConfig.templateData.site.url

            # Redirect any requests accessing one of our sites oldUrls to the new site url
            server.use (req,res,next) ->

                if req.headers.host in oldUrls
                    res.redirect(newUrl+req.url, 301)
                else
                    next()
            #url to make a user admin
            server.get /\/makeAdmin/, (req,res,next) ->
                user = req.user
                user = latestConfig.makeAdmin(user.service_id,user.service)
                req.login user, (err) ->
                    if err
                        next(err)
                    res.redirect('/admin')
                    
                    
            server.get '/' , (req,res,next) ->
                if req.user and req.user.isNew
                    res.redirect('/sign-up')
                else
                    next()
                    
            server.post '/createAccount' , (req,res,next) ->
                name = req.body.NickName
                if name and req.user and req.user.isNew
                    req.user.name = name
                    latestConfig.saveNewUser(req.user)
                    res.redirect('/')
                else
                    next()
           
}

# Export our DocPad Configuration
module.exports = docpadConfig
