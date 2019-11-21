trigger Case_AllTriggers on Case (before insert, before update, before delete, after insert, after update, after delete) {
    //The goal of the trigger is to achieve the following:
    //1. Allow creation of case only in the New Status
    //2. Allow changes of case to Cancelled status from all status except Closed
    //3. Allow closing the case manually for PO Discrepancies cases when the status is Doc # Created
    //4. Disallow deletion of case if it is anything other than New status
    //5. Lock the Case Record for edits when it is in either of Approved / Submitted / Doc # Created / Cancelled / Closed status
    //Ensure that you update the Test classes with the error messages if there are any changes in the error message wording
    
    //This trigger will also update the Open_Cases__c on the Price Protection Program object for all Price Protection Cases
    //This is handled in the after triggers
    Bypass_TPWV__c BypassCS 	= Bypass_TPWV__c.getInstance();
    Boolean BypassValidations 	= BypassCS.Bypass_Validation_Rules__c;
    Id POD_RecTypeId 			= Schema.SObjectType.Case.getRecordTypeInfosByName().get('PO Discrepancies').getRecordTypeId();
    Id PP_RecTypeId 			= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Price Protection').getRecordTypeId();
    
    if (Trigger.isBefore){
        //Get the Bypass Validations checkbox value. We will bypass triggers for users who have the Bypass Validations flag is checked
        if (!BypassValidations){
            //Execute the trigger before Salesforce Operations
            if (Trigger.isInsert){
                //Check if status is New when inserting Case. Else stop the creation
                //Run the logic only if the Record Type is one of PO Discrepancies / Price Protection
                //Check the status field
                for (Case C : Trigger.new){
                    if (C.Status 	!= 'New'){
                        if (C.RecordTypeId == POD_RecTypeId || C.RecordTypeId == PP_RecTypeId)
                            C.Status.addError('Status can only be New when creating a Case');
                    }
                    if(C.Integration_Status__c != '')
                        C.Integration_Status__c = '';
                }
            }
            if (Trigger.isUpdate){
                //Prevent changes to the case status manually.
                Set <Id> CaseIds 			= Trigger.newMap.keySet();
                List <Case> CaseRecords 	= [select Id, Status, RecordTypeId  from Case where Id in :CaseIds];
                if (!CaseRecords.isEmpty()){
                    List <String> CurrentRecTriggerStatus 	= new List <String>();
                    Map <Id, String> CaseId2String 			= new Map <Id, String>();
                    for (Case RecordLoop : CaseRecords){
                        //Setup the Map to compare the new value to the old one
                        CaseId2String.put(RecordLoop.Id, RecordLoop.Status);
                        CurrentRecTriggerStatus.add(RecordLoop.Status);
                    }
                    //Setup a List to check for the mappings. This list will always have the All value in it
                    CurrentRecTriggerStatus.add('All');
                    Map <String, String> MappingSetup 		= new Map <String, String>();
                    //For all the values in the List, identify the Meta Data setup in place
                    //Query the meta data setup and build a CSV string of all the allowed statuses
                    for (String RecordLoop: CurrentRecTriggerStatus){
                        String AllowedStatusChanges 		= '';
                        List <Case_Status_Change__mdt> StatusChangeMapping = [select Existing_Status__c, New_Status__c from Case_Status_Change__mdt where Existing_Status__c = :RecordLoop];
                        if (!StatusChangeMapping.isEmpty()){
                            for (Case_Status_Change__mdt MetaDataLoop: StatusChangeMapping){
                                AllowedStatusChanges 		= AllowedStatusChanges + ',' + MetaDataLoop.New_Status__c;
                            }
                        }
                        if (AllowedStatusChanges 			!= ''){
                            MappingSetup.put(RecordLoop, AllowedStatusChanges);
                        }
                    }
                    String CurrentDBStatus = '';
                    for (Case RecordLoop: Trigger.new){
                        CurrentDBStatus 					= CaseId2String.get(RecordLoop.Id);
                        system.debug('CurrentDBStatus: ' + CurrentDBStatus + ', RecordLoop.Status: ' + RecordLoop.Status);
                        system.debug('MappingSetup: ' + MappingSetup);
                        //Check if there is a mapping for the current DB Status
                        //In case there is, then the Transition Allowed variables will not be -1
                        //Else they will be -1 indicating that the transition is not allowed
                        //User will then be presented with an error message
                        Integer TransitionAllowedCurrent 	= -1;
                        if (CurrentDBStatus == RecordLoop.Status){
                            //The above condition is to skip the status change validations if the user is just updating the record and not changing the status
                            //We will be preventing updates to the record here
                            if (CurrentDBStatus == 'Approved' || CurrentDBStatus == 'Submitted' || CurrentDBStatus == 'Doc # Created' || CurrentDBStatus == 'Cancelled'|| CurrentDBStatus == 'Closed'){
                                RecordLoop.addError('This case can no longer be edited');
                            }
                        } else {
                            if (MappingSetup.get(CurrentDBStatus) != null)
                                TransitionAllowedCurrent 		= MappingSetup.get(CurrentDBStatus).indexOf(RecordLoop.Status);
                            //Integer TransitionAllowedAll 		= MappingSetup.get('All').indexOf(RecordLoop.Status);
                            if (TransitionAllowedCurrent 		!= -1){
                                //Do Nothing
                            } else {
                                RecordLoop.Status.addError('Status cannot be changed from ' + CurrentDBStatus + ' to ' + RecordLoop.Status + ' manually');
                            } 
                        }
                    }// End of for (Case RecordLoop: Trigger.new)
                }// End of if (!CaseRecords.isEmpty())
            }// End of if (Trigger.isUpdate)
        }// End of if (!BypassValidations)
    } else if (Trigger.isAfter){
        //Loop through all the records and identify the Programs
        //Bypass validations
        if(!BypassValidations){
            BypassCS.Bypass_Validation_Rules__c = true;
            upsert BypassCS;
        }
	    Set <Id> OrigPP_Programs 	= new Set <Id>();
        //Identify all the records to process
        if (!Trigger.isDelete){
            for (Case RecordLoop: Trigger.new){
                if(RecordLoop.RecordTypeId == PP_RecTypeId)
                    OrigPP_Programs.add(RecordLoop.Associated_Price_Protection_Program__c);
            }
        } else {
            for (Case RecordLoop: Trigger.old){
                if(RecordLoop.RecordTypeId == PP_RecTypeId)
                    OrigPP_Programs.add(RecordLoop.Associated_Price_Protection_Program__c);
            }
        }
        system.debug('List of New Programs: ' + OrigPP_Programs);
        
        //Get a list of Case Statuses and Programs
        AggregateResult[] Program2CaseStatus = [select Associated_Price_Protection_Program__c , Status from Case where Associated_Price_Protection_Program__c IN :OrigPP_Programs group by Associated_Price_Protection_Program__c, Status];
        Map <Id, String> ProgramIds2StatusCSV = new Map <Id, String>();
        String StatusValues = '';
        for (AggregateResult Looper: Program2CaseStatus){
            Id ProgramId 		= (Id)Looper.get('Associated_Price_Protection_Program__c');
            String StatusVals 	= (String)Looper.get('Status');
            
            if (ProgramIds2StatusCSV.get(ProgramId) == null){
                ProgramIds2StatusCSV.put(ProgramId, StatusVals);
            } else{
                ProgramIds2StatusCSV.put(ProgramId, ProgramIds2StatusCSV.get(ProgramId) + ',' + StatusVals);
            }
        }
        //The above logic will provide a map containing the Program Ids as the key set and comma seperated Case Status values as values
        //The Aggregate query does not bring is records which are not found in the Group to
        //Below logic will add such Programs from the OrigPP_Programs Set to the Map
        //This is essential as users can remove the Associated Program against a Case and that Program may have no more Non Closed / Cancelled cases under it
        //We need to uncheck the Open Cases flag for such Programs
        for (Id Looper: OrigPP_Programs){
            if (ProgramIds2StatusCSV.get(Looper) == null)
                ProgramIds2StatusCSV.put(Looper, 'NA');
        }
        //Now query the list of Programs and the carry out the updates
        List <Price_Protection_Program__c> ProgramList = [select Id, Open_Cases__c from Price_Protection_Program__c where Id In :OrigPP_Programs];
        if(!ProgramList.isEmpty()){
            for (Price_Protection_Program__c RecordLoop: ProgramList){
                Set <String> SplitList = new Set <String>();
                SplitList.addAll(ProgramIds2StatusCSV.get(RecordLoop.Id).split(','));
                Boolean OpenCases4Program = false;
                for (String Looper : SplitList){
                    if (Looper != 'Closed' && Looper != 'Cancelled' && Looper != 'NA')
                        OpenCases4Program = true;
                }
                RecordLoop.Open_Cases__c = OpenCases4Program;
            }
            update ProgramList;
        }
        
        //Disable the Bypass of validations
        if(!BypassValidations){
            BypassCS.Bypass_Validation_Rules__c = false;
            upsert BypassCS;
        }
    }
}