/***********************************************************************************
Class Name: DGF_iTunesRepricingBatch
Purpose: Batch class for iTunes Repricing
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             22/05/2017           Jata                Initial Development
******************************************************************************************/
global with sharing class DGF_iTunesRepricingBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    /***********************************
     Method Name: start
     Purpose: method to query for Products 
    ***********************************/
    global list<Product__c> start(Database.BatchableContext BC) {
        //query for prodcuts and the associated pricing records 
        Id FilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        Id FilmRecTypeIdOfRelease = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        list<Product__c> prodList=[SELECT ID, RecordTypeId, Digital_Release__r.RecordTypeId, Digital_Release__r.US_Physical_Street_Date__c,
                                   Digital_Release__r.CA_Physical_Street_Date__c, Digital_Release__r.US_iTunes_Price_Date__c,
                                   Digital_Release__r.CA_iTunes_Price_Date__c,
                                   (SELECT ID, Category__c, Platform__c, Account__c, Price_Type__c, Product__c, Resolution__c,
                                    SRP__c, Territory__c, iTunes_Tier__c, Valid_From__c, Valid_To__c, WSP__c, Promotion__c,
                                    Product__r.Digital_Release__r.US_EST_Date__c, Product__r.Digital_Release__r.CA_EST_Date__c,
                                    Product__r.Digital_Release__r.US_Physical_Street_Date__c, Product__r.Digital_Release__r.CA_Physical_Street_Date__c,
                                    Product__r.Digital_Release__r.US_iTunes_Price_Date__c, Product__r.Digital_Release__r.CA_iTunes_Price_Date__c
                                    from Pricing__r where Account__c =: DGF_Constants.iTUNES) from Product__c where
                                   RecordTypeID =: FilmRecTypeId and
                                   Digital_Release__r.RecordTypeID =: FilmRecTypeIdOfRelease and
                                   (Digital_Release__r.US_iTunes_Price_Date__c =: System.today() OR 
                                    Digital_Release__r.CA_iTunes_Price_Date__c =: System.today())];
        return prodList;
    }
    
    /***********************************
     Method Name: execute
     Purpose: method to create repricing records
    ***********************************/
    global void execute(Database.BatchableContext BC, List<Product__c> prodList) {
        List<Pricing__c> pricingListToUpdate = new List<Pricing__c>();
        List<Pricing__c> pricingListToInsert = new List<Pricing__c>();
        
        //looping over product List
        for (Product__c prod:prodList) {
            
            if (prod.Digital_Release__r.US_iTunes_Price_Date__c == System.today() || 
                prod.Digital_Release__r.CA_iTunes_Price_Date__c == System.today()) {
                    for (Pricing__c pr : prod.Pricing__r) {
                         Date Change1;
                         Date Change2;
                        if (pr.Territory__c == 'US' && pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c != null 
                           && pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c == System.today()) {
                            Change1 = pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(6);
                            Change2 = pr.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(18);  
                        }
                        else if (pr.Territory__c == 'CA' && pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c != null
                                && pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c == System.today()) {
                            Change1 = pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(6);
                            Change2 = pr.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(18);
                        }
                        //closing out existing iTune records
                        if (pr.Account__c == DGF_Constants.iTUNES && pr.Valid_From__c <= System.today() && (pr.Valid_To__c == null || pr.Valid_To__c > System.today()) 
                        && (pr.Price_Type__c == DGF_Constants.ORIGINAL || pr.Price_Type__c == DGF_Constants.REPRICE) && Change1 != null && Change2 != null) {
                            pr.Valid_To__c = Change1 - 1;//closing out existing pricing record
                            pricingListToUpdate.add(pr);
                            //Create new Reprice1 record
                            Pricing__c itunesPricing1 = new Pricing__c (Price_Type__c=DGF_Constants.REPRICE,Account__c=pr.Account__c,
                                                                        Category__c=pr.Category__c,Platform__c=pr.Platform__c,Promotion__c=pr.Promotion__c,
                                                                        Product__c=pr.Product__c,Resolution__c=pr.Resolution__c,
                                                                        SRP__c=pr.SRP__c,Territory__c=pr.Territory__c,iTunes_Tier__c = pr.iTunes_Tier__c,
                                                                        Valid_From__c=change1,Valid_To__c=change2 - 1);
                            if (pr.SRP__c != null) {
                                itunesPricing1.WSP__c=pr.srp__c*.85; 
                            }
                            
                            //Create new Reprice2 record
                            Pricing__c itunesPricing2 = new Pricing__c (Price_Type__c=DGF_Constants.REPRICE,Account__c=pr.Account__c,
                                                                        Category__c=pr.Category__c,Platform__c=pr.Platform__c,Promotion__c=pr.Promotion__c,
                                                                        Product__c=pr.Product__c,Resolution__c=pr.Resolution__c,
                                                                        SRP__c=pr.SRP__c,Territory__c=pr.Territory__c,iTunes_Tier__c = pr.iTunes_Tier__c,
                                                                        Valid_From__c=change2,Valid_To__c=null);
                            if (pr.SRP__c != null) {
                                itunesPricing2.WSP__c=pr.srp__c*.775;
                            }
                            
                            pricingListToInsert.add(itunesPricing1);
                            pricingListToInsert.add(itunesPricing2); 
                           
                        }
                    }
                }
        }

        //performing DML
        try {
            if (!pricingListToUpdate.isEmpty()) {
                Database.update(pricingListToUpdate,False);
            }
            if (!pricingListToInsert.isEmpty()) {
              Database.insert(pricingListToInsert,False);
            }
            
        }
        catch (Exception e) {
            DGF_ExceptionLogController.createExceptionLog('After insert of Pricing records','DGF_iTunesRepricingBatch',e.getMessage());
        }
    }
    
    /***********************************
     Method Name: finish
     Purpose: 
    ***********************************/
    global void finish(Database.BatchableContext BC) {
    }
}