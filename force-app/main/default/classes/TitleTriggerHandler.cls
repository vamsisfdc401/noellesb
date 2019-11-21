/*****************************************************************************************
Class Name: TitleTriggerHandler
Purpose: This class handles the business logic for the Title Trigger
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             27/07/2017           Jay Ehrgott              Initial Development
******************************************************************************************/
public class TitleTriggerHandler {
    
    private static Set<ID> setTitleIds = new Set<ID>();
    private static Id PreOrderTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(DGF_Constants.PRE_ORDER).getRecordTypeId();
    
    //Method to set a Salesforce reference lookup to a parent title, if one exists for the Title record
    public static void setParentTitle(){
        
		//Get GTM recordTypeId 
        Id recTypeId = Schema.Sobjecttype.Title__c.getRecordTypeInfosByName().get('GTM').getRecordTypeId();        
        System.debug('recTypeId.....'+recTypeId);
 
		//Create a set of parent SGENNOS included in the trigger execution
        Set<String> parentSgenno = new Set<String>();
        for (Title__c t : (List<Title__c>)Trigger.new) {
            String newParent = t.Parent_SGENNO__c;
            parentSgenno.add(newParent);
        }
       
	    // Query to create a list of Parent Titles
    	List<Title__c> parentList = new List<Title__c>(
        	[select Id,SGENNO__c from Title__c 
			 where SGENNO__c in :parentSgenno]);        

		// Iterate over the parent list to make a map of SGENNO to Id  
        Map<String,Id> mapSgennoIds = new Map<String, Id>();       
        for(Title__c parentTitle : parentList) { 
            if(parentTitle.SGENNO__c != null){
                mapSgennoIds.put(parentTitle.SGENNO__c, parentTitle.Id);
            }
        }

        //Iterate through records in Trigger.new and set the Parent Title field to the ID of the parent, based on sysgen
        //Set value to null if no Parent SGENNO on the record    
        for(Title__c t : (List<Title__c>)trigger.new){
            if(t.RecordTypeId == recTypeId){   // Should not execute on any type except 'GTM'
                if(t.Parent_SGENNO__c != null){ 
                    t.Parent_Title__c = mapSgennoIds.get(t.Parent_SGENNO__c);              
                }
                else{
                    t.Parent_Title__c = null;
                }
            }
        }                
    }    
    
    
    /***********************************
    Method Name: executeOnAfterUpdate
    Purpose:Should execute only for after update event
    ***********************************/    
    public static void executeOnAfterUpdate() {  //DFOR-1498
    	list<product__c> updateProducts =  new List<Product__C>();
    	for (title__c title : (List<title__c>)trigger.new) {
    		
    		 title__c titleOld = (title__c)Trigger.oldMap.get(title.id);
            //adding version id to set
            if (titleOld.EIDR__c!= title.EIDR__c && !setTitleIds.contains(title.id)) {
                setTitleIds.add(title.id);
            }
        }
        
        if(!setTitleIds.isEmpty()){
        	List<Digital_Release__c> digiReleaseList = [select id, title__c, (select id, L1_EIDR__c from products__r where recordtypeid = :PreOrderTypeId) from digital_release__c where title__c = : setTitleIds];
        	 
        	
        	if(!digiReleaseList.isEmpty()){
        		for(digital_release__c dr : digiReleaseList){        			
        			if(dr.products__r!=null && dr.products__r.size()>0){
        				title__c title = (title__c)Trigger.newMap.get(dr.title__c);
        				for(product__C prod: dr.products__r){        					
        					prod.L1_EIDR__c = title.EIDR__c;
        					updateProducts.add(prod);
        				}
        			}
        		}
        		
        		if(!updateProducts.isEmpty()){
        			update updateProducts;
        		}
        	}
        }
    	
    }
    
}