/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class OrderIntegrationTest {
    @TestSetup
    static void makeData(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();
        Id priceBookId = TestFactorySObject.getStandardPricebookId();
        update new Pricebook2(Id=priceBookId);

        Country__c[] countriesToInsert = new Country__c[]{};
        States__c[] statesToInsert = new States__c[]{};
        City__c[] citiesToInsert = new City__c[]{};
        countriesToInsert.add((Country__c)testFactory.createSObject(new Country__c()));
        insert countriesToInsert;

        statesToInsert.add((States__c)testFactory.createSObject(new States__c(Country__c=countriesToInsert[0].Id)));
        insert statesToInsert;

        citiesToInsert.add((City__c)testFactory.createSObject(new City__c(State__c=statesToInsert[0].Id)));
        citiesToInsert.add((City__c)testFactory.createSObject(new City__c(State__c=statesToInsert[0].Id)));
        insert citiesToInsert;

        ProductHierarchy__c[] productHierarchiesToInsert = new ProductHierarchy__c[]{};
        productHierarchiesToInsert.add((ProductHierarchy__c)testFactory.createSObject(new ProductHierarchy__c()));
        insert productHierarchiesToInsert;

        Product2[] productsToInsert = new Product2[]{};
        productsToInsert.add((Product2)testFactory.createSObject(new Product2(ProductHierarchy__c=productHierarchiesToInsert[0].Id,ExternalId__c='111')));
        insert productsToInsert;

        DistributionCenter__c[] distributionCentersToInsert = new DistributionCenter__c[]{};
        distributionCentersToInsert.add((DistributionCenter__c)testFactory.createSObject(new DistributionCenter__c(Code__c='3895784309')));
        insert distributionCentersToInsert;

        AccountGroup__c[] accountGroupsToInsert = new AccountGroup__c[]{};
        accountGroupsToInsert.add((AccountGroup__c)testFactory.createSObject(new AccountGroup__c()));
        insert accountGroupsToInsert;

        Account[] accountsToInsert = new Account[]{};
        accountsToInsert.add((Account)testFactory.createSObject(new Account(AccountGroup__c=accountGroupsToInsert[0].Id,CNPJ__c='11.111.111/1111-11',ExternalId__c='01134080000130')));
        insert accountsToInsert;

        Tax__c[] taxesToInsert = new Tax__c[]{};
        taxesToInsert.add((Tax__c)testFactory.createSObject(new Tax__c(Product__c=productsToInsert[0].Id,DistributionCenter__c=distributionCentersToInsert[0].Id,State__c=statesToInsert[0].Id)));
        insert taxesToInsert;

        ProfitMargin__c[] profitMarginsToInsert = new ProfitMargin__c[]{};
        profitMarginsToInsert.add((ProfitMargin__c)testFactory.createSObject(new ProfitMargin__c(Product__c=productsToInsert[0].Id,
            AccountGroup__c=accountGroupsToInsert[0].Id,DistributionCenter__c=distributionCentersToInsert[0].Id,
            City__c=citiesToInsert[0].Id)));
        profitMarginsToInsert.add((ProfitMargin__c) testFactory.createSObject(new ProfitMargin__c(ProductHierarchy__c=productHierarchiesToInsert[0].Id,
            Account__c=accountsToInsert[0].Id,DistributionCenter__c=distributionCentersToInsert[0].Id,Country__c=countriesToInsert[0].Id)));
        
        insert profitMarginsToInsert;

        Shipping__c[] shippingsToInsert = new Shipping__c[]{};
        shippingsToInsert.add((Shipping__c)testFactory.createSObject(new Shipping__c(ProductHierarchy__c=productHierarchiesToInsert[0].Id,
            State__c=statesToInsert[0].Id,DistributionCenter__c=distributionCentersToInsert[0].Id)));
        shippingsToInsert.add((Shipping__c)testFactory.createSObject(new Shipping__c(Product__c=productsToInsert[0].Id,
            State__c=statesToInsert[0].Id,DistributionCenter__c=distributionCentersToInsert[0].Id)));
        
        insert shippingsToInsert;

        PaymentCondition__c[] paymentConditionsToInsert = new PaymentCondition__c[]{};
        paymentConditionsToInsert.add((PaymentCondition__c)testFactory.createSObject(new PaymentCondition__c(Code__c='90')));
        insert paymentConditionsToInsert;

        
        AccountAddress__c[] accountAddressesToInsert = new AccountAddress__c[]{};
        accountAddressesToInsert.add((AccountAddress__c)testFactory.createSObject(new AccountAddress__c(Account__c=accountsToInsert[0].Id,City__c=citiesToInsert[0].Id,Code__c='ER4597')));
        insert accountAddressesToInsert;
        

    }
    @isTest
    static void testInboundSuccess() {
        String JSONString = '{ '+
        '"request":['+
        '   {'+
        '   "accountCode": "01134080000130",'+
        '   "orderCode": "0000100",'+
        '   "status": "Draft",'+
        '   "addressCode": "ER4597",'+
        '   "paymentCode": "90",'+
        '   "effectiveDate": "2020-01-01",'+
        '   "freightType": "CIF",'+
        '   "distributionCenterCode": "3895784309",'+
        '   "deliveryDate": "2021-02-12",'+
        '   "obs": "Envio deve ser feito antes de março",'+
        '   "orderItems": ['+
        '       {'+
        '       "quantity": 1,'+
        '       "productCode": "111",'+
        '       "unitPrice": 49.99,'+
        '       "totvsItem": false,'+
        '       "listPrice": 259.99'+
        '       }'+
        '   ]'+
        '   }'+
        '   ]'+
        '}';
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/orderInbound';
        request.httpMethod = 'POST'; 
        request.requestBody = Blob.valueOf(JSONString); 
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;
        Test.startTest();
        OrderIntegration.orderInbound();
        Test.stopTest();

    }
    @isTest
    static void testInboundPartialSuccess(){
        String JSONString = '{ '+
        '"request":['+
        '   {'+
        '   "accountCode": "01134080000130",'+
        '   "orderCode": "0000100",'+
        '   "status": "Draft",'+
        '   "addressCode": "ER4597",'+
        '   "paymentCode": "90",'+
        '   "effectiveDate": "2020-01-01",'+
        '   "freightType": "CIF",'+
        '   "distributionCenterCode": "3895784309",'+
        '   "deliveryDate": "2021-02-12",'+
        '   "obs": "Envio deve ser feito antes de março",'+
        '   "orderItems": ['+
        '       {'+
        '       "quantity": 1,'+
        '       "productCode": "111",'+
        '       "unitPrice": 49.99,'+
        '       "totvsItem": false,'+
        '       "listPrice": 259.99'+
        '       },'+
        '       {'+
        '       "quantity": 1,'+
        '       "productCode": "112",'+
        '       "unitPrice": 49.99,'+
        '       "totvsItem": false,'+
        '       "listPrice": 259.99'+
        '       }'+
        '   ]'+
        '   },'+
        '   {'+
        '   "accountCode": "0113408000013",'+
        '   "orderCode": "0000101",'+
        '   "status": "Draft",'+
        '   "addressCode": "ER4597",'+
        '   "paymentCode": "90",'+
        '   "effectiveDate": "2020-01-01",'+
        '   "freightType": "CIF",'+
        '   "distributionCenterCode": "3895784309",'+
        '   "deliveryDate": "2021-02-12",'+
        '   "obs": "Envio deve ser feito antes de março",'+
        '   "orderItems": ['+
        '       {'+
        '       "quantity": 1,'+
        '       "productCode": "111",'+
        '       "unitPrice": 49.99,'+
        '       "totvsItem": false,'+
        '       "listPrice": 259.99'+
        '       }'+
        '   ]'+
        '   }'+
        '   ]'+
        '}';
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/orderInbound';
        request.httpMethod = 'POST'; 
        request.requestBody = Blob.valueOf(JSONString); 
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;
        Test.startTest();
        OrderIntegration.orderInbound();
        Test.stopTest();
    }
    @isTest
    public static void testInboundEmpty(){
        String JSONString = '{'+
        '   "request": []'+
        '}';
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/orderInbound';
        request.httpMethod = 'POST'; 
        request.requestBody = Blob.valueOf(JSONString); 
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;
        Test.startTest();
        OrderIntegration.orderInbound();
        Test.stopTest();
    }
}