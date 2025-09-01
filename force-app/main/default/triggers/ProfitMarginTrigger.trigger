trigger ProfitMarginTrigger on ProfitMargin__c (before insert,before update) {
    System.debug('ProfitMargin Trigger => (' + Trigger.operationType + ')');
    ProfitMarginTriggerHandler handler = new ProfitMarginTriggerHandler(Trigger.old, Trigger.new,
        Trigger.oldMap, Trigger.newMap);
    if (ProfitMarginTriggerHandler.isTriggerEnabled()){
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