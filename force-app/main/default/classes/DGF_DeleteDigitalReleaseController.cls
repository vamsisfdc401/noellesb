/*****************************************************************************************
Class Name: DGF_DeleteDigitalReleaseController
Purpose: Controller for release deletion component
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             15/05/2017           Mohit                    Initial Development
******************************************************************************************/
public without sharing class DGF_DeleteDigitalReleaseController{
    
    /***********************************
    Method Name: hasDeleteAccess
    Purpose: only specific user profiles have delete access
    ***********************************/
    @AuraEnabled public static boolean hasDeleteAccess(ID releaseID){
        //gettin user details
        User u = [Select id,name,Profile.Name from User where id=:userinfo.getUserId()];
        
        //if product user or admin then true 
        if(u.Profile.Name == DGF_Constants.PROFILE_PRODUCT_USER || u.Profile.Name == DGF_Constants.PROFILE_SYS_ADMIN){
            return TRUE;
        }
        else{
            return FALSE;
        }
    }
    
    /***********************************
    Method Name: fetchTitleVersions
    Purpose: method to fetch title versions for matching title
    ***********************************/
    @AuraEnabled public static string deleteRelease(ID releaseID){
        try{
            
            string retURL;
            
            System.Debug('check release ID '+releaseID);
            
            //checking if release ID is not null
            if(releaseID != null){
                
                //on deletion user will be redirected to digital release tab
                retURL = string.valueof(releaseID).substring(0,3);
                
                //getting list of products to delete
                List<Product__c> lstProdsToDelete = [Select Id from Product__c where Digital_Release__c =: releaseID];
                
                //getting list of products pricing to delete
                List<Pricing__c> lstProdPricingToDelete = [Select Id from Pricing__c where Product__c in: lstProdsToDelete];
                
                //getting list of product versions to delete
                List<Product_Version__c> lstProdVersionToDelete = [Select Id from Product_Version__c where Product__c in:lstProdsToDelete];
                
                //getting list of product account to delete
                List<Product_Account__c> lstProdAccountToDelete = [Select id from Product_Account__c where Product__c in:lstProdsToDelete];
                
                //getting list of Bonus records to delete
                List<EPO_Bonus__c> lstBonusToDelete = [Select Id from EPO_Bonus__c where Digital_Release__c =: releaseID];
                
                //getting list of Bonus accounts to delete
                List<Bonus_Account__c> lstBonusAccountToDelete = [Select id from Bonus_Account__c where Bonus__c in: lstBonusToDelete];
                
                //getting list of SVOD to delete
                List<Catalog_Window__c> lstSVODWindow = [Select id from Catalog_Window__c where Digital_Release__c =:releaseID];
                
                //Digital Date
                List<Digital_Date__c> lstDigitalDates = [Select id from Digital_Date__c where Digital_Release__c =:releaseID];
                
                //delete SVOD window if not empty
                if(!lstSVODWindow.isEmpty()){
                    delete lstSVODWindow;                   
                }
                
                //delete digital Dates if not empty
                if(!lstDigitalDates.isEmpty()){
                    delete lstDigitalDates;                   
                }
                
                //delete product versions if not empty
                if(!lstProdVersionToDelete.isEmpty()){
                    delete lstProdVersionToDelete;
                }
                
                //delete product pricing
                if(!lstProdPricingToDelete.isEmpty()){
                    delete lstProdPricingToDelete;
                }
                
                //delete product accounts if not empty
                if(!lstProdAccountToDelete.isEmpty()){
                    delete lstProdAccountToDelete;
                }
                
                //delete bonus account if not empty
                if(!lstBonusAccountToDelete.isEmpty()){
                    delete lstBonusAccountToDelete;
                }
                
                //delete Bonus records
                if(!lstBonusToDelete.isEmpty()){
                    delete lstBonusToDelete;
                }
                
                //delete products 
                if(!lstProdsToDelete.isEmpty()){
                    delete lstProdsToDelete;
                }
                                
                //delete digital release
                Digital_Release__c dgRel = new Digital_Release__c();
                dgRel.ID = releaseID;
                
                delete dgRel;
            }
            
            return retURL;        
        }
        catch(exception ex){
            System.Debug('Error @@@ '+ex.getMessage());   
            throw new AuraHandledException(ex.getMessage());
            return null;
        } 
    }
}