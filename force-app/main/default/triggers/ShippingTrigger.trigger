trigger ShippingTrigger on Shipping__c (before insert,before update, after update) {
    System.debug('Shipping Trigger => (' + Trigger.operationType + ')');
    ShippingTriggerHandler handler = new ShippingTriggerHandler(Trigger.old, Trigger.new,
        Trigger.oldMap, Trigger.newMap);
    if (ShippingTriggerHandler.isTriggerEnabled()){
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                handler.beforeInsert();
            }
            when BEFORE_UPDATE {
                handler.beforeUpdate();
            }
            when AFTER_UPDATE {
                handler.afterUpdate();
            }
            

        }

    }
}