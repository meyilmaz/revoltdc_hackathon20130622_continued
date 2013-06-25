Meteor.startup ->
  Meteor.autorun ->
    document.title = Session.get('document-title');

Meteor.methods 
    checkSunlight: (query) ->
        return "Loading"
    
    
Meteor.Router.add
    '/test':'somedata',
    '/nice/:query': (query)->
            Meteor.call("checkSunlight",query,
                (err,res)->
                    Session.set("result",res)
            )
            return "nice"
    '/capitol/:query': (query)->
            Meteor.apply("checkCapitolWords", {query},true,
                (err,res)->
                    console.log(err)
                    Session.set("result",res)
            )
            return "capitol"
    
        

Template.nice.rendered =->
    Session.set("document-title","testing")
    console.log "test"
    "blah"

Template.nice.helpers
        result: ->
            console.log(Session.get("result"))
            return Session.get("result")

Template.capitol.helpers
        result: ->
            console.log(Session.get("result"))
            
            return Session.get("result")
        cloud: ->
            words = Session.get("result")
            console.log words
            scriptn = "<script>cloud.make({ width: 1000,height: 800, font: 'Helvetica', container: '#wordcloud',words: ["
            words.forEach (element, index, array)->
                scriptn +=  "{text:'"+element.ngram+"', size: "+element.count+"},"
            
            scriptn +="].map(function(d) {return {text: d.text, size: (d.size/100)};})})</script>"
            return scriptn