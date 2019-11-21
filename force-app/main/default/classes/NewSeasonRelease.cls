public class NewSeasonRelease {
     
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
        
        String selects = '';        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
        
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
            
        }        
        
        return 'SELECT ' + selects + ' FROM ' + objectName + ' ';
        
    }
    @AuraEnabled
    public static List<Digital_Release__c> getSeasonOptions(String recId){
        List<Digital_Release__c> options = new List<Digital_Release__c>();
        for (Digital_Release__c dr: [select id,Name from Digital_Release__c where Series_Name__c=:recId AND IsDeleted =false ORDER BY CreatedDate DESC]) {
            options.add(dr);
        }
        System.debug('options'+options);
        return options;
    }
    @AuraEnabled
    public static String saveRec(String recId,String strName, String strTitle,String seasonId){
        
        String strMsg = '';
        DGF_TriggerUtility.executeDigitalReleaseTrigger = FALSE;
        system.debug('===recId==='+recId);
        list<Digital_Release__c> rname = new list<Digital_Release__c>();
        rname=[select id, name,of_Seasons__c from Digital_Release__c where id=:recID ];
        list<Digital_Release__c> lstDROld = new list<Digital_Release__c>();
        lstDROld = [SELECT CreatedDate,Id,Name,Series_Name__r.name,Season__c,of_Seasons__c 
                    FROM Digital_Release__c 
                    WHERE Series_Name__c =: recId                   
                    ORDER BY CreatedDate DESC
                    LIMIT 1];
        if(lstDROld ==null)
        {	
            strMsg = 'No Records Found';
            return strMsg;
            
        }
        
        Id devRecordTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('TV').getRecordTypeId();   
        String ProdName ='';
        String newDRId = '';
        String soql = getCreatableFieldsSOQL('Digital_Release__c','');
        soql+= ' WHERE Id = \''+seasonId+'\'';
        system.debug('soql====='+soql);
        list<Digital_Release__c> lstDigtR = Database.query(soql);
        if(lstDigtR!=null)
        {
            Digital_Release__c dr = lstDigtR[0].clone(false, true);   
            
            dr.Series_Name__c = recId;           
            dr.RecordTypeId = devRecordTypeId;
            dr.Title__c = strTitle;
            dr.Season__c =String.valueOf(Integer.valueOf(rname[0].of_Seasons__c) +1);
            system.debug('season value---------------'+dr.Season__c);
            dr.name = strName; 
            ProdName =strName;
            
            dr.US_EST_Launch_Date__c=null;
            dr.CA_EST_Launch_Date__c=null;
            dr.US_Initial_EST_Launch_Date__c=null;
            dr.CA_Initial_EST_Launch_Date__c=null;
            dr.Season_On_Air_Premiere_Date__c=null;
            
            dr.Clone_pricing_records_from_last_season__c = false; 
            insert dr;
            newDRId = dr.Id;            
            
        }
        // Update the parent Digital Release with increment value        
        list<Digital_Release__c> lstDRParent = new list<Digital_Release__c>();
        lstDRParent = [SELECT CreatedDate,Id,Name,Series_Name__c,of_Seasons__c 
                       FROM Digital_Release__c 
                       WHERE Id =: recId
                       LIMIT 1
                      ];
        if(lstDRParent!=null && lstDRParent.size()>0)
        {
            
            If(lstDRParent[0].of_Seasons__c != null) 
                
                
                lstDRParent[0].of_Seasons__c +=1;
            
            update lstDRParent;
            
        }
        Id recTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Episode Pricing').getRecordTypeId();        
        Map<Id,Product__c> oldProduct = new Map<Id,Product__c>();
        List<Product__c> newProductList = new List<Product__c>();
        List<Pricing__c> newPricingList = new List<Pricing__c>();
        set<Id> prodIdSet = new set<Id>();
        List<Product__c> productList = [Select Id, Name ,X3D__c, HD__c,HDR__c,SD__c,UHD__c,EST_Tier__c,
                                        US_Platform_Offering__c,CA_Platform_Offering__c,
                                        RecordTypeId
                                        FROM Product__c 
                                        where Digital_Release__c =: seasonId  ];
        
        system.debug('productList===='+productList);
        for(Product__c prod : productList){
            Product__c newProduct = prod.clone(false, true, false, false); //do a deep clone
            newProduct.Digital_Release__c = newDRId;    //p.Id;
            newProduct.name = ProdName;
            if(recTypeId == prod.RecordTypeId)
            {
                newProduct.name = ProdName+'(per Episode)';
            }
            
            newProductList.add(newProduct);
            oldProduct.put(prod.Id,newProduct);
            prodIdSet.add(prod.Id);
        }
        system.debug('newProductList===='+newProductList);
        system.debug('oldProduct===='+oldProduct);
        insert newProductList;
        
        return  newDRId+' '+ProdName;
    }
    
}