/*****************************************************************************************
Class Name: BOMItemTriggerHandler
Purpose: This class is responsible to handle all the complexity during BOM Item Trigger executes. 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             03/09/2016           Ipsita                   Initial Development
******************************************************************************************/
public class BOMItemTriggerHandler
{
    // Local Variables.
    private static String uProfileName;
    private static String profileName;
    public static Set<Id> updateableMaterialIds = new Set<Id>();
    // Static constructor.
    static
    {
        if(TriggerUtility.currentUser != null){
            uProfileName = TriggerUtility.currentUser.Profile.Name;
        }
    }
    
    // Follwoing method manages the Before Insert trigger event.
    public static void executeOnBeforeInsert()
    {
    
        List<BOM_Item__c> updateTBOMList= new List<BOM_Item__c>();//RE-131
        
        // Executes only for Platform API.
        if(uProfileName == 'Platform API')
        {
            for(BOM_Item__c newBOM : (List<BOM_Item__c>)Trigger.New){
                //newBOM.BOM_Function__c = '023'; 
                
                //RE-131---  Code to initialize fields for TBOMS created from SAP.
                if(newBOM.Item_Category__c=='T'){
                    if(newBOM.Unit_of_Measure__c != 'PC'){
                        newBOM.Unit_of_Measure__c = 'PC';
                    }
                    if(newBOM.Production_Flag__c == null){
                        newBOM.Production_Flag__c = TRUE;
                    }   
                    if(newBOM.BOM_Quantity__c == null ||newBOM.BOM_Quantity__c == 0){
                        newBOM.BOM_Quantity__c = 1;
                    }
                }
                
            }
        }
        // Executes for all other users than Platform API.
        else
        {
            set<id> cmpID = new set<Id>();
            List<BOM_Item__c> bomRecList = new List<BOM_Item__c>();
            
            for(BOM_Item__c bom : (List<BOM_Item__c>)Trigger.New)
            {
                bom.BOM_Function__c = '009';
                cmpID.add(bom.Material_Component__c );
                
                system.debug('==========CmpID ==='+bom.Material_Component__c);
                system.debug('==========matID ==='+bom.Material__c);  
                if(bom.Material_Component__c != Null && bom.Material__c != Null){                                                                         
                    bomRecList.add(bom);
                } 
                
            }
            
            //Update Component Number  
            //list<Material__c> matRec = [select Material_Number__c,id from Material__c where Id IN:cmpID];
            Map<id,material__c> matRecMap = new Map<id,Material__c>([select id,Material_Number__c from Material__c where Id IN:cmpID]);                  
            
            // Updates component number with material's material number.
            for(BOM_Item__c bom : (List<BOM_Item__c>)Trigger.New)
            { 
                if(matRecMap.size()>0 && matRecMap!=null && matRecMap.containsKey(bom.material_Component__c)){      //matRec[0].Material_Number__c!=null ){                       
                    bom.Component_Number__c = matRecMap.get(bom.material_Component__c).Material_Number__c;        //matRec[0].Material_Number__c                        
                }  
            }  
            
            if(bomRecList.size()>0){
                BOMItemTriggerHandler.updateBomItem(bomRecList);
            }
        }
    }
    
    // Follwoing method manages the Before Update trigger event.
    public static void executeOnBeforeUpdate()
    {
        // Executes only for platform API.
        if(uProfileName == 'Platform API')
        {
            for(BOM_Item__c newBOM : (List<BOM_Item__c>)Trigger.New){
                //newBOM.BOM_Function__c = '023'; 
            }
        }
    }
    
