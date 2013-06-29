class Legislator
    constructor: (options) -> 
        {@bioguide_id, @birthday, @chamber,@contact_form,@crp_id,@district,
         @facebook_id,@fax,@fec_ids,@first_name,@gender,@govtrack_id,@in_office,
         @last_name,@lis_id,@middle_name,@name_suffix,@nickname,@office,@party,
         @phone,@senate_class,@state,@state_name,@state_rank,@thomas_id,@title,
         @twitter_id,@votesmart_id,@website,@youtube_id} = options
        console.log(@)
        console.log(@fec_ids)
        return @
    getName: ()->
        return  @first_name+" "+@last_name

Meteor.Router.add
    '/test':'somedata'
    
sunlight_api_key = "myapikey"
        
Meteor.methods
    fetchBiographic: (query) ->
        result = Meteor.http.call('GET',"http://congress.api.sunlightfoundation.com/legislators",
            params:
                "apikey": sunlight_api_key,
                "last_name": query       
        )
        console.log( query + " is query")
        if result.statusCode is 200
           resulting = JSON.parse(result.content);
           legi = new Legislator(resulting.results[0])
           console.log(legi.getName())
           return legi
    checkSunlight: (query) ->
        @unblock()
        result = Meteor.http.call( "GET","http://congress.api.sunlightfoundation.com/votes",
            params:
                "apikey": sunlight_api_key,
                "query": query      
        )
        console.log( query + " is query")
        if result.statusCode is 200
            resulting = JSON.parse(result.content);
            console.log(resulting)
            return resulting  
        false        
    checkCapitolWords: (query) ->
        Future = Npm.require("fibers/future");
        fut = new Future()
        cb = fut.resolver()
        result = Meteor.http.call('GET',"http://congress.api.sunlightfoundation.com/legislators",
            params:
                "apikey": sunlight_api_key,
                "last_name": query,
            ,(err,res)->
                    return cb(err,res)           
        )
        result = fut.wait()
        console.log( query + " is query")
        if result.statusCode is 200
           resulting = JSON.parse(result.content);
           console.log( resulting )
           console.log( resulting.results[0].bioguide_id )
           bioguide_id = resulting.results[0].bioguide_id
           legi = new Legislator(resulting.results[0])
           console.log(legi.getName())
           resulting = Meteor.call("fetchCapitolWords",bioguide_id)
           return resulting
        else
            return false
    fetchCapitolWords: (bioguide_id)->
           Future = Npm.require("fibers/future");
           fut2 = new Future()
           cb = fut2.resolver()
           capitol_by_leg = Meteor.http.call('GET',"http://capitolwords.org/api/1/phrases.json"
                params:
                    "apikey": sunlight_api_key,
                    "entity_type": "legislator",
                    "entity_value": bioguide_id
                (err,res)->
                    return cb(err,res)
           )
           capitol_by_leg = fut2.wait()
           if capitol_by_leg.statusCode is 200
              resulting = JSON.parse(capitol_by_leg.content);  
              resulting.sort (a, b)->
                return b.count - a.count
              console.log(resulting)
              return resulting
            else
              return false
        
