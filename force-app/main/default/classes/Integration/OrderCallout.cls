public with sharing class OrderCallout {
    
    public static void calloutViaOrderIdList(List<Id> orderIdList){
        List<Order> relatedOrderList = [SELECT Id,Account.ExternalId__c,AccountAddress__r.Code__c,PaymentCondition__r.Code__c,EffectiveDate,ShippingType__c,
        DistributionCenter__r.Code__c,OrderNumber,DeliveryDate__c,Status,IntegrationLogOutbound__c,
        (SELECT Id,Product2.ExternalId__c,totvsItem__c,ExternalId__c,UnitPrice,ListPrice,Quantity,OrderItemNumber FROM OrderItems WHERE DeletedProduct__c = false) 
        FROM Order 
        WHERE Id IN :orderIdList];
        Map<String,List<OrderIN>> requestMap = new Map<String,List<OrderIN>>();
        Set<String> relatedOrderExternalIds = new Set<String>();

        requestMap.put('request', new List<OrderIN>());
        
        for (Order iOrder:relatedOrderList){
            requestMap.get('request').add(new OrderIN(iOrder));
        }

        System.debug(JSON.serialize(requestMap));

        String requestURL = 'callout:OrgLucas/services/apexrest/orders';
        HttpResponse response = IntegrationUtils.sendRequest(requestMap,requestURL);
        
        IntegrationLog calloutLog = new IntegrationLog()
            .setEndpoint(requestURL)
            .setPayloadOUT(JSON.serialize(requestMap))
            .setIntegrationName('Order')
            .setRecordTypeName('Outbound');
        
        String responseBody = response.getBody();
        Boolean hasAnyError = false;
        String externalIdsFromResponse = '';

        if (IntegrationUtils.isResponseOk(response)){
            
            System.debug(responseBody);
            try{
                Map<String,List<DataIntegration.Response>> inboundResponse = (Map<String,List<DataIntegration.Response>>)JSON.deserialize(responseBody, 
                Map<String,List<DataIntegration.Response>>.class);
                
                for (List<DataIntegration.Response> iResponseList:inboundResponse.values()){
                    for (DataIntegration.Response iResponse:iResponseList){
                        if (iResponse.hasError == true && !hasAnyError){
                            hasAnyError = true; 
                        }

                        externalIdsFromResponse+=iResponse.externalCode+',';
                    }
                }
                calloutLog.setExternalIdList(externalIdsFromResponse)
                    .setPayloadIN(JSON.serialize(inboundResponse))
                    .setHasAnyErrors(hasAnyError)
                    .setHasDeleted(false);

                
            }

            catch(Exception e){

                System.debug('Callout Response - Could not parse response as map, parsing as list');

                for (DataIntegration.Response iResponse : (List<DataIntegration.Response>) JSON.deserialize(responseBody, List<DataIntegration.Response>.class)){
                    if (iResponse.hasError == true && !hasAnyError){
                        hasAnyError = true; 
                    }

                    externalIdsFromResponse+=iResponse.externalCode+',';
                }
                calloutLog.setExternalIdList(externalIdsFromResponse)
                    .setPayloadIN(responseBody)
                    .setHasAnyErrors(hasAnyError)
                    .setHasDeleted(false);
            }
                
            
        }
        else{//means an error happened in the response, which will likely return no useful log, so everything related should be considered to have error'd

            System.debug('Error! '+response.getStatusCode()+'response: '+responseBody);
            
            hasAnyError = true;
            calloutLog.setExternalIdList(externalIdsFromResponse)
                .setPayloadIN('Error '+response.getStatusCode()+' '+responseBody)
                .setHasAnyErrors(hasAnyError)
                .setHasDeleted(false);
            System.debug('Teste3');
        }
        String logId = calloutLog.build();
        for (Order iOrder : relatedOrderList){
            iOrder.IntegrationLogOutbound__c = logId;

            if (hasAnyError) iOrder.Status = 'Erro De Integração';

            else iOrder.Status = 'Integrado';
        }

        update relatedOrderList;
       
        
    }
    @InvocableMethod
    public static void invokeCalloutIntegration(List<Id> orderIdList){
        System.debug('Order Send to callout button OrderList: '+orderIdList);
        OrderTriggerHelper.calloutToExternalSystem(orderIdList);
    }
    public class OrderIN{
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
        public List<OrderItemIN> orderItems = new List<OrderItemIN>();
        public OrderIN(Order orderToConvert){
            this.accountCode = orderToConvert.Account.ExternalId__c;
            this.addressCode = orderToConvert.AccountAddress__r.Code__c;
            this.paymentCode = orderToConvert.PaymentCondition__r.Code__c;
            this.effectiveDate = orderToConvert.EffectiveDate;
            this.freightType = orderToConvert.ShippingType__c;
            this.distributionCenterCode = orderToConvert.DistributionCenter__r.Code__c;
            this.orderCode = orderToConvert.OrderNumber;
            this.deliveryDate = orderToConvert.DeliveryDate__c;
            this.status = 'Draft'; //mudar depois!
            this.obs = 'Callout!';
            for (OrderItem iOrderItem:orderToConvert.OrderItems){
                this.orderItems.add(new OrderItemIN(iOrderItem));
            }
        }
    }
    public class OrderItemIN{
        public String productCode;
        public String itemCode;
        public Boolean totvsItem;
        public Decimal unitPrice;
        public Decimal listPrice;
        public Decimal quantity;
        public OrderItemIN(OrderItem orderItemToConvert){
            this.productCode = orderItemToConvert.Product2.ExternalId__c;
            this.itemCode = orderItemToConvert.orderItemNumber;
            this.totvsItem = orderItemToConvert.totvsItem__c;
            this.unitPrice = orderItemToConvert.UnitPrice;
            this.listPrice = orderItemToConvert.ListPrice;
            this.quantity = orderItemToConvert.Quantity;

        }
    }
    
}