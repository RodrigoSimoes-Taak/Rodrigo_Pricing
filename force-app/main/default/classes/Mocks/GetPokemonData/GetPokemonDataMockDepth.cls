public with sharing class GetPokemonDataMockDepth implements HttpCalloutMock {
    public static HttpResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        String responseBody =   '{"count": 1,'+
                                '"next": "https://pokeapi.co/api/v2/pokemon",'+
                                '"previous": null,'+
                                '"results": ['+
                                ' {'+
                                '   "name": "bulbasaur",'+
                                '   "url": "https://pokeapi.co/api/v2/pokemon/1/"'+
                                ' }'+
                                ']'+
                                '}';
        response.setBody(responseBody);
        response.setStatusCode(200);
        return response;
    }
}