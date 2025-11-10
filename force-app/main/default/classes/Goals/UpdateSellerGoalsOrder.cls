public with sharing class UpdateSellerGoalsOrder implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(
            'SELECT Id, PaymentCondition__c, OwnerId, ActivatedDate,Status,StatusCode,OrderItemSum__c,'+
            '(SELECT Product2Id, Product2.ProductHierarchy__c,Quantity,FinalPriceWithDiscount__c FROM OrderItems)'+
            'FROM Order WHERE ActivatedDate = THIS_YEAR OR StatusCode!= \'Activated\''
        );
    }
    public void execute(Database.BatchableContext context, List<Order> orders){

        List<Id> relatedSellerIds = new List<Id>();
        for (Order iOrder:orders){
            relatedSellerIds.add(iOrder.OwnerId);
        }
        List<Goal__c> relatedGoals = [SELECT Id FROM Goal__c WHERE Seller__c IN:relatedSellerIds AND Year__c =: Date.today().year()];
        Map<Id,List<Goal__c>> relatedSellerGoalMap = new Map<Id,List<Goal__c>>();

        /*
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
    
        
        
        */
    }
    public void finish(Database.BatchableContext context){

    }

    
}