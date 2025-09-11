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
private class ShippingTriggerTest {
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
        insert productsToInsert;

        Shipping__c[] shippingsToInsert = new Shipping__c[]{};
        shippingsToInsert.add((Shipping__c)testFactory.createSObject(new Shipping__c(Product__c=productsToInsert[0].Id,
        DistributionCenter__c=distributionCentersToInsert[0].Id,State__c=statesToInsert[0].Id)));
        shippingsToInsert.add((Shipping__c)testFactory.createSObject(new Shipping__c(Product__c=productsToInsert[0].Id,
        DistributionCenter__c=distributionCentersToInsert[0].Id,Country__c=countriesToInsert[0].Id)));
        shippingsToInsert.add((Shipping__c)testFactory.createSObject(new Shipping__c(ProductHierarchy__c=productHierarchiesToInsert[0].Id,
        DistributionCenter__c=distributionCentersToInsert[0].Id,City__c=citiesToInsert[0].Id)));
        insert shippingsToInsert;
    }
    @isTest
    static void updateTest() {
        Shipping__c updatedShipping = [SELECT Id,Country__c,State__c FROM Shipping__c WHERE State__c != null LIMIT 1];
        update updatedShipping;//should not error (no changes were made)
        updatedShipping.State__c = null;
        updatedShipping.Country__c = [SELECT Id FROM Country__c LIMIT 1].Id;
        try{
            update updatedShipping; //should error(outer duplicate)!
            System.assert(false);
        }
        catch(Exception e){
            System.assert(true);
        }
    }
    @isTest
    static void innerDuplicate(){
        Shipping__c[] shippingsToInsert = new Shipping__c[]{};
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        DistributionCenter__c distributionCenter = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        City__c city = [SELECT Id FROM City__c LIMIT 1];
        shippingsToInsert.add(new Shipping__c(Name='testname',Product__c=product.Id,Status__c='Aprovado',DistributionCenter__c=distributionCenter.Id,
        City__c=city.Id));
        shippingsToInsert.add(new Shipping__c(Name='testname',Product__c=product.Id,Status__c='Aprovado',DistributionCenter__c=distributionCenter.Id,
        City__c=city.Id));
        try{
            insert shippingsToInsert;
            System.assert(false);
        }
        catch(Exception e){
            System.Assert(true);
        }
       


    }
}