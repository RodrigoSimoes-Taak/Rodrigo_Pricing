public with sharing class ShippingTriggerHandler {
    private static Boolean isEnabled;
	static {
		isEnabled = true;
	}
	public static Boolean isTriggerEnabled() {
		return isEnabled;
	}
	public static Boolean disableTrigger() {
		return isEnabled = false;
	}
	public static Boolean enableTrigger() {
		return isEnabled = true;
	}
	List<Shipping__c> oldRecordList { get; set; }
	List<Shipping__c> newRecordList { get; set; }
	Map<Id, Shipping__c> oldRecordMap { get; set; }
	Map<Id, Shipping__c> newRecordMap { get; set; }
	public ShippingTriggerHandler(
		List<Shipping__c> oldRecordList,
		List<Shipping__c> newRecordList,
		Map<Id, Shipping__c> oldRecordMap,
		Map<Id, Shipping__c> newRecordMap
	) {
		this.oldRecordList = oldRecordList;
		this.newRecordList = newRecordList;
		this.oldRecordMap = oldRecordMap;
		this.newRecordMap = newRecordMap;
	}
	public void beforeInsert() {
		ShippingTriggerHelper.handleInsertShipping(this.newRecordList);
	}
	public void beforeUpdate() {
        ShippingTriggerHelper.handleUpdateShipping(this.newRecordMap,this.oldRecordMap);
	}
}