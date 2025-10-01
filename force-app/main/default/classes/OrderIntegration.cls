@RestResource(urlMapping='/orderItem')
global with sharing class OrderIntegration {
    
    
    public class OrderResponse{
        public OrderResponseContent[] response = new OrderResponseContent[]{};
        public OrderResponse(Order[] newOrders){
            for (Order iOrder:newOrders){
                response.add(new OrderResponseContent(iOrder));
            }
        }
    }
    public class OrderResponseContent{
        public String salesforceId;
        public String externalCode;
        public Boolean status;
        public String errorMessage;
        public String sObjectType;
        public OrderResponseContent(Order newOrder){
            salesforceId = newOrder.Id;
            externalCode = newOrder.ExternalId__c;
            status = false;
            errorMessage = '';
            sObjectType = 'Order';
        }
    }
    
    public class OrderRequest {
        public OrderIN[] request;
    }
    public class OrderIN{
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
        public OrderItemIN[] orderItems;
    }
    public class OrderItemIN{
        public String productCode;
        public String orderitemCode;
        public Boolean totvsItem;
        public Date deliveryDate;
        public Decimal unitPrice;//manual price
        public Decimal motorPrice;//CostPrice, check if it matches the pricebook value?
        public Decimal quantity;
        public String status;//??
    }
    public static Order[] convertOrder(OrderIN[] ordersToIntegrate,Map<String,Id> relatedAccountsMap){
        Order[] newOrders = new Order[]{};
        //relate OrderIN fields with Order fields!
        Contract[] relatedContractsQueryResult = [SELECT Id,AccountId FROM Contract WHERE AccountId IN :relatedAccountsMap.values()];
        Map<Id,Id> relatedContractsMap = new Map<Id,Id>();
        for (Contract iContract: relatedContractsQueryResult){
            relatedContractsMap.put(iContract.AccountId,iContract.Id);
        }
        for (OrderIN iOrderIN:ordersToIntegrate){ //TODO: add the rest of the fields!
            newOrders.add(new Order(PaymentCondition__c=iOrderIN.conditionCode, ContractId=relatedContractsMap.get(iOrderIN.clienteCode),
            DistributionCenter__c= iOrderIN.distributionCenter, AccountAddress__c=iOrderIN.addressCode, 
            EffectiveDate=iOrderIN.effectiveDate, DeliveryDate__c=iOrderIN.deliveryDate, ExternalId__c=iOrderIN.orderNumber, 
            AccountId=iOrderIN.clienteCode, ShippingType__c=iOrderIN.freightType, Status='Draft'));
        }
        return newOrders;
    }
    public static OrderItem[] convertOrderItem(OrderIN[] ordersToIntegrate,Order[] newOrders){
        OrderItem[] newOrderItems = new OrderItem[]{};
        for (Integer i = 0; i < newOrders.size();++i){
            for (OrderItemIN iOrderItem:ordersToIntegrate[i].orderItems){
                
                newOrderItems.add(new OrderItem(ExternalId__c=iOrderItem.orderItemCode, Product2Id=iOrderItem.productCode, 
                OrderId=newOrders[i].Id, Quantity=iOrderItem.quantity, UnitPrice=iOrderItem.unitPrice,ListPrice=iOrderItem.motorPrice,
                totvsItem__c=iOrderItem.totvsItem));
            }
        }
        return newOrderItems;
    }
    @HttpPost
	global static String returnTest(){
		OrderIN[] ordersToIntegrate = ((OrderRequest)JSON.deserialize(RestContext.request.requestBody.toString(),OrderRequest.class)).request;
		
        //code to relate Codes with IDs using SOQL
        Set<String> relatedAddresses = new Set<String>();
        Set<String> relatedPayments = new Set<String>();
        Set<String> relatedOrderItemIds = new Set<String>();
        Set<String> relatedDistributionCenters = new Set<String>();
        Set<String> relatedProducts = new Set<String>();
        Set<String> relatedAccounts = new Set<String>();
        for (OrderIN iOrder:ordersToIntegrate){
            for (OrderItemIN iOrderItem:iOrder.orderItems){
                relatedProducts.add(iOrderItem.productCode);
                relatedOrderItemIds.add(iOrderItem.orderitemCode);
            }
            relatedAddresses.add(iOrder.addressCode);
            relatedPayments.add(iOrder.conditionCode);
            relatedDistributionCenters.add(iOrder.distributionCenter);
            relatedAccounts.add(iOrder.clienteCode);
            
        }
        
        AccountAddress__c[] relatedAddressesQueryResult = [SELECT Id,Code__c FROM AccountAddress__c WHERE Code__c IN :relatedAddresses];
        Map<String,Id> relatedAddressesMap = new Map<String,Id>();
        for (AccountAddress__c iAddress:relatedAddressesQueryResult){
            relatedAddressesMap.put(iAddress.Code__c,iAddress.Id);
        }
        PaymentCondition__c[] relatedPaymentsQueryResult = [SELECT Id, Code__c FROM PaymentCondition__c WHERE Code__c IN :relatedPayments];
        Map<String,Id> relatedPaymentsMap = new Map<String,Id>();
        for (PaymentCondition__c iPaymentCondition:relatedPaymentsQueryResult){
            relatedPaymentsMap.put(iPaymentCondition.Code__c,iPaymentCondition.Id);
        }
        DistributionCenter__c[] relatedDistributionCentersQueryResult = [SELECT Id, Code__c FROM DistributionCenter__c WHERE Code__c IN :relatedDistributionCenters];
        Map<String,Id> relatedDistributionCentersMap = new Map<String,Id>();
        for (DistributionCenter__c iDistributionCenter:relatedDistributionCentersQueryResult){
            relatedDistributionCentersMap.put(iDistributionCenter.Code__c,iDistributionCenter.Id);
        }
        Product2[] relatedProductsQueryResult = [SELECT Id, ExternalId__c FROM Product2 WHERE ExternalId__c IN :relatedProducts];
        Map<String,Id> relatedProductsMap = new Map<String,Id>();
        for (Product2 iProduct:relatedProductsQueryResult){
            relatedProductsMap.put(iProduct.ExternalId__c,iProduct.Id);
        }
        Account[] relatedAccountsQueryResult = [SELECT Id, ExternalId__c FROM Account WHERE ExternalId__c IN:relatedAccounts];
        Map<String,Id> relatedAccountsMap = new Map<String,Id>();
        for (Account iAccount:relatedAccountsQueryResult){
            relatedAccountsMap.put(iAccount.ExternalId__c,iAccount.Id);
        }



        for (OrderIN iOrder:ordersToIntegrate){
            for (OrderItemIN iOrderItem:iOrder.orderItems){
                iOrderItem.productCode = relatedProductsMap.get(iOrderItem.productCode);
            }
            iOrder.addressCode = relatedAddressesMap.get(iOrder.addressCode);
            iOrder.conditionCode = relatedPaymentsMap.get(iOrder.conditionCode);
            iOrder.distributionCenter = relatedDistributionCentersMap.get(iOrder.distributionCenter);
            iOrder.clienteCode = relatedAccountsMap.get(iOrder.clienteCode);
        }
        IntegrationLog__c log = new IntegrationLog__c(Name='LogSemTemplate');
        Order[] newOrders = convertOrder(ordersToIntegrate,relatedAccountsMap);
        try{
            Database.upsert(newOrders,Order.externalId__c);
            OrderItem[] orderItemsToDelete = [SELECT Id FROM OrderItem WHERE ExternalId__c IN :relatedOrderItemIds];
            delete orderItemsToDelete;
            //all remaining OrderItems related to the Orders should have DeletedProduct = true
            String[] relatedOrderIds = new String[]{};
            for (OrderIN iOrder:ordersToIntegrate){
                relatedOrderIds.add(iOrder.orderNumber);
            }
            OrderItem[] newOrderItems = convertOrderItem(ordersToIntegrate,newOrders);
            for (OrderItem iOrderItem:[SELECT Id,DeletedProduct__c FROM OrderItem WHERE Order.ExternalId__c IN :relatedOrderIds]){
                iOrderItem.DeletedProduct__c = true;
                newOrderItems.add(iOrderItem);
            }
            upsert newOrderItems;
            log.ErrorMessage__c = '';
            log.Status__c = 'Success';
            log.ExecutionDate__c = Datetime.now();
            insert log;
        }
        catch(Exception e){
            log.ErrorMessage__c = e.getMessage();
            log.Status__c = 'Error';
            log.ExecutionDate__c = Datetime.now();
            insert log;
        }
        
        

		
		return JSON.serialize(new OrderResponse(newOrders));
	}
}
    
