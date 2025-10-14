public with sharing class ProfitMarginTriggerHelper {
    public static void handleInsertProfitMargin(ProfitMargin__c[] newProfitMargins){
        //problema é quando conta= produto= e local=, logo se deve checar qual dos campos foi
        //preenchido do profitmargin, e comparar com os outros margins, se os tres forem iguais, addError
        Id[] relatedProductHierarchy = new Id[]{};
        Id[] relatedProduct = new Id[]{};
        Id[] relatedAccountGroup = new Id[]{};
        Id[] relatedAccount = new Id[]{};
        Id[] relatedCity = new Id[]{};
        Id[] relatedState = new Id[]{};
        Id[] relatedCountry = new Id[]{};
        Map<String,ProfitMargin__c> mapComparison = new Map<String,ProfitMargin__c>();
        for (ProfitMargin__c iProfitMargin:newProfitMargins){ //checks to see what's related, for a better SOQL query
            if (iProfitMargin.ProductHierarchy__c != null){
                relatedProductHierarchy.add(iProfitMargin.ProductHierarchy__c);
            }
            if (iProfitMargin.Product__c != null){
                relatedProduct.add(iProfitMargin.Product__c);
            }
            if (iProfitMargin.AccountGroup__c != null){
                relatedAccountGroup.add(iProfitMargin.AccountGroup__c);
            }
            if (iProfitMargin.Account__c != null){
                relatedAccount.add(iProfitMargin.Account__c);
            }
            if (iProfitMargin.City__c != null){
                relatedCity.add(iProfitMargin.City__c);
            }
            if (iProfitMargin.State__c != null){
                relatedState.add(iProfitMargin.State__c);
            }
            if (iProfitMargin.Country__c != null){
                relatedCountry.add(iProfitMargin.Country__c);
            }
            String key = iProfitMargin.ProductHierarchy__c +'-'+iProfitMargin.Product__c +'-'+iProfitMargin.Country__c+'-'+iProfitMargin.State__c+'-'+iProfitMargin.City__c+'-'+iProfitMargin.AccountGroup__c+'-'+iProfitMargin.Account__c;
            if (!mapComparison.containsKey(key)){
                mapComparison.put(key,iProfitMargin);
            }
            else{
                mapComparison.get(key).addError('Duplicata Detectada');
            }
        }
        ProfitMargin__c[] relatedProfitMargins = [SELECT ProductHierarchy__c,Product__c,AccountGroup__c,Account__c,City__c,
        State__c,Country__c
        FROM ProfitMargin__c 
        WHERE (ProductHierarchy__c IN :relatedProductHierarchy OR Product__c IN :relatedProduct) AND
        (AccountGroup__c IN :relatedAccountGroup OR Account__c IN :relatedAccount) AND
        (City__c IN :relatedCity OR State__c IN :relatedState OR Country__c IN :relatedCountry)];
        
        
        for (ProfitMargin__c iProfitMargin:relatedProfitMargins){
            String key = iProfitMargin.ProductHierarchy__c +'-'+iProfitMargin.Product__c +'-'+iProfitMargin.Country__c+'-'
            +iProfitMargin.State__c+'-'+iProfitMargin.City__c+'-'+iProfitMargin.AccountGroup__c+'-'+iProfitMargin.Account__c;
            if (!mapComparison.containsKey(key)){
                mapComparison.put(key,iProfitMargin);
            }
            else{
                mapComparison.get(key).addError('Duplicata Detectada');
            }
        }
   }
   public static void handleUpdateProfitMargin(Map<Id,ProfitMargin__c> newRecordMap,Map<Id,ProfitMargin__c> oldRecordMap){
        //se algo importante mudar, rodar insert, caso contrario, continuar!
        ProfitMargin__c[] toCheck = new ProfitMargin__c[]{};
        for (Id iId:newRecordMap.keySet()){
            if (newRecordMap.get(iId).Product__c != oldRecordMap.get(iId).Product__c ||
            newRecordMap.get(iId).ProductHierarchy__c != oldRecordMap.get(iId).ProductHierarchy__c ||
            newRecordMap.get(iId).Account__c != oldRecordMap.get(iId).Account__c ||
            newRecordMap.get(iId).AccountGroup__c != oldRecordMap.get(iId).AccountGroup__c ||
            newRecordMap.get(iId).City__c != oldRecordMap.get(iId).City__c ||
            newRecordMap.get(iId).State__c != oldRecordMap.get(iId).State__c ||
            newRecordMap.get(iId).Country__c != oldRecordMap.get(iId).Country__c){
                toCheck.add(newRecordMap.get(iId));
            }
        }
        if (!toCheck.isEmpty()){
            handleInsertProfitMargin(toCheck);
        }

   }
   public static void handleUpdateOrderItemInfo(Map<Id,ProfitMargin__c> newRecordMap){
        update [SELECT Id FROM OrderItem WHERE ProfitMargin__c IN :newRecordMap.keySet()];
    }
}