trigger DevUserTrigger on DevUser__c (BEFORE insert, before update) {
    System.debug('DevUser Trigger => (' + Trigger.operationType + ')');
    DevUserTriggerHandler handler = new DevUserTriggerHandler(Trigger.old, Trigger.new,
        Trigger.oldMap, Trigger.newMap);
    if (DevUserTriggerHandler.isTriggerEnabled()){
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                handler.beforeInsert();
            }
            when BEFORE_UPDATE {
                handler.beforeUpdate();
            }
            

        }

    }

}