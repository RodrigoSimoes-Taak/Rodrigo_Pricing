trigger OrderTrigger on Order (before update,after update) {
    System.debug('Order Trigger => (' + Trigger.operationType + ')');
    OrderTriggerHandler handler = new OrderTriggerHandler(Trigger.old, Trigger.new,
        Trigger.oldMap, Trigger.newMap);
    if (ProfitMarginTriggerHandler.isTriggerEnabled()){
        switch on Trigger.operationType {
            
            when BEFORE_UPDATE {
                handler.beforeUpdate();
            }
            when AFTER_UPDATE{
                handler.afterUpdate();
            }
            
            

        }

    }
}