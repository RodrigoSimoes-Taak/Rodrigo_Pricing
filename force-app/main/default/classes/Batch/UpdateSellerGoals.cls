public with sharing class UpdateSellerGoals implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext context){
        //TODO: Decide if LIMIT should be used, and the number!
        return Database.getQueryLocator( //gets all Goals from Every user, from this year
            'SELECT NegotiatedEarnings__c,ProjectedEarnings__c,ActualEarnings__c,Seller__c, '+
            '(SELECT Id, RecordTypeId Product__c, ProductHierarchy__c, PaymentCondition__c, GoalValue__c, NegotiatedEarnings__c, '+
            'ProjectedEarnings__c, ActualEarnings__c, GoalAmount__c, NegotiatedAmount__c,ActualAmount__c, ProjectedAmount__c, '+
            'ReachedPercentage__c,CommissionPercentage__c FROM GoalItems__r) '+
            'FROM Goal__c WHERE Year__c ='+Date.today().year()
            );
    }
    public void execute(Database.BatchableContext context,  List<Goal__c> goals){
        List<Id> relatedSellerIds = new List<Id>();
        Map<Id,List<GoalItem__c>> relatedSellerGoalItemMap = new Map<Id,List<GoalItem__c>>();

        for(Goal__c goal : goals){
            relatedSellerIds.add(goal.Seller__c);

            for (GoalItem__c iGoalItem:goal){
                if (!relatedSellerGoalItemMap.containsKey(goal.Seller__c)){
                    relatedSellerGoalItemMap.put(goal.Seller__c,new List<GoalItem__c>());
                }
                iGoalItem.ProjectedAmount__c = 0;
                iGoalItem.NegotiatedAmount__c = 0;
                iGoalItem.ActualAmount__c = 0;
                relatedSellerGoalItemMap.get(goal.Seller__c).add(iGoalItem);
            }

            
        }
        List<Opportunity> sellerOppList = [
            SELECT Id,Amount,
            (SELECT Product2Id,Product2.ProductHierarchy__c,Quantity,TotalPrice FROM OpportunityLineItems)
            FROM Opportunity WHERE OwnerId IN:relatedSellerIds AND StageName = 'Closed Won' AND CloseDate = THIS_YEAR
            ];
        for (Opportunity iOpp:sellerOppList){
            for (GoalItem__c iGoalItem:relatedSellerGoalItemMap.get(iOpp.OwnerId)){
                if (iGoalItem.ProductHierarchy__c != null && iOpp.OpportunityLineItems.Product2.ProductHierarchy__c == iGoalItem.ProductHierarchy__c){
                    iGoalItem.ProjectedAmount__c += iOpp.OpportunityLineItems.Quantity;
                    
                }
                else if (iGoalItem.Product__c != null && iOpp.OpportunityLineItems.Product2Id == iGoalItem.Product__c){
                    iGoalItem.ProjectedAmount__c += iOpp.OpportunityLineItems.Quantity;
                }
            }
        }

        
        

        List<Order> sellerOrderList = [
            SELECT Id, PaymentCondition__c, OwnerId,
            (SELECT Product2Id, Product2.ProductHierarchy__c FROM OrderItems)
            FROM Order WHERE OwnerId IN:relatedSellerIds AND (ActivatedDate = THIS_YEAR OR StatusCode!= 'Activated')]; //An order COULD start in one year and finish in another, which date do I grab?
        //REMINDER: If it's in 'Erro de Integração', it has been APPROVED and ACTIVATED, but the integration didn't work
        Map<Id,List<Order>> sellerOrderMap = new Map<Id,List<Order>>();

        for (Order iOrder:sellerOrderList){
            if (!sellerOrderMap.containsKey(iOrder.OwnerId)){
                sellerOrderMap.put(iOrder.OwnerId,new List<Order>());
            }
            sellerOrderMap.get(iOrder.OwnerId).add(iOrder);
        }
        
        
        
        //if Opps == Closed Won -> ProjectedEarnings
        //if Order.StatusCode != Activated -> NegotiatedEarnings
        //if Order.StatusCode == Activated -> ActualEarnings 

        
    }
    public void finish(Database.BatchableContext context){
        // execute any post-processing operations
    }
}