public with sharing class IntegrationUtils {
    public static HttpResponse sendRequest(Object requestContent,String requestURL){
        
        HttpRequest request = new HttpRequest();
        request.setBody(JSON.serialize(requestContent));
        request.setEndpoint(requestURL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json'); // Set Content-Type header
        HttpResponse response = new Http().send(request);
        return response;
    }
    public static Boolean isResponseOk(HttpResponse response){
        return response.getStatusCode() == 200;
    }
}