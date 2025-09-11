public with sharing class TemplateDefaultFields {
	public interface FieldDefaults {
		Map<String, Object> getFieldDefaults(Decimal countSObjectCreated);
	}

	
    




	public class AccountDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Account - Teste ' + String.valueOf(countSObjectCreated)
			};
		}
	}

	public class ContactDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'LastName' => 'Contact - Teste ' + String.valueOf(countSObjectCreated),
                'Name__c'=> 'NomeTeste',
                'LastName__c' => 'SobrenomeTeste',
                'Phone__c'=>'1234',
                'MobilePhone__c'=>'1234',
                'Email'=>'emailteste@mail.com'
			};
		}
	}


	

	public class OrderDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
                'Status'=>'Draft',
				'EffectiveDate' => Date.today().addDays(1),
                'ShippingType__c' => 'CIF',
                'DeliveryDate__c' => Date.today().addDays(2)
			};
		}
	}
	public class Product2Defaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Product2 Test ' + String.valueOf(countSObjectCreated),
				'IsActive' => true,
                'ProductCode__c'=>String.valueOf(countSObjectCreated),
                'ProductCost__c'=>5
			};
		}
	}

	public class PricebookEntryDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'IsActive' => true
			};
		}
	}

	public class PaymentConditionDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
                'Name' => 'Payment Condition Test ' + String.valueOf(countSObjectCreated),
				'Code__c' => String.valueOf(countSObjectCreated)
			};
		}
	}
    
    //vv modificacoes especificas para Pricing
    public class TaxDefaults implements FieldDefaults{//finished
        public Map<String,Object> getFieldDefaults(Decimal countSObjectCreated){
            return new Map<String,Object>{
                'Name'=>'Tax'+String.valueOf(countSObjectCreated),
                'Status__c'=>'Aprovado',
                'TaxOnCost__c' => 20
            };
        }
    }
    public class ShippingDefaults implements FieldDefaults{//finished
        public Map<String,Object> getFieldDefaults(Decimal countSObjectCreated){
            return new Map<String,Object>{
                'Name'=>'Shipping'+String.valueOf(countSObjectCreated),
                'Status__c'=>'Aprovado',
                'Value__c'=>20

            };
        }
    }
    public class ProfitMarginDefaults implements FieldDefaults{//finished
        public Map<String,Object> getFieldDefaults(Decimal countSObjectCreated){
            return new Map<String,Object>{
                'Name'=>'Profit'+String.valueOf(countSObjectCreated),
                'Status__c'=>'Aprovado',
                'MarginPercentage__c'=>20
            };
        }
    }
    public class CityDefaults implements FieldDefaults{ //finished
        public Map<String,Object> getFieldDefaults(Decimal countSObjectCreated){
            return new Map<String,Object>{
                'Name'=>'City'+String.valueOf(countSObjectCreated),
                'IBGECode__c'=> String.valueOf(countSObjectCreated)
            };
        }
    }
    public class StatesDefaults implements FieldDefaults{ //finished
        public Map<String,Object> getFieldDefaults(Decimal countSObjectCreated){
            return new Map<String,Object>{
                'Name'=>'State'+String.valueOf(countSObjectCreated),
                'NameShort__c' => 'S'+String.valueOf(countSObjectCreated)
            };
        }
    }
    public class CountryDefaults implements FieldDefaults{ //finished
        public Map<String,Object> getFieldDefaults(Decimal countSObjectCreated){
            return new Map<String,Object>{
                'Name'=>'Country'+String.valueOf(countSObjectCreated),
                'NameShort__c' => 'CR'+String.valueOf(countSObjectCreated)
            };
        }
    }
    public class AccountGroupDefaults implements FieldDefaults{ //finished
        public Map<String,Object> getFieldDefaults(Decimal countSObjectCreated){
            return new Map<String,Object>{
                'Name' => 'Account Group Test ' + String.valueOf(countSObjectCreated),
                'Code__c'=> String.valueOf(countSObjectCreated)
                
            };
        }
    }
    public class AccountAddressDefaults implements FieldDefaults{//finished
        public Map<String,Object> getFieldDefaults(Decimal countSObjectCreated){
            return new Map<String,Object>{
                'Name' => 'Account Address Test ' + String.valueOf(countSObjectCreated),
                'Code__c'=> String.valueOf(countSObjectCreated),
                'Neighborhood__c'=>'Neighborhood'+String.valueOf(countSObjectCreated),
                'Address__c'=>'Address'+String.valueOf(countSObjectCreated),
                'CEP__c'=>'CEP'+String.valueOf(countSObjectCreated)
                

            };
        }
    }
    public class ContractDefaults implements FieldDefaults{
        public Map<String,Object> getFieldDefaults(Decimal countSObjectCreated){
            return new Map<String,Object>{
                'StartDate'=> Date.today(),
                'ContractTerm'=>12
                
                
            };
        }
    }
    public class DistributionCenterDefaults implements FieldDefaults{//finished
        public Map<String,Object> getFieldDefaults(Decimal countSObjectCreated){
            return new Map<String,Object>{
                'Name'=>'Distribution Center Test ' + String.valueOf(countSObjectCreated),
                'Code__c'=> String.valueOf(countSObjectCreated)
            };
        }
    }
    public class ProductHierarchyDefaults implements FieldDefaults{//finished
        public Map<String,Object> getFieldDefaults(Decimal countSObjectCreated){
            return new Map<String,Object>{
                'Name'=>'Product Hierarchy Test ' + String.valueOf(countSObjectCreated),
                'Code__c'=> String.valueOf(countSObjectCreated)
            };
        }
    }
    
}