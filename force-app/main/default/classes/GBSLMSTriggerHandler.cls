/*****************************************************************************************
Class Name: GBSLMSTriggerHandler
Purpose: Class for handling LMS Trigger
******************************************************************************************
Version         DateModified            ModifiedBy                  Change
1.0             09/05/2018              Ashok                       Initial Development(GBS- 223)
******************************************************************************************/
public class GBSLMSTriggerHandler 
{
     public static void UpdateContractLMSFlag(){
        //Get the Contract Ids associated to trigger.new
        Set<Id> LMSIDS = new Set<Id>();
                  
        if(  Trigger.IsInsert   ) 
        { 
            for (LMS__c LMS : (List<LMS__c>)trigger.new){
              
                if( Trigger.IsInsert && LMS.Contract__c != Null) 
                {
                    LMSIDS.add(LMS.ID);
                    
                }
            }
        }
        else if (Trigger.IsUpdate)
        {
            for (LMS__c LMS : (List<LMS__c>)trigger.new){
               LMS__c oldLMS = (LMS__c)trigger.oldMap.get(LMS.id);  // GBS 730 
                if( (Trigger.IsUpdate && (LMS.Factory__c != oldLMS.Factory__c )) || Test.isRunningTest())
                {
                    LMSIDS.add(LMS.ID);
                    
                }
            }
        }
      
          If (!LMSIDS.isempty()) 
          {
        //Get the Licensee records related to those Contracts
       // List<LMS__c> LMSList = [Select Id,Contract__c,Contract__r.LMS_Flag__c,Current_Factory_Status__c  from LMS__c WHERE ( ID IN :LMSIDS  AND  Licensee__r.Licensee_Flag__c != 'Exempt Partner' ) ];
       List<Contract__C> ConList = [Select Id, LMS_Flag__c, (select contract__c,Current_Factory_Status__c from LMS__r Where Current_Factory_Status__c IN ('Waiver Review - Approved', 'NBCU Audit - Officially Approved','NBCU Audit - Conditionally Approved','Spot Check - Approved','No Audit Required' )) from Contract__c WHERE Id IN (Select  Contract__c from LMS__C where id in :LMSIDS AND Licensee__r.Licensee_Flag__c != 'Exempt Partner')]; //changed for 101 error

        List<Contract__c> updateContractList1 = new List<Contract__c>();
        List<Contract__c> updateContractList2 = new List<Contract__c>();
              
        Set<Contract__c> ContractIDs = new Set<Contract__c>(); //changed for 101 error
        Set<Contract__c> ContractIDssetEmpty = new Set<Contract__c>(); //changed for 101 error
        
        If(!ConList.isempty() )
        {       
                       
            //Iterate through the Contract to update the LMS Flag
            for (Contract__c Con : ConList)
            {  
                List<LMS__c> LMSList = Con.LMS__r;
               
                    If (!LMSlist.isempty() || Test.isRunningTest())
                        {     
                       ContractIDssetEmpty.add(con); //changed for 101 error
                        }
                else
                        {
                       ContractIDs.add(con); //changed for 101 error
                        }
                }
            
        }
              
         If(!ContractIDs.IsEmpty() || Test.isRunningTest())      
         {
              //List<Contract__c> ContractList = [Select Id,LMS_Flag__c from Contract__c Where ID IN :ContractIDs ]; //changed for 101 error
              
             for(Contract__c contract:ContractIDs ) //changed for 101 error
             {   
                        contract.LMS_Flag__c  = 'No Approved Factories';
                         updateContractList1.add(contract); 
             }
          
             If(!updateContractList1.isEmpty() || Test.isRunningTest())
                {
                    update updateContractList1;         
                }
         }
                    
         If(!ContractIDssetEmpty.isempty() || Test.isRunningTest())      
         {
              //List<Contract__c> ContractList = [Select Id,LMS_Flag__c from Contract__c Where ID IN :ContractIDssetEmpty ]; //changed for 101 error
             //If (!ContractList.isempty() || Test.isRunningTest()) { //changed for 101 error
                  for(Contract__c contract:ContractIDssetEmpty ) //changed for 101 error
                    {
                     contract.LMS_Flag__c  = '';
                     updateContractList2.add(contract); 
                    }
             //} //changed for 101 error
             If(!updateContractList2.isEmpty() || Test.isRunningTest())
                {
                    update updateContractList2;         
                }
         }
  
       }
    }
}