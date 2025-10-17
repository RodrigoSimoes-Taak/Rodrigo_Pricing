public with sharing class BatchStaleOrderRemove implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(
            'SELECT Id,(SELECT Id FROM Attachments) FROM Order WHERE CreatedDate < LAST_N_MONTHS:'+(MonthsToDelete__mdt.getInstance('m01fj00000MnEd3AAF'))
        );
    }
    public void execute(Database.BatchableContext context, List<Order> records){
        System.debug('BatchStaleOrderRemove - Deleting records: '+records);
        List<Attachment> attachments = new List<Attachment>();
        for (Order iOrder:records){
            attachments.addAll(iOrder.Attachments);
        }
        delete attachments;
        delete records;
    }
    public void finish(Database.BatchableContext context){
        System.debug('BatchStaleOrderRemove - Finished Deleting Stale Orders');
    }
}