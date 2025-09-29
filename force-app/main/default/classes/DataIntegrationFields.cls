global with sharing class DataIntegrationFields {

	public interface FieldData {
		List<String> getRequiredFields();
		String getFieldKey();
		String getFieldId();
		String getExternalId();
		SObject deserialize();
	}

	public interface FieldDataChild {
		List<String> getRequiredFields();
		String getFieldId();
		String getFieldExternal();
		String getParentId();
		String getParentKey();
		SObject deserialize();
	}

	global class OrderINData implements FieldData { // extends OrderBase
		public String clienteCode;
        public String addressCode; //AccountAddress
        public String conditionCode; //payment condition
        public Date effectiveDate;
        public String freightType; 
        public String distributionCenter; 
        public String orderNumber;
        public Date deliveryDate;
        public Date deliveryDateERP;
        public String status;
        public String obs;
        public Integer priority;

		public List<OrderItemINData> orderItems {get; set;}

		public Order deserialize() {
			return new Order(
				ExternalId__c			= this.orderNumber,//OrderNumber
				EffectiveDate			= this.effectiveDate,
				Account					= new Account(ExternalId__c = this.clienteCode),//clientecode
				PaymentCondition__c 	= [SELECT Id FROM PaymentCondition__c WHERE Code__c = :this.conditionCode LIMIT 1].Id,
				DistributionCenter__c	= [SELECT Id FROM DistributionCenter__c WHERE Code__c = :this.distributionCenter LIMIT 1].Id,
				AccountAddress__c 		= [SELECT Id FROM AccountAddress__c WHERE Code__c = :this.addressCode LIMIT 1].Id,
				ShippingType__c 		= this.freightType,
				DeliveryDate__c 		= this.deliveryDate,
				Status 					='Draft'

			);
		}

		public List<String> getRequiredFields() {
			return new List<String>{
				'ExternalId__c',
				'EffectiveDate',
				'Status'
			};
		}
		public List<String> getRequiredLookups() {
			return new List<String>{
				
			};
		}

		public String getFieldKey() {
			return 'ExternalId__c';
		}
		public String getFieldId() {
			return 'Id';
		}
		public String getExternalId() {
			return this.orderNumber;
		}
	}
	global class OrderItemINData implements FieldDataChild { // extends OrderItemBase
		public String id;
		public String productCode;
        public String orderitemCode;
        public Boolean totvsItem;
        public Date deliveryDate;
        public Decimal unitPrice;//manual price
        public Decimal motorPrice;//CostPrice, check if it matches the pricebook value?
        public Integer quantity;
		public String orderExternalId;
        public String status;//??

		public OrderItem deserialize() {
			OrderItem orderItem = new OrderItem(
				ExternalId__c	= this.orderItemCode,
				Quantity		= this.quantity,
				UnitPrice		= this.unitPrice,
				ListPrice		= this.motorPrice,
				totvsItem__c	= this.totvsItem
			);

			if (this.id == null || this.id == '') {
				orderItem.Order 	=  new Order(ExternalId__c = this.orderExternalId);
				orderItem.Product2			= new Product2(ExternalId__c = this.productCode);
			}
			else orderItem.Id = this.id;

			return orderItem;
		}

		public List<String> getRequiredFields() {
			return new List<String>{
				'UnitPrice',
				'Quantity',
				'ExternalId__c'
			};
		}
		public List<String> getRequiredLookups() {
			return new List<String>{
				
			};
		}

		public String getFieldId() {
			return 'Id';
		}
		public String getFieldExternal() {
			return 'ExternalId__c';
		}
		public String getParentId() {
			return 'OrderId';
		}
		public String getParentKey() {
			return this.orderExternalId;
		}
	}

	global virtual class Response {
		public String salesforceId;
		public String externalId;
		public String sobjectType;
		public Boolean hasError;
		public String errorMessage;

		public void success(String salesforceId, String externalId, String sobjectType){
			this.salesforceId	= salesforceId;
			this.externalId		= externalId;
			this.sobjectType	= sobjectType;
			this.hasError		= false;
		}

		public void error(String externalId, String errorMessage, String sobjectType){
			this.externalId		= externalId;
			this.sobjectType	= sobjectType;
			this.hasError		= true;
			this.errorMessage	= errorMessage;
		}

		public void error(String salesforceId, String externalId, String errorMessage, String sobjectType){
			this.salesforceId	= salesforceId;
			this.externalId		= externalId;
			this.sobjectType	= sobjectType;
			this.hasError		= true;
			this.errorMessage	= errorMessage;
		}
	}
	global class ResponseParent extends Response {
		public List<DataIntegrationFields.Response> items;
	}
}
