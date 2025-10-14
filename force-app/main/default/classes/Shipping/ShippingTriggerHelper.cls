public with sharing class ShippingTriggerHelper {
    public static void handleInsertShipping(Shipping__c[] newShippings){
        Id[] relatedProductHierarchy = new Id[]{};
        Id[] relatedProduct = new Id[]{};
        Id[] relatedCity = new Id[]{};
        Id[] relatedState = new Id[]{};
        Id[] relatedCountry = new Id[]{};
        Map<String,Shipping__c> mapComparison = new Map<String,Shipping__c>();
        for (Shipping__c iShipping:newShippings){
            if (iShipping.ProductHierarchy__c != null){
                relatedProductHierarchy.add(iShipping.ProductHierarchy__c);
            }
            if (iShipping.Product__c != null){
                relatedProduct.add(iShipping.Product__c);
            }
            if (iShipping.City__c != null){
                relatedCity.add(iShipping.City__c);
            }
            if (iShipping.State__c != null){
                relatedState.add(iShipping.State__c);
            }
            if (iShipping.Country__c != null){
                relatedCountry.add(iShipping.Country__c);
            }
            String key = iShipping.ProductHierarchy__c +'-'+iShipping.Product__c +'-'+iShipping.Country__c +'-'+iShipping.State__c +'-'+iShipping.City__c;
            if (!mapComparison.containsKey(key)){
                mapComparison.put(key,iShipping);
            }
            else{
                mapComparison.get(key).addError('Duplicata Detectada');
            }
        }
        Shipping__c[] relatedShippings = [SELECT ProductHierarchy__c,Product__c,City__c,State__c,Country__c
        FROM Shipping__c 
        WHERE (ProductHierarchy__c IN :relatedProductHierarchy OR Product__c IN :relatedProduct) AND
        (City__c IN :relatedCity OR State__c IN :relatedState OR Country__c IN :relatedCountry)];
        for (Shipping__c iShipping:relatedShippings){
            String key = iShipping.ProductHierarchy__c +'-'+iShipping.Product__c +'-'+iShipping.Country__c +'-'+iShipping.State__c +'-'+iShipping.City__c;
            if (!mapComparison.containsKey(key)){
                mapComparison.put(key,iShipping);
            }
            else{
                mapComparison.get(key).addError('Duplicata Detectada');
            }
 
        }
    }
    public static void handleUpdateShipping(Map<Id,Shipping__c> newRecordMap, Map<Id,Shipping__c> oldRecordMap){
        Shipping__c[] toCheck = new Shipping__c[]{};


        for (Id iId:newRecordMap.keySet()){
            if (newRecordMap.get(iId).Product__c != oldRecordMap.get(iId).Product__c ||
            newRecordMap.get(iId).ProductHierarchy__c != oldRecordMap.get(iId).ProductHierarchy__c ||
            newRecordMap.get(iId).City__c != oldRecordMap.get(iId).City__c ||
            newRecordMap.get(iId).State__c != oldRecordMap.get(iId).State__c ||
            newRecordMap.get(iId).Country__c != oldRecordMap.get(iId).Country__c){

                toCheck.add(newRecordMap.get(iId));
            }
        }

        if (!toCheck.isEmpty()){
            handleInsertShipping(toCheck);
        }
    }
    public static void handleUpdateOrderItemInfo(Map<Id,Shipping__c> newRecordMap){
        update [SELECT Id FROM OrderItem WHERE Shipping__c IN :newRecordMap.keySet()];

    }
}