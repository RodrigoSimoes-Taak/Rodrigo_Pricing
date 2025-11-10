public with sharing class GoalComparisons {
    public static Boolean isOrderApproved(Order order){
        return (order.StatusCode == 'Activated' || order.Status == 'Erro De Integração');
    }
    public static Boolean isGoalItemForHierarchy(GoalItem__c iGoalItem){
        return iGoalItem.ProductHierarchy__c != null;
    }
    public static Boolean isGoalItemForProduct(GoalItem__c iGoalItem){
        return iGoalItem.Product__c != null;
    }
    public static Boolean isGoalItemForPaymentCondition(GoalItem__c iGoalItem){
        return iGoalItem.PaymentCondition__c != null;
    }
    
}