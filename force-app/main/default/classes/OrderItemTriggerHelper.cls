public with sharing class OrderItemTriggerHelper {
    //public static Map<Id,Map<String,SObject[]>> relatedProductsMap = new Map<Id,Map<String,SObject[]>>(); //Map that relates products to
                                                                                                //Shipping, PriceBooks, Tax and
                                                                                                //Margin
    public static Set<Id> relatedProducts = new Set<Id>();
    public static Map<Id,PriceBookEntry[]> relatedProductsCostMap = new Map<Id,PricebookEntry[]>();
    public static Map<Id,Tax__c[]> relatedProductsTaxMap = new Map<Id,Tax__c[]>();
    public static Map<Id,ProfitMargin__c[]> relatedProductsProfitMap = new Map<Id,ProfitMargin__c[]>();
    public static Map<Id,Shipping__c[]> relatedProductsShippingMap = new Map<Id,Shipping__c[]>();
    public static Map<Id,Order> relatedOrdersMap;

    public static void handleInsertOrderItem(OrderItem[] newOrderItems){
        
        Set<Id> relatedOrders = new Set<Id>();
        for (OrderItem iOrderItem:newOrderItems){
            relatedOrders.add(iOrderItem.OrderId);
        }
        relatedOrdersMap = new Map<Id,Order>(
            [SELECT Id, AccountAddress__r.City__c,AccountAddress__r.City__r.State__c,
            AccountAddress__r.City__r.State__r.Country__c,Account.AccountGroup__c,AccountId 
            FROM Order 
            WHERE Id IN :relatedOrders]);

        for (OrderItem iOrderItem:newOrderItems){
            relatedProducts.add(iOrderItem.Product2Id);
            //if (!relatedProductsMap.contains(iOrderItem.Product2Id)){
                
                //relatedProductsMap.put(iOrderItem.Product2Id,new Map<String,SObject[]>());
                //relatedProductsMap.get(iOrderItem.Product2Id).put('PricebookEntry',new PricebookEntry[]{});
                //relatedProductsMap.get(iOrderItem.Product2Id).put('Shipping',new Shipping__c[]{});
                //relatedProductsMap.get(iOrderItem.Product2Id).put('Tax',new Tax__c[]{});
                //relatedProductsMap.get(iOrderItem.Product2Id).put('Margin',new ProfitMargin__c[]{});
            //}
            
        }
        for (Id iId:relatedProducts){
            relatedProductsCostMap.put(iId,new PricebookEntry[]{});
            relatedProductsTaxMap.put(iId,new Tax__c[]{});
            relatedProductsProfitMap.put(iId,new ProfitMargin__c[]{});
            relatedProductsShippingMap.put(iId,new Shipping__c[]{});
        }

        Map<Id,Id[]> relatedHierarchyMap = new Map<Id,Id[]>(); //relates Map<ProductHierarchy__c.Id,Product2Id[]>, since a hierarchy can have multiple products
        for (Product2 iProduct:[
            SELECT Id, ProductHierarchy__c 
            FROM Product2 
            WHERE Id IN:relatedProducts]){
            if (iProduct.ProductHierarchy__c != null){
                if (!relatedHierarchyMap.containsKey(iProduct.ProductHierarchy__c)){
                    relatedHierarchyMap.put(iProduct.ProductHierarchy__c,new Id[]{});
                }
                relatedHierarchyMap.get(iProduct.ProductHierarchy__c).add(iProduct.Id);  
            }    
        }
        //vv Production Cost
        PricebookEntry[] relatedPricebooks = [
            SELECT UnitPrice,Product2Id FROM PricebookEntry 
            WHERE Product2Id IN :relatedProducts AND isActive = True AND Pricebook2.isActive = True ]; //checks if pricebook is active and listing is active
        for (PricebookEntry iPricebookEntry:relatedPricebooks){//adds all pricebook entries to their product
            relatedProductsCostMap.get(iPricebookEntry.Product2Id).add(iPricebookEntry);
        }
        
        System.debug('D1 '+relatedHierarchyMap);
        
        
        //vv Shipping
        Shipping__c[] relatedShippings = [
            SELECT Value__c,Product__c,ProductHierarchy__c,City__c,State__c,Country__c 
            FROM Shipping__c 
            WHERE (Product__c IN :relatedProducts OR ProductHierarchy__c IN :relatedHierarchyMap.keySet()) AND Status__c = 'Aprovado'
            ORDER BY City__c NULLS LAST, Product__c NULLS LAST];
        System.debug(relatedShippings.size());
        for (Shipping__c iShipping:relatedShippings){
            System.debug(relatedShippings);
            if (iShipping.Product__c != null){
                relatedProductsShippingMap.get(iShipping.Product__c).add(iShipping);
                System.debug('Pos shipping');
            }
            else{
                for (Id iProduct:relatedHierarchyMap.get(iShipping.ProductHierarchy__c)){
                    relatedProductsShippingMap.get(iProduct).add(iShipping);
                }
                
            }
        }
        
        
        //vv Tax
        Tax__c[] relatedTaxes = [
            SELECT TaxOnCost__c,Product__c,State__c 
            FROM Tax__c 
            WHERE Product__c IN :relatedProducts AND Status__c = 'Aprovado'];
        for (Tax__c iTax:relatedTaxes){
            relatedProductsTaxMap.get(iTax.Product__c).add(iTax);
        }

        //vv Profit Margin
        ProfitMargin__c[] relatedMargins =[
            SELECT ProductHierarchy__c,Product__c,City__c,State__c,Country__c,AccountGroup__c,Account__c,MarginPercentage__c
            FROM ProfitMargin__c 
            WHERE (Product__c IN :relatedProducts OR ProductHierarchy__c IN :relatedHierarchyMap.keySet()) 
            AND Status__c = 'Aprovado'
            ORDER BY City__c NULLS LAST, Account__c NULLS LAST, Product__c NULLS LAST];
        
        for (ProfitMargin__c iProfitMargin:relatedMargins){
            if (iProfitMargin.Product__c != null){
                relatedProductsProfitMap.get(iProfitMargin.Product__c).add(iProfitMargin);
            }
            else{
                for (Id iProduct:relatedHierarchyMap.get(iProfitMargin.ProductHierarchy__c)){
                    relatedProductsProfitMap.get(iProduct).add(iProfitMargin);
                }
            }
        }
    
        for (OrderItem iOrderItem:newOrderItems){
            //checks if none of the maps are empty, if true, addError!
            if (relatedProductsCostMap.get(iOrderItem.Product2Id).isEmpty() ||
                relatedProductsProfitMap.get(iOrderItem.Product2Id).isEmpty() ||
                relatedProductsShippingMap.get(iOrderItem.Product2Id).isEmpty()||
                relatedProductsTaxMap.get(iOrderItem.Product2Id).isEmpty()){
                

                iOrderItem.addError('RE - Não está autorizada a venda deste produto devido a falta de parâmetros, entre em contato com o time de pricing.'); 
            }
        }
    }

    /*
    public static void handleTax(OrderItem[] newOrderItems){
        if (newOrderItems.isEmpty()){
            return;
        }
        System.debug('TX');
        for (OrderItem iOrderItem:newOrderItems){
            iOrderItem.TaxPercentage__c = null;
            for (Tax__c iTax: relatedProductsTaxMap.get(iOrderItem.Product2Id)){
                if (iTax.State__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__r.State__c){
                    iOrderItem.TaxPercentage__c = iTax.TaxOnCost__c;
                    iOrderItem.Tax__c = iTax.Id;
                    break;
                }

            } 
            if (iOrderItem.TaxPercentage__c == null){
                iOrderItem.addError('TX - Não está autorizada a venda deste produto devido a falta de parâmetros, entre em contato com o time de pricing.');
            }
        }
    }
    public static void handleShipping(OrderItem[] newOrderItems){
        if (newOrderItems.isEmpty()){
            return;
        }
        System.debug('SH');
        
        
        
        for (OrderItem iOrderItem:newOrderItems){
            Integer[] mostSpecificOptions = new Integer[]{};
            Shipping__c mostSpecificObject = null;
            for (Shipping__c iShipping: relatedProductsShippingMap.get(iOrderItem.Product2Id)){
                Integer[] currentOptions = new Integer[]{};
                if (iShipping.Product__c != null){
                    
                    currentOptions.add(1);
                }
                else{
                    
                    currentOptions.add(2);
                }
                if(iShipping.City__c != null){
                    
                    if (iShipping.City__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__c){
                        currentOptions.add(1);
                    }
                }
                else if(iShipping.State__c != null){
                    
                    if (iShipping.State__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__r.State__c){ 
                        currentOptions.add(2);
                    }
                }
                else if(iShipping.Country__c != null){
                    
                    if (iShipping.Country__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__r.State__r.Country__c){ 
                        currentOptions.add(3);
                    }
                }
                if (currentOptions.size()==2){
                    if (mostSpecificObject == null){
                        mostSpecificObject = iShipping;
                        mostSpecificOptions = currentOptions;
                    }
                    else{
                        if (currentOptions[0]<mostSpecificOptions[0]){
                            mostSpecificObject = iShipping;
                            mostSpecificOptions = currentOptions;
                        }
                        else if (currentOptions[0] == mostSpecificOptions[0] && currentOptions[1]<mostSpecificOptions[1]){
                            mostSpecificObject = iShipping;
                            mostSpecificOptions = currentOptions;
                        }
                    }
                }

            }
            if (mostSpecificObject == null){
                iOrderItem.addError('SH - Não está autorizada a venda deste produto devido a falta de parâmetros, entre em contato com o time de pricing.');            
            }
            else{
                iOrderItem.ShippingCost__c = mostSpecificObject.Value__c;
                iOrderItem.Shipping__c = mostSpecificObject.Id;
            }
        }
    }
    public static void handleProfitMargin(OrderItem[] newOrderItems){
        if (newOrderItems.isEmpty()){
            return;
        }
        System.debug('PF');
        
        
        
        for (OrderItem iOrderItem:newOrderItems){
            Integer[] mostSpecificOptions = new Integer[]{};
            ProfitMargin__c mostSpecificObject = null;
            for (ProfitMargin__c iProfitMargin: relatedProductsProfitMap.get(iOrderItem.Product2Id)){
                Integer[] currentOptions = new Integer[]{};
                if (iProfitMargin.Product__c != null){
                    
                    currentOptions.add(1);
                }
                else{
                    
                    currentOptions.add(2);
                }
                if (iProfitMargin.Account__c != null){
                    
                    if (iProfitMargin.Account__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountId){
                        currentOptions.add(1);
                    }
                }
                else{
                    if (iProfitMargin.AccountGroup__c == relatedOrdersMap.get(iOrderItem.OrderId).Account.AccountGroup__c){
                        currentOptions.add(2);
                    }
                }
                if(iProfitMargin.City__c != null){
                    
                    if (iProfitMargin.City__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__c){
                        currentOptions.add(1);
                    }
                }
                else if(iProfitMargin.State__c != null){
                    
                    if (iProfitMargin.State__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__r.State__c){ 
                        currentOptions.add(2);
                    }
                }
                else if(iProfitMargin.Country__c != null){
                    
                    if (iProfitMargin.Country__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__r.State__r.Country__c){ 
                        currentOptions.add(3);
                    }
                }
                
                if (currentOptions.size()==3){
                    if (mostSpecificObject == null){
                        mostSpecificObject = iProfitMargin;
                        mostSpecificOptions = currentOptions;
                    }
                    else{
                        if (currentOptions[0]<mostSpecificOptions[0]){
                            mostSpecificObject = iProfitMargin;
                            mostSpecificOptions = currentOptions;
                        }
                        else if (currentOptions[0] == mostSpecificOptions[0] && currentOptions[1]<mostSpecificOptions[1]){
                            mostSpecificObject = iProfitMargin;
                            mostSpecificOptions = currentOptions;
                        }
                        else if (currentOptions[0] == mostSpecificOptions[0] && currentOptions[1] == mostSpecificOptions[1] && currentOptions[2] < mostSpecificOptions[2]){
                            mostSpecificObject = iProfitMargin;
                            mostSpecificOptions = currentOptions;
                        }
                    }
                }

            }
            if (mostSpecificObject == null){
                iOrderItem.addError('PM - Não está autorizada a venda deste produto devido a falta de parâmetros, entre em contato com o time de pricing.');            
            }
            else{
                iOrderItem.MarginPercentage__c = mostSpecificObject.MarginPercentage__c;
                iOrderItem.ProfitMargin__c = mostSpecificObject.Id;
            }
        }
    }
    public static void handleProductCost(OrderItem[] newOrderItems){
        if (newOrderItems.isEmpty()){
            return;
        }
        System.debug('PC');
        for (OrderItem iOrderItem:newOrderItems){
            for (PricebookEntry iPricebookEntry:relatedProductsCostMap.get(iOrderItem.Product2Id)){
                iOrderItem.ProductCost__c = iPricebookEntry.UnitPrice; //there should be only 1 price per Product2, therefore it's a length 1 for loop

            }
        }
    }
    */

    public static void handleSpecificity(OrderItem[] newOrderItems,String objectType){
        //possibly replace String objectType with an Enum, eventually
        //expected call would be handleSpecificity(newOrderItems,'Tax');
        
        if (newOrderItems.isEmpty()){
            return;
        }
        
        Map<Id,SObject[]> relatedObjectsMap;
        Integer expectedSize;
        Integer[] expectedBest;
        String field1;
        String field2;
        
        if (objectType == 'Margin'){
            relatedObjectsMap = relatedProductsProfitMap;
            expectedSize = 3;
            expectedBest = new Integer[]{1,1,1};
        }
        else if (objectType == 'Shipping'){
            relatedObjectsMap = relatedProductsShippingMap;
            expectedSize = 2;
            expectedBest = new Integer[]{1,1};
        }
        else if (objectType=='Tax'){ //special case
            System.debug('TX');
            for (OrderItem iOrderItem:newOrderItems){
                iOrderItem.TaxPercentage__c = null;
                for (Tax__c iTax: relatedProductsTaxMap.get(iOrderItem.Product2Id)){
                    if (iTax.State__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__r.State__c){
                        iOrderItem.TaxPercentage__c = iTax.TaxOnCost__c;
                        iOrderItem.Tax__c = iTax.Id;
                        break;
                    }

                } 
                if (iOrderItem.TaxPercentage__c == null){
                    iOrderItem.addError(objectType+' - Não está autorizada a venda deste produto devido a falta de parâmetros, entre em contato com o time de pricing.');
                }
            }
            return;

        }
        else if (objectType == 'Cost'){ //special case
            System.debug('PC');
            for (OrderItem iOrderItem:newOrderItems){
                for (PricebookEntry iPricebookEntry:relatedProductsCostMap.get(iOrderItem.Product2Id)){
                    iOrderItem.ProductCost__c = iPricebookEntry.UnitPrice; //there should be only 1 price per Product2, therefore it's a length 1 for loop

                }
            }
            return;
        }


        for (OrderItem iOrderItem:newOrderItems){
            Integer[] mostSpecificOptions = new Integer[]{};
            SObject mostSpecificObject = null;
            for (SObject iObject: relatedObjectsMap.get(iOrderItem.Product2Id)){
                Integer[] currentOptions = new Integer[]{};
                if (iObject.get('Product__c') != null){
                    
                    currentOptions.add(1);
                }
                else{
                    
                    currentOptions.add(2);
                }

                
                if(iObject.get('City__c') != null){
                    
                    if (iObject.get('City__c') == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__c){
                        currentOptions.add(1);
                    }
                }
                else if(iObject.get('State__c') != null){
                    
                    if (iObject.get('State__c') == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__r.State__c){ 
                        currentOptions.add(2);
                    }
                }
                else if(iObject.get('Country__c') != null){
                    
                    if (iObject.get('Country__c') == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__r.State__r.Country__c){ 
                        currentOptions.add(3);
                    }
                }
                if (objectType == 'Margin'){ //since margin is the only one that requires account/AccountGroup
                    if (iObject.get('Account__c') != null){
                        if (iObject.get('Account__c') == relatedOrdersMap.get(iOrderItem.OrderId).AccountId){
                            currentOptions.add(1);
                        }
                    }
                    else{
                        if (iObject.get('AccountGroup__c') == relatedOrdersMap.get(iOrderItem.OrderId).Account.AccountGroup__c){
                            currentOptions.add(2);
                        }
                    }

                }


                if (currentOptions.size()==expectedSize){
                    if (currentOptions == expectedBest){//found the best possible case
                        mostSpecificObject = iObject;
                        mostSpecificOptions = currentOptions;
                        System.debug('Break!');
                        break;
                    }
                    else if (mostSpecificObject == null){//initial case
                        mostSpecificObject = iObject;
                        mostSpecificOptions = currentOptions;
                    }
                    else{//comparison case
                        if (currentOptions[0]<mostSpecificOptions[0]){
                            mostSpecificObject = iObject;
                            mostSpecificOptions = currentOptions;
                        }
                        else if (expectedSize>1){
                            if (currentOptions[0] == mostSpecificOptions[0] && currentOptions[1]<mostSpecificOptions[1]){
                                mostSpecificObject = iObject;
                                mostSpecificOptions = currentOptions;
                            }
                        }
                        else if (expectedSize>2){
                            if (currentOptions[0] == mostSpecificOptions[0] && currentOptions[1] == mostSpecificOptions[1] && currentOptions[2] < mostSpecificOptions[2]){
                                mostSpecificObject = iObject;
                                mostSpecificOptions = currentOptions;
                            }
                        }
                    }
                }
            }


            if (mostSpecificObject == null){
                iOrderItem.addError(objectType+' - Não está autorizada a venda deste produto devido a falta de parâmetros, entre em contato com o time de pricing.');            
            }
            else{
                if (objectType == 'Margin'){
                    iOrderItem.put('MarginPercentage__c', mostSpecificObject.get('MarginPercentage__c'));
                    iOrderItem.put('ProfitMargin__c', mostSpecificObject.Id);
                }
                else if (objectType == 'Shipping'){
                    iOrderItem.put('ShippingCost__c', mostSpecificObject.get('Value__c'));
                    iOrderItem.put('Shipping__c', mostSpecificObject.Id);
                }
                
            }
           


        }

    }
    
    
}