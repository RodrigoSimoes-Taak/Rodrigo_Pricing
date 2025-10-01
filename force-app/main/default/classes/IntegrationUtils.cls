public with sharing class IntegrationUtils {
	public static Boolean SYSTEM_DEBUG_ENABLED   = true;

	public static Boolean checkEmptyString(Object value) {
		return ((value == null || value == '' || value == 'null') ? true : false);
	}
	
	// Records upsert validation, adding results to the response list
	public static Boolean upsertRecords(List<Database.UpsertResult> upsertResults, List<DataIntegrationFields.ResponseParent> responseList,
										List<SObject> sobjectListToUpsert, Schema.SObjectField field) {
		Boolean hasError = false;
		for (DataIntegrationFields.Response response : responseList) hasError = response.hasError;

		for (Integer i = 0; i < upsertResults.size(); i++) {
			DataIntegrationFields.ResponseParent responseData = new DataIntegrationFields.ResponseParent();
			SObject sobjectResult = sobjectListToUpsert[i];
			Database.UpsertResult upsertResult = upsertResults[i];

			if (upsertResult.isSuccess()) {
				responseData.success(
					upsertResult.getId(),
					String.valueOf(sobjectResult.get(field)),
					String.valueOf(sobjectResult.getSObjectType())
				);
			}
			else {
				responseData.error(
					String.valueOf(sobjectResult.get(field)),
					upsertResult.getErrors()[0].getMessage().replace('Campos obrigatórios ausentes', 'Valor inválido para o campo obrigatório'),
					String.valueOf(sobjectResult.getSObjectType())
				);

				hasError = true;
			}

			responseList.add(responseData);
		}

		return hasError;
	}

	// Child records upsert validation, adding results to the response list
	public static void upsertChildRecords(List<Database.UpsertResult> upsertResults, Map<String, List<DataIntegrationFields.Response>> responseMap,
											List<SObject> sobjectListToUpsert, Map<String, String> parentExternalIdToChild, Schema.SObjectField field) {
		for (Integer i = 0; i < upsertResults.size(); i++) {
			DataIntegrationFields.Response responseData = new DataIntegrationFields.Response();
			SObject objectResult = sobjectListToUpsert[i];
			Database.UpsertResult upsertResult = upsertResults[i];

			if (upsertResult.isSuccess()) {
				responseData.success(
					upsertResult.getId(),
					String.valueOf(objectResult.get(field)),
					String.valueOf(objectResult.getSObjectType())
				);
			}
			else {
				responseData.error(
					String.valueOf(objectResult.get(field)),
					upsertResult.getErrors()[0].getMessage().replace('Campos obrigatórios ausentes', 'Valor inválido para o campo obrigatório'),
					String.valueOf(objectResult.getSObjectType())
				);
			}

			String responseKey = parentExternalIdToChild.get((String)objectResult.get(field));
			// Associating child object's response with object response
			if (!responseMap.containsKey(responseKey))
				responseMap.put(responseKey, new List<DataIntegrationFields.Response>());
			responseMap.get(responseKey).add(responseData);
		}
	}
	

    // Standard Http Request response
    public class RequestResponseObject {
        // Response object, in case the callout was successful.
        public HttpResponse response;
        // Boolean that determines if there is an exception or a HttpResponse.
        public Boolean success;
        // Exception object, in case there is any.
        public Exception exceptionObject;

        public RequestResponseObject(HttpResponse response){
            this.success = true;
            this.response = response;
            this.exceptionObject = null;
        }

        public RequestResponseObject(Exception ex){
            this.success = false;
            this.response = null;
            this.exceptionObject = ex;
        }
    }

    
    // CALLOUT STANDARD RESPONSE OUTTER CLASS
    public class CalloutResponse{
		public CalloutOrder.ResponseParameters parsedResponse;
		public Boolean success;
		public String errorMessage;

		public CalloutResponse(CalloutOrder.ResponseParameters response){
			this.success = true;
			this.errorMessage = '';
			this.parsedResponse = response;
		}

		public CalloutResponse(String errorMessage){
			this.success = false;
			this.errorMessage = errorMessage;
			this.parsedResponse = null;
		}

        public CalloutResponse(String errorMessage, CalloutOrder.ResponseParameters response){
			this.success = false;
			this.errorMessage = errorMessage;
			this.parsedResponse = response;
		}
	}
    // CALLOUT PARSING INNER INTERFACE
    public interface CalloutResponseParsedData{}

    public static RequestResponseObject executeCallout(String namedCredential, String payload, Map<String, String> requestHeaders){
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        // Timeout reduced in 10000 miliseconds in order to avoid timeouts in invoke actions through javascript.
        request.setTimeout(110000);
        request.setEndpoint(namedCredential);
        request.setBody(payload);

        
        if (requestHeaders != null && requestHeaders.size() > 0){
            for (String headerKey : requestHeaders.keySet()){
                request.setHeader(headerKey, requestHeaders.get(headerKey));
            }
        }

        Long microtime = (Datetime.now()).getTime();
        if (SYSTEM_DEBUG_ENABLED){
            System.debug('EXECUTING WITH NAMED CREDENTIAL: '+namedCredential);
            System.debug('METHOD USED: '+request.getMethod());
            System.debug('SENT PAYLOAD: '+payload);
            System.debug('SENT HEADERS: '+JSON.serializePretty(requestHeaders));
        }

        HttpResponse response;
        try {
            response = (new Http()).send(request);

            if (SYSTEM_DEBUG_ENABLED){
                System.debug('RESPONSE IN '+((Datetime.now()).getTime() - microtime));
                System.debug('RESPONSE STATUS: '+response.getStatus()+' - '+String.valueOf(response.getStatusCode()));
                for (String headerKey : response.getHeaderKeys()){
                    if (String.isNotBlank(headerKey)) System.debug('HEADER KEY: '+headerKey+' | VALUE: '+response.getHeader(headerKey));
                }

                System.debug('RESPONSE BODY: '+response.getBody());
            }

            return new RequestResponseObject(response);
        } catch (Exception ex) {
            if (SYSTEM_DEBUG_ENABLED) System.debug('CALLOUT EXCEPTION: '+ex.getMessage());

            return new RequestResponseObject(ex);
        }
    }
	public static Id WSLog(String integrationName, String recordTypeName, String payloadIN, String payloadOUT, Boolean hasAnyErrors){
        System.debug('ON WS LOG: '+integrationName);

        Boolean shouldUseAttachmentIN  = (payloadIN.length() > 100000);
        Boolean shouldUseAttachmentOUT = (payloadOUT.length() > 100000);

        Datetime tNow = System.now();

        ID rType = Schema.SObjectType.IntegrationLog__c.getRecordTypeInfosByDeveloperName().containsKey(recordTypeName) ? Schema.SObjectType.IntegrationLog__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId() : null;
		
        if (rType == null){
            System.debug('FAILED TO GET RECORDTYPE FROM LIST');
        }
        IntegrationLog__c log = new IntegrationLog__c(
            // RecordTypeId      = rType,
            Name    = integrationName,
            Attachment__c = (shouldUseAttachmentIN || shouldUseAttachmentOUT),
            PayloadIN__c     = (shouldUseAttachmentIN  ? '' : payloadIN),
            PayloadOUT__c    = (shouldUseAttachmentOUT ? '' : payloadOUT),
            Status__c         = (hasAnyErrors ? 'ERROR' : 'OK')
        );

        try{
            insert log;

            // Maximum Size for a String
            if (shouldUseAttachmentIN){
            	createAttachment(log.Id, integrationName, 'IN', log.Name, String.valueOf(tNow), payloadIN);
            }

            if (shouldUseAttachmentOUT){
            	createAttachment(log.Id, integrationName, 'OUT', log.Name, String.valueOf(tNow), payloadOUT);
            }

            System.debug('NEW LOG CREATED: '+log.Id);
        }catch(Exception e){
            System.debug('EXCEPTION ON LOG - Please review parameters - '+e.getMessage()+' - '+e.getStackTraceString());
        }

        return log.id;
    }

    @TestVisible
    private static void createAttachment(String recordId, String integrationName, String inOrOut, String logName, String timeAsString, String payload){
    	Attachment att = new Attachment();
    	att.Name = 'LOG-'+integrationName+'-'+inOrOut+'-'+timeAsString+'.txt';
    	att.Body = Blob.valueOf(payload);
    	att.ParentId = recordId;
    	insert att;
    }
}
