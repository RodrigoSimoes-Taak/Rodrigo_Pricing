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
        //perguntar: Faz sentido deletar alguns records para testes?
        //plano inicial:
        //1 order
        //1 products
        //1 account
        //1 accountaddress
        //1 accountgroup
        //1 producthierarchy
        //1 impostos
        //2 fretes (1 produto 1 hierarquia)
        //2 margens (1 produto 1 hierarquia)

        //!! Fazer orderitems NO TESTE, não no makedata!
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

        Contract[] contractsToInsert = new Contract[]{};
        contractsToInsert.add((Contract)testFactory.createSObject(new Contract(AccountId=accountsToInsert[0].Id)));
        insert contractsToInsert;

        AccountAddress__c[] accountAddressesToInsert = new AccountAddress__c[]{};
        accountAddressesToInsert.add((AccountAddress__c)testFactory.createSObject(new AccountAddress__c(Account__c=accountsToInsert[0].Id,City__c=citiesToInsert[0].Id)));
        accountAddressesToInsert.add((AccountAddress__c)testFactory.createSObject(new AccountAddress__c(Account__c=accountsToInsert[0].Id,City__c=citiesToInsert[1].Id)));
        insert accountAddressesToInsert;

        Contact[] contactsToInsert = new Contact[]{};
        contactsToInsert.add((Contact)testFactory.createSObject(new Contact()));
        insert contactsToInsert;

        Order[] ordersToInsert = new Order[]{};
        ordersToInsert.add((Order) testFactory.createSObject(new Order(AccountId=accountsToInsert[0].Id,
        PaymentCondition__c=paymentConditionsToInsert[0].Id,ContractId=contractsToInsert[0].Id, DistributionCenter__c=distributionCentersToInsert[0].Id,
        AccountAddress__c=accountAddressesToInsert[0].Id,Contact__c=contactsToInsert[0].Id, Pricebook2Id=priceBookId)));
        insert ordersToInsert;
       
        PricebookEntry[] pricebookEntriesToInsert = new PricebookEntry[]{};
        pricebookEntriesToInsert.add((PricebookEntry) testFactory.createSObject(new PricebookEntry(Pricebook2Id=priceBookId,
        Product2Id=productsToInsert[0].Id,UnitPrice=productsToInsert[0].ProductCost__c)));
        insert pricebookEntriesToInsert;

        /*
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
        */
       



        
    }
    @isTest
    static void successfulTest() {
        makeOrder();
    }
    @isTest
    static void lackOfParametersTest(){

        delete [SELECT Id FROM Tax__c];
        try{
            makeOrder();
            System.Assert(false);
        }
        catch(Exception e){
            System.Assert(true);
        }

    }
    @isTest
    static void unrelatedParametersTest(){
        Tax__c[] taxes = [SELECT Id, State__c FROM Tax__c];
        Shipping__c[] shipping = [SELECT Id, State__c, Country__c, City__c FROM Shipping__c];
        ProfitMargin__c[] margins = [SELECT Id, City__c, State__c, Country__c FROM ProfitMargin__c];
        States__c newState = new States__c(Name='Test',Country__c=[SELECT Id FROM Country__c LIMIT 1].Id,NameShort__c='Test');
        insert newState;
        for (Tax__c iTax:taxes){
            iTax.State__c = newState.Id;
        }
        for (Shipping__c iShipping:shipping){
            iShipping.Country__c = null;
            iShipping.City__c = null;
            iShipping.State__c = newState.Id;
        }
        for (ProfitMargin__c iMargin:margins){
            iMargin.City__c = null;
            iMargin.Country__c = null;
            iMargin.State__c = newState.Id;
        }
        try{
            update taxes;
            makeOrder();
            System.assert(false);
        }
        catch(Exception e){
            try{
                update shipping;
                makeOrder();
                System.assert(false);
            }
            catch(Exception e2){
                try{
                    update margins;
                    makeOrder();
                    System.assert(false);
                }
                catch(Exception e3){
                    System.Assert(true);
                }
            }
        }
       

    }
    @isTest
    static void bestParametersTest(){

    }
    static void makeOrder(){
        OrderItem[] orderItemsToInsert = new OrderItem[]{};
        Order order = [SELECT Id FROM Order LIMIT 1];
        PricebookEntry pricebookEntry = [SELECT Id, UnitPrice FROM PricebookEntry LIMIT 1];
        orderItemsToInsert.add(new OrderItem(OrderId=order.Id,PricebookEntryId=pricebookEntry.Id,Quantity=1,UnitPrice=pricebookEntry.UnitPrice));
        insert orderItemsToInsert; //inserts the orderItem, which goes through all the triggers
    }
}