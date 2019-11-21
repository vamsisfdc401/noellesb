/***********************************************************************************
Class Name: DGF_DefaultProductPricing
Purpose: handler for price defaulting
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             11/05/2017           Jata                    Initial Development
******************************************************************************************/
public class DGF_DefaultProductPricing {         
    
    /***********************************
     Method Name: defaultProductPricing
     Purpose: creating instance of pricing records
    ***********************************/
    public static List<Pricing__c> defaultProductPricing(Product__c prd, String resolution){
        
        //declaring variables
        Boolean isUSEST = true;
        Boolean isUSVOD = true;
        Boolean isCAEST = true;
        Boolean isCAVOD = true;
        
        List<Pricing__c> pricingListToInsert = new List<Pricing__c>();
        List<String> usPlatformValues = new List<String>();
        List<String> caPlatformValues = new List<String>();
        Pricing__c prcRecord;
        //checking existing pricing records
        for (Pricing__c prc : prd.Pricing__r) {
            if ((prc.Price_Type__c == DGF_Constants.ORIGINAL || prc.Price_Type__c == DGF_Constants.REPRICE) && prc.Platform__c == DGF_Constants.PLATFORM_EST && prc.Resolution__c == resolution && prc.Territory__c == DGF_Constants.TERRITORY_US && prc.Product__c == prd.Id) {
                isUSEST = false;
            }
            if ((prc.Price_Type__c == DGF_Constants.ORIGINAL || prc.Price_Type__c == DGF_Constants.REPRICE) && prc.Platform__c == DGF_Constants.PLATFORM_VOD && prc.Resolution__c == resolution && prc.Territory__c == DGF_Constants.TERRITORY_US && prc.Product__c == prd.Id) {
                isUSVOD = false;
            }
            if ((prc.Price_Type__c == DGF_Constants.ORIGINAL || prc.Price_Type__c == DGF_Constants.REPRICE) && prc.Platform__c == DGF_Constants.PLATFORM_EST && prc.Resolution__c == resolution && prc.Territory__c == DGF_Constants.TERRITORY_CA && prc.Product__c == prd.Id) {
                isCAEST = false;
            }
            if ((prc.Price_Type__c == DGF_Constants.ORIGINAL || prc.Price_Type__c == DGF_Constants.REPRICE) && prc.Platform__c == DGF_Constants.PLATFORM_VOD && prc.Resolution__c == resolution && prc.Territory__c == DGF_Constants.TERRITORY_CA && prc.Product__c == prd.Id) {
                isCAVOD = false;
            }
        }
        
        
        //splitting multi - select values of US platform offering
        if (prd.US_Platform_Offering__c != null) {
            usPlatformValues.addAll(prd.US_Platform_Offering__c.split(';'));
        }
        
        //splitting multi - select values of CA platform offering
        if (prd.CA_Platform_Offering__c != null) {
            caPlatformValues.addAll(prd.CA_Platform_Offering__c.split(';'));
        }
        
        //if US platform offering is present
        if (usPlatformValues.size()>0) {
            //looping over US platform offering values
            for (String val : usPlatformValues) {
                //if platform offering is EST
                if (val == DGF_Constants.PLATFORM_EST && isUSEST) {
                    //creating an instance of pricing record
                    prcRecord =  new Pricing__c(Platform__c = DGF_Constants.PLATFORM_EST,Category__c = prd.EST_Tier__c,
                                                Resolution__c = resolution,Territory__c = DGF_Constants.TERRITORY_US,Price_Type__c = DGF_Constants.ORIGINAL,
                                                Name = DGF_Constants.TERRITORY_US,Product__c = prd.Id);
                    
                    // Use NewtoUHDESTDate If Original && UHD  
                    if(resolution.equalsIgnoreCase('UHD') && prd.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c!=null){
                    	prcRecord.Valid_From__c = prd.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c;
                    }
                    else if(prd.Digital_Release__r.US_EPO_Date__c == null){//if Pre order date is null then use EST date else pre order date from release
                        prcRecord.Valid_From__c = prd.Digital_Release__r.US_EST_Date__c;
                    } 
                    else {
                        prcRecord.Valid_From__c = prd.Digital_Release__r.US_EPO_Date__c;
                    }
                    
                    //adding instance to pricing list to insert
                    pricingListToInsert.add(prcRecord);
                }
                
                //if platform offering is iVOD or cVOD
                if ((val == DGF_Constants.PLATFORM_IVOD || val == DGF_Constants.PLATFORM_CVOD) && prd.Digital_Release__r.US_Launch_VOD_Categorization__c != null && isUSVOD) {
                    isUSVOD = FALSE;
                    //creating an instance of pricing record
                    prcRecord =  new Pricing__c(Platform__c = DGF_Constants.PLATFORM_VOD,Category__c = prd.Digital_Release__r.US_Launch_VOD_Categorization__c,
                                                Resolution__c = resolution,Territory__c = DGF_Constants.TERRITORY_US,Price_Type__c = DGF_Constants.ORIGINAL,
                                                Valid_From__c = prd.Digital_Release__r.US_VOD_Start_Date__c, 
                                                Valid_To__c = prd.Digital_Release__r.US_VOD_End_Date__c,
                                                Name = DGF_Constants.TERRITORY_US,Product__c = prd.Id);
                    
                    //adding instance to list of records to insert                  
                    pricingListToInsert.add(prcRecord);
                }
            }
        }
        
        //if CA platform offering is present
        if (caPlatformValues.size()>0) {
            for (String val : caPlatformValues) {
                //if platform offering is EST
                if (val == DGF_Constants.PLATFORM_EST && isCAEST) {
                    //creating an instance of pricing record
                    prcRecord =  new Pricing__c(Platform__c = DGF_Constants.PLATFORM_EST,Category__c = prd.CA_EST_Tier__c,
                                                Resolution__c = resolution,Territory__c = DGF_Constants.TERRITORY_CA,Price_Type__c = DGF_Constants.ORIGINAL,
                                                Name = DGF_Constants.TERRITORY_CA,Product__c = prd.Id);
                    
                    // Use NewtoUHDESTDate If Original && UHD  
                    if(resolution.equalsIgnoreCase('UHD') && prd.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c!=null){
                    	prcRecord.Valid_From__c = prd.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c;
                    }else if (prd.Digital_Release__r.CA_EPO_Date__c == null) {  //if pre order date is null then use EST date else use pre order date                
                        prcRecord.Valid_From__c = prd.Digital_Release__r.CA_EST_Date__c;
                    } else {
                        prcRecord.Valid_From__c = prd.Digital_Release__r.CA_EPO_Date__c;
                    }
                    
                    //adding pricing record instance to list
                    pricingListToInsert.add(prcRecord);
                }
                
                //if platform offering is iVOD or cVOD
                if ((val == DGF_Constants.PLATFORM_IVOD || val == DGF_Constants.PLATFORM_CVOD) && prd.Digital_Release__r.CA_Launch_VOD_Categorization__c != null && isCAVOD) {
                    isCAVOD = FALSE;
                    //creatin an instance of pricing record
                    prcRecord =  new Pricing__c(Platform__c = DGF_Constants.PLATFORM_VOD,Category__c = prd.Digital_Release__r.CA_Launch_VOD_Categorization__c,
                                                Resolution__c = resolution,Territory__c = DGF_Constants.TERRITORY_CA,Price_Type__c = DGF_Constants.ORIGINAL,
                                                Valid_From__c = prd.Digital_Release__r.CA_VOD_Start_Date__c, 
                                                Valid_To__c = prd.Digital_Release__r.CA_VOD_End_Date__c,
                                                Name = DGF_Constants.TERRITORY_CA,Product__c = prd.Id);
                    
                    //adding pricing record instance to list
                    pricingListToInsert.add(prcRecord);
                }
            }
        }
        return pricingListToInsert;
    }    
    
