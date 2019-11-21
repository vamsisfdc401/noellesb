/***********************************************************************************
Class Name: DGF_DigitalReleaseTriggerHelper
Purpose: Helper class for digital release trigger
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             08/01/2018           Prarthana                Initial Development
******************************************************************************************/
public with sharing class DGF_DigitalReleaseTriggerHelper {
    
    private static Id TvProductAccRecTypeId = Schema.SObjectType.Product_Account__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
    /***********************************
    Method Name: createProductAccounts
    Purpose: method to create TV Product Accounts
    ***********************************/
    public static list<sobject> createProductAccounts(Digital_Release__c dg, Product__c prod,list<sobject>accList) {
        list<sobject> prodAccList = new list<sobject> ();
        for(sobject obj : accList) {
            Account acc = (Account)obj;
            // check if the values on TV Release match the values on account
            if(acc.Categorization__c != null && dg.Categorization__c != null && acc.Categorization__c.contains(dg.Categorization__c) &&
               acc.Scripted_Reality__c != null && dg.Scripted_Reality__c != null && acc.Scripted_Reality__c.contains(dg.Scripted_Reality__c) &&
               //acc.Network_Categorization__c != null && dg.US_Network_Categorization__c != null && acc.Network_Categorization__c.contains(dg.US_Network_Categorization__c) ) { DFOR-1578
               acc.Network_Categorization__c != null && dg.US_Network_Categorization__c != null && acc.Network_Categorization__c.contains(dg.US_Network_Categorization__c) ) {
                   //create Product Account
                   Product_Account__c prdAcc = new Product_Account__c (Product__c = prod.Id , Account__c = acc.Id, RecordTypeId = TvProductAccRecTypeId);
                   //set the value of the launch date
                   if(acc.Territory__c == DGF_Constants.TERRITORY_US && dg.US_EST_Launch_Date__c != null) {
                       prdAcc.launch_date__c = dg.US_EST_Launch_Date__c;
                   }
                   else if(acc.Territory__c == DGF_Constants.TERRITORY_CA && dg.CA_EST_Launch_Date__c != null) {
                       prdAcc.launch_date__c = dg.CA_EST_Launch_Date__c;
                   }
                   prodAccList.add(prdAcc);
               }
            
        }
        return prodAccList;
    }               
    
    /***********************************
    Method Name: createBonusAccounts
    Purpose: method to create TV Bonus Accounts
    ***********************************/
    public static list<sobject> createBonusAccounts(Digital_Release__c dg, EPO_Bonus__c epo,list<sobject>accList) {
        list<sobject> bonusAccList = new list<sobject> ();
        for(sobject obj : accList) {
            Account acc = (Account)obj;
            //chek if values on TV Release match that on the Account
            if(acc.Categorization__c != null && dg.Categorization__c != null && acc.Categorization__c.contains(dg.Categorization__c) &&
               acc.Scripted_Reality__c !=null && dg.Scripted_Reality__c !=null && acc.Scripted_Reality__c.contains(dg.Scripted_Reality__c) &&
               //acc.Network_Categorization__c !=null && dg.US_Network_Categorization__c !=null && acc.Network_Categorization__c.contains(dg.US_Network_Categorization__c)  && DFOR-1578
               acc.Network_Categorization__c !=null && dg.US_Network_Categorization__c !=null && acc.Network_Categorization__c.contains(dg.US_Network_Categorization__c)  &&
               acc.Bonus__c != null && epo.Bonus_Type__c !=null && acc.Bonus__c.contains(epo.Bonus_Type__c)) {
               
                    //create a Bonus Account record
                   Bonus_Account__c bonusAcc = new Bonus_Account__c (Bonus__c = epo.Id , Account__c = acc.Id);
                   //set value of the Start Date
                   if(acc.territory__c ==DGF_Constants.TERRITORY_US && epo.us_start_date__c != null) {
                       bonusAcc.start_date__c = epo.us_start_date__c;
                   }
                   else if(acc.territory__c ==DGF_Constants.TERRITORY_CA && epo.ca_start_date__c != null) {
                       bonusAcc.start_date__c = epo.ca_start_date__c;
                   }
                   bonusAccList.add(bonusAcc);
           }
                       
        }
        return bonusAccList;
    }
    
  
}