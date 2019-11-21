/*****************************************************************************************
Class Name: DGF_AddCarriageController
Purpose: Controller for new product Account
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             29/06/2017           Jata                    Initial Development
******************************************************************************************/
public class DGF_AddCarriageController {
    /**private instance**/
    private static Id FilmRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
    private static Id TVRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
    private static Id BundleRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId();
    private static Id PrdAccFilmRecTypeId = Schema.SObjectType.Product_Account__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
    private static Id PrdAccTVRecTypeId = Schema.SObjectType.Product_Account__c.getRecordTypeInfosByName().get(DGF_Constants.TV).getRecordTypeId();
    private static Id PrdAccBundleRecTypeId = Schema.SObjectType.Product_Account__c.getRecordTypeInfosByName().get(DGF_Constants.BUNDLE).getRecordTypeId();
    private static Id PrdAccEpsdpricngRecTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.EPISODE_PRICING).getRecordTypeId();
    
    /***********************************
    Method Name: fetchProducts
    Purpose: method to fetch Products
    ***********************************/
    @AuraEnabled public static List<ProductAccountWrapper> fetchProducts(String searchKeyWord, String buttonID, String productType,String fromDate, String untilDate, Id accountId) {
        try{
            
            //storing search key word in a variable
            String searchKey = '%' + searchKeyWord + '%';
            String SOQLFilm;
            String SOQLBundle;
            String SOQLTV;
            String subSOQL;
            Boolean isSelected = true;
            Date frmDate;
            Date untlDate;
            Date defaultDate;
            
            if(fromDate!='' && fromDate!=null){ 
            list<String> splitDate=fromDate.split('-');
              //frmDate=date.newInstance(Integer.valueOf(splitDate[0]),Integer.valueOf(splitDate[1]),Integer.valueOf(splitDate[2]));
              frmDate=Date.ValueOf(fromDate);
            }
            if(untilDate!='' && untilDate!=null){
            list<String> splitDate=untilDate.split('-');
             // untlDate=date.newInstance(Integer.valueOf(splitDate[0]),Integer.valueOf(splitDate[1]),Integer.valueOf(splitDate[2]));
             untlDate=Date.ValueOf(untilDate);
            }
            System.debug('frmDate==>'+frmDate);
            System.debug('untlDate==>'+untlDate);
            //list of type wrapper to be returned
            List<ProductAccountWrapper> returnProductAccount = new List<ProductAccountWrapper>();
            
            //querying Account record
            Account acnt = [select Id, Territory__c from Account where Id =: accountId];
            
            subSOQL = ' (Select Id,EST_Start_Date__c,VOD_Start_Date__c,VOD_End_Date__c,PPV_Start_Date__c,PPV_End_Date__c,X4K_EST__c,Push_VOD_Start_Date__c,Push_VOD_End_Date__c,Launch_Date__c from product_Account__r where Account__c =: accountId)';
            
            //Creating string query based on Product record type on View All button
            if(buttonID == 'btnSearchAll'){
                if(productType == 'Film' || productType == 'All')
                    SOQLFilm = 'Select Id,Name,UHD__c,RecordType.Name,RecordTypeID,Digital_Release__r.New_to_UHD__c,Digital_Release__r.New_to_UHD_US_EST_Release_Date__c,Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c,Digital_Release__r.CA_Bundle_Avail_Date__c,Digital_Release__r.US_Bundle_Avail_Date__c,Digital_Release__r.CA_EST_Launch_Date__c,Digital_Release__r.US_EST_Launch_Date__c,Digital_Release__r.US_EST_Date__c,Digital_Release__r.CA_EST_Date__c,Digital_Release__r.US_VOD_Start_Date__c,Digital_Release__r.US_VOD_End_Date__c,Digital_Release__r.CA_VOD_Start_Date__c,Digital_Release__r.CA_VOD_End_Date__c,'+subSOQL+' from Product__c where RecordTypeId =: FilmRecTypeId';
                if(productType == 'TV' || productType == 'All')
                    SOQLTV = 'Select Id,Name,UHD__c,RecordType.Name,RecordTypeID,Digital_Release__r.New_to_UHD__c,Digital_Release__r.New_to_UHD_US_EST_Release_Date__c,Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c,Digital_Release__r.CA_Bundle_Avail_Date__c,Digital_Release__r.US_Bundle_Avail_Date__c,Digital_Release__r.CA_EST_Launch_Date__c,Digital_Release__r.US_EST_Launch_Date__c,Digital_Release__r.US_EST_Date__c,Digital_Release__r.CA_EST_Date__c,Digital_Release__r.US_VOD_Start_Date__c,Digital_Release__r.US_VOD_End_Date__c,Digital_Release__r.CA_VOD_Start_Date__c,Digital_Release__r.CA_VOD_End_Date__c,'+subSOQL+' from Product__c where RecordTypeId =: TVRecTypeId';
                if(productType == 'Bundle' || productType == 'All')
                    SOQLBundle = 'Select Id,Name,UHD__c,RecordType.Name,RecordTypeID,Digital_Release__r.New_to_UHD__c,Digital_Release__r.New_to_UHD_US_EST_Release_Date__c,Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c,Digital_Release__r.CA_Bundle_Avail_Date__c,Digital_Release__r.US_Bundle_Avail_Date__c,Digital_Release__r.CA_EST_Launch_Date__c,Digital_Release__r.US_EST_Launch_Date__c,Digital_Release__r.US_EST_Date__c,Digital_Release__r.CA_EST_Date__c,Digital_Release__r.US_VOD_Start_Date__c,Digital_Release__r.US_VOD_End_Date__c,Digital_Release__r.CA_VOD_Start_Date__c,Digital_Release__r.CA_VOD_End_Date__c,'+subSOQL+' from Product__c where RecordTypeId =: BundleRecTypeId';
            }
            else {
                if(productType == 'Film' || productType == 'All')
                    SOQLFilm = 'Select Id,Name,UHD__c,RecordType.Name,RecordTypeID,Digital_Release__r.New_to_UHD__c,Digital_Release__r.New_to_UHD_US_EST_Release_Date__c,Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c,Digital_Release__r.CA_Bundle_Avail_Date__c,Digital_Release__r.US_Bundle_Avail_Date__c,Digital_Release__r.CA_EST_Launch_Date__c,Digital_Release__r.US_EST_Launch_Date__c,Digital_Release__r.US_EST_Date__c,Digital_Release__r.CA_EST_Date__c,Digital_Release__r.US_VOD_Start_Date__c,Digital_Release__r.US_VOD_End_Date__c,Digital_Release__r.CA_VOD_Start_Date__c,Digital_Release__r.CA_VOD_End_Date__c,'+subSOQL+' from Product__c where (Name LIKE : searchKey OR Tags__c LIKE : searchKey) And RecordTypeId =: FilmRecTypeId';
                if(productType == 'TV' || productType == 'All')
                    SOQLTV = 'Select Id,Name,UHD__c,RecordType.Name,RecordTypeID,Digital_Release__r.New_to_UHD__c,Digital_Release__r.New_to_UHD_US_EST_Release_Date__c,Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c,Digital_Release__r.CA_Bundle_Avail_Date__c,Digital_Release__r.US_Bundle_Avail_Date__c,Digital_Release__r.CA_EST_Launch_Date__c,Digital_Release__r.US_EST_Launch_Date__c,Digital_Release__r.US_EST_Date__c,Digital_Release__r.CA_EST_Date__c,Digital_Release__r.US_VOD_Start_Date__c,Digital_Release__r.US_VOD_End_Date__c,Digital_Release__r.CA_VOD_Start_Date__c,Digital_Release__r.CA_VOD_End_Date__c,'+subSOQL+' from Product__c where (Name LIKE : searchKey OR Tags__c LIKE : searchKey) And RecordTypeId =: TVRecTypeId';
                if(productType == 'Bundle' || productType == 'All')
                    SOQLBundle = 'Select Id,Name,UHD__c,RecordType.Name,RecordTypeID,Digital_Release__r.New_to_UHD__c,Digital_Release__r.New_to_UHD_US_EST_Release_Date__c,Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c,Digital_Release__r.CA_Bundle_Avail_Date__c,Digital_Release__r.US_Bundle_Avail_Date__c,Digital_Release__r.CA_EST_Launch_Date__c,Digital_Release__r.US_EST_Launch_Date__c,Digital_Release__r.US_EST_Date__c,Digital_Release__r.CA_EST_Date__c,Digital_Release__r.US_VOD_Start_Date__c,Digital_Release__r.US_VOD_End_Date__c,Digital_Release__r.CA_VOD_Start_Date__c,Digital_Release__r.CA_VOD_End_Date__c,'+subSOQL+' from Product__c where (Name LIKE : searchKey OR Tags__c LIKE : searchKey) And RecordTypeId =: BundleRecTypeId';
            }
            
            //Creating string query based on release dates
            if(acnt.Territory__c == 'US'){
                System.debug('fromDate'+fromDate);
                System.debug('untilDate'+untilDate);
                //Filter based on US EST dates
                if(productType == 'Film' || productType == 'All'){
                    if(frmDate != null && untlDate != null)
                        SOQLFilm = SOQLFilm + ' AND ((Digital_Release__r.US_EST_Date__c >= :frmDate  AND Digital_Release__r.US_EST_Date__c <= :untlDate) OR (Digital_Release__r.US_VOD_Start_Date__c >= :frmDate AND Digital_Release__r.US_VOD_Start_Date__c <= :untlDate)) Order by Digital_Release__r.US_EST_Date__c';
                    if(frmDate == null && untlDate != null)
                        SOQLFilm = SOQLFilm + ' AND (Digital_Release__r.US_EST_Date__c <= :untlDate OR Digital_Release__r.US_VOD_Start_Date__c <= :untlDate) Order by Digital_Release__r.US_EST_Date__c';
                    if(frmDate != null && untlDate == null)
                        SOQLFilm = SOQLFilm + ' AND (Digital_Release__r.US_EST_Date__c >= :frmDate OR Digital_Release__r.US_VOD_Start_Date__c >= :frmDate) Order by Digital_Release__r.US_EST_Date__c';
                    if(frmDate == null && buttonID == 'btnSearchAll' && untlDate == null)
                    {
                        defaultDate = System.today() +1;
                        SOQLFilm = SOQLFilm + ' AND (Digital_Release__r.US_EST_Date__c >= :defaultDate OR Digital_Release__r.US_VOD_Start_Date__c >= :defaultDate) Order by Digital_Release__r.US_EST_Date__c';
                    } 
                    else if(frmDate == null && untlDate == null){
                        SOQLFilm = SOQLFilm + ' Order by Digital_Release__r.US_EST_Date__c';  
                    } 
                }
                //Filter based on US EST Launch dates
                if(productType == 'TV' || productType == 'All'){
                    if(frmDate != null && untlDate != null)
                        SOQLTV = SOQLTV + ' AND ((Digital_Release__r.US_EST_Launch_Date__c >= :frmDate  AND Digital_Release__r.US_EST_Launch_Date__c <= :untlDate)) Order by Digital_Release__r.US_EST_Launch_Date__c';
                    if(frmDate == null && untlDate != null)
                        SOQLTV = SOQLTV + ' AND (Digital_Release__r.US_EST_Launch_Date__c <= :untlDate) Order by Digital_Release__r.US_EST_Launch_Date__c';
                    if(frmDate != null && untlDate == null)
                        SOQLTV = SOQLTV + ' AND (Digital_Release__r.US_EST_Launch_Date__c >= :frmDate) Order by Digital_Release__r.US_EST_Launch_Date__c';
                    if(frmDate == null && buttonID == 'btnSearchAll' && untlDate == null)
                    {
                        defaultDate = System.today() +1;
                        SOQLTV = SOQLTV + ' AND (Digital_Release__r.US_EST_Launch_Date__c >= :defaultDate) Order by Digital_Release__r.US_EST_Launch_Date__c';
                    }
                    else if(frmDate == null && untlDate == null){
                        SOQLTV = SOQLTV + ' Order by Digital_Release__r.US_EST_Launch_Date__c';  
                    }
                }
                //Filter based on US Bundle Avail date
                if(productType == 'Bundle' || productType == 'All'){
                    if(frmDate != null && untlDate != null)
                        SOQLBundle = SOQLBundle + ' AND ((Digital_Release__r.US_Bundle_Avail_Date__c >= :frmDate  AND Digital_Release__r.US_Bundle_Avail_Date__c <= :untlDate)) Order by Digital_Release__r.US_Bundle_Avail_Date__c';
                    if(frmDate == null && untlDate != null)
                        SOQLBundle = SOQLBundle + ' AND (Digital_Release__r.US_Bundle_Avail_Date__c <= :untlDate) Order by Digital_Release__r.US_Bundle_Avail_Date__c';
                    if(frmDate != null && untlDate == null)
                        SOQLBundle = SOQLBundle + ' AND (Digital_Release__r.US_Bundle_Avail_Date__c >= :frmDate) Order by Digital_Release__r.US_Bundle_Avail_Date__c';
                    if(frmDate == null && buttonID == 'btnSearchAll' && untlDate == null)
                    {
                        defaultDate = System.today() +1;
                        SOQLBundle = SOQLBundle + ' AND (Digital_Release__r.US_Bundle_Avail_Date__c >= :defaultDate) Order by Digital_Release__r.US_Bundle_Avail_Date__c';
                    }
                    else if(frmDate == null && untlDate == null){
                        SOQLBundle = SOQLBundle + ' Order by Digital_Release__r.US_Bundle_Avail_Date__c';  
                    }
                }
                
            }
            else if(acnt.Territory__c == 'CA'){
                System.debug('fromDate'+fromDate);
                System.debug('untilDate'+untilDate);
                //Filter based on CA EST dates
                if(productType == 'Film' || productType == 'All'){
                    if(frmDate != null && untlDate != null)
                        SOQLFilm = SOQLFilm + ' AND ((Digital_Release__r.CA_EST_Date__c >= :frmDate  AND Digital_Release__r.CA_EST_Date__c <= :untlDate) OR (Digital_Release__r.CA_VOD_Start_Date__c >= :frmDate AND Digital_Release__r.CA_VOD_Start_Date__c <= :untlDate)) Order by Digital_Release__r.CA_EST_Date__c';
                    if(frmDate == null && untlDate != null)
                        SOQLFilm = SOQLFilm + ' AND (Digital_Release__r.CA_EST_Date__c <= :untlDate OR Digital_Release__r.CA_VOD_Start_Date__c <= :untlDate) Order by Digital_Release__r.CA_EST_Date__c';
                    if(frmDate != null && untlDate == null)
                        SOQLFilm = SOQLFilm + ' AND (Digital_Release__r.CA_EST_Date__c >= :frmDate OR Digital_Release__r.CA_VOD_Start_Date__c >= :frmDate) Order by Digital_Release__r.CA_EST_Date__c';
                    if(frmDate == null && buttonID == 'btnSearchAll' && untlDate == null)
                    {
                        defaultDate = System.today() +1;
                        SOQLFilm = SOQLFilm + ' AND (Digital_Release__r.CA_EST_Date__c >= :defaultDate OR Digital_Release__r.CA_VOD_Start_Date__c >= :defaultDate) Order by Digital_Release__r.CA_EST_Date__c';
                    }
                    else if(frmDate == null && untlDate == null){
                        SOQLFilm = SOQLFilm + ' Order by Digital_Release__r.CA_EST_Date__c';  
                    }   
                }
                //Filter based on CA EST launch dates
                if(productType == 'TV' || productType == 'All'){
                    if(frmDate != null && untlDate != null)
                        SOQLTV = SOQLTV + ' AND ((Digital_Release__r.CA_EST_Launch_Date__c >= :frmDate  AND Digital_Release__r.CA_EST_Launch_Date__c <= :untlDate)) Order by Digital_Release__r.CA_EST_Launch_Date__c';
                    if(frmDate == null && untlDate != null)
                        SOQLTV = SOQLTV + ' AND (Digital_Release__r.CA_EST_Launch_Date__c <= :untlDate) Order by Digital_Release__r.CA_EST_Launch_Date__c';
                    if(frmDate != null && untlDate == null)
                        SOQLTV = SOQLTV + ' AND (Digital_Release__r.CA_EST_Launch_Date__c >= :frmDate) Order by Digital_Release__r.CA_EST_Launch_Date__c';
                    if(frmDate == null && buttonID == 'btnSearchAll' && untlDate == null)
                    {
                        defaultDate = System.today() +1;
                        SOQLTV = SOQLTV + ' AND (Digital_Release__r.CA_EST_Launch_Date__c >= :defaultDate) Order by Digital_Release__r.CA_EST_Launch_Date__c';
                    }
                    else if(frmDate == null && untlDate == null){
                        SOQLTV = SOQLTV + ' Order by Digital_Release__r.CA_EST_Launch_Date__c';  
                    }
                }
                //Filter based on CA Bundle Avail dates
                if(productType == 'Bundle' || productType == 'All'){
                    if(frmDate != null && untlDate != null)
                        SOQLBundle = SOQLBundle + ' AND ((Digital_Release__r.CA_Bundle_Avail_Date__c >= :frmDate  AND Digital_Release__r.CA_Bundle_Avail_Date__c <= :untlDate)) Order by Digital_Release__r.CA_Bundle_Avail_Date__c';
                    if(frmDate == null && untlDate != null)
                        SOQLBundle = SOQLBundle + ' AND (Digital_Release__r.CA_Bundle_Avail_Date__c <= :untlDate) Order by Digital_Release__r.CA_Bundle_Avail_Date__c';
                    if(frmDate != null && untlDate == null)
                        SOQLBundle = SOQLBundle + ' AND (Digital_Release__r.CA_Bundle_Avail_Date__c >= :frmDate) Order by Digital_Release__r.CA_Bundle_Avail_Date__c';
                    if(frmDate == null && buttonID == 'btnSearchAll' && untlDate == null)
                    {
                        defaultDate = System.today() +1;
                        SOQLBundle = SOQLBundle + ' AND (Digital_Release__r.CA_Bundle_Avail_Date__c >= :defaultDate) Order by Digital_Release__r.CA_Bundle_Avail_Date__c';
                    }
                    else if(frmDate == null && untlDate == null){
                        SOQLBundle = SOQLBundle + ' Order by Digital_Release__r.CA_Bundle_Avail_Date__c';  
                    }
                }
                
            }
            
            //querying all matching Products
            List<Product__c> lstOfProducts = new List<Product__c>();
            List<Product__c> tempList = new List<Product__c>();
            if(productType == 'Film' || productType == 'All'){
                SOQLFilm = SOQLFilm + ' Limit 10000';
                if(!lstOfProducts.isEmpty()){
                    tempList=database.query(SOQLFilm);
                    lstOfProducts.addAll(tempList);
                }
                else
                    lstOfProducts = Database.query(SOQLFilm); 
            }
            if(productType == 'TV' || productType == 'All'){
                SOQLTV = SOQLTV + ' Limit 10000';
                if(!lstOfProducts.isEmpty()){
                    tempList=database.query(SOQLTV);
                    lstOfProducts.addAll(tempList);
                }
                else
                    lstOfProducts = Database.query(SOQLTV); 
            }
            if(productType == 'Bundle' || productType == 'All'){
                SOQLBundle = SOQLBundle + ' Limit 10000';
                if(!lstOfProducts.isEmpty()){
                    tempList=database.query(SOQLBundle);
                    lstOfProducts.addAll(tempList);
                }
                else
                    lstOfProducts = Database.query(SOQLBundle);  
            }
            
            if(!lstOfProducts.isEmpty()){
                for(Product__c prd : lstOfProducts){
                    
                    if(!prd.Product_Account__r.isEmpty()){
                        System.Debug('check entry in if');
                        
                        for(Product_Account__c prdAccount : prd.Product_Account__r){
                            returnProductAccount.add(new ProductAccountWrapper(prd,isSelected,prdAccount,acnt));
                        } 
                    }
                    else {
                        returnProductAccount.add(new ProductAccountWrapper(prd,isSelected,null,acnt));
                    }
                }
            }
            return returnProductAccount;
        }
        catch(exception ex){
            System.Debug('Error @@@ '+ex.getMessage());   
            throw new AuraHandledException(ex.getMessage());
            return null;
        }  
        
    }
    
    /***********************************
    Method Name: submitDetails
    Purpose: save records
    ***********************************/
    @AuraEnabled public static ID submitDetails(ID accountID,String strProductAccount){
        try{
            //list for inserting junction Object Product Account
            List<Product_Account__c> insertableProductAccount = new List<Product_Account__c>();
            Set<Product_Account__c> tempProductAccount = new Set<Product_Account__c>(); //USST-3066
            Account accDetails = [Select Id from Account where Id =: accountID];
            system.debug('strProductAccount==>'+strProductAccount);
            List<DGF_AddCarriageController.ProductAccountWrapper> lstProductAccount = (List<DGF_AddCarriageController.ProductAccountWrapper>)System.JSON.deserialize(strProductAccount,List<DGF_AddCarriageController.ProductAccountWrapper>.class);
            
            //checking if product Promotion list is not empty
            if(!lstProductAccount.isEmpty()){
                for(ProductAccountWrapper  prodAcc : lstProductAccount){
                    
                    //creating an instance of Product Account
                    if(prodAcc.isSelected == true){
                        prodAcc.prdAcc.Account__c = accountID;
                        prodAcc.prdAcc.Product__c = prodAcc.productID;
                        if(prodAcc.recordtypeId == FilmRecTypeId){
                            prodAcc.prdAcc.PPV_Start_Date__c = prodAcc.ppvStartDate;
                            prodAcc.prdAcc.PPV_End_Date__c = prodAcc.ppvEndDate;
                            prodAcc.prdAcc.Push_VOD_Start_Date__c = prodAcc.pushStartDate;
                            prodAcc.prdAcc.Push_VOD_End_Date__c = prodAcc.pushEndDate;
                            prodAcc.prdAcc.EST_Start_Date__c = prodAcc.estDate;
                            prodAcc.prdAcc.VOD_Start_Date__c = prodAcc.vodStartDate;
                            prodAcc.prdAcc.VOD_End_Date__c = prodAcc.vodEndDate;
                            prodAcc.prdAcc.X4K_EST__c = prodAcc.x4kEST;
                            prodAcc.prdAcc.RecordTypeId = PrdAccFilmRecTypeId;
                            prodAcc.prdAcc.Carriage__c = true;
                        }
                        else if(prodAcc.recordtypeId == TVRecTypeId){
                            prodAcc.prdAcc.RecordTypeId = PrdAccTVRecTypeId;
                            prodAcc.prdAcc.Launch_Date__c = prodAcc.estDate;
                            prodAcc.prdAcc.Carriage__c = true;
                        }
                        else if(prodAcc.recordtypeId == BundleRecTypeId){
                            prodAcc.prdAcc.RecordTypeId = PrdAccBundleRecTypeId;
                            prodAcc.prdAcc.Launch_Date__c = prodAcc.estDate;
                            prodAcc.prdAcc.Carriage__c = true;
                        }
                            
                        //adding instance to the list
                       insertableProductAccount.add(prodAcc.prdAcc);
                    }
                    
                    
                }
            }            
           
            
            //inserting Promotion Product
            if(!insertableProductAccount.isEmpty()){
                //USST-3066 start -- deciding whether record needs to be inserted or updated. If PA already exists, then remove it from this list and update it using a separate list.
                List<Product_Account__c> updatableProductAccount = new List<Product_Account__c>();
                List<Product_Account__c> lstExistingProductAccounts = [Select Id, Account__c, Product__c from Product_Account__c where Account__c =: accountID];
                Map<ID, Product_Account__c> mapExistingProductAccounts= new Map<ID, Product_Account__c>();
                if (!lstExistingProductAccounts.isEmpty()) {
                    for (Product_Account__c pa : lstExistingProductAccounts) {
                        mapExistingProductAccounts.put(pa.Product__c, pa);                      
                    }
                }
                tempProductAccount.addAll(insertableProductAccount);
                for (Product_Account__c pa : insertableProductAccount) {
                    if (mapExistingProductAccounts.get(pa.Product__c) != null && pa.Product__c == mapExistingProductAccounts.get(pa.Product__c).Product__c) {
                        if (pa.ID != null) {
                            updatableProductAccount.add(pa);
                        }
                        tempProductAccount.remove(pa);
                    }
                }
                insertableProductAccount.clear();
                insertableProductAccount.addAll(tempProductAccount);
                
                insert insertableProductAccount;
                
                if(!updatableProductAccount.isEmpty()){
                    update updatableProductAccount;
                }
                //USST-3066 end
            }
            
            //returning ID
            return accountID;
        }
        catch(DMLException ex){
            throw new AuraHandledException(ex.getDmlMessage(0));
            return ex.getDmlMessage(0);
        }
        catch(exception ex){
            System.Debug('Error @@@ '+ex.getMessage());   
            throw new AuraHandledException(ex.getMessage());
            return null;
        }
    }
    
    /***********************************
    Method Name: getUser
    Purpose: method to get Account user
    ***********************************/
    @AuraEnabled public static boolean getUser() {
        //querying current user
        User u = [Select id,name,Profile.Name from User where ID=:userinfo.getUserID()];
        
        if(u != null && (u.Profile.Name == DGF_Constants.PROFILE_SYS_ADMIN) || u.Profile.Name == DGF_Constants.PROFILE_ACCOUNT_USER){
            return false;
        }else{
            return true;
        }
    }
    
    /***********************************
    Method Name: getAccountName
    Purpose: method to get Account Name
    ***********************************/
    @AuraEnabled public static String getAccountName(Id accId) {
        
        //querying Account record
        Account acnt = [select Id,Name from Account where Id =: accId];
        
        return acnt.Name;
    }
    
    //wrapper class for Product Account mapping 
    public class ProductAccountWrapper{
        
        @AuraEnabled public boolean isSelected {get;set;}
        @AuraEnabled public boolean isBundle {get;set;}
        @AuraEnabled public boolean isTV {get;set;}
        @AuraEnabled public ID productID {get;set;}
        @AuraEnabled public string productName {get;set;}
        @AuraEnabled public string recordtypeName {get;set;}
        @AuraEnabled public Id recordtypeId {get;set;}
        @AuraEnabled public Date estDate {get;set;}
        @AuraEnabled public Date vodStartDate {get;set;}
        @AuraEnabled public Date vodEndDate {get;set;}
        @AuraEnabled public Date ppvStartDate {get;set;}
        @AuraEnabled public Date ppvEndDate {get;set;}
        @AuraEnabled public Date pushStartDate {get;set;}
        @AuraEnabled public Date pushEndDate {get;set;}
        @AuraEnabled public Date x4kEST {get;set;}
        //@AuraEnabled public Date launchDate {get;set;}
        @AuraEnabled public Id proAccountId {get;set;}
        @AuraEnabled public Product_Account__c prdAcc {get; set;}
        
        public ProductAccountWrapper(Product__c prd, Boolean selected,Product_Account__c prdAcc,Account acc){
            
            if(prdAcc == null)
                isSelected = false;
            else
                isSelected = true;
            
            productID = prd.ID;
            productName = prd.Name;
            recordtypeName = prd.RecordType.Name;
            recordtypeId = prd.RecordTypeID;
            //setting variables for record types to enable/disable date fields
            if(recordtypeId == BundleRecTypeId){
                isBundle = true;
            }else if(recordtypeId == TVRecTypeId){
                isTV = true;
            }else if(recordtypeId == FilmRecTypeId){
                isBundle = false;
                isTV = false;
            }
            //defaulting date fields if Product Account is available for the products
            if(prdAcc != null){
                this.prdAcc = prdAcc;
                if(recordtypeId == FilmRecTypeId){
                    estDate = prdAcc.EST_Start_Date__c;
                    vodStartDate =  prdAcc.VOD_Start_Date__c;
                    vodEndDate = prdAcc.VOD_End_Date__c;
                    ppvStartDate = prdAcc.PPV_Start_Date__c;
                    ppvEndDate = prdAcc.PPV_End_Date__c;
                    x4kEST = prdAcc.X4K_EST__c;
                    pushStartDate = prdAcc.Push_VOD_Start_Date__c;
                    pushEndDate = prdAcc.Push_VOD_End_Date__c;
                }
                else 
                    estDate = prdAcc.Launch_Date__c;
            }
            //defaulting date fields if product is not available for the products based on the record types
            else if(prdAcc == null){
                this.prdAcc = new Product_Account__c();
                if(recordtypeId == FilmRecTypeId){
                    if(acc.Territory__c == 'US'){
                        estDate = prd.Digital_Release__r.US_EST_Date__c;
                        vodStartDate =  prd.Digital_Release__r.US_VOD_Start_Date__c;
                        vodEndDate = prd.Digital_Release__r.US_VOD_End_Date__c;
                        ppvStartDate = prd.Digital_Release__r.US_VOD_Start_Date__c;
                        ppvEndDate = prd.Digital_Release__r.US_VOD_End_Date__c;
                        pushStartDate = prd.Digital_Release__r.US_VOD_Start_Date__c;
                        pushEndDate = prd.Digital_Release__r.US_VOD_End_Date__c;
                        if(prd.UHD__c && prd.Digital_Release__r.New_to_UHD__c)
                            x4kEST = prd.Digital_Release__r.New_to_UHD_US_EST_Release_Date__c;
                        else
                            x4kEST = prd.Digital_Release__r.US_EST_Date__c;
                    }
                    else if(acc.Territory__c == 'CA'){
                        estDate = prd.Digital_Release__r.CA_EST_Date__c;
                        vodStartDate =  prd.Digital_Release__r.CA_VOD_Start_Date__c;
                        vodEndDate = prd.Digital_Release__r.CA_VOD_End_Date__c;
                        ppvStartDate = prd.Digital_Release__r.CA_VOD_Start_Date__c;
                        ppvEndDate = prd.Digital_Release__r.CA_VOD_End_Date__c;
                        pushStartDate = prd.Digital_Release__r.CA_VOD_Start_Date__c;
                        pushEndDate = prd.Digital_Release__r.CA_VOD_End_Date__c;
                        if(prd.UHD__c && prd.Digital_Release__r.New_to_UHD__c)
                            x4kEST = prd.Digital_Release__r.New_to_UHD_CA_EST_Release_Date__c;
                        else
                            x4kEST = prd.Digital_Release__r.CA_EST_Date__c;
                    }
                }
                else if(recordtypeId == TVRecTypeId){
                    if(acc.Territory__c == 'US'){
                         estDate = prd.Digital_Release__r.US_EST_Launch_Date__c;
                         //x4kEST = prd.Digital_Release__r.US_EST_Launch_Date__c;
                         //launchDate = prd.Digital_Release__r.US_EST_Launch_Date__c;
                    }
                    else if(acc.Territory__c == 'CA'){
                         estDate = prd.Digital_Release__r.CA_EST_Launch_Date__c;
                         //x4kEST = prd.Digital_Release__r.CA_EST_Launch_Date__c;
                         //launchDate = prd.Digital_Release__r.CA_EST_Launch_Date__c;
                    }
                    
                }
                else if(recordtypeId == BundleRecTypeId){
                    if(acc.Territory__c == 'US'){
                        estDate = prd.Digital_Release__r.US_Bundle_Avail_Date__c;
                        //x4kEST = prd.Digital_Release__r.US_Bundle_Avail_Date__c;
                        //launchDate = prd.Digital_Release__r.US_Bundle_Avail_Date__c;
                    }
                    else if(acc.Territory__c == 'CA'){
                        estDate = prd.Digital_Release__r.CA_Bundle_Avail_Date__c;
                        //x4kEST = prd.Digital_Release__r.CA_Bundle_Avail_Date__c;
                        //launchDate = prd.Digital_Release__r.CA_Bundle_Avail_Date__c;
                    }
                }
                
            }
            
            
        } 
    }
    
}