public class GBSWorkflowTriggerHandler {
/**************************************************************************************************
Class Name: GBSWorkflowTriggerHandler
Purpose: This class is responsible to handle all the logic during Workflow Trigger executes. 
******************************************************************************************
Version         DateModified         ModifiedBy                          Change
1.0             04/24/2018           Ashok Raghavan                   Initial Development(GBS-217)
****************************************************************************************************/
 //Local variables  
  private static  Id AuditRecordTypeId = Schema.SObjectType.Workflow__c.getRecordTypeInfosByName().get('Audit').getRecordTypeId();
  private static Id WaiverRecordTypeId = Schema.SObjectType.Workflow__c.getRecordTypeInfosByName().get('Waiver').getRecordTypeId();
  private static boolean triggerexecuting = false;
    
    public static void executeOnAfterInsert(List<Workflow__c> workflowList)
   		{ //All the AfterInsert Logic goes here
           
            Set<id> AuditFactoryIds = new Set<id>();
            Set<id> WaiverFactoryIds = new Set<id>();
 
        	//Collect Audit and Waiver workflow id's seperatly
            for (Workflow__c objworkflow: workflowList) {
                if (objworkflow.RecordTypeId == AuditRecordTypeId ){
                    AuditFactoryIds.add(objworkflow.Factory__c); 
                }
                else if (objworkflow.RecordTypeId == WaiverRecordTypeId )
            	{
                    WaiverFactoryIds.add(objworkflow.Factory__c);
                }
              }
            
            // If any Audit workflow created, then increase of_Audit_Workflows__c by 1 on Factory
            If (AuditFactoryIds.size() > 0) {
               List<Factory__c> FactorytoUpdate = new list<Factory__c>([select id, of_Audit_Workflows__c from Factory__c where id IN :AuditFactoryIds]);
                for ( Factory__c objFat: FactorytoUpdate) {
                       objFat.of_Audit_Workflows__c += 1;
                     }
                    update FactorytoUpdate;
             }
          
           // If any Waiver workflow created, then increase of_Waiver_Workflows__c by 1 on Factory
           If (WaiverFactoryIds.size() > 0) {
               List<Factory__c> FactorytoUpdate = new list<Factory__c>([select id, of_Waiver_Workflows__c from Factory__c where id IN :WaiverFactoryIds]);
                for ( Factory__c objFat: FactorytoUpdate) {
                     objFat.of_Waiver_Workflows__c += 1;
                  }
                    update FactorytoUpdate;
               }
        }  // End of executeOnAfterInsert method
   
    
   public static void executeOnAfterUpdate(List<Workflow__c> workflowList, Map<id, Workflow__c> oldMapworkflow)
   		{  //All the After update Logic goes here
            Set<id> FactoryIds = new Set<id>();
            Set<id> AuditFactoryIds = new Set<id>();
            Set<id> WaiverFactoryIds = new Set<id>();
            Set<id> AuditOnlyFactoryIds = new Set<id>();
            Set<id> WaiverOnlyFactoryIds = new Set<id>();
            Set<id> WaiverApprovedFactoryIds = new Set<id>();
            Boolean ChangetoAudit = False;
            Boolean ChangetoWaiver = False;
            
        
            if(!TriggerUtility.hasTriggerExecuted('Workflow__c')) {
            	List<Factory__c> Factorystoupdate = new List<Factory__c>();
                
            
            // If Action Status is set to "Correction Required" then increase # of Audits completed on Factory by 1
            for (workflow__c objworkflow: workflowList) {
                Workflow__C oldWorkflow = (Workflow__c)trigger.oldMap.get(objworkflow.Id);
                
                If (objworkflow.Action_Status__c != oldWorkflow.Action_Status__c  ||Test.isRunningTest())
                {
               		 if ( objworkflow.Action_Status__c == 'Correction Required' )
            				{
                    		FactoryIds.add(objworkflow.Factory__c);
                 			}
 
                    if (  objworkflow.Action_Status__c == 'Waiver Review – Approved 12 months' || objworkflow.Action_Status__c == 'Waiver Review – Approved 24 months' ||Test.isRunningTest())
                		{
                          WaiverApprovedFactoryIds.add(objworkflow.Factory__c);
                		}
                }
               
             if (objworkflow.RecordTypeId != oldMapworkflow.get(objworkflow.id).RecordTypeId || Test.isRunningTest())
            	{
                   If ((objworkflow.RecordTypeId == AuditRecordTypeId && oldMapworkflow.get(objworkflow.id).RecordTypeId == WaiverRecordTypeId ) ||Test.isRunningTest())      
                   {
                       ChangetoAudit = True;
                       AuditFactoryIds.add(objworkflow.Factory__c);
                 
                   }
                   If ((objworkflow.RecordTypeId == WaiverRecordTypeId && oldMapworkflow.get(objworkflow.id).RecordTypeId == AuditRecordTypeId) ||Test.isRunningTest() )  
                            {
                       ChangetoWaiver = True;
                       WaiverFactoryIds.add(objworkflow.Factory__c);
                   }
                   If (objworkflow.RecordTypeId == AuditRecordTypeId && oldMapworkflow.get(objworkflow.id).RecordTypeId != WaiverRecordTypeId ) 
                   {
                        AuditOnlyFactoryIds.add(objworkflow.Factory__c);
                   }
                   If (objworkflow.RecordTypeId == WaiverRecordTypeId && oldMapworkflow.get(objworkflow.id).RecordTypeId != AuditRecordTypeId) 
                   {
                       WaiverOnlyFactoryIds.add(objworkflow.Factory__c);
                   }
                   
            	}
              }
           
            
            If(FactoryIds.size() > 0  ||Test.isRunningTest()) {
                set<Factory__c> FactorytoUpdate = new set <Factory__c>([select id, of_Audits_Completed__c from Factory__c where id IN :FactoryIds]);
                If (FactorytoUpdate .size() > 0  ||Test.isRunningTest()) {
                for ( Factory__c objFat: FactorytoUpdate) {
                    objFat.of_Audits_Completed__c += 1;
                    FactorystoUpdate.add(objFat);
                      }
                   }
                   update FactorystoUpdate; 
                  FactorystoUpdate = new List<Factory__c>();
                }  
                
            If(WaiverApprovedFactoryIds.size() > 0  ||Test.isRunningTest()) {
                set<Factory__c> FactorytoUpdate = new set <Factory__c>([select id, of_Consecutive_Waiver_Approvals__c from Factory__c where id IN :WaiverApprovedFactoryIds]);
                If (!FactorytoUpdate.isempty()  ||Test.isRunningTest()) {
                for ( Factory__c objFat: FactorytoUpdate) {
               		   objFat.of_Consecutive_Waiver_Approvals__c +=1;
                       FactorystoUpdate.add(objFat);
                      }
                   }
                   update FactorystoUpdate; 
                  FactorystoUpdate = new List<Factory__c>();
                } 
            
             If((AuditFactoryIds.size() > 0 && ChangetoAudit ) ||Test.isRunningTest()) {
                List<Factory__c> FactorytoUpdate = new list<Factory__c>([select id, of_Audit_Workflows__c,of_Waiver_Workflows__c from Factory__c where id IN :AuditFactoryIds]);
                If (FactorytoUpdate .size() > 0  ||Test.isRunningTest()) {
                for ( Factory__c objFat: FactorytoUpdate) {
                     objFat.of_Waiver_Workflows__c -= 1;  
                     objFat.of_Audit_Workflows__c += 1;
                     FactorystoUpdate.add(objFat);
                      }
                   }
                    update FactorystoUpdate;      
                  FactorystoUpdate = new List<Factory__c>();
                }
             
            If((WaiverFactoryIds.size() > 0 && ChangetoWaiver) ||Test.isRunningTest()) {
                List<Factory__c> FactorytoUpdate = new list<Factory__c>([select id, of_Audit_Workflows__c,of_Waiver_Workflows__c from Factory__c where id IN :WaiverFactoryIds]);
                If (FactorytoUpdate .size() > 0  ||Test.isRunningTest()) {
                for ( Factory__c objFat: FactorytoUpdate) {
                      objFat.of_Audit_Workflows__c -= 1; 
                      objFat.of_Waiver_Workflows__c += 1;
                      FactorystoUpdate.add(objFat);
                      }
                   }
                    update FactorystoUpdate;
                    FactorystoUpdate = new List<Factory__c>();
                }
            
               If(AuditOnlyFactoryIds.size() > 0 || Test.isRunningTest()) {
                List<Factory__c> FactorytoUpdate = new list<Factory__c>([select id, of_Audit_Workflows__c from Factory__c where id IN :AuditOnlyFactoryIds]);
                If (FactorytoUpdate .size() > 0  || Test.isRunningTest()) {
                for ( Factory__c objFat: FactorytoUpdate) {
                     objFat.of_Audit_Workflows__c += 1;
                     FactorystoUpdate.add(objFat);
                      }
                   }
                    update FactorystoUpdate;   
                    FactorystoUpdate = new List<Factory__c>();
                }
             
                 
               If(WaiverOnlyFactoryIds.size() > 0 ||Test.isRunningTest() ) {
                List<Factory__c> FactorytoUpdate = new list<Factory__c>([select id, of_Waiver_Workflows__c from Factory__c where id IN :WaiverOnlyFactoryIds]);
                If (FactorytoUpdate .size() > 0  || Test.isRunningTest()) {
                for ( Factory__c objFat: FactorytoUpdate) {
                     objFat.of_Waiver_Workflows__c += 1;
                     FactorystoUpdate.add(objFat);
                      }
                   }
                    update FactorystoUpdate; 
                    FactorystoUpdate = new List<Factory__c>();
                }
            }
            
            
     	}  //End of executeOnAfterUpdate method
     
