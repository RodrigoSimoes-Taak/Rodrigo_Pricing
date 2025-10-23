public with sharing class JSONErrorCatcher {
    public static String catchJSONError(Exception e){
        String[] lines = RestContext.request.requestBody.toString().split('\n');
        Pattern getLine = Pattern.compile('line:(\\d+)');
        Matcher match = getLine.matcher(e.getMessage());
        if (match.find()){
            System.debug('Teste '+match.group(1));
            System.debug('Teste2 '+lines[Integer.valueOf(match.group(1))-1]);
        }
        return 'Error! Line ' +lines[Integer.valueOf(match.group(1))-1]+' Should be a string!';
    }
}