    /***********************************
     Method Name: deleteUpdateProductPricing
     Purpose: record to be deleted or updated
    ***********************************/
    public static Map<String, List<sObject>> deleteUpdateProductPricing(Map<ID,Map<String,Set<String>>> trrtryAndResolution, Map<ID,Map<String,Set<String>>> mapProdAndPlatform){
        //declaring variables
        List<Pricing__c> pricingToDelete = new List<Pricing__c>();
        List<Pricing__c> updateablePricing  = new List<Pricing__c>();
        List<Pricing__c> pricingList = new List<pricing__c>([Select Id,Platform__c,Product__c,Territory__c,Valid_From__c,Valid_To__c,Resolution__c from Pricing__c where Product__c in : trrtryAndResolution.keySet() OR Product__c in : mapProdAndPlatform.keySet()]);
        Map<String, List<sObject>> mapPricingDMLRecords = new Map<String, List<sObject>>();
        
        //looping over pricing records
        for (Pricing__c prc : pricingList) {
            Set<String> resoltn = trrtryAndResolution.get(prc.Product__c).get(prc.Territory__c);
            Set<String> platform = mapProdAndPlatform.get(prc.Product__c).get(prc.Territory__c);
            
            if (platform != null) {
                //looping over platform if platform has been removed
                for (String Platfrm : platform) {
                    //scenario for US territory if it is updated or removed
                    if (prc.Platform__c == Platfrm && prc.Territory__c == DGF_Constants.TERRITORY_US && (prc.Valid_From__c > SYSTEM.TODAY() || prc.Valid_From__c == null)) {
                        pricingToDelete.add(prc);
                    }
                    else if (prc.Platform__c == Platfrm && prc.Territory__c == DGF_Constants.TERRITORY_US && prc.Valid_From__c <= SYSTEM.TODAY() && prc.Valid_To__c == null) {
                        prc.Valid_To__c = SYSTEM.TODAY();
                        updateablePricing.add(prc);
                    }
                    
                    //scenario for CA territory if it is updated or removed
                    if (prc.Platform__c == Platfrm && prc.Territory__c == DGF_Constants.TERRITORY_CA && (prc.Valid_From__c > SYSTEM.TODAY() || prc.Valid_From__c == null)) {
                        pricingToDelete.add(prc);
                    }
                    else if (prc.Platform__c == Platfrm && prc.Territory__c == DGF_Constants.TERRITORY_CA && prc.Valid_From__c <= SYSTEM.TODAY() && prc.Valid_To__c == null) {
                        prc.Valid_To__c = SYSTEM.TODAY();
                        updateablePricing.add(prc);
                    }
                }
            }
            if (resoltn != null) {
                //looping over resolutions if presolution has been removed
                for (String res : resoltn) {
                    //scenario if resolution is changed
                    if (prc.Resolution__c == res && (prc.Valid_From__c > SYSTEM.TODAY() || prc.Valid_From__c == null)) {
                        pricingToDelete.add(prc);
                    }
                    else if (prc.Resolution__c == res && prc.Valid_From__c <= SYSTEM.TODAY() && prc.Valid_To__c == null) {
                        prc.Valid_To__c = SYSTEM.TODAY();
                        updateablePricing.add(prc);
                    }
                }
            }
        }
        
        //adding update list to map
        if (!updateablePricing.isEmpty()) {
            mapPricingDMLRecords.put('UPDATE',updateablePricing);
        }
        
        //adding delete list to map
        if (!pricingToDelete.isEmpty()) {
            mapPricingDMLRecords.put('DELETE',pricingToDelete);
        }
        
        return mapPricingDMLRecords;        
    }
    
