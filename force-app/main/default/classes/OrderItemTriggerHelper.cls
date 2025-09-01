public with sharing class OrderItemTriggerHelper {
    public static void handleInsertOrderItem(OrderItem[] newOrderItems){
        //checar se possui Custo de producao, Frete, Imposto e Margem
        Id[] relatedProducts = new Id[]{}; //get all the related products
        
        Map<Id,Map<String,SObject[]>> relatedProductsMap = new Map<Id,Map<String,SObject[]>>(); //Map that relates products to
                                                                                                //Shipping, PriceBooks, Tax and
                                                                                                //Margin
        //Id[] relatedHierarchy = new Id[]{}; //adicionar cheque aos SELECTS para tambem checar as hierarquias relacionadas!
        for (OrderItem iOrderItem:newOrderItems){
            //relatedHierarchy.add(iOrderItem.Product2Id.ProductHierarchy__c); //perguntar como fazer isso funcionar!
            relatedProducts.add(iOrderItem.Product2Id);
            relatedProductsMap.put(iOrderItem.Product2Id,new Map<String,SObject[]>());
            relatedProductsMap.get(iOrderItem.Product2Id).put('PricebookEntry',new PricebookEntry[]{});
            relatedProductsMap.get(iOrderItem.Product2Id).put('Shipping',new Shipping__c[]{});
            relatedProductsMap.get(iOrderItem.Product2Id).put('Tax',new Tax__c[]{});
            relatedProductsMap.get(iOrderItem.Product2Id).put('Margin',new ProfitMargin__c[]{});
        }

        //precisa pegar valor de custo de producao (pricebookentry) frete, imposto e margem!
        //vv custo de produção
        PricebookEntry[] relatedPricebooks = [SELECT UnitPrice,Product2Id FROM PricebookEntry 
                                            WHERE Product2Id IN :relatedProducts AND isActive = True 
                                            AND Pricebook2.isActive = True ]; //checks if procebook is active and listing is active
        for (PricebookEntry iPricebookEntry:relatedPricebooks){//adds all pricebook entries to their product
            relatedProductsMap.get(iPricebookEntry.Product2Id).get('PricebookEntry').add(iPricebookEntry);
        }
       
        //vv Frete
        Shipping__c[] relatedShippings = [SELECT Value__c,Product__c FROM Shipping__c WHERE Product__c IN :relatedProducts AND Status__c = 'Aprovado'];
        for (Shipping__c iShipping:relatedShippings){
            relatedProductsMap.get(iShipping.Product__c).get('Shipping').add(iShipping);
        }
        //vv Imposto
        Tax__c[] relatedTaxes = [SELECT TaxOnCost__c,Product__c FROM Tax__c WHERE Product__c IN :relatedProducts AND Status__c = 'Aprovado'];
        for (Tax__c iTax:relatedTaxes){
            relatedProductsMap.get(iTax.Product__c).get('Tax').add(iTax);
        }

        //vv Margem
        ProfitMargin__c[] relatedMargins =[SELECT MarginPercentage__c,Product__c FROM ProfitMargin__c WHERE Product__c IN :relatedProducts AND Status__c = 'Aprovado'];
        
        for (ProfitMargin__c iProfitMargin:relatedMargins){
            relatedProductsMap.get(iProfitMargin.Product__c).get('Margin').add(iProfitMargin);
        }
        
        
        
        
        for (OrderItem iOrderItem:newOrderItems){
            //checks if none of the maps inside the maps are empty, if true, addError!
            if (relatedProductsMap.get(iOrderItem.Product2Id).get('PricebookEntry').isEmpty() ||
                relatedProductsMap.get(iOrderItem.Product2Id).get('Shipping').isEmpty() ||
                relatedProductsMap.get(iOrderItem.Product2Id).get('Tax').isEmpty()||
                relatedProductsMap.get(iOrderItem.Product2Id).get('Margin').isEmpty()){
                

                iOrderItem.addError('Não está autorizada a venda deste produto devido a falta de parâmetros, entre em contato com o time de pricing.');
            }
           
            
            
        }
        
    }
    public static void handleProfitMargin(OrderItem[] newOrderItems){

    }
}