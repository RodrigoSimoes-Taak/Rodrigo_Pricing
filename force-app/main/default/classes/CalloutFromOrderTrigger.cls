public with sharing class CalloutFromOrderTrigger {
    @future(callout=true)
    public static void calloutToExternalSystem(Id[] orderIds,String requestURL){
        CalloutOrder.processIntegration(orderIds, requestURL);
    }
}