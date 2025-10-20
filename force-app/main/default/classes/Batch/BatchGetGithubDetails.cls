public with sharing class BatchGetGithubDetails implements Database.Batchable<SObject>,Database.AllowsCallouts {
    public class GithubResponse{
        public String bio;
        public String type;
        public String id;
    }
    public List<DevUser__c> records;
    public BatchGetGithubDetails(List<DevUser__c> records){
        this.records = records;
        
    }
    public Iterable<DevUser__c> start(Database.BatchableContext context){
        return records;
    }
    public void execute (Database.BatchableContext context, List<DevUser__c> scope){
        List<DevUser__c> devsToUpsert = new List<DevUser__c>();
        
        System.debug('BatchGetGithubDetails Batch - Executing');
        List<GithubResponse> responses = new List<GithubResponse>();
        List<String> githubLogins = new List<String>();
        String externalIdList = '';
        Boolean hasAnyErrors = false;
        
        for (DevUser__c iDevUser:scope){
            githubLogins.add(iDevUser.Login__c);
            HttpRequest request = new HttpRequest();
            String requestURL = 'https://api.github.com/users/'+iDevUser.Login__c;
            request.setMethod('GET');
            request.setEndpoint(requestURL);
            HttpResponse response = new Http().send(request);
            if (response.getStatusCode() != 200 && !hasAnyErrors){
                hasAnyErrors = true;
            }
            else{
                String responseBody = response.getBody();
                
                GithubResponse accountDetails = ((GithubResponse)JSON.deserialize(responseBody, GithubResponse.class));

                externalIdList+= accountDetails.id+', ';
                responses.add(accountDetails);
                iDevUser.Name = iDevUser.Login__c;
                iDevUser.Bio__c = accountDetails.bio;
                iDevUser.Type__c = accountDetails.type;
                iDevUser.ExternalId__c = accountDetails.id;
                devsToUpsert.add(iDevUser);
            }
            
        }
        try{
            Database.upsert(devsToUpsert,DevUser__c.Login__c,false);
            System.debug('BatchGetGithubDetails Teste');
            
            IntegrationLog.createLog('DevUser',externalIdList.substring(0,255) , 'Outbound', JSON.serialize(responses), JSON.serialize(githubLogins),'https://api.github.com/users/', hasAnyErrors, false);
        }
        catch(Exception e){
            System.debug('BatchGetGithubDetails Batch - Error when upserting records '+e.getMessage());
        }
        

    }
    public void finish(Database.BatchableContext context){

    }
    
}
