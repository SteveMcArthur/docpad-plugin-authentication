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
                plugin = tester.docpad.getPlugin('authentication')
                
                test 'plugin config should have strategy property', (done) ->
                    config = plugin.getConfig()
                    expect(config).to.have.property('strategies')
                    done()
                    
                test 'plugin config should have protectedUrls property', (done) ->
                    config = plugin.getConfig()
                    expect(config).to.have.property('protectedUrls')
                    done()
                    
                test 'plugin should have getValidStrategies property', (done) ->
                    expect(plugin).to.have.property('getValidStrategies')
                    done()
                    
                test 'getValidStrategies should return count of 1', (done) ->
                    count = plugin.getValidStrategies().count
                    expect(count).to.equal(1)
                    done()
                
                test 'plugin should have socialLogin property', (done) ->
                    expect(plugin).to.have.property('socialLogin')
                    done()

                test 'server should redirect to login page when not authenticated: admin.html', (done) ->
                    fileUrl = "#{baseUrl}/admin.html"
                    request fileUrl, (err,response,actual) ->
                        return done(err)  if err
                        actualStr = actual.toString()
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
                        

                    
                    
                
                    
                
                    
                
                    
                    


