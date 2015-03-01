# Authentication Plugin for [DocPad](http://docpad.org)

Handles authentication and login functionality via social login for your docpad application. Protects pages from unauthenticated users. Uses the node module [social-login](https://github.com/26medias/social-login) to standardise the configuration interface to the various login strategies and handle routing and redirection.

**Note:** Please ensure you install the latest version as a number of bug fixes were implemented in v2.0.4

## Support ##
The following services are supported:

*   facebook
*   twitter
*   google
*   github

Not yet tested but should work in theory

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
            your own method that will look up membership by
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
                    settings:
                        clientID: "YOUR_CLIENT_ID"
                        clientSecret: "YOUR_CLIENT_SECRET"
                        authParameters: scope: ['https://www.googleapis.com/auth/userinfo.profile','https://www.googleapis.com/auth/userinfo.email']
                    url:
                        auth: '/auth/google'
                        callback: '/auth/google/callback'
                        success: '/'
                        fail: '/auth/google/fail'
                github:
                    settings:
                        clientID: "YOUR_CLIENT_ID"
                        clientSecret: "YOUR_CLIENT_SECRET"
                    url:
                        auth: '/auth/github'
                        callback: '/auth/github/callback'
                        success: '/'
                        fail: '/auth/github/fail'


# ..
```
Similar configuration for the other services available.

**Please note**

Much of the correct functioning of this plugin depends on the correct configuration on the side of the various services developer consoles. In particular, pay attention to URLs. Some services do not work well with localhost/127.0.0.1. I couldn't get facebook to work on localhost. Make sure the domain of your login button is on the same domain that the service returns you to. Seems obvious, but in testing I had a login page on 127.0.0.1 and the service was returning me to localhost. You will lose your session if you do that - and it may not be obvious why.

**Don't test in development mode with dynamic pages**

To write out any information, such as username, that is returned from the login, you will need to mark the page as dynamic (and install the [clean urls plugin](https://www.npmjs.com/package/docpad-plugin-cleanurls)). However, this seems to cause a problem when in development mode and the live reload. I don't think this is specific to this plugin, but it means you will end up in a loop of the page regenerating and reloading.

## Example

For a working example using twitter, facebook and google, refer to the [My Authentication Website](http://login-stevehome.rhcloud.com)


## License

Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT license](http://creativecommons.org/licenses/MIT/)

Copyright &copy; 2015+ Steve McArthur <steve@stevemcarthur.co.uk> (http://www.stevemcarthur.co.uk)
