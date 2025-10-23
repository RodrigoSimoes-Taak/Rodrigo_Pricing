public with sharing class EvaluateResponseCode {
    public static Boolean isResponseOk(HttpResponse response){
        return response.getStatusCode() == 200;
    }
    public static Boolean isJSONMalformat(HttpResponse response){
        return response.getStatusCode() == 400;
    }
}