public with sharing class RST_TimedCSV_Controller {
    /*
    @AuraEnabled
    public static Object processCSVLines(string fileUploadId){
        return RST_Controller.processCSVLines(fileUploadId);
    }

    @AuraEnabled
    public static Object processCSVFile(string fileUploadId){
        return RST_Controller.processCSVforFile(fileUploadId);
    }
	*/
    /*
    @AuraEnabled
    public static Object receiveCSVFile(String myBase64File) {
        system.debug('got to controller');
        
        Blob decodedBlob = EncodingUtil.base64Decode(myBase64File);
        String result = decodedBlob.toString();
        
        
        String myFile = EncodingUtil.urlDecode(myBase64File, 'UTF-8');
        system.debug('myFile');
        system.debug(myFile);
        
		return RST_Controller.readCSV_String(myFile);

    }
	*/
}