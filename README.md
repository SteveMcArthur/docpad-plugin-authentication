# Authentication Plugin for [DocPad](http://docpad.org)

<!-- INSTALL/ -->

Handles authentication and login functionality via social login for your docpad application. Protects pages from unauthenticated users. Uses the node module [social-login](https://github.com/26medias/social-login) to standardise the configuration interface to the various login strategies and handle routing and redirection.


## Support ##
The following services are supported:

*   facebook
*   twitter
*   google
*   github
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

Example configurations for facebook, twitter and google in the [docpad configuration file](https://docpad.org/docs/config):

``` coffee
# ...
    plugins:
        authentication:
            #list of urls that will be protected by authentication
            protectedUrls: ['/admin/*','/analytics/*']
            
            ###
            lookup function to retrieve membership details after
            authentication. Probably want to replace it with
            your own method that will look up a memebership by
            some method (json file, db?)
            ###
            findOrCreate: (opts,done) ->
                done opts.profile #make sure this is called and the profile or user data is returned
                
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
                        clientID: "YOUR_API_KEY"
                        clientSecret: "YOUR_API_SECRET"
                        authParameters: scope: 'read_stream,manage_pages'
                    url:
                        auth: '/auth/facebook'
                        callback: '/auth/facebook/callback'
                        success: '/'
                        fail: '/login'
                twitter:
                    settings:
                        clientID: "YOUR_API_KEY"
                        clientSecret: "YOUR_API_SECRET"
                    url:
                        auth: '/auth/twitter'
                        callback: '/auth/twitter/callback'
                        success: '/'
                        fail: '/login'
                google:
                    settings: {}
                    url:
                        auth: '/auth/google'
                        callback: '/auth/google/callback'
                        success: '/'
                        fail: '/auth/google/fail'

# ..
```
Similar configuration for the other services available.

<!-- LICENSE/ -->

## License

Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT license](http://creativecommons.org/licenses/MIT/)

Copyright &copy; 2015+ Steve McArthur <steve@stevemcarthur.co.uk> (http://www.stevemcarthur.co.uk)

<!-- /LICENSE -->
