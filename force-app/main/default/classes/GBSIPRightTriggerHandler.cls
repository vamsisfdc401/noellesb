public class GBSIPRightTriggerHandler {

/*****************************************************************
Method Name: buildIPDetailString
Purpose: static method called in 'after' context to build/rebuild string
containing Product Details in a Product Rights Group Record (GBS-218)
***************************************************************/   

    public static void buildIPDetailString(){
        //Get the Intellectual Property Rights Group Ids associated to trigger.new
        Set<Id> productRightsGroupId = new Set<Id>();
        
        if(Trigger.IsInsert || Trigger.IsUpdate)
        {
            for (Intellectual_Property_Right__c pr : (List<Intellectual_Property_Right__c>)trigger.new){
                if(pr.Product_Rights_Group__c != NULL){
                    productRightsGroupId.add(pr.Product_Rights_Group__c);
                }
            }
        }
        else if(Trigger.IsDelete)
        {
            for (Intellectual_Property_Right__c pr : (List<Intellectual_Property_Right__c>)trigger.old){
                
                if(pr.Product_Rights_Group__c != NULL){
                    productRightsGroupId.add(pr.Product_Rights_Group__c);
                }
            }
        }
        
        //Get the Intellectual Property Right records related to those Product Rights Groups
        List<Intellectual_Property_Right__c> ipList = [Select Id, Product_Rights_Group__c, Intellectual_Property__r.Name from Intellectual_Property_Right__c WHERE (Product_Rights_Group__c IN :productRightsGroupId)];

        //construct List to put updated IP Detail string on        
        List<Product_Rights_Group__c> productRightsGroupList = [Select Id, IP_Details__c from Product_Rights_Group__c WHERE Id IN :productRightsGroupId];

        //Iterate through the Product Rights Groups and Intellectual Property Rights to update the IP Details string
        for (Product_Rights_Group__c prg : productRightsGroupList){
            //Reset string to blank
            prg.IP_Details__c = '';
            
            //Concatenate name into IP Details field on PRG
            for(Intellectual_Property_Right__c ip: ipList){
                if(ip.Product_Rights_Group__c == prg.Id){
                    prg.IP_Details__c += ip.Intellectual_Property__r.Name + '; ';
                }
            }
        }
        
        update productRightsGroupList;
        
    }
}