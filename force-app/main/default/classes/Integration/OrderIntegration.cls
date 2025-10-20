@RestResource(urlMapping='/orderInbound')
global with sharing class OrderIntegration {
    
    public class OrderRequest {
        public List<OrderIN> request;
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
        public List<OrderItemIN> orderItems;
    }
    public class OrderItemIN{
        public String productCode;
        public String itemCode;
        public Boolean totvsItem;
        public Decimal unitPrice;
        public Decimal listPrice;
        public Decimal quantity;
    }
    public static List<Order> convertOrder(List<OrderIN> ordersToIntegrate,Map<String,List<DataIntegration.Response>> responseMap){
        List<Order> newOrders = new List<Order>();
        for (OrderIN iOrderIN:ordersToIntegrate){ 
            Boolean hasNulls = false;
            
                newOrders.add(new Order(
                    PaymentCondition__r=new PaymentCondition__c(Code__c=iOrderIN.paymentCode),
                    DistributionCenter__r= new DistributionCenter__c(Code__c=iOrderIN.distributionCenterCode), 
                    AccountAddress__r=new AccountAddress__c(Code__c=iOrderIN.addressCode),
                    EffectiveDate=iOrderIN.effectiveDate,
                    DeliveryDate__c=iOrderIN.deliveryDate,
                    ExternalId__c=iOrderIN.orderCode,
                    Account=new Account(ExternalId__c=iOrderIN.accountCode),
                    ShippingType__c=iOrderIN.freightType, 
                    Status='Novo',
                    Observations__c=iOrderIN.obs));
            
        }
        return newOrders;
    }
    public static List<OrderItem> convertOrderItem(List<OrderIN> ordersToIntegrate,List<Order> newOrders,List<Database.UpsertResult> orderUpsertResults, 
    Map<String,List<DataIntegration.Response>> responseMap){

        List<OrderItem> newOrderItems = new List<OrderItem>();
        for (Integer i = 0; i < newOrders.size();++i){
            if (orderUpsertResults[i].isSuccess()){
                for (OrderItemIN iOrderItem:ordersToIntegrate[i].orderItems){
                    newOrderItems.add(new OrderItem(ExternalId__c=iOrderItem.itemCode, Product2=new Product2(ExternalId__c=iOrderItem.productCode), 
                        OrderId=newOrders[i].Id, Quantity=iOrderItem.quantity, UnitPrice=iOrderItem.unitPrice,ListPrice=iOrderItem.listPrice,
                        totvsItem__c=iOrderItem.totvsItem));
                    
                    
                }
            }
            
        }
        return newOrderItems;
    }
    @HttpPost
	global static Map<String,List<DataIntegration.Response>> orderInbound(){
        String endpoint = System.Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/orderInbound';
        Map<String,List<DataIntegration.Response>> responseMap = new Map<String,List<DataIntegration.Response>>();
        responseMap.put('Order',new List<DataIntegration.Response>());
        responseMap.put('OrderItem',new List<DataIntegration.Response>());
        List<OrderIN> ordersToIntegrate = new List<OrderIN>();
        try{
            
		    ordersToIntegrate = ((OrderRequest)JSON.deserialize(RestContext.request.requestBody.toString(),OrderRequest.class)).request;
        }
        catch(Exception e){
            String[] lines = RestContext.request.requestBody.toString().split('\n');
            Pattern getLine = Pattern.compile('line:(\\d+)');
            Matcher match = getLine.matcher(e.getMessage());
            if (match.find()){
                System.debug('Teste '+match.group(1));
                System.debug('Teste2 '+lines[Integer.valueOf(match.group(1))-1]);
            }
            String errorMessage = 'Error! Line ' +lines[Integer.valueOf(match.group(1))-1]+' Should be a string!';
            System.debug('Error on OrderIntegration: '+e.getStackTraceString()+e.getMessage()+':\n   '+RestContext.request.requestBody.toString());
            responseMap.get('Order').add(new DataIntegration.Response('','',errorMessage,'Order'));
            IntegrationLog.createLog('Order', '', 'Inbound', RestContext.request.requestBody.toString(), errorMessage, endpoint, true, false);
            RestContext.response.statusCode = 400;
            return responseMap;

        }
        //code to relate Codes with IDs using SOQL
        String externalIdList = '';
        for (OrderIN iOrder:ordersToIntegrate){
            externalIdList += iOrder.orderCode + ',';
        }
        Boolean hasAnyErrors = false;
       
        
        try{
            List<Order> newOrders = convertOrder(ordersToIntegrate,responseMap);
            if (newOrders.isEmpty()){
                IntegrationLog.createLog('Order', externalIdList, 'Inbound',  JSON.serialize(ordersToIntegrate),JSON.serialize(responseMap), endpoint, true, false);
                return responseMap;
            }
            
            
            List<Database.UpsertResult> orderUpsertResults = Database.upsert(newOrders,Order.ExternalId__c,false);
            Set<String> successfulOrderUpsertExternalIds = new Set<String>();
            for (Integer i = 0; i < orderUpsertResults.size(); i++){
                String errorMessage = '';
                if (!orderUpsertResults[i].isSuccess()){
                    if (!hasAnyErrors){
                        hasAnyErrors = true;
                    }
                    
                    for (Database.Error iError: orderUpsertResults[i].getErrors()){
                        errorMessage += iError.getStatusCode()+ ' - '+ iError.getMessage();
                    }
                }
                else{
                    successfulOrderUpsertExternalIds.add(newOrders[i].ExternalId__c);
                }
                responseMap.get('Order').add(new DataIntegration.Response(orderUpsertResults[i].getId(),newOrders[i].ExternalId__c,errorMessage,'Order'));
                
            }
            
            
            List<OrderItem> orderItemsToDelete = [SELECT Id FROM OrderItem WHERE Order.ExternalId__c IN :successfulOrderUpsertExternalIds];
            delete orderItemsToDelete; //deletes all OrderItems related to successful Order inserts
            
            List<OrderItem> newOrderItems = convertOrderItem(ordersToIntegrate,newOrders,orderUpsertResults,responseMap);
            
            for (Integer i = 0; i < newOrderItems.size();++i){
                externalIdList += newOrderItems[i].ExternalId__c + ',';
                
            }
            

            List<Database.UpsertResult> orderItemsUpsertResults = Database.upsert(newOrderItems,false);
            for (Integer i = 0;i < orderItemsUpsertResults.size();++i){ 
                String errorMessage = '';
                if (!orderItemsUpsertResults[i].isSuccess()){
                    
                    if (!hasAnyErrors){
                        hasAnyErrors = true;
                    }
                    
                    for (Database.Error iError: orderItemsUpsertResults[i].getErrors()){
                        errorMessage += iError.getStatusCode()+ ' - '+ iError.getMessage();
                    }
                    
                }
                responseMap.get('OrderItem').add(new DataIntegration.Response(orderItemsUpsertResults[i].getId(),newOrderItems[i].ExternalId__c,errorMessage,'OrderItem'));
            }
            
            
            
            String logId = IntegrationLog.createLog('Order', externalIdList, 'Inbound', JSON.serialize(ordersToIntegrate),JSON.serialize(responseMap),  endpoint, hasAnyErrors, false);
            List<Order> ordersToUpdate = new List<Order>();
            List<Order> ordersToDelete = new List<Order>();
            Map<String,Order> integratedOrders  = new Map<String,Order>();
            for (Order iOrder:[SELECT ExternalId__c, (SELECT Id FROM OrderItems) FROM Order WHERE ExternalId__c IN:successfulOrderUpsertExternalIds]){
                integratedOrders.put(iOrder.ExternalId__c,iOrder);
            }

            for (String iOrderExternalId: successfulOrderUpsertExternalIds){
                if (integratedOrders.get(iOrderExternalId).OrderItems.isEmpty()){
                    ordersToDelete.add(new Order(Id = integratedOrders.get(iOrderExternalId).Id));
                }
                else{
                    ordersToUpdate.add(new Order(ExternalId__c = iOrderExternalId,IntegrationLogInbound__c = logId));
                }
                
                
            }
            if (!ordersToUpdate.isEmpty()){
                Database.upsert(ordersToUpdate,Order.ExternalId__c,false);
                
            }
            if (!ordersToDelete.isEmpty()){
                delete ordersToDelete;
            }
            
           
            
        }
        catch(Exception e){
            System.debug('Error on OrderIntegration: '+e.getMessage());
            IntegrationLog.createLog('Order', externalIdList, 'Inbound', JSON.serialize(ordersToIntegrate), JSON.serialize(responseMap), endpoint, true, false);
            
        }
        
        

		return responseMap;
	}
}
    
