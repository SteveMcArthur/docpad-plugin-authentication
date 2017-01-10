# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    request = require('request')
    fs = require('fs')
    util = require('util')
    pathUtil = require('path')
 
    # Define My Tester
    class AuthSetup2 extends testers.ServerTester
        


        # Custom test for the server
        testServer: (next) ->
            # Prepare
            tester = @

            # Create the server
            super
            
            forceServer = false
            forceServer = if tester.config.msg then tester.config.msg.forceServerCreation || false
            msg =  if forceServer  then "forceServerCreation: " else ""
            
 
            # Test
            @suite 'Check plugin does not clash with other plugins', (suite,test) ->
                # Prepare
                plugin = tester.docpad.getPlugin('authentication')
                aardvarkPlugin = tester.docpad.getPlugin('aardvark')
                baseUrl = "http://localhost:#{tester.docpad.config.port}"
                loginTitleReg = /\<title\>Login Page\<\/title\>/
                
                test 'aardvark is loaded', (done) ->
                    expect(aardvarkPlugin).to.be.an('object')
                    done()

                
                ###
                test 'forceServerCreation should be true', (done) ->
                    val = plugin.getConfig().forceServerCreation || false
                    expect(val).to.equal(true)
                    done()
                ###
                    
                test 'call aardvark route', (done) ->
                    fileUrl = "#{baseUrl}/aardvark"
                    request fileUrl, (err,response,actual) ->
                        return done(err)  if err
                        actualStr = actual.toString()
                        console.log(actual)
                        expectedStr = "Ethel The Aardvark Goes Quantity Surveying"
                        expect(actualStr).to.equal(expectedStr)
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
                        