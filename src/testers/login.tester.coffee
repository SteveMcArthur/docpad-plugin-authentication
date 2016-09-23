# Export Plugin Tester
module.exports = (testers) ->
    # PRepare
    {expect} = require('chai')
    request = require('request')
    fs = require('fs')
    util = require('util')

    # Define My Tester
    class LoginTester extends testers.ServerTester
        # Test Generate
        #testGenerate: testers.RendererTester::testGenerate

        # Custom test for the server
        testServer: (next) ->
            # Prepare
            tester = @

            # Create the server
            super
            
            msg = tester.config.msg+" " || ""
            forceServer =  if msg != "" then true else false
            githubSignInReg = /<title>(Sign in to GitHub).*<\/title>/

            # Test
            @suite msg+'login', (suite,test) ->
                # Prepare
                baseUrl = "http://localhost:#{tester.docpad.config.port}"
                outExpectedPath = tester.config.outExpectedPath
                plugin = tester.docpad.getPlugin('authentication')


                test 'test redirect to github sign in page', (done) ->
                    fileUrl = "#{baseUrl}/auth/github"
                    request fileUrl, (err,response,actual) ->
                        return done(err)  if err
                        m = actual.match(githubSignInReg)
                        actualStr = if m then m[1] else ""
                        expectedStr = 'Sign in to GitHub'
                        expect(actualStr).to.equal(expectedStr)
                        done()
                        