# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    request = require('request')
    fs = require('fs')
    util = require('util')

    # Define My Tester
    class AuthSetup extends testers.ServerTester
        
        # Custom test for the server
        testServer: (next) ->
            # Prepare
            tester = @

            # Create the server
            super
            
            forceServer = false
            forceServer = if tester.config.msg then tester.config.msg.forceServerCreation || false
            if forceServer is undefined
                forceServer = false
            msg =  if forceServer  then "forceServerCreation: " else ""
            
 
            # Test
            @suite msg+' auth setup', (suite,test) ->
                # Prepare
                baseUrl = "http://localhost:#{tester.docpad.config.port}"
                loginTitleReg = /\<title\>Login Page\<\/title\>/
                outExpectedPath = tester.config.outExpectedPath
                plugin = tester.docpad.getPlugin('authentication')
                
                
                test 'ensureAuthenticated method exists', (done) ->
                    expect(plugin.getConfig().ensureAuthenticated).to.be.instanceof(Function)
                    done()
                
                    
                test 'getValidStrategies should return count of 1', (done) ->
                    count = plugin.getValidStrategies().count
                    expect(count).to.equal(1)
                    done()

                test 'forceServerCreation should be '+forceServer, (done) ->
                    val = plugin.getConfig().forceServerCreation || false
                    expect(val).to.equal(forceServer)
                    done()


                test 'server should redirect to login page when not authenticated: admin.html', (done) ->
                    fileUrl = "#{baseUrl}/admin.html"
                    request fileUrl, (err,response,actual) ->
                        return done(err)  if err
                        m = (actual.toString()).match(loginTitleReg)
                        expect(m).to.not.be.null
                        done()
                        
                test 'server should redirect to login page when not authenticated: analytics.html', (done) ->
                    fileUrl = "#{baseUrl}/analytics.html"
                    request fileUrl, (err,response,actual) ->
                        return done(err)  if err
                        m = (actual.toString()).match(loginTitleReg)
                        expect(m).to.not.be.null
                        done()
                        