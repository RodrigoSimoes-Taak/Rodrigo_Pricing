public with sharing class OrderTriggerHelper {
    public static void checkIfApprovalRequired(List<Order> newRecordList) {
        System.debug('OrderTriggerHelper!');
        List<Id> orderIdsToSend = new List<Id>();
        List<Approval.ProcessSubmitRequest> ordersToApprove = new List<Approval.ProcessSubmitRequest>();
        for (Order iOrder : newRecordList) {
            if (iOrder.Status == 'Em Aprovação') {
                if (iOrder.HighestDiscount__c >= 20) {
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    System.debug('Teste4');
                    approvalRequest.setObjectId(iOrder.Id);
                    approvalRequest.setSubmitterId(UserInfo.getUserId());
                    approvalRequest.setProcessDefinitionNameOrId('DiscountApproval');
                    ordersToApprove.add(approvalRequest);
                } 

                else {
                    iOrder.Status = 'Aprovado';
                }
            }
        }
        if (!ordersToApprove.isEmpty()) {
            List<Approval.ProcessResult> approvalResult = Approval.process(ordersToApprove);
            System.debug(approvalResult);
        }

    }
  public static void sendOrdersToCallout(Map<Id,Order> newRecordMap) {
    List<Id> orderIdsToSend = new List<Id>();
    for (Id iId: newRecordMap.keySet()){
        if (newRecordMap.get(iId).Status == 'Aprovado') {
            orderIdsToSend.add(iId);
        }
    }
    if (!orderIdsToSend.isEmpty()){
        calloutToExternalSystem(orderIdsToSend);
        System.debug('OrderTrigger Callout sem erros!');
    }
  }
  @future(callout=true)
  public static void calloutToExternalSystem(List<Id> orderIdsToSend) {
    OrderCallout.calloutViaOrderIdList(orderIdsToSend);
  }
}
