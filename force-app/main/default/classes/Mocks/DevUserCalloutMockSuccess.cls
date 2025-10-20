public with sharing class DevUserCalloutMockSuccess implements HttpCalloutMock {
    public static HttpResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        String responseBody =   
        '{'+
        '   "id": 192711408,'+
        '   "bio": "Teste, teste",'+
        '   "type": "User"'+
        '}'
        
        
        ;
        response.setBody(responseBody);
        response.setStatusCode(200);
        return response;
    }
}