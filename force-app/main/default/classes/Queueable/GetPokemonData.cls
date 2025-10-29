public with sharing class GetPokemonData implements Queueable, Database.AllowsCallouts {
    private String requestUrl;
    public GetPokemonData(String requestURL){
        this.requestURL = requestURL;
    }
    public void execute(QueueableContext context) {
        HttpResponse response = SendRequest.sendGETRequestEmptyBody(requestURL);
        //request info from url



        IntegrationLog calloutLog = new IntegrationLog()
            .reset()
            .setEndpoint(requestURL)
            .setIntegrationName('Pokemon')
            .setRecordTypeName('Outbound');

        String responseBody = response.getBody();

        if (EvaluateResponseCode.isResponseOk(response)){
            PokemonResponse pokemonResponse = ((PokemonResponse)JSON.deserialize(responseBody, PokemonResponse.class));
            calloutLog.setPayloadIN(JSON.serialize(pokemonResponse));
            System.debug(pokemonResponse);
            List<Pokemon__c> pokemonsToInsert = new List<Pokemon__c>();
            for (PokemonData iPokemon:pokemonResponse.results){
                Pokemon__c pokemon = new Pokemon__c(Name = iPokemon.name,pokemonURL__c=iPokemon.url);
                pokemonsToInsert.add(pokemon);
            }
            if (!pokemonsToInsert.isEmpty()){
                insert pokemonsToInsert;
            }


        }
        else{
            calloutLog.setPayloadIN(responseBody).setHasAnyErrors(true);
        }
        calloutLog.build();
        
    }
    public class PokemonResponse{
        Integer count;
        String next;
        String previous;
        List<PokemonData> results;
    }
    public class PokemonData{
        public String name;
        public String url;
    }

}