    // Follwoing method manages the After Insert trigger event.
    public static void executeOnAfterInsert()
    {
        List<Task> lstTask = new List<Task>();
        Set<Id> compIds = new Set<Id>();
        Set<Id> parentIds = new Set<Id>();
        
        for(BOM_Item__c newBOM : (List<BOM_Item__c>)Trigger.New){
            if(newBOM.Material_Component__c != null)
                compIds.add(newBOM.Material_Component__c);
            if(newBOM.Material__c != null)
                parentIds.add(newBOM.Material__c);
        }
        //Added For REL-43
        Map<Id, Material__c> componentMap = new Map<Id, Material__c>([SELECT Id, Name, Component_Type__c, release__r.name, Format__c, Item_Code__c, Material_Number__c, Street_Date__c, Label_Code__c FROM Material__c WHERE Id IN: compIds]); 
        Map<Id, Material__c> parentMap; 
        Set<Id> parDispIds = new Set<Id>();
       
        if(!TriggerUtility.checkFromTemplate && !TriggerUtility.checkFromCloning)
            parentMap = new Map<Id, Material__c>([SELECT Id, Total_Item_Qty__c, Item_Type__c FROM Material__c WHERE Id IN: parentIds]); 
        
        for(BOM_Item__c newBOM : (List<BOM_Item__c>)Trigger.New){
            // Creates Task on parent material record.
            if(String.valueof(newBOM.Material__c) != null && string.valueof(newBOM.Material__c) != '' && newBOM.Material_Component__c != null) {
                Task objTask = new Task();
                objTask.Subject = 'Component Added';
                objTask.Description = 'Component Name: '+ componentMap.get(newBOM.Material_Component__c).Name + '\n' + 'Added By: '+ userinfo.getName() + '\n' + 'DateTime: ' + DateTime.Now() + '\n' +' Component Number: '+ newBOM.Component_Number__c  ;
                objTask.Activity_Description__c = 'Component Name: '+ componentMap.get(newBOM.Material_Component__c).Name + ' Added By: '+ userinfo.getName() + ' Component Number: '+ newBOM.Component_Number__c;
                objTask.Activity_Description__c = objTask.Activity_Description__c.left(120);                    
                objTask.WhatId = Id.valueof(newBOM.Material__c);
                objTask.Status = 'Completed';
                //Added below fields as part of REL-43
                objTask.Component_Type__c=componentMap.get(newBOM.Material_Component__c).Component_Type__c;
                objTask.Format__c=componentMap.get(newBOM.Material_Component__c).Format__c;
                objTask.Item_Code__c=componentMap.get(newBOM.Material_Component__c).Item_Code__c;
                objTask.Material_Number__c=componentMap.get(newBOM.Material_Component__c).Material_Number__c;
                objTask.Release_Name__c = componentMap.get(newBOM.Material_Component__c).release__r.name;
                objTask.Street_Date__c = componentMap.get(newBOM.Material_Component__c).Street_Date__c;//REL-155
                objTask.Label_Code__c = componentMap.get(newBOM.Material_Component__c).Label_Code__c;//REL-43 changes_6thNov
                objTask.MaterialDescription_SmartSheet__c = componentMap.get(newBOM.Material_Component__c).Name;//REL-43 changes_6thNov
                lstTask.add(objTask);
            }
            
            if(String.valueof(newBOM.Material__c) != null && string.valueof(newBOM.Material__c) != '')
                updateableMaterialIds.add(newBOM.Material__c);
            
            // Added for RE-17
            if(!TriggerUtility.checkFromTemplate && !TriggerUtility.checkFromCloning && 
               newBOM.Material__c != null && parentMap.get(newBOM.Material__c).Item_Type__c == 'D (Display Vehicle)')
            {
                parDispIds.add(newBOM.Material__c);
            }
        }
        
        if(lstTask.size() > 0)
            insert lstTask;
        
        if(uProfileName != 'Platform API')
        {
            BOMItemTriggerHandler.updateBomItemcompoDate(Trigger.New);
        }
        
        // Added for RE-17
        if(parDispIds.size() > 0)
            RSUCalculationHandler.updateMaterialTree(parDispIds, true);
        
    }
    
