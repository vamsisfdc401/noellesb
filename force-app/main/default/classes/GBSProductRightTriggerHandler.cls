public class GBSProductRightTriggerHandler {
    
/*****************************************************************
Method Name: buildProductDetailString
Purpose: static method called in 'after' context to build/rebuild string
containing Product Details in a Product Rights Group Record
Author : Harsha(05/08/2018)
***************************************************************/

    public static void buildProductDetailString(){
        //Get the Product Rights Group Ids associated to trigger.new
        Set<Id> productRightsGroupId = new Set<Id>();
        
        if(Trigger.IsInsert || Trigger.IsUpdate)
        {
            for (Product_Right__c pr : (List<Product_Right__c>)trigger.new){
                if(pr.Product_Rights_Group__c != NULL){
                    productRightsGroupId.add(pr.Product_Rights_Group__c);
                }
            }
        }
        else if(Trigger.IsDelete)
        {
            for (Product_Right__c pr : (List<Product_Right__c>)trigger.old){
                
                if(pr.Product_Rights_Group__c != NULL){
                    productRightsGroupId.add(pr.Product_Rights_Group__c);
                }
            }
        }
        
        //Get the Product Right records related to those Product Rights Groups
        List<Product_Right__c> prList = [Select Id, Product_Rights_Group__c, Product_Type__r.Name from Product_Right__c WHERE (Product_Rights_Group__c IN :productRightsGroupId)];

        //construct List to put updated Product Detail string on        
        List<Product_Rights_Group__c> productRightsGroupList = [Select Id, Product_Details__c from Product_Rights_Group__c WHERE Id IN :productRightsGroupId];

        //Iterate through the Product Rights Groups and Product Rights to update the Product Details string
        for (Product_Rights_Group__c prg : productRightsGroupList){
            //Reset string to blank
            prg.Product_Details__c = '';
            
            //Concatenate name into Product Details field on PRG
            for(Product_Right__c pr: prList){
                if(pr.Product_Rights_Group__c == prg.Id){
                    prg.Product_Details__c += pr.Product_Type__r.Name + '; ';
                }
                if(prg.Product_Details__c.length() >= Integer.valueOf(System.Label.GBS_ProductDetails_Length)){
                    prg.Product_Details__c = prg.Product_Details__c.left(Integer.valueOf(System.Label.GBS_ProductDetails_Length));
                    break;
                }
            }
        }
        
        update productRightsGroupList;
        
    }
    
  
      
/*****************************************************************
Method Name: SetLMSFlagonParentContract
Purpose: static method called in 'after' context to set GrandParent
GBS Contract LMS Status 
Author : Ashok Raghavan (05/10/2017)
Jira : GBS - 223
***************************************************************/
public static void SetLMSFlagonParentContract(){
       
    //Get the Product Rights Group Ids associated to trigger.new
        Set<Id> productRightsGroupId = new Set<Id>();
        Set<Id> productRightsNoLMSGroupId = new Set<Id>();
        
    
        if(Trigger.IsInsert || Trigger.IsUpdate)
        {
            for (Product_Right__c pr : (List<Product_Right__c>)trigger.new){
                if(pr.Product_Rights_Group__c != NULL  ){
                    If(pr.Product_LMS_Status__c !=Null && pr.Product_LMS_Status__c.contains('No LMS')) {
                    productRightsNoLMSGroupId.add(pr.Product_Rights_Group__c);
                    }
                    else 
                     {
                    productRightsGroupId.add(pr.Product_Rights_Group__c);
                     }
               }
            }
        }
             
       /* else if(Trigger.IsDelete)
        {
            for (Product_Right__c pr : (List<Product_Right__c>)trigger.old){
                
                if(pr.Product_Rights_Group__c != NULL){
                    productRightsGroupId.add(pr.Product_Rights_Group__c);
                    ContractIdwithNoLMSrequired.add(pr.Product_Rights_Group__r.contract__c);
                }
            }
        }*/
           //Get the Contract id associated to the Product right Groups
        
        Set<Id> ContractIdwithLMSrequired = new Set<Id>();
        List<Contract__c> UpdateContractRecords = new List<Contract__c>();
    
          //Get all the PRG and Product rights associated to the contract where the LMS Required is true
              
        List<Product_Rights_Group__c> productRightsGroupList = [Select Id, LMS_Required__c,Contract__c from Product_Rights_Group__c WHERE Id IN :productRightsGroupId];
        
        for (Product_Rights_Group__c PRG: productRightsGroupList)
           {
               ContractIdwithLMSrequired.add(PRG.Contract__c);
           }
    
            Set<Id> ContractIdwithNoLMSrequired = new Set<Id>();
    
          //Get all the PRG and Product rights associated to the contract where the NoLMS Required option is true
              
        List<Product_Rights_Group__c> RPGroupList = [Select Id, LMS_Required__c,Contract__c from Product_Rights_Group__c WHERE Id IN :productRightsNoLMSGroupId];
        
        for (Product_Rights_Group__c PRG: RPGroupList)
           {
               If (PRG.LMS_Required__c <= 0 ){
               ContractIdwithNoLMSrequired.add(PRG.Contract__c);
               }
           }
    
    
    
         If  (!ContractIdwithNoLMSrequired.IsEmpty() )
                {
                    List<Contract__c> RetriveContractList = [Select Id,LMS_Flag__c,Licensee__r.Licensee_Flag__c from Contract__c where ID IN :ContractIdwithNoLMSrequired];
                    
                    If (RetriveContractList.size() > 0 ){
                        for (Contract__c contract:RetriveContractList )
                        {
                                // Get all contract record to update LMS_Flag Not required
                            contract.LMS_Flag__c = 'No LMS Required';
                            UpdateContractRecords.add(contract);

                         }
                           update UpdateContractRecords;
                    }
        
                }
        else if   (!ContractIdwithLMSrequired.isempty())
                {
                    
                    set<id> contracttoUpdate = new set<id>();
                    List<Contract__c> ContracttoUpdateList = new List<Contract__c>();
                    
                    // Get all contract record to update LMS_Flag Required
                     List<Contract__c> RetriveContractList = [Select Id from Contract__c where ID IN :ContractIdwithLMSrequired AND Licensee__r.Licensee_Flag__c != 'Exempt Partner'];
                     List<Contract__c> ContractLMSList =[Select Id,(Select Id,Contract__c from LMS__r) from Contract__c where Id IN :RetriveContractList];
                     
                      
                    for (Contract__c Con:ContractLMSList)
                    {          
                        contracttoUpdate.add(con.id);
                        
                        for(LMS__c LMS : Con.LMS__r) 
                                {
                                    If (LMS.Contract__c != null)
                                    {
                                        contracttoUpdate.remove(con.id);
                                    }
                                              
                                }
                            
                        }
                    
                    If (!contracttoUpdate.isempty())
                    {
                        
                        List <Contract__c> UpdatecontractList = [Select id,LMS_Flag__c from Contract__c where ID IN :contracttoUpdate ];
                        
                        for (Contract__c contracts: UpdatecontractList)
                        {   
                            Contracts.LMS_Flag__c = 'No LMS\'s Submitted';
                            ContracttoUpdateList.add(contracts);
                        }
                       update ContracttoUpdateList;
                        
                    }
             }
    }
}