public with sharing class TaxTriggerHelper {
    public static void handleInsertTax(Tax__c[] newTaxes){
        
        Id[] relatedProduct = new Id[]{};
        Id[] relatedState = new Id[]{};
        for (Tax__c iTax:newTaxes){
            relatedProduct.add(iTax.Product__c);
            relatedState.add(iTax.State__c);
        }
        Tax__c[] relatedTaxes = [SELECT Product__c,State__c
        FROM Tax__c 
        WHERE Product__c IN :relatedProduct AND
        State__c IN :relatedState ];
        Map<Id,Tax__c[]> relatedTaxesMap = new Map<Id,Tax__c[]>();
        for (Tax__c iTax:relatedTaxes){ //creates a map that relates taxes to products
            
            if (!relatedTaxesMap.containsKey(iTax.Product__c)){
                relatedTaxesMap.put(iTax.Product__c,new Tax__c[]{});
            }
            relatedTaxesMap.get(iTax.Product__c).add(iTax);
            
            
        }
        for (Tax__c iTax:newTaxes){ //checks to see if there's a duplicate tax
            
            if (relatedTaxesMap.containsKey(iTax.Product__c)){
                for (Tax__c iRelatedTax:relatedTaxesMap.get(iTax.Product__c)){
                   if (iTax.State__c == iRelatedTax.State__c){
                        iTax.addError('Duplicata Detectada');
                        break;
                    }
                }
            }
        }
    }
}