    // Follwoing method manages the After Update trigger event.
    public static void executeOnAfterUpdate()
    {
        List<Task> lstTask = new List<Task>();
        Set<Id> compIds = new Set<Id>();
        Set<Id> parentIds = new Set<Id>();
        Set<Id> bomitemId= new Set<Id>();
        
        for(BOM_Item__c newBOM : (List<BOM_Item__c>)Trigger.New){
            if(newBOM.Material_Component__c != null)
                compIds.add(newBOM.Material_Component__c);
            if(((Map<Id, BOM_Item__c>)Trigger.OldMap).get(newBOM.Id).Material_Component__c != null)
                compIds.add(((Map<Id, BOM_Item__c>)Trigger.OldMap).get(newBOM.Id).Material_Component__c);
            
            if(newBOM.Material__c != null)
                parentIds.add(newBOM.Material__c);    
            //Update Bom Status on Item Qty change - DF-1755/1754    
            
            //System.debug('###Inside AfterExecute of bomitem trigger');
            /*if(((Map<Id, BOM_Item__c>)Trigger.OldMap).get(newBOM.Id).Component_Quantity__c!=newBOM.Component_Quantity__c || 
                (((Map<Id, BOM_Item__c>)Trigger.OldMap).get(newBOM.Id).BOM_Quantity__c!=newBOM.BOM_Quantity__c)){
                bomitemId.add(newBOM.id);
               // System.debug('###ComponentQuantity Changed' ); 
            }*/                 
        }
        
        //REL-43 Added  fields Component_Type__c,Format__c,Item_Code__c,Material_Number__c,release__r.name to the below query.
        Map<Id, Material__c> componentMap = new Map<Id, Material__c>([SELECT Id, Name, Component_Type__c, release__r.name, Format__c, Item_Code__c, Material_Number__c, Street_Date__c, Label_Code__c FROM Material__c WHERE Id IN: compIds]); 
        Map<Id, Material__c> parentMap = new Map<Id, Material__c>([SELECT Id, Total_Item_Qty__c, Item_Type__c FROM Material__c WHERE Id IN: parentIds]); 
        Set<Id> parDispIds = new Set<Id>();
        
        //if(uProfileName != 'Platform API')
        //{
        ID tempOldComponentId;
        ID tempNewComponentId;
        
        for(BOM_Item__c newBOM : (List<BOM_Item__c>)Trigger.New){                
            tempOldComponentId = ((BOM_Item__c)Trigger.OldMap.get(newBOM.id)).Material_Component__c;
            
            // Creates task on previous material record while material is changed on Bom Item.
            if(String.valueof(newBOM.Material__c) != null && string.valueof(newBOM.Material__c) != '' && 
               newBOM.Material_Component__c != null && tempOldComponentId != newBOM.Material_Component__c) {
                   Task objTask = new Task();
                   objTask.Subject = 'Component Added';
                   objTask.Description = 'Component Name: '+ componentMap.get(newBOM.Material_Component__c).Name + '\n' + 'Added By: '+ userinfo.getName() + '\n' + 'DateTime: ' + DateTime.Now() + '\n' +' Component Number: '+ newBOM.Component_Number__c  ;
                   objTask.Activity_Description__c = 'Component Name: '+ componentMap.get(newBOM.Material_Component__c).Name + ' Added By: '+ userinfo.getName() + ' Component Number: '+ newBOM.Component_Number__c;
                   objTask.Activity_Description__c = objTask.Activity_Description__c.left(120);                    
                   objTask.WhatId = Id.valueof(newBOM.Material__c);
                   objTask.Status = 'Completed';
                   //Added below fields as part of REL-43
                   objTask.Component_Type__c=componentMap.get(newBOM.Material_Component__c).Component_Type__c;
                   objTask.Format__c=componentMap.get(newBOM.Material_Component__c).Format__c;
                   objTask.Item_Code__c=componentMap.get(newBOM.Material_Component__c).Item_Code__c;
                   objTask.Material_Number__c=componentMap.get(newBOM.Material_Component__c).Material_Number__c;
                   objTask.Release_Name__c = componentMap.get(newBOM.Material_Component__c).release__r.name;
                   objTask.Street_Date__c = componentMap.get(newBOM.Material_Component__c).Street_Date__c;//REL-155
                   objTask.Label_Code__c = componentMap.get(newBOM.Material_Component__c).Label_Code__c;//REL-43 changes_6thNov
                   objTask.MaterialDescription_SmartSheet__c = componentMap.get(newBOM.Material_Component__c).Name;//REL-43 changes_6thNov
                   
                   lstTask.add(objTask);
                   
                   updateableMaterialIds.add(newBOM.Material__c);
               }
            // Added for RE-17
            BOM_Item__c oldBOM = (BOM_Item__c)Trigger.OldMap.get(newBOM.id);
            if(oldBOM.Material__c != null && parentMap.get(oldBOM.Material__c).Item_Type__c == 'D (Display Vehicle)' && 
               (oldBOM.BOM_Quantity__c != newBOM.BOM_Quantity__c || oldBOM.Deletion_Flag__c != newBOM.Deletion_Flag__c || oldBOM.BOM_Function__c != newBOM.BOM_Function__c))
            {
                parDispIds.add(oldBOM.Material__c);
            } 
        } 
        // Added for RE-17
        if(parDispIds.size() > 0)
            RSUCalculationHandler.updateMaterialTree(parDispIds, true);
        
        for(BOM_Item__c oldBOM : (List<BOM_Item__c>)Trigger.Old){                
            tempNewComponentId = ((BOM_Item__c)Trigger.NewMap.get(oldBOM.id)).Material_Component__c;
            
            // Creates task on new material record while material is changed on Bom Item.
            if(String.valueof(oldBOM.Material__c) != null && string.valueof(oldBOM.Material__c) != '' && 
               oldBOM.Material_Component__c != null && tempNewComponentId != oldBOM.Material_Component__c) {
                   Task objTask = new Task();
                   objTask.Subject = 'Component Removed';
                   objTask.Description = 'Component Name: '+ componentMap.get(oldBOM.Material_Component__c).Name + '\n' + 'Added By: '+ userinfo.getName() + '\n' + 'DateTime: ' + DateTime.Now() + '\n' +' Component Number: '+ oldBOM.Component_Number__c  ;
                   objTask.Activity_Description__c = 'Component Name: '+ componentMap.get(oldBOM.Material_Component__c).Name + ' Added By: '+ userinfo.getName() + ' Component Number: '+ oldBOM.Component_Number__c;
                   objTask.Activity_Description__c = objTask.Activity_Description__c.left(120);
                   objTask.WhatId = Id.valueof(oldBOM.Material__c);
                   objTask.Status = 'Completed';
                   //Added below fields as part of REL-43
                   objTask.Component_Type__c=componentMap.get(oldBOM.Material_Component__c).Component_Type__c;
                   objTask.Format__c=componentMap.get(oldBOM.Material_Component__c).Format__c;
                   objTask.Item_Code__c=componentMap.get(oldBOM.Material_Component__c).Item_Code__c;
                   objTask.Material_Number__c=componentMap.get(oldBOM.Material_Component__c).Material_Number__c;
                   objTask.Release_Name__c = componentMap.get(oldBOM.Material_Component__c).release__r.name;
                   objTask.Street_Date__c = componentMap.get(oldBOM.Material_Component__c).Street_Date__c;//REL-155
                   objTask.Label_Code__c = componentMap.get(oldBOM.Material_Component__c).Label_Code__c;//REL-43 changes_6thNov
                   objTask.MaterialDescription_SmartSheet__c = componentMap.get(oldBOM.Material_Component__c).Name;//REL-43 changes_6thNov
                   lstTask.add(objTask);
                   
                   updateableMaterialIds.add(oldBOM.Material__c);
               }  
        }      
        
        
        if(lstTask.size() > 0)       
            insert lstTask;
        //}
        
        /*if(!bomitemId.isEmpty()){
            updateBomStatusOnItmQtyChnge(bomitemId);
        }*/        
    }
    
