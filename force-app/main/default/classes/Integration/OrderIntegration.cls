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
    public static List<Order> convertOrder(List<OrderIN> ordersToIntegrate,Map<String,Id> relatedAccountsMap,Map<String,List<DataIntegration.Response>> responseMap){
        List<Order> newOrders = new List<Order>();
        List<Contract> relatedContractsQueryResult = [SELECT Id,AccountId FROM Contract WHERE AccountId IN :relatedAccountsMap.values()];
        Map<Id,Id> relatedContractsMap = new Map<Id,Id>();
        for (Contract iContract: relatedContractsQueryResult){
            relatedContractsMap.put(iContract.AccountId,iContract.Id);
        }
        for (OrderIN iOrderIN:ordersToIntegrate){ 
            String errorMessage = 'The following fields have errors: ';
            Boolean hasNulls = false;
            if(iOrderIN.paymentCode == null){
                if (!hasNulls){
                    hasNulls = true;
                }
                
                errorMessage += 'PaymentCode ';
            } 
            if(iOrderIN.distributionCenterCode == null){
                if (!hasNulls){
                    hasNulls = true;
                }
                errorMessage += 'DistributionCenterCode ';
            } 
            if (iOrderIN.addressCode == null){
                if (!hasNulls){
                    hasNulls = true;
                }
                errorMessage += 'AddressCode ';
            }
            if(iOrderIN.accountCode == null){
                if (!hasNulls){
                    hasNulls = true;
                }
                errorMessage += 'AccountCode ';
            }
            if (hasNulls){
                responseMap.get('Order').add(new DataIntegration.Response(null,iOrderIN.orderCode,errorMessage,'Order'));
            }
            else{
                newOrders.add(new Order(PaymentCondition__c=iOrderIN.paymentCode, ContractId=relatedContractsMap.get(iOrderIN.accountCode),
                DistributionCenter__c= iOrderIN.distributionCenterCode, AccountAddress__c=iOrderIN.addressCode, 
                EffectiveDate=iOrderIN.effectiveDate, DeliveryDate__c=iOrderIN.deliveryDate, ExternalId__c=iOrderIN.orderCode, 
                AccountId=iOrderIN.accountCode, ShippingType__c=iOrderIN.freightType, Status='Novo',Observations__c=iOrderIN.obs));
            }
            
        }
        return newOrders;
    }
    public static List<OrderItem> convertOrderItem(List<OrderIN> ordersToIntegrate,List<Order> newOrders,List<Database.UpsertResult> orderUpsertResults, 
    Map<String,List<DataIntegration.Response>> responseMap){

        List<OrderItem> newOrderItems = new List<OrderItem>();
        for (Integer i = 0; i < newOrders.size();++i){
            if (orderUpsertResults[i].isSuccess()){
                for (OrderItemIN iOrderItem:ordersToIntegrate[i].orderItems){
                    //System.debug('ProductCode debug: '+iOrderItem.productCode);
                    if (iOrderItem.productCode == null){
                        
                        responseMap.get('OrderItem').add(new DataIntegration.Response(null,iOrderItem.itemCode,
                            'No Product2Id found for OrderItem with ExternalId: '+iOrderItem.itemCode+' \n','OrderItem'));
                    }
                    else{
                        newOrderItems.add(new OrderItem(ExternalId__c=iOrderItem.itemCode, Product2Id=iOrderItem.productCode, 
                            OrderId=newOrders[i].Id, Quantity=iOrderItem.quantity, UnitPrice=iOrderItem.unitPrice,ListPrice=iOrderItem.listPrice,
                            totvsItem__c=iOrderItem.totvsItem));
                    }
                    
                }
            }
            
        }
        return newOrderItems;
    }
    @HttpPost
	global static Map<String,List<DataIntegration.Response>> orderInbound(){
		List<OrderIN> ordersToIntegrate = ((OrderRequest)JSON.deserialize(RestContext.request.requestBody.toString(),OrderRequest.class)).request;
        List<OrderIN> originalOrders = ((OrderRequest)JSON.deserialize(RestContext.request.requestBody.toString(),OrderRequest.class)).request;
        //code to relate Codes with IDs using SOQL
        Set<String> relatedAddresses = new Set<String>();
        Set<String> relatedPayments = new Set<String>();
        Set<String> relatedOrderItemIds = new Set<String>();
        Set<String> relatedDistributionCenters = new Set<String>();
        Set<String> relatedProducts = new Set<String>();
        Set<String> relatedAccounts = new Set<String>();
        Set<String> relatedOrderExternalIds = new Set<String>();
        for (OrderIN iOrder:ordersToIntegrate){
            for (OrderItemIN iOrderItem:iOrder.orderItems){
                relatedProducts.add(iOrderItem.productCode);
                relatedOrderItemIds.add(iOrderItem.itemCode);
            }
            relatedOrderExternalIds.add(iOrder.orderCode);
            relatedAddresses.add(iOrder.addressCode);
            relatedPayments.add(iOrder.paymentCode);
            relatedDistributionCenters.add(iOrder.distributionCenterCode);
            relatedAccounts.add(iOrder.accountCode);
            
        }
        
        List<AccountAddress__c> relatedAddressesQueryResult = [SELECT Id,Code__c FROM AccountAddress__c WHERE Code__c IN :relatedAddresses];
        Map<String,Id> relatedAddressesMap = new Map<String,Id>();
        for (AccountAddress__c iAddress:relatedAddressesQueryResult){
            relatedAddressesMap.put(iAddress.Code__c,iAddress.Id);
        }
        List<PaymentCondition__c> relatedPaymentsQueryResult = [SELECT Id, Code__c FROM PaymentCondition__c WHERE Code__c IN :relatedPayments];
        Map<String,Id> relatedPaymentsMap = new Map<String,Id>();
        for (PaymentCondition__c iPaymentCondition:relatedPaymentsQueryResult){
            relatedPaymentsMap.put(iPaymentCondition.Code__c,iPaymentCondition.Id);
        }
        List<DistributionCenter__c> relatedDistributionCentersQueryResult = [SELECT Id, Code__c FROM DistributionCenter__c WHERE Code__c IN :relatedDistributionCenters];
        Map<String,Id> relatedDistributionCentersMap = new Map<String,Id>();
        for (DistributionCenter__c iDistributionCenter:relatedDistributionCentersQueryResult){
            relatedDistributionCentersMap.put(iDistributionCenter.Code__c,iDistributionCenter.Id);
        }
        List<Product2> relatedProductsQueryResult = [SELECT Id, ExternalId__c FROM Product2 WHERE ExternalId__c IN :relatedProducts];
        Map<String,Id> relatedProductsMap = new Map<String,Id>();
        for (Product2 iProduct:relatedProductsQueryResult){
            relatedProductsMap.put(iProduct.ExternalId__c,iProduct.Id);
        }
        List<Account> relatedAccountsQueryResult = [SELECT Id, ExternalId__c FROM Account WHERE ExternalId__c IN:relatedAccounts];
        Map<String,Id> relatedAccountsMap = new Map<String,Id>();
        for (Account iAccount:relatedAccountsQueryResult){
            relatedAccountsMap.put(iAccount.ExternalId__c,iAccount.Id);
        }



        for (OrderIN iOrder:ordersToIntegrate){
            for (OrderItemIN iOrderItem:iOrder.orderItems){
                iOrderItem.productCode = relatedProductsMap.get(iOrderItem.productCode);
            }
            iOrder.addressCode = relatedAddressesMap.get(iOrder.addressCode);
            iOrder.paymentCode = relatedPaymentsMap.get(iOrder.paymentCode);
            iOrder.distributionCenterCode = relatedDistributionCentersMap.get(iOrder.distributionCenterCode);
            iOrder.accountCode = relatedAccountsMap.get(iOrder.accountCode);
        }
        String externalIdList = '';
        for (String iExternalId:relatedOrderExternalIds){
            externalIdList += iExternalId + ',';
        }
        
        String endpoint = System.Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/orderInbound';
        Map<String,List<DataIntegration.Response>> responseMap = new Map<String,List<DataIntegration.Response>>();
        try{
            
            responseMap.put('Order',new List<DataIntegration.Response>());
            responseMap.put('OrderItem',new List<DataIntegration.Response>());

            List<Order> newOrders = convertOrder(ordersToIntegrate,relatedAccountsMap,responseMap);
            if (newOrders.isEmpty()){
                IntegrationLog.createLog('Order', externalIdList, 'Inbound', JSON.serialize(originalOrders), JSON.serialize(responseMap), endpoint, true, false);
                return responseMap;
            }
            Boolean hasAnyErrors = false;
            
            List<Database.UpsertResult> orderUpsertResults = Database.upsert(newOrders,Order.ExternalId__c,false);
            Set<String> successfulOrderUpsertExternalIds = new Set<String>();
            for (Integer i = 0; i < orderUpsertResults.size(); i++){
                String errorMessage = '';
                if (!orderUpsertResults[i].isSuccess()){
                    if (!hasAnyErrors){
                        hasAnyErrors = true;
                    }
                    
                    for (Database.Error iError: orderUpsertResults[i].getErrors()){
                        errorMessage += iError.getMessage() + ' \n';
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
            
            Boolean hasDeleted = false;
            /*
            //all remaining OrderItems related to the Orders should have DeletedProduct = true, since they're not included in the callout!
            for (OrderItem iOrderItem:[SELECT Id,DeletedProduct__c,ExternalId__c FROM OrderItem WHERE Order.ExternalId__c IN :relatedOrderExternalIds]){ //sets deletedProduct to true
                if (!hasDeleted){
                    hasDeleted = true;
                }
                
                iOrderItem.DeletedProduct__c = true;
                newOrderItems.add(iOrderItem);
            }
            */

            
            
            List<Database.SaveResult> orderItemsUpsertResults = Database.insert(newOrderItems,false);
            for (Integer i = 0;i < orderItemsUpsertResults.size();++i){ 
                String errorMessage = '';
                if (!orderItemsUpsertResults[i].isSuccess()){
                    
                    if (!hasAnyErrors){
                        hasAnyErrors = true;
                    }
                    
                    for (Database.Error iError: orderItemsUpsertResults[i].getErrors()){
                        errorMessage += iError.getMessage() + ' \n';
                    }
                    
                }
                responseMap.get('OrderItem').add(new DataIntegration.Response(orderItemsUpsertResults[i].getId(),newOrderItems[i].ExternalId__c,errorMessage,'OrderItem'));
            }
            
            
            
            String logId = IntegrationLog.createLog('Order', externalIdList, 'Inbound', JSON.serialize(originalOrders), JSON.serialize(responseMap), endpoint, hasAnyErrors, hasDeleted);
            for (Order iOrder: newOrders){
                iOrder.IntegrationLogInbound__c = logId;
                update iOrder;
            }
            
        }
        catch(Exception e){
            IntegrationLog__c log=new IntegrationLog__c(); 
            log.ErrorMessage__c = e.getMessage();
            log.Status__c = 'Error';
            log.ExecutionDate__c = Datetime.now();
            insert log;
        }
        
        

		return responseMap;
	}
}
    
