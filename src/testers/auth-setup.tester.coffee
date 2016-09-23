# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    request = require('request')
    fs = require('fs')
    util = require('util')

    # Define My Tester
    class AuthSetup extends testers.ServerTester
        # Test Generate
        testGenerate: testers.RendererTester::testGenerate

        # Custom test for the server
        testServer: (next) ->
            # Prepare
            tester = @

            # Create the server
            super
            
            msg = tester.config.msg || ""
            forceServer =  if msg != "" then true else false
 
            # Test
            @suite msg+' auth setup', (suite,test) ->
                # Prepare
                baseUrl = "http://localhost:#{tester.docpad.config.port}"
                outExpectedPath = tester.config.outExpectedPath
                plugin = tester.docpad.getPlugin('authentication')
                
                    
                test 'getValidStrategies should return count of 1', (done) ->
                    count = plugin.getValidStrategies().count
                    expect(count).to.equal(1)
                    done()

                test 'forceServerCreation should be '+forceServer, (done) ->
                    expect(plugin.getConfig().forceServerCreation).to.equal(forceServer)
                    done()


                test 'server should redirect to login page when not authenticated: admin.html', (done) ->
                    fileUrl = "#{baseUrl}/admin.html"
                    request fileUrl, (err,response,actual) ->
                        return done(err)  if err
                        actualStr = actual.toString()
                        console.log(actual)
                        expectedStr = 'Login'
                        expect(actualStr).to.equal(expectedStr)
                        done()
                        
                test 'server should redirect to login page when not authenticated: analytics.html', (done) ->
                    fileUrl = "#{baseUrl}/analytics.html"
                    request fileUrl, (err,response,actual) ->
                        return done(err)  if err
                        actualStr = actual.toString()
                        expectedStr = 'Login'
                        expect(actualStr).to.equal(expectedStr)
                        done()
                        