    // Following method manages the After Delete event.
    public static void executeOnAfterDelete()
    {
        List<Task> lstTask = new List<Task>();
        Set<Id> compIds = new Set<Id>();
        Set<Id> parentIds = new Set<Id>();
        for(BOM_Item__c oldBOM : (List<BOM_Item__c>)Trigger.Old){
            if(oldBOM.Material_Component__c != null)
                compIds.add(oldBOM.Material_Component__c);
            if(oldBOM.Material__c != null)
                parentIds.add(oldBOM.Material__c);
        }
        //REL-43 Added  fields Component_Type__c,Format__c,Item_Code__c,Material_Number__c,release__r.name to the below query.
        Map<Id, Material__c> componentMap = new Map<Id, Material__c>([SELECT Id, Name, Component_Type__c, Format__c, Item_Code__c, Material_Number__c,release__r.name, Street_Date__c, Label_code__c FROM Material__c WHERE Id IN: compIds]); 
        Map<Id, Material__c> parentMap = new Map<Id, Material__c>([SELECT Id, Total_Item_Qty__c, Item_Type__c FROM Material__c WHERE Id IN: parentIds]); 
        Map<Id, Material__c> updateableMaterials = new Map<Id, Material__c>();
        Set<Id> parDispIds = new Set<Id>();
        
        //if(uProfileName != 'Platform API')
        //{
        for(BOM_Item__c oldBOM : (List<BOM_Item__c>)Trigger.Old){                
            // Creates task on parent material when BOM Item is removed.
            if(String.valueof(oldBOM.Material__c) != null && string.valueof(oldBOM.Material__c) != '' && oldBOM.Material_Component__c != null) {
                Task objTask = new Task();
                objTask.Subject = 'Component Deleted';
                objTask.Description = 'Component Name: '+ componentMap.get(oldBOM.Material_Component__c).Name + '\n' + 'Deleted By: '+ userinfo.getName() + '\n' + 'DateTime: ' + DateTime.Now() + '\n' +' Component Number: '+ oldBOM.Component_Number__c  ;
                objTask.Activity_Description__c = 'Component Name: '+ componentMap.get(oldBOM.Material_Component__c).Name + ' Deleted By: '+ userinfo.getName() + ' Component Number: '+ oldBOM.Component_Number__c;
                objTask.Activity_Description__c = objTask.Activity_Description__c.left(120); 
                objTask.WhatId = Id.valueof(oldBOM.Material__c);
                objTask.Status = 'Completed';
                //Added below fields as part of REL-43
                objTask.Component_Type__c=componentMap.get(oldBOM.Material_Component__c).Component_Type__c;
                objTask.Format__c=componentMap.get(oldBOM.Material_Component__c).Format__c;
                objTask.Item_Code__c=componentMap.get(oldBOM.Material_Component__c).Item_Code__c;
                objTask.Material_Number__c=componentMap.get(oldBOM.Material_Component__c).Material_Number__c;
                objTask.Release_Name__c = componentMap.get(oldBOM.Material_Component__c).release__r.name;
                objTask.Street_Date__c = componentMap.get(oldBOM.Material_Component__c).Street_Date__c;//REL-155
                objTask.Label_Code__c = componentMap.get(oldBOM.Material_Component__c).Label_Code__c;//REL-43 changes_6thNov
                objTask.MaterialDescription_SmartSheet__c = componentMap.get(oldBOM.Material_Component__c).Name;//REL-43 changes_6thNov
                
                lstTask.add(objTask);
                
                updateableMaterialIds.add(oldBOM.Material__c);
            }
            
            // Added for RE-17
            if(oldBOM.Material__c != null && parentMap.get(oldBOM.Material__c).Item_Type__c == 'D (Display Vehicle)')
            {
                parDispIds.add(oldBOM.Material__c);
            }  
        }   
        
        if(lstTask.size() > 0)      
            insert  lstTask;
        //}
        // Changed for RE-17
        if(parDispIds.size() > 0)
            RSUCalculationHandler.updateMaterialTree(parDispIds, true);
    }
    
