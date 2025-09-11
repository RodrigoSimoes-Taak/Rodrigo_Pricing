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
private class ProfitMarginTriggerTest {
    @TestSetup
    static void makeData(){
        TestFactorySObject testFactory = TestFactorySObject.getInstance();
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

        ProfitMargin__c[] profitMarginsToInsert = new ProfitMargin__c[]{};
        profitMarginsToInsert.add((ProfitMargin__c)testFactory.createSObject(new ProfitMargin__c(Product__c=productsToInsert[0].Id,
            AccountGroup__c=accountGroupsToInsert[0].Id,DistributionCenter__c=distributionCentersToInsert[0].Id,
            State__c=statesToInsert[0].Id)));
        profitMarginsToInsert.add((ProfitMargin__c) testFactory.createSObject(new ProfitMargin__c(ProductHierarchy__c=productHierarchiesToInsert[0].Id,
            Account__c=accountsToInsert[0].Id,DistributionCenter__c=distributionCentersToInsert[0].Id,
            Country__c=countriesToInsert[0].Id)));
        
        insert profitMarginsToInsert;
    }
    @isTest
    static void successfulTest() {
        ProfitMargin__c updatedMargin = [SELECT Id FROM ProfitMargin__c WHERE State__c != null LIMIT 1];
        
        update updatedMargin;
    }
    @isTest
    static void outerDuplicateProfitMarginTest(){
        ProfitMargin__c duplicateMargin = [SELECT Id, Name, State__c,Account__c,AccountGroup__c,Country__c,Product__c,ProductHierarchy__c FROM ProfitMargin__c WHERE Country__c != null LIMIT 1];
        duplicateMargin.Product__c = [SELECT Id FROM Product2 LIMIT 1].Id;
        duplicateMargin.ProductHierarchy__c = null;
        duplicateMargin.Country__c = null;
        duplicateMargin.State__c = [SELECT Id FROM States__c LIMIT 1].Id;
        duplicateMargin.AccountGroup__c = [SELECT Id FROM AccountGroup__c LIMIT 1].Id;
        duplicateMargin.Account__c = null;
        try{
            update duplicateMargin;
            System.assert(false);
        }
        catch(Exception e){
            System.assert(true);
        }
    }
    @isTest
    static void innerDuplicateProfitMarginTest(){
        ProfitMargin__c[] newProfitMargins = new ProfitMargin__C[]{};
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        DistributionCenter__c distributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        City__c city = [SELECT Id FROM City__c LIMIT 1];
        AccountGroup__c accountGroup = [SELECT Id FROM AccountGroup__c LIMIT 1];
        newProfitMargins.add(new ProfitMargin__c(Name='testname',Product__c=product.Id,AccountGroup__c=accountGroup.Id,DistributionCenter__c=distributionCenter.Id,
        City__c=city.Id,Status__c='Aprovado'));
        newProfitMargins.add(new ProfitMargin__c(Name='testname',Product__c=product.Id,AccountGroup__c=accountGroup.Id,DistributionCenter__c=distributionCenter.Id,
        City__c=city.Id,Status__c='Aprovado'));
        try{
            insert newProfitMargins;
            System.assert(false);
        }
        catch(Exception e){
            System.assert(true);
        }
    }
}