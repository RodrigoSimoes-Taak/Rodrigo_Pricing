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
private class TaxTriggerTest {
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

        DistributionCenter__c[] distributionCentersToInsert = new DistributionCenter__c[]{};
        distributionCentersToInsert.add((DistributionCenter__c)testFactory.createSObject(new DistributionCenter__c()));
        insert distributionCentersToInsert;

        ProductHierarchy__c[] productHierarchiesToInsert = new ProductHierarchy__c[]{};
        productHierarchiesToInsert.add((ProductHierarchy__c)testFactory.createSObject(new ProductHierarchy__c()));
        insert productHierarchiesToInsert;

        Product2[] productsToInsert = new Product2[]{};
        productsToInsert.add((Product2)testFactory.createSObject(new Product2(ProductHierarchy__c=productHierarchiesToInsert[0].Id)));
        productsToInsert.add((Product2)testFactory.createSObject(new Product2(ProductHierarchy__c=productHierarchiesToInsert[0].Id)));
        insert productsToInsert;

        Tax__c[] taxesToInsert = new Tax__c[]{};
        taxesToInsert.add((Tax__c)testFactory.createSObject(new Tax__c(Product__c=productsToInsert[0].Id,DistributionCenter__c=distributionCentersToInsert[0].Id,State__c=statesToInsert[0].Id)));
        
        insert taxesToInsert;
    }
    @isTest
    static void successfulTest() {
        Tax__c updatedTax = [SELECT Id, Name, State__c FROM Tax__c LIMIT 1];
        States__c newState = new States__c(Name='TestState',NameShort__c='TS',Country__c=[SELECT Id FROM Country__c LIMIT 1].Id);
        insert newState;
        updatedTax.State__c = newState.Id;
        update updatedTax;
    }
    @isTest
    static void outerDuplicateTaxTest(){
        Tax__c duplicateTax = new Tax__c(Name='TestName',State__c=[SELECT Id FROM States__c LIMIT 1].Id,Product__c=[SELECT Id FROM Product2 LIMIT 1].Id,
        DistributionCenter__c=[SELECT Id FROM DistributionCenter__c LIMIT 1].Id);

        try{
            insert duplicateTax;
            System.assert(false);
        }
        catch(Exception e){
            
            System.assert(true);
            
            
        }
        
    }
    @isTest
    static void innerDuplicateTaxTest(){
        Tax__c[] duplicateTaxes = new Tax__c[]{};
        duplicateTaxes.add(new Tax__c(Name='TestName2',State__c=[SELECT Id FROM States__c LIMIT 1].Id,Product__c=[SELECT Id FROM Product2 LIMIT 1].Id,
        DistributionCenter__c=[SELECT Id FROM DistributionCenter__c LIMIT 1].Id));
        duplicateTaxes.add(new Tax__c(Name='TestName3',State__c=[SELECT Id FROM States__c LIMIT 1].Id,Product__c=[SELECT Id FROM Product2 LIMIT 1].Id,
        DistributionCenter__c=[SELECT Id FROM DistributionCenter__c LIMIT 1].Id));
        try{
            insert duplicateTaxes;
            System.assert(false);
        }
        catch(Exception e){
            System.assert(true);
        }
        
    }
}