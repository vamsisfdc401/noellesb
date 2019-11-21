/*****************************************************************************************
    Class Name: DeleteMaterial 
    Purpose: Apex class for deleting BOM ,Release material and vmaterial 
    ******************************************************************************************
    Version         DateModified         ModifiedBy               Change
    1.0                                                 Initial Development
    1.1              11/23/2017           Dinakar       USST-2471
    ******************************************************************************************/



    global without sharing class DeleteMaterial{
        

        public static Map<String,Id>materialUpdateMap=new Map<String,Id>();
        public static Set<Id>materialIdSetExisting=new Set<Id>();
        Id recId ;
        public static void deleteVMaterial(List<v_Material__c> deleteVMat){
            if(!deleteVMat.isEmpty()){
                delete deleteVMat;
            }
        }
        public DeleteMaterial (){
            recId = ApexPages.currentPage().getParameters().get('id');
            system.debug('recI '+recId);
        }
        
        /************************************
        Method Name: deleteMaterial
        Purpose: below method handles to delete BOM ,Release material and vmaterial records basedon material id passed as parameter
        *************************************/
        
        webservice static void deleteMaterial(Id matId){
            List<Material__c>deleteMaterial=[select id from Material__c where id =:matId and (material_status__c='Draft' or material_status__c='Submitted' or material_status__c='Sent Back')];//Added 'Sent Back' status for USST-2383
            List<Material__c> delChildMat = new List<Material__c>();
            System.debug('##deleteMaterial'+deleteMaterial);
            List<Bom_item__c>deleteBomitemList_parent=[Select id, material_Component__c from bom_item__c where material__c=:matId];  
            List<Release_Material__c>deleteReleaseMat_orphanComponents = new List<Release_Material__c>();
            if(deleteBomitemList_parent.size() > 0 && deleteBomitemList_parent[0].material_Component__c != null){
                delChildMat = new List<Material__c>([Select Id, Release__c, Item_Type__c from Material__c where Id =: deleteBomitemList_parent[0].material_Component__c LIMIT 1]);
            }
            for (Bom_item__c bom : deleteBomitemList_parent) {
                
                if (delChildMat.size() > 0 && delChildMat[0].Item_Type__c == 'C - Components' && delChildMat[0].Release__c != null) {
                    Release_Material__c delChildRelMat = [Select Id from Release_Material__c where Release__c =: delChildMat[0].Release__c and Material__c =: delChildMat[0].Id LIMIT 1];
                    deleteReleaseMat_orphanComponents.add(delChildRelMat);
                }
            }
            List<Bom_item__c>deleteBomitemList_child=[Select id from bom_item__c where material_Component__c=:matId]; 
            List<Release_Material__c> deleteReleaseMat=[Select id from Release_Material__c where Material__c=:matId];
            List<v_Material__c>deleteVMaterial=[Select id from v_Material__c where Material__c=:matId] ; 
                
            try{
                if(!deleteMaterial.isEmpty()){
                    if(!deleteBomitemList_parent.isEmpty()){
                        delete deleteBomitemList_parent;
                    }
                    if(!deleteBomitemList_child.isEmpty()){
                        delete deleteBomitemList_child;
                    }
                    if(!deleteReleaseMat.isEmpty()){
                        delete deleteReleaseMat;
                    }
                    if(!deleteReleaseMat_orphanComponents.isEmpty()){
                        delete deleteReleaseMat_orphanComponents;
                    }
                    if(!deleteVMaterial.isEmpty()){
                        delete deleteVMaterial;
                    }
                     delete deleteMaterial;
                }
            } 
            catch(Exception e){
                System.debug('!!!!!DML EXCEPTION'+e);
            }    
        }
        /******************************************
        Method Name: materialDeleteionRequest
        Purpose: Below method handles the material 
                    partial deletion process.
        *******************************************/

            public Pagereference materialDeleteionRequest(){
                List<Material__c> lstExistingMaterial = new List<Material__c>();
                List<Material__c> lstExistingMaterialClone = new List<Material__c>();
                Map<ID,Material__c> mapMatDetails = new Map<ID,Material__c>(); 
                Set<Id> setMaterialID = new Set<Id>();
                TriggerUtility.checkFromUpdateMaterial = TRUE;
                system.debug('recId=== '+recId);
                Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
                String strMaterial = getCreatableFieldsSOQL('Material__c','Id = : recId');
                Id matId = ApexPages.currentPage().getParameters().get('id');
                system.debug('matId==== '+matId);
                List<Release_Material__c> deleteReleaseMat=[Select id from Release_Material__c where Material__c=:matId];
                system.debug('deleteReleaseMat==== '+deleteReleaseMat);
                List<v_Material__c> vMatList = [Select id,status__c,Material__c from v_Material__c where Material__c =: matId];
                String matName; //USST-2471
                String deleteRequestName; //USST-2471
                
                
                system.debug('strMaterial=== '+strMaterial);
                 // Querying material record.
                if(strMaterial!=null && strMaterial!=''){
                    lstExistingMaterial  = Database.Query(strMaterial);
                    system.debug('lstExistingMaterial === '+lstExistingMaterial );
                }
                
                 for(Material__c mat : lstExistingMaterial){
                     system.debug('inside for');
                    if(mat.material_status__c=='Processed in SAP' || mat.material_status__c=='Approved') {
                        matName = mat.Name; //USST-2471
                        materialIdSetExisting.add(mat.id);
                        Material__c matCopy = mat.clone(false,true);
                        //matCopy.Name = mat.Name; // commented for USST-2471
                        matCopy.Material_Status__c = 'Draft';
                        matCopy.BOM_Status__C = 'Draft';
                        matCopy.Brand_Group__c = '';
                        matCopy.RecordTypeId = recTypeId;
                        matCopy.Original_Material_Number__c = mat.id;
                        matCopy.Material_Number__c = mat.Material_Number__c;
                        matCopy.BOM_Integration_State__c = '';
                        matCopy.BOM_Function__c = '';
                        matCopy.Function__c = '009';
                        matCopy.Material_Integration_State__c = '';
                        matCopy.OwnerId =userinfo.getUserId();
                        //matCopy.Deletion_Flag__c = true;
                        matCopy.Material_Description_Unique__c = ''; 
                        //matCopy.Original_Release_Date__c=mat.Original_Release_Date__c; 
                        matCopy.Deletion_Update_Request__c = true; //USST-2856 
                        
                        //USST-2471---start
                        if ((vMatList.size() > 0 && vMatList[0].status__c != 'Active') || vMatList.isEmpty()) {
                            if (matName.length() >= 37) {
                                deleteRequestName = matName.substring(0,36) + ' DNU';
                            }
                            else {
                                deleteRequestName = matName + ' DNU';
                            }
                            matCopy.Name = deleteRequestName;
                        }
                        //USST-2471---end
                        
                        lstExistingMaterialClone.add(matCopy); 
                    }
                    mapMatDetails.put(mat.id,mat);
                 }
                 
                 if(lstExistingMaterialClone.size() > 0){
                     insert lstExistingMaterialClone; 
                     system.debug('lstExistingMaterialClone=== '+lstExistingMaterialClone);
                     
                 }
                system.debug('lstExistingMaterialClone=== '+lstExistingMaterialClone);
                for(Material__c m: lstExistingMaterialClone){
                    materialUpdateMap.put(m.Original_Material_Number__c,m.id);
                    system.debug('inside for');
                    FeedItem post = new FeedItem();
                    post.ParentId = m.Original_Material_Number__c;
                    if(vMatList.size() > 0 && (vMatList[0].status__c == 'Active' || vMatList[0].status__c == 'Pending')){
                        post.Body = 'This material has been requested for partial deactivation.'; // And i was... super simple :D
                    }
                    else{
                        post.Body = 'This material has been requested for deactivation.'; // And i was... super simple :D
                    }
                     
                    insert post;
                    
                    FeedItem post1 = new FeedItem();
                    post1.ParentId = m.id;
                    if(vMatList.size() > 0 && (vMatList[0].status__c == 'Active' || vMatList[0].status__c == 'Pending')){
                        post1.Body = 'This material has been requested for partial deactivation.'; // And i was... super simple :D
                    }
                    else{
                        post1.Body = 'This material has been requested for deactivation.'; // And i was... super simple :D
                    } 
                    insert post1;
                } 
                
                createSalesClone();
                createValuationClone();
                createAltUnitMeasClone();
                createClassificationClone();
                createPlantClone();
                List<Material__c> mattList = new List<Material__c>();
                for(Material__c mt: lstExistingMaterialClone){
                    Material__c matt = new Material__c();
                    matt.id = mt.id;
                    if(vMatList.size() > 0 && (vMatList[0].status__c == 'Active' || vMatList[0].status__c == 'Pending')){
                        matt.Partial_Deletion_Request__c = true;
                    }
                    else{
                        matt.deletion_flag__c = true;
                    }
                    mattList.add(matt);
                }
                 if(!deleteReleaseMat.isEmpty()){
                    delete deleteReleaseMat;
                }
                if(!mapMatDetails.isEmpty()){
                    vProjectUtility.removeVMaterial(mapMatDetails.values(), null);
                }
                update mattList;
               
                for(Material__c m : mattList){
                    setMaterialID.add(m.id);
                }
                FutureMaterial.unlockMaterial(setMaterialID);
                Pagereference targetClonePg;
                if(lstExistingMaterialClone.size() > 0){
                    targetClonePg = new pageReference('/'+lstExistingMaterialClone[0].Id);
                    targetClonePg.setRedirect(true);
                    return targetClonePg;
                }
                else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Material Deletion can be requested only after Material is processed in SAP.');
                    ApexPages.addMessage(myMsg);
                }
                return null;
                      
           }
           
           public static string getCreatableFieldsSOQL(String objectName, String whereClause){
            
            String selects = '';
            
            if (whereClause == null || whereClause == ''){ return null; }
            
            // Get a map of field name and field token
            Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();      
            list<string> selectFields = new list<string>();
            
            if (fMap != null){
                for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                    Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    if (fd.isAccessible()){ // field is creatable
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
            
            // Returing final built query.
            return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;        
        }   
        
        public static void createSalesClone(){
            System.debug('##createSalesClone '+getFieldsSOQL('Sales__c'));
            system.debug('materialIdSetExisting==== '+materialIdSetExisting);
            String qry='Select '+ getFieldsSOQL('Sales__c')+' from Sales__c where material__c in:materialIdSetExisting';
            system.debug('qry==== '+qry);
            List<Sales__c>insertableSales=new List<Sales__c>();
            List<v_Material__c> vMatList = [Select id,status__c,Material__c from v_Material__c where Material__c IN: materialIdSetExisting LIMIT 1];
            for(Sales__c sales:Database.query(qry)){
                system.debug('materialUpdateMap=== '+materialUpdateMap);
                if(materialUpdateMap.containsKey(sales.material__c)){
                    Sales__c salesClone=sales.clone(false,false,false,false);
                    System.debug('##createSalesClone'+sales.material__c);
                    salesClone.material__c=materialUpdateMap.get(sales.material__c);
                     if(vMatList.size() > 0 && vMatList[0].status__c == 'Inactive'){
                         system.debug('inside if');
                        salesClone.Function__c = '003';
                        salesClone.Deletion_Flag__c = true;
                        salesClone.D_Chain_Spec__c = 'XX - Never Released'; //USST-2471
                        //salesClone.D_Chain_Spec__c = materialUpdateMap.get(sales).D_Chain_Spec__c;
                    }
                    else if(vMatList.size() == 0){
                         system.debug('inside else if');
                        salesClone.Function__c = '003';
                        salesClone.Deletion_Flag__c = true;
                        salesClone.D_Chain_Spec__c = 'XX - Never Released'; //USST-2471
                        //salesClone.D_Chain_Spec__c = materialUpdateMap.get(sales.D_Chain_Spec__c);
                    }
                    else{
                         system.debug('inside else');
                        salesClone.Function__c = '004';
                        salesClone.D_Chain_Spec__c = 'XX - Never Released';
                    }
                    salesClone.Execute_Validation__c = false;
                    insertableSales.add(salesClone);
                }
            }
            
            if(!insertableSales.isEmpty()){
                TriggerUtility.donotExecute =true;
                 database.insert(insertableSales,true);
                 TriggerUtility.donotExecute =false;
            }
        }
        
        //to create clone of plant record
        public static void createPlantClone(){
            //System.debug('##createPlantClone');
            Set<String> validPlants = new Set<String>{'V000 - Univ Studios HV Planning Plant', 'V300 - Technicolor - TN', 'V400 - Technicolor', 'V500 - Technicolor', 'V750 - TECHNICOLOR HES', 'V850 - Technicolor Canada'}; //USST-2738 //USST-2793
            String qry='Select '+ getFieldsSOQL('Plant__c')+' from Plant__c where material__c in:materialIdSetExisting and Plant__c in: validPlants'; //USST-2738
            List<v_Material__c> vMatList = [Select id,status__c,Material__c from v_Material__c where Material__c IN : materialIdSetExisting LIMIT 1];
            List<Plant__c>insertablePlant=new List<Plant__c>();
            for(Plant__c plant:Database.query(qry)){
                if (validPlants.contains(String.valueOf(plant.Plant__c))) { //USST-2793
                    if(materialUpdateMap.containsKey(plant.material__c)){
                        Plant__c plantClone=plant.clone(false,false,false,false);
                        plantClone.material__c=materialUpdateMap.get(plant.material__c);
                        if(vMatList.size() > 0 && vMatList[0].status__c == 'Inactive'){
                            plantClone.Function__c = '003';
                            plantClone.Deletion_Flag__c = true;
                            plantClone.Plant_Specific_Matl_Status__c = 'XX - Never Released'; //USST-2471
                        }
                        //USST-2471----start
                        else if(vMatList.size() == 0){
                             system.debug('inside else if');
                            plantClone.Function__c = '003';
                            plantClone.Deletion_Flag__c = true;
                            plantClone.Plant_Specific_Matl_Status__c = 'XX - Never Released';
                        }
                        //USST-2471----end
                        plantClone.Execute_Validation__c = false;
                        insertablePlant.add(plantClone);
                    }
                    validPlants.remove(String.valueOf(plant.Plant__c)); //To prevent cloning multiple times if duplicates exist //USST-2793
                }
            }
            
            if(!insertablePlant.isEmpty()){
                database.insert(insertablePlant,false);
            }
        }
        
        //to create clone of classification record
        public static void createClassificationClone(){
            //System.debug('##createClassificationClone');
            String qry='Select '+ getFieldsSOQL('Classification__c')+' from Classification__c where material__c in:materialIdSetExisting';
            List<v_Material__c> vMatList = [Select id,status__c,Material__c from v_Material__c where Material__c IN : materialIdSetExisting LIMIT 1];
            List<Classification__c >insertableClassification=new List<Classification__c>();
            for(Classification__c cls:Database.query(qry)){
                if(materialUpdateMap.containsKey(cls.material__c)){
                    Classification__c clsClone=cls.clone(false,false,false,false);
                    clsClone.material__c=materialUpdateMap.get(cls.material__c);
                    if(vMatList.size() > 0 && vMatList[0].status__c == 'Inactive'){
                        clsClone.Function__c = '003';
                        clsClone.Deletion_Flag__c = true;
                    }
                    clsClone.Execute_Validation__c = false;
                    insertableClassification.add(clsClone);
                }
            }
            
            if(!insertableClassification.isEmpty()){
                database.insert(insertableClassification,false);
            }
        }
        
        //to create clone of alternate unit of measure
        public static void createAltUnitMeasClone(){
            //System.debug('##createAltUnitMeasClone');
            /*String qryFields = getFieldsSOQL('Alternative_Unit_of_Measure__c');
            if(qryFields == null || qryFields == ''){
                qryFields = 'id';
            }*/
            String qry='Select '+getFieldsSOQL('Alternative_Unit_of_Measure__c')+' from Alternative_Unit_of_Measure__c where material__c in:materialIdSetExisting';
            List<v_Material__c> vMatList = [Select id,status__c,Material__c from v_Material__c where Material__c IN : materialIdSetExisting LIMIT 1];
            List<Alternative_Unit_of_Measure__c>insertableAUoMs=new List<Alternative_Unit_of_Measure__c>();
            for(Alternative_Unit_of_Measure__c auom : Database.query(qry)){
                if(materialUpdateMap.containsKey(auom.material__c)){
                    Alternative_Unit_of_Measure__c auomClone=auom.clone(false,false,false,false);
                    auomClone.material__c=materialUpdateMap.get(auom.material__c);
                    if(vMatList.size() > 0 && vMatList[0].status__c == 'Inactive'){
                        auomClone.Function__c = '003';
                        auomClone.Deletion_Flag__c = true;
                    }
                    auomClone.Execute_Validation__c = false;
                    insertableAUoMs.add(auomClone);
                }
            }
            
            if(!insertableAUoMs.isEmpty()){
                database.insert(insertableAUoMs,false);
            }
        }
        
        //to create clone of valuation record
        public static void createValuationClone(){
            //System.debug('##createValuationClone');
            Set<String> validValuations = new Set<String> {'V000', 'V300', 'V400', 'V500', 'V750', 'V850'}; //USST-2738 //USST-2793
            String qry='Select '+ getFieldsSOQL('Valuation__c')+' from Valuation__c where material__c in:materialIdSetExisting and Valuation_Area__c in: validValuations'; //USST-2738
            List<v_Material__c> vMatList = [Select id,status__c,Material__c from v_Material__c where Material__c IN : materialIdSetExisting LIMIT 1];
            List<Valuation__c>insertableVals=new List<Valuation__c>();
            for(Valuation__c val:Database.query(qry)){
                if (validValuations.contains(String.valueOf(val.Valuation_Area__c))) { //USST-2793
                    if(materialUpdateMap.containsKey(val.material__c)){
                        Valuation__c valClone=val.clone(false,false,false,false);
                        valClone.material__c=materialUpdateMap.get(val.material__c);
                        if(vMatList.size() > 0 && vMatList[0].status__c == 'Inactive'){
                            valClone.Function__c = '003';
                            valClone.Deletion_Flag__c = true;
                        }
                        valClone.Execute_Validation__c = false;
                        insertableVals.add(valClone);
                    }
                    validValuations.remove(String.valueOf(val.Valuation_Area__c)); //To prevent cloning multiple times if duplicates exist //USST-2793
                }
            }
            
            if(!insertableVals.isEmpty()){
                database.insert(insertableVals,false);
            }
        }
        
        //to get all creatable fields
        public static string getFieldsSOQL(String objectName){
            
            String selects = '';
            
            //if (whereClause == null || whereClause == ''){ return null; }
            
            // Get a map of field name and field token
            Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();      
            list<string> selectFields = new list<string>();
            
            if (fMap != null){
                for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                    Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                    if (fd.isAccessible() && fd.getName() != 'Material_Description_Unique__c' && fd.getName() != 'Id' && fd.getName()!='OwnerId'){ // field is creatable
                        selectFields.add(fd.getName());
                    }
                }
                
            }
            
            if (!selectFields.isEmpty()){
                for (string s:selectFields){
                    selects += s + ',';
                    System.Debug('@@Field@@ '+s);
                }
                if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}            
            }
            
            System.Debug('SOQL Qry @@ '+selects);
            if(selects == null || selects == ''){
                selects = 'id';
            }

            return selects;        
        } 
        
        /******************************************
        Method Name: activateMaterialRequest
        Purpose: Below method handles the material 
                   reactivation process.
        *******************************************/
        public pagereference activateMaterialRequest(){
        List<Material__c> lstExistingMaterial = new List<Material__c>();
        List<Material__c> lstExistingMaterialClone = new List<Material__c>();
        String strMaterial = getCreatableFieldsSOQL('Material__c','Id = : recId');
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        Set<Id> setMaterialID = new Set<Id>();
        TriggerUtility.checkFromUpdateMaterial = TRUE;
        system.debug('strMaterial=== '+strMaterial);
             // Querying material record.
            if(strMaterial!=null && strMaterial!=''){
                lstExistingMaterial  = Database.Query(strMaterial);
                system.debug('lstExistingMaterial === '+lstExistingMaterial );
            }
            for(Material__c mat : lstExistingMaterial){
                if(mat.material_status__c=='Deleted') {
                    materialIdSetExisting.add(mat.id);
                    Material__c matCopy = mat.clone(false,true);
                    matCopy.Name = mat.Name;
                    matCopy.Material_Status__c = 'Draft';
                    matCopy.BOM_Status__C = 'Draft';
                    matCopy.Brand_Group__c = '';
                    matCopy.RecordTypeId = recTypeId;
                    matCopy.Original_Material_Number__c = mat.id;
                    matCopy.Material_Number__c = mat.Material_Number__c;
                    matCopy.BOM_Integration_State__c = '';
                    matCopy.BOM_Function__c = '';
                    matCopy.Function__c = '009';
                    matCopy.Material_Integration_State__c = '';
                    matCopy.OwnerId =userinfo.getUserId();
                    matCopy.Deletion_Flag__c = false;
                    matCopy.Material_Description_Unique__c = '';
                    matCopy.Request_For_Reactivation__c = true;   
                    matCopy.Execute_Validation_Rule__c = false;
                    lstExistingMaterialClone.add(matCopy); 
                }
                //mapMatDetails.put(mat.id,mat);
            }
            if(lstExistingMaterialClone.size() > 0){
                insert lstExistingMaterialClone; 
                system.debug('lstExistingMaterialClone=== '+lstExistingMaterialClone);
                 
            }
            for(Material__c m: lstExistingMaterialClone){
                materialUpdateMap.put(m.Original_Material_Number__c,m.id);
                FeedItem post = new FeedItem();
                post.ParentId = m.Original_Material_Number__c;
                post.Body = 'This material has been requested for reactivation.'; // And i was... super simple :D
                 
                insert post;
            }
            
            createReactivateSalesClone();
            createReactivateValuationClone();
            createReactivateAltUnitMeasClone();
            createReactivateClassificationClone();
            createReactivatePlantClone();
            List<Material__c> mattList = new List<Material__c>();
            for(Material__c mt: lstExistingMaterialClone){
                Material__c matt = new Material__c();
                matt.id = mt.id;
                mattList.add(matt);
            }
            for(Material__c m : mattList){
                setMaterialID.add(m.id);
            }
            FutureMaterial.unlockMaterial(setMaterialID);
            Pagereference targetClonePg = new pageReference('/'+lstExistingMaterialClone[0].Id);
            targetClonePg.setRedirect(true);
            return targetClonePg;
    }

        public static void createReactivateSalesClone(){
            System.debug('##createSalesClone '+getFieldsSOQL('Sales__c'));
            system.debug('materialIdSetExisting==== '+materialIdSetExisting);
            String qry='Select '+ getFieldsSOQL('Sales__c')+' from Sales__c where material__c in:materialIdSetExisting';
            system.debug('qry==== '+qry);
            List<Sales__c>insertableSales=new List<Sales__c>();
            for(Sales__c sales:Database.query(qry)){
                system.debug('materialUpdateMap=== '+materialUpdateMap);
                if(materialUpdateMap.containsKey(sales.material__c)){
                    Sales__c salesClone=sales.clone(false,false,false,false);
                    System.debug('##createSalesClone'+sales.material__c);
                    salesClone.material__c=materialUpdateMap.get(sales.material__c);
                    System.debug('##createSalesClone_Material'+materialUpdateMap.get(sales.material__c));
                    salesClone.Function__c = '004';
                    salesClone.Deletion_Flag__c = false;
                    salesClone.D_Chain_Spec__c = 'FR - Future Release';
                    salesClone.Execute_Validation__c = false;
                    insertableSales.add(salesClone);
                }
            }
            
            if(!insertableSales.isEmpty()){
                TriggerUtility.donotExecute =true;
                 database.insert(insertableSales,true);
                 TriggerUtility.donotExecute =false;
            }
        }
        
        //to create clone of plant record
        public static void createReactivatePlantClone(){
            //System.debug('##createPlantClone');
            Set<String> validPlants = new Set<String>{'V000 - Univ Studios HV Planning Plant', 'V300 - Technicolor - TN', 'V400 - Technicolor', 'V500 - Technicolor', 'V750 - TECHNICOLOR HES', 'V850 - Technicolor Canada'}; //USST-2738 //USST-2793
            String qry='Select '+ getFieldsSOQL('Plant__c')+' from Plant__c where material__c in:materialIdSetExisting and Plant__c in: validPlants'; //USST-2738
            
            List<Plant__c>insertablePlant=new List<Plant__c>();
            for(Plant__c plant:Database.query(qry)){
                if (validPlants.contains(String.valueOf(plant.Plant__c))) { //USST-2793
                    if(materialUpdateMap.containsKey(plant.material__c)){
                        Plant__c plantClone=plant.clone(false,false,false,false);
                        plantClone.material__c=materialUpdateMap.get(plant.material__c);
                        //plantClone.Function__c = '003';
                        plantClone.Deletion_Flag__c = false;
                        plantClone.Execute_Validation__c = false;
                        insertablePlant.add(plantClone);
                    }
                    validPlants.remove(String.valueOf(plant.Plant__c)); //To prevent cloning multiple times if duplicates exist //USST-2793
                }
            }
            
            if(!insertablePlant.isEmpty()){
                database.insert(insertablePlant,false);
            }
        }
        
        //to create clone of classification record
        public static void createReactivateClassificationClone(){
            //System.debug('##createClassificationClone');
            String qry='Select '+ getFieldsSOQL('Classification__c')+' from Classification__c where material__c in:materialIdSetExisting';
            
            List<Classification__c >insertableClassification=new List<Classification__c>();
            for(Classification__c cls:Database.query(qry)){
                if(materialUpdateMap.containsKey(cls.material__c)){
                    Classification__c clsClone=cls.clone(false,false,false,false);
                    clsClone.material__c=materialUpdateMap.get(cls.material__c);
                    //clsClone.Function__c = '003';
                    clsClone.Deletion_Flag__c = false;
                    clsClone.Execute_Validation__c = false;
                    insertableClassification.add(clsClone);
                }
            }
            
            if(!insertableClassification.isEmpty()){
                database.insert(insertableClassification,false);
            }
        }
        
        //to create clone of alternate unit of measure
        public static void createReactivateAltUnitMeasClone(){
            String qry='Select '+getFieldsSOQL('Alternative_Unit_of_Measure__c')+' from Alternative_Unit_of_Measure__c where material__c in:materialIdSetExisting';

            List<Alternative_Unit_of_Measure__c>insertableAUoMs=new List<Alternative_Unit_of_Measure__c>();
            for(Alternative_Unit_of_Measure__c auom : Database.query(qry)){
                if(materialUpdateMap.containsKey(auom.material__c)){
                    Alternative_Unit_of_Measure__c auomClone=auom.clone(false,false,false,false);
                    auomClone.material__c=materialUpdateMap.get(auom.material__c);
                    //auomClone.Function__c = '003';
                    auomClone.Deletion_Flag__c = false;
                    auomClone.Execute_Validation__c = false;
                    insertableAUoMs.add(auomClone);
                }
            }
            
            if(!insertableAUoMs.isEmpty()){
                database.insert(insertableAUoMs,false);
            }
        }
        
        //to create clone of valuation record
        public static void createReactivateValuationClone(){
            //System.debug('##createValuationClone');
            Set<String> validValuations = new Set<String> {'V000', 'V300', 'V400', 'V500', 'V750', 'V850'}; //USST-2738 //USST-2793
            String qry='Select '+ getFieldsSOQL('Valuation__c')+' from Valuation__c where material__c in:materialIdSetExisting and Valuation_Area__c in:validValuations'; //USST-2738
            
            List<Valuation__c>insertableVals=new List<Valuation__c>();
            for(Valuation__c val:Database.query(qry)){
                if (validValuations.contains(String.valueOf(val.Valuation_Area__c))) { //USST-2793
                    if(materialUpdateMap.containsKey(val.material__c)){
                        Valuation__c valClone=val.clone(false,false,false,false);
                        valClone.material__c=materialUpdateMap.get(val.material__c);
                        //valClone.Function__c = '003';
                        valClone.Deletion_Flag__c = false;
                        valClone.Execute_Validation__c = false;
                        insertableVals.add(valClone);
                    }
                    validValuations.remove(String.valueOf(val.Valuation_Area__c)); //To prevent cloning multiple times if duplicates exist //USST-2793
                }
            }
            
            if(!insertableVals.isEmpty()){
                database.insert(insertableVals,false);
            }
        } 
    }