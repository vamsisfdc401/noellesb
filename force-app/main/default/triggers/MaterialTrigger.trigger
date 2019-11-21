/*****************************************************************************************
TriggerName: MaterialTrigger 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             19/07/2016                                    Initial Development
******************************************************************************************/
trigger MaterialTrigger on Material__c (before insert, after insert, before update, after update, before delete,after delete) {
     if(Trigger_inactive__c.getInstance('MaterialTrigger') != null && !Trigger_inactive__c.getInstance('MaterialTrigger').Active__c)
        return;
    system.debug('trigger active');
    Set<Id> setParentid = new Set<Id>();
    Set<Id> setReleaseId = new Set<Id>();
    List<Release_Material__c> lstReleaseMaterial = new List<Release_Material__c>();
    List<BOM_Item__c> lstBom = new List<BOM_Item__c>();
    //Boolean updatesFromTibco = false; //USST-2766
    
    Boolean hasnonfutureRelease = false; //USST-2248
    Id matRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId(); //USST-2248
    
    if(TriggerUtility.materialTriggerExecuted() && !TriggerUtility.initiatedFromMaterial && !TriggerUtility.CheckFromTemplate)
    {
        //Variable for storing profile details
        String profileName;
        
        //Getting profile name from trigger utility
        IF (TriggerUtility.currentUser != null){
            profileName = TriggerUtility.currentUser.Profile.Name;
        }

        //Context variable for before scenario  
        if(Trigger.isBefore){
            if(Trigger.isUpdate){
               
                if(!TriggerUtility.checkFromCloning)
                {
                    MaterialTriggerHelper.checkDuplicateMaterialUPC();    
                    MaterialTriggerHandler.updateBomStatus();    
                    // Calling method to update Material status and Integration State.
                    MaterialTriggerHandler.updateStatusOnIntegrationState();
                }
                //==========================================================================
                //Below logic only for API user
                if(profileName == 'Platform API'){
                  for(Material__c each: trigger.new){
                     if(each.Material_Integration_State__c=='P') //&& TriggerUtility.checkMatGrpUpdate)//Added Filter for RE-14
                         each.Function__c='023';
                     if(each.BOM_Integration_State__c=='P')    
                         each.BOM_Function__c='023';
                     
                     //Added the code as part of DF-1631    
                     if(each.material_status__c=='Processed in SAP' && each.Item_Type__c=='D (Display Vehicle)' 
                         && each.material_number__c!='' && each.material_number__c!=null && each.Item_Code__c == 'FT - PHANTOM TRAY'
                         && (each.BOM_status__c=='Draft' || each.BOM_status__c=='Sent Back'||each.BOM_status__c=='In Progress')){
                              each.BOM_status__c='Approved';
                              each.BOM_Integration_State__c ='N';
                     }   
                     //USST-2766 - External ID setup for TIBCO ---start
                     /*if (each.TM_Version_Id_Tibco__c != Trigger.oldMap.get(each.Id).TM_Version_Id_Tibco__c ||
                         each.Sub_Label_Code_Id_Tibco__c != Trigger.oldMap.get(each.Id).Sub_Label_Code_Id_Tibco__c ||
                         each.Material_Number_Tibco__c != Trigger.oldMap.get(each.Id).Material_Number_Tibco__c ||
                         each.Alternative_Legal_Title_Id_Tibco__c != Trigger.oldMap.get(each.Id).Alternative_Legal_Title_Id_Tibco__c ||
                         (each.SGENNO_Title_Tibco__c != Trigger.oldMap.get(each.Id).SGENNO_Title_Tibco__c && each.SGENNO_Title_Tibco__c != null && each.SGENNO_Title_Tibco__c != '') ||
                         (each.SGENNO_Deal_Tibco__c != Trigger.oldMap.get(each.Id).SGENNO_Deal_Tibco__c && each.SGENNO_Deal_Tibco__c != null && each.SGENNO_Deal_Tibco__c != '' && each.Deal_Id_Tibco__c != Trigger.oldMap.get(each.Id).Deal_Id_Tibco__c && each.Deal_Id_Tibco__c != null && each.Deal_Id_Tibco__c != ''))  
                     {
                         updatesFromTibco = true;
                     }*/
                     //USST-2766 - External ID setup for TIBCO --- end
                  }
                  MaterialTriggerHandler.populateBOMHeaderInSAPMaterial();
                  MaterialTriggerHandler.transferOwner(Trigger.New);
                  //MaterialTriggerHandler.updateDeleteOriginalMaterial(); //USST-3225
                  //USST-2766 - External ID setup for TIBCO ---start
                  /*if (updatesFromTibco) {
                     MaterialTriggerHandler.handleTibcoUpdateFields();                  
                  }*/
                  //USST-2766 - External ID setup for TIBCO --- end
                    
                }
                //==========================================================================
                
                if(profileName != 'Platform API')
                {
                    //if(Label.Disable_Material_Future_Trigger != 'Yes')
                        MaterialTriggerHandler.executeOnBeforeUpdate(); 
                }                       
            }
            
            else if(Trigger.isInsert){
                MaterialTriggerHelper.checkDuplicateMaterialUPC();
                if(profileName != 'Platform API')
                {
                    MaterialTriggerHandler.executeOnBeforeInsert();
                } 
                else{                    
                    MaterialTriggerHandler.updatestatusFromSAP(Trigger.New);
                    MaterialTriggerHandler.populateBOMHeaderInSAPMaterial();  
                    
                    //for ZDLT material territory should be defaulted to US & CDN
                    for(Material__c mat : (List<Material__c>)Trigger.New){
                        mat.Defaults_Processing__c = FALSE;
                        if(mat.Material_Type__c == 'ZDLT'){
                            mat.Territory__c = 'US & CDN';
                        }
                        if(mat.Format__c != null && mat.Format_Description__c == null && FormatCode_Format_Mapping__c.getInstance(mat.Format__c) != null)
                        {
                            if(mat.Technical_Format__c != null && mat.Technical_Format__c == '09 - VARIOUS 3D')
                            {
                                if(mat.Format__c == '02 - DVD')
                                    mat.Format_Description__c = '3D DVD';
                                else if(mat.Format__c == '09 - BLU-RAY')
                                    mat.Format_Description__c = '3D BD';
                                else if(mat.Format__c == '11 - ULTRA HD 4K')
                                    mat.Format_Description__c = '3D UHD';
                                else
                                    mat.Format_Description__c = FormatCode_Format_Mapping__c.getInstance(mat.Format__c).Wizard_Format__c;
                            }
                            else
                                mat.Format_Description__c = FormatCode_Format_Mapping__c.getInstance(mat.Format__c).Wizard_Format__c;
                        }
                    }
                }          
            } 
            //added for RE-35  
            else if(Trigger.isDelete)
            {
                MaterialTriggerHandler.executeOnBeforeDelete();
            }   
        }  
        //context variable check for after scenario
        else if(Trigger.isAfter){
            TriggerUtility.initiatedFromMaterial = TRUE;
            if(!Trigger.isDelete){
            // For BOM Long Text parsing
                BOMLongTextHandler.manageBOMLongText();  
            }
            
            if(Trigger.isUpdate){   
                //Added for RE-111
                set<Id> idSet = new set<Id>();
                for(Material__c mat : trigger.new){
                    idSet.add(mat.id);
                }             
                // For V-Project Functionality.
                //MaterialTrigger_Refactor.addOrRemoveVMaterialAIAU();
                if(TriggerUtility.currentUser.Name == 'API User')
                {
                   MaterialTriggerHandler.updateDeleteOriginalMaterial(); //USST-3225
                   MaterialTriggerHandler.afterUpdateAddVMaterial(); 
                   MaterialTriggerHandler.updateOriginalMaterial(Trigger.new);
                   MaterialTriggerHandler.updatePreOrderDatefromMaterial1(Trigger.new);
                   MaterialTriggerHandler.deleteReleaseMaterial(idSet);
                   
                }
                if(TriggerUtility.currentUser.Name!='API User')//if(profileName != 'Platform API')
                {
                    //chatterOnDateUpdate.chatterOnMaterialDateUpdate(trigger.new);
                    MaterialTriggerHandler.executeOnAfterUpdate();
                    
                }
                else
                {
                    // It cancels associated Update materials if certain condition is met.
                    MaterialTriggerHandler.cancelUpdateMaterials1();
                    
                    // Update child component with parent material number.
                    MaterialTriggerHandler.updateComponentStatus(Trigger.New);
                    //Update BomItem with Material Number of Child
                    MaterialTriggerHandler.updateBomItemMaterialNumberReference(Trigger.New);
                    
                    //MaterialTriggerHandler.updateBOMFunction();
                    MaterialTriggerHandler.updateBOMStatusJointCorrugate1();
                    //MaterialTriggerHandler.callOnDelete(Trigger.new);
                }
                
                if(!TriggerUtility.checkFromCloning)
                {
                    //MaterialTriggerHandler.updateOriginalMaterial(Trigger.new);
                    //MaterialTriggerHandler.updatePreOrderDatefromMaterial1(Trigger.new);
                    //MaterialTriggerHandler.callOnDelete(Trigger.new);
                }
            }
            
            else if(Trigger.isInsert){
                if(TriggerUtility.currentUser.Name!='API User')//if(profileName != 'Platform API')
                {
                    //TriggerUtility.initiatedFromMaterial = TRUE;
                    MaterialTriggerHandler.executeOnAfterInsert();
                    //MaterialTrigger_Refactor.addOrRemoveVMaterialAIAU();
                }                
            }            
            else if(Trigger.isDelete){
                if(profileName != 'Platform API')
                {    
                    MaterialTriggerHandler.executeOnAfterDelete();
                }           
            }     
        }      
    }
    
    if(TriggerUtility.CheckFromTemplate){
        if(Trigger.isBefore && Trigger.isInsert){
            MaterialTriggerHandler.executeOnBeforeInsert();
        }
        
        if(Trigger.isAfter && Trigger.isInsert){
            MaterialTriggerHandler.executeOnAfterInsert();
        }
        //Added for Activity defects on 10th Nov
      String profileName;  
        //Getting profile name from trigger utility
        if (TriggerUtility.currentUser != null){
            profileName = TriggerUtility.currentUser.Profile.Name;
        }
        //Added for Activity defects on 10Nov
        if(Trigger.isAfter && Trigger.isDelete){
                if(profileName != 'Platform API')
                {    
                    MaterialTriggerHandler.executeOnAfterDelete();
                }           
         }
    
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        String profileName;
        
        //Getting profile name from trigger utility
        IF (TriggerUtility.currentUser != null){
            profileName = TriggerUtility.currentUser.Profile.Name;
        }
        
        if(profileName == 'Platform API'){
            MaterialTriggerHandler.updateMatStatusOnActivate(Trigger.new);
            // Adding the below piece of codes for defect 2674
                for(Material__c objMat : Trigger.New){
                    Material__c objoldMat = Trigger.oldMap.get(objMat.ID);
                    if(objoldMat.Deletion_Flag__c==false && objMat.Deletion_Flag__c== true && objMat.Material_Type__c !='FERT' && objMat.Original_Material_Number__c == null ){
                        setParentid.add(objMat.id);
                    }
                }
                lstBom = [select id,Name,Material__c,Material_Component__c from BOM_Item__c where Material_Component__c in : setParentid ];
                if(lstBom.size()>0)
                  Database.delete(lstBom);
        }
    }
    // Adding the below piece of code for 2248
    if(Trigger.isBefore && Trigger.isUpdate){
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        Boolean throwError = false;
        Set<Id> setMaterialId = new Set<Id>();
        //USST-2877 --- start
        String profileName; 
        if (TriggerUtility.currentUser != null){
            profileName = TriggerUtility.currentUser.Profile.Name;
        }   
        //USST-2877 --- end        
        for(Material__c objMaterial : Trigger.new){
            if(objMaterial.recordtypeId == recTypeId && (objMaterial.Street_Date__c != Trigger.oldMap.get(objMaterial.Id).Street_Date__c ||
                objMaterial.Original_Release_Date__c != Trigger.oldMap.get(objMaterial.Id).Original_Release_Date__c || 
                objMaterial.Pre_Order_Close_Date__c != Trigger.oldMap.get(objMaterial.Id).Pre_Order_Close_Date__c) && objMaterial.Material_Type__c =='FERT' && (objMaterial.Format__c !='08 - EST (ELECTRONIC SELL THRU)' && objMaterial.Item_Code__c !='BF - BABY FERT') && profileName != 'System Administrator' && profileName != 'Limited Administrator' && profileName != 'Platform API' && profileName != 'Master Data Admin' && objMaterial.m2m5Update__c != true) //USST-2877 //USST-2859 //USST-3008
            {
                    setMaterialId.add(objMaterial.id);
            }
        }
        if (setMaterialId.size() > 0) { //Added for 101 error 04102018
            for(Sales__c objSales : [Select id,Name,D_Chain_Spec__c from Sales__c where material__c in: setMaterialId]){
                if(objSales.D_Chain_Spec__c != 'FR - Future Release'){
                    throwError = true;
                    break;
                }
            } 
        }
        if(throwError){
            for(Material__c objMaterial2 : Trigger.new){
                objMaterial2.addError('Date changes cannot be made due to Materials being orderable. Please contact Master Data for any questions.');
            }
        }
    }
    // End of 2248  
    
    //USST-2749 -- start
    if (Trigger.isAfter && Trigger.isUpdate) {
        List<Bom_Item__c> lstBoms = new List<Bom_Item__c>();
        Map<ID,String> matTerrMap = new Map<ID,String>();
        List<Bom_Item__c> lstBomsToUpdate = new List<Bom_Item__c>();
        list<Material__c> lstUpdtMats = new list <Material__c> (); //USST-2837
        Map<Material__c,String> updatedMatsMap = new Map<Material__c,String>(); //USST-2837
        Map<String,Material__c> oldMatMap = new Map<String,Material__c>(); //USST-2837
        lstBoms = [Select Id, Territory__c, Material__c from Bom_Item__c where Material__c in : Trigger.newMap.keySet()];
        for (Material__c mt : Trigger.new) {
            matTerrMap.put(mt.Id, mt.Territory__c);
        }
        for (Bom_Item__c bom : lstBoms) {
            bom.Territory__c = matTerrMap.get(bom.Material__c);
            lstBomsToUpdate.add(bom);
        }
        if (lstBomsToUpdate.size() > 0) {
            update lstBomsToUpdate;
        }
        //USST-2837 --- start
        for (Material__c mat : Trigger.new) {
            Material__c oldMat = (Material__c)Trigger.oldMap.get(mat.Id);
             if(TriggerUtility.currentUser.Profile.Name == 'Platform API' && mat.Old_Material_Load__c == mat.Material_Number__c){//USST-3343
            
            
            }Else  {
                if(mat.Old_Material_Load__c != oldMat.Old_Material_Load__c && mat.Old_Material_Load__c!= null)
                updatedMatsMap.put(mat, mat.Old_Material_Load__c);
            }
        }
        if (updatedMatsMap.size() > 0) {
            List<Material__c> oldMats = [Select Material_Number__c, Id from Material__c where Material_Number__c IN: updatedMatsMap.values()];
            if (oldMats.size() > 0) {
                for (Material__c oldMat : oldMats) {
                    oldMatMap.put(oldMat.Material_Number__c, oldMat);
                }
            }
            if (oldMatMap.size() > 0) {
                for (Material__c mat : updatedMatsMap.keySet()) {
                    Material__c m = new Material__c (Id=mat.Id, Old_Material_No__c=oldMatMap.get(mat.Old_Material_Load__c).Id);
                    lstUpdtMats.add(m);
                }
            }
            
            if (lstUpdtMats.size() > 0 && (!TriggerUtility.checkFromCloning) ) {
              try{
               
                  update lstUpdtMats;
                  }catch (DMLException e){
                     for (Material__C materror: Trigger.new) {
                          materror.addError('Please select the Old material SAP from the same territory'); //USST-2768
                     }}
                
            }
        }
        //USST-2837 --- end
        
    }
    //USST-2749 -- end
    
    
}