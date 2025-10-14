public with sharing class OrderTriggerHelper {
    public static void handleUpdateOrder(List<Order> newRecordList){
        System.debug('OrderTriggerHelper!');
        List<Id> orderIdsToSend = new List<Id>();
        List<Approval.ProcessSubmitRequest> ordersToApprove = new List<Approval.ProcessSubmitRequest>();
        for (Order iOrder:newRecordList){
            if (iOrder.Status == 'Em Aprovação'){
                if (iOrder.HighestDiscount__c >=20){
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    System.debug('Teste4');
                    approvalRequest.setObjectId(iOrder.Id);
                    approvalRequest.setSubmitterId(UserInfo.getUserId());
                    approvalRequest.setProcessDefinitionNameOrId('DiscountApproval');
                    ordersToApprove.add(approvalRequest);
                }
                else{
                    iOrder.Status = 'Aprovado';
                }
            }
            if (iOrder.Status == 'Aprovado'){
                iOrder.Observations__c = 'Teste :)';
                orderIdsToSend.add(iOrder.Id);
            }
            
            
                
        }
        if (!ordersToApprove.isEmpty()){
            List<Approval.ProcessResult> approvalResult = Approval.process(ordersToApprove);
            
            System.debug(approvalResult);
        }
        
        if (!orderIdsToSend.isEmpty()){
            sendOrdersToCallout(orderIdsToSend);
            
        }
    }
    public static void sendOrdersToCallout(List<Id> orderIdsToSend){
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
    @future(callout=true)
    public static void calloutToExternalSystem(List<Id> orderIdsToSend){
        OrderCallout.calloutViaOrderIdList(orderIdsToSend);
    }
}