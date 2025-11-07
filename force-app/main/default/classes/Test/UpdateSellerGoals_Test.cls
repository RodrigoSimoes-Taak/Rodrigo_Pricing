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
private class UpdateSellerGoals_Test {
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
        productsToInsert.add((Product2)testFactory.createSObject(new Product2(ProductHierarchy__c=productHierarchiesToInsert[0].Id)));
        insert productsToInsert;

        DistributionCenter__c[] distributionCentersToInsert = new DistributionCenter__c[]{};
        distributionCentersToInsert.add((DistributionCenter__c)testFactory.createSObject(new DistributionCenter__c()));
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
        paymentConditionsToInsert.add((PaymentCondition__c)testFactory.createSObject(new PaymentCondition__c()));
        insert paymentConditionsToInsert;

        

        AccountAddress__c[] accountAddressesToInsert = new AccountAddress__c[]{};
        accountAddressesToInsert.add((AccountAddress__c)testFactory.createSObject(new AccountAddress__c(Account__c=accountsToInsert[0].Id,City__c=citiesToInsert[0].Id)));
        accountAddressesToInsert.add((AccountAddress__c)testFactory.createSObject(new AccountAddress__c(Account__c=accountsToInsert[0].Id,City__c=citiesToInsert[1].Id)));
        insert accountAddressesToInsert;

        Contact[] contactsToInsert = new Contact[]{};
        contactsToInsert.add((Contact)testFactory.createSObject(new Contact()));
        insert contactsToInsert;

        Order[] ordersToInsert = new Order[]{};
        ordersToInsert.add((Order) testFactory.createSObject(new Order(AccountId=accountsToInsert[0].Id,
        PaymentCondition__c=paymentConditionsToInsert[0].Id, DistributionCenter__c=distributionCentersToInsert[0].Id,
        AccountAddress__c=accountAddressesToInsert[0].Id,Contact__c=contactsToInsert[0].Id, Pricebook2Id=priceBookId)));
        insert ordersToInsert;
       
        PricebookEntry[] pricebookEntriesToInsert = new PricebookEntry[]{};
        pricebookEntriesToInsert.add((PricebookEntry) testFactory.createSObject(new PricebookEntry(Pricebook2Id=priceBookId,
        Product2Id=productsToInsert[0].Id,UnitPrice=productsToInsert[0].ProductCost__c)));
        insert pricebookEntriesToInsert; 

        List<OrderItem> orderItemsToInsert = new List<OrderItem>();
        orderItemsToInsert.add(
            new OrderItem(Product2Id = productsToInsert[0].Id,Quantity=1,UnitPrice=2.99,OrderId=ordersToInsert[0].Id,
            PricebookEntryId = pricebookEntriesToInsert[0].Id)
            );
        insert orderItemsToInsert;

        List<Opportunity> oppsToInsert = new List<Opportunity>();
        oppsToInsert.add((Opportunity)testFactory.createSObject(
            new Opportunity(Pricebook2Id=priceBookId,StageName='Closed Won',CloseDate=Date.today()))
            );
        insert oppsToInsert;

        List<OpportunityLineItem> oppLineItemsToInsert = new List<OpportunityLineItem>();
        oppLineItemsToInsert.add((OpportunityLineItem)testFactory.createSObject(
            new OpportunityLineItem(OpportunityId = oppsToInsert[0].Id,Product2Id= productsToInsert[0].Id)));
        insert oppLineItemsToInsert;

        List<Goal__c> goalsToInsert = new List<Goal__c>();
        goalsToInsert.add(new Goal__c(Name= 'TestGoal',Year__c=Date.today().year(),Seller__c = UserInfo.getUserId()));
        insert goalsToInsert;

        List<GoalItem__c> goalItemsToInsert = new List<GoalItem__c>();
        goalItemsToInsert.add(new GoalItem__c( //performance goalItem
            Name = 'Performance',RecordTypeId= '012fj000002MaDN',Meta__c = goalsToInsert[0].Id,GoalValue__c = 5,CommissionPercentage__c=2));
        insert goalItemsToInsert;


    }

    @isTest
    static void checkOppValue() {
        Test.startTest();
        Database.executeBatch(new UpdateSellerGoals());
        Test.stopTest();
        Decimal value = [SELECT ProjectedEarnings__c FROM GoalItem__c WHERE Name = 'Performance'].ProjectedEarnings__c;
        System.assertEquals(2.99, value);
    }
    @isTest
    static void checkDraftOrderValue(){
        Test.startTest();
        Database.executeBatch(new UpdateSellerGoals());
        Test.stopTest();
        Decimal value = [SELECT NegotiatedEarnings__c FROM GoalItem__c WHERE Name = 'Performance'].NegotiatedEarnings__c;
        System.assertEquals(33.11, value); //2.99 + Shipping, taxes etc.
    }
    @isTest
    static void checkActivatedOrderValue(){
        Order orderToUpdate = [SELECT Id,Status FROM Order];
        orderToUpdate.Status = 'Integrado';
        update orderToUpdate;
        Test.startTest();
        Database.executeBatch(new UpdateSellerGoals());
        Test.stopTest();
        Decimal value = [SELECT ActualEarnings__c FROM GoalItem__c WHERE Name = 'Performance'].ActualEarnings__c;
        System.assertEquals(33.11, value); //2.99 + Shipping, taxes etc.
    }
    @isTest
    static void checkOppAmount(){

    }
    @isTest
    static void checkCommissionPercentage(){

    }
}