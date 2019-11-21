/***********************************************************************************
Class Name: DGF_iTunesPricingUpdateMarginDateBatch
Purpose: Batch class for iTunes Pricing Update Margin Date
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             08/11/2017           Nandeesh               Initial Development
******************************************************************************************/
global with sharing class DGF_iTunesPricingUpdateMarginDateBatch implements Database.Batchable<sObject>,Database.Stateful {
	
    
    /***********************************
    Method Name: start
    Purpose: method to query for Digital Release 
    ***********************************/
    global list<Digital_Release__c> start(Database.BatchableContext BC) {
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        Id FilmRecTypeIdOfRelease = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        Id BundleRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId();
        
        
        list<Digital_Release__c> digitalRelList = [SELECT ID,New_to_UHD_US_EST_Release_Date__c, RecordTypeId, New_to_UHD_CA_EST_Release_Date__c,
                                                   (SELECT Id,RecordTypeId, Digital_Release__r.RecordTypeId, Digital_Release__r.US_Physical_Street_Date__c,
                                                    Digital_Release__r.CA_Physical_Street_Date__c, Digital_Release__r.US_iTunes_Price_Date__c,
                                                    Digital_Release__r.CA_iTunes_Price_Date__c FROM
                                                    Products__r)
                                                   FROM Digital_Release__c
                                                   WHERE (New_to_UHD_US_EST_Release_Date__c =: System.today() OR 
                                                          New_to_UHD_CA_EST_Release_Date__c =: System.today())];
                                                          
       System.debug('EXECUTE??' + digitalRelList   + 'BundleRecTypeId' + BundleRecTypeId + 'FilmRecTypeId' +FilmRecTypeId );
        
        return digitalRelList;
        
    }
    /***********************************
    Method Name: execute
    Purpose: 
    ***********************************/
    global void execute(Database.BatchableContext BC, List<Digital_Release__c> digitalRelList) {
        Id BundleRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId();
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId(); 
        List<Digital_Release__c>releaseListToUpdate = new List<Digital_Release__c>();
        List<Digital_Release__c> bundleReleaseList = new List<Digital_Release__c>();
        List<Pricing__c> priceList = new List<Pricing__c>();
        List<Pricing__c> bundlePriceList = new List<Pricing__c>();
        List<Pricing__c>priceListToDelete = new List<Pricing__c>();
        List<Pricing__c>priceListToUpdate = new List<Pricing__c>();
        List<Pricing__c>priceListToInsert = new List<Pricing__c>();
        
        Pricing_Tier__c matchedTier = new Pricing_Tier__c();
	    //Pricing_Tier__c currTier = new Pricing_Tier__c();
	    Pricing_Tier__c currRepriceTier = new Pricing_Tier__c(); 	
	    
	    System.debug('EXECUTE??' + digitalRelList   + 'BundleRecTypeId' + BundleRecTypeId + 'FilmRecTypeId' +FilmRecTypeId );
	       				
	       				
        Set<Id> prodSet = new Set<Id>();
        Set<Id> bundleProdSet = new Set<Id>();
        Set<Id> pricingSet = new Set<Id>();
        Integer days1;
        Integer days2;
        Integer days3;
        
        // to update US / CA itunes Prices Date in Digital release
        For (Digital_Release__c data : digitalRelList){
        	if(data.recordTypeId !=BundleRecTypeId){
        		if (data.New_to_UHD_US_EST_Release_Date__c == System.today()) {
                	data.US_iTunes_Price_Date__c = data.New_to_UHD_US_EST_Release_Date__c.addMonths(6).addDays(1) ;
	            }
	            if (data.New_to_UHD_CA_EST_Release_Date__c == System.today()) {
	                data.CA_iTunes_Price_Date__c = data.New_to_UHD_CA_EST_Release_Date__c.addMonths(6).addDays(1);
	            }
	            releaseListToUpdate.add(data);
        	}/*else if(data.recordTypeId == BundleRecTypeId){
        		bundleReleaseList.add(data);
        	} */           
        }
        
       
        
        if (!releaseListToUpdate.isEmpty()) {
            Database.update(releaseListToUpdate,False);
        }
        
        // fetch the products related to Release
        For (Digital_Release__c release : digitalRelList){
        	if(release.RecordTypeId == BundleRecTypeId){
        		For(Product__c proId : release.Products__r){
	                //prodSet.add(proId.Id);
	                bundleProdSet.add(proId.Id);
	            }	        		
        	}else{
        		For(Product__c proId : release.Products__r) {
	                prodSet.add(proId.Id);
	            }
        	}
        }
        
         System.debug('bundleProdSet:::' + bundleProdSet);
        
        // fetch the Pricing related to above Products
        if (!prodSet.isEmpty()) {
            priceList =[SELECT ID, Category__c, Platform__c, Account__c, Price_Type__c, Product__c, Resolution__c,
                        SRP__c, Territory__c, iTunes_Tier__c, Valid_From__c, Valid_To__c, WSP__c, Promotion__c,
                        Product__r.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c, Product__r.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c,
                        Product__r.Digital_Release__r.US_iTunes_Price_Date__c, Product__r.Digital_Release__r.CA_iTunes_Price_Date__c
                        FROM Pricing__c
                        WHERE Product__c IN : prodSet
                        AND (Price_Type__c =: DGF_Constants.ORIGINAL OR Price_Type__c =: DGF_Constants.REPRICE)
                        AND Product__r.Digital_Release__r.RecordTypeId != : BundleRecTypeId];
        } 
        
        
        For (Pricing__c pri : priceList) {
            // For US UHD Valid From
            if (pri.Product__r.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c <= pri.Valid_From__c && pri.Territory__c == DGF_Constants.TERRITORY_US && pri.Account__c == DGF_Constants.iTUNES) {
                priceListToDelete.add(pri);
            }
            // for CA UHD Valid From
            if (pri.Product__r.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c <= pri.Valid_From__c && pri.Territory__c == DGF_Constants.TERRITORY_CA && pri.Account__c == DGF_Constants.iTUNES) {
                priceListToDelete.add(pri);
            }
            
            // for US Valid To Date
            if ( ( pri.Product__r.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c <= pri.Valid_To__c || pri.Valid_To__c == null ) && pri.Territory__c == DGF_Constants.TERRITORY_US && pri.Account__c == DGF_Constants.iTUNES && pri.Product__r.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c != null) {
                pri.Valid_To__c = pri.Product__r.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c - 1;
                priceListToUpdate.add(pri);
            }
            
            // for CA Valid To Date
            if ( ( pri.Product__r.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c <= pri.Valid_To__c || pri.Valid_To__c == null ) && pri.Territory__c == DGF_Constants.TERRITORY_CA && pri.Account__c == DGF_Constants.iTUNES && pri.Product__r.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c != null) {
                pri.Valid_To__c = pri.Product__r.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c - 1;
                priceListToUpdate.add(pri);
            }
            
            //for PART C - Creating New for US
            if (pri.Account__c != DGF_Constants.iTUNES && pri.Valid_From__c <= System.today() && ( pri.Valid_To__c >= System.today() || pri.Valid_To__c == null ) && pri.Territory__c == DGF_Constants.TERRITORY_US && pri.Product__r.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c != null && pri.Platform__c == DGF_Constants.PLATFORM_EST ) {
                if (pri.Product__r.Digital_Release__r.US_iTunes_Price_Date__c != null && pri.Valid_From__c != null) {
                    days1=pri.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(pri.Valid_From__c);
                    days2=pri.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(pri.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(6));
                    days3=pri.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(pri.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(18));
                }
                
                Pricing__c iTunes = new Pricing__c (Price_Type__c = pri.Price_Type__c, Account__c=DGF_Constants.iTUNES,
                                                    Category__c = pri.Category__c, Platform__c = pri.Platform__c, Promotion__c = pri.Promotion__c,
                                                    Product__c = pri.Product__c, Resolution__c = pri.Resolution__c,
                                                    SRP__c = pri.SRP__c,  Territory__c = pri.Territory__c, 
                                                    Valid_From__c = System.today() , Valid_To__c = pri.Valid_To__c); 
                
                DGF_TriggerUtility.getDataSetFromBatch = TRUE;
                Pricing__c iTunesWithWSPUS =  DGF_PricingTriggerHandler.CalculateWSPandiTunesTier(iTunes, days1, days2, days3);
                DGF_TriggerUtility.getDataSetFromBatch = FALSE;
                
                priceListToInsert.add(iTunesWithWSPUS);
            }
            //for PART C - Creating New  for CA
            if (pri.Account__c != DGF_Constants.iTUNES && pri.Valid_From__c <= System.today() && ( pri.Valid_To__c >= System.today() || pri.Valid_To__c == null )  && pri.Territory__c == DGF_Constants.TERRITORY_CA && pri.Product__r.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c != null && pri.Platform__c == DGF_Constants.PLATFORM_EST) {
                if (pri.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c != null && pri.Valid_From__c != null) {
                    days1=pri.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(pri.Valid_From__c);
                    days2=pri.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(pri.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(6));
                    days3=pri.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(pri.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(18));
                }
                
                Pricing__c iTunes = new Pricing__c (Price_Type__c = pri.Price_Type__c, Account__c=DGF_Constants.iTUNES,
                                                    Category__c = pri.Category__c, Platform__c = pri.Platform__c, Promotion__c = pri.Promotion__c,
                                                    Product__c = pri.Product__c, Resolution__c = pri.Resolution__c,
                                                    SRP__c = pri.SRP__c,  Territory__c = pri.Territory__c, 
                                                    Valid_From__c = System.today() , Valid_To__c = pri.Valid_To__c); 
                
                DGF_TriggerUtility.getDataSetFromBatch = TRUE;
                Pricing__c iTunesWithWSPCA =  DGF_PricingTriggerHandler.CalculateWSPandiTunesTier(iTunes, days1, days2, days3);
                DGF_TriggerUtility.getDataSetFromBatch = FALSE;
                priceListToInsert.add(iTunesWithWSPCA);
            }
            
            //for PART C - Cloning for US
            if (pri.Valid_From__c > System.today() && pri.Account__c != DGF_Constants.iTUNES && pri.Price_Type__c == DGF_Constants.REPRICE && pri.Territory__c == DGF_Constants.TERRITORY_US && pri.Product__r.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c != null && pri.Platform__c == DGF_Constants.PLATFORM_EST) {
                if(pri.Product__r.Digital_Release__r.US_iTunes_Price_Date__c != null && pri.Valid_From__c != null) {
                    days1=pri.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(pri.Valid_From__c);
                    days2=pri.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(pri.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(6));
                    days3=pri.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.daysBetween(pri.Product__r.Digital_Release__r.US_iTunes_Price_Date__c.addMonths(18));
                }
                
                Pricing__c iTunesClone = new Pricing__c (Price_Type__c=pri.Price_Type__c, Account__c= DGF_Constants.iTUNES ,
                                                         Category__c = pri.Category__c, Platform__c = pri.Platform__c, Promotion__c = pri.Promotion__c,
                                                         Product__c = pri.Product__c, Resolution__c = pri.Resolution__c,
                                                         SRP__c = pri.SRP__c, Territory__c = pri.Territory__c,  
                                                         Valid_From__c = pri.Valid_From__c, Valid_To__c = pri.Valid_To__c);
                
                DGF_TriggerUtility.getDataSetFromBatch = TRUE;
                Pricing__c iTunesCloneWithWSPUS =  DGF_PricingTriggerHandler.CalculateWSPandiTunesTier(iTunesClone, days1, days2, days3);
                DGF_TriggerUtility.getDataSetFromBatch = FALSE;
                priceListToInsert.add(iTunesCloneWithWSPUS);
            }
            //for PART C - Cloning for CA
            if (pri.Valid_From__c > System.today() && pri.Account__c != DGF_Constants.iTUNES && pri.Price_Type__c == DGF_Constants.REPRICE && pri.Territory__c == DGF_Constants.TERRITORY_CA && pri.Product__r.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c != null && pri.Platform__c == DGF_Constants.PLATFORM_EST) {
                if(pri.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c != null && pri.Valid_From__c != null) {
                    days1=pri.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(pri.Valid_From__c);
                    days2=pri.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(pri.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(6));
                    days3=pri.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.daysBetween(pri.Product__r.Digital_Release__r.CA_iTunes_Price_Date__c.addMonths(18));
                }
                Pricing__c iTunesClone = new Pricing__c (Price_Type__c=pri.Price_Type__c, Account__c= DGF_Constants.iTUNES ,
                                                         Category__c = pri.Category__c, Platform__c = pri.Platform__c, Promotion__c = pri.Promotion__c,
                                                         Product__c = pri.Product__c, Resolution__c = pri.Resolution__c,
                                                         SRP__c = pri.SRP__c, Territory__c = pri.Territory__c,  
                                                         Valid_From__c = pri.Valid_From__c, Valid_To__c = pri.Valid_To__c);
                
                DGF_TriggerUtility.getDataSetFromBatch = TRUE;
                Pricing__c iTunesCloneWithWSPCA =  DGF_PricingTriggerHandler.CalculateWSPandiTunesTier(iTunesClone, days1, days2, days3);
                DGF_TriggerUtility.getDataSetFromBatch = FALSE;
                priceListToInsert.add(iTunesCloneWithWSPCA);
            } 
        }
        
        //Bundle Processing        
               
         if (!bundleProdSet.isEmpty()) { 
         	System.debug('Bundle Processing??');
            bundlePriceList =[SELECT ID, Category__c, Platform__c, Account__c, Price_Type__c, Product__c, Resolution__c,
                        SRP__c, Territory__c, iTunes_Tier__c, Valid_From__c, Valid_To__c, WSP__c, Promotion__c,
                        Product__r.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c, Product__r.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c,
                        Product__r.Digital_Release__r.US_iTunes_Price_Date__c, Product__r.Digital_Release__r.CA_iTunes_Price_Date__c,product__r.HDR__c,product__r.UHD__c 
                        FROM Pricing__c
                        WHERE Product__c IN : bundleProdSet
                        AND (Price_Type__c =: DGF_Constants.ORIGINAL OR Price_Type__c =: DGF_Constants.REPRICE) 
                        AND Product__r.Digital_Release__r.recordTypeId = :BundleRecTypeId
                        AND Account__c = :DGF_Constants.iTUNES                        
                        //AND Product__r.Digital_release__r.Initial_Launch_Categorization__c = :'New Release'
                        ];
                        
                        System.debug('bundlePriceList?? SIZE' + bundlePriceList.size());
                        
                        
          List<pricing_tier__c> tierList = [SELECT ID, Product_Type__c, iTunes_Tier__c, Customer_Specific__c, Category__c, WSP__c, SRP__c, Territory__c, Resolution__c, Platform__c, margin__c from Pricing_Tier__c WHERE Customer_Specific__c =: 'iTunes' and Product_Type__c = 'Bundle' 
         order by territory__C , iTunes_Tier__c asc];
                        
	      	For (Pricing__c pri : bundlePriceList) {
	            // For US UHD Valid From
	            matchedTier=null;
	            currRepriceTier = null;
	            
	            if (pri.Product__r.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c <= pri.Valid_From__c && pri.Territory__c == DGF_Constants.TERRITORY_US && pri.Account__c == DGF_Constants.iTUNES) {
	                priceListToDelete.add(pri);
	            }
	            // for CA UHD Valid From
	            if (pri.Product__r.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c <= pri.Valid_From__c && pri.Territory__c == DGF_Constants.TERRITORY_CA && pri.Account__c == DGF_Constants.iTUNES) {
	                priceListToDelete.add(pri);
	            }
	            
	            // for US Valid To Date
	            if ( ( pri.Product__r.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c <= pri.Valid_To__c || pri.Valid_To__c == null ) && pri.Territory__c == DGF_Constants.TERRITORY_US && pri.Account__c == DGF_Constants.iTUNES && pri.Product__r.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c != null) {
	                pri.Valid_To__c = pri.Product__r.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c - 1;
	                priceListToUpdate.add(pri);
	            }
	            
	            // for CA Valid To Date
	            if ( ( pri.Product__r.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c <= pri.Valid_To__c || pri.Valid_To__c == null ) && pri.Territory__c == DGF_Constants.TERRITORY_CA && pri.Account__c == DGF_Constants.iTUNES && pri.Product__r.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c != null) {
	                pri.Valid_To__c = pri.Product__r.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c - 1;
	                priceListToUpdate.add(pri);
	            }
	            
	            //for PART C - Creating New for US OR CA
	            if (pri.Price_Type__c == DGF_Constants.ORIGINAL && pri.product__r.HDR__c ) {
	                if (pri.Valid_From__c != null && ((pri.Territory__c == DGF_Constants.TERRITORY_US && pri.Product__r.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c!=null && pri.Product__r.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c == system.today()) ||
	                (pri.Territory__c == DGF_Constants.TERRITORY_CA && pri.Product__r.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c!=null && pri.Product__r.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c == system.today()))){
		                
		                
		                System.debug('ORIGINAL ENTERED>>');
		                	
		               	for(Pricing_Tier__c pt : tierList){
			         		if(pt.Territory__c != pri.Territory__c || pt.resolution__c != pri.resolution__c || pt.margin__c != DGF_Constants.BUNDLE_iTune_WSP1) continue;
			         		
			         		if(pri.srp__c == pt.srp__c ){
			         			matchedTier = pt;
			         			break;
			         		}
			         	}
			         	
			         	if(matchedTier!=null){
			         		System.debug('MATCHED TIER???' +matchedTier );
			         		
			         		Pricing__c itunesPricing = new Pricing__c (Price_Type__c = pri.Price_Type__c, Account__c = DGF_Constants.iTUNES,
	                                                   Platform__c = pri.Platform__c,
	                                                   Product__c = pri.Product__c, Resolution__c = pri.Resolution__c,
	                                                   srp__c = matchedTier.srp__c, wsp__c = matchedTier.wsp__c,Territory__c = pri.Territory__c,
	                                                   Valid_From__c = System.today() ,Valid_To__c = System.today().addmonths(3),
	                                                   Promotion__c = pri.Promotion__c, iTunes_Tier__c = matchedTier.iTunes_Tier__c);
				             
				             priceListToInsert.add(itunesPricing);        
				             
				             for(Pricing_Tier__c pt : tierList){
				             	decimal currMargin = 0;
				             	currMargin =  100 - (pt.wsp__c / pt.srp__c).setscale(2);
				             	system.debug('currMargin>>>>' + currMargin);
				         		if(pt.Territory__c != pri.Territory__c || pt.resolution__c != pri.resolution__c || currMargin == DGF_Constants.BUNDLE_iTune_WSP1) continue;
				         		
					         		if(matchedTier.srp__c  == pt.srp__c ){
					         			currRepriceTier = pt;
					         			System.debug('REPRICE TIER FOUND>>>????' + currRepriceTier);
					         			break;
					         		}else{
					         			System.debug('REPRICE TIER NOT FOUND>>>' + currRepriceTier + 'matchedTier.srp__c>>' +matchedTier.srp__c + 'pt.srp' + pt.srp__c);
					         		}
				         	}              
				         	
				         	Pricing__c itunesRePricing;
				         	
				         	if(currRepriceTier!=null){         		
				         		  itunesRePricing = new Pricing__c (Price_Type__c = DGF_Constants.REPRICE, Account__c = DGF_Constants.iTUNES,
				                                                   Platform__c = pri.Platform__c,
				                                                   Product__c = pri.Product__c, Resolution__c = pri.Resolution__c,
				                                                   srp__c = currRepriceTier.srp__c, wsp__c = currRepriceTier.wsp__c,Territory__c = pri.Territory__c,
				                                                   Valid_From__c = System.today().addmonths(3).adddays(1),
				                                                   Promotion__c = pri.Promotion__c, iTunes_Tier__c = currRepriceTier.iTunes_Tier__c);
				                  priceListToInsert.add(itunesRePricing);
				                 System.debug('Add Repricing????' + itunesRePricing);
				         	}
				             
		         		}
		           	}
	            }
	            
	        }
            
        } 
        //Bundle iTune Processing Ends
        
        try {
            if (!priceListToUpdate.isEmpty()) {
                Database.update(priceListToUpdate,False);
            }
            if (!priceListToDelete.isEmpty()) {
                Database.delete(priceListToDelete,False);
            }
            if (!priceListToInsert.isEmpty()) {
                Database.Insert(priceListToInsert,False);
            }
        }
        catch (Exception e) {
            DGF_ExceptionLogController.createExceptionLog('Create / Update / Delete Pricing ','DGF_iTunesPricingUpdateMarginDateBatch',e.getMessage());
        }     
    }
    global void finish(Database.BatchableContext BC) {
    }
}