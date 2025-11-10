public with sharing class GoalUpdates {
    public static void updateGoalItemsInSF(Map<Id,List<GoalItem__c>> relatedSellerGoalItemMap){
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
    public static void updateGoalsInSF(Map<Id,Goal__c> goalsToUpdateMap){
        if (!goalsToUpdateMap.isEmpty()){
            System.debug('Updated goals: '+goalsToUpdateMap);
            update (List<Goal__c>)goalsToUpdateMap.values();
        }
        
    }
}