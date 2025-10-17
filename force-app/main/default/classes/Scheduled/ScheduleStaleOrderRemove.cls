public with sharing class ScheduleStaleOrderRemove implements Schedulable {
    public void execute(SchedulableContext context){
        Database.executeBatch(new BatchStaleOrderRemove(),10);
        
    }
}