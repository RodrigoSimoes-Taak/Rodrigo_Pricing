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
        }
        ProfitMargin__c[] relatedProfitMargins = [SELECT ProductHierarchy__c,Product__c,AccountGroup__c,Account__c,City__c,
        State__c,Country__c
        FROM ProfitMargin__c 
        WHERE (ProductHierarchy__c IN :relatedProductHierarchy OR Product__c IN :relatedProduct) AND
        (AccountGroup__c IN :relatedAccountGroup OR Account__c IN :relatedAccount) AND
        (City__c IN :relatedCity OR State__c IN :relatedState OR Country__c IN :relatedCountry)];
        //achar forma de evitar O(n2)!
        
        Map<Id,ProfitMargin__c[]> relatedProfitMarginsMap = new Map<Id,ProfitMargin__c[]>();
        for (ProfitMargin__c iProfitMargin:relatedProfitMargins){ //creates a map that relates margins to products/hierarchies
            if (iProfitMargin.Product__c!= null){
                if (!relatedProfitMarginsMap.containsKey(iProfitMargin.Product__c)){
                    relatedProfitMarginsMap.put(iProfitMargin.Product__c,new ProfitMargin__c[]{});
                }
                relatedProfitMarginsMap.get(iProfitMargin.Product__c).add(iProfitMargin);
            }
            else if (iProfitMargin.ProductHierarchy__c!=null){
                if (!relatedProfitMarginsMap.containsKey(iProfitMargin.ProductHierarchy__c)){
                    relatedProfitMarginsMap.put(iProfitMargin.ProductHierarchy__c,new ProfitMargin__c[]{});
                }
                relatedProfitMarginsMap.get(iProfitMargin.ProductHierarchy__c).add(iProfitMargin);
            }
            
        }

        for (ProfitMargin__c iProfitMargin:newProfitMargins){ //checks to see if there's a duplicate margin
            if (iProfitMargin.Product__c != null) {
                if (relatedProfitMarginsMap.containsKey(iProfitMargin.Product__c)){
                    for (ProfitMargin__c iRelatedProfitMargin:relatedProfitMarginsMap.get(iProfitMargin.Product__c)) {
                        if (iProfitMargin.Account__c  == iRelatedProfitMargin.Account__c && 
                        iProfitMargin.AccountGroup__c == iRelatedProfitMargin.AccountGroup__c &&
                        iProfitMargin.City__c         == iRelatedProfitMargin.City__c &&
                        iProfitMargin.State__c        == iRelatedProfitMargin.State__c &&
                        iProfitMargin.Country__c      == iRelatedProfitMargin.Country__c) {
                            iProfitMargin.addError('Duplicata Detectada');
                            break;
                        }
                    }
                }
            }
            else if (iProfitMargin.ProductHierarchy__c != null) {
                if (relatedProfitMarginsMap.containsKey(iProfitMargin.ProductHierarchy__c)){
                    for (ProfitMargin__c iRelatedProfitMargin:relatedProfitMarginsMap.get(iProfitMargin.ProductHierarchy__c)){
                        if (iProfitMargin.Account__c == iRelatedProfitMargin.Account__c && 
                        iProfitMargin.AccountGroup__c == iRelatedProfitMargin.AccountGroup__c &&
                        iProfitMargin.City__c == iRelatedProfitMargin.City__c &&
                        iProfitMargin.State__c == iRelatedProfitMargin.State__c &&
                        iProfitMargin.Country__c == iRelatedProfitMargin.Country__c){
                            iProfitMargin.addError('Duplicata Detectada');
                            break;
                        }
                    }
                }
            }
        }
   }
}