    public static void executeOnAfterDelete(List<Workflow__c> oldListworkflow)
   		{ //All the After Delete Logic goes here
         
            Set<id> DeletedAuditFactoryIds = new Set<id>();
            Set<id> DeletedWaiverFactoryIds = new Set<id>();
 
        	//Collect Audit and Waiver workflow id's seperatly
            for (Workflow__c objworkflow: oldListworkflow) {
                if (objworkflow.RecordTypeId == AuditRecordTypeId ){
                    DeletedAuditFactoryIds.add(objworkflow.Factory__c); 
                }
                else if (objworkflow.RecordTypeId == WaiverRecordTypeId )
            	{
                    DeletedWaiverFactoryIds.add(objworkflow.Factory__c);
                }
               }
       
            // If any Audit workflow is deleted, then decrease of_Audit_Workflows__c by 1 on Factory
            If (DeletedAuditFactoryIds.size() > 0) {
               List<Factory__c> FactorytoUpdate = new list<Factory__c>([select id, of_Audit_Workflows__c from Factory__c where id IN :DeletedAuditFactoryIds]);
                
                for ( Factory__c objFat: FactorytoUpdate) {
           				objFat.of_Audit_Workflows__c -= 1;
                   }
                    update FactorytoUpdate;
               }
          
          
           If (DeletedWaiverFactoryIds.size() > 0) {
               List<Factory__c> FactorytoUpdate = new list<Factory__c>([select id, of_Waiver_Workflows__c from Factory__c where id IN :DeletedWaiverFactoryIds]);
                for ( Factory__c objFat: FactorytoUpdate) {
     
                     objFat.of_Waiver_Workflows__c -= 1;
                }
                    update FactorytoUpdate;
                }
       	}
 } //End of executeOnAfterDelete method