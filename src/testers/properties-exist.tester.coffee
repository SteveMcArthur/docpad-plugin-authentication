# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    request = require('request')
    fs = require('fs')
    util = require('util')

    # Define My Tester
    class PropertiesExistTester extends testers.ServerTester
   
        # Custom test for the server
        testServer: (next) ->
            # Prepare
            tester = @

            # Create the server
            super
            
            @suite 'plugin properites', (suite,test) ->
            
                plugin = tester.docpad.getPlugin('authentication')
                config = plugin.getConfig()

                @suite 'config properties exist', (suite,test,done) ->
                    expectedConfig = [
                        "sessionSecret",
                        "protectedUrls",
                        "strategies",
                        "ensureAuthenticated",
                        "getUsers",
                        "forceServerCreation"
                    ]

                    expectedConfig.forEach (item) ->
                        test item+' property', () ->
                            expect(config).to.have.property(item)

                    done()

                @suite 'plugin properties exist', (suite,test,done) ->
                    expectedConfig = [
                        #"socialLoginClass",
                        #"simpleMembership",
                        "socialLogin"
                    ]

                    expectedConfig.forEach (item) ->
                        test item+' property', () ->
                            expect(plugin).to.have.property(item)

                    done()

                @suite 'plugin methods are functions', (suite,test,done) ->
                    expectedMethods = [
                        "createDocPadServer",
                        "getValidStrategies",
                        "setUpMembership",
                        "createSocialLoginClass",
                        "serverExtend"
                    ]

                    expectedMethods.forEach (item) ->
                        test item+' method', () ->
                            console.log(item)
                            expect(plugin[item]).to.be.instanceof(Function)

                    done()



                        
                        