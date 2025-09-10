public with sharing class TemplateDefaultFields {
	public interface FieldDefaults {
		Map<String, Object> getFieldDefaults(Decimal countSObjectCreated);
	}

	public class UserDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Username' => 'test' + Datetime.now().getTime() +'@test.com',
				'LastName' => 'taak',
				'Email' => 'test@taak.com',
				'Alias' => 'ttst',
				'CommunityNickname' => 'ttst',
				'TimeZoneSidKey' => 'America/Sao_Paulo',
				'LocaleSidKey' => 'pt_BR',
				'EmailEncodingKey' => 'ISO-8859-1',
				'LanguageLocaleKey' => 'pt_BR',
				'IsActive' => true
			};
		}
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

	public class AssetDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Asset - Teste ' + String.valueOf(countSObjectCreated)
			};
		}
	}

	public class WarrantyTermDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'WarrantyTermName' => 'WarrantyTerm - Teste ' + String.valueOf(countSObjectCreated),
				'WarrantyDuration' => 1000,
				'WarrantyType' => 'Padrão',
				'WarrantyUnitOfTime' => 'Months',
				'EffectiveStartDate' => 'Data da instalação',
				'IsActive' => true
			};
		}
	}

	public class AssetWarrantyDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'StartDate' => Date.today().addDays(-1)
			};
		}
	}

	public class CaseDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Origin' => 'WhatsApp',
				'Status' => 'InService'
			};
		}
	}

	public class SLAControlDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'ExternalId__c' => 'ExternalId__c ' + String.valueOf(countSObjectCreated),
				'SlaInMinutes__c' => 100
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

	public class OrderItemDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
			};
		}
	}

	public class ProblemDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Subject' => 'Problem Test',
				'Urgency' => 'Low',
				'Impact' => 'Low',
				'Priority' => 'Low',
				'Status' => 'New'
			};
		}
	}

	public class OrderProblemDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{};
		}
	}

	public class WorkOrderDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
			};
		}
	}

	public class ServiceAppointmentDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
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

	public class ProductRequestDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
			};
		}
	}

	public class ProductRequestLineItemDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'QuantityRequested' => 1
			};
		}
	}

	public class CarrierDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'ExternalId__c' => 'Carrier Test ' + String.valueOf(countSObjectCreated)
			};
		}
	}

	public class TransactionDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'ExternalId__c' => 'Transaction Test ' + String.valueOf(countSObjectCreated)
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
    
	public class FormDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
			};
		}
	}

	public class TaskDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Priority' => 'Low',
				'Subject' => 'Task Test ' + String.valueOf(countSObjectCreated),
				'StartDate__c' => Date.today().addDays(1),
				'EndDate__c' => Date.today().addDays(5)
			};
		}
	}

	public class EventDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Subject' => 'Email',
				'StartDate__c' => Date.today().addDays(1),
				'EndDate__c' => Date.today().addDays(5)
			};
		}
	}

	public class EventTypeDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Event Type Test ' + String.valueOf(countSObjectCreated),
				'IsActive__c' => true
			};
		}
	}

	public class QuestionDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Description__c' => 'Question Test ' + String.valueOf(countSObjectCreated),
				'ExternalId__c' => 'Question Test ' + String.valueOf(countSObjectCreated)
			};
		}
	}

	public class AnswerDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'ExternalId__c' => 'Answer Test ' + String.valueOf(countSObjectCreated)
			};
		}
	}

	public class InvoiceNoteDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Invoice Note Test ' + String.valueOf(countSObjectCreated),
				'IssueDate__c' => Date.today()
			};
		}
	}

	public class InvoiceNoteLineItemDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'AssetManufactureDate__c' => Date.today().addDays(1),
				'Quantity__c' => 10,
				'AssetSerialNumber__c' => 'Test' + String.valueOf(countSObjectCreated)
			};
		}
	}

	public class TravelDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{};
		}
	}

	public class OpportunityDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Opportunity Test ' + String.valueOf(countSObjectCreated),
				'StageName' => 'Qualification',
				'CloseDate' => Date.today().addDays(1)
			};
		}
	}

	public class OpportunityLineItemDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{};
		}
	}

	public class LeadDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'LastName' => 'Lead Test ' + String.valueOf(countSObjectCreated),
				'Company' => 'Lead Company Test ' + String.valueOf(countSObjectCreated),
				'Status' => 'New'
			};
		}
	}

	public class CatalogStructureDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'CatalogStructure Test ' + String.valueOf(countSObjectCreated)
			};
		}
	}

	public class StructureDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Structure Test ' + String.valueOf(countSObjectCreated),
				'Year__c' => '2024',
				'ExternalId__c' => 'Structure Test ' + String.valueOf(countSObjectCreated)
			};
		}
	}

	public class StructureSectionDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Structure Test ' + String.valueOf(countSObjectCreated),
				'ExternalId__c' => 'Structure Section Test ' + String.valueOf(countSObjectCreated)
			};
		}
	}

	public class StructureSectionItemDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Structure Test ' + String.valueOf(countSObjectCreated),
				'ExternalId__c' => 'Structure Section Item Test ' + String.valueOf(countSObjectCreated)
			};
		}
	}

	public class LocationDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Location Test ' + String.valueOf(countSObjectCreated)
			};
		}
	}

	public class AssociatedLocationDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Associated Location Test ' + String.valueOf(countSObjectCreated)
			};
		}
	}

	public class QuoteDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Quote Test ' + String.valueOf(countSObjectCreated)
			};
		}
	}

	public class QuoteLineItemDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
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