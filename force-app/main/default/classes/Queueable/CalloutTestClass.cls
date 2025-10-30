public with sharing class CalloutTestClass {
    @InvocableMethod
    public static void enqueueCalloutToPokemonAPI(){ 

        Integer calloutsPerEnqueue = Integer.valueOf(DevParameters__mdt.getInstance('NumberOfCalloutsPerEnqueue').Value__c);

        AsyncOptions options = new AsyncOptions();
        options.MaximumQueueableStackDepth =  Integer.valueOf(DevParameters__mdt.getInstance('QueueableMaxDepth').Value__c);

        GetPokemonData newCallout = new GetPokemonData()
            .setRequestURL(DevParameters__mdt.getInstance('PokemonURL').Value__c)
            .setCalloutsPerEnqueue(calloutsPerEnqueue)
            .build();
        Id jobID = System.enqueueJob(newCallout,options);
        System.debug(jobID);
        
        
        
    }
}