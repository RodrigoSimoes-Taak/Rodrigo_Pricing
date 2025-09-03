public with sharing class OrderItemTriggerHelper {
    public static Map<Id,Map<String,SObject[]>> relatedProductsMap = new Map<Id,Map<String,SObject[]>>(); //Map that relates products to
                                                                                                //Shipping, PriceBooks, Tax and
                                                                                                //Margin
    public static Map<Id,Order> relatedOrdersMap;                                                                 
    public static void handleInsertOrderItem(OrderItem[] newOrderItems){
        //checar se possui Custo de producao, Frete, Imposto e Margem
        Set<Id> relatedOrders = new Set<Id>();
        for (OrderItem iOrderItem:newOrderItems){
            relatedOrders.add(iOrderItem.OrderId);
        }
        relatedOrdersMap = new Map<Id,Order>([SELECT Id, AccountAddress__r.City__c,AccountAddress__r.City__r.State__c,
        AccountAddress__r.City__r.State__r.Country__c,Account.AccountGroup__c,AccountId 
        FROM Order 
        WHERE Id IN :relatedOrders]);

        for (OrderItem iOrderItem:newOrderItems){//acredito que o problema é que ProductHierarchy__c esta muito longe, logo nao pode ser pego!
            //iOrderItem.Product2.ProductHierarchy__c retorna nulo!
            if (!relatedProductsMap.containsKey(iOrderItem.Product2Id)){

                relatedProductsMap.put(iOrderItem.Product2Id,new Map<String,SObject[]>());
                relatedProductsMap.get(iOrderItem.Product2Id).put('PricebookEntry',new PricebookEntry[]{});
                relatedProductsMap.get(iOrderItem.Product2Id).put('Shipping',new Shipping__c[]{});
                relatedProductsMap.get(iOrderItem.Product2Id).put('Tax',new Tax__c[]{});
                relatedProductsMap.get(iOrderItem.Product2Id).put('Margin',new ProfitMargin__c[]{});
            }
            
        }

        Map<Id,Id[]> relatedHierarchyMap = new Map<Id,Id[]>(); //relaciona Map<ProductHierarchy__c.Id,Product2Id[]>, já que uma hierarquia pode ter varios produtos
        for (Product2 iProduct:[SELECT Id, ProductHierarchy__c FROM Product2 WHERE Id IN:relatedProductsMap.keySet()]){
            if (iProduct.ProductHierarchy__c != null){
                if (!relatedHierarchyMap.containsKey(iProduct.ProductHierarchy__c)){
                    relatedHierarchyMap.put(iProduct.ProductHierarchy__c,new Id[]{});
                }
                relatedHierarchyMap.get(iProduct.ProductHierarchy__c).add(iProduct.Id);  
            }    
        }
        //procurar hierarquias baseado no product2 relacionados, e aí inserir as hierarquias
        //precisa pegar valor de custo de producao (pricebookentry) frete, imposto e margem!
        //vv custo de produção
        PricebookEntry[] relatedPricebooks = [SELECT UnitPrice,Product2Id FROM PricebookEntry 
                                            WHERE Product2Id IN :relatedProductsMap.keySet() AND isActive = True 
                                            AND Pricebook2.isActive = True ]; //checks if pricebook is active and listing is active
        for (PricebookEntry iPricebookEntry:relatedPricebooks){//adds all pricebook entries to their product
            relatedProductsMap.get(iPricebookEntry.Product2Id).get('PricebookEntry').add(iPricebookEntry);
        }
        
        System.debug('D1 '+relatedHierarchyMap);
        System.debug('D2 '+relatedProductsMap);
        
        //vv Frete
        Shipping__c[] relatedShippings = [SELECT Value__c,Product__c,ProductHierarchy__c,City__c,State__c,Country__c 
        FROM Shipping__c 
        WHERE (Product__c IN :relatedProductsMap.keySet() OR ProductHierarchy__c IN :relatedHierarchyMap.keySet())
        AND Status__c = 'Aprovado'];
        System.debug(relatedShippings.size());
        for (Shipping__c iShipping:relatedShippings){
            System.debug(relatedShippings);
            if (iShipping.Product__c != null){
                relatedProductsMap.get(iShipping.Product__c).get('Shipping').add(iShipping);
                System.debug('Pos shipping');
            }
            else{
                for (Id iProduct:relatedHierarchyMap.get(iShipping.ProductHierarchy__c)){
                    relatedProductsMap.get(iProduct).get('Shipping').add(iShipping);
                }
                
            }
        }
        System.debug('D3 '+relatedProductsMap);
        
        //vv Imposto
        Tax__c[] relatedTaxes = [SELECT TaxOnCost__c,Product__c,State__c FROM Tax__c WHERE Product__c IN :relatedProductsMap.keySet() AND Status__c = 'Aprovado'];
        for (Tax__c iTax:relatedTaxes){
            relatedProductsMap.get(iTax.Product__c).get('Tax').add(iTax);
        }
        System.debug('D4 '+relatedProductsMap);

        //vv Margem
        ProfitMargin__c[] relatedMargins =[SELECT ProductHierarchy__c,Product__c,City__c,State__c,Country__c,AccountGroup__c,Account__c,MarginPercentage__c
        FROM ProfitMargin__c 
        WHERE (Product__c IN :relatedProductsMap.keySet() OR ProductHierarchy__c IN :relatedHierarchyMap.keySet()) 
        AND Status__c = 'Aprovado'];
        
        for (ProfitMargin__c iProfitMargin:relatedMargins){
            if (iProfitMargin.Product__c != null){
                relatedProductsMap.get(iProfitMargin.Product__c).get('Margin').add(iProfitMargin);
            }
            else{
                for (Id iProduct:relatedHierarchyMap.get(iProfitMargin.ProductHierarchy__c)){
                    relatedProductsMap.get(iProduct).get('Margin').add(iProfitMargin);
                }
            }
        }
    
        for (OrderItem iOrderItem:newOrderItems){
            //checks if none of the maps inside the maps are empty, if true, addError!
            if (relatedProductsMap.get(iOrderItem.Product2Id).get('PricebookEntry').isEmpty() ||
                relatedProductsMap.get(iOrderItem.Product2Id).get('Shipping').isEmpty() ||
                relatedProductsMap.get(iOrderItem.Product2Id).get('Tax').isEmpty()||
                relatedProductsMap.get(iOrderItem.Product2Id).get('Margin').isEmpty()){
                

                iOrderItem.addError('01 - Não está autorizada a venda deste produto devido a falta de parâmetros, entre em contato com o time de pricing.'); 
            }
        }
    }
    public static void handleTax(OrderItem[] newOrderItems){
        if (newOrderItems.isEmpty()){
            return;
        }
        System.debug('TX1 '+relatedProductsMap);
        for (OrderItem iOrderItem:newOrderItems){
            for (Tax__c iTax: ((Tax__c[])relatedProductsMap.get(iOrderItem.Product2Id).get('Tax'))){
                if (iTax.State__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__r.State__c){
                    iOrderItem.TaxPercentage__c = iTax.TaxOnCost__c;
                    iOrderItem.Tax__c = iTax.Id;
                    break;
                }

            } 
            if (iOrderItem.TaxPercentage__c == null){
                iOrderItem.addError('02 - Não está autorizada a venda deste produto devido a falta de parâmetros, entre em contato com o time de pricing.');
            }
        }
        
    }
    public static void handleShipping(OrderItem[] newOrderItems){
        if (newOrderItems.isEmpty()){
            return;
        }
        System.debug('SH2 '+relatedProductsMap);
        Integer[] opcoes = new Integer[]{};
        Shipping__c selecionado;
        Integer[] melhor = new Integer[]{};
        for (OrderItem iOrderItem:newOrderItems){
            melhor.clear();
            selecionado = null;
            for (Shipping__c iShipping: ((Shipping__c[])relatedProductsMap.get(iOrderItem.Product2Id).get('Shipping'))){
                opcoes.clear();
                if (iShipping.Product__c != null){
                    //quer dizer que eh relacao de produto!
                    opcoes.add(1);
                }
                else{
                    //quer dizer que eh relacao de hierarquia!
                    opcoes.add(2);
                }
                if(iShipping.City__c != null){
                    //quer dizer que tem cidade!
                    if (iShipping.City__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__c){//logo cidade bate
                        opcoes.add(1);
                    }
                }
                else if(iShipping.State__c != null){
                    //quer dizer que tem estado!
                    if (iShipping.State__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__r.State__c){ //logo estado bate
                        opcoes.add(2);
                    }
                }
                else if(iShipping.Country__c != null){
                    //quer dizer que tem pais!
                    if (iShipping.Country__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__r.State__r.Country__c){ //logo pais bate
                        opcoes.add(3);
                    }
                }
                if (opcoes.size()==2){
                    if (selecionado == null){
                        selecionado = iShipping;
                        melhor = opcoes;
                    }
                    else{
                        if (opcoes[0]<melhor[0]){
                            selecionado = iShipping;
                            melhor = opcoes;
                        }
                        else if (opcoes[0] == melhor[0] && opcoes[1]<melhor[1]){
                            selecionado = iShipping;
                            melhor = opcoes;
                        }
                    }
                }

            }
            if (selecionado == null){
                iOrderItem.addError('03 - Não está autorizada a venda deste produto devido a falta de parâmetros, entre em contato com o time de pricing.');            
            }
            else{
                iOrderItem.ShippingCost__c = selecionado.Value__c;
                iOrderItem.Shipping__c = selecionado.Id;
            }
        }
    }
    public static void handleProfitMargin(OrderItem[] newOrderItems){
        if (newOrderItems.isEmpty()){
            return;
        }
        System.debug('PF2 '+relatedProductsMap);
        Integer[] opcoes = new Integer[]{};
        ProfitMargin__c selecionado;
        Integer[] melhor = new Integer[]{};
        for (OrderItem iOrderItem:newOrderItems){
            melhor.clear();
            selecionado = null;
            for (ProfitMargin__c iProfitMargin: ((ProfitMargin__c[])relatedProductsMap.get(iOrderItem.Product2Id).get('Margin'))){
                opcoes.clear();
                if (iProfitMargin.Product__c != null){
                    //quer dizer que eh relacao de produto!
                    opcoes.add(1);
                }
                else{
                    //quer dizer que eh relacao de hierarquia!
                    opcoes.add(2);
                }
                if (iProfitMargin.Account__c != null){
                    //quer dizer que eh para conta
                    if (iProfitMargin.Account__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountId){
                        opcoes.add(1);
                    }
                }
                else{
                    if (iProfitMargin.AccountGroup__c == relatedOrdersMap.get(iOrderItem.OrderId).Account.AccountGroup__c){
                        opcoes.add(2);
                    }
                }
                if(iProfitMargin.City__c != null){
                    //quer dizer que tem cidade!
                    if (iProfitMargin.City__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__c){//logo cidade bate
                        opcoes.add(1);
                    }
                }
                else if(iProfitMargin.State__c != null){
                    //quer dizer que tem estado!
                    if (iProfitMargin.State__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__r.State__c){ //logo estado bate
                        opcoes.add(2);
                    }
                }
                else if(iProfitMargin.Country__c != null){
                    //quer dizer que tem pais!
                    if (iProfitMargin.Country__c == relatedOrdersMap.get(iOrderItem.OrderId).AccountAddress__r.City__r.State__r.Country__c){ //logo pais bate
                        opcoes.add(3);
                    }
                }
                
                if (opcoes.size()==3){
                    if (selecionado == null){
                        selecionado = iProfitMargin;
                        melhor = opcoes;
                    }
                    else{
                        if (opcoes[0]<melhor[0]){
                            selecionado = iProfitMargin;
                            melhor = opcoes;
                        }
                        else if (opcoes[0] == melhor[0] && opcoes[1]<melhor[1]){
                            selecionado = iProfitMargin;
                            melhor = opcoes;
                        }
                        else if (opcoes[0] == melhor[0] && opcoes[1] == melhor[1] && opcoes[2] < melhor[2]){
                            selecionado = iProfitMargin;
                            melhor = opcoes;
                        }
                    }
                }

            }
            if (selecionado == null){
                iOrderItem.addError('03 - Não está autorizada a venda deste produto devido a falta de parâmetros, entre em contato com o time de pricing.');            
            }
            else{
                iOrderItem.MarginPercentage__c = selecionado.MarginPercentage__c;
                iOrderItem.ProfitMargin__c = selecionado.Id;
            }
        }
    }
    public static void handleProductCost(OrderItem[] newOrderItems){
        if (newOrderItems.isEmpty()){
            return;
        }
        System.debug('PC2 '+relatedProductsMap);
        for (OrderItem iOrderItem:newOrderItems){
            for (PricebookEntry iPricebookEntry:((PricebookEntry[])relatedProductsMap.get(iOrderItem.Product2Id).get('PricebookEntry'))){
                iOrderItem.ProductCost__c = iPricebookEntry.UnitPrice;

            }
        }

    }
}