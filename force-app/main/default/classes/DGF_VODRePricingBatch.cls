/***********************************************************************************
Class Name: DGF_VODRePricingBatch
Purpose: Batch class for VOD Repricing
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             17/05/2017           Prarthana                Initial Development
******************************************************************************************/
global with sharing class DGF_VODRePricingBatch implements Database.Batchable<sObject>,Database.Stateful{
  
    /***********************************
    Method Name: start
    Purpose: method to query for Products which have reached end of VOD Window
    ***********************************/
    global list<Product__c> start(Database.BatchableContext BC){
        //query for prodcuts and the associated pricing records where VOD End Date=today
        list<Product__c>prodList=[SELECT ID,RecordTypeId,Digital_Release__r.RecordTypeId,US_VOD_Tier__c,CA_VOD_Tier__c,Digital_Release__c,Digital_Release__r.CA_Day_and_Date_VOD_End_Date__c,Digital_Release__r.US_Day_and_Date_VOD_End_Date__c,Digital_Release__r.CA_Pre_Theatrical_VOD_End_Date__c,Digital_Release__r.US_Pre_Theatrical_VOD_End_Date__c,Digital_Release__r.CA_New_Release_Standard_VOD_End_Date__c,Digital_Release__r.US_New_Release_Standard_VOD_End_Date__c,Digital_Release__r.US_VOD_End_Date__c from Product__c where Digital_Release__r.CA_Day_and_Date_VOD_End_Date__c=:date.today() OR Digital_Release__r.US_Day_and_Date_VOD_End_Date__c=:date.today() OR Digital_Release__r.CA_Pre_Theatrical_VOD_End_Date__c=:date.today() OR Digital_Release__r.US_Pre_Theatrical_VOD_End_Date__c=:date.today() OR Digital_Release__r.CA_New_Release_Standard_VOD_End_Date__c=:Date.today() OR Digital_Release__r.US_New_Release_Standard_VOD_End_Date__c=:date.today()   ];
        return prodList;
    }
    
    /***********************************
    Method Name: execute
    Purpose: method to create repricing records
    ***********************************/
    global void execute(Database.BatchableContext BC, List<Product__c> prodList){
   
        list<Pricing__c>pricingToBeInsertedList=new list<Pricing__c>();
        list<Pricing__c>pricingToBeUpdatedList=new list<Pricing__c>();
        set<Id>prodIdSet=new set<Id>();
        map<String,Pricing_Tier__c>ptMap=new map<String,Pricing_Tier__c>();
        list<Product__c>prodToBeUpdatedList=new list<Product__c>();
         Id FilmReleaseRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
          Id FilmProdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
          //query for the VOD Pricing Tiers of Film Type
          list<Pricing_Tier__c>pricingtierList=[SELECT Category__c,Platform__c,Product_Type__c,Resolution__c,Territory__c,WSP__c,SRP__c FROM Pricing_Tier__c where Product_Type__c=:DGF_Constants.FILM  and Platform__c=:DGF_Constants.PLATFORM_VOD];
          for(Pricing_Tier__c pt:pricingtierList){
            ptMap.put(pt.Category__c+':'+pt.Resolution__c+':'+pt.Territory__c,pt);
          }
        
        //prepare set of Product ID's
        for(Product__c prod:prodList){
            prodIdSet.add(prod.id);
            
        }
        System.debug('pr.........'+prodList);
        //Query for the pricing records of the queried products
        list<Pricing__c>priceList=[SELECT ID,Product__r.Digital_Release__r.CA_New_Release_Standard_VOD_Start_Date__c,Product__r.Digital_Release__r.CA_Day_and_Date_VOD_Start_Date__c,Product__r.Digital_Release__r.US_New_Release_Standard_VOD_Start_Date__c,Product__r.Digital_Release__r.US_Day_and_Date_VOD_Start_Date__c,Category__c,Platform__c,Price_Type__c,Product__c,Resolution__c,SRP__c,Territory__c,Valid_From__c,Valid_To__c ,WSP__c,Product__r.Digital_Release__r.US_VOD_End_Date__c,product__R.Digital_Release__r.CA_VOD_End_Date__c,Product__r.US_VOD_Tier__c,Product__r.Digital_Release__r.US_Pre_Theatrical_VOD_End_Date__c,Product__r.CA_VOD_Tier__c,Product__r.Digital_Release__r.CA_Pre_Theatrical_VOD_End_Date__c,Product__r.Digital_Release__r.US_Day_and_Date_VOD_End_Date__c,Product__r.Digital_Release__r.CA_Day_and_Date_VOD_End_Date__c,Product__r.Digital_Release__r.US_New_Release_Standard_VOD_End_Date__c,Product__r.Digital_Release__r.CA_New_Release_Standard_VOD_End_Date__c from Pricing__c where Platform__c=:DGF_Constants.PLATFORM_VOD and product__c in:prodList];
        
        
        //iterate over the fetched products
        for(Product__c prod:prodList){
            //check if associated pricing records exist
            if(prod.RecordTypeId==FilmProdRecTypeId && prod.Digital_Release__r.RecordTypeId==FilmReleaseRecTypeId){
                if(!priceList.isEmpty()){
                    //iterate over the pricing
                    for(Pricing__c pr:priceList){
                        //check if the pricing's product matches the Product that we are iterating on
                        if(pr.product__c==prod.id){
                            //for US Territory
                            if(pr.Territory__c=='US'){
                            
                                    //for VOD Tier Pre theatrical
                                    if(pr.Product__r.US_VOD_Tier__c==DGF_Constants.PRE_THEATRICAL && pr.Product__r.Digital_Release__r.US_Pre_Theatrical_VOD_End_Date__c==date.today()){
                                        //create the repricing record
                                  
                                        Pricing__c rePrice=new Pricing__c(Price_Type__c=DGF_Constants.REPRICE ,Category__c=DGF_Constants.DAY_AND_DATE,Valid_From__c=pr.Product__r.Digital_Release__r.US_Day_and_Date_VOD_Start_Date__c,Platform__c=pr.Platform__c,Product__c=pr.Product__c,Resolution__c=pr.Resolution__c,Territory__c=pr.Territory__c);
                                        if(ptmap.containsKey(DGF_Constants.DAY_AND_DATE+':'+pr.Resolution__c+':'+pr.Territory__c)){
                                            rePrice.WSP__c=ptmap.get(DGF_Constants.DAY_AND_DATE+':'+pr.Resolution__c+':'+pr.Territory__c).WSP__c;
                                            rePrice.SRP__c=ptmap.get(DGF_Constants.DAY_AND_DATE+':'+pr.Resolution__c+':'+pr.Territory__c).SRP__c;
                                        }
                                       
                                        pricingToBeInsertedList.add(rePrice);
                                        //update validTo date on old priing record
                                        if(pr.category__c==DGF_Constants.PRE_THEATRICAL && (pr.Price_Type__c==DGF_Constants.ORIGINAL ||pr.Price_type__c==DGF_Constants.REPRICE ) ){
                                            pr.Valid_To__c=date.today();
                                            pricingToBeUpdatedList.add(pr);
                                        }
                                        prod.US_VOD_Tier__c=DGF_Constants.DAY_AND_DATE;
                                        prodToBeUpdatedList.add(prod);
                                       
                                    }
                                    //for VOD Tier Day and Date
                                    else if(pr.Product__r.US_VOD_Tier__c==DGF_Constants.DAY_AND_DATE && pr.Product__r.Digital_Release__r.US_Day_and_Date_VOD_End_Date__c==date.today()){
                                        //create the repricing record
                                        Pricing__c rePrice=new Pricing__c(Price_Type__c=DGF_Constants.REPRICE,Category__c=DGF_Constants.CURRENT,Valid_From__c=pr.Product__r.Digital_Release__r.US_New_Release_Standard_VOD_Start_Date__c,Platform__c=pr.Platform__c,Product__c=pr.Product__c,Resolution__c=pr.Resolution__c,Territory__c=pr.Territory__c);
                                      
                                        if(ptmap.containsKey(DGF_Constants.CURRENT+':'+pr.Resolution__c+':'+pr.Territory__c)){
                                            rePrice.WSP__c=ptmap.get(DGF_Constants.CURRENT+':'+pr.Resolution__c+':'+pr.Territory__c).WSP__c;
                                            rePrice.SRP__c=ptmap.get(DGF_Constants.CURRENT+':'+pr.Resolution__c+':'+pr.Territory__c).SRP__c;
                                        }
                                          pricingToBeInsertedList.add(rePrice);
                                        //update validTo date on old priing record
                                        if(pr.category__c==DGF_Constants.DAY_AND_DATE && (pr.Price_Type__c==DGF_Constants.ORIGINAL||pr.Price_type__c==DGF_Constants.REPRICE)){
                                            pr.Valid_To__c=date.today();
                                            pricingToBeUpdatedList.add(pr);
                                        }
                                        prod.US_VOD_Tier__c=DGF_Constants.CURRENT;
                                        prodToBeUpdatedList.add(prod);
                                        
                                    }
                                     //for VOD Tier New Release Premium or New Release Standard
                                    else if(pr.Product__r.US_VOD_Tier__c==DGF_Constants.CURRENT && pr.Product__r.Digital_Release__r.US_New_Release_Standard_VOD_End_Date__c==date.today() ){
                                        //create the repricing record
                                        Pricing__c rePrice=new Pricing__c(Price_Type__c=DGF_Constants.REPRICE,Category__c=DGF_Constants.CATALOG,Valid_From__c=pr.Product__r.Digital_Release__r.US_New_Release_Standard_VOD_End_Date__c+1,Platform__c=pr.Platform__c,Product__c=pr.Product__c,Resolution__c=pr.Resolution__c,Territory__c=pr.Territory__c);
                                       
                                        if(ptmap.containsKey(DGF_Constants.CATALOG+':'+pr.Resolution__c+':'+pr.Territory__c)){
                                            rePrice.WSP__c=ptmap.get(DGF_Constants.CATALOG+':'+pr.Resolution__c+':'+pr.Territory__c).WSP__c;
                                            rePrice.SRP__c=ptmap.get(DGF_Constants.CATALOG+':'+pr.Resolution__c+':'+pr.Territory__c).SRP__c;
                                        }
                                         pricingToBeInsertedList.add(rePrice);
                                        //update validTo date on old priing record
                                        if(pr.category__c==DGF_Constants.CURRENT && (pr.Price_Type__c==DGF_Constants.ORIGINAL||pr.Price_type__c==DGF_Constants.REPRICE)){
                                            pr.Valid_To__c=date.today();
                                            pricingToBeUpdatedList.add(pr);
                                        }
                                        prod.US_VOD_Tier__c=DGF_Constants.CATALOG;
                                        prodToBeUpdatedList.add(prod);
                                    }
                                
                            }
                            //for CA Territory
                            else if(pr.Territory__c=='CA'){
                                //if CA Vod end date=today
                                //if(pr.Product__r.Digital_Release__r.CA_VOD_End_Date__c==date.today()){
                                    //for VOD Tier Pre theatrical
                                    if(pr.Product__r.CA_VOD_Tier__c==DGF_Constants.PRE_THEATRICAL && pr.Product__r.Digital_Release__r.CA_Pre_Theatrical_VOD_End_Date__c==date.today()){
                                        //create the repricing record
                                        Pricing__c rePrice=new Pricing__c(Price_Type__c=DGF_Constants.REPRICE,Category__c=DGF_Constants.DAY_AND_DATE,Valid_From__c=pr.Product__r.Digital_Release__r.CA_Day_and_Date_VOD_Start_Date__c,Platform__c=pr.Platform__c,Product__c=pr.Product__c,Resolution__c=pr.Resolution__c,Territory__c=pr.Territory__c);
                                        if(ptmap.containsKey(DGF_Constants.DAY_AND_DATE+':'+pr.Resolution__c+':'+pr.Territory__c)){
                                            rePrice.WSP__c=ptmap.get(DGF_Constants.DAY_AND_DATE+':'+pr.Resolution__c+':'+pr.Territory__c).WSP__c;
                                            rePrice.SRP__c=ptmap.get(DGF_Constants.DAY_AND_DATE+':'+pr.Resolution__c+':'+pr.Territory__c).SRP__c;
                                        }
                                        pricingToBeInsertedList.add(rePrice);
                                        //update validTo date on old priing record
                                        if(pr.category__c==DGF_Constants.PRE_THEATRICAL && (pr.Price_Type__c==DGF_Constants.ORIGINAL||pr.Price_type__c==DGF_Constants.REPRICE)){
                                            pr.Valid_To__c=date.today();
                                            pricingToBeUpdatedList.add(pr);
                                        }
                                        prod.CA_VOD_Tier__c=DGF_Constants.DAY_AND_DATE;
                                        prodToBeUpdatedList.add(prod);
                                    }
                                    //for VOD Tier Day and Date
                                    else if(pr.Product__r.CA_VOD_Tier__c==DGF_Constants.DAY_AND_DATE && pr.Product__r.Digital_Release__r.CA_Day_and_Date_VOD_End_Date__c==date.today()){
                                        System.debug('day and date............');
                                        //create the repricing record
                                        Pricing__c rePrice=new Pricing__c(Price_Type__c=DGF_Constants.REPRICE,Category__c=DGF_Constants.CURRENT,Valid_From__c=pr.Product__r.Digital_Release__r.CA_New_Release_Standard_VOD_Start_Date__c,Platform__c=pr.Platform__c,Product__c=pr.Product__c,Resolution__c=pr.Resolution__c,Territory__c=pr.Territory__c);
                                        if(ptmap.containsKey(DGF_Constants.CURRENT+':'+pr.Resolution__c+':'+pr.Territory__c)){
                                            rePrice.WSP__c=ptmap.get(DGF_Constants.CURRENT+':'+pr.Resolution__c+':'+pr.Territory__c).WSP__c;
                                            rePrice.SRP__c=ptmap.get(DGF_Constants.CURRENT+':'+pr.Resolution__c+':'+pr.Territory__c).SRP__c;
                                        }
                                        pricingToBeInsertedList.add(rePrice);
                                        //update validTo date on old priing record
                                       if(pr.category__c==DGF_Constants.DAY_AND_DATE && (pr.Price_Type__c==DGF_Constants.ORIGINAL||pr.Price_type__c==DGF_Constants.REPRICE)){
                                            pr.Valid_To__c=date.today();
                                            pricingToBeUpdatedList.add(pr);
                                        }
                                        prod.CA_VOD_Tier__c=DGF_Constants.CURRENT;
                                        prodToBeUpdatedList.add(prod);
                                    }
                                     //for VOD Tier New Release Premium or New Release Standard
                                    else if(pr.Product__r.CA_VOD_Tier__c==DGF_Constants.CURRENT && pr.Product__r.Digital_Release__r.CA_New_Release_Standard_VOD_End_Date__c==date.today() ){
                                        //create the repricing record
                                        Pricing__c rePrice=new Pricing__c(Price_Type__c=DGF_Constants.REPRICE,Category__c=DGF_Constants.CATALOG,Valid_From__c=pr.Product__r.Digital_Release__r.CA_New_Release_Standard_VOD_End_Date__c+1,Platform__c=pr.Platform__c,Product__c=pr.Product__c,Resolution__c=pr.Resolution__c,Territory__c=pr.Territory__c);
                                        if(ptmap.containsKey(DGF_Constants.CATALOG+':'+pr.Resolution__c+':'+pr.Territory__c)){
                                            rePrice.WSP__c=ptmap.get(DGF_Constants.CATALOG+':'+pr.Resolution__c+':'+pr.Territory__c).WSP__c;
                                            rePrice.SRP__c=ptmap.get(DGF_Constants.CATALOG+':'+pr.Resolution__c+':'+pr.Territory__c).SRP__c;
                                        }
                                        pricingToBeInsertedList.add(rePrice);
                                        //update validTo date on old priing record
                                        if(pr.category__c==DGF_Constants.CURRENT && (pr.Price_Type__c==DGF_Constants.ORIGINAL||pr.Price_type__c==DGF_Constants.REPRICE)){
                                            pr.Valid_To__c=date.today();
                                            pricingToBeUpdatedList.add(pr);
                                        }
                                        prod.CA_VOD_Tier__c=DGF_Constants.CATALOG;
                                        prodToBeUpdatedList.add(prod);
                                    }
                               
                            }
                        }
                    }
                    
                }
            }
        }
        //performing DML
        try{
        
            if(!pricingToBeUpdatedList.isEmpty()){
                database.update(pricingToBeUpdatedList);
            }
            if(!pricingToBeInsertedList.isEmpty()){
                database.insert(pricingToBeInsertedList);
            }
            
            if(!prodToBeUpdatedList.isEmpty()){
                map<Id,Product__c> prodMap=new map<Id,Product__c>();
                for(Product__c pr:prodToBeUpdatedList){
                    prodMap.put(pr.id,pr);
                }
                database.update(prodMap.values());
            }
        }
        catch(Exception e){
         System.debug('Exception.......'+e.getMessage());
         DGF_ExceptionLogController.createExceptionLog('After insert of Pricing records','DGF_VODRepricingBatch',e.getMessage());
        }
        
    }
     global void finish(Database.BatchableContext BC){
     }
}