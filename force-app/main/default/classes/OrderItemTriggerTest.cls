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
private class OrderItemTriggerTest {
    @TestSetup
    static void makeData(){
        //grupo de clientes
        AccountGroup__c newAccountGroup = new AccountGroup__c(Name='Mercados');
        insert newAccountGroup;
        //criar contas
        Account[] accountsToInsert = new Account[]{};
        accountsToInsert.add(new Account(Name='Mercado1',AccountGroup__c=newAccountGroup.Id,CNPJ__c='11.111.111/1111-11'));
        accountsToInsert.add(new Account(Name='Mercado2',AccountGroup__c=newAccountGroup.Id,CNPJ__c='11.111.111/1111-12'));
        accountsToInsert.add(new Account(Name='Mercado3',AccountGroup__c=newAccountGroup.Id,CNPJ__c='11.111.111/1111-13'));

        insert accountsToInsert;
        //criar pais
        Country__c newCountry = new Country__c (Name='Brasil',NameShort__c='BR');
        insert newCountry;
        //criar estado
        States__c[] newStates = new States__c[]{};
        newStates.add(new States__c(Name='Sao Paulo',NameShort__c='SP',Country__c=newCountry.Id));
        newStates.add(new States__c(Name='Rio de Janeiro',NameShort__c='RJ',Country__c=newCountry.Id));
        newStates.add(new States__c(Name='Minas Gerais',NameShort__c='MG',Country__c=newCountry.Id));
        insert newStates;
        //criar cidade
        City__c[] newCities = new City__c[]{};
        newCities.add(new City__c(Name='Sao Paulo',State__c=newStates[0].Id,IBGECode__c='11111'));
        newCities.add(new City__c(Name='Rio de Janeiro',State__c=newStates[1].Id,IBGECode__c='22222'));
        newCities.add(new City__c(Name='Belo Horizonte',State__c=newStates[2].Id,IBGECode__c='33333'));
        insert newCities;
        //criar enderecos
        AccountAddress__c[] addressesToInsert = new AccountAddress__c[]{};
        addressesToInsert.add(new AccountAddress__c(Name='Endereco1',Account__c=accountsToInsert[0].Id,City__c=newCities[0].Id,Code__c='11111-111',CEP__c='11111-111',Address__c='Rua 1',Neighborhood__c='Centro'));
        addressesToInsert.add(new AccountAddress__c(Name='Endereco2',Account__c=accountsToInsert[1].Id,City__c=newCities[1].Id,Code__c='22222-222',CEP__c='22222-222',Address__c='Rua 2',Neighborhood__c='Centro'));
        addressesToInsert.add(new AccountAddress__c(Name='Endereco3',Account__c=accountsToInsert[2].Id,City__c=newCities[2].Id,Code__c='33333-333',CEP__c='33333-333',Address__c='Rua 3',Neighborhood__c='Centro'));

        insert addressesToInsert;
        //criar contratos
        Contract[] contractsToInsert = new Contract[]{};
        for (Integer i = 0; i < 3; ++i){
            contractsToInsert.add(new Contract(AccountId=accountsToInsert[i].Id,StartDate=Date.today(),Status='Draft',ContractTerm=12));
        }
        insert contractsToInsert;
        PaymentCondition__c paymentToInsert = new PaymentCondition__c(Name='Crédito',Code__c='8763');
        DistributionCenter__c distributionToInsert = new DistributionCenter__c(Name='Centro de Distr. SP',Code__c='7363');
        ProductHierarchy__c hierarchyToInsert = new ProductHierarchy__c(Name='Padaria',Code__c='80085');
        insert paymentToInsert;
        insert distributionToInsert;
       



        
    }
    @isTest
    static void myUnitTest() {
        
        
    }
}