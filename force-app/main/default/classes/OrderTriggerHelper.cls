public with sharing class OrderTriggerHelper {
    public static void handleUpdateOrder(List<Order> newRecordList, Map<Id,Order> oldRecordMap){
        List<Id> orderIdsToSend = new List<Id>();
        for (Order iOrder:newRecordList){
            if (iOrder.Status == 'Aprovado'){
                iOrder.Observations__c = 'Teste :)';
                orderIdsToSend.add(iOrder.Id);
            }
        }
        if (orderIdsToSend.size()>0){
            
            try{
                calloutToExternalSystem(orderIdsToSend);
                
                System.debug('OrderTrigger Callout sem erros!');
            }
            catch(Exception e){
                List<Order> ordersToUpdate = new List<Order>();
                Trigger.new[0].addError('Erro ao dar callout! ' + e);
                for (Id iOrderId:orderIdsToSend){
                    ordersToUpdate.add(new Order(Id=iOrderId,Status='Erro De Integração'));
                }
                update ordersToUpdate;
            }
        }
    }
    @future(callout=true)
    public static void calloutToExternalSystem(List<Id> orderIdsToSend){
        OrderCallout.calloutViaOrderIdList(orderIdsToSend);
    }
}