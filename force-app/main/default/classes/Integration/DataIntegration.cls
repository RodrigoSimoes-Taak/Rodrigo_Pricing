public with sharing class DataIntegration {
    public class Response{
        public String salesforceId= '';
        public String externalCode = '';
        public Boolean hasError = false;
        public String errorMessage = '';
        public String sObjectType;
        public Response setSalesforceId( String salesforceId){
            this.salesforceId = salesforceId;
            return this;
        }
        public Response setExternalCode(String externalCode){
            this.externalCode = externalCode;
            return this;
        }
        public Response setErrorMessage(String errorMessage){
            this.errorMessage = errorMessage;
            if (errorMessage != ''){
                this.hasError = true;
            }
            return this;
        }
        public Response setSObjectType(String sObjectType){
            this.sObjectType = sObjectType;
            return this;
        }
        
        
    }
}