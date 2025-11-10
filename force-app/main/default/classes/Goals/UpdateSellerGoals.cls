public with sharing class UpdateSellerGoals implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext context){
        String closedStageName = 'Closed Won';
        //TODO: Decide if LIMIT should be used, and the number!
        return Database.getQueryLocator( //gets all Goals from Every user, from this year
            'SELECT Id, Amount, OwnerId, '+
            '(SELECT Product2Id, Product2.ProductHierarchy__c, Quantity,TotalPrice FROM OpportunityLineItems) '+
            'FROM Opportunity WHERE StageName =:closedStageName AND CloseDate = THIS_YEAR'
            );
            
    }
    public void execute(Database.BatchableContext context,  List<Opportunity> opportunities){
        List<Id> relatedSellerIds = new List<Id>();
        for (Opportunity iOpp:opportunities){
            relatedSellerIds.add(iOpp.OwnerId);
        }
        List<GoalItem__c> relatedGoalItemsList = [SELECT Id,Product__c,ProductHierarchy__c,PaymentCondition__c,GoalValue__c,
        ProjectedEarnings__c,NegotiatedEarnings__c,ActualEarnings__c,ReachedPercentage__c,
        CommissionPercentage__c,Goal__r.Seller__c
        FROM GoalItem__c WHERE Goal__r.Seller__c IN:relatedSellerIds AND Goal__r.Year__c =:Date.today().year()];
        Map<Id,List<GoalItem__c>> relatedSellerGoalItemsMap = new Map<Id,List<GoalItem__c>>();

        for (GoalItem__c iGoalItem:relatedGoalItemsList){
            if (!relatedSellerGoalItemsMap.containsKey(iGoalItem.Goal__r.Seller__c)){
                relatedSellerGoalItemsMap.put(iGoalItem.Goal__r.Seller__c,new List<GoalItem__c>());
            }
            relatedSellerGoalItemsMap.get(iGoalItem.Goal__r.Seller__c).add(iGoalItem);
        }
        for (Opportunity iOpp:opportunities){
            for (OpportunityLineItem iOppLineItem:iOpp.OpportunityLineItems){
                for (GoalItem__c iGoalItem:relatedSellerGoalItemsMap.get(iOpp.OwnerId)){
                    if (!GoalComparisons.isGoalItemForPaymentCondition(iGoalItem)){

                        if (GoalComparisons.isGoalItemForHierarchy(iGoalItem)){
                            if (iOppLineItem.Product2.ProductHierarchy__c == iGoalItem.ProductHierarchy__c){
                                iGoalItem.ProjectedEarnings__c += iOppLineItem.TotalPrice;
                            }
                        }

                        else if (GoalComparisons.isGoalItemForProduct(iGoalItem)){
                            if (iOppLineItem.Product2Id == iGoalItem.Product__c){
                                iGoalItem.ProjectedEarnings__c += iOppLineItem.TotalPrice;
                            } 
                        }

                        else{//Means it's a performance goal
                            iGoalItem.ProjectedEarnings__c += iOppLineItem.TotalPrice;
                        }
                    }
                    
                }
                   
            }
            
        }
        GoalUpdates.updateGoalItemsInSF(relatedSellerGoalItemsMap);
        
    }
    public void finish(Database.BatchableContext context){
        // execute any post-processing operations
        Database.executeBatch(new UpdateSellerGoalsOrder()); 
    }
    
    
    
}