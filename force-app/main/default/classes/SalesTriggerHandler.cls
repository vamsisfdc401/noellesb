/*****************************************************************************************
Class Name: SalesTriggerHandler
Purpose: Sales Trigger handler class to handle logic.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             21/08/2016                                    Initial Development
******************************************************************************************/
public class SalesTriggerHandler{
    private static String uProfileName;
    
    // Static constructor
    static
    {
        if(TriggerUtility.currentUser != null){
            uProfileName = TriggerUtility.currentUser.Profile.Name;
        }
    }
    
    /*********************************************************************
    Method Name: executeOnBeforeInsert
    Purpose:Handles Before Insert logic.
    **********************************************************************/
    public static void executeOnBeforeInsert(){
        Set<Id> matIds = new Set<Id>();
        for(Sales__c sales : (List<Sales__c>) Trigger.New)
        {
            if(sales.Material__c != null){
                matIds.add(sales.Material__c);
            }    
        }
        Map<Id, Date> materialRelDateMap = new Map<Id, Date>();
        Map<Id, Material__c> matMap = new Map<Id, Material__c>();
        
        list <Material__c> mat1 = [SELECT Id, Release__r.Physical_Street_Date__c, RecordTypeId, Original_Material_Number__c, Original_Material_Number__r.Material_Status__c 
        FROM Material__c WHERE Id IN: matIds];
        
        System.debug('updatematerial '+mat1);
        
        for(Material__c mat : [SELECT Id, Release__r.Physical_Street_Date__c, RecordTypeId, Original_Material_Number__c, Original_Material_Number__r.Material_Status__c, Item_Code__c  
        FROM Material__c WHERE Id IN: matIds]) //USST-3069
        {
            System.debug('updatematerial '+mat);
            if (mat.Item_Code__c != 'BF - BABY FERT') { //USST-3069
                materialRelDateMap.put(mat.Id, mat.Release__r.Physical_Street_Date__c);
            }
            matMap.put(mat.Id, mat);
        }
        System.debug('materialRelDateMap '+materialRelDateMap);
        
        list<Sales__c> salesRec = new list<Sales__c>();
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        for(Sales__c sales : (List<Sales__c>) Trigger.New)
        {
            if(sales.Material__c != null && materialRelDateMap.get(sales.Material__c) != null){
                sales.Original_Release_Date__c = materialRelDateMap.get(sales.Material__c);
              }    
            
            // Checking for platform API user.
            if(uProfileName == 'Platform API'){
                sales.Function__c = '023';
            }
            else{
                if((sales.Function__c == null || sales.Function__c.trim() == '') && 
                sales.Material__c != null && matMap.get(sales.Material__c).RecordTypeId == recTypeId && matMap.get(sales.Material__c).Original_Material_Number__c != null)
                {
                    if(matMap.get(sales.Material__c).Original_Material_Number__r.Material_Status__c == 'Processed in SAP'){
                        sales.Function__c = '023';
                    }
                    else if(matMap.get(sales.Material__c).Original_Material_Number__r.Material_Status__c == 'Sent to SAP' ||
                    matMap.get(sales.Material__c).Original_Material_Number__r.Material_Status__c == 'SAP Error')
                    {
                        sales.Function__c = '004';
                    }
                }
                else if(sales.Function__c == null || sales.Function__c.trim() == ''){
                    sales.Function__c = '009';
                }
            }     
            
            if(sales.Material__c != null)
            {
                salesRec.add(sales);
            }
        }
        
        //if(salesRec.size()>0)
        if(TriggerUtility.currentUser.Name!='API User'){
        
            SalesTriggerHandler.updatePreOrderDate(Trigger.New);
        }    
    }
    
