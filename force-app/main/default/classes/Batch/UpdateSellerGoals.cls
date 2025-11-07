public with sharing class UpdateSellerGoals implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext context){
        //TODO: Decide if LIMIT should be used, and the number!
        return Database.getQueryLocator( //gets all Goals from Every user, from this year
            'SELECT ActualEarnings__c,Seller__c, '+
            '(SELECT Id, RecordTypeId, Product__c, ProductHierarchy__c, PaymentCondition__c, GoalValue__c, '+
            'NegotiatedEarnings__c, ProjectedEarnings__c, ActualEarnings__c,ReachedPercentage__c, CommissionPercentage__c '+
            'FROM GoalItems__r) '+
            'FROM Goal__c WHERE Year__c = '+Date.today().year()
            );
    }
    public void execute(Database.BatchableContext context,  List<Goal__c> goals){
        List<Id> relatedSellerIds = new List<Id>();
        Map<Id,List<GoalItem__c>> relatedSellerGoalItemMap = new Map<Id,List<GoalItem__c>>();
        Map<Id,Goal__c> relatedSellerGoalMap = new Map<Id,Goal__c>();
        for(Goal__c iGoal : goals){
            
            iGoal.ActualEarnings__c = 0;
            relatedSellerGoalMap.put(iGoal.Seller__c,iGoal);

            relatedSellerIds.add(iGoal.Seller__c);
            for (GoalItem__c iGoalItem:iGoal.GoalItems__r){
                if (!relatedSellerGoalItemMap.containsKey(iGoal.Seller__c)){
                    relatedSellerGoalItemMap.put(iGoal.Seller__c,new List<GoalItem__c>());
                }
                
                iGoalItem = resetGoalItem(iGoalItem);
                
                relatedSellerGoalItemMap.get(iGoal.Seller__c).add(iGoalItem);
            }

            
        }
        List<Opportunity> sellerOppList = [
            SELECT Id,Amount, OwnerId,
            (SELECT Product2Id,Product2.ProductHierarchy__c,Quantity,TotalPrice FROM OpportunityLineItems)
            FROM Opportunity WHERE OwnerId IN:relatedSellerIds AND StageName = 'Closed Won' AND CloseDate = THIS_YEAR
            ];
        
        for (Opportunity iOpp:sellerOppList){
            for (OpportunityLineItem iOppLineItem:iOpp.OpportunityLineItems){
                if (relatedSellerGoalItemMap.containsKey(iOpp.OwnerId)){
                    for (GoalItem__c iGoalItem:relatedSellerGoalItemMap.get(iOpp.OwnerId)){

                        if (!isGoalItemForPaymentCondition(iGoalItem)){ //opp doesn't have payment conditions

                            if (isGoalItemForHierarchy(iGoalItem)){
                                if (iOppLineItem.Product2.ProductHierarchy__c == iGoalItem.ProductHierarchy__c){
                                    iGoalItem.ProjectedEarnings__c += iOppLineItem.TotalPrice;
                                }
                            }

                            else if (isGoalItemForProduct(iGoalItem)){
                                if (iOppLineItem.Product2Id == iGoalItem.Product__c){
                                    iGoalItem.ProjectedEarnings__c += iOppLineItem.TotalPrice;
                                }
                            }

                            else{ //Means it's a performance goal
                                iGoalItem.ProjectedEarnings__c += iOppLineItem.TotalPrice;
                            }
                        }
                    }
                }
                
            }
        }

        
        

        List<Order> sellerOrderList = [
            SELECT Id, PaymentCondition__c, OwnerId, ActivatedDate,Status,StatusCode,OrderItemSum__c,
            (SELECT Product2Id, Product2.ProductHierarchy__c,Quantity,FinalPriceWithDiscount__c FROM OrderItems)
            FROM Order WHERE OwnerId IN:relatedSellerIds AND (ActivatedDate = THIS_YEAR OR StatusCode!= 'Activated')]; //An order COULD start in one year and finish in another, which date do I grab?
        //REMINDER: If it's in 'Erro de Integração', it has been APPROVED and ACTIVATED, but the integration didn't work
        //so allow it to count towards goals
        Map<Id,Goal__c> goalsToUpdateMap = new Map<Id,Goal__c>();

        for (Order iOrder:sellerOrderList){
            Boolean addedPaymentCondition = false;
            Boolean orderApproved = isOrderApproved(iOrder);
            if (orderApproved){
                Goal__c relatedGoal = relatedSellerGoalMap.get(iOrder.OwnerId);
                if (goalsToUpdateMap.containsKey(relatedGoal.Id)){
                    goalsToUpdateMap.get(relatedGoal.Id).ActualEarnings__c += iOrder.OrderItemSum__c;
                }
                else{
                    relatedGoal.ActualEarnings__c += iOrder.OrderItemSum__c;
                    goalsToUpdateMap.put(relatedGoal.Id,relatedGoal);
                }
            }
            
            for (OrderItem iOrderItem:iOrder.OrderItems){
                if (relatedSellerGoalItemMap.containsKey(iOrder.OwnerId)){
                    for (GoalItem__c iGoalItem:relatedSellerGoalItemMap.get(iOrder.OwnerId)){
                        if (isGoalItemForHierarchy(iGoalItem)){
                            
                            if (iOrderItem.Product2.ProductHierarchy__c == iGoalItem.ProductHierarchy__c){
                                if (orderApproved){
                                    iGoalItem.ActualEarnings__c += iOrderItem.FinalPriceWithDiscount__c;
                                }
                                else{
                                    iGoalItem.NegotiatedEarnings__c += iOrderItem.FinalPriceWithDiscount__c;
                                }
                                
                            }
                            
                        }
                        else if (isGoalItemForProduct(iGoalItem)){

                            if (iOrderItem.Product2Id == iGoalItem.Product__c){

                                if (orderApproved){
                                    iGoalItem.ActualEarnings__c += iOrderItem.FinalPriceWithDiscount__c;
                                }

                                else{
                                    iGoalItem.NegotiatedEarnings__c += iOrderItem.FinalPriceWithDiscount__c;
                                }
                            }

                        }
                        else if (isGoalItemForPaymentCondition(iGoalItem)){

                            if (iOrder.PaymentCondition__c == iGoalItem.PaymentCondition__c && !addedPaymentCondition){
                                addedPaymentCondition = true;
                                if (orderApproved){
                                    iGoalItem.ActualEarnings__c += iOrderItem.FinalPriceWithDiscount__c;

                                }
                                else{
                                    iGoalItem.NegotiatedEarnings__c +=iOrderItem.FinalPriceWithDiscount__c;
                                }
                            }
                            
                        }
                        else {
                            if (orderApproved){
                                iGoalItem.ActualEarnings__c += iOrderItem.FinalPriceWithDiscount__c;
                                
                            }
                            else{
                                iGoalItem.NegotiatedEarnings__c += iOrderItem.FinalPriceWithDiscount__c;
                            }
                        }
                    
                    }
                }
                
            }
        }

        updateGoalItemsInSF(relatedSellerGoalItemMap);

        updateGoalsInSF(goalsToUpdateMap);
    
        
        
        
    }
    public void finish(Database.BatchableContext context){
        // execute any post-processing operations
    }
    Boolean isOrderApproved(Order order){
        return (order.StatusCode == 'Activated' || order.Status == 'Erro De Integração');
    }
    void updateGoalItemsInSF(Map<Id,List<GoalItem__c>> relatedSellerGoalItemMap){
        List<GoalItem__c> goalItemsToUpdate = new List<GoalItem__c>();
        for (Id iId: relatedSellerGoalItemMap.keySet()){
            for (GoalItem__c iGoalItem:relatedSellerGoalItemMap.get(iId)){
                System.debug('Item de meta: '+iGoalItem);
                if (iGoalItem.ActualEarnings__c>= iGoalItem.GoalValue__c){
                    
                    iGoalItem.ReachedPercentage__c = iGoalItem.CommissionPercentage__c;
                    
                }
                goalItemsToUpdate.add(iGoalItem);
            }
        }
        update goalItemsToUpdate;
        
    }
    void updateGoalsInSF(Map<Id,Goal__c> goalsToUpdateMap){
        if (!goalsToUpdateMap.isEmpty()){
            System.debug('Updated goals: '+goalsToUpdateMap);
            update (List<Goal__c>)goalsToUpdateMap.values();
        }
        
    }
    Boolean isGoalItemForHierarchy(GoalItem__c iGoalItem){
        return iGoalItem.ProductHierarchy__c != null;
    }
    Boolean isGoalItemForProduct(GoalItem__c iGoalItem){
        return iGoalItem.Product__c != null;
    }
    Boolean isGoalItemForPaymentCondition(GoalItem__c iGoalItem){
        return iGoalItem.PaymentCondition__c != null;
    }
    GoalItem__c resetGoalItem(GoalItem__c iGoalItem){
        iGoalItem.ProjectedEarnings__c = 0;
        iGoalItem.NegotiatedEarnings__c = 0;
        iGoalItem.ActualEarnings__c = 0;
        return iGoalItem;
    }
}