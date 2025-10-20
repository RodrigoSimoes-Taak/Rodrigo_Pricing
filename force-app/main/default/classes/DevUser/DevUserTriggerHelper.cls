public with sharing class DevUserTriggerHelper {
    public static void handleInsertDevUser(List<DevUser__c> newRecordList){
        handleBatchCallout(newRecordList);

    }
    public static void handleUpdateDevUSer(Map<Id,DevUser__c> newRecordMap, Map<Id,DevUser__c> oldRecordMap){
        List<DevUser__c> recordsToUpdate = new List<DevUser__c>();
        for (Id iId:newRecordMap.keySet()){
            if (newRecordMap.get(iId).Login__c != oldRecordMap.get(iId).Login__c){ //login updated
                recordsToUpdate.add(newRecordMap.get(iId));
            }
        }

        if (!recordsToUpdate.isEmpty()){
            handleBatchCallout(recordsToUpdate);
        }

    }
    public static void handleBatchCallout(List<DevUser__c> recordsToUpdate){
        Database.executeBatch(new BatchGetGithubDetails(recordsToUpdate), 50); 
    }
}