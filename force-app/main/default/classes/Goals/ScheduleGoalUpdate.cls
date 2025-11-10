public with sharing class ScheduleGoalUpdate implements Schedulable {
    public void execute(SchedulableContext context){
        //!!!reset all goal fields? Or is that overkill? Makes sense?
        List<Goal__c> goalsToReset = [
            SELECT Id,(SELECT Id FROM GoalItems__r) 
            FROM Goal__c WHERE Year__c =:Date.today().year()];
        for (Goal__c iGoal:goalsToReset){
            iGoal.ActualEarnings__c = 0;
            for (GoalItem__c iGoalItem:iGoal.GoalItems__r){
                iGoalItem.ActualEarnings__c = 0;
                iGoalItem.NegotiatedEarnings__c = 0;
                iGoalItem.ProjectedEarnings__c = 0;
                iGoalItem.ReachedPercentage__c = 0;
            }
        }
        update goalsToReset;
        
        Database.executeBatch(new UpdateSellerGoals());
    }
}