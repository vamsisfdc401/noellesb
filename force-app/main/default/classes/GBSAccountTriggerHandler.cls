/*****************************************************************************************
Class Name: GBSAccountTriggerHandler
Purpose: Class for handling Account Trigger
******************************************************************************************
Version        	DateModified         	ModifiedBy               	Change
1.0             08/05/2018           	Ashok                    	Initial Development
******************************************************************************************/

public class GBSAccountTriggerHandler 
{   //GBS- 223
	private static Id licenseeContactRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GBSConstants.LICENSEECONTACT).getRecordTypeId();
    private static Id TaskRecordTypeId  = Schema.SObjectType.Task.getRecordTypeInfosByName().get(GBSConstants.GBSTaskRecordType).getRecordTypeId();
           
      public static void UpdateContractLMSFlag(){
        //Get the Account Ids associated to trigger.new
        Set<Id> AccountIDs = new Set<Id>();
        
        if( Trigger.IsInsert || Trigger.IsUpdate)   
        { 
            for (Account acc : (List<Account>)trigger.new){
                
                if(acc.RecordTypeID == licenseeContactRecTypeId && acc.Licensee_Flag__c == 'Exempt Partner')
                {
                    AccountIDs.add(acc.ID);
                }
            }
        }
      
      If (!AccountIDs.isempty()) 
          {
        //Get the Contract records related to those Accounts
        List<Contract__c> contractList = [Select Id,LMS_Flag__c  from Contract__c WHERE (Licensee__c  IN :AccountIDs and LMS_Flag__c != 'No LMS Required' ) ];
        
        If(!contractList.isempty())
        {
        	List<Contract__c> updateContractList = new List<Contract__c>();
               
        	//Iterate through the Contract to update the LMS Flag
        	for (Contract__c contract : contractList)
        	{
            	contract.LMS_Flag__c  = 'No LMS Required';
                updateContractList.add(contract);
        	}
        	update updateContractList; 
    	} 
       }
      }

   
    

     public static void createTask(List<Account> accList)
	   {  
           List<Task> tskList = new List<Task>();
	          
           for(Account accObj : accList)
			  {
			      if(accObj.RecordTypeID == licenseeContactRecTypeId  )
				  {
				     Task tsk = new Task();
                     tsk.RecordTypeId = TaskRecordTypeId;
					 tsk.Subject = 'Licensee Onboarding';
					 tsk.Status = 'Open';
					 tsk.Priority = 'Normal';
                     tsk.type = 'New Licensee';
                     tsk.ActivityDate=system.today();
					 tsk.WhatId = accObj.ID;
                     List<User> AssignedtoId = [select id from user where UserName = :Label.GBS_Licensee_Onboarding_User ];
                      If (!AssignedtoId.isempty())
                      {
					 		tsk.OwnerId = AssignedtoId[0].id;
                      }
                      else {
                          tsk.OwnerId = accObj.OwnerId;
                      }
			 	 tskList.add(tsk);
				  }
			  }
			        if(tskList!=null && tskList.size()>0)
			  
			           insert tskList;
	   }

  
}