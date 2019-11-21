/*****************************************************************************************
Class Name: GBSLMSIPTriggerHandler
Purpose: Handler class for GBSLMSIPTrigger
Version : 1.0
Date Created : 05/09/2018
Created By : Harsha Vardhan P
JIRA : GBS-278
******************************************************************************************/
public class GBSLMSIPTriggerHandler {
    /********************************************************
    Method Name: setIPNamesOnLMS
    Purpose: Method to stamp selected IPs on LMS
    Parameters: Map<Id, GBS_LMS_IP__c>
    Return Type: void
    *********************************************************/ 
    public static void setIPNamesOnLMS(Map<Id, GBS_LMS_IP__c> LMSIPs) {
        Set<Id> LMSIds = new Set<Id>();
        Map<Id, String> LMSIdToIPsMap = new Map<Id, String>();
        List<LMS__c> LMSRecordsToUpdate = new List<LMS__c>();
        
        //  Collect LMS Ids from LMS IPs
        for(GBS_LMS_IP__c LMSIP : LMSIPs.values()) {
            LMSIds.add(LMSIP.GBS_LMS__c);
        }
        
        //  Query and iterate all LMS IPs associated to the LMS Ids collected above
        for(GBS_LMS_IP__c LMSIP : [Select Id, GBS_Intellectual_Property__r.Name, GBS_LMS__c From GBS_LMS_IP__c Where GBS_LMS__c IN : LMSIds]) {
            //  Prepare a map with LMS Id as key and assoictaed IP Names with comma separated as value
            String IPNames = LMSIP.GBS_Intellectual_Property__r.Name;
            
            if(LMSIdToIPsMap.containsKey(LMSIP.GBS_LMS__c)) {
                //  Proceed only if the string(which is stored into IP Details field of LMS) length is not exceeding 255
                if(!LMSIdToIPsMap.get(LMSIP.GBS_LMS__c).endsWith('...')) {
                    //  If string length exceeds 250 after adding another IP Name, just add ellipsis at the end
                    if((LMSIdToIPsMap.get(LMSIP.GBS_LMS__c) + ',' + IPNames).length() >= 250)
                        IPNames = LMSIdToIPsMap.get(LMSIP.GBS_LMS__c) + '...';
                    else
                        IPNames = LMSIdToIPsMap.get(LMSIP.GBS_LMS__c) + ',' + IPNames;
                }
            }
                
            LMSIdToIPsMap.put(LMSIP.GBS_LMS__c, IPNames);
        }
        
        //  Update LMS records with the concatenated IP Names
        for(Id LMSId : LMSIds) {
            LMS__c lms = new LMS__c();
            if(LMSIdToIPsMap.containsKey(LMSId)) {
                lms = new LMS__c(Id = LMSId, LMS_IP__c = LMSIdToIPsMap.get(LMSId));
            }
            else {
                lms = new LMS__c(Id = LMSId, LMS_IP__c = null);
            }
            LMSRecordsToUpdate.add(lms);
            
        }
        
        try {
            //  Perform DML on LMS 
            if(!LMSRecordsToUpdate.isEmpty())
                update LMSRecordsToUpdate;
        }catch(DMLException e) {
            //  Log exception
            DGF_ExceptionLogController.createExceptionLog('While creating new LMS IP', 'GBSLMSIPTriggerHandler', e.getMessage());
        }
    }
}