/*****************************************************************************************
Class Name: FlowCloneRecord 
Purpose: Apex class to clone any record with all the fields that can be edited which is called from the Flow to clone the approved board pack
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             26/09/2016           Ashwini Gnanamurthy      Initial Development
******************************************************************************************/
public class FlowCloneRecord {
   
   /************************************
    Method Name: cloneObjectRecord
    Purpose: clone any record with all the fields that can be edited
    *************************************/ 
   @InvocableMethod
    public static List<Id> cloneObjectRecord(List<Id> toBeClonedRecordIds) {
        
        //Fetch Object Name
        String sObjName = toBeClonedRecordIds[0].getSObjectType().getDescribe().getName();
        
        
        ///Fetch all writable fields
        String selects = '';         
                
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(sObjName.toLowerCase()).getDescribe().Fields.getMap();
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
              
               
        List<Id> clonedRecordIds = new List<Id>(); 
        List<SObject> clonedRecords = new List<SObject>();       
        
        String query = 'SELECT '+selects+' from '+sObjName+ ' where ID IN :toBeClonedRecordIds';            
        
        List<SObject> tobeClonedRecords = Database.query(query);         
        
        for(Sobject rec : tobeClonedRecords ){
            SObject clonedrec = rec.clone(false, true, false, false);            
            clonedRecords.add(clonedrec);
        }
        insert clonedRecords; 
               
        for(SObject clones :clonedRecords){
            clonedRecordIds.add(clones.id);
        }
        system.debug('//////clonedRecordIds' +clonedRecordIds);
        return clonedRecordIds;
    }
    
}