    /*********************************************************************
    Method Name: executeOnBeforeUpdate
    Purpose:Handles Before Update event.
    **********************************************************************/
    public static void executeOnBeforeUpdate()
    {
        for(Sales__c sales : (List<Sales__c>) Trigger.New)
        {
            if(uProfileName == 'Platform API'){
                sales.Function__c = '023';
            }
            else{
                if(sales.Function__c == '023'){// && !sales.isUpdateRecordType__c 
                    sales.Function__c = '004';
                }
                if(sales.Deletion_Flag__c){
                    sales.Function__c = '003';
                }
            }      
        }
    }
    
    
    /*********************************************************************
    Method Name: executeOnAfterInsert
    Purpose:Handles After Insert Event.
    **********************************************************************/
     public static void executeOnAfterInsert()
    {
        // Fields to be checked.
        Map<String, String> salesMaterialDateFieldMap = new Map<String, String>{'Street_Date__c' => 'Street_Date__c',
                                    'Theatrical_Release_Date__c' => 'Theatrical_Release_Date__c',
                                    'Windowed_Rental_Pre_Order_Close_Date__c' => 'Windowed_Rental_Pre_Order_Close_Date__c',
                                    'Windowed_Rental_Street_Date__c' => 'Windowed_Rental_Street_Date__c',
                                    'VOD_Street_Date__c' => 'VOD_Street_Date__c',
                                    'Internal_Announce_Date__c' => 'Internal_Announce_Date__c',
                                    'Solicitation_Date__c' => 'Trade_Solicitation_Date__c',
                                    'In_Plant_Date__c' => 'In_Plant_Date__c',
                                    'Pre_Order_Date__c' => 'Pre_Order_Close_Date__c',
                                    'EST_Date__c' => 'EST_Date__c'
                                   };
        
        // Below Map captures minimum date diffrence value with its associated field name.
        Map<Id, Map<String, Date>> materialWithSalesDateFieldMap = new Map<Id, Map<String, Date>>();
        List<Sales__c>salesUpdate=new List<Sales__c>();
        
        for(Id salesId : Trigger.newMap.keySet())
        {
            Sales__c newIns = (Sales__c) Trigger.newMap.get(salesId);
            // Sales__c oldIns = (Sales__c) Trigger.oldMap.get(salesId);
            
            if(newIns.Material__c != null)
            {
                // If map does not contain material id, create instance.
                if(!materialWithSalesDateFieldMap.containsKey(newIns.Material__c)){
                    materialWithSalesDateFieldMap.put(newIns.Material__c, new Map<String, Date>());
                }
                for(String salesFieldApi : salesMaterialDateFieldMap.keySet())
                {
                    if(newIns.get(salesFieldApi) != null)
                    {
                        if(materialWithSalesDateFieldMap.get(newIns.Material__c).containsKey(salesFieldApi))
                        {
                            // Compare existing date in map and new date value.
                            Integer existingDateDiff = math.abs(Date.today().daysBetween(materialWithSalesDateFieldMap.get(newIns.Material__c).get(salesFieldApi)));
                            Integer newDateDiff = math.abs(Date.today().daysBetween(Date.valueOf(newIns.get(salesFieldApi))));
                            
                        }    
                        else
                        {
                            materialWithSalesDateFieldMap.get(newIns.Material__c).put(salesFieldApi, Date.valueOf(newIns.get(salesFieldApi)));
                        }
                    }
                }
            }
            
            if(newIns.Street_Date__c!=null || newIns.Theatrical_Release_Date__c!=null ||newIns.Pre_Order_Date__c!=null||newIns.Original_Release_Date__c!=null||newIns.Solicitation_Date__c!=null){
                salesUpdate.add(newIns);
            }
        }        
        
        // Update the Sales date in Materials.
        List<Material__c> updateMaterialList = new List<Material__c>();
        for(Id matId : materialWithSalesDateFieldMap.keySet())
        {
            Material__c instance = new Material__c();
            instance.Id = matId;
            for(String salesFieldApi : materialWithSalesDateFieldMap.get(matId).keySet())
            {
                String materialFieldApi = salesMaterialDateFieldMap.get(salesFieldApi);
                instance.put(materialFieldApi, materialWithSalesDateFieldMap.get(matId).get(salesFieldApi));
            }
            
            updateMaterialList.add(instance);
        }
        
        if(updateMaterialList.size() > 0 && TriggerUtility.currentUser.Name!='API User')
        {
            if(TriggerUtility.checkFromCloning){
                TriggerUtility.doNotExecute = TRUE; 
            }
            //update updateMaterialList;
            if(TriggerUtility.checkFromCloning){
                TriggerUtility.doNotExecute = FALSE;
            } 
        }
        
        if(TriggerUtility.currentUser.Profile.Name=='Platform API' && TriggerUtility.currentUser.Name=='API User'){
            if(!salesUpdate.isEmpty()){
                updateStreetDateOnMaterial(salesUpdate);  
            }    
        }
    }
    
    
    /*********************************************************************
    Method Name: executeOnAfterUpdate
    Purpose:Handles After Update Event.
    **********************************************************************/
    // Handles After Update Event.
    public static void executeOnAfterUpdate()
    {
        // Fields to be checked.
        Map<String, String> salesMaterialDateFieldMap = new Map<String, String>{'Street_Date__c' => 'Street_Date__c',
                                    'Theatrical_Release_Date__c' => 'Theatrical_Release_Date__c',
                                    'Windowed_Rental_Pre_Order_Close_Date__c' => 'Windowed_Rental_Pre_Order_Close_Date__c',
                                    'Windowed_Rental_Street_Date__c' => 'Windowed_Rental_Street_Date__c',
                                    'VOD_Street_Date__c' => 'VOD_Street_Date__c',
                                    'Internal_Announce_Date__c' => 'Internal_Announce_Date__c',
                                    'Solicitation_Date__c' => 'Trade_Solicitation_Date__c',
                                    'In_Plant_Date__c' => 'In_Plant_Date__c',
                                    'Pre_Order_Date__c' => 'Pre_Order_Close_Date__c',
                                    'EST_Date__c' => 'EST_Date__c'
                                   };
        
        // Below Map captures minimum date diffrence value with its associated field name.
        Map<Id, Map<String, Date>> materialWithSalesDateFieldMap = new Map<Id, Map<String, Date>>();
        List<Sales__c>salesUpdate=new List<Sales__c>();
        Set<id>salesIds=new Set<id>();
        Set<id>matids=new Set<id>();
        
        for(Id salesId : Trigger.newMap.keySet())
        {
            Sales__c newIns = (Sales__c) Trigger.newMap.get(salesId);
            Sales__c oldIns = (Sales__c) Trigger.oldMap.get(salesId);
            
            if(newIns.Material__c != null)
            {
                // If map does not contain material id, create instance.
                if(!materialWithSalesDateFieldMap.containsKey(newIns.Material__c)){
                    materialWithSalesDateFieldMap.put(newIns.Material__c, new Map<String, Date>());
                }
                
                for(String salesFieldApi : salesMaterialDateFieldMap.keySet())
                {
                    if(newIns.get(salesFieldApi) != oldIns.get(salesFieldApi) && newIns.get(salesFieldApi) != null)
                    {
                        if(materialWithSalesDateFieldMap.get(newIns.Material__c).containsKey(salesFieldApi))
                        {
                            // Compare existing date in map and new date value.
                            Integer existingDateDiff = math.abs(Date.today().daysBetween(materialWithSalesDateFieldMap.get(newIns.Material__c).get(salesFieldApi)));
                            Integer newDateDiff = math.abs(Date.today().daysBetween(Date.valueOf(newIns.get(salesFieldApi))));
                            
                            // If current date is 
                            if(newDateDiff < existingDateDiff)
                            {
                                materialWithSalesDateFieldMap.get(newIns.Material__c).put(salesFieldApi, Date.valueOf(newIns.get(salesFieldApi)));
                            }
                        }    
                        else
                        {
                            materialWithSalesDateFieldMap.get(newIns.Material__c).put(salesFieldApi, Date.valueOf(newIns.get(salesFieldApi)));
                        }
                    }
                }
            }
            
            if((newIns.Street_Date__c!=oldIns.Street_Date__c && newIns.Street_Date__c!=null) || (newIns.Pre_Order_Date__c!=oldIns.Pre_Order_Date__c && newIns.Pre_Order_Date__c!=null)
            ||(newIns.Original_Release_Date__c!=oldIns.Original_Release_Date__c && newIns.Original_Release_Date__c!=null) || (newIns.Solicitation_Date__c!=oldIns.Solicitation_Date__c && newIns.Solicitation_Date__c!=null)
            ||(newIns.Theatrical_Release_Date__c!=oldIns.Theatrical_Release_Date__c && newIns.Theatrical_Release_Date__c!=null)){
                salesUpdate.add(newIns);
            }
            if(newIns.Deletion_Flag__c!=oldIns.Deletion_Flag__c && newIns.Deletion_Flag__c!=true)
            {
                salesIds.add(newIns.Id);
                matids.add(newIns.material__c);
            }
        }
        
        // Update the Sales date in Materials.
        List<Material__c> updateMaterialList = new List<Material__c>();
        for(Id matId : materialWithSalesDateFieldMap.keySet())
        {
            Material__c instance = new Material__c();
            instance.Id = matId;
            for(String salesFieldApi : materialWithSalesDateFieldMap.get(matId).keySet())
            {
                String materialFieldApi = salesMaterialDateFieldMap.get(salesFieldApi);
                instance.put(materialFieldApi, materialWithSalesDateFieldMap.get(matId).get(salesFieldApi));
            }
            
            updateMaterialList.add(instance);
        }
        
        
        if(!TriggerUtility.initiatedFromMaterial && updateMaterialList.size() > 0 && TriggerUtility.currentUser.Name!='API User')
        {
            if(TriggerUtility.checkFromCloning){
                TriggerUtility.doNotExecute = TRUE; 
            }
            //update updateMaterialList;
            if(TriggerUtility.checkFromCloning){
                TriggerUtility.doNotExecute = FALSE;
            } 
        }
        
        if(TriggerUtility.currentUser.Profile.Name=='Platform API' && TriggerUtility.currentUser.Name=='API User'){
            if(!salesUpdate.isEmpty()){
                updateStreetDateOnMaterial(salesUpdate);               
            }    
        }
        if(TriggerUtility.currentUser.Profile.Name=='Platform API' && TriggerUtility.currentUser.Name=='API User'){
            if(!matids.isEmpty()){
                updateStreetDateOnMaterialOnDelete(matids,salesids);
            }    
        }
    
    }
    