    // Following method updates several flag properties depending on parent and child material in BOM Item.
    public static void updateBomItem(list<BOM_Item__c> bomRec)
    {
        set<Id> matRecID = new set<Id>();
        set<Id> matCompRecID = new set<Id>();
        Map<Id,Material__c> matRecMap = new Map<Id,Material__c>();
        Map<Id,Material__c> matCompRecMap = new Map<Id,Material__c>();
        set<Id> bomRecID = new set<Id>();
        
        // Fetching parent and child material ids.
        for(BOM_Item__c each : bomRec){
            bomRecID.add(each.Id);
            matRecID.add(each.Material__c);
            matCompRecID.add(each.Material_Component__c);
            system.debug('==========Cmp ==='+each.Material_Component__c);
            system.debug('==========mat ==='+each.Material__c);
            
        }
        
        // Retreiving parent and child material data.
        for(Material__c mat :[Select ID, Material_Type__c,Item_Code__c,Item_Type__c from Material__c Where ID IN:matRecID]){
            system.debug('=========mat==='+mat);
            matRecMap.put(mat.id,mat);         
        }
        
        for(Material__c compPat :[Select ID, Material_Type__c,Item_Code__c from Material__c Where ID IN:matCompRecID]){
            system.debug('=========compPat==='+compPat);
            matCompRecMap.put(compPat.id,compPat);         
        }  
        
        // Iterating over current context BomItems.
        for(BOM_Item__c each : bomRec){             
            // If any of the material record not found in system, continue to next iteration.
            if(!matRecMap.containsKey(each.Material__c) || !matCompRecMap.containsKey(each.Material_Component__c))
                continue;
            
            // Following conditions evaluate to few flag values.
            if(each.Material__c !=Null && each.Material_Component__c!=Null && matCompRecMap.get(each.Material_Component__c).Material_Type__c !=null && matCompRecMap.get(each.Material_Component__c).Item_Code__c !=null && (matCompRecMap.get(each.Material_Component__c).Material_Type__c == 'ROH' && (matCompRecMap.get(each.Material_Component__c).Item_Code__c != 'DS - DISC' && matCompRecMap.get(each.Material_Component__c).Item_Code__c != 'DA - DISC ART' && matCompRecMap.get(each.Material_Component__c).Item_Code__c != 'DL - DISC LAYER'))){
                system.debug('==========1 ===');
                each.Costing_Flag__c = 'X - 100% relevant to costing';
                each.Item_Category__c = 'L';
                each.Production_Flag__c  = True;
                each.Sales_Flag__c = False;
            }
            else if(each.Material__c !=Null && each.Material_Component__c!=Null && matCompRecMap.get(each.Material_Component__c).Material_Type__c !=null && matCompRecMap.get(each.Material_Component__c).Item_Code__c !=null && (matCompRecMap.get(each.Material_Component__c).Material_Type__c == 'ROH' && (matCompRecMap.get(each.Material_Component__c).Item_Code__c == 'DS - DISC' || matCompRecMap.get(each.Material_Component__c).Item_Code__c == 'DA - DISC ART' || matCompRecMap.get(each.Material_Component__c).Item_Code__c == 'DL - DISC LAYER'))){
                system.debug('==========2 ===');
                each.Costing_Flag__c = 'N - Not relevant to costing';
                each.Item_Category__c = 'N';
                each.Production_Flag__c  = True;
                each.Sales_Flag__c = False;
            }
            else if(each.Material__c !=Null && each.Material_Component__c!=Null && matCompRecMap.get(each.Material_Component__c).Material_Type__c !=null && matCompRecMap.get(each.Material_Component__c).Material_Type__c == 'Z009'){
                system.debug('==========3 ===');
                each.Costing_Flag__c = 'N - Not relevant to costing';
                each.Item_Category__c = 'L';
                each.Production_Flag__c  = True;
                each.Sales_Flag__c = False;
            }
            else if(each.Material__c !=Null && each.Material_Component__c!=Null && matCompRecMap.get(each.Material_Component__c).Material_Type__c!=null && matCompRecMap.get(each.Material_Component__c).Material_Type__c == 'ZVSM'){
                system.debug('==========4 ===');
                each.Costing_Flag__c = 'N - Not relevant to costing';
                each.Item_Category__c = 'N';
                each.Production_Flag__c  = True;
                each.Sales_Flag__c = False;
            } 
            else if(each.Material__c !=Null && each.Material_Component__c!=Null && matRecMap.get(each.Material__c).Item_Type__c!=null && matCompRecMap.get(each.Material_Component__c).Material_Type__c!=null && matCompRecMap.get(each.Material_Component__c).Item_Code__c!=null && matCompRecMap.get(each.Material_Component__c).Material_Type__c == 'FERT' && matCompRecMap.get(each.Material_Component__c).Item_Code__c == 'BF - BABY FERT' ){
                system.debug('==========5 ===');
                each.Costing_Flag__c = 'N - Not relevant to costing';
                each.Item_Category__c = 'N';
                each.Production_Flag__c  = False;
                each.Sales_Flag__c = False;
            } 
            else if(each.Material__c !=Null && each.Material_Component__c!=Null && matRecMap.get(each.Material__c).Item_Type__c!=null && matCompRecMap.get(each.Material_Component__c).Material_Type__c!=null && matCompRecMap.get(each.Material_Component__c).Item_Code__c!=null && matCompRecMap.get(each.Material_Component__c).Material_Type__c == 'FERT' && matCompRecMap.get(each.Material_Component__c).Item_Code__c != 'BF - BABY FERT' && (matRecMap.get(each.Material__c).Item_Type__c== 'S (Single)' || matRecMap.get(each.Material__c).Item_Type__c== 'M (Multipack)')){
                system.debug('==========6 ===');
                each.Costing_Flag__c = 'X - 100% relevant to costing';
                each.Item_Category__c = 'L';
                each.Production_Flag__c  = True;
                each.Sales_Flag__c = False;
            }
            else if(each.Material__c !=Null && each.Material_Component__c!=Null && matRecMap.get(each.Material__c).Item_Type__c!=null && matCompRecMap.get(each.Material_Component__c).Material_Type__c!=null && matCompRecMap.get(each.Material_Component__c).Item_Code__c!=null && matCompRecMap.get(each.Material_Component__c).Material_Type__c == 'FERT' && matCompRecMap.get(each.Material_Component__c).Item_Code__c != 'BF - BABY FERT' && matRecMap.get(each.Material__c).Item_Type__c == 'D (Display Vehicle)'){
                system.debug('==========7 ===');
                each.Costing_Flag__c = 'X - 100% relevant to costing';
                each.Item_Category__c = 'L';
                each.Production_Flag__c  = True;
                each.Sales_Flag__c = True;
            }
            else if(each.Material__c !=Null && each.Material_Component__c!=Null && matCompRecMap.get(each.Material_Component__c).Material_Type__c!=null && matCompRecMap.get(each.Material_Component__c).Material_Type__c == 'ZVSM'){
                system.debug('==========8 ===');
                each.Costing_Flag__c = 'N - Not relevant to costing';
                each.Item_Category__c = 'N';
                each.Production_Flag__c  = True;
                each.Sales_Flag__c = False;
            } 
        }             
    }
    
