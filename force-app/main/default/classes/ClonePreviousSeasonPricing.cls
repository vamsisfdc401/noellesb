public class ClonePreviousSeasonPricing {   
    @AuraEnabled
    public static String clonePricingRecords(String recId,String seasonId) {
        String strMsg = '';
        System.debug('record id'+recId);
        System.debug('record id'+seasonId);
        DGF_TriggerUtility.executeDigitalReleaseTrigger = FALSE;       
        Id devRecordTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();        
        List<Product__c> prodList = [Select Id, Digital_Release__c, Digital_Release__r.Series_Name__c,
                                     RecordTypeId
                                     FROM Product__c 
                                     where Id =: recId];         
        
        String strSeriesId = prodList[0].Digital_Release__r.Series_Name__c;
        String strPodRecTypeId = prodList[0].RecordTypeId;
        String strPodDRId = prodList[0].Digital_Release__c;
        System.debug('strSeriesId---'+strSeriesId);
        list<Digital_Release__c> lstDROld = new list<Digital_Release__c>();
        lstDROld = [SELECT CreatedDate,Id,Name,Series_Name__c,CA_EST_Launch_Date__c,US_EST_Launch_Date__c 
                    FROM Digital_Release__c 
                    WHERE Series_Name__c =: strSeriesId	and Id=:seasonId                    
                                         
                   ];
        List<Digital_Release__c> dr = [select id,name,CA_EST_Launch_Date__c,US_EST_Launch_Date__c from Digital_Release__c where  id=:strPodDRId ];
        if(dr[0].CA_EST_Launch_Date__c == null && dr[0].US_EST_Launch_Date__c == null){
            strMsg = 'CA/US Launch Date';
            return strMsg;
        } else {
            
            Integer index = 0;
        Integer lstSize = 0;
        String previousDRId = '';
        if(lstDROld!=null && lstDROld.size()>0)
        { 
            
            previousDRId = lstDROld[0].Id;
        }else
        {
            strMsg = 'No Records Found';
            return strMsg;
        }
        system.debug('previousDRId====='+previousDRId);
        Id recTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Episode Pricing').getRecordTypeId();        
        Map<Id,Product__c> oldProduct = new Map<Id,Product__c>();
        List<Product__c> newProductList = new List<Product__c>();
        List<Pricing__c> newPricingList = new List<Pricing__c>();
        set<Id> prodIdSet = new set<Id>();
        List<Product__c> productList = [Select Id, Name ,X3D__c, HD__c,HDR__c,SD__c,UHD__c,EST_Tier__c,
                                        US_Platform_Offering__c,CA_Platform_Offering__c,
                                        RecordTypeId
                                        FROM Product__c 
                                        where Digital_Release__c =: previousDRId
                                        AND RecordTypeId = :strPodRecTypeId];
        
        system.debug('productList===='+productList);
        for(Product__c prod : productList){
            prodIdSet.add(prod.Id);
            //oldProduct.put(prod.Id,newProduct);
        }        
        system.debug('prodIdSet===='+prodIdSet);        
        list<Pricing__c> lstPricingRecs = new list<Pricing__c>();
        lstPricingRecs = [Select ID,Category__c,iTunes_Tier__c,Margin__c, 
                          Platform__c, Price_Type__c, Product__c, Resolution__c, SRP__c, 
                          Territory__c, Valid_From__c, Valid_To__c, 
                          WSP__c 
                          FROM Pricing__c
                          WHERE Product__c IN: prodIdSet
                         // AND Price_Type__c = 'Original'
                          AND Valid_To__c = null                           
                          AND Account__c != 'iTunes'];
        system.debug('newPricingList====='+lstPricingRecs);
        if(lstPricingRecs!=null && lstPricingRecs.size()>0)
        {
            for(Pricing__c prObj :lstPricingRecs)
            { 
                if(prObj.Territory__c == 'US' && dr[0].US_EST_Launch_Date__c != null){
                    Pricing__c newPrice = prObj.clone(false, false, false, false); //do a deep clone
                    newPrice.Product__c  = recId;
                    if(newPrice.Territory__c == 'US'){
                    newPrice.Valid_From__c=  dr[0].US_EST_Launch_Date__c; 
                }
                    newPricingList.add(newPrice);
                }
                 if(prObj.Territory__c == 'CA' && dr[0].CA_EST_Launch_Date__c != null){
                    Pricing__c newPrice = prObj.clone(false, false, false, false); //do a deep clone
                    newPrice.Product__c  = recId;
                    if(newPrice.Territory__c == 'CA'){
                    newPrice.Valid_From__c=  dr[0].CA_EST_Launch_Date__c; 
                }
                    newPricingList.add(newPrice);
                }           
 
                }               
            }
         else{
            strMsg = 'No Records Found';
            return strMsg;
            
        }
        if(newPricingList!=null && newPricingList.size()>0)
        {
            system.debug('newPricingList====='+newPricingList);
            DGF_TriggerUtility.isCloningProcess = True;
            insert newPricingList;
        }
        
        return 'Created'; 
    }
           
   }
        
    @AuraEnabled
    public static List<Digital_Release__c> getSeasonOptions(String recId){
              
        List<Digital_Release__c> options = new List<Digital_Release__c>();
        for(Product__c pro:[select id,Digital_Release__r.Series_Name__c from Product__c where id=:recId]){
            for (Digital_Release__c dr: [select id,Name from Digital_Release__c where Series_Name__c=:pro.Digital_Release__r.Series_Name__c AND IsDeleted =false ORDER BY CreatedDate DESC]) {
                options.add(dr);
            }
        }
        List<Product__c> pro1=[select id ,Digital_Release__r.Name from Product__c where id =:recId ]; 
        
        System.debug('options'+options);
        for(Integer i =0; i<options.size(); i++){
            if(options[i].Name == pro1[0].Digital_Release__r.name ){
                options.remove(i);
            }
        }
        System.debug('options'+options);
        return options;
    } 
}