    //Mathod to update Pre Order Date based on Material Format Description
    public static void updatePreOrderDate(list<Sales__c> salesRecList)
    {
        set<Id> matId = new Set<Id>();
        list<Sales__c> updateSalesRec = new List<Sales__c>();
        for(Sales__c each : salesRecList){
            matId.add(each.Material__c);
        } 
        
        
        Map<Id, Material__c> mapMatRec = new Map<Id, Material__c>([Select Id,Pre_Order_Close_Date__c,Street_Date__c,Theatrical_Release_Date__c,
        Trade_Solicitation_Date__c,Original_Release_Date__c,Internal_Announce_Date__c
        from Material__c where Id IN:matId]);      
        
        try {
            for(Sales__c sales : salesRecList){
                Material__c rel = mapMatRec.get(sales.material__c);  
                if(sales.material__c != null && mapMatRec.containsKey(sales.material__c) && mapMatRec.get(sales.material__c).Theatrical_Release_Date__c != null){
                    sales.Theatrical_Release_Date__c = mapMatRec.get(sales.material__c).Theatrical_Release_Date__c;
                } 
                if(sales.material__c != null && mapMatRec.containsKey(sales.material__c) && mapMatRec.get(sales.material__c).Pre_Order_Close_Date__c != null){
                    sales.Pre_Order_Date__c = mapMatRec.get(sales.material__c).Pre_Order_Close_Date__c;
                    
                }
                if(sales.material__c != null && mapMatRec.containsKey(sales.material__c) && mapMatRec.get(sales.material__c).Street_Date__c != null){
                    sales.Street_Date__c = mapMatRec.get(sales.material__c).Street_Date__c;
                }
                if(sales.material__c != null && mapMatRec.containsKey(sales.material__c) && mapMatRec.get(sales.material__c).Trade_Solicitation_Date__c != null){
                    sales.Solicitation_Date__c = mapMatRec.get(sales.material__c).Trade_Solicitation_Date__c;
                }
                if(sales.material__c != null && mapMatRec.containsKey(sales.material__c) && mapMatRec.get(sales.material__c).Original_Release_Date__c != null){
                    sales.Original_Release_Date__c = mapMatRec.get(sales.material__c).Original_Release_Date__c;
                }
                if(sales.material__c != null && mapMatRec.containsKey(sales.material__c) && mapMatRec.get(sales.material__c).Internal_Announce_Date__c != null){
                    sales.Announcement_Date_US__c = mapMatRec.get(sales.material__c).Internal_Announce_Date__c;
                }   
                updateSalesRec.add(sales);
            }
        }
        catch(System.DmlException ex){
            System.debug(ex.getMessage());
        
        }
        if(updateSalesRec.size() > 0){
        }   
    
    }
    
