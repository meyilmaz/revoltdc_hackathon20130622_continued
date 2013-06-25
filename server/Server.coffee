Meteor.Router.add
    '/test':'somedata'
    
sunlight_api_key = "yourapikey"
        
Meteor.methods 
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
        @unblock()
        result = Meteor.http.call('GET',"http://congress.api.sunlightfoundation.com/legislators",
            params:
                "apikey": sunlight_api_key,
                "last_name": query      
        )   
        console.log( query + " is query")
        if result.statusCode is 200
           resulting = JSON.parse(result.content); 
           console.log( resulting.results[0].bioguide_id )
           bioguide_id = resulting.results[0].bioguide_id
           capitol_by_leg = Meteor.http.call('GET',"http://capitolwords.org/api/1/phrases.json"
                params:
                    "apikey": sunlight_api_key,
                    "entity_type": "legislator",
                    "entity_value": bioguide_id
           )
           if capitol_by_leg.statusCode is 200
              resulting = JSON.parse(capitol_by_leg.content);  
              resulting.sort (a, b)->
                return b.count - a.count
              console.log(resulting)
              return resulting
            else
                return resulting
        false
