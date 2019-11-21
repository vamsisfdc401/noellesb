public with sharing class RST_Controller {

    @AuraEnabled
    public static ParseResults processRawCSV_Batch(string fileUploadId){
        system.debug('starting batch calls with upload id: ' + fileUploadId);
        DateTime useNow = System.now();
        //Boolean runDeleteFirst = true;
        ParseResults batchResult = new ParseResults();
        //try{
            //if(runDeleteFirst){
                Id batchprocessid = Database.executeBatch(new RST_BatchDeletePlayWeeks(fileUploadId), 100);
                batchResult.issues.add(batchprocessid);
                batchResult.issues.add('process started at ' + useNow);
            //} else {
            //    Id batchprocessid = Database.executeBatch(new RST_BatchProcess_RawCSV(fileUploadId), 100);
            //    batchResult.issues.add('process started at ' + useNow);
            //}
            
        //} catch(Exception e){
        //    batchResult.issues.add('Error running batch: ' + e.getMessage());
        //    batchResult.result = 'Error';
        //}
        return batchResult;
    }

    @AuraEnabled
    public static ParseResults processCSVLines(string fileUploadId){
        ParseResults csvResults = new ParseResults();
        //csvResults.result = 'Success';

        system.debug('process for file ' + fileUploadId);

        // get files for this record - multi step content document thing
        // 1) get the id of the document
        Id docId = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :fileUploadId][0].ContentDocumentId;
        //system.debug('doc Id ' + docId);  
        // 2) get the latest verion off the document
        ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :docId ORDER BY CreatedDate DESC LIMIT 1];

        List<String> csvLines;
        
        try{
            csvLines = CSV_Reader.parseCSVLines(cv.VersionData.toString(), false);
        } catch(Exception e){
            csvResults.issues.add('Error parsing csv file: Please ensure proper CSV file');
            csvResults.result = 'Error ' + e.getMessage();
            return csvResults;
        }
        List<RST_RawCSVLine__c> rawLines = new List<RST_RawCSVLine__c>();
        Integer lineCount = 0;
        for(String aLine : csvLines){
            system.debug(aLine);
            //RST_RawCSVLine__c newLine = new RST_RawCSVLine__c();
            rawLines.add(new RST_RawCSVLine__c(RawCSV__c = aLine, UploadId__c = fileUploadId, Is_Header__c = (lineCount == 0)));
            lineCount++;
        }
        system.debug('completed reading file; lines: ' + lineCount);
        try{
            insert rawLines;
            csvResults.issues.add('Inserted ' + lineCount + ' rows');
        } catch(Exception e){
            csvResults.issues.add('Error saving csv lines:' + e.getMessage());
            csvResults.result = 'Error';
            return csvResults;
        }

        return csvResults;
    }
    
    public class ParseResults{

        @AuraEnabled public String result {get; set;}
        @AuraEnabled public List<String> issues {get; set;}

        public ParseResults(){
            result = 'Success';
            issues = new List<String>();
        }
    }
}