/*****************************************************************************************
Class Name: DGF_NewProductComponentController
Purpose: Controller for new product component
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             02/05/2017           Mohit                    Initial Development
******************************************************************************************/
public with sharing class DGF_NewProductComponentController {  
    
    /**private instance**/
    private static Id FilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
    private static Id TVRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
    private static Id BundleRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId(); 
    
    /***********************************
    Method Name: fetchTitleVersions
    Purpose: method to fetch title versions for matching title
    ***********************************/
    @AuraEnabled public static List<TitleVersionWrapper> fetchTitleVersions(ID releaseID,String searchKeyWord) {
        try {
            
            //storing search key word in a variable
            String searchKey = '%' + searchKeyWord + '%';
            
            //setting different rights variable
            Boolean isUSESTRght = FALSE;
            Boolean isUSVODRght = FALSE;
            Boolean isCAESTRght = FALSE;
            Boolean isCAVODRght = FALSE;
            
            Boolean isBundle = FALSE;
            set<id> tmVersionIdSet = new set<id>();
            set<id> tmVersionIdSetwthProduct = new set<id>();
            
            
            //list of type wrapper to be returned
            List<TitleVersionWrapper> returnTitleVersionList = new List<TitleVersionWrapper>();
            
            //getting release details
            List<Digital_Release__c> lstDigitalRelease = [Select id, name, RecordType.Name, Title__c from Digital_Release__c where ID =: releaseID];
            
            if(DGF_Constants.BUNDLE.equalsIgnoreCase(lstDigitalRelease[0].RecordType.Name)){
            	isBundle = True;
            }
            
            //querying all matching titles along with version and right details           
            List <Title__c> lstOfTitles = [select id, name, Network_of_Air_Date__c, Pilot_Flag__c,(Select id, name, TVD_SAFE_Production_ID__c, 
                                                                                                   Version_EIDR__c, Original_Flag__c from TM_Versions__r where TVD_SAFE_Production_ID__c != null),
                                           (Select id, name, Platform__c, Territory__c, Rights__c from Rights__r) from Title__c where Name LIKE: searchKey OR Tags__c LIKE : searchKey limit 5000];
                        
            //if list not empty        
            if (!lstOfTitles.isEmpty()) {
            	
            	//If Release is Bundle Gather TitleVersions and Search for Product Associations. DFOR - 1574
            	if(isBundle){
            		for (Title__c title : lstOfTitles) {
            			for(TM_Version__c tm : title.TM_Versions__r){
	            			tmVersionIdSet.add(tm.id);
	            		}
	            	}
	            	if(tmVersionIdSet!=null && tmVersionIdSet.size()>0){
	            		list<product_version__c> tmWithProdList = [select id, TM_Version__c, product__c from Product_Version__c where Product__r.RecordType.name != :DGF_Constants.BUNDLE and TM_Version__c in :tmVersionIdSet ];
	            		if(tmWithProdList!=null && tmWithProdList.size()>0){
	            			for(product_version__c pv: tmWithProdList){
	            				tmVersionIdSetwthProduct.add(pv.TM_Version__c);
	            			}
	            		}
	            	}            		
            	}
            	
            	
                
                //looping over title details
                for (Title__c title : lstOfTitles) {
                    
                    //if release has a title then only populate the versions related to that 
                    if (lstDigitalRelease[0].Title__c != null && lstDigitalRelease[0].Title__c != title.Id) {
                        continue;
                    }
                    
                    //looping over related tm versions
                    for (TM_Version__c tm : title.TM_Versions__r) {
                        isUSESTRght = FALSE;
                        isUSVODRght = FALSE;
                        isCAESTRght = FALSE;
                        isCAVODRght = FALSE;
                        
                        //looping over related rights
                        for (Right__c rght : title.Rights__r) {
                            //if rights territory is US
                           
                            if (rght.Territory__c == DGF_Constants.TERRITORY_US) {
                                if (rght.Platform__c == DGF_Constants.PLATFORM_VOD && rght.Rights__c == TRUE) {
                                    isUSVODRght = TRUE;
                                }                            
                                else if(rght.Platform__c == DGF_Constants.PLATFORM_EST && rght.Rights__c == TRUE) {  
                                    isUSESTRght = TRUE;                          
                                }
                            }
                            //if rights territory is CA
                            else if (rght.Territory__c == DGF_Constants.TERRITORY_CA) {                       
                                if (rght.Platform__c == DGF_Constants.PLATFORM_VOD && rght.Rights__c == TRUE) {
                                    isCAVODRght = TRUE;
                                }                            
                                else if (rght.Platform__c == DGF_Constants.PLATFORM_EST && rght.Rights__c == TRUE) { 
                                    isCAESTRght = TRUE;                           
                                }                        
                            }                       
                        }
                        
                        //adding a instance in the list
                        if(isBundle){ 
                        	if(tmVersionIdSetwthProduct.contains(tm.id)){
                        		returnTitleVersionList.add(new TitleVersionWrapper(title, tm, isUSESTRght, isUSVODRght, isCAESTRght, isCAVODRght)); 
                        	}
                        }else{
                        	 returnTitleVersionList.add(new TitleVersionWrapper(title, tm, isUSESTRght, isUSVODRght, isCAESTRght, isCAVODRght));  
                        }
                                     
                    }            
                }        
            }
            
            //returning the list of records
            return returnTitleVersionList;  
        }
        catch (exception ex) {   
            throw new AuraHandledException(ex.getMessage());
            return null;
        }    
    }    
    
    /***********************************
    Method Name: getProductUser
    Purpose: method to get product user
    ***********************************/
    @AuraEnabled public static boolean getProductUser() {
        
        User u = [Select id, name, Profile.Name from User where ID =: userinfo.getUserID()];
        
        if (u != null && (u.Profile.Name == DGF_Constants.PROFILE_PRODUCT_USER || u.Profile.Name == DGF_Constants.PROFILE_SYS_ADMIN)) {
            return false;
        }
        else {
            return true;
        }
    }
    
    /***********************************
    Method Name: getTitleName
    Purpose: method to title name for release
    ***********************************/
    @AuraEnabled public static string getTitleName(ID releaseID) {
        
        //getting release details
        List<Digital_Release__c> lstDigitalRelease = [Select id, name, RecordType.Name, Title__c, Title__r.Name from Digital_Release__c 
                                                      where ID =: releaseID];
        
        if (lstDigitalRelease[0].Title__c != null) {
            return lstDigitalRelease[0].Title__r.Name;
        }
        else {
            return null;
        }      
    }
    
    /***********************************
    Method Name: getESTTierValues
    Purpose: method to get EST Tier picklist values
    ***********************************/
    @AuraEnabled public static List<String> getESTTierValues() {
        //creating a list instance to be returned
        List<String> options = new List<String>();
        
        //getting describe of EST Tier field from product object
        Schema.DescribeFieldResult fieldResult = Product__c.EST_Tier__c.getDescribe();
        
        //getitng picklist values
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        options.add('None');
        
        //looping over picklist and storing in list to be returned
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        //returning list
        return options;
    }
    
   
    
    /***********************************
    Method Name: getReleaseType
    Purpose: method to identify the type of release
    ***********************************/
    @AuraEnabled public static string getReleaseType(ID releaseID) {
        //getting release details
        List<Digital_Release__c> lstDigitalRelease = [Select id, name, RecordType.Name from Digital_Release__c where ID =: releaseID];
        return lstDigitalRelease[0].RecordType.Name;
    }
    
    /***********************************
    Method Name: submitDetails
    Purpose: save records
    ***********************************/
    @AuraEnabled public static ID submitDetails(ID releaseID, String strProductVersion, string strESTTier, string strVersion) {
        try {
            //variable declaration
            ID idLeadTitle; 
            List<Title__c>  lstLeadTitle = new List<Title__c>();        
            
            //getting release details
            List<Digital_Release__c> lstDigitalRelease = [Select id, name, RecordType.Name from Digital_Release__c where ID =: releaseID];
            
            //creating a product instance to be inserted
            Product__c insertableProd; 
            
            //list for inserting product versions
            List<Product_Version__c> insertableProductVersion = new List<Product_Version__c>();
            List<DGF_NewProductComponentController.TitleVersionWrapper> lstProductVersion = (List<DGF_NewProductComponentController.TitleVersionWrapper>)System.JSON.deserialize(strProductVersion, List<DGF_NewProductComponentController.TitleVersionWrapper>.class);
            //checking if list not empty
            if (!lstDigitalRelease.isEmpty()) {
                TitleVersionWrapper  tv = lstProductVersion[0];
                //creating a BUNDLE product
                if (lstDigitalRelease[0].RecordType.Name == DGF_Constants.BUNDLE || lstProductVersion.size() > 1) {
                    insertableProd = new Product__c();   
                    insertableProd.Name = String.Valueof(lstDigitalRelease[0].Name).length() > 80 ? String.Valueof(lstDigitalRelease[0].Name).substring(0,79) : lstDigitalRelease[0].Name;                    
                    insertableProd.Digital_Release__c = lstDigitalRelease[0].ID; 
                    insertableProd.RecordTypeID = BundleRecTypeId ;            
                }
                //creating a FILM product
                else if (lstDigitalRelease[0].RecordType.Name == DGF_Constants.FILM) {
                    insertableProd = new Product__c();
                    
                    if (tv.isOriginalVersion) {
                        insertableProd.Name = tv.titleName;
                    }
                    else {
                        insertableProd.Name = tv.titleName + ' (' + strVersion + ')';
                        insertableProd.Version__c = strVersion;
                    }
                    
                    insertableProd.X48_Hour_Rental_Availability__c = TRUE;
                    insertableProd.EST_Tier__c = strESTTier;
                    insertableProd.CA_EST_Tier__c = strESTTier;
                    insertableProd.Digital_Release__c = lstDigitalRelease[0].ID;
                    insertableProd.RecordTypeID = FilmRecTypeId ;
                   
                    insertableProd.EIDR__c =  lstProductVersion[0].EDIR ;
                    insertableProd.Product_ID__c = lstProductVersion[0].productID ;
                    
                }
                //creating a TV product
                else if (lstDigitalRelease[0].RecordType.Name == DGF_Constants.TV) {
                    insertableProd = new Product__c();
                    insertableProd.Name = String.Valueof(lstDigitalRelease[0].Name).length() > 80 ? String.Valueof(lstDigitalRelease[0].Name).substring(0,79) : lstDigitalRelease[0].Name;                   
                    insertableProd.Digital_Release__c = lstDigitalRelease[0].ID;
                    insertableProd.RecordTypeID = TVRecTypeId ;
                    insertableProd.EIDR__c =  lstProductVersion[0].EDIR ;
                    insertableProd.Product_ID__c = lstProductVersion[0].productID ;
                }    
            }
            
            //inserting Product record
            if (insertableProd != null) {
                insert insertableProd;
            }
            
            //checking if title version list is not empty
            if (!lstProductVersion.isEmpty()) {
                for (TitleVersionWrapper  tv : lstProductVersion) {
                    
                    //creating an instance of product version
                    Product_Version__c pv = new Product_Version__c();
                    pv.Name = tv.titleName + ' ' + tv.versionName;
                    pv.Product__c = insertableProd.ID;
                    pv.TM_Version__c = tv.versionID ;
                    pv.Lead_Title__c = tv.isLeadTitle;
                    
                    //getting lead title ID
                    if (tv.isLeadTitle) {
                        idLeadTitle = tv.titleID ;
                    }
                   
                    insertableProductVersion.add(pv);
                }
            }            
            
            //inserting product versions
            if (!insertableProductVersion.isEmpty()) {
                insert insertableProductVersion;
            }
            
            //getting lead title details
            if (string.valueof(idLeadTitle) !=null && string.valueof(idLeadTitle) != '') {
                lstLeadTitle = [Select id, name, Genre_Primary__c, Primary_GTM_Genre__c, (Select id, name, US_EST_Date__c, CA_EST_Date__c, 
                                                                                         US_EPO_Date__c, CA_EPO_Date__c, Theatrical_Genre__c from Digital_Releases__r where
                                                                                         RecordType.Name =: DGF_Constants.FILM order by createddate desc limit 1) from Title__c where ID =: idLeadTitle];
            }
            
            //updating digital release fields based on lead title
            if (!lstLeadTitle.isEmpty()) {
                Digital_Release__c dgr = new Digital_Release__c();
                dgr.ID = releaseID;
                
                //populating date fields on digital release based on latest created film release on title
                if (!lstLeadTitle[0].Digital_Releases__r.isEmpty()) {
                    dgr.Bundle_Genre__c = lstLeadTitle[0].Digital_Releases__r[0].Theatrical_Genre__c;
                    dgr.US_Bundle_Avail_Date__c = lstLeadTitle[0].Digital_Releases__r[0].US_EST_Date__c ;
                    dgr.CA_Bundle_Avail_Date__c =  lstLeadTitle[0].Digital_Releases__r[0].CA_EST_Date__c ;
                    dgr.CA_Bundle_Pre_Purchase_Date__c =  lstLeadTitle[0].Digital_Releases__r[0].CA_EPO_Date__c ;
                    dgr.US_Bundle_Pre_Purchase_Date__c =  lstLeadTitle[0].Digital_Releases__r[0].US_EPO_Date__c ;
                }
                
                update dgr;
            }
            
            //returning ID
            return insertableProd.Id;
        }
        catch (DMLException ex) {
            throw new AuraHandledException(ex.getDmlMessage(0));
            return null;
        }
        catch (exception ex) {  
            throw new AuraHandledException(ex.getMessage());
            return null;
        }
    }
     /***********************************
    Method Name: saveNoVersionProduct
    Purpose: method to create Product without version associated-DFOR-853
    ***********************************/
    @AuraEnabled public static Id saveNoVersionProduct(Id releaseID) {
        Id PreOrderProdRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.PREORDER).getRecordTypeId();
        
        Digital_Release__c release = [SELECT ID, RecordType.Name, Name, SD__c, HD__c, UHD__c, X3D__c, (Select ID, Version_Availability__c, RecordTypeId FROM Products__r where RecordTypeId =:PreOrderProdRecTypeId) from Digital_Release__c where id =: releaseID];
        Product__c prod = new Product__c(Name = release.Name, Digital_Release__c = releaseID, SD__c = release.SD__c, HD__c = release.HD__c, UHD__c = release.UHD__c, X3D__c = release.X3D__c);
        if (release.recordtype.name == DGF_Constants.FILM) {
            prod.RecordTypeId = FilmRecTypeId;
        }
        else if (release.recordtype.name == DGF_Constants.TV) {
            prod.RecordTypeId = TVRecTypeId;
        }
        else if(release.recordtype.name == DGF_Constants.BUNDLE) {
            prod.RecordTypeId = BundleRecTypeId;
        }
        try {
            insert prod;
            if(!release.Products__r.isEmpty()) {
               Product__c preOrderProd =  release.Products__r[0];
                list<Product_Account__c> paList = new list<Product_Account__c>();
                paList = [Select Id, Account__c, Version__c, Account__r.Pre_Order_Best_Version__c FROM Product_Account__c where Account__r.Pre_Order_Best_Version__c = true and Product__c =:preOrderProd.Id];
                if(preOrderProd.Version_Availability__c == null || preOrderProd.Version_Availability__c == '') {
                    preOrderProd.Version_Availability__c = 'Alternate';
                }
                else if(!preOrderProd.Version_Availability__c.contains('Alternate')){
                    preOrderProd.Version_Availability__c += ';Alternate';
                    for(Product_Account__c  pa :paList) {
                        pa.Version__c = 'Alternate';
                    }
                }
               update preOrderProd;
                update paList;
            }
            return prod.id;
        }
        catch (exception ex) {
            throw new AuraHandledException(ex.getMessage());
            return null;
        }
    }
    
    //wrapper class for title versions mapping 
    public class TitleVersionWrapper {
        
        @AuraEnabled public string strTitleAndVersionID {get;set;}
        @AuraEnabled public boolean isUSESTRights {get;set;}
        @AuraEnabled public boolean isUSVODRights {get;set;}
        @AuraEnabled public boolean isCAESTRights {get;set;}
        @AuraEnabled public boolean isCAVODRights {get;set;}
        @AuraEnabled public ID titleID {get;set;}
        @AuraEnabled public string titleName {get;set;}
        @AuraEnabled public ID versionID {get;set;}
        @AuraEnabled public string versionName {get;set;}
        @AuraEnabled public string productID {get;set;}
        @AuraEnabled public string EDIR {get;set;}
        @AuraEnabled public boolean isLeadTitle {get;set;}
        @AuraEnabled public boolean isOriginalVersion {get;set;}
        
        public TitleVersionWrapper(Title__c ttl, TM_version__c tmv, Boolean usESTRght, Boolean usVODRght, Boolean caESTRght, Boolean caVODRght) {
            
            isUSESTRights = FALSE;
            isUSVODRights = FALSE;
            isCAESTRights = FALSE;
            isCAVODRights = FALSE;
            isLeadTitle = FALSE;
            isOriginalVersion = FALSE;
            
            isUSESTRights = usESTRght;
            isUSVODRights = usVODRght;
            isCAESTRights = caESTRght;
            isCAVODRights = caVODRght; 
            strTitleAndVersionID = ttl.ID ;
            strTitleAndVersionID  = strTitleAndVersionID + tmv.ID;
            
            titleID = ttl.ID;
            titleName = ttl.Name;
            versionID = tmv.ID;
            versionName = tmv.Name;
            productID = tmv.TVD_SAFE_Production_ID__c;
            EDIR = tmv.Version_EIDR__c;
            isOriginalVersion = tmv.Original_Flag__c;
        } 
    }    
}