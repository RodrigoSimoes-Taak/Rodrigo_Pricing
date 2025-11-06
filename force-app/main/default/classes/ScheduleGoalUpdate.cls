public with sharing class ScheduleGoalUpdate implements Schedulable {
    public void execute(SchedulableContext context){
        Database.executeBatch(new UpdateSellerGoals(),50);
    }
}