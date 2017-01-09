# Export Plugin
module.exports = (BasePlugin) ->
    # Define Plugin
    console.log("GOT AATESTER....")
    class AaTester extends BasePlugin
        
        # Plugin name
        name: 'aatester'

        config: {}
        
        
        setConfig: ->
            super
            @docpad.log('info',"aatester loaded...")
            
            
        # Use to extend the server with routes that will be triggered before the DocPad routes.
        serverExtend: (opts) ->
            # Extract the server from the options
            {server} = opts
            
            server.get '/something', (req,res,next) ->
                txt = "Something..."
                console.log(txt)
                res.send(txt)