    // Following method updates Component Dates from parent material.
    public static void updateBomItemcompoDate(list<BOM_Item__c> bomrec)
    {
        map<id,Material__c> parentMatRec = new map<id,Material__c>();
        set<Id> matRecID = new set<Id>();
        set<Id> matCompRecID = new set<Id>();
        Map<Id,Material__c> matRecMap = new Map<Id,Material__c>();
        list<Material__c> updateComRec = new list<Material__c>();
        set<Id> comId= new set<Id>();
        SET<ID> parMatIds = new set<Id>();
        Set<ID> setProcessed = new Set<ID>();
        
        for(BOM_Item__c each : bomRec){
            matRecID.add(each.Material__c);
            matCompRecID.add(each.Material_Component__c);          
            
        }
        
        // Retreiving parent and child materials.
        for(Material__c mat :[Select ID,Street_Date__c,Release__c from Material__c Where ID IN:matRecID]){
            matRecMap.put(mat.id,mat);         
        } 
        
        list<Material__c> comRec = [Select id,Street_Date__c,Release__c,Item_Code__c,Material_Type__c  from Material__c where Id IN:matCompRecID];
        
        // Iterating over bom to populate date fields in child materials.
        for(BOM_Item__c each : bomRec){
            for(Material__c eachmat : comRec){
                if(each.Material_Component__c == eachmat.Id && !setProcessed.contains(eachmat.id) && eachmat.Release__c != null && eachmat.Release__c ==  matRecMap.get(each.Material__c).Release__c){
                    if(eachmat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false) {
                        eachmat.Street_Date__c =  matRecMap.get(each.Material__c).Street_Date__c ;
                        updateComRec.add(eachmat);
                    }
                    setProcessed.add(eachmat.id);
                } 
            }     
            
        }
        if(updateComRec.size()>0)
            Database.update(updateComRec, false);
        
    }
    