    public static list<pricing__c> defaultTVPricingforCAFromUS(product__c prod, Digital_Release__c digitalRelease){
    	list<pricing__c> CAPricingRecords = new list<pricing__c>();
    	boolean CAExists = false;
    	date caESTDate = digitalRelease.CA_EST_Launch_Date__c;
    	
    	//list<pricing__c> prodPricingList = new list<pricing__c>();
    	if(prod.pricing__r!=null){
    		for(pricing__c pr: prod.pricing__r){
    			if(pr.Territory__c =='CA'){
    				CAExists = true;
    				break;
    			}
    		}
    		if(!CAExists){ 
    			for(pricing__c pr: prod.pricing__r){
    				if(pr.valid_from__c <=caESTDate && (pr.valid_to__c ==null || pr.valid_to__c > caESTDate) ){
    					Pricing__c caPrice = new Pricing__c(Account__c = pr.Account__c, Category__c = pr.Category__c, 
                                            iTunes_Tier__c = pr.iTunes_Tier__c, 
                                            Platform__c = pr.Platform__c,
                                            Product__c = pr.Product__c, 
                                            Resolution__c = pr.Resolution__c, 
                                            SRP__c = pr.SRP__c, Territory__c = 'CA', WSP__c = pr.WSP__c,
                                            Price_Type__c = DGF_Constants.ORIGINAL, 
                                            Valid_From__c = caESTDate, 
                                            Valid_To__c = null);
                      CAPricingRecords.add(caPrice);                      
    				}
    			}
    		}    		
    	}
    	
    	return CAPricingRecords;
    	 
    }
}