# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    request = require('request')
    fs = require('fs')
    util = require('util')

    # Define My Tester
    class MyTester extends testers.ServerTester
        # Test Generate
        testGenerate: testers.RendererTester::testGenerate

        # Custom test for the server
        testServer: (next) ->
            # Prepare
            tester = @

            # Create the server
            super

            # Test
            @suite 'authentication', (suite,test) ->
                # Prepare
                baseUrl = "http://localhost:#{tester.docpad.config.port}"
                outExpectedPath = tester.config.outExpectedPath
                fileUrl = "#{baseUrl}/admin.html"

                test 'server should redirect to login page when not authenticated', (done) ->
                    request fileUrl, (err,response,actual) ->
                        return done(err)  if err
                        actualStr = actual.toString()
                        expectedStr = 'Login'
                        expect(actualStr).to.equal(expectedStr)
                        done()
                        
                test 'plugin config should have strategy property', (done) ->
                    config = tester.docpad.getPlugin('authentication').getConfig()
                    expect(config).to.have.property('strategies')
                    done()
                    
                    
                
                    
                
                    
                
                    
                    


