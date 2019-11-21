/*****************************************************************************************
TriggerName: BOMItemTrigger 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             19/07/2016           Ipsita                    Initial Development
******************************************************************************************/
trigger BOMItemTrigger on BOM_Item__c (before insert, after insert, before update, after update, after delete,before delete) {
    
    String uProfileName;
    Set<Id> matNumber = new Set<Id>();
    Set<Id> matl = new Set<Id>();    
    private static string recFertMatId;
    private static string recFertMatIdIns;
    private static Set<Id> setFertMat = new Set<Id>();
    Set<Id> setFertMat2 = new Set<Id>();
 
    if(TriggerUtility.currentUser != null){
        uProfileName = TriggerUtility.currentUser.Profile.Name;
    }
    
    if(!TriggerUtility.hasTriggerExecuted('BOM_Item__c'))
    {
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            BOMItemTriggerHandler.updateItemQuantity();
        }
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            for(BOM_Item__c bom : Trigger.New){
                matNumber.add(bom.Material_Component__c);
                matl.add(bom.Material__c);
            }
            BOMItemTriggerHandler.updateBOMStatusfromSAP(matNumber);    
            BOMItemTriggerHandler.updateComponentStatus(matl);
        }
        
        // Handling Before events
        if(Trigger.isBefore)
        {
            // Scope for Before Insert
            if(Trigger.isInsert)
            {
                BOMItemTriggerHandler.executeOnBeforeInsert();
            }
            // Scope for Before Update
            else if(Trigger.isUpdate)
            {
                updateMaterialsIntegrationState();
                
                BOMItemTriggerHandler.executeOnBeforeUpdate();
            }
        }
        // Handling After events
        else
        {
            // Scope for After Insert
            if(Trigger.isInsert)
            {
                //updateBOMFunction();
                
                BOMItemTriggerHandler.executeOnAfterInsert();
                if(uProfileName != 'Platform API')
                    updateBOMCountInMaterial(uProfileName);
            }
            // Scope for After Update
            else if(Trigger.isUpdate)
            {
                //updateBOMFunction();
                
                BOMItemTriggerHandler.executeOnAfterUpdate();
                //BOMItemTriggerHandler.updateItemQuantity();
                if(uProfileName != 'Platform API')
                    updateBOMCountInMaterial(uProfileName);
            }
            // Scope for After Delete
            else if(Trigger.isDelete)
            {
                BOMItemTriggerHandler.executeOnAfterDelete();
            }
        }
        // For Defect 2622
        /***Set<Id> setFertMat = new Set<Id>();
        List<Material__c> lstFertMat = new List<Material__c>();
        if(Trigger.isupdate && trigger.isAfter){
            for(BOM_Item__c bom : Trigger.New){
                //bom.Bom_Item_Text__c ='Testing1' ;
                if(bom.Deletion_Flag__c == True && bom.Material_Component__r.Material_Type__c =='FERT' && Trigger.oldMap.get(bom .id).Deletion_Flag__c == False){
                 bom.Bom_Item_Text__c ='Testing2' ;
                    if(!setFertMat.contains(bom.Material_Component__c)){
                     bom.Bom_Item_Text__c ='Testing3' ;
                        setFertMat.add(bom.Material_Component__c);
                    }
                }
            }
            for(Material__c objMat : [select id,Name,BOM_Status__c from Material__c where id in: setFertMat]){
                objMat.BOM_Status__c ='Approved';
                lstFertMat.add(objMat);
            } 
            if(lstFertMat.size()>0){
                Database.update(lstFertMat);
            }  
        } ***/
    }
    
    
     //Update Bom Status on Item Qty change - DF-1755/1754
     Set<Id> bomitemId= new Set<Id>();
    if(Trigger.isupdate && trigger.isAfter){
        for(Bom_item__c bItem:Trigger.New){
            if(Trigger.oldMap.get(bItem.id).BOM_Quantity__c!=bItem.BOM_Quantity__c){
                bomitemId.add(bItem.id);
            }
        }
        
        if(!bomitemId.isEmpty()){
            BOMItemTriggerHandler.updateBomStatusOnItmQtyChnge(bomitemId);
        }
    }
    
   
    
    // This method updates the child BOM count in Material record.
    private void updateBOMCountInMaterial(String profileName){
        if(profileName != 'Platform API'){
            system.debug('USST-2622');
            List<Material__c> updateableMaterials = new List<Material__c>();
            Map<Id, Integer> materialChildCountMap = new Map<Id, Integer>();
            for(AggregateResult c : [SELECT Material__c, count(Id) total 
                                     FROM BOM_Item__c
                                     WHERE Material__c IN :BOMItemTriggerHandler.updateableMaterialIds 
                                     GROUP BY Material__c])
            {
                materialChildCountMap.put(String.valueOf(c.get('Material__c')), Integer.valueOf(String.valueOf(c.get('total'))));
            }
            
            for(Id matId : BOMItemTriggerHandler.updateableMaterialIds)
            {
                Material__c mat = new Material__c();
                mat.Id = matId;
                mat.Count_BOM_Item__c = 0;
                
                if(materialChildCountMap.containsKey(matId))
                {
                    mat.Count_BOM_Item__c = materialChildCountMap.get(matId);
                    system.debug('USST-2622');
                }
                updateableMaterials.add(mat);
            }
            if(updateableMaterials.size() > 0){
                system.debug('USST-2622');
                try{                                                                    //USST-2675
                    update updateableMaterials;
                }                                                                       //USST-2675
                catch (Exception ex){                                                        
                   trigger.new[0].adderror('Changes cannot be made while Material is in Submitted status. Please wait for Master Data to approve.');
                }      
            }   
        
        } 
    }
    
      
    public void updateMaterialsIntegrationState()
    {
        List<Material__c> updateableMaterials = new List<Material__c>();
        Set<Id> updateableIntegrationMaterialIds = new Set<Id>();
        
        List<BOM_Item__c> bomRecList = new List<BOM_Item__c>();
        
        if(Trigger.isBefore && Trigger.isUpdate)
        {
           set<id> cmpID = new set<Id>();
           
            for(Id recId : Trigger.NewMap.keySet())
            {
                BOM_Item__c newIns = (BOM_Item__c) Trigger.NewMap.get(recId);
                BOM_Item__c oldIns = (BOM_Item__c) Trigger.OldMap.get(recId);
                
                if(newIns.Material_Component__c != oldIns.Material_Component__c && newIns.Material_Component__c!=null){
                   cmpID.add(newIns.Material_Component__c );
                }
              
               if(newIns.Material_Component__c != oldIns.Material_Component__c || newIns.Material__c != oldIns.Material__c){
                   bomRecList.add(newIns);
                }
                
                if(newIns.Material__r.BOM_Status__c != oldIns.Material__r.BOM_Status__c && newIns.Material__r.BOM_Status__c == 'Approved')
                {
                    newIns.BOM_Integration_State__c = 'N';
                    if(newIns.Material_Component__c != null)
                        updateableIntegrationMaterialIds.add(newIns.Material_Component__c);
                }
                else if(newIns.BOM_Integration_State__c != oldIns.BOM_Integration_State__c)
                {
                    if(newIns.BOM_Integration_State__c == 'P')
                    {
                        newIns.Material__r.BOM_Status__c = 'Sent to SAP';
                    }
                    else if(newIns.BOM_Integration_State__c == 'S')
                    {
                        newIns.Material__r.BOM_Status__c = 'Processed in SAP';
                    }
                    else if(newIns.BOM_Integration_State__c == 'E')
                    {
                        newIns.Material__r.BOM_Status__c = 'SAP Error';
                    }
                }
            }
            
            if(bomRecList.size()>0){
              BOMItemTriggerHandler.updateBomItem(bomRecList);
            }
            //Update Component Number  
              list<Material__c> matRec = [select Material_Number__c from Material__c where Id IN:cmpID];  
              Map<id,material__c> matRecMap = new Map<id,Material__c>([select id,Material_Number__c from Material__c where Id IN:cmpID]);                
                   
                    for(BOM_Item__c bom : Trigger.New)
                    {
                        if(matRec.size()>0 && matRecMap!=null){//&& matRec[0].Material_Number__c!=null){
                            bom.Component_Number__c = matRecMap.get(bom.material_Component__c).Material_Number__c;  //matRec[0].Material_Number__c;
                        
                         } 
                   }
            
            if(updateableIntegrationMaterialIds.size() > 0)
            {
                for(Id matId : updateableIntegrationMaterialIds)
                {
                    Material__c mat = new Material__c();
                    mat.Id = matId;
                    mat.BOM_Integration_State__c = 'N';
                    updateableMaterials.add(mat);
                }
                
                update updateableMaterials;
            }
        }
    }
    
    // Following method is responsible to update the BOM function value of Parent Material and BOM Item object.
    public void updateBOMFunction()
    {
        Set<Id> childMaterialIds = new Set<Id>();
        System.debug('----->updateBOMFunction');
        if(Trigger.isBefore && Trigger.isUpdate)
        {
            for(BOM_Item__c bom : Trigger.New)
            {
                if(bom.Material_Component__c != null)
                    childMaterialIds.add(bom.Material_Component__c);
            }
            System.debug('-----childMaterialIds> '+childMaterialIds);
            if(childMaterialIds.size() > 0)
            {
                Set<Id> processedChildMaterialIds = new Set<Id>();
                
                for(Material__c mat : [SELECT Id FROM Material__c
                                       WHERE Id IN :childMaterialIds AND BOM_Status__c='Processed in SAP'])
                {
                    processedChildMaterialIds.add(mat.Id);
                }
                
                if(processedChildMaterialIds.size() > 0)
                {
                    for(BOM_Item__c bom : Trigger.New)
                    {
                        if(bom.Material_Component__c != null && processedChildMaterialIds.contains(bom.Material_Component__c) && bom.BOM_Function__c != '003')
                            bom.BOM_Function__c = '004';
                    }
                }
            }
        }
        else if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete))
        {
            Map<Id, Id> childParentMaterialMap = new Map<Id, Id>();
            
            if(Trigger.isInsert || Trigger.isUpdate)
            {
                for(BOM_Item__c bom : Trigger.New)
                {
                    if(bom.Material__c != null  && bom.Material_Component__c != null)
                        childParentMaterialMap.put(bom.Material_Component__c, bom.Material__c);
                }
            }
            else
            {
                for(BOM_Item__c bom : Trigger.Old)
                {
                    if(bom.Material__c != null  && bom.Material_Component__c != null)
                        childParentMaterialMap.put(bom.Material_Component__c, bom.Material__c);
                }
            }
            System.debug('-----childParentMaterialMap> '+childParentMaterialMap);
            
            if(childParentMaterialMap.size() > 0)
            {
                Set<Id> updateableParentMaterialIds = new Set<Id>();
                Set<Id> updateableBomItems4ChildMats = new Set<Id>();
                
                for(Material__c mat : [SELECT Id FROM Material__c
                                       WHERE Id IN :childParentMaterialMap.keySet() AND BOM_Status__c='Processed in SAP'])
                {
                    if(childParentMaterialMap.containsKey(mat.Id))
                        updateableParentMaterialIds.add(childParentMaterialMap.get(mat.Id));
                }
                
                if(updateableParentMaterialIds.size() > 0)
                {
                    List<Material__c> updateableMaterialList = new List<Material__c>();
                    for(Id matId : updateableParentMaterialIds)
                    {
                        Material__c mat = new Material__c();
                        mat.Id = matId;
                        mat.BOM_Function__c = '004';
                        
                        updateableMaterialList.add(mat);
                    }
                    
                    update updateableMaterialList;
                }
            }
        }
    }
    
 
    if(!TriggerUtility.doNotExecute && Trigger.isAfter && Trigger.isInsert){
        BOMItemTriggerHandler.updatestatusFromSAP(Trigger.New);
    } 
    if(!TriggerUtility.doNotExecute && Trigger.isBefore && Trigger.isInsert){
        BOMItemTriggerHandler.updateBOMFuncFromSAP(Trigger.New);
    }  
     
    if(!TriggerUtility.doNotExecute && Trigger.isAfter && Trigger.isDelete && uProfileName == 'Platform API'){
        BOMItemTriggerHandler.updateBOMStatusOnDelete(Trigger.old); //USST-2609
    }
    // Adding below things for defect 2622
    if(Trigger.isBefore && Trigger.isDelete){
        List<Material__c> lstFertMat = new List<Material__c>();
        for(BOM_Item__c bom : Trigger.old){
        recFertMatId = bom.Material_Component__c;
                if(bom.Material_Component__r.Material_Type__c =='FERT'){
                    if(!setFertMat2.contains(bom.Material_Component__c)){
                        setFertMat2.add(recFertMatId);
                        recFertMatId=bom.Material_Component__c;
                    }
                }
            }
            for(Material__c objMat : [select id,Name,BOM_Status__c from Material__c where id in: setFertMat2]){
               if(objMat.BOM_Status__c =='Processed in SAP' && objMat.Material_Type__c =='FERT'){
                    objMat.BOM_Status__c ='Approved';
                    lstFertMat.add(objMat);
                }
            } 
            if(lstFertMat.size()>0){
                Database.update(lstFertMat);
            }      
    }
   // Adding Below Piece of code for 2622 and 2684
  /*** if(Trigger.isAfter){
        if(Trigger.isInsert){
        List<Material__c> lstFertMat = new List<Material__c>();
          for(BOM_Item__c bom : Trigger.new){
              system.debug('Checking the BOM id---'+bom.Material__c+bom.Material__r.Name);
              recFertMatId = bom.Material__c;
              if( !setFertMat2.contains(bom.Material__c) && recFertMatId != null && bom.Material__c != null){
                  setFertMat.add(recFertMatId );
                  setFertMat2.add(recFertMatId);
                  recFertMatId=bom.Material__c;
              }
          }
          for(Material__c objMat : [select id,Name,BOM_Status__c,Material_Type__c  from Material__c where id in: setFertMat2 ]){
          system.debug('Checking the BOM status and Material Type---'+objMat.BOM_Status__c+objMat.Material_Type__c);
              if(objMat.BOM_Status__c =='Processed in SAP' && objMat.Material_Type__c =='FERT' ){
                    objMat.BOM_Integration_State__c ='N';
                    objMat.BOM_Status__c ='Approved';
                    lstFertMat.add(objMat);
                }
            } 
            if(lstFertMat.size()>0){
            system.debug('I am performing DML operation-----'+lstFertMat.size());
                Database.update(lstFertMat);
            }        
        }
        else if(Trigger.isupdate){
          List<Material__c> lstFertMat = new List<Material__c>();
           for(BOM_Item__c bom : Trigger.new){
              recFertMatId = bom.Material__c;
              if( !setFertMat2.contains(bom.Material_Component__c)  && recFertMatId != null && bom.Deletion_Flag__c){
                 setFertMat2.add(recFertMatId );
                  //recFertMatId=bom.Material_Component__c;
              }
              // for 2700
              
               
           }
           for(Material__c objMat : [select id,Name,BOM_Status__c,Material_Type__c  from Material__c where id in: setFertMat2 ]){
              if(objMat.BOM_Status__c =='Processed in SAP' && objMat.Material_Type__c =='FERT'){
                    objMat.BOM_Integration_State__c ='N';
                    objMat.BOM_Status__c ='Approved';
                    lstFertMat.add(objMat);
                }
            } 
            if(lstFertMat.size()>0){
                Database.update(lstFertMat);
            }     
        }
    
    }
    ***/
    //USST-2749 -- start
    if (Trigger.isBefore && Trigger.isInsert) {
        Set<ID> setMatIDs = new Set<ID>();
        List<Bom_Item__c> lstBoms = new List<Bom_Item__c>();
        List<Material__c> lstMats = new List<Material__c>();
        Map<ID,String> matTerrMap = new Map<ID,String>();
        
        for (Bom_Item__c bom : Trigger.new) {
            setMatIDs.add(bom.Material__c);
        }
        lstMats = [Select Id, Territory__c from Material__c where Id IN : setMatIDs];
        for (Material__c mt : lstMats) {
            matTerrMap.put(mt.Id, mt.Territory__c);
        }
        for (Bom_Item__c bom : Trigger.new) {
            bom.Territory__c = matTerrMap.get(bom.Material__c);
        }
    }
    //USST-2749 -- end
}