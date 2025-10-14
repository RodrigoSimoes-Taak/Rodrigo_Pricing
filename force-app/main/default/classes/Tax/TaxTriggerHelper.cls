public with sharing class TaxTriggerHelper {
    public static void handleInsertTax(Tax__c[] newTaxes){
        
        Id[] relatedProduct = new Id[]{};
        Id[] relatedState = new Id[]{};
        Map<String,Tax__c> mapComparison = new Map<String,Tax__c>();
        for (Tax__c iTax:newTaxes){ //inner duplicate check
            String key = iTax.Product__c +'-'+iTax.State__c;
            relatedProduct.add(iTax.Product__c);
            relatedState.add(iTax.State__c);
            if (!mapComparison.containsKey(key)){
                mapComparison.put(key,iTax);
            }
            else{
                mapComparison.get(key).addError('Duplicata Detectada');
            }
        }
        

        for (Tax__c iTax:[SELECT Product__c,State__c FROM Tax__c WHERE Product__c IN :relatedProduct AND State__c IN :relatedState]){
            String key = iTax.Product__c +'-'+iTax.State__c;
            if (!mapComparison.containsKey(key)){
                mapComparison.put(key,iTax);
            }
            else{
                mapComparison.get(key).addError('Duplicata Detectada');
            }
        }
    }
    public static void handleUpdateTax(Map<Id,Tax__c> newRecordMap, Map<Id,Tax__c> oldRecordMap){
        Tax__c[] toCheck = new Tax__C[]{};
        Id[] relatedProduct = new Id[]{};
        for (Id iId:newRecordMap.keySet()){
            if (newRecordMap.get(iId).Product__c != oldRecordMap.get(iId).Product__c ||
            newRecordMap.get(iId).State__c != oldRecordMap.get(iId).State__c){
                relatedProduct.add(newRecordMap.get(iId).Product__c);
                toCheck.add(newRecordMap.get(iId));
            }
        }
        //[SELECT FROM OrderItem WHERE Product2Id IN: relatedProduct]; //mandar dar update nos orderitem que teriam seu valor modificado por taxes
        if (!toCheck.isEmpty()){
            handleInsertTax(toCheck);
        }
    }
    public static void handleUpdateOrderItemInfo(Map<Id,Tax__c> newRecordMap){
        update [SELECT Id FROM OrderItem WHERE Tax__c IN:newRecordMap.keySet()];
    }
}