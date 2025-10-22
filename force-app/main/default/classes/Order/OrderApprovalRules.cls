public with sharing class OrderApprovalRules implements Approvalrules {
    public static void checkIfNeedsApproval(List<SObject> sObjectsToEvaluate){

        List<Approval.ProcessSubmitRequest> ordersNeedApproval = new List<Approval.ProcessSubmitRequest>();
        List<Order> ordersToEvaluate = (List<Order>)sObjectsToEvaluate;
        for (Order iOrder:ordersToEvaluate){
            if (iOrder.Status == 'Em Aprovação'){
                Boolean requiresApproval = false;
                requiresApproval = checkDiscount(iOrder,ordersNeedApproval);
                //if it requires approval, skip to the next order
                if (requiresApproval){
                    continue;
                }
                //Add any future business approval rules here!


                //if no approvals required
                if (!requiresApproval){
                    iOrder.Status = 'Aprovado';
                }
            }
            
        }

        if (!ordersNeedApproval.isEmpty()){

            sendToApproval(ordersNeedApproval);
        }
    }

    public static void sendToApproval(List<Approval.ProcessSubmitRequest> ordersNeedApproval){

        List<Approval.ProcessResult> approvalResult = Approval.process(ordersNeedApproval);
        System.debug(approvalResult);
    }

    public static Boolean checkDiscount(Order orderToEvaluate,List<Approval.ProcessSubmitRequest> ordersNeedApproval){

        Decimal maxDiscountBeforeApproval = Decimal.valueOf(DevParameters__mdt.getInstance('ApprovalPercentage').Value__c);

        if (orderToEvaluate.HighestDiscount__c >= maxDiscountBeforeApproval) {

            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            System.debug('Teste4');
            approvalRequest.setObjectId(orderToEvaluate.Id);
            approvalRequest.setSubmitterId(UserInfo.getUserId());
            approvalRequest.setProcessDefinitionNameOrId('DiscountApproval');
            ordersNeedApproval.add(approvalRequest);
            return true;

        } 
        return false;
        
            
    }
}