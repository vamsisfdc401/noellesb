/***********************************************************************************
Class Name: DGF_ProductAccountTriggerHandler
Purpose: Handler class for Product Account trigger
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             07/08/2017           Jata                Initial Development
******************************************************************************************/
public class DGF_ProductAccountTriggerHandler {
    /*****private declaration*****/
    private static Product_Account__c  prdAccOld;
    
    /***********************************
    Method Name: executeOnBeforeInsert
    Purpose:Should execute only for before insert event
    ***********************************/    
    public static void executeOnBeforeInsert(){
        //first iteration over trigger.new
        for(Product_Account__c pa : (List<Product_Account__c>)trigger.new){
            //Validation for PPV Start Date and PPV End Date
            if(pa.PPV_End_Date__c  != null && pa.PPV_Start_Date__c  != null && Pa.PPV_End_Date__c < pa.PPV_Start_Date__c ){
                pa.addError(DGF_Constants.DGF_PPV_End_Date_should_be_after_PPV_Start_Date);
            }
            //Validation for Push VOD Start Date and Push VOD End Date
            if(pa.Push_VOD_End_Date__c != null && pa.Push_VOD_Start_Date__c != null && Pa.Push_VOD_End_Date__c < pa.Push_VOD_Start_Date__c){
                pa.addError(DGF_Constants.DGF_Push_VOD_End_Date_should_be_after_Push_VOD_Start_Date);
            }
            //Validation for VOD Start Date and VOD End Date
            if(pa.VOD_End_Date__c != null && pa.VOD_Start_Date__c != null && Pa.VOD_End_Date__c < pa.VOD_Start_Date__c  ){
                pa.addError(DGF_Constants.DGF_VOD_End_Date_should_be_after_VOD_Start_Date);
            }
            
        } 
        
    }
    
    /***********************************
    Method Name: executeOnBeforeUpdate
    Purpose:Should execute only for before update event
    ***********************************/    
    public static void executeOnBeforeUpdate(){
        
        //first iteration over trigger.new
        for(Product_Account__c pa : (List<Product_Account__c>)trigger.new){
            prdAccOld = (Product_Account__c)Trigger.oldMap.get(pa.Id);
            //Validation for PPV Start Date and PPV End Date
            if((prdAccOld.PPV_End_Date__c != pa.PPV_End_Date__c || prdAccOld.PPV_Start_Date__c != pa.PPV_Start_Date__c) && pa.PPV_End_Date__c  != null && pa.PPV_Start_Date__c  != null && Pa.PPV_End_Date__c < pa.PPV_Start_Date__c ){
                pa.addError(DGF_Constants.DGF_PPV_End_Date_should_be_after_PPV_Start_Date);
            }
            //Validation for Push VOD Start Date and Push VOD End Date
            if((prdAccOld.Push_VOD_End_Date__c != pa.Push_VOD_End_Date__c || prdAccOld.Push_VOD_Start_Date__c != pa.Push_VOD_Start_Date__c) && pa.Push_VOD_End_Date__c != null && pa.Push_VOD_Start_Date__c != null && Pa.Push_VOD_End_Date__c < pa.Push_VOD_Start_Date__c){
                pa.addError(DGF_Constants.DGF_Push_VOD_End_Date_should_be_after_Push_VOD_Start_Date);
            }
            //Validation for VOD Start Date and VOD End Date
            if((prdAccOld.VOD_End_Date__c != pa.VOD_End_Date__c || prdAccOld.VOD_Start_Date__c != pa.VOD_Start_Date__c) && pa.VOD_End_Date__c != null && pa.VOD_Start_Date__c != null && Pa.VOD_End_Date__c < pa.VOD_Start_Date__c){
                pa.addError(DGF_Constants.DGF_VOD_End_Date_should_be_after_VOD_Start_Date);
            }
            
        } 
        
    }
    
}