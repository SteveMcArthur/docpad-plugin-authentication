# Authentication Plugin for [DocPad](http://docpad.org)

[![Build Status](https://img.shields.io/travis/SteveMcArthur/docpad-plugin-authentication/master.svg)](https://travis-ci.org/SteveMcArthur/docpad-plugin-authentication "Check this project's build status on TravisCI")
[![NPM version](https://img.shields.io/npm/v/docpad-plugin-authentication.svg)](https://www.npmjs.com/package/docpad-plugin-authentication "View this project on NPM")
[![NPM downloads](https://img.shields.io/npm/dm/docpad-plugin-authentication.svg)](https://www.npmjs.com/package/docpad-plugin-authentication "View this project on NPM")

Handles authentication and login functionality via social login for your docpad application. Protects pages from unauthenticated users. Uses the node module [social-login](https://github.com/26medias/social-login) to standardise the configuration interface to the various login strategies and handle routing and redirection.

**Note:** Please ensure you install the latest version as a number of bug fixes were implemented in v2.0.7

## Support ##
The following services are supported:

*   facebook
*   twitter
*   google
*   github

The following services were removed as dependencies with version 2.3.0. Mainly because there was little demand for them and so were unecessary dependencies. If those services are required, add the corresponding dependency to the package.json file.

*   instagram
*   linkedin
*   amazon
*   dropbox
*   foursquare
*   imgur
*   meetup
*   wordpress
*   tumblr


## Install

### Install the Plugin

```
docpad install authentication
```
or
```
npm install docpad-plugin-authentication --save
```

## Configure

Example configurations for facebook, twitter, google and gihub in the [docpad configuration file](https://docpad.org/docs/config):

``` coffee
# ...

    #-------------------------------------------------------------------------------------#
    #Membership related code used by the findOrCreate method passed to the authentication plugin
        
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
   
    plugins:
        authentication:
            #list of urls that will be protected by authentication 
            protectedUrls: ['/admin/*','/analytics/*','/super-secret-url/*']
            
            ###
            This is a simple example of a method use to check
            membership. All it does is check the user id returned
            by the service is in the validUsers array in the docpad
            config. In a real world app you would probably want to look-up
            membership in a seperate list or database
            ###
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
                    #Houston - we have a problem
                    done("User not checked - couldn't get docpad reference",opts.profile)
                    
            ###
            Middleware function to ensure user is authenticated.
            This will be applied to any url in the protectedUrls config option.
            In this default function, if the request is authenticated (typically via a persistent login session),
            the request will proceed.  Otherwise, the user will be redirected to the
            login page. Substitute your own function (via docpad.config) that will perhaps do
            some more complicated checking (eg for user)
            ###
            ensureAuthenticated: (req, res, next) ->
                if req.isAuthenticated()
                    return next();
            
                res.redirect('/login') 
                
            ###
            configuration parameters for the various authentication
            strategies. You will normally need to create an application
            via the various services developer consoles to get a the
            appropriate clientIDs and clientSecrets (sometimes called things
            like consumer key/secrets or API key/secrets). Recommended that you
            store these values in an environment file (https://docpad.org/docs/config)
            and added to your .gitignore file
            ###
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
                        
    environments:
        development:
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



# ..
```
Note: You don't need to configure a logout URL unless you want to use a URL other than '/logout'.

Similar configuration for the other services available.

**No implementation of membership**

There is no implementation of membership with this plugin. This is deliberate. So, out of the box the plugin is not a complete login solution. You need to supply your own membership system. For a simple personal blog this can be a configuration in the docpad.coffee file with a hard coded list of members, probably just yourself. For a few more members you might just store the list in a file. The next step is then to go to a database. All of these will work without the plugin locking you in to one system. Somewhere down the line I intend to create a seperate plugin that will implement a membership system using both the filesystem or a mongo db - but even without that it is straight forward to create your own system.


**Please note**

Much of the correct functioning of this plugin depends on the correct configuration on the side of the various services developer consoles. In particular, pay attention to URLs. Some services do not work well with localhost/127.0.0.1. I couldn't get facebook to work on localhost. Make sure the domain of your login button is on the same domain that the service returns you to. Seems obvious, but in testing I had a login page on 127.0.0.1 and the service was returning me to localhost. You will lose your session if you do that - and it may not be obvious why.

**How to work out if it is your setup causing problems or your configuration of a particular service**

Use github to test your own application, even if you don't intend to use github as your login service. If login works with github but not another service, chances are that the problem is with your configuration of the particular service that is failing. Some services are more difficult to configure correctly than others, but github seems to be the easiest. Also check the url returned by a failing service. Often there is information in the response header or query parameters returned by the service.

**Don't test in development mode with live reload**

To write out any information, such as username, that is returned from the login, you will need to mark the page as dynamic (and install the [clean urls plugin](https://www.npmjs.com/package/docpad-plugin-cleanurls)). However, this seems to cause a problem when in development mode and the live reload. I don't think this is specific to this plugin, but it means you will end up in a loop of the page regenerating and reloading. It's best to just remove the [livereload plugin](https://www.npmjs.com/package/docpad-plugin-livereload). Delete it from the package.json file and the node_modules directory.

**Plugin checks for configured authentication strategies**

The plugin now checks the configured authentication strategies all have a clientID and clientSecret. If not, these strategies are removed and a warning issued through the console. If no strategies are configured, a warning will be issued that no pages will be protected by authentication.

## Example

For a working example using twitter, facebook, google and github, refer to the [My Authentication Website](http://login-stevehome.rhcloud.com)


## License

Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT license](http://creativecommons.org/licenses/MIT/)

Copyright &copy; 2015+ Steve McArthur <steve@stevemcarthur.co.uk> (http://www.stevemcarthur.co.uk)