    // It updates the BOM Quantity field.
    public static void updateItemQuantity(){
        List<BOM_Item__c> lstBOMItem = new List<BOM_Item__c>();
        for(BOM_Item__c newBOM : (List<BOM_Item__c>)Trigger.New){
            system.debug('bom qnty=='+newBOM.BOM_Quantity__c);
            if(newBOM.Component_Quantity__c != '' && newBOM.Component_Quantity__c != null && newBOM.Component_Quantity__c != String.Valueof(newBOM.BOM_Quantity__c)){ //Added NULL check for USST-2542
                newBOM.BOM_Quantity__c = Decimal.valueOf(newBOM.Component_Quantity__c);
            }
        }
    }
    
    // Following method updates BOM Status in material while material number is populated by plantform API user.
    public static void updateBOMStatusfromSAP(Set<Id> matNumber){
        List<Material__c> matLst = new List<Material__c>();
        List<Material__c> matList = [select id,BOM_Status__c,createdBy.Profile.Name,Material_Number__c,Material_Type__c from Material__c where id IN: matNumber];
        
        if(matList.size() > 0){
            for(Material__c mat : matList){
                if(mat.Material_Number__c != null && TriggerUtility.currentUser.Profile.Name == 'Platform API' && mat.Material_Type__c != 'ZVSM' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'  && mat.BOM_Status__c == 'Draft' && mat.createdBy.Profile.Name == 'Platform API'){
                    mat.BOM_Status__c = 'In Progress';
                    matLst.add(mat);
                }
                else if(mat.Material_Number__c != null && TriggerUtility.currentUser.Profile.Name == 'Platform API' && mat.Material_Type__c == 'ZVSM' && mat.Material_Type__c == 'ROH' && mat.Material_Type__c == 'Z009'  && mat.createdBy.Profile.Name == 'Platform API'){
                    mat.BOM_Status__c = 'Draft';
                    matLst.add(mat);
                }
            }
        }
        if(matLst.size() > 0){
            update matLst;
        }   
    }
    
    // It updates the associated component status to Approved when parent is submitted with its material number. 
    public static void updateComponentStatus(Set<Id> matl){
        List<Material__c> lstMatl = new List<Material__c>();    
        List<BOM_Item__c> bomList = [SELECT Id, Material_Component__c, Material__c,Material__r.BOM_Status__c, Material__r.Material_Status__c, Material__r.Material_Number__c, Material__r.Label_Code__c, Material_Component__r.Material_Status__c
                                     FROM BOM_Item__c 
                                     WHERE Material__c IN: matl AND Material_Component__r.Material_Type__c IN ('ROH', 'Z009')];
        system.debug('bomList '+bomList);
        if(bomList.size() > 0){
            for(BOM_Item__c bom : bomList){
                if(bom.Material__r.Material_Number__c != null && bom.Material__r.Label_Code__c != null && bom.Material_Component__r.Material_Status__c == 'Submitted'){
                    System.debug('JC error');
                    Material__c mat = new Material__c();
                    mat.id = bom.Material_Component__c;
                    mat.Selection_Reference_Number__c = bom.Material__r.Material_Number__c;
                    //mat.Label_Code__c = bom.Material__r.Label_Code__c;
                    mat.BOM_Status__c = 'Approved';
                    system.debug('bomList '+mat);
                    lstMatl.add(mat);
                    system.debug('bomList '+lstMatl);
                }
            }
        }
        if(lstMatl.size() > 0){
            update lstMatl;
        }
        
    }
    
    // Following method updates the BOM Status depending on SAP integration.
    public static void updatestatusFromSAP(List<BOM_Item__c> bomItemList){
        Map<Id,Material__c> bomMatList = new Map<Id,Material__c>();
        Map<Id,Material__c> bomMatCompList = new Map<Id,Material__c>();
        set<id> newId = new set<id>();
        if(TriggerUtility.currentUser != null){
            profileName = TriggerUtility.currentUser.Profile.Name;
        }
        
        if(bomItemList.size() > 0){
            for(BOM_Item__c bom : bomItemList){
                if(bom.Material__c != null ){
                    newId.add(bom.Material__c);
                }
            }
            Map<Id,Material__c> mapMaterial = new Map<Id,Material__c>([Select id, BOM_Status__c from Material__c where id IN: newId]);
            for(BOM_Item__c bom : bomItemList){
                if(profileName == 'Platform API'){
                    if(bom.Material__c != null && bom.Material_Component__c != null && bom.Material_Component__c <> System.Label.DISC_BOM_MASTER && 
                       mapMaterial.get(bom.Material__c) != null && mapMaterial.get(bom.Material__c).BOM_Status__c == 'Draft'){    // Modified for RE-180
                        Material__c mat = mapMaterial.get(bom.Material__c);
                        mat.BOM_Status__c = 'In Progress';
                        bomMatList.put(mat.id,mat);
                    }
                }
            }
        }
        if(bomMatList.size() > 0){
            update bomMatList.values();
        }
    }
    
