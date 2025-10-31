
public with sharing class OrderCalloutMockSuccess implements HttpCalloutMock {

    public static HttpResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        String responseBody =   '{"OrderItem":[{"sObjectType":"OrderItem","salesforceId":"802fj0000091lseAAA" '+
                                ',"hasError":false,"externalCode":"01","errorMessage":""}]'+
                                ',"Order":[{"sObjectType":"Order","salesforceId":"801fj00000Lxc5DAAR"'+
                                ',"hasError":false,"externalCode":"0000101","errorMessage":""}]}';
        response.setBody(responseBody);
        response.setStatusCode(200);
        return response;
    }
}