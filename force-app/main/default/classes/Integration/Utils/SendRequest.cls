public with sharing class SendRequest {
    public static HttpResponse sendPOSTRequestJSONBody(Object requestContent,String requestURL){
        HttpRequest request = new HttpRequest();
        request.setBody(JSON.serialize(requestContent));
        request.setEndpoint(requestURL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json'); // Set Content-Type header
        HttpResponse response = new Http().send(request);
        return response;
    }
    public static HttpResponse sendGETRequestEmptyBody(String requestURL){
        HttpRequest request = new HttpRequest();
        request.setEndpoint(requestURL);
        request.setMethod('GET');
        HttpResponse response = new Http().send(request);
        return response;
    }
}