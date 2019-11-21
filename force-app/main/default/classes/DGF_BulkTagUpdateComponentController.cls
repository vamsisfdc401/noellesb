/*****************************************************************************************
Class Name: DGF_BulkTagUpdateComponentController
Purpose: Controller for bulk updating tags
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             03/07/2017           Mohit                    Initial Development
******************************************************************************************/
public with Sharing class DGF_BulkTagUpdateComponentController{ 
    
    /***********************************
    Method Name: fetchRecordDetails
    Purpose: method to fetch detials of searched record
    ***********************************/
    @AuraEnabled public static List<sObject> fetchRecordDetails(String searchKeyWord, string frmDt, string toDt, string objectType, string actionType,string selectField) {
        try {
            //intializing
            List<sObject> lstRecordDetails = new List<sObject>();
            List<sObject> filmRecordDetails=new List<sobject>();
            List<sobject> tvOrBundleProdDetails=new list<sobject>();
            String filmRecType = DGF_Constants.FILM;
            String tvRecType = DGF_Constants.TV;
            String bundleRecType = DGF_Constants.BUNDLE;
            String SOQL = '';
            Date fromDate;
            Date toDate;
            
            //setting from date
            if (frmDt != null && frmDt != '') {
                fromDate = Date.ValueOf(frmDt);
            }
            
            //setting to date
            if (toDt != null && toDt != '') {
                toDate = Date.ValueOf(toDt);
            }
            
            //storing search key word in a variable
            String searchKey = '%' + searchKeyWord + '%';
            
            //for title search
            if (objectType == 'Title') {
                SOQL = 'Select id, name, Tags__c, Insert_Date__c, MPAA_Rating__c, Genre_Primary__c, Initial_Release_Air_Year__c from Title__c where ';
                
                if (selectField == 'Name') {
                    SOQL = SOQL + ' Name like : searchKey ';
                }
                else if (selectField == 'Tag') {
                    SOQL = SOQL + ' Tags__c like : searchKey ';
                }
                else if (selectField == 'MPAA Rating') {
                    SOQL = SOQL + ' MPAA_Rating__c like : searchKey ';
                }
                else if (selectField == 'Genre') {
                    SOQL = SOQL + ' Genre_Primary__c like : searchKey ';
                }
                else if (selectField == 'Initial Release Air year') {
                    SOQL = SOQL + ' Initial_Release_Air_Year__c like : searchKey ';
                }               
                
                //if from date is entered
                if (string.valueOf(fromDate) != null && string.valueOf(fromDate) != '' && actionType == 'filter') {
                    SOQL = SOQL + ' AND Insert_Date__c >=: fromDate';
                }
                
                //if to date is entered
                if (string.valueOf(toDate) != null && string.valueOf(toDate) != '' && actionType == 'filter') {
                    SOQL = SOQL + ' AND Insert_Date__c <=: toDate';
                }               
            }
            //for product search
            else if (objectType == 'Product') {
                //query for Film RecordType
                SOQL = 'Select id,name,Tags__c,Digital_Release__r.US_EST_Date__c,HE_US_Rating__c,HE_Primary_Genre__c,HE_Secondary_Genre__c,HE_Tertiary_Genre__c,Franchise__c    from Product__c where ';                
                
                if (selectField == 'Name') {
                    SOQL = SOQL + ' Name like : searchKey ';
                }
                else if (selectField == 'Tag') {
                    SOQL = SOQL + ' Tags__c like : searchKey ';
                }
                else if (selectField == 'He US Rating') {
                    SOQL = SOQL + ' HE_US_Rating__c like : searchKey ';
                }
                else if (selectField == 'Genre') {
                    SOQL = SOQL + ' (HE_Primary_Genre__c like : searchKey OR HE_Secondary_Genre__c like : searchKey OR HE_Tertiary_Genre__c like : searchKey) ';
                }
                else if (selectField == 'Franchise') {
                    SOQL = SOQL + ' Franchise__c like : searchKey ';
                }
                
                //Filter using US EST Date only for Film RecordType                
                //if from date is entered                
                if (string.valueOf(fromDate) != null && string.valueOf(fromDate) != '' && actionType == 'filter') {
                    SOQL = SOQL + ' AND ((recordtype.Name = : filmRecType AND Digital_Release__r.US_EST_Date__c >=: fromDate) OR (recordtype.Name = : tvRecType AND Digital_Release__r.US_EST_Launch_Date__c >=: fromDate) OR (recordtype.Name = : bundleRecType AND Digital_Release__r.US_Bundle_Avail_Date__c >=: fromDate)) ';
                }
                
                //if to date is entered
                if (string.valueOf(toDate) != null && string.valueOf(toDate) != '' && actionType == 'filter') {
                    SOQL = SOQL + ' AND ((recordtype.Name = : filmRecType AND Digital_Release__r.US_EST_Date__c <=: toDate) OR (recordtype.Name = : tvRecType AND Digital_Release__r.US_EST_Launch_Date__c <=: toDate) OR (recordtype.Name = : bundleRecType AND Digital_Release__r.US_Bundle_Avail_Date__c <=: toDate)) ';
                }                  
            }
            //for promotion search
            else if (objectType == 'Promotion') {
                SOQL = 'Select id, name, Tags__c  from Promotion__c where ';
                
                if (selectField == 'Name') {
                    SOQL = SOQL + ' Name like : searchKey ';
                }
                else if (selectField == 'Tag') {
                    SOQL = SOQL + ' Tags__c like : searchKey ';
                }
                
                //if from date is entered
                if (string.valueOf(fromDate) != null && string.valueOf(fromDate) != '' && actionType == 'filter') {
                    SOQL = SOQL + ' AND Start_Date__c >=: fromDate';
                }
                
                //if to date is entered
                if (string.valueOf(toDate) != null && string.valueOf(toDate) != '' && actionType == 'filter') {
                    SOQL = SOQL + ' AND Start_Date__c <=: toDate';
                }   
            }
            
            //SOQL not null
            if (SOQL != null && SOQL != '') {
                //executing SOQL 
                SOQL = SOQL + ' Limit 10000 ';
                lstRecordDetails = Database.Query(SOQL);
            }
            
            //returning the list of records
            if (!lstRecordDetails.isEmpty()) {
                return lstRecordDetails;
            }
            
            return null;
        }
        catch (exception ex) { 
            throw new AuraHandledException(ex.getMessage());
            return null;
        }   
    }
    
    /***********************************
    Method Name: updateRecordDetails
    Purpose: update tag field
    ***********************************/
    @AuraEnabled public static string updateRecordDetails(String recordSet, string tag, string objectType, string existingTag, string operationType) {
        try{
            //intializing list
            List<sObject> updateRecords = new List<sObject>();
            string tempTags;
            
            //deserializing for title
            if(objectType == 'Title'){
                updateRecords = (List<Title__c>)System.JSON.deserialize(recordSet,List<Title__c>.class);
            }
            //deserializing for product
            else if(objectType == 'Product'){
                updateRecords = (List<Product__c>)System.JSON.deserialize(recordSet,List<Product__c>.class);
            }
            //deserializing for promotion
            else if(objectType == 'Promotion'){
                updateRecords = (List<Promotion__c>)System.JSON.deserialize(recordSet,List<Promotion__c>.class);
            }
            
            //looping over record list
            for (integer i = 0; i < updateRecords.size(); i++ ) {
                //if user is adding new tags
                if (operationType == 'Add') {				
                    if (updateRecords[i].get('Tags__c') == null || updateRecords[i].get('Tags__c') == '') {
                        updateRecords[i].put('Tags__c',tag);
                    }
                    else {
                        updateRecords[i].put('Tags__c',updateRecords[i].get('Tags__c') + ',' + tag);
                    }					
                } 
                //if user is updating or removing tags
                else if (operationType == 'Update' || operationType == 'Remove') {
                    //if existing tag is null then continue
                    if (updateRecords[i].get('Tags__c') == null || updateRecords[i].get('Tags__c') == ''){
                        //updateRecords[i].put('Tags__c',tag);
                        continue;
                    }					
                    else {                                               
                        //storing tag in temp var
                        tempTags = string.valueof(updateRecords[i].get('Tags__c'));
                        
                        //if tag exists and update scenario
                        if (operationType == 'Update' && tempTags.contains(existingTag)) {
                            //updateRecords[i].put('Tags__c',tempTags.replace(existingTag, tag));
                            updateRecords[i].put('Tags__c', getNewTags(tempTags, existingTag, tag, 'Update'));
                        }
                        //if tag exists and remove scenario
                        else if (operationType == 'Remove' && tempTags.contains(tag)) {
                            //updateRecords[i].put('Tags__c',tempTags.replace(tag, ''));
                            updateRecords[i].put('Tags__c', getNewTags(tempTags, tag, null, 'Remove'));													
                        }
                    }				
                }				
            }
            
            //updating records
            if (!updateRecords.isEmpty()) {
                //update updateRecords;
                DGF_PerformDML.saveRecords(updateRecords,'update');                
            }            
            
            return null;
        }
        catch (DMLException ex) {
            throw new AuraHandledException(ex.getDmlMessage(0));
            return null;
        }
        catch (exception ex) {
            throw new AuraHandledException(ex.getMessage());
            return null;
        }   
    }
    
    /***********************************
    Method Name: getNewTags
    Purpose: method to refine tags and return
    ***********************************/
    private static string getNewTags(string actualTag, string tagToReplace, string tagToReplaceWith, string operationType) {       
        
        //declaring variables
        List<string> lstActualTags = actualTag.split(',');
        Set<string> setTagsToReplace = new Set<string>();
        string tempTag;
		boolean isUpdated = FALSE;
        
        //adding splitted values to the set
        setTagsToReplace.addall(tagToReplace.split(','));
        
        //looping over actual list
        for (integer j = 0; j < lstActualTags.size(); j++) {
            //if actual value is present in set of values to be removed
            if (!setTagsToReplace.contains(lstActualTags[j])) {				
                if (tempTag == null || tempTag == '') {
                    tempTag = lstActualTags[j].trim();
                }
                else {
                    tempTag = tempTag + ',' + lstActualTags[j].trim();
                }
            }
			else {
				isUpdated = TRUE;
			}
        }
        
        //if update operation
        if (operationType == 'Update' && isUpdated) {
            //if temp tag isnull
            if (tempTag == null || tempTag == '') {
                tempTag = tagToReplaceWith;
            }
            else {
                tempTag = tempTag + ',' +  tagToReplaceWith;
            }			
        }
        
        return tempTag;
    }
}