    /*********************************************************************
    Method Name: updateStreetDateOnMaterial
    Purpose:Biz logic to be executed on update/insert of streetDate on sales record by API User
    **********************************************************************/
    public static void updateStreetDateOnMaterial(List<Sales__c>SalesList){
        Set<id>matIds=new Set<id>();
        Map<id,List<Sales__c>>salesMap=new Map<id,List<Sales__c>>();
        List<Material__c>updateMatList=new List<Material__c>();
        List<Sales__c>salesList1=new List<Sales__c>();
        Boolean isChanged;
        
        if(!SalesList.isEmpty()){
            for(Sales__c sales:SalesList){
                if(sales.Street_Date__c!=null && sales.material__c!=null && sales.Deletion_Flag__c==false){
                    matIds.add(sales.material__c);
                    if(salesMap.containsKey(sales.material__c)){
                        salesMap.get(sales.material__c).add(sales);
                    }
                    else{
                        salesMap.put(sales.material__c,new List<Sales__c>{sales});
                    }
                }
            
            }
        }
        
        for(Material__c mat:[Select Street_Date__c,Territory__c,Theatrical_Release_Date__c,Pre_Order_Close_Date__c,Trade_Solicitation_Date__c,Original_Release_Date__c, Material__c.Internal_Announce_Date__c from Material__c where id in:matIds]){
        isChanged=false;
        if(mat.Territory__c!='US & CDN'){
            if(salesMap.containsKey(mat.id) && (mat.Street_Date__c==null || mat.Street_Date__c!=salesMap.get(mat.id)[0].Street_Date__c)){
                mat.Street_Date__c=salesMap.get(mat.id)[0].Street_Date__c;  
                isChanged=true;                  
            }
            if(salesMap.containsKey(mat.id) && (mat.Pre_Order_Close_Date__c==null || mat.Pre_Order_Close_Date__c!=salesMap.get(mat.id)[0].Pre_Order_Date__c)){
                mat.Pre_Order_Close_Date__c=salesMap.get(mat.id)[0].Pre_Order_Date__c;  
                system.debug('**Pre_Order_Close_Date__c '+mat.Pre_Order_Close_Date__c);
                isChanged=true;                  
            }
            if(salesMap.containsKey(mat.id) && (mat.Original_Release_Date__c==null || mat.Original_Release_Date__c!=salesMap.get(mat.id)[0].Original_Release_Date__c)){
                mat.Original_Release_Date__c=salesMap.get(mat.id)[0].Original_Release_Date__c;  
                isChanged=true;                  
            }
            if(salesMap.containsKey(mat.id) && (mat.Trade_Solicitation_Date__c==null || mat.Trade_Solicitation_Date__c!=salesMap.get(mat.id)[0].Solicitation_Date__c)){
                mat.Trade_Solicitation_Date__c=salesMap.get(mat.id)[0].Solicitation_Date__c;  
                isChanged=true;                  
            }
            if(salesMap.containsKey(mat.id) && (mat.Theatrical_Release_Date__c==null || mat.Theatrical_Release_Date__c!=salesMap.get(mat.id)[0].Theatrical_Release_Date__c)){
                mat.Theatrical_Release_Date__c=salesMap.get(mat.id)[0].Theatrical_Release_Date__c;  
                isChanged=true;                  
            }
            if(salesMap.containsKey(mat.id) && (mat.Internal_Announce_Date__c==null || mat.Internal_Announce_Date__c!=salesMap.get(mat.id)[0].Announcement_Date_US__c)){
                mat.Internal_Announce_Date__c=salesMap.get(mat.id)[0].Announcement_Date_US__c;  
                isChanged=true;                  
            }
            if(isChanged==true)
                updateMatList.add(mat);
        }
        
        else if(mat.Territory__c=='US & CDN'){
                if(salesMap.containsKey(mat.id)){
                    salesList1=salesMap.get(mat.id);
                    if(!salesList1.isEmpty()){
                        for(Sales__c s:salesList1){
                            if(s.sales_org__c=='V100 - US Home Video' && (mat.street_date__c==null || mat.street_date__c!=s.Street_Date__c)){
                                mat.Street_Date__c=s.Street_Date__c;
                                isChanged=true;
                            }
                            if(s.sales_org__c=='V100 - US Home Video' && (mat.Pre_Order_Close_Date__c==null || mat.Pre_Order_Close_Date__c!=s.Pre_Order_Date__c)){
                                mat.Pre_Order_Close_Date__c=s.Pre_Order_Date__c;
                                system.debug('**Pre_Order_Close_Date__c '+mat.Pre_Order_Close_Date__c);
                                isChanged=true;
                            }
                            if(s.sales_org__c=='V100 - US Home Video' && (mat.Original_Release_Date__c==null || mat.Original_Release_Date__c!=s.Original_Release_Date__c)){
                                mat.Original_Release_Date__c=s.Original_Release_Date__c;
                                isChanged=true;
                            }
                            if(s.sales_org__c=='V100 - US Home Video' && (mat.Trade_Solicitation_Date__c==null || mat.Trade_Solicitation_Date__c!=s.Solicitation_Date__c)){
                                mat.Trade_Solicitation_Date__c=s.Solicitation_Date__c;
                                isChanged=true;
                            }
                            if(s.sales_org__c=='V100 - US Home Video' && (mat.Theatrical_Release_Date__c==null || mat.Theatrical_Release_Date__c!=s.Theatrical_Release_Date__c)){
                                mat.Theatrical_Release_Date__c=s.Theatrical_Release_Date__c;
                                isChanged=true;
                            }
                            if(salesMap.containsKey(mat.id) && (mat.Internal_Announce_Date__c==null || mat.Internal_Announce_Date__c!=salesMap.get(mat.id)[0].Announcement_Date_US__c)){
                                mat.Internal_Announce_Date__c=salesMap.get(mat.id)[0].Announcement_Date_US__c;  
                                isChanged=true;                  
                            }
                        }
                    }
                    
                    if(isChanged==true)
                    updateMatList.add(mat);
                }
        
            }
        }
        
        if(!updateMatList.isEmpty()){
            if(TriggerUtility.checkFromCloning){
                TriggerUtility.doNotExecute = TRUE; 
            }
            update updateMatList;
            if(TriggerUtility.checkFromCloning){
                TriggerUtility.doNotExecute = FALSE;
            } 
        }
    }
    
