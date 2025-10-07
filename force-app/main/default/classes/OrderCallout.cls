public with sharing class OrderCallout {

    public static void calloutViaOrderId(List<Id> orderIdList){
        List<Order> relatedOrderList = [SELECT Id,Account.ExternalId__c,AccountAddress__r.Code__c,PaymentCondition__r.Code__c,EffectiveDate,ShippingType__c,
        DistributionCenter__r.Code__c,ExternalId__c,DeliveryDate__c,Status,IntegrationLogOutbound__c,
        (SELECT Id,Product2.ExternalId__c,totvsItem__c,ExternalId__c,UnitPrice,ListPrice,Quantity FROM OrderItems) 
        FROM Order 
        WHERE Id IN :orderIdList];
        Map<String,List<OrderIN>> requestMap = new Map<String,List<OrderIN>>();
        requestMap.put('request', new List<OrderIN>());
        for (Order iOrder:relatedOrderList){
            requestMap.get('request').add(new OrderIN(iOrder));
        }
        System.debug(JSON.serialize(requestMap));
        





        String requestURL = 'callout:SelfOrgNamedCred/services/apexrest/orderInbound';
        HttpRequest request = new HttpRequest();
        request.setBody(JSON.serialize(requestMap));
        request.setEndpoint(requestURL);
        request.setMethod('POST');
        String responseBody;
        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() == 200){
            responseBody = response.getBody();
            System.debug(responseBody);
        }
        else{
            System.debug('Error! '+response.getStatusCode());
        }
        Map<String,List<DataIntegration.Response>> inboundResponse = (Map<String,List<DataIntegration.Response>>)JSON.deserialize(responseBody, 
            Map<String,List<DataIntegration.Response>>.class);
        String externalIds = '';
        Boolean hasAnyError = false;
        for (List<DataIntegration.Response> iResponseList:inboundResponse.values()){
            for (DataIntegration.Response iResponse:iResponseList){
                if (iResponse.hasError == true && !hasAnyError){
                    hasAnyError = true; 
                }
                externalIds+=iResponse.externalCode+',';
            }
            
        }
        
        String logId = IntegrationLog.createLog('Order', externalIds, 'Outbound', JSON.serialize(requestMap), JSON.serialize(inboundResponse) , requestURL, hasAnyError, false);//hasDeleted doesnt make much sense here
        for (Order iOrder : relatedOrderList){
            iOrder.IntegrationLogOutbound__c = logId;
        }
        update relatedOrderList;
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
            this.orderCode = orderToConvert.ExternalId__c;
            this.deliveryDate = orderToConvert.DeliveryDate__c;
            this.status = orderToConvert.Status;
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
            this.itemCode = orderItemToConvert.ExternalId__c;
            this.totvsItem = orderItemToConvert.totvsItem__c;
            this.unitPrice = orderItemToConvert.UnitPrice;
            this.listPrice = orderItemToConvert.ListPrice;
            this.quantity = orderItemToConvert.Quantity;

        }
    }
    
}