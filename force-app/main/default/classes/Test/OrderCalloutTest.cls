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
private class OrderCalloutTest {
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
        accountsToInsert.add((Account)testFactory.createSObject(new Account(AccountGroup__c=accountGroupsToInsert[0].Id,CNPJ__c='11.111.111/1111-11')));
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

        Order[] ordersToInsert = new Order[]{};
        ordersToInsert.add((Order) testFactory.createSObject(testFactory.createSObject(new Order(AccountId=accountsToInsert[0].Id,DistributionCenter__c=distributionCentersToInsert[0].Id,
        AccountAddress__c = accountAddressesToInsert[0].Id,PaymentCondition__c=paymentConditionsToInsert[0].Id,Status = 'Novo'))));
        insert ordersToInsert;

        PricebookEntry[] pricebookEntriesToInsert = new PricebookEntry[]{};
        pricebookEntriesToInsert.add((PricebookEntry) testFactory.createSObject(new PricebookEntry(Pricebook2Id=priceBookId,
        Product2Id=productsToInsert[0].Id,UnitPrice=productsToInsert[0].ProductCost__c)));
        insert pricebookEntriesToInsert; 
        
        OrderItem[] orderItemsToInsert = new OrderItem[]{};
        orderItemsToInsert.add(new OrderItem(Product2Id=productsToInsert[0].Id,OrderId=ordersToInsert[0].Id,UnitPrice=20,ListPrice=25,Quantity=1));
        insert orderItemsToInsert;
    }

    @isTest
    static void testCalloutSuccess() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OrderCalloutMockSuccess());
        
        Order orderToApprove = [SELECT Id,IntegrationLogOutbound__c FROM Order LIMIT 1];
        orderToApprove.Status = 'Em Aprovação';
        update orderToApprove;
        Test.stopTest();
        orderToApprove = [SELECT Id,IntegrationLogOutbound__c FROM Order LIMIT 1];
        System.assert(orderToApprove.IntegrationLogOutbound__c != null);
    }
    @isTest
    static void testCalloutError(){
        Test.startTest();
        
        
        Test.setMock(HttpCalloutMock.class, new OrderCalloutMockError());
        
        Order orderToApprove = [SELECT Id,IntegrationLogOutbound__c FROM Order LIMIT 1];
        orderToApprove.Status = 'Aprovado';
        update orderToApprove;
        Test.stopTest();
        orderToApprove = [SELECT Id,IntegrationLogOutbound__c FROM Order LIMIT 1];
        System.assert(orderToApprove.IntegrationLogOutbound__c != null);
    }   
    @isTest
    static void testCalloutResponseError(){
        Test.startTest();
        
        
        Test.setMock(HttpCalloutMock.class, new OrderCalloutResponseError());
        
        Order orderToApprove = [SELECT Id,IntegrationLogOutbound__c FROM Order LIMIT 1];
        orderToApprove.Status = 'Aprovado';
        update orderToApprove;
        Test.stopTest();
        orderToApprove = [SELECT Id,IntegrationLogOutbound__c FROM Order LIMIT 1];
        System.assert(orderToApprove.IntegrationLogOutbound__c != null);
    }
    @isTest
    static void testCalloutNeedApproval() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OrderCalloutMockSuccess());
        
        Product2 orderItemProduct = [SELECT Id FROM Product2 LIMIT 1];
        Order orderToApprove = [SELECT Id,IntegrationLogOutbound__c FROM Order LIMIT 1];
        OrderItem orderItemToInsert = new OrderItem(Product2Id=orderItemProduct.Id,OrderId=orderToApprove.Id,UnitPrice=1,ListPrice=200,Quantity=1);
        insert orderItemToInsert;
        
        orderToApprove.Status = 'Em Aprovação';
        update orderToApprove;
        Test.stopTest();
        
        
    }
}