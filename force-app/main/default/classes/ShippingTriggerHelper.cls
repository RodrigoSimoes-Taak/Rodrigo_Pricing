public with sharing class ShippingTriggerHelper {
    public static void handleInsertShipping(Shipping__c[] newShippings){
        Id[] relatedProductHierarchy = new Id[]{};
        Id[] relatedProduct = new Id[]{};
        Id[] relatedCity = new Id[]{};
        Id[] relatedState = new Id[]{};
        Id[] relatedCountry = new Id[]{};
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
        }
        Shipping__c[] relatedShippings = [SELECT ProductHierarchy__c,Product__c,City__c,State__c,Country__c
        FROM Shipping__c 
        WHERE (ProductHierarchy__c IN :relatedProductHierarchy OR Product__c IN :relatedProduct) AND
        (City__c IN :relatedCity OR State__c IN :relatedState OR Country__c IN :relatedCountry)];
        Map<Id,Shipping__c[]> relatedShippingsMap = new Map<Id,Shipping__c[]>();
        for (Shipping__c iShipping:relatedShippings){ //creates a map that relates shipping to products/hierarchies
            if (iShipping.Product__c!= null){
                if (!relatedShippingsMap.containsKey(iShipping.Product__c)){
                    relatedShippingsMap.put(iShipping.Product__c,new Shipping__c[]{});
                }
                relatedShippingsMap.get(iShipping.Product__c).add(iShipping);
            }
            else if (iShipping.ProductHierarchy__c!=null){
                if (!relatedShippingsMap.containsKey(iShipping.ProductHierarchy__c)){
                    relatedShippingsMap.put(iShipping.ProductHierarchy__c,new Shipping__c[]{});
                }
                relatedShippingsMap.get(iShipping.ProductHierarchy__c).add(iShipping);
            }
            
        }
        for (Shipping__c iShipping:newShippings){ //checks to see if there's a duplicate shipping
            if (iShipping.Product__c != null){
                if (relatedShippingsMap.containsKey(iShipping.Product__c)){
                    for (Shipping__c iRelatedShipping:relatedShippingsMap.get(iShipping.Product__c)){
                        if (iShipping.City__c == iRelatedShipping.City__c &&
                        iShipping.State__c == iRelatedShipping.State__c &&
                        iShipping.Country__c == iRelatedShipping.Country__c){
                            iShipping.addError('Duplicata Detectada');
                            break;
                        }
                    }
                }
            }
            else if (iShipping.ProductHierarchy__c != null){
                if (relatedShippingsMap.containsKey(iShipping.ProductHierarchy__c)){
                    for (Shipping__c iRelatedShipping:relatedShippingsMap.get(iShipping.ProductHierarchy__c)){
                        if (iShipping.City__c == iRelatedShipping.City__c &&
                        iShipping.State__c == iRelatedShipping.State__c &&
                        iShipping.Country__c == iRelatedShipping.Country__c){
                            iShipping.addError('Duplicata Detectada');
                            break;
                        }
                    }
                }
            }
        }
    }
}