   /*********************************************************************
    Method Name: updateStreetDateOnMaterialOnDelete
    Purpose:Biz logic to be executed on deletion of sales record by API User
    **********************************************************************/
    public static void updateStreetDateOnMaterialOnDelete(Set<id>MatIds,Set<id>salesIds){
    
        List<Material__c>updateMatList =new List<Material__c>();
        for(Material__c m:[select id,street_date__c, (select id,street_Date__c,sales_org__c,Original_Release_Date__c,Theatrical_Release_Date__c,Solicitation_Date__c,Pre_Order_Date__c from sales__r where id not in:salesIds) from Material__c where id in:MatIds]){
            if(MatIds.contains(m.id) && m.sales__r.size()>0){
                m.street_date__c=m.sales__r[0].Street_Date__c;
                m.Original_Release_Date__c=m.sales__r[0].Original_Release_Date__c;
                m.Theatrical_Release_Date__c=m.sales__r[0].Theatrical_Release_Date__c;
                m.Trade_Solicitation_Date__c=m.sales__r[0].Solicitation_Date__c;
                m.Pre_Order_Close_Date__c=m.sales__r[0].Pre_Order_Date__c;
                updateMatList.add(m);
            }
        }
        System.debug('##updateStreetDateOnMaterialOnDelete'+updateMatList);
        if(!updateMatList.isEmpty()){
            if(TriggerUtility.checkFromCloning){
                TriggerUtility.doNotExecute = TRUE; 
            }
            update updateMatList;
            if(TriggerUtility.checkFromCloning){
                TriggerUtility.doNotExecute = FALSE;
            }
        }
    }   
    
