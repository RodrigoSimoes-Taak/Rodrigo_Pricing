public with sharing class OrderTriggerHelper {
    public static void checkIfApprovalRequired(List<Order> newRecordList) {

        System.debug('OrderTriggerHelper!');
        
        
        OrderApprovalRules.checkIfNeedsApproval(newRecordList);
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
