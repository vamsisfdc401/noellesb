/*****************************************************************************************
Class Name: GBSContractTriggerHandler
Purpose: Class for handling Contract Trigger
******************************************************************************************
Version        	DateModified         	ModifiedBy               	Change
1.0             08/05/2018           	Ashok                    	Initial Development
******************************************************************************************/

public class GBSContractTriggerHandler 
{   //GBS- 223
	private static Id licenseeContactRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(GBSConstants.LICENSEECONTACT).getRecordTypeId();
    
           
      public static void UpdateContractLMSFlag(){
        //Get the Contract Ids associated to trigger.new
        Set<Id> ContractIDS = new Set<Id>();
                  
        if(  Trigger.IsInsert || Trigger.IsUpdate)   
        { 
            for (Contract__c contract : (List<Contract__c>)trigger.new){
                
                if( contract.Licensee__c != Null)
                {
                    ContractIDS.add(contract.ID);
                }
            }
        }
      
          If (ContractIDS.Size() >0) 
          {
        //Get the Licensee records related to those Contracts
        List<Contract__c> contractList = [Select Id,LMS_Flag__c  from Contract__c WHERE ( ID IN :ContractIDS  AND  Licensee__r.Licensee_Flag__c = 'Exempt Partner' and LMS_Flag__c != 'No LMS Required' ) ];
       
        
        If(contractList.size() > 0)
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
}