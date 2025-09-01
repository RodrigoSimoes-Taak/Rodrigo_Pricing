public with sharing class ProfitMarginTriggerHandler {
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
	List<ProfitMargin__c> oldRecordList { get; set; }
	List<ProfitMargin__c> newRecordList { get; set; }
	Map<Id, ProfitMargin__c> oldRecordMap { get; set; }
	Map<Id, ProfitMargin__c> newRecordMap { get; set; }
	public ProfitMarginTriggerHandler(
		List<ProfitMargin__c> oldRecordList,
		List<ProfitMargin__c> newRecordList,
		Map<Id, ProfitMargin__c> oldRecordMap,
		Map<Id, ProfitMargin__c> newRecordMap
	) {
		this.oldRecordList = oldRecordList;
		this.newRecordList = newRecordList;
		this.oldRecordMap = oldRecordMap;
		this.newRecordMap = newRecordMap;
	}
	public void beforeInsert() {
		ProfitMarginTriggerHelper.handleInsertProfitMargin(this.newRecordList);
	}
	public void beforeUpdate() {
        ProfitMarginTriggerHelper.handleInsertProfitMargin(this.newRecordList);
	}
}