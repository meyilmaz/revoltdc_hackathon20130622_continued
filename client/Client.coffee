Meteor.methods 
    checkSunlight: (query) ->
        return "Loading"
    
localbiocollection = new Meteor.Collection(null)

localbiocollection.find().observe(
        added: (doc,beforeIndex)->
            console.log(Session)
            console.log(doc)
)
        

Meteor.autorun ->
    bioquery = Session.get("bioquery")
    if bioquery
        bioquery_result = Meteor.call("fetchBiographic", bioquery,
                                (err,res) ->
                                    localbiocollection.insert(res)
                            )
    
Meteor.Router.add
    '/test':'somedata',
    '/nice/:query': (query)->
            Meteor.call("checkSunlight",query,
                (err,res)->
                    Session.set("result",res)
            )
            return "nice"
    '/capitol/:query': (query)->
            res = Meteor.call("checkCapitolWords", query,
                    (err,res)->  
                     Session.set("result",res)
            )
            console.log(res)
            console.log("set session result")
            
            return "capitol"
    '/bio/:query': (query) ->
            Session.set("bioquery",query)
            #Session.set("biographic",bio)
            Session.set("federal",true)
            #console.log(bio)
            #externalcall_dep.changed()
            return "bio"
Template.header.helpers
    federal: ->
        if Session.get("federal") == true
            return "header_capitol_selected"
        else
            return "header_capitol"

Template.nice.rendered =->
    Session.set("document-title","testing")
    console.log "test"
    "blah"


    
Template.bio.helpers
        result: ->
            console.log("party rendering")
            bio = localbiocollection.find().fetch()[0]
            console.log(bio)
            return bio
        party:->
            console.log("party rendering")
            bio = localbiocollection.find().fetch()[0]
            if bio
                party = bio.party    
                img_url = "/img/parties/"
                if party == 'R'
                    img_url +="republican.svg"
                else if party == 'D'
                    img_url +="democratic.svg"
            else
                img_url = "/img/hamsterload.gif"
            return img_url
                

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