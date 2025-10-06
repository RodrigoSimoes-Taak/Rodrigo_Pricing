public with sharing class CalloutOrder {
	
	public static IntegrationUtils.CalloutResponse processIntegration(List<Id> orderId,String requestURL){

		Order parentOrder = [SELECT Id, ExternalId__c, AccountId,PaymentCondition__r.Code__c,EffectiveDate,ShippingType__c,DistributionCenter__r.Code__c,
        AccountAddress__r.Code__c,DeliveryDate__c,Status,OrderNumber,
         (SELECT Id,Product2.ExternalId__c,ExternalId__c,totvsItem__c,UnitPrice,ListPrice,Quantity,Order.ExternalId__c FROM OrderItems) FROM Order WHERE Id IN :orderId];

		//get relevant credentials
        AccessTokenCredential__c accessCredentials = [SELECT ClientId__c,Username__c,RequestURL__c,ClientSecret__c,Password__c,SecurityToken__c,
        AccessURL__c FROM AccessTokenCredential__c WHERE RequestURL__c =:requestURL LIMIT 1];
		List<Order> allOrders = new List<Order>{parentOrder};
		
		IntegrationUtils.CalloutResponse calloutResponse = sendOrder(allOrders,accessCredentials);

		if (calloutResponse.success) {
			
			ResponseParameters resp = (ResponseParameters) calloutResponse.parsedResponse;
			
			Map<String, Order> orderMap = new Map<String, Order>();
            String orderExternalIds = '';

            
           

			for (Order ord : allOrders) {
				orderMap.put(ord.OrderNumber, ord);
                orderExternalIds += orderExternalIds == '' ? ord.ExternalId__c : ', ' + ord.ExternalId__c;
			}
            String integrationLogId = IntegrationLog.createLog('Order',orderExternalIds,'Outbound',JSON.serialize(allOrders),JSON.serialize(calloutResponse),accessCredentials.RequestURL__c,false,false);
            System.debug('Integration log id: '+integrationLogId);
            if (integrationLogId != null) IntegrationLog.updateOrderWithIntegrationLogId(allOrders, integrationLogId, 'OUT');
			List<Order> orderList = new List<Order>();

			for (ResponseParametersWrapper respWrapper : resp.responses) {
				if (orderMap.containsKey(respWrapper.SalesforceCode)) {

					Order ord = orderMap.get(respWrapper.SalesforceCode);

					if (respWrapper.Error == 'TRUE') {
						//Error Treatments
                        System.debug('ERRO!');
					} else {
						//Success Treatments
                        System.debug('Sucesso!');
					}
					
					orderList.add(ord);
				}
			}

			if (!orderList.isEmpty()) {
				update orderList;
			}
		}
		
		return calloutResponse;
	}
    public static String getAccessToken(AccessTokenCredential__c accessCredentials){
        
        String username = accessCredentials.Username__c;
        String password = accessCredentials.Password__c + accessCredentials.SecurityToken__c;
        String clientId = accessCredentials.ClientId__c;
        String clientSecret = accessCredentials.ClientSecret__c;
        String accessUrl = accessCredentials.AccessURL__c;
        String accesstoken = (String)Cache.Org.get(username.substringBefore('@'));
        if (accesstoken != null){
            System.debug('Cache hit! Returning cache access token!');
            return accesstoken;
        }
        else{
            System.debug('Cache miss! Getting a new access token!');
            HttpRequest req = new HttpRequest();
            req.setEndpoint(accessUrl);
            req.setMethod('POST');
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setBody('grant_type=password' + '&client_id='+clientId + 
                '&client_secret='+clientSecret + '&username='+username + '&password='+password);
            Http http = new Http();
            HttpResponse response = http.send(req);
            accesstoken = ((Map<String,String>)JSON.deserialize(response.getBody(), Map<String,String>.class)).get('access_token');
            Cache.Org.put(username.substringBefore('@'), accesstoken, 7200);
            return accesstoken;
        }
    }
	public static IntegrationUtils.CalloutResponse sendOrder(List<Order> orders,AccessTokenCredential__c accessCredentials) {
			
		List<RequestParameters> request = new List<RequestParameters>();
		for (Order ord : orders) {
			request.add(new RequestParameters(ord));

		}
        Map<String,RequestParameters[]> requestMap = new Map<String,RequestParameters[]>();
        requestMap.put('request',request);
		String payload = JSON.serialize(requestMap);
        System.debug('Payload:\n'+payload); //need to set a name to the list inside the json!!
		//Metodo para busca de Access Token, depende de cada projeto, podendo estar presente dentro de uma custom settings ou relacionado com outra requisição.
		String accessToken = getAccessToken(accessCredentials);
		//Path geralmente cadastrado dentro de ua customSettings
		String endpoint = (Test.isRunningTest() ? 'callout:HANA_Oncoprod/PrePedido_SFOut' : accessCredentials.RequestURL__c);
		Map<String, String> headersMap = new Map<String, String>();
		headersMap.put('Content-type', 'application/json');
		headersMap.put('Authorization', 'Bearer '+ accessToken);
		
		IntegrationUtils.RequestResponseObject responseObject = IntegrationUtils.executeCallout(endpoint, payload, headersMap);
        HttpResponse response = responseObject.response;
		if (responseObject.success) {

			try {

				List<ResponseParametersWrapper> responses = (List<ResponseParametersWrapper>) JSON.deserialize(response.getBody(), List<ResponseParametersWrapper>.class);
				return new IntegrationUtils.CalloutResponse(new ResponseParameters(responses));
			} catch (Exception e) {
				
				String defaultErrorMessage = 'Malformatted HTTP Response Exception: ' + e.getMessage();

				return new IntegrationUtils.CalloutResponse(defaultErrorMessage);
			}
		} else {
			
			return new IntegrationUtils.CalloutResponse(responseObject.exceptionObject.getMessage());
		}
	}
	public class RequestParameters {
		public String accountCode;
        public String addressCode; 
        public String paymentCode; 
        public Date effectiveDate;
        public String freightType; 
        public String distributionCenterCode; 
        public String orderCode;
        public Date deliveryDate;
        public String status;
        public String obs;
		public OrderItemParameters[] orderItems;

		public RequestParameters(Order ord) {
			this.orderCode = ord.ExternalId__c;
            this.accountCode = ord.AccountId;
            this.paymentCode = ord.PaymentCondition__r.Code__c;
            this.effectiveDate = ord.EffectiveDate;
            this.freightType = ord.ShippingType__c;			
            this.distributionCenterCode = ord.DistributionCenter__r.Code__c;
            this.addressCode = ord.AccountAddress__r.Code__c;
            this.deliveryDate = ord.DeliveryDate__c;
            this.status = ord.Status;
			this.orderItems = new List<OrderItemParameters>();
            this.obs = 'Callout!';

			for (OrderItem ordIt : Ord.OrderItems) {
				orderItems.add(new OrderItemParameters(ordIt));
			}
		}
	}

	public class OrderItemParameters {
		public String productCode;
        public String itemCode;
        public Boolean totvsItem;
        public Decimal unitPrice;
        public Decimal listPrice;
        public Decimal quantity;
		public String orderExternalId;
		

		public OrderItemParameters(OrderItem ordIt) {
			this.productCode = ordIt.Product2.ExternalId__c;
            this.itemCode = ordIt.ExternalId__c;
            this.totvsItem = ordIt.totvsItem__c;
            this.unitPrice = 12;//ordIt.UnitPrice;
            this.listPrice = ordIt.ListPrice;
            this.quantity = ordIt.Quantity;
            this.orderExternalId = ordIt.Order.ExternalId__c;
		}
	}

	public class ResponseParameters {
		public List<ResponseParametersWrapper> responses;

		public ResponseParameters(List<ResponseParametersWrapper> responses) {
			this.responses = responses;
		}
	}

	public class ResponseParametersWrapper {
		public String Status;
		public String Error;
		public String SalesforceCode;
		public String ERPCode;
	}
    
}