    /*********************************************************************
    Method Name: executeOnBeforeDelete 
    Purpose:streetDate Update on Material When a sales record is deleted by APIUser
    **********************************************************************/ 
    public static void executeOnBeforeDelete(List<Sales__c>SalesList){
        Set<id>salesIds=new Set<id>();
        Set<id>matIds= new Set<id>();
        
        for(Sales__c sales:SalesList){
            salesIds.add(sales.id);
            matIds.add(sales.material__c);
        }
        
        if(!salesIds.isEmpty() && !matIds.isEmpty() && TriggerUtility.currentUser.Name=='API User'){
            updateStreetDateOnMaterialOnDelete(matIds,salesIds);
        }
    } 
    
      /*****************************************************************
    Method Name: UpdateMaterialStatus 
    Purpose:Update on Material status when a sales D-chain spec is XX
                by APIUser
    ****************************************************************  
    public static void UpdateMaterialStatus(List<Sales__c>SalesList){
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        List<Material__c> matList = new List<Material__c>();
        
        Set<id> matId = new Set<id>();
        for(Sales__c salesMat:SalesList){
            matId.add(salesMat.material__c);
        }
        Map<Id, Material__c> matMap = new Map<Id, Material__c>([select id,recordTypeId from Material__c where Id IN : matId]);
        for(Sales__c sales:SalesList){
            if(sales.D_Chain_Spec__c == 'XX - Never Released' && matMap.get(sales.Material__c).RecordTypeId != recTypeId){
                Material__c mat = new Material__c();
                mat.id = sales.material__c;
                mat.Material_status__c = 'Deleted';
                matList.add(mat);
            }
        }
        
        if(matList.size() > 0){
            
            TriggerUtility.doNotExecute = true;
            update matList;
        }
    }   
*/
}