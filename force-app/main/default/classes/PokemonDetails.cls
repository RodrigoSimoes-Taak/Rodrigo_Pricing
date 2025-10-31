public with sharing class PokemonDetails {
    @InvocableMethod
    public static void enqueueCalloutToPokemonAPI(){ 

        Integer calloutsPerEnqueue = Integer.valueOf(DevParameters__mdt.getInstance('NumberOfCalloutsPerEnqueue').Value__c);

        AsyncOptions options = new AsyncOptions();
        options.MaximumQueueableStackDepth =  Integer.valueOf(DevParameters__mdt.getInstance('QueueableMaxDepth').Value__c);
        String requestUrl = DevParameters__mdt.getInstance('PokemonURL').Value__c;
        Integer limitPerCallout = Integer.valueOf(DevParameters__mdt.getInstance('PokemonsPerCallout').Value__c);
        GetPokemonData newCallout = new GetPokemonData()
            .setRequestURL(requestUrl+'?limit='+limitPerCallout)
            .setCalloutsPerEnqueue(calloutsPerEnqueue)
            .build();
        Id jobID = System.enqueueJob(newCallout,options);
        System.debug(jobID);
        
        
        
    }
}