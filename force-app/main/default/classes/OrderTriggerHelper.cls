public with sharing class OrderTriggerHelper {
    public static void handleUpdateOrder(List<Order> newRecordList, Map<Id,Order> oldRecordMap){
        List<Id> OrderIdsToSend = new List<Id>();
        for (Order iOrder:newRecordList){
            if (iOrder.Status == 'Activated' && oldRecordMap.get(iOrder.Id).Status == 'Draft'){
                iOrder.Observations__c = 'Teste :)';
                iOrder.Status = 'Draft';
                OrderIdsToSend.add(iOrder.Id);

            }
        }
        if (OrderIdsToSend.size()>0){
            //https://resilient-shark-cuvy0j-dev-ed.trailblaze.my.salesforce.com/services/apexrest/upsertOrder/*
            //https://brave-unicorn-rf9nqw-dev-ed.trailblaze.my.salesforce.com/services/apexrest/upsertOrder/*
            try{
                CalloutFromOrderTrigger.calloutToExternalSystem(OrderIdsToSend, 'https://resilient-shark-cuvy0j-dev-ed.trailblaze.my.salesforce.com/services/apexrest/upsertOrder/*');
                System.debug('OrderTrigger Callout sem erros!');
            }
            catch(Exception e){
                Trigger.new[0].addError('Erro ao dar callout! ' + e);
            }
        }
    }
}