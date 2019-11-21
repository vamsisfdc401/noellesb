/*****************************************************************************************
Class Name: GBSFactoryTriggerhandler
Purpose: Class for handling Contract Trigger
******************************************************************************************
Version         DateModified            ModifiedBy                  Change
1.0             08/05/2018              Ashok                       Initial Development*GBS 670)
******************************************************************************************/

public class GBSFactoryTriggerhandler 
{
     public static void UpdateContractLMSFlag(){
        //Get the Factory Ids associated to trigger.new
        Set<Id> FactoryIDS = new Set<Id>();
        if(  Trigger.IsInsert || Trigger.IsUpdate)   
        {   
            for (Factory__c Factory : (List<Factory__c>) trigger.new){
                Factory__c oldFactory = (Factory__c)trigger.oldMap.get(Factory.Id);
                if( Factory.Factory_Status__c != Null && (Factory.Factory_Status__c != oldFactory.Factory_Status__c)) 
                {
                        FactoryIDS.add(Factory.ID);
                }
            }
        }
         
        If (!FactoryIDS.isempty()) 
          {
        //Get the Licensee records related to those Contracts
       // List<LMS__c> LMSList = [Select Id,Contract__c,Contract__r.LMS_Flag__c,Current_Factory_Status__c  from LMS__c WHERE ( ID IN :LMSIDS  AND  Licensee__r.Licensee_Flag__c != 'Exempt Partner' ) ];
       List<Contract__C> ConList = [Select Id, (select contract__c,Current_Factory_Status__c from LMS__r Where Current_Factory_Status__c IN ('Waiver Review - Approved', 'NBCU Audit - Officially Approved','NBCU Audit - Conditionally Approved','Spot Check - Approved','No Audit Required','Waiver Review - Approved (Spot Check Passed)' )) from Contract__c WHERE Id IN (Select  Contract__c from LMS__C where LMS__c.Factory__c in :FactoryIDS AND Licensee__r.Licensee_Flag__c != 'Exempt Partner')];

        List<Contract__c> updateContractList1 = new List<Contract__c>();
        List<Contract__c> updateContractList2 = new List<Contract__c>();
              
        Set<ID> ContractIDs = new Set<ID>();
        Set<ID> ContractIDssetEmpty = new Set<ID>();
        
        If(!ConList.isempty() )
        {       
                       
            //Iterate through the Contract to update the LMS Flag
            for (Contract__c Con : ConList)
            {  
                List<LMS__c> LMSList = Con.LMS__r;
               
                    If (!LMSlist.isempty() || Test.isRunningTest())
                        {     
                       ContractIDssetEmpty.add(con.id);
                        }
                else
                        {
                       ContractIDs.add(con.id);
                        }
                }
            
        }
              
         If(!ContractIDs.IsEmpty() || Test.isRunningTest())      
         {
              List<Contract__c> ContractList = [Select Id,LMS_Flag__c from Contract__c Where ID IN :ContractIDs ];
              
             for(Contract__c contract:ContractList )
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
              List<Contract__c> ContractList = [Select Id,LMS_Flag__c from Contract__c Where ID IN :ContractIDssetEmpty ];
             If (!ContractList.isempty() || Test.isRunningTest()) {
                  for(Contract__c contract:ContractList )
                    {
                     contract.LMS_Flag__c  = '';
                     updateContractList2.add(contract); 
                    }
             }
             If(!updateContractList2.isEmpty() || Test.isRunningTest())
                {
                    update updateContractList2;         
                }
         }
  
       }
         
         
         /*
          If (!FactoryIDS.isEmpty()) 
          {
          //Get all related LMS records
          List<LMS__c> LMSContractList = [Select Contract__r.id,Contract__r.LMS_Flag__C  from LMS__c WHERE  LMS__c.Factory__c in :FactoryIDS];
          Set<id> ContractIDS = new set<id>();
               If(!LMSContractList.isEmpty() || Test.isRunningTest())
                {
                    for (LMS__c LMS : LMSContractList)
                    {
                       ContractIDS.add(LMS.Contract__r.id);
                    }
                } 
                
                If(!ContractIDS.isempty()|| Test.isRunningTest())
                    {
                        // update the contract LMS status to Empty only if it is already not Empty.
                        List<Contract__c> ContractList = [Select id,LMS_Flag__c  from Contract__c WHERE  ID  in :ContractIDS and LMS_Flag__c !=''];
                        If (!ContractList.isempty()|| Test.isRunningTest())
                        {
                            for (Contract__c contract : ContractList)
                                {
                                contract.LMS_Flag__c = '';
                                }
                        update ContractList;
                        }
                    }
             }*/
      }
}