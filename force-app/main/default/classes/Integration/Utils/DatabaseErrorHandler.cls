public with sharing class DatabaseErrorHandler {
    public static String getUpsertErrorMessage(Database.UpsertResult upsertResult){
        String errorMessage = '';
        if (!upsertResult.isSuccess()){ 
            for (Database.Error iError: upsertResult.getErrors()){
                    errorMessage += iError.getStatusCode()+ ' - '+ iError.getMessage();
            }
                    
        }
        return errorMessage;
    }
}