public with sharing class CalloutTestClass {
    @future(callout=true)
    public static void callout(){ 
        //TODO: do one future callout to get the current number of pokémon, then run it in intervals of 20!
        GetPokemonData newCallout = new GetPokemonData('https://pokeapi.co/api/v2/pokemon?limit=2000');
        Id jobID = System.enqueueJob(newCallout);
        System.debug(jobID);
    }
}