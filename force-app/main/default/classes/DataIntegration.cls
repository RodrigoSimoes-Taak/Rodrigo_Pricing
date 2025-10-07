public with sharing class DataIntegration {
    public class Response{
        public String salesforceId;
        public String externalCode;
        public Boolean hasError;
        public String errorMessage;
        public String sObjectType;
        public Response(String Id,String ExternalId,String errorMessage,String sObjectType){
            this.salesforceId = Id;
            this.externalCode = ExternalId;
            this.errorMessage = errorMessage;
            if (this.errorMessage == '' || this.errorMessage == null){//if errorMessage is empty/null, no error!
                this.hasError = false;
            }
            else{
                this.hasError = true;
            }
            
            
            this.sObjectType = sObjectType;
        }
    }
}