    //This method updates the BOM function to same as Material BOM function
    public static void updateBOMFuncFromSAP(List<BOM_Item__c> bomItemList){
        Map<Id,Material__c> bomMatList = new Map<Id,Material__c>();
        Map<Id,Material__c> bomMatCompList = new Map<Id,Material__c>();
        set<id> newId = new set<id>();
        if(TriggerUtility.currentUser != null){
            profileName = TriggerUtility.currentUser.Profile.Name;
        }
        if(bomItemList.size() > 0){
            for(BOM_Item__c bom : bomItemList){
                if(bom.Material__c != null ){
                    newId.add(bom.Material__c);
                }
                if(bom.Material_Component__c != null){
                    newId.add(bom.Material_Component__c);
                }
            }
            Map<Id,Material__c> mapMaterial = new Map<Id,Material__c>([Select id, BOM_Status__c,BOM_Function__c from Material__c where id IN: newId]);
            for(BOM_Item__c bom : bomItemList){
                if(profileName == 'Platform API'){
                    if(bom.Material__c != null ){
                        Material__c mat = mapMaterial.get(bom.Material__c);
                        bom.Function__c = mat.BOM_Function__c;
                        //bomMatList.put(mat.id,mat);
                    }
                }
            }
        }
    }
    
    //This Method updates the BOM Status when a BOM is deleted
    public static void updateBOMStatusOnDelete(List<BOM_Item__c> bomItemList){
        Map<Id,Material__c> bomMatList = new Map<Id,Material__c>();
        set<id> newId = new set<id>();
        if(bomItemList.size() > 0){
            for(BOM_Item__c bom : bomItemList){
                if(bom.Material__c != null ){
                    newId.add(bom.Material__c);
                }
            }
            
            Map<Id,Material__c> mapMaterial = new Map<Id,Material__c>([Select id, BOM_Status__c,BOM_Number__c,Plant__c,BOM_Usage__c,BOM_Category__c,Alternative_BOM__c, Territory__c, (SELECT Id FROM BOM_Items__r LIMIT 1) from Material__c where id IN: newId]);
            system.debug('mapMaterial==== '+mapMaterial);
            for(BOM_Item__c bom : bomItemList){
                if(bom.Material__c != null ){
                    Material__c mat = mapMaterial.get(bom.Material__c);
                    if(mat.BOM_Items__r.size() == 0){
                        mat.BOM_Status__c = 'Draft';
                        mat.BOM_Number__c = '';
                        //USST-2814 --- start
                        if (mat.Territory__c == 'CDN') {
                            mat.Plant__c = 'V850';
                        }
                        else {
                            mat.Plant__c =  'V000';
                        }
                        mat.BOM_Category__c = 'M';
                        mat.Alternative_BOM__c = '1';
                        mat.BOM_Usage__c = '3';
                        //USST-2814 --- end
                        bomMatList.put(mat.id,mat);
                    }
                }
            }
        }
        if(!bomMatList.isEmpty()){
            update bomMatList.values();
        }
    }
    
    //Update Bom Status on Item Qty change - DF-1755/1754
     public static void updateBomStatusOnItmQtyChnge(Set<Id>bomitemId){
        List<Material__c>udpateMatList=new List<Material__c>();
        Set<Id>materialid=new Set<Id>();
        
        if(!bomitemId.isEmpty()){
            for(Bom_item__c bomItem:[Select Material_component__c,Material__r.item_type__c from Bom_item__c where id in:bomitemId AND Item_Category__c != 'T']){
                System.debug('##Material Item Type'+bomItem.Material__r.item_type__c);
                if(bomItem.Material__r.item_type__c=='D (Display Vehicle)'){
                    materialid.add(bomItem.Material__c);
                }
            }
        }
        System.debug('##Inside updateBomStatusOnItmQtyChnge'+materialid);
        
        if(!materialid.isEmpty()){
            for(Material__c mat: [Select id,bom_status__c,bom_integration_state__c,item_type__c from Material__c where id in:materialid])
            {
                if(mat.bom_status__c=='Processed in SAP'){
                    System.debug('JC error');
                    mat.bom_status__c='Approved';
                    mat.bom_integration_state__c='N';
                    mat.bom_function__c='004';
                    udpateMatList.add(mat);
                }
            }
        
        }
        if(!udpateMatList.isEmpty()){
            update udpateMatList;
        }
    }
}