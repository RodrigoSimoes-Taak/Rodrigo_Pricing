public with sharing class IntegrationLog {
	String integrationName;
	String externalIdList;
	String recordTypeName;
	public String payloadIN;
	public String payloadOUT;
	public String endpoint;
	public Boolean hasAnyErrors;
	public Boolean hasDeleted;
    Boolean attachmentIN;
    Boolean attachmentOUT;
    Datetime datetimeNow;
    Id recordTypeId;
    public IntegrationLog reset(){
        this.integrationName = '';
        this.externalIdList = '';
        this.recordTypeName = '';
        this.payloadIN = '';
        this.payloadOUT = '';
        this.endpoint = '';
        this.hasAnyErrors = false;
        this.hasDeleted = false;
        this.attachmentIN = false;
        this.attachmentOUT = false;
        return this;
    }
	public IntegrationLog setIntegrationName(String integrationName){
		this.integrationName = integrationName;
		return this;
	}

	public IntegrationLog setExternalIdList(String externalIdList){
		this.externalIdList = externalIdList;
		return this;
	}

	public IntegrationLog setRecordTypeName(String recordTypeName){
		this.recordTypeName = recordTypeName;
		return this;
	}

	public IntegrationLog setPayloadIN(String payloadIN){
		this.payloadIN = payloadIN;
		return this;
	}

	public IntegrationLog setPayloadOUT(String payloadOUT){
		this.payloadOUT = payloadOUT;
		return this;
	}

	public IntegrationLog setEndpoint(String endpoint){
		this.endpoint = endpoint;
		return this;
	}

	public IntegrationLog setHasAnyErrors(Boolean hasAnyErrors){
		this.hasAnyErrors = hasAnyErrors;
		return this;
	}

	public IntegrationLog setHasDeleted(Boolean hasDeleted){
		this.hasDeleted = hasDeleted;
		return this;
	}
    public Id build(){
        return createLog();
    }

	private Id createLog(){
		//System.debug('');
		// Se os dados forem maiores que 100.000 TRUE, se não FALSE
		attachmentIN = (payloadIN.length() > 130000);
	    attachmentOUT = (payloadOUT.length() > 130000);
		datetimeNow = System.now(); // Data Atual
		// Pega Id do log de integração (IN ou OUT)
		recordTypeId = Schema.SObjectType.IntegrationLog__c.getRecordTypeInfosByDeveloperName().containsKey(recordTypeName) ?
							Schema.SObjectType.IntegrationLog__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId()
							: null;

		if (recordTypeId == null) System.debug('Falha ao pegar o recordTypeId do log de integração => ' + recordTypeId);

		IntegrationLog__c log = createIntegrationLogRecord();

		try { // Insere o log de integração e cria anexo se for necessario
			insert log;

			// Confere se é necessario criar anexo
			if (attachmentIN) createAttachment(log, 'IN', payloadIN);
			if (attachmentOUT) createAttachment(log, 'OUT', payloadOUT);
		}
		catch (Exception error) {
			System.debug('EXCEPTION ON LOG - Please review parameters - ' + error.getMessage() + ' - ' + error.getStackTraceString());
			log.Status__c = 'Error';
			log.ErrorMessage__c = error.getMessage();
		}

		return log.Id;
	}
    
	private IntegrationLog__c createIntegrationLogRecord() {
		return new IntegrationLog__c(
			Name = integrationName + ' ' + recordTypeName,
			Endpoint__c = endpoint,
			ExternalIdList__c = externalIdList.length() > 255 ? externalIdList.substring(0, 256) : externalIdList,
			RecordTypeId = recordTypeId,
			Attachment__c = (attachmentIN || attachmentOUT),
			PayloadIN__c = (attachmentIN  ? '' : payloadIN),
			PayloadOUT__c = (attachmentOUT ? '' : payloadOUT),
			ExecutionDate__c = datetimeNow,
			Status__c = (hasAnyErrors ? 'Error' : 'Success'),
			ErrorMessage__c = '',
			HasDeleted__c = hasDeleted
		);
	}

	
	private Id createAttachment(IntegrationLog__c log, String inOrOut, String payload){
		Attachment attachment = new Attachment(
			Name = 'LOG-' + log.Name + '-' + inOrOut + '-' + String.valueOf(datetimeNow) + '.txt',
			Body = Blob.valueOf(payload),
			ParentId = log.Id
		);

		insert attachment;

		return attachment.Id;
	}
}
