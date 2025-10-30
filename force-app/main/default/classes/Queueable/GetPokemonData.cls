public with sharing class GetPokemonData implements Queueable, Database.AllowsCallouts {
    private String requestURL;
    private Integer calloutsPerEnqueue;
    private List<Pokemon__c> pokemonsToInsert = new List<Pokemon__c>();
    private IntegrationLog calloutLog;
    private Integer offset;

    public GetPokemonData setRequestURL(String requestURL){
        this.requestURL = requestURL;

        return this;
    }
    public GetPokemonData setCalloutsPerEnqueue(Integer calloutsPerEnqueue){
        this.calloutsPerEnqueue = calloutsPerEnqueue;

        return this;
    }
    public GetPokemonData setPokemonsToInsert(List<Pokemon__c> pokemonsToInsert){
        this.pokemonsToInsert = pokemonsToInsert;
        return this;
    }
    public GetPokemonData setCalloutLog(IntegrationLog calloutLog){
        this.calloutLog = calloutLog;
        return this;
    }
    public GetPokemonData setOffset(Integer offset){
        this.offset = offset;
        return this;
    }
    public GetPokemonData build(){
        this.requestURL = this.requestURL+'&offset='+this.offset;
        return this;
    }
    
    public void execute(QueueableContext context) {
        System.debug('Depth Limits ('+System.AsyncInfo.hasMaxStackDepth()+'):'+System.AsyncInfo.getCurrentQueueableStackDepth()+'/'+System.AsyncInfo.getMaximumQueueableStackDepth());
        for (Integer i=0; i<this.calloutsPerEnqueue;++i){
            System.debug('Callout Limits:'+Limits.getCallouts()+'/'+Limits.getLimitCallouts() );
             
            HttpResponse response = SendRequest.sendGETRequestEmptyBody(requestURL);
            //request info from url


            if (calloutLog == null){
                calloutLog = new IntegrationLog()
                .reset()
                .setEndpoint(requestURL)
                .setIntegrationName('Pokemon')
                .setRecordTypeName('Outbound');
            }
            

            String responseBody = response.getBody();

            if (EvaluateResponseCode.isResponseOk(response)){

                DataIntegration.PokemonResponse pokemonResponse = 
                    ((DataIntegration.PokemonResponse)JSON.deserialize(responseBody, DataIntegration.PokemonResponse.class));

                calloutLog.setPayloadIN(calloutLog.payloadIN+JSON.serialize(pokemonResponse));
                System.debug(pokemonResponse);

                requestUrl = pokemonResponse.next ?? 'null';
                System.debug(requestUrl);
                for (DataIntegration.PokemonData iPokemon:pokemonResponse.results){
                    Pattern getId = Pattern.compile('pokemon/(\\d+)/');
                    Matcher match = getId.matcher(iPokemon.url);
                    match.find();
                    Pokemon__c pokemon = new Pokemon__c(Name = iPokemon.name,pokemonURL__c=iPokemon.url,pokemonId__c=match.group(1));
                    this.pokemonsToInsert.add(pokemon);
                }
            
            }

            else{
                calloutLog
                .setPayloadIN(calloutLog.payloadIN+' '+responseBody)
                .setHasAnyErrors(true)
                .build();

                if (!pokemonsToInsert.isEmpty()){
                    Database.upsert(pokemonsToInsert,Pokemon__c.pokemonId__c,false);
                }

                requestUrl = 'null';
                break;
            }

            

            if (requestUrl == 'null'){
                System.debug('Entrou para insert!');
                calloutLog.build();
                if (!pokemonsToInsert.isEmpty()){
                    Database.upsert(pokemonsToInsert,Pokemon__c.pokemonId__c,false);
                }

                break;
            }

        }
        if (System.AsyncInfo.getCurrentQueueableStackDepth() == System.AsyncInfo.getMaximumQueueableStackDepth()){
            System.debug('Profundidade do Enqueue chegou no limite! Considere aumentar o seu limite, ou aumentar os callouts em metadados!');
            calloutLog.build();
            if (!pokemonsToInsert.isEmpty()){
                Database.upsert(pokemonsToInsert,Pokemon__c.pokemonId__c,false);
            }
        }
        else if (requestURL != 'null'){
            System.debug('Chamando outro enqueue!');
            
            GetPokemonData newCallout = new GetPokemonData()
            .setRequestURL(requestURL)
            .setCalloutsPerEnqueue(calloutsPerEnqueue)
            .setCalloutLog(calloutLog)
            .setPokemonsToInsert(pokemonsToInsert)
            .setOffset(offset)
            .build();
            Id jobID = System.enqueueJob(newCallout);
            System.debug(jobID);
        }

        
        
    }
    

}
