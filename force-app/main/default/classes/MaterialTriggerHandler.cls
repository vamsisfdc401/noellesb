/*****************************************************************************************
 Class Name: MaterialTriggerHandler
 Purpose: This class handles the business logic for Material Trigger.
 ******************************************************************************************
 Version         DateModified         ModifiedBy               Change
 1.0             20/07/2016           Suman Kundu              Initial Development
 1.1             02/08/2016           Durgesh Choubey          Added method 
                                                               updateMaterialHeepOnParent
                                                               updateChildMaterialStatusAftrApproval 
 2.003           16/02/17             Mohit Goyal/             Code Refactoring
                                      Suman Kundu
 ******************************************************************************************/
 public with sharing class MaterialTriggerHandler {
     
     private static Map<String, Map<Id, SObject>> fetchDataSet = new Map<String, Map<Id, SObject>>();
     private static Map<String, List<SObject>> insertableDataSet = new Map<String, List<SObject>>();
     private static Map<String, Map<Id, SObject>> updateableDataSet = new Map<String, Map<Id, SObject>>();
     private static Map<String, Map<Id, SObject>> deleteableDataSet = new Map<String, Map<Id, SObject>>();    
     
     private static Map<Id, Deal__c> titleDealMap = new Map<Id, Deal__c>();
   private static Map<String, Origin_Code__c> originCodeLblCodeMap = new Map<String, Origin_Code__c>(); // Added REL-147 //USST-2728
     private static Map<String, Origin_Code__c> originCodeSubLblCodeMap = new Map<String, Origin_Code__c>(); //USST-2728
     private static Map<Id, TM_Version__c> titleTMVersionMap = new Map<Id, TM_Version__c>();
     private static Set<ID> setTitleID = new Set<ID>();
     private static Set<ID> setDealID = new Set<ID>();
     private static Set<ID> setReleaseID = new Set<ID>();
     @testVisible private static Set<ID> setMaterialID = new Set<ID>();
     private static Set<string> setOriginCode = new Set<string>();
     private static Set<string> setLabelCode = new Set<string>();
     private static Set<ID> setTMVersionID = new Set<ID>();
     private static Map<String, String> lblCodeSubLblCodeIdMap = new Map<String, String>();
     private static Map<String, Id> subLblCodeMap = new Map<String, Id>();
     private static Id updateRecTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
     private static Id reqRecTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();
     private static Id matRecTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
     private static Id classficationRecordTypeId1 = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
     private static List<TM_Version__c> tmVersionList= new List<TM_Version__c>();
     private static Set<String> statusToCheck = new Set<String>{'Sent to SAP', 'SAP Error', 'Process in SAP'};
     private static Map<Id, TM_Version__c> tmVersionMap = new Map<ID,TM_Version__c>();
     private static Set<Id> material4TerritoryChangeIds = new Set<Id>();
     private static Map<Id, String> materialTerritoryReduceMap = new Map<Id, String>();
     private static Set<Id> deletingMatIds = new Set<Id>();
     private static Set<Id> matIds1 = new Set<Id>();
     private static Map<Id, List<BOM_Item__c>> matBomMap = new Map<Id, List<BOM_Item__c>>();
     private static List<v_Material__c> deletedMatVMatList = new List<v_Material__c>();
     private static Material__c oldMat;
     private static String profileName;
     private static string parentMatid;
     private static set<Id> setparentMatid;
     private static Map<String,List<Deal__c>> dealDefaultMap=new Map<String,List<Deal__c>>();//RE-10
     private static Set<Id> titleIdSet = new Set<Id>();//RE-10
     private static Map<Id, Material__c> childMatLabelChangeMap = new Map<Id, Material__c>();    // Changed for Deal
        
     static{
     
     
     
         if(!insertableDataSet.containsKey('Release_Material__c'))
             insertableDataSet.put('Release_Material__c', new List<SObject>());
     
     
     }
     
     /***********************************
     Method Name: resetDataSet
     Purpose:Followingmethod is used to reset context data variable
     ***********************************/
     private static void resetDataSet()
     {
         fetchDataSet.clear();
         insertableDataSet.clear();
         updateableDataSet.clear();
         deleteableDataSet.clear();
         titleDealMap.clear();
     originCodeLblCodeMap.clear(); // Added REL-147
         originCodeSubLblCodeMap.clear();
         titleTMVersionMap.clear();
         setTitleID.clear();
         setDealID.clear();
         setReleaseID.clear();
         setMaterialID.clear();
         setOriginCode.clear();
         setLabelCode.clear();
         lblCodeSubLblCodeIdMap.clear();
         subLblCodeMap.clear();
         tmVersionList.clear();
     }
     
     /***********************************
     Method Name: getDataSet
     Purpose: method for executing SOQL
     ***********************************/
     @testVisible
     private static void getDataSet()
     {
         //for title details
         if(!setTitleID.isEmpty()){
             if(!fetchDataSet.containsKey('Title__c'))
                 fetchDataSet.put('Title__c',new Map<ID,sObject>());
             
             for(Title__c title : [Select ID, Name, Title_Abbreviation__c, 
                                   (SELECT Id, Name, Deal_ID__c, Label_Code__c, Title__c, Legal_Owner__c, Financial_Owner__c, Origin_Code__c, Title__r.Name     // Changed for Deal
                                    FROM Deals__r where Finance_Default_Deal__c=TRUE) , (SELECT Id, Title__c FROM TM_Versions__r where  Original_Flag__c=TRUE)
                                    FROM Title__c WHERE ID IN :setTitleID ]){
                 fetchDataSet.get('Title__c').put(title.ID, title);  
                 
                 //creating title deal map 
                 if(!titleDealMap.containsKey(title.ID) && !title.Deals__r.isEmpty()){
                     titleDealMap.put(title.ID, title.Deals__r[0]);
           setDealID.add(title.Deals__r[0].Id);    // Added for REL-147
                 }
                 
                 //creating title TM Version map 
                 if(!titleTMVersionMap.containsKey(title.ID) && !title.TM_Versions__r.isEmpty()){
                     titleTMVersionMap.put(title.ID, title.TM_Versions__r[0]);
                 }
             }
         } 
         
         // Fetch Release Details
         if(!setReleaseID.isEmpty())
         {
             if(!fetchDataSet.containsKey('Release__c'))
                 fetchDataSet.put('Release__c',new Map<ID,sObject>());
             
             for(Release__c rel : [SELECT Id, Name, Brand_Group__c, Deal__c, Deal__r.Legal_Owner__c, Deal__r.Financial_Owner__c,Street_Date__c,First_Theatrical_Date__c,
                                   Windowed_Rental_Pre_Order_Close_Date__c, Windowed_Rental_Street_Date__c, VOD_Street_Date__c,Internal_Announce_Date__c,Trade_Solicitation_Date__c,
                                   In_Plant_Date__c,Pre_Order_Close_Date__c,EST_Date__c, TM_Version__c,Release_Status__c, Title__c, //Added Title for REL-165
                                   (SELECT Id, Material_Status__c FROM Materials__r)
                                   FROM Release__c
                                   WHERE Id IN :setReleaseID])
             {
                 fetchDataSet.get('Release__c').put(rel.Id, rel);
             }
             system.debug('fetchDataSet'+fetchDataSet);
         }
 
         //for deal details 
         if(!setDealID.isEmpty()){
             if(!fetchDataSet.containsKey('Deal__c'))
                 fetchDataSet.put('Deal__c',new Map<ID,sObject>());
         
             for(Deal__c deal : [SELECT Id, Deal_ID__c, Label_Code__c, Title__c, Legal_Owner__c, Financial_Owner__c,Origin_Code__c
                                 FROM Deal__c WHERE ID IN :setDealID ]){
                                     
                 fetchDataSet.get('Deal__c').put(deal.ID, deal);
                 system.debug('deal 2778 :: '+ deal);
                 if(deal.Label_Code__c != null){
                     setLabelCode.add(deal.Label_Code__c);
                 }
                     
                 if(deal.Origin_Code__c != null){
                     setOriginCode.add(deal.Origin_Code__c);
                 }
             }
         }
         
         if(TriggerUtility.currentUser.Label_Code__c != null)
             setLabelCode.add(TriggerUtility.currentUser.Label_Code__c);
         
         // Fetching Label Code and Sub-Label Code relationship
         if(!setLabelCode.isEmpty())
         {
             for(String lblCode : setLabelCode)
             {
                 if(LabelCode_SubLabelCode_Map__c.getInstance(lblCode) != null && LabelCode_SubLabelCode_Map__c.getInstance(lblCode).Sub_Label_Code_Id__c != null)
                 {
                     lblCodeSubLblCodeIdMap.put(lblCode, LabelCode_SubLabelCode_Map__c.getInstance(lblCode).Sub_Label_Code_Id__c);
                 }
             }
             
             // Fetching sub label code Id map.
             if(lblCodeSubLblCodeIdMap.size() > 0)
             {
                 for(Sub_Label_Code__c sLblCode : [SELECT Id, Sub_Label_Code_ID__c FROM Sub_Label_Code__c 
                                                   WHERE Sub_Label_Code_ID__c IN: lblCodeSubLblCodeIdMap.values()])
                 {
                     /* DF-2152 ---*/ subLblCodeMap.put(sLblCode.Sub_Label_Code_ID__c, sLblCode.Id);
                 }
             }
         }
         
         //get BOM Item Details along with Material
         if(!setMaterialID.isEmpty()){
             if(!fetchDataSet.containsKey('Material__c'))
                 fetchDataSet.put('Material__c',new Map<ID,sObject>());
             // Changed for 101 Error
             Set<Id> ftMatIds = new Set<Id>();
            
             for(BOM_Item__c bom : [SELECT Id, Material__c, Material_Component__c, Material_Component__r.Material_Status__c, Material__r.Release__c, Material_Component__r.Release__c, 
                                    Material_Component__r.Material_Type__c,material__r.Street_Date__c,material__r.Pre_Order_Close_Date__c,BOM_Function__c,
                                    Material_Component__r.Item_Type__c,Material_Component__r.Item_Code__c,Material_Component__r.Street_Date__c ,                                
                                    Material__r.Material_Status__c,Material__r.BOM_Status__c, Material__r.Material_Number__c, Material__r.Label_Code__c,  Material_Component__r.Selection_Reference_Number__c, Material_Component__r.Component_Material__c, Material__r.CreatedBy.userRole.Name                                 
                                    FROM BOM_Item__c
                                    WHERE Material__c IN: setMaterialID])
             {
                 if(!matBomMap.containsKey(bom.Material__c))
                     matBomMap.put(bom.Material__c, new List<BOM_Item__c>());
                 matBomMap.get(bom.Material__c).add(bom);
                 // Changed for 101 Error
                 if (bom.Material_Component__r.Item_Type__c == 'D (Display Vehicle)' && bom.Material_Component__r.Item_Code__c == 'FT - PHANTOM TRAY' && 
                    bom.Material_Component__r.Material_Type__c == 'FERT') {
                    ftMatIds.add(bom.Material_Component__c);
                 }
             }
             
             for(Material__c mt : [SELECT ID, Name, Material_Type__c, Title__c, Title__r.Genre_Primary__c, Title__r.Runtime_US__c, Label_Code__c,
                                   Item_Type__c, Item_Code__c, Format__c, Territory__c, RecordTypeId, Release__c, Street_Date__c,Theatrical_Release_Date__c,
                                   Windowed_Rental_Pre_Order_Close_Date__c, Windowed_Rental_Street_Date__c,VOD_Street_Date__c,Original_Release_Date__c,
                                   Internal_Announce_Date__c,Trade_Solicitation_Date__c, In_Plant_Date__c,Pre_Order_Close_Date__c,EST_Date__c,Material_Status__c,Material_Number__c,
                                   BOM_status__c,BOM_Integration_State__c,  
                                   (SELECT Id, Street_Date__c, Pre_Order_Date__c, Material__c, Original_Release_Date__c, Announcement_Date_US__c,
                                    Theatrical_Release_Date__c, Solicitation_Date__c, Windowed_Rental_Pre_Order_Close_Date__c,Windowed_Rental_Street_Date__c,
                                    VOD_Street_Date__c, Internal_Announce_Date__c, In_Plant_Date__c, EST_Date__c, Territory__c, Material_Pricing_Group__c
                                    FROM Sales__r),
                                   (SELECT Id, Name, Special_Procurement__c FROM Plants__r),
                                   (SELECT Id FROM Valuations__r),
                                   (SELECT Id,Deletion_Flag__c,RecordTypeID FROM Classifications__r),
                                   (SELECT Id FROM Alternative_Units_of_Measure__r),
                                   (SELECT Id, Component_Number__c, Material_Component__c, Material__c FROM BOM_Items1__r),
                                   (SELECT Id FROM v_Materials__r)
                                   FROM Material__c where ID IN: setMaterialID OR Id IN: ftMatIds]){ // Changed for 101 Error
             System.debug('##Fetchdata set material'+ mt);                          
                 fetchDataSet.get('Material__c').put(mt.ID, mt);
             }
         }
         
         //get origin code details
         if(!setOriginCode.isEmpty()){
             if(!fetchDataSet.containsKey('Origin_Code__c'))
                 fetchDataSet.put('Origin_Code__c',new Map<ID,sObject>());
             
             for(Origin_Code__c oc : [SELECT Origin_Code__c, Label_Code__c, Sub_Label_Code__c, Label_Code_2__c, Sub_Label_Code_2__c, Default_Deal_ID__c FROM Origin_Code__c WHERE Origin_Code__c IN :setOriginCode]){ //USST-2728 & USST-2669
                 fetchDataSet.get('Origin_Code__c').put(oc.ID, oc);
                 
                 if(oc.Label_Code__c != null && !originCodeLblCodeMap.containsKey(oc.Origin_Code__c)) { // Added for REL-147
                    originCodeLblCodeMap.put(oc.Origin_Code__c, oc); //USST-2728
                 }
                 if(oc.Sub_Label_Code__c != null && !originCodeSubLblCodeMap.containsKey(oc.Origin_Code__c)){
                    originCodeSubLblCodeMap.put(oc.Origin_Code__c, oc);  //USST-2728
                 }
                 
             }
         }
         
         //creating a map of TM Version
         if(!setTMVersionID.isEmpty()){
             if(!fetchDataSet.containsKey('TM_Version__c'))
                 fetchDataSet.put('TM_Version__c',new Map<ID,sObject>());
             
             for(TM_Version__c tm : [SELECT Id, Version_Type__c, Original_Flag__c FROM TM_Version__c WHERE Id IN: setTMVersionID])
             {
                 fetchDataSet.get('TM_Version__c').put(tm.Id, tm);
                 
                 if(!tmVersionMap.containsKey(tm.ID)){
                     tmVersionMap.put(tm.ID,tm);
                 }
             }
         }
         
         //Getting TM version ID for G1200 user
         if(TriggerUtility.currentUser != null && TriggerUtility.currentUser.UserRole.Name=='G1200' && TriggerUtility.currentUser.Label_Code__c=='89 - FUNIMATION'){
             tmVersionList = [Select id from TM_Version__c where Series_Sys__c=:Label.G1200_SGENNO limit 1];
         }       
     }
     
     /***********************************
     Method Name: commitDataSet
     Purpose:Should Method for performing DML operations
     ***********************************/
     private static void commitDataSet()
     {
         //for inserting records
        if(!insertableDataSet.isEmpty())
        {
            // Changed for Deal
            Map<String, List<SObject>> tmpInsertableDataSet = new Map<String, List<SObject>>();
            // Copying elements from static variable.
            for(String sobjectApi : insertableDataSet.keySet())
            {
                tmpInsertableDataSet.put(sobjectApi, new List<SObject>());
                for(SObject rec : insertableDataSet.get(sobjectApi))
                {
                    tmpInsertableDataSet.get(sobjectApi).add(rec.clone());
                }
            }
            insertableDataSet.clear();
            
            for(String sobjectApi : tmpInsertableDataSet.keySet())
            {
                List<SObject> dataSet = tmpInsertableDataSet.get(sobjectApi);
                if(dataSet != null && dataSet.size() > 0) //Updated for REL-172
                {
                    insert dataSet;
                }
            }
        }
        
          //for updating records
        if(!updateableDataSet.isEmpty())
        {
            // Changed for Deal
            Map<String, Map<Id, SObject>> tmpUpdateableDataSet = new Map<String, Map<Id, SObject>>();
            // Copying elements from static variable.
            for(String sobjectApi : updateableDataSet.keySet())
            {
                tmpUpdateableDataSet.put(sobjectApi, new Map<Id, SObject>());
                for(Id recId : updateableDataSet.get(sobjectApi).keySet())
                {
                    tmpUpdateableDataSet.get(sobjectApi).put(recId, updateableDataSet.get(sobjectApi).get(recId).clone(true, false, false, false));
                }
            }
            updateableDataSet.clear();
            
            for(String sobjectApi : tmpUpdateableDataSet.keySet())
            {
                if(TriggerUtility.doNotExecuteOnMaterialCloningUpdate && Trigger.isUpdate && sobjectApi.equalsIgnoreCase('Sales__c'))
                {
                    continue;
                }
                
                Map<Id, SObject> dataSet = tmpUpdateableDataSet.get(sobjectApi);
                
                System.debug('*****sobjectApi> '+sobjectApi+' :: '+dataSet.values());
                if(dataSet != null && dataSet.size() > 0) //Updated for REL-172
                {
                    
                    update dataSet.values();
                }
            }
        }
        
        //for deleting records
        if(!deleteableDataSet.isEmpty())
        {
            // Changed for Deal
            Map<String, Map<Id, SObject>> tmpDeleteableDataSet = new Map<String, Map<Id, SObject>>();
            // Copying elements from static variable.
            for(String sobjectApi : deleteableDataSet.keySet())
            {
                tmpDeleteableDataSet.put(sobjectApi, new Map<Id, SObject>());
                for(Id recId : deleteableDataSet.get(sobjectApi).keySet())
                {
                    tmpDeleteableDataSet.get(sobjectApi).put(recId, deleteableDataSet.get(sobjectApi).get(recId).clone(true, false, false, false));
                }
            }
            deleteableDataSet.clear();
            
            for(String sobjectApi : tmpDeleteableDataSet.keySet())
            {
                Map<Id, SObject> dataSet = tmpDeleteableDataSet.get(sobjectApi);
                if(dataSet != null && dataSet.size() > 0) //Updated for REL-172
                {
                    delete dataSet.values();
                }
            }
        }
     }
     
     /***********************************
     Method Name: executeOnBeforeInsert
     Purpose:Should execute only for before insert event.
     ***********************************/    
     public static void executeOnBeforeInsert(){
         
         List<Material__c> matList = new List<Material__c>();
         
         //first iteration over trigger.new to create collections
         for(Material__c mt : (List<Material__c>)trigger.new)
         {   
             //populating item code for based on material type if it is ROH/Z009
             if(mt.Material_Type__c != null && (mt.Material_Type__c == 'ROH' || mt.Material_Type__c == 'Z009') && mt.Component_Type__c != null && Component_ItemCode_Mapping__c.getInstance(mt.Component_Type__c) != null)
             {
                mt.Item_Code__c = Component_ItemCode_Mapping__c.getInstance(mt.Component_Type__c).Item_Code__c;
             }
 
             //if territory for a Baby FERT is not US & CDN then throw error
             if(mt.Item_Type__c == 'S (Single)' && mt.Item_Code__c == 'BF - BABY FERT' && mt.Territory__c != 'US & CDN' && mt.Label_Code__c != '59 - Paramount')
             {
                if(!TriggerUtility.checkFromCloning)
                    mt.addError('Please select territory US & CDN for Baby FERT.');
                else
                    mt.Territory__c = 'US & CDN';
             }
             
             //setting item catgeory group based on material Type
             if(mt.Item_Type__c == 'S (Single)' || mt.Item_Type__c == 'M (Multipack)')
                 mt.Item_Category_Group__c = 'NORM';
             else if(mt.Item_Type__c == 'D (Display Vehicle)')
                 mt.Item_Category_Group__c = 'ZUMF';
             else if(mt.Material_Type__c == 'ROH' || mt.Material_Type__c == 'Z009')
                 mt.Item_Category_Group__c = 'ZCMP';
             
             // Format Code to Format Assignment
             assignWizardFormat(mt);
             
             //creating a set of title ID
             if(mt.Title__c != null && !setTitleID.contains(mt.Title__c)){
                 setTitleID.add(mt.Title__c);
                 titleIdSet.add(mt.Title__c);//RE-10
             } 
 
             //creating a set of deal ID
             if(mt.Deal__c != null && !setDealID.contains(mt.Deal__c)){
                 system.debug('deal 2788 :: '+mt.Deal__c);
                 setDealID.add(mt.Deal__c);
             }   
             
             //creating a set of label codes
             if(mt.Label_Code__c != null && !setLabelCode.contains(mt.Label_Code__c)){
                 setLabelCode.add(mt.Label_Code__c);             
             }
             
             //creating a set of release ID
             if(mt.Release__c != null && !setReleaseID.contains(mt.Release__c)){
                 setReleaseID.add(mt.Release__c);
             }
             
             //creating a set of origin code
             if(mt.TM_Origin_Code__c != null && !setOriginCode.contains(mt.TM_Origin_Code__c)){
                 setOriginCode.add(mt.TM_Origin_Code__c);
             }
             
             //creating a list of material with record type Id other than update
             if(mt.RecordTypeId != updateRecTypeId){   
                 matList.add(mt);
             } 
         }
         
         //fetching data set for processing
         getDataSet(); 
         fetchDealData(); //RE-10     
         
         // Call the naming convention class to maintain Material Names.
         if(TriggerUtility.followMaterialNamingConvension || Test.isRunningTest())
             MaterialNamingConventionHandler.setMaterialDescription();
         
         
         //checking dupicate description
         MaterialTriggerHelper.checkDuplicateMaterialDescription();
                 
         //Validating BOM Long Text
         if(!matList.isEmpty()){      
             checkSpecialChars(matList,false);
         }        
         
         //second iteration over Trigger.New for actual iteration
         for(Material__c mt : (List<Material__c>)trigger.new)
         {
             mt.Name = mt.Name.toUpperCase();
             
            // Changed for Deal
            if (mt.Title__c != null && titleDealMap != null && titleDealMap.get(mt.Title__c) != null && 
                titleDealMap.get(mt.Title__c).Origin_Code__c == null) {
                mt.addError('The Origin Code of Deal: '+titleDealMap.get(mt.Title__c).Name+' (under Title: '+
                            titleDealMap.get(mt.Title__c).Title__r.Name+') is not valid in the system. Please reach out to IT to resolve.');
            }
            
            // Changed for Deal
            if (mt.Deal__c != null && fetchDataSet != null && fetchDataSet.get('Deal__c') != null &&
                fetchDataSet.get('Deal__c').get(mt.Deal__c) != null) {
                Deal__c curDeal = (Deal__c) fetchDataSet.get('Deal__c').get(mt.Deal__c);
                if(curDeal.Origin_Code__c == null) {
                    mt.addError('This Deal\'s Origin Code is not valid in the system. Please reach out to IT to resolve.');
                }
            }
             //Following method validates if materials are having Label code or not. If it does not have, it attempts fill it with logic.
             validateNPopulateLabelCode(mt);
             
             //Method to update Label Code
             updateLabelCode(mt);
             
            // Calling child component batch job for label code change. // Changed for Deal
            if(childMatLabelChangeMap.size() > 0) {
                Database.executeBatch(new ChildLabelUpdateBatchHandler(childMatLabelChangeMap.values()));
            }
            
             // Calling method to synchronize values with associated release
             syncMaterialWithRelease(mt);
             
             // Calling method to populate Function.
             updateFunctionValue(mt);
                       
             //setting sub label code based on origin code or label code
             if(mt.Material_Type__c == 'FERT' && mt.Title__c != Null && titleDealMap.containsKey(mt.Title__c) && titleDealMap.get(mt.Title__c) != null)
             {
                 mt.Deal_id__c=titleDealMap.get(mt.title__c).deal_Id__c; //USST-2728
                 
                 if(titleDealMap.get(mt.Title__c).Origin_Code__c != null && originCodeSubLblCodeMap.containsKey(titleDealMap.get(mt.Title__c).Origin_Code__c) && originCodeSubLblCodeMap.get(titleDealMap.get(mt.Title__c).Origin_Code__c) != null && mt.RecordTypeId != updateRecTypeId) //USST-2707
                 {           
                    //USST-2728 --- start
                    if (originCodeSubLblCodeMap.get(titleDealMap.get(mt.Title__c).Origin_Code__c).Default_Deal_ID__c != null && originCodeSubLblCodeMap.get(titleDealMap.get(mt.Title__c).Origin_Code__c).Default_Deal_ID__c != '' && originCodeSubLblCodeMap.get(titleDealMap.get(mt.Title__c).Origin_Code__c).Default_Deal_ID__c == mt.Deal_ID__c) {
                        mt.Sub_Label_Code_Lookup__c = originCodeSubLblCodeMap.get(titleDealMap.get(mt.Title__c).Origin_Code__c).Sub_Label_Code_2__c;
                    }
                    else {
                        mt.Sub_Label_Code_Lookup__c = originCodeSubLblCodeMap.get(titleDealMap.get(mt.Title__c).Origin_Code__c).Sub_Label_Code__c;
                    }
                    //USST-2728 --- end
                 }
                 else if(titleDealMap.get(mt.Title__c).Label_Code__c != null)
                 {
                     String lblCode = titleDealMap.get(mt.Title__c).Label_Code__c;
                     if(lblCodeSubLblCodeIdMap.containsKey(lblCode) && subLblCodeMap.containsKey(lblCodeSubLblCodeIdMap.get(lblCode)) && mt.RecordTypeId != updateRecTypeId) //USST-2707
                         mt.Sub_Label_Code_Lookup__c = subLblCodeMap.get(lblCodeSubLblCodeIdMap.get(lblCode));
                 }
             }
             else if(mt.Material_Type__c == 'FERT' && (mt.Item_Type__c == 'M (Multipack)' || mt.Item_Type__c == 'D (Display Vehicle)') && 
                 mt.Label_Code__c != null && lblCodeSubLblCodeIdMap.containsKey(mt.Label_Code__c) && subLblCodeMap.containsKey(lblCodeSubLblCodeIdMap.get(mt.Label_Code__c)) && mt.RecordTypeId != updateRecTypeId) //USST-2707
             {
                 mt.Sub_Label_Code_Lookup__c = subLblCodeMap.get(lblCodeSubLblCodeIdMap.get(mt.Label_Code__c));
             }
             
             //setting TM Version
             if(mt.Title__c != Null && titleTMVersionMap.containsKey(mt.Title__c) && TriggerUtility.checkFromUpdateMaterial == false) 
             {
                 mt.TM_Version_Lookup__c = titleTMVersionMap.get(mt.Title__c).ID;
             }
             
             if(mt.item_type__c=='D(Display Vehicle)' && TriggerUtility.checkFromCloning){
             
                 mt.product_class__c='';
             }
             //updating TM version for G1200 user
             updateTMVersionG1200(mt);
             
             //update dates on material based on release
             updateDateFromRelease(mt);
             
             //update date fields on materials based on street date
             updateMaterialDate(mt);
             
             //populating record type fiter
             updateRecordTypeFilter(mt);
             

            //ReleaseForce 2.0 RE-10 Defaulting Deal ID for LabelCode - 59,36,88,23,86,32
             if(Default_DealID_Mapping__c.getAll()!=null && Default_DealID_Mapping__c.getInstance(mt.Label_code__c)!=null && mt.Item_Type__c=='S (Single)'){
                 system.debug('enter pckg code 2778');
                 if(dealDefaultMap!=null && dealDefaultMap.get(Default_DealID_Mapping__c.getInstance(mt.Label_code__c).DEAL_ID__c)!=null){
                         for(Deal__c deal: dealDefaultMap.get(Default_DealID_Mapping__c.getInstance(mt.Label_code__c).DEAL_ID__c)){
                            if(deal.title__c==mt.title__c){
                                 mt.Deal_id__c=deal.deal_Id__c;
                                 mt.deal__c=deal.id;
                                break; //added for usst-2455
                             }
                             
                             else{
                                 mt.deal__c=null;
                                 mt.Deal_id__c=null;
                                continue; //added for usst-2455
                             }
                         }
                 }
                 else if(titleDealMap!=null && titleDealMap.containsKey(mt.title__c)){
                                 mt.Deal_id__c=titleDealMap.get(mt.title__c).deal_Id__c;
                                 mt.deal__c=titleDealMap.get(mt.title__c).id;
                  }
                 else{
                     mt.deal__c=null;
                     mt.Deal_id__c=null;
                 }
                 
                 System.debug('##Deal ONInsert'+mt.deal__c+' ## DealID'+mt.Deal_id__c);
             }
             
             system.debug('mat origin code :: '+mt.TM_Origin_Code__c);
         }
         
         //Releaseforce2.0 RE-50---calling method to insert contact information from release
         insertMaterialContacts(setReleaseID);
         
         //applying default values on material and child records
         if(!TriggerUtility.checkFromTemplate && !TriggerUtility.doNotExecuteDefaulting)
             DefaultingHandler.applyDefaultValues();
         
         //performing DML
         commitDataSet();
         
         //clear data set
         resetDataSet();
     }
     
     /***********************************
     Method Name: executeOnAfterInsert
     Purpose:Should execute only for after insert event.
     ***********************************/
     public static void executeOnAfterInsert(){
         
         setMaterialID = Trigger.NewMap.KeySet();
         
         for(Material__c mt : (List<Material__c>)trigger.new){
             //creating a set of release ID
             if(mt.Release__c != null && !setReleaseID.contains(mt.Release__c)){
                 setReleaseID.add(mt.Release__c);
             }
         }
         
         //fetching data set for processing
         getDataSet(); 
         
         if(!insertableDataSet.containsKey('Task'))
             insertableDataSet.put('Task', new List<SObject>());
         
         if(TriggerUtility.checkFromCloning){
             BOMLongTextHandler.manageBOMLongText();
         }
         
         checkSpecialChars((List<Material__c>)trigger.new,true);
         
         Set<Id> releaseIds = new Set<Id>();
         List<Material__c> lstMaterialAdd = new List<Material__c>();
         List<Material__c> lstMaterialRemove = new List<Material__c>();
         Map<Id,Material__c> updateMatList = new Map<Id,Material__c>();
         System.Debug('check Trigger size!! '+trigger.new.size());
         
         for(Material__c mt : (List<Material__c>)trigger.new){
             
             // Calling method to create Release Material for associated Release (if needed)
             createReleaseMaterial(mt);
             
             // Method to update date fields on sales records.
             updatePreOrderDatefromMaterial(mt);
             
             // Method to update component number on bom item if its changed on component material
             updateBomItemMaterialNumberReference(mt);
             
             //For TM Version update on Release
             updateTMVonRelease(mt);
             
             // Creating task for updating material.
             if(mt.Release__c != null && mt.recordtypeId != updateRecTypeId) { //REL-217 to exclude update Materials from Activity tracking
                 Task objTask = new Task();
                 objTask.Subject = 'Material Added';
                 objTask.Description = 'Material Name: '+ mt.Name + '\n' + 'Added By: '+ userinfo.getName() + '\n' + 'DateTime: ' + DateTime.Now() ;
                 objTask.Activity_Description__c = 'Material Name: '+ mt.Name  + 'Added By: '+ userinfo.getName() + 'DateTime: ' + DateTime.Now() ;
                 objTask.Activity_Description__c = objTask.Activity_Description__c.left(120);        
                 objTask.WhatId = Id.valueof(mt.Release__c);
                 objTask.Status = 'Completed';
                 objTask.material__c = mt.id;
                 //Added below fields as part of REL-43
                objTask.Component_Type__c=mt.Component_Type__c;
                objTask.Format__c=mt.Format__c;
                objTask.Item_Code__c=mt.Item_Code__c;
                objTask.Material_Number__c=mt.Material_Number__c;
                if (fetchDataSet.get('Release__c') != null && (Release__c)fetchDataSet.get('Release__c').get(mt.Release__c) != null) {
                    objTask.Release_Name__c = ((Release__c)fetchDataSet.get('Release__c').get(mt.Release__c)).Name;
                }
                objTask.Street_Date__c = mt.Street_Date__c;//REL-155
                objTask.Label_Code__c = mt.Label_Code__c;//REL-43 changes_6thNov
                objTask.MaterialDescription_SmartSheet__c = mt.name;//REL-43 changes_6thNov
                 
                insertableDataSet.get('Task').add(objTask);
                 
                if(mt.Material_Status__c != null && statusToCheck.contains(mt.Material_Status__c))
                {
                    releaseIds.add(mt.Release__c);
                }
             }
             
             //creating classfication record
             createClassificationRecord(mt);
             
             if(!TriggerUtility.checkFromCloning)
             {
                 // Update Plant records for Phantom Trays.
                 plantUpdateForPhantomTrays(mt);
                 if(!mt.Execute_Validation_Rule__c){
                     Material__c upMat;
                     if(updateMatList.containsKey(mt.id)){
                         upMat = updateMatList.get(mt.id);
                     }
                     else {
                         upMat = new Material__c(Id=mt.Id);
                     }
                     upMat.Execute_Validation_Rule__c =true;
                     updateMatList.put(mt.id,upMat);
                 }
             }
             
             // Modified for REL-52
              if(updateMatList.size() > 0 && !TriggerUtility.checkFromUpdateMaterial){
                 TriggerUtility.doNotExecute = True;
                 update updateMatList.values();
                 TriggerUtility.doNotExecute = False;
             }
             // Updates Sales record from Material
             updateSalesfromMaterial(mt);
             
             // To add or remove V-Material.
             if(mt.Material_Number__c != null && mt.Item_Code__c != 'BF - BABY FERT' && mt.RecordTypeID != updateRecTypeId){    
                 lstMaterialAdd.add(mt);
             }
             
             if(mt.Material_Status__c == 'Deleted'){
                 lstMaterialRemove.add(mt);
             }
             
             if(!mt.Execute_Validation_Rule__c){
                Material__c upMat;
                     if(updateMatList.containsKey(mt.id)){
                         upMat = updateMatList.get(mt.id);
                     }
                     else {
                         upMat = new Material__c(Id=mt.Id);
                     }
                     upMat.Execute_Validation_Rule__c =true;
                     updateMatList.put(mt.id,upMat);
             }
         }
         
         // Modified for REL-52
         if(updateMatList.size() > 0 && !TriggerUtility.checkFromUpdateMaterial){
             TriggerUtility.doNotExecute = True;
             update updateMatList.values();
             TriggerUtility.doNotExecute = False;
         }
         
         if(releaseIds.size() > 0 && TriggerUtility.currentUser != null && TriggerUtility.currentUser.Profile.Name != 'Platform API'){
             updateMaterialCounterOnStatus(releaseIds);
         } 
         
         if(!TriggerUtility.checkFromTemplate)
         {
             if(!lstMaterialAdd.isEmpty()){
                 vProjectUtility.addVMaterials(lstMaterialAdd,null);         
             }
             system.debug('lstMaterialRemove=== '+lstMaterialRemove);
             if(!lstMaterialRemove.isEmpty()){
                 vProjectUtility.removeVMaterial(lstMaterialRemove, null);         
             }
         }
         
         //performing DML
         commitDataSet();
         
         //applying default values on material and child records
         if(!TriggerUtility.checkFromTemplate && !TriggerUtility.doNotExecuteDefaulting)
             DefaultingHandler.applyDefaultValues();
         
         //clear data set
         resetDataSet();
     }
     
     /***********************************
     Method Name: executeOnBeforeUpdate
     Purpose:Should execute only for before update event.
     ***********************************/
     public static void executeOnBeforeUpdate(){
         
         //create a set of material ID
         setMaterialID = Trigger.NewMap.KeySet();
         
         //list of material where BOM Long text has changed
         List<Material__c>updateMat=new List<Material__c>();
         
         //method to unlock material record in case any
         IF(!TriggerUtility.CheckfromTemplate)
             unLockRecord();
             
         for(Material__c mt : (List<Material__c>)trigger.new){
             
             //changing material name to upper case
             mt.Name = mt.Name.toUpperCase();            
             
             oldMat = (Material__c)Trigger.oldMap.get(mt.Id); 
             
             //setting deal to null if title is changed to null
             if(mt.Title__c != oldMat.Title__c && mt.Title__c==Null && oldMat.Title__c!=null) {
                 system.debug('deal 2778 :: '+mt.Deal__c);
                 mt.Deal__c = Null;
             }
                   
             
             // Defdaulting Item Category Group
             if(mt.Item_Type__c == 'S (Single)' || mt.Item_Type__c == 'M (Multipack)')
                 mt.Item_Category_Group__c = 'NORM';
             else if(mt.Item_Type__c == 'D (Display Vehicle)')
                 mt.Item_Category_Group__c = 'ZUMF';
             
             //creating a set of title ID
             if(mt.Title__c != null && mt.Title__c != oldMat.Title__c && !setTitleID.contains(mt.Title__c)){
                 setTitleID.add(mt.Title__c);
             } 
             
             //RE-10
             if(mt.Title__c!=null){
                 titleIdSet.add(mt.Title__c);
             }
             
             //creating a set of release ID
             if(mt.Release__c != null && !setReleaseID.contains(mt.Release__c)){
                 setReleaseID.add(mt.Release__c);
             }
             
             //creating a set of origin code
             if(mt.Material_Type__c == 'FERT' && mt.TM_Origin_Code__c != oldMat.TM_Origin_Code__c && mt.TM_Origin_Code__c != null && !setOriginCode.contains(mt.TM_Origin_Code__c)){
                 setOriginCode.add(mt.TM_Origin_Code__c);
             }
             
             //creating a set of deal ID
             if(mt.Deal__c != null && !setDealID.contains(mt.Deal__c)){
                 system.debug('deal 2778 :: '+mt.Deal__c);
                 setDealID.add(mt.Deal__c);
                 if (mt.Deal__c != oldMat.Deal__c && mt.Title__c != null) {    // Changed for Deal
                    setTitleID.add(mt.Title__c);
                 }
             }   
             
             //creating a set of label codes
             if(mt.Label_Code__c != null && !setLabelCode.contains(mt.Label_Code__c)){
                 setLabelCode.add(mt.Label_Code__c);             
             }
             
             //creating a set of TM Version ID
             if(mt.Material_Type__c == 'FERT' && !setTMVersionID.contains(mt.TM_Version_Lookup__c) && mt.Title__c != null && mt.TM_Version_Lookup__c != oldMat.TM_Version_Lookup__c && mt.TM_Version_Lookup__c != null){
                 setTMVersionID.add(mt.TM_Version_Lookup__c);
             }
             
             //For BF territory should be US & CDN
             if(mt.Item_Type__c == 'S (Single)' && mt.Item_Code__c == 'BF - BABY FERT' && mt.Territory__c != 'US & CDN'){
                 mt.addError('Please select territory US & CDN for Baby FERT.');
             }
             
             //if old and new material BOM Long Text is not same
             if(oldMat.BOM_Long_Text__c != mt.BOM_Long_Text__c){
                 updateMat.add(mt);
             }
             if(oldMat.Material_status__c!=null){
                 mt.Prior_Status__c=oldMat.Material_status__c;
             }
             
              if(mt.recordTypeId == updateRecTypeId && (mt.Label_Code__c == '24 - PURE FLIX' || mt.Label_Code__c == '34 - Film Arcade' || mt.Label_Code__c == '44 - GKIDS' || mt.Label_Code__c == '45 - PICTUREHOUSE' || mt.Label_Code__c == '46 - DREAMWORKS ANImtION' 
                 || mt.Label_Code__c == '55 - Open Road Films' || mt.Label_Code__c == '57 - BLEECKER STREET' || mt.Label_Code__c == '58 - HiT Entertainment' || mt.Label_Code__c == '61 - Universal Pictures' || mt.Label_Code__c == '62 - Focus' || mt.Label_Code__c == '63 - Family Home Entertainment'
                 || mt.Label_Code__c == '64 - STX FINANCING LLC' || mt.Label_Code__c == '91 - AVIRON PICTURES' || mt.Label_Code__c == '36 - NEON RATED LLC')){
                 if(mt.street_date__c != oldMat.street_date__c ||
                     mt.Pre_Order_Close_Date__c != oldMat.Pre_Order_Close_Date__c ||
                     mt.Original_Release_Date__c != oldMat.Original_Release_Date__c ||
                     mt.Trade_Solicitation_Date__c != oldMat.Trade_Solicitation_Date__c ||
                     mt.Internal_Announce_Date__c != oldMat.Internal_Announce_Date__c || 
                     mt.Theatrical_Release_Date__c != oldMat.Theatrical_Release_Date__c ||
                     mt.Windowed_Rental_Pre_Order_Close_Date__c != oldMat.Windowed_Rental_Pre_Order_Close_Date__c ||
                     mt.Windowed_Rental_Street_Date__c != oldMat.Windowed_Rental_Street_Date__c){
                         if(mt.Material_Status__c == 'Draft' || mt.Material_Status__c == 'Sent Back')
                             mt.Execute_Validation_Rule__c = false;
                         mt.Date_Update_Request__c = true;
                     
                 }
             }
         }
         //fetching data set for processing
         getDataSet();
         fetchdealData();//RE-10
         
         //checking dupicate description
         MaterialTriggerHelper.checkDuplicateMaterialDescription();
         
         //STY-905 Method to check if BOM Long text contains special characters.
         if(TriggerUtility.checkFromCloning){
             BOMLongTextHandler.manageBOMLongText();
         }
         else{    
             if(!updateMat.isEmpty() && !TriggerUtility.CheckfromTemplate){
                 checkSpecialChars(updateMat,false);
             }               
         }
         
         for(Material__c mt : (List<Material__c>)trigger.new){
             
             oldMat = (Material__c)Trigger.oldMap.get(mt.Id);
             
             // Calling method to synchronize values with associated release
             syncMaterialWithRelease(mt);   
 
             // Calling method to populate Function.
             updateFunctionValue(mt);    
             
             //updating TM version on title change
             if(mt.Title__c != oldMat.Title__c && mt.Title__c != null && titleTMVersionMap.containsKey(mt.Title__c)) {
                 mt.TM_Version_Lookup__c = titleTMVersionMap.get(mt.Title__c).ID;
             }
             
            // Changed for Deal // Changed for REL-208
            if (mt.Title__c != null && mt.Title__c != oldMat.Title__c && titleDealMap != null && titleDealMap.get(mt.Title__c) != null) {
                if (titleDealMap.get(mt.Title__c).Origin_Code__c == null) {
                    mt.addError('The Origin Code of Deal: '+titleDealMap.get(mt.Title__c).Name+' (under Title: '+
                                titleDealMap.get(mt.Title__c).Title__r.Name+') is not valid in the system. Please reach out to IT to resolve.');
                }
                else {
                    
                    mt.Deal__c = titleDealMap.get(mt.Title__c).Id;
                    mt.Deal_ID__c = titleDealMap.get(mt.Title__c).Deal_ID__c; //USST-2728
                    system.debug('deal 2778 :: '+mt.Deal__c);
                }
            }
            
             //Added check for REL-12.. Not allow udpation of Label code on Components if the Status is not in Draft,Submitted or Sent Back.
             if(mt.Label_code__c != oldMat.Label_code__c &&( mt.Material_type__c=='ROH' || mt.Material_type__c=='Z009') && mt.material_status__c!='Draft' && mt.material_status__c!='Submitted' && mt.material_status__c!='Sent Back') {
                 mt.addError('Label Code cannot be updated for this as the Material status is not Draft,Submitted or Sent Back');
             }
             
             //updating title source based on TM Version
             //USST-2787 --- start
             if(mt.Material_Type__c == 'FERT' && mt.Title__c != oldMat.Title__c && mt.Title__c != null && 
                 mt.TM_Version_Lookup__c != null && tmVersionMap != null && tmVersionMap.containsKey(mt.TM_Version_Lookup__c) &&
                 tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c != null && tmVersionMap.get(mt.TM_Version_Lookup__c).Original_Flag__c == true)
             {
                if (tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'TH - Theatrical' || tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'DIRCUT - Director\'s Cut' || tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'UNRATED - Unrated' || tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'EXTEND - Extended' || tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'AIR - Airline' || tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'IMAX - IMAX')
                {
                    mt.Title_Source__c = '01 - THEATRICAL';
                }
                else if (tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'NONTH - Non-Theatrical' || tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'HV - Home Video' || tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'DTV - Direct To Video')
                {
                    mt.Title_Source__c = '03 - MADE FOR VIDEO';
                }
                else if (tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'TV - Television' || tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'SO - Stretchout' || tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'DIGITAL - Digital' || tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'UNC - Uncensored')
                {
                    mt.Title_Source__c = '02 - TELEVISION';
                }
                if (mt.Label_Code__c == '46 - DREAMWORKS ANIMATION' && (tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'TV - Television' || tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'SO - Stretchout' || tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'DIGITAL - Digital' || tmVersionMap.get(mt.TM_Version_Lookup__c).Version_Type__c == 'UNC - Uncensored'))
                {
                    mt.Title_Source__c = '03 - MADE FOR VIDEO';
                }
             }
             //USST-2787 --- end
             //setting sub label code value // Changed for REL-208
             if(!TriggerUtility.checkFromDefaulting && mt.Material_Type__c == 'FERT' && mt.Title__c != Null && mt.Title__c != oldMat.Title__c &&
                titleDealMap.containsKey(mt.Title__c) && titleDealMap.get(mt.Title__c) != null)
             {
                 //set Master Data Admin flag by checking logged in user group 
                 Boolean isMasterDataAdmin = false;
                 Set<Id> masterUserset = new Set<Id>();
                 for(GroupMember gm : [SELECT Id,UserOrGroupId FROM GroupMember WHERE Group.Developername = 'Master_Data' and UserOrGroupId =: UserInfo.getUserId()]){
                     isMasterDataAdmin = true;
                 }
                 
                 //set sub label code value only if its not a Master Data Admin
                 if(!isMasterDataAdmin){
                     if(titleDealMap.get(mt.Title__c).Origin_Code__c != null && originCodeSubLblCodeMap.containsKey(titleDealMap.get(mt.Title__c).Origin_Code__c))
                     {
                         if(originCodeSubLblCodeMap.get(titleDealMap.get(mt.Title__c).Origin_Code__c) != null && mt.RecordTypeId != updateRecTypeId){ //USST-2707
                             //USST-2728 --- start
                             if (originCodeSubLblCodeMap.get(titleDealMap.get(mt.Title__c).Origin_Code__c).Default_Deal_ID__c != null && originCodeSubLblCodeMap.get(titleDealMap.get(mt.Title__c).Origin_Code__c).Default_Deal_ID__c != '' && originCodeSubLblCodeMap.get(titleDealMap.get(mt.Title__c).Origin_Code__c).Default_Deal_ID__c == mt.Deal_ID__c) {
                                mt.Sub_Label_Code_Lookup__c = originCodeSubLblCodeMap.get(titleDealMap.get(mt.Title__c).Origin_Code__c).Sub_Label_Code_2__c;
                             }
                             else {
                                mt.Sub_Label_Code_Lookup__c = originCodeSubLblCodeMap.get(titleDealMap.get(mt.Title__c).Origin_Code__c).Sub_Label_Code__c;                               
                             }
                             //USST-2728 --- end
                         }
                     }
                     else if(titleDealMap.get(mt.Title__c).Label_Code__c != null)
                     {
                         String lblCode = titleDealMap.get(mt.Title__c).Label_Code__c;
                         if(lblCodeSubLblCodeIdMap.containsKey(lblCode) && subLblCodeMap.containsKey(lblCodeSubLblCodeIdMap.get(lblCode))&& mt.RecordTypeId != updateRecTypeId){ //USST-2707
                             mt.Sub_Label_Code_Lookup__c = subLblCodeMap.get(lblCodeSubLblCodeIdMap.get(lblCode));
                         }
                     }
                 }
             }
             
             //update date fields on material based on dates on release
             if(!TriggerUtility.initiatedFromRelease)
                 updateDateFromRelease(mt);
             
             //update material date
             updateMaterialDate(mt);
             
             //populating record type fiter
             updateRecordTypeFilter(mt);
             
             //update label code
             if(!TriggerUtility.checkFromDefaulting && !TriggerUtility.checkFromTemplate && !TriggerUtility.initiatedFromDeal) {    // Changed for REL-174
                updateLabelCode(mt);
               
                // Calling child component batch job for label code change. // Changed for Deal
                if(childMatLabelChangeMap.size() > 0) {
                    Database.executeBatch(new ChildLabelUpdateBatchHandler(childMatLabelChangeMap.values()));
                }
             }
             //update BOM Status
             updateBOMStatusonEdit(mt);
             
            // Validating if changed deal has origin code or not. // Changed for Deal
            Deal__c curDeal;
            if (mt.Deal__c != oldMat.Deal__c && mt.Deal__c != null && fetchDataSet != null && fetchDataSet.get('Deal__c') != null &&
                fetchDataSet.get('Deal__c').get(mt.Deal__c) != null) {
                curDeal = (Deal__c) fetchDataSet.get('Deal__c').get(mt.Deal__c);
                if(curDeal.Origin_Code__c == null) {
                    mt.addError('This Deal\'s Origin Code is not valid in the system. Please reach out to IT to resolve.');
                }
            }
            
              //ReleaseForce 2.0 RE-10 Defaulting Deal ID for LabelCode - 59,36,88,23,86,32
             if(mt.Deal__c!=null && mt.Deal__c!=oldMat.Deal__c && Default_DealID_Mapping__c.getAll()!=null && Default_DealID_Mapping__c.getInstance(mt.Label_code__c)!=null && mt.Item_Type__c=='S (Single)'){
                 system.debug('deal pckg code 2778');
                 System.debug('##Deal__c updated');
                 if(dealDefaultMap!=null && dealDefaultMap.get(Default_DealID_Mapping__c.getInstance(mt.Label_code__c).DEAL_ID__c)!=null){
                         for(Deal__c deal: dealDefaultMap.get(Default_DealID_Mapping__c.getInstance(mt.Label_code__c).DEAL_ID__c)){
                             if(deal.title__c==mt.title__c){
                                 mt.Deal_id__c=deal.deal_Id__c;
                                 mt.deal__c=deal.id;
                             }
                             
                             else{
                                 mt.deal__c=null;
                                 mt.Deal_id__c=null;
                             }
                         }
                 }
                 System.debug('##Deal__c updated '+mt.Deal_id__c+'Deal Name '+mt.deal__c);
             }
             
             //ReleaseForce 2.0 RE-10 Defaulting Deal ID for LabelCode - 59,36,88,23,86,32
             if(mt.Label_Code__c!=null && mt.Label_Code__c!=oldMat.Label_Code__c && Default_DealID_Mapping__c.getAll()!=null && Default_DealID_Mapping__c.getInstance(mt.Label_code__c)!=null && mt.Item_Type__c=='S (Single)'){
                 system.debug('deal pckg code 2778');
                 if(dealDefaultMap!=null && dealDefaultMap.get(Default_DealID_Mapping__c.getInstance(mt.Label_code__c).DEAL_ID__c)!=null){
                         for(Deal__c deal: dealDefaultMap.get(Default_DealID_Mapping__c.getInstance(mt.Label_code__c).DEAL_ID__c)){
                             if(deal.title__c==mt.title__c){
                                 mt.Deal_id__c=deal.deal_Id__c;
                                 mt.deal__c=deal.id;
                             }
                             
                             else{
                                 mt.deal__c=null;
                                 mt.Deal_id__c=null;
                             }
                         }
                 }
             }
           System.debug('Material Deal--before------->'+mt.deal__c);
           system.debug('mat origin code :: '+mt.TM_Origin_Code__c);
         }
         
         //vlaidating if all the SAP fields are populated
         if(((Material__c)(Trigger.New[0])).Material_Status__c != ((Material__c)(Trigger.OldMap.get(Trigger.New[0].ID))).Material_Status__c && ((Material__c)(Trigger.New[0])).Material_Status__c == 'Approved' && !TriggerUtility.CheckfromTemplate){
             MaterialApprovalHandler.checkSAPallFieldsComplete((List<Material__c>)trigger.New);
         }
         
         //applying default values on material and child records
         if(!TriggerUtility.CheckfromTemplate && !TriggerUtility.doNotExecuteDefaulting)
             DefaultingHandler.applyDefaultValues();
            //Please remove the below block
            For(Material__c mat:(List<Material__c>)Trigger.new){  
            
                System.debug('Material Deal------->'+mat.deal__c);
            }
         
         //performing DML
         commitDataSet();
         
         //clear data set
         resetDataSet();
     }
     
     /***********************************
     Method Name: executeOnAfterUpdate
     Purpose:Should execute only for after update event.
     ***********************************/
     public static void executeOnAfterUpdate(){
         Boolean isSalesUpdated = FALSE;
         
         setMaterialID = Trigger.NewMap.KeySet();
         
         set<Id>sentBackIds=new set<Id>();
         set<Id>deletedMats=new set<Id>(); //ReleaseForce 2.0 RE-111 delete Release Materials when material is deleted from SAP
          Set<id>relSet=new Set<id>(); //USST-2843 & USST-2793
          Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId(); //USST-2843 & USST-2793
         system.debug('usst-2546 :: '+(List<Material__c>)trigger.new);
         for(Material__c mt : (List<Material__c>)trigger.new){
             
             oldMat = (Material__c)Trigger.oldMap.get(mt.Id);   
            system.debug('@@@@@@@@@@@@@ oldMat1 ::'+oldMat);
            
            //USST-2843 & USST-2793 --- start
            if((mt.Material_Status__c=='Submitted' || (mt.Material_Status__c=='Approved' && mt.Item_Type__c == 'D (Display Vehicle)')) && mt.recordtypeid !=recTypeId) {             
                if(mt.Material_Type__c =='FERT'){
                    relSet.add(mt.release__c);
                }
            }  
            if(!relSet.isEmpty()){
                List<Release__c> relRec=[select Release_Status__c from Release__c where id in:relSet] ;
                for(Release__c rel:relRec){
                    rel.release_status__c='Materials Requested';
                }  
                if(!relRec.isEmpty()){
                    update relRec;
                }
            }
            //USST-2843 & USST-2793 --- end
              //creating a set of material ID where territory was change
             if(mt.Territory__c != oldMat.Territory__c && mt.Territory__c != null && mt.Territory__c.equalsIgnoreCase('US & CDN') && (oldMat.Territory__c == 'US' || oldMat.Territory__c == 'CDN'))
             {
                 material4TerritoryChangeIds.add(mt.id);
             }
             
             // Check if territory is reduced from US & CDN to US or CDN.
             if(mt.Territory__c != oldMat.Territory__c && mt.Territory__c != null && oldMat.Territory__c != null && oldMat.Territory__c.equalsIgnoreCase('US & CDN') && (mt.Territory__c == 'US' || mt.Territory__c == 'CDN'))
             {
                 if((mt.Material_Status__c == 'Draft' || (mt.Material_Status__c != 'Draft' && TriggerUtility.currentUser.Profile.Name == 'Master Data Admin')))
                     materialTerritoryReduceMap.put(mt.Id, (mt.Territory__c == 'US' ? 'CDN' : 'US'));
                 else
                     mt.addError('Territory cannot be changed in status: '+ mt.Material_Status__c+'.');
             }   
            
             // If update Material's deletion flag is checked
             if(mt.Deletion_Flag__c != oldMat.Deletion_Flag__c && mt.Deletion_Flag__c && mt.RecordTypeId == updateRecTypeId)
             {
                 deletingMatIds.add(mt.Id);
             } 
 
             //RE-111 Get a list of all deleted Materials.
             if(mt.Deletion_Flag__c != oldMat.Deletion_Flag__c && mt.Deletion_Flag__c)
             {
                 deletedMats.add(mt.Id);
             }
 
             //creating a set of release IDs
             if(mt.Release__c != null && mt.Material_Status__c != oldMat.Material_Status__c && (statusToCheck.contains(mt.Material_Status__c) || statusToCheck.contains(oldMat.Material_Status__c)) && mt.Material_Status__c!='Submitted')
             {
                 setReleaseID.add(mt.Release__c);
             }           
             //Added for resolving REL-165 issue
             if(mt.Release__c != null && mt.Deal__c != oldMat.Deal__c) {
                setReleaseID.add(mt.Release__c);
             }
             // Checking is SAP Update Indicator is checked and material's record type is 'Material' 
             if(mt.SAP_Update_Indicator__c != oldMat.SAP_Update_Indicator__c && mt.SAP_Update_Indicator__c && mt.RecordTypeId == matRecTypeId)
             {
                 matIds1.add(mt.Id);
             }
             
             // Checking if material is rejected and its status is Sent Back 
             if(mt.Material_Status__c != oldMat.Material_Status__c && mt.Material_Status__c=='Sent Back')    
             {
                 sentBackIds.add(mt.Id);
             }
         }
         
         //fetching data set for processing
         getDataSet(); 
         
         List<Material__c> lstMaterialAdd = new List<Material__c>();
         List<Material__c> lstMaterialRemove = new List<Material__c>();
         List<Material__c> updateMatList = new List<Material__c>();
         
         for(Material__c mt : (List<Material__c>)trigger.new){
             
             oldMat = (Material__c)Trigger.oldMap.get(mt.Id);    
            
             //method for creating release material
             createReleaseMaterial(mt);
             
             //calling method to update function value
             updateFunctionValue(mt);
             
             //Update Status of component
             if(!TriggerUtility.checkFromCloning && !TriggerUtility.doNotExecuteOnMaterialCloningUpdate)
                 updateComponentStatus(mt);
             
             //To check DealId is populated on the material
             checkDealIdPopulated(mt);
             
             // Method to update date fields on sales records.
             updatePreOrderDatefromMaterial(mt);
             
             // Method to update component number on bom item 
             updateBomItemMaterialNumberReference(mt);
             
             //For TM Version update on Release
             updateTMVonRelease(mt);
             
             //code for creating task for new release       
             if(String.valueof(mt.Release__c) != null && string.valueof(mt.Release__c) != '' && oldMat.Release__c != mt.Release__c && mt.recordtypeId != updateRecTypeId) { //REL-217 to exclude update Materials from Activity tracking
                 Task objTask = new Task();
                 objTask.Subject = 'Material Added';
                 objTask.Description = 'Material Name: '+ mt.Name + '\n' + 'Added By: '+ userinfo.getName() + '\n' + 'DateTime: ' + DateTime.Now() ;
                 objTask.Activity_Description__c = 'Material Name: '+ mt.Name +  'Added By: '+ userinfo.getName()  ;
                 objTask.Activity_Description__c = objTask.Activity_Description__c.left(120);   
                 objTask.WhatId = Id.valueof(mt.Release__c);
                 objTask.Status = 'Completed';
                 objTask.material__c = mt.id;
                 //Added below fields as part of REL-43
                objTask.Component_Type__c=mt.Component_Type__c;
                objTask.Format__c=mt.Format__c;
                objTask.Item_Code__c=mt.Item_Code__c;
                objTask.Material_Number__c=mt.Material_Number__c;
                if (fetchDataSet.get('Release__c') != null && (Release__c)fetchDataSet.get('Release__c').get(mt.Release__c) != null) {
                    objTask.Release_Name__c = ((Release__c)fetchDataSet.get('Release__c').get(mt.Release__c)).Name;
                }
                objTask.Street_Date__c = mt.Street_Date__c;//REL-155
                objTask.Label_Code__c = mt.Label_Code__c;//REL-43 changes_6thNov
                objTask.MaterialDescription_SmartSheet__c = mt.name;//REL-43 changes_6thNov
                
                if (!insertableDataSet.containsKey('Task')) {    // Changed for Deal
                    insertableDataSet.put('Task', new List<SObject>());
                }
                 insertableDataSet.get('Task').add(objTask);
             }
             
             //for task creation
             if(String.valueof(OldMat.Release__c) != null && string.valueof(OldMat.Release__c) != '' 
                                                        && mt.Release__c != OldMat.Release__c && mt.Release__c != null && mt.recordtypeId != updateRecTypeId) { //Added null check for USST-2646 //REL-217 to exclude update Materials from Activity tracking
                 Task objTask = new Task();
                 objTask.Subject = 'Material Removed';
                 objTask.Description = 'Material Name: '+ OldMat.Name + '\n' + 'Removed By '+ userinfo.getName() + '\n' + 'DateTime: ' + DateTime.Now() ;
                 objTask.Activity_Description__c = 'Material Name:'+ OldMat.Name + 'Removed By: '+ userinfo.getName() ;
                 objTask.Activity_Description__c = objTask.Activity_Description__c.left(120);
                 objTask.WhatId = Id.valueof(OldMat.Release__c);
                 objTask.Status = 'Completed';
                  //Added below fields as part of REL-43
                 objTask.Component_Type__c=mt.Component_Type__c;
                 objTask.Format__c=mt.Format__c;
                 objTask.Item_Code__c=mt.Item_Code__c;
                 objTask.Material_Number__c=mt.Material_Number__c;
                 if (fetchDataSet.get('Release__c') != null && (Release__c)fetchDataSet.get('Release__c').get(mt.Release__c) != null) {
                    objTask.Release_Name__c = ((Release__c)fetchDataSet.get('Release__c').get(mt.Release__c)).Name;
                 }
                 objTask.Street_Date__c = mt.Street_Date__c;//REL-155
                 objTask.Label_Code__c = mt.Label_Code__c;//REL-43 changes_6thNov
                 objTask.MaterialDescription_SmartSheet__c = mt.name;//REL-43 changes_6thNov
                
                if (!insertableDataSet.containsKey('Task')) {    // Changed for Deal
                    insertableDataSet.put('Task', new List<SObject>());
                }
                 insertableDataSet.get('Task').add(objTask);
             }  
             
             // If Date fields in material got changed, replicate the same in associated sales record(s)
             if(fetchDataSet.containsKey('Material__c') && fetchDataSet.get('Material__c').containsKey(mt.ID) && TriggerUtility.currentUser.Name!='API User')
             {
                 for(Sales__c sales : ((Material__c) fetchDataSet.get('Material__c').get(mt.Id)).Sales__r)
                 {
                     isSalesUpdated = FALSE;                 
                     
                     Sales__c updtSales;
                     if(!updateableDataSet.containsKey('Sales__c'))
                         updateableDataSet.put('Sales__c', new Map<Id, SObject>());                        
                     
                     if(!updateableDataSet.get('Sales__c').containsKey(sales.ID)){
                         updtSales = sales;
                     }
                     else
                     {
                         updtSales = (Sales__c) updateableDataSet.get('Sales__c').get(sales.ID);
                     }                   
                     system.debug('************ '+oldMat.Title_Source__c + mt.Title_Source__c);

                    //USST-2493--- start :: Defaulting for MaterialPricing Group --- writing code here because Title source for multipacks is getting updated on Submission.
                    if ((mt.Item_Type__c == 'S (Single)' || mt.Item_Type__c == 'M (Multipack)') && mt.Material_Status__c != 'Processed in SAP') { //Modified for REL-158
                        isSalesUpdated = TRUE;
                        if (mt.Material_Type__c == 'FERT') {
                            if (mt.Item_Type__c == 'D (Display Vehicle)') {
                                updtSales.Material_Pricing_Group__c = 'Z0 - Not Tracked';
                            }
                            else if (mt.Label_Code__c == '89 - FUNIMATION') {
                                updtSales.Material_Pricing_Group__c = 'C2 - Not Tracked, 20%';
                            }
                            else if (mt.Label_Code__c == '45 - PICTUREHOUSE') {
                                updtSales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                            }
                            else if (mt.Label_Code__c == '57 - BLEECKER STREET') {
                                updtSales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                            }
                            else if (mt.Label_Code__c == '88 - Cinedigm') {
                                updtSales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                            }
                            else if (mt.Label_Code__c == '58 - HiT Entertainment') {
                                updtSales.Material_Pricing_Group__c = 'C7 - Not Tracked, 25%';
                            }
                            else if (mt.Label_Code__c == '24 - PURE FLIX') {
                                updtSales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                            }
                            else if (mt.Label_Code__c == '49 - PBS') {
                                updtSales.Material_Pricing_Group__c = 'D8 - Not Tracked, 35%';
                            }
                            else if (mt.Label_Code__c == '86 – SHOUT! Factory') {
                                updtSales.Material_Pricing_Group__c = 'C7 - Not Tracked, 25%';
                            }
                            else if (mt.Label_Code__c == '36 - NEON RATED LLC') {
                                updtSales.Material_Pricing_Group__c = 'C2 - Not Tracked, 20%';
                            }
                            else if (mt.Label_Code__c == '32 - Elevation' && updtSales.territory__c == 'CDN') {
                                updtSales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                            }
                            else if (mt.Label_Code__c == '23 - Remstar' && updtSales.territory__c == 'CDN') {
                                updtSales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                            }
                            else if (mt.Label_Code__c == '78 - D Films' && updtSales.territory__c == 'CDN') {
                                updtSales.Material_Pricing_Group__c = 'D3 - Not Tracked, 30%';
                            }
                            else if (mt.Label_Code__c == '59 - Paramount') {
                                if (mt.Title_Source__c == '02 - TELEVISION') {
                                    updtSales.Material_Pricing_Group__c = 'D7 - Not Tracked, 34%'; //USST-3162
                                }
                                else {
                                    updtSales.Material_Pricing_Group__c = 'E2 - Not Tracked, 38%'; //USST-3162
                                }
                            }
                            else if (updtSales.territory__c == 'US' && (mt.Item_Type__c == 'S (Single)' || mt.Item_Type__c == 'M (Multipack)')) {
                                updtSales.Material_Pricing_Group__c = 'E8 - Not Tracked, 44%'; //USST-3162
                            }
                            else if (updtSales.territory__c == 'CDN' && (mt.Item_Type__c == 'S (Single)' || mt.Item_Type__c == 'M (Multipack)')) {
                                if (mt.Title_Source__c == '02 - TELEVISION') {
                                    updtSales.Material_Pricing_Group__c = 'D5 - Not Tracked, 32%'; //USST-3162
                                }
                                else {
                                    updtSales.Material_Pricing_Group__c = 'E1 - Not Tracked, 37%'; //USST-3162
                                }
                            }
                        }
                        //USST-2493--- end :: Defaulting for MaterialPricing Group
                    }

                     
                     if(oldMat.Street_Date__c != mt.Street_Date__c && mt.Street_Date__c != null)
                     {
                         isSalesUpdated = TRUE;
                         updtSales.Street_Date__c = mt.Street_Date__c;
                     }
                     
                     if(oldMat.Pre_Order_Close_Date__c != mt.Pre_Order_Close_Date__c && mt.Pre_Order_Close_Date__c != null)
                     {
                         isSalesUpdated = TRUE;
                         updtSales.Pre_Order_Date__c = mt.Pre_Order_Close_Date__c;
                         system.debug('**Pre_Order_Close_Date__c '+mt.Pre_Order_Close_Date__c);
                     }
                     
                     if(oldMat.Internal_Announce_Date__c != mt.Internal_Announce_Date__c && mt.Internal_Announce_Date__c != null)
                     {
                         isSalesUpdated = TRUE;
                         updtSales.Internal_Announce_Date__c = mt.Internal_Announce_Date__c;
                     }
                     
                     if(oldMat.In_Plant_Date__c != mt.In_Plant_Date__c && mt.In_Plant_Date__c != null)
                     {
                         isSalesUpdated = TRUE;
                         updtSales.In_Plant_Date__c = mt.In_Plant_Date__c;
                     }
                     
                     if(oldMat.Theatrical_Release_Date__c != mt.Theatrical_Release_Date__c && mt.Theatrical_Release_Date__c != null)
                     {
                         isSalesUpdated = TRUE;
                         updtSales.Theatrical_Release_Date__c = mt.Theatrical_Release_Date__c;
                     }
                     
                     if(isSalesUpdated ){
                         if((mt.material_status__c != 'Processed in SAP') || (mt.material_status__c == 'Processed in SAP' && (TriggerUtility.currentUser.Profile.Name == 'Platform API' || TriggerUtility.currentUser.Profile.Name == 'System Administrator'))){  //USST-2846
                    
                         updateableDataSet.get('Sales__c').put(sales.ID, updtSales);  
                        }
                     }                      
                 }
             }   
             
             if(!TriggerUtility.checkFromCloning && !TriggerUtility.doNotExecuteOnMaterialCloningUpdate)
             {
                 plantUpdateForPhantomTrays(mt);
                 updatePhanatomTrayDates(mt);
             }
             
             if(setReleaseID.size() > 0 && TriggerUtility.currentUser.Profile.Name != 'Platform API'){
                 updateMaterialCounterOnStatus(setReleaseID);
             }  
             
             // To add or remove V-Material.
             if(mt.Material_Number__c != null && oldMat.Material_Number__c == null && mt.Item_Code__c != 'BF - BABY FERT' && mt.RecordTypeID != updateRecTypeId){    
                 lstMaterialAdd.add(mt);
             }
             
             if(mt.Material_Status__c == 'Deleted' && oldMat.Material_Status__c != 'Deleted'){
                 lstMaterialRemove.add(mt);
             }
                        
             //update BOM Function on BOM Item
             updateBOMFunction(mt);
             
             updateClassificationFields(mt);
             
             // Modified for REL-52
              if(!mt.Execute_Validation_Rule__c && !TriggerUtility.checkFromUpdateMaterial){
                 updateMatList.add(new Material__c(Id=mt.id,Execute_Validation_Rule__c=true));
             }
         }
         
         cancelUpdateMaterials();
         
         if(!TriggerUtility.checkFromTemplate)
         {
             if(!lstMaterialAdd.isEmpty()){
                 vProjectUtility.addVMaterials(lstMaterialAdd,null);         
             }
             
             if(!lstMaterialRemove.isEmpty()){
                 vProjectUtility.removeVMaterial(lstMaterialRemove, null);         
             }
         }
         
         updateBOMStatusJointCorrugate();
         
         //performing DML
         commitDataSet();
         
         //updating child territory
         if(material4TerritoryChangeIds.size() > 0)
         {
             updateTerritoryInChildComponents(material4TerritoryChangeIds);
         }  
         
         //removing child views
         if(materialTerritoryReduceMap.size() > 0)
         {
             removeChildViews4TerritoryChange(materialTerritoryReduceMap);
         }
         
         //deleting child view on material delete
         if(deletingMatIds.size() > 0)
         {
             removeChildViews4MaterialDelete(deletingMatIds);
         }                        
         
         //creating child record for new territory 
         
         DefaultingHandler.createChildRecordForTerritoryChange();
         updateAlternativeUnitofMeasure(trigger.new);       
         
         if(!TriggerUtility.doNotExecuteDefaulting)
             DefaultingHandler.applyDefaultValues();
         
         if(!sentBackIds.isEmpty())
         {
             updateComponentOnSentBack(sentBackIds);
         }
         //RE-39
         deleteRejectionChatter(trigger.new);
         //clear data set
         resetDataSet();
         
          //ReleaseForce 2.0 RE-111 delete Release Materials when material is deleted from SAP
         if(!deletedMats.isEmpty() && TriggerUtility.currentUser.Profile.Name == 'Platform API'){
             deleteReleaseMaterial(deletedMats);
         }
         System.debug('**updateMatList----'+updateMatList);
         if(updateMatList.size() > 0)
             update updateMatList;           
     }
     
     /***********************************
     Method Name: afterUpdateAddVMaterial
     Purpose:Should execute only for after update event.
     ***********************************/
     public static void afterUpdateAddVMaterial(){
         
         List<Material__c> lstMaterialAdd = new List<Material__c>();
         
         for(Material__c mt : (List<Material__c>)trigger.new){
             
             oldMat = (Material__c)Trigger.oldMap.get(mt.Id);
             if(mt.Material_Number__c != null && oldMat.Material_Number__c == null && mt.Item_Code__c != 'BF - BABY FERT' && mt.RecordTypeID != updateRecTypeId){    
                 lstMaterialAdd.add(mt);
             }
         }
         
         if(!lstMaterialAdd.isEmpty()){
             vProjectUtility.addVMaterials(lstMaterialAdd,null);         
         }
     }
     
     
     /***********************************
     Method Name: executeOnBeforeDelete
     Purpose:Should execute only for before delete event.
     Added for RE-35
     ***********************************/
     public static void executeOnBeforeDelete(){
         setMaterialID = Trigger.OldMap.KeySet();
         
         //fetching data set for processing
         getDataSet();
 
         for(Material__c mt : (List<Material__c>) trigger.old)
         {
             if(fetchDataSet.containsKey('Material__c') && fetchDataSet.get('Material__c').containsKey(mt.ID) && TriggerUtility.currentUser.Name != 'API User')
             {
                 for(v_Material__c vMat : ((Material__c) fetchDataSet.get('Material__c').get(mt.Id)).v_Materials__r)
                 {
                     deletedMatVMatList.add(vMat);
                 }
             }
         }
         System.debug('*****deletedMatVMatList_B> '+deletedMatVMatList);
     }
       
     /***********************************
     Method Name: executeOnAfterDelete
     Purpose:Should execute only after delete event
     ***********************************/
     public static void executeOnAfterDelete(){
         Set<Id> releaseIds = new Set<Id>();
         
         if(!insertableDataSet.containsKey('Task'))
             insertableDataSet.put('Task', new List<SObject>());
         if(!updateableDataSet.containsKey('v_Material__c'))
             updateableDataSet.put('v_Material__c', new Map<Id, SObject>());
         
         //Added for Activity related changes on 10th Nov    
        for(Material__c oldMaterial : (List<Material__c>)Trigger.Old){
            setReleaseID.add(oldMaterial.Release__c);
        }     
        
        //fetching data set for processing added on 10thNov
        getDataSet();
        
         for(Material__c oldMaterial : (List<Material__c>)Trigger.Old){
             if(String.valueof(oldMaterial.Release__c) != null && string.valueof(oldMaterial.Release__c) != '' && oldMaterial.recordtypeId != updateRecTypeId) { //REL-217 to exclude update Materials from Activity tracking
                 Task objTask = new Task();
                 objTask.Subject = 'Material Deleted';
                 objTask.Description = 'Material Name: '+ OldMaterial.Name + '\n' + 'Deleted By '+ userinfo.getName() + '\n' + 'DateTime: ' + DateTime.Now() ;
                 objTask.Activity_Description__c = 'Material Name: '+ oldMaterial.Name + 'Deleted By: '+ userinfo.getName() + '\n' + 'DateTime: ' + DateTime.Now() ;
                 objTask.Activity_Description__c = objTask.Activity_Description__c.left(120); 
                 objTask.WhatId = Id.valueof(oldMaterial.Release__c);
                 objTask.Status = 'Completed';
                 objTask.material__c = null;
                  //Added below fields as part of REL-43
                 objTask.Component_Type__c=oldMaterial.Component_Type__c;
                 objTask.Format__c=oldMaterial.Format__c;
                 objTask.Item_Code__c=oldMaterial.Item_Code__c;
                 objTask.Material_Number__c=oldMaterial.Material_Number__c;
                 if(fetchDataSet.get('Release__c')!=null && (Release__c)fetchDataSet.get('Release__c').get(oldMaterial.Release__c)!=null) {
                    objTask.Release_Name__c = ((Release__c)fetchDataSet.get('Release__c').get(oldMaterial.Release__c)).Name;
                 }
                 objTask.Street_Date__c = oldMaterial.Street_Date__c;//REL-155
                 objTask.Label_Code__c = oldMaterial.Label_Code__c;//REL-43 changes_6thNov
                 objTask.MaterialDescription_SmartSheet__c = oldMaterial.name;//REL-43 changes_6thNov
                
                 insertableDataSet.get('Task').add(objTask);
                 
                 if(oldMaterial.Material_Status__c != '' && statusToCheck.contains(oldMaterial.Material_Status__c))
                 {
                     releaseIds.add(oldMaterial.Release__c);
                 }
             }  
         }  
         
         if(releaseIds.size() > 0 && TriggerUtility.currentUser.Profile.Name != 'Platform API'){
             updateMaterialCounterOnStatus(releaseIds);
         }  
         
         //added code for RE-35
         if(deletedMatVMatList != null && deletedMatVMatList.size() > 0)
         {
             for(v_Material__c vMat : [SELECT Id FROM v_Material__c WHERE Id IN: deletedMatVMatList])
             {
                 vMat.Status__c = 'Inactive';
                 updateableDataSet.get('v_Material__c').put(vMat.Id, vMat);
             }
         }
 
         //perform DML
         commitDataSet();
     }
     
 
     /***********************************
     Method Name: assignWizardFormat
     Purpose:Following method assigns Wizard Format field based on Format Code.
     ***********************************/
     private static void assignWizardFormat(Material__c mat)
     {
         if(TriggerUtility.checkFromTemplate)
             return;
         
         // Assigning material type for components.
         if(mat.Material_Type__c == null && mat.Component_Type__c != null)
         {
             if(mat.Component_Type__c != null && Component_MaterialType_Mapping__c.getInstance(mat.Component_Type__c) != null &&
                Component_MaterialType_Mapping__c.getInstance(mat.Component_Type__c).Material_Type__c == 'Z009')
             {
                 mat.Material_Type__c = 'Z009';
             }
             else
             {
                 mat.Material_Type__c = 'ROH';
             }
         }
         
         if(mat.Material_Type__c == null)
             mat.Material_Type__c = 'FERT';
         
         // Populating Item Code from Component Type mapping for ROH and Z009.
         if(mat.Material_Type__c != null && (mat.Material_Type__c == 'ROH' || mat.Material_Type__c == 'Z009') && 
            mat.Component_Type__c != null && Component_ItemCode_Mapping__c.getInstance(mat.Component_Type__c) != null)
         {
             mat.Item_Type__c = 'C - Components';
             mat.Item_Code__c = Component_ItemCode_Mapping__c.getInstance(mat.Component_Type__c).Item_Code__c;
             mat.Xplant_Material_Status__c = 'AA';
         }
         else if(mat.Material_Type__c != null && mat.Material_Type__c == 'FERT')
         {
             mat.Create_Version__c = true;
         }
         
         if(mat.Format__c != null && mat.Format_Description__c == null && FormatCode_Format_Mapping__c.getInstance(mat.Format__c) != null)
         {
             mat.Format_Description__c = FormatCode_Format_Mapping__c.getInstance(mat.Format__c).Wizard_Format__c;
         }
     }
     
     /***********************************
     Method Name: validateNPopulateLabelCode
     Purpose:Following method validates if materials are having Label code or not. If it does not have, it attempts fill it with logic.
             If it cannot populate, throws error message.
     ***********************************/ 
     private static void validateNPopulateLabelCode(Material__c mat)
     {
         if(TriggerUtility.checkFromTemplate)
             return;
         
         if((mat.Label_Code__c == null || mat.Label_Code__c == '' || mat.Legal_Owner__c == null || mat.Legal_Owner__c == '') && mat.Title__c != null)
         {
             if(titleDealMap.containsKey(mat.Title__c) && titleDealMap.get(mat.Title__c) != null && titleDealMap.get(mat.Title__c).Legal_Owner__c != null)
             {
                 mat.Deal__c = titleDealMap.get(mat.Title__c).Id; //USST-2778
                 mat.Deal_ID__c = titleDealMap.get(mat.Title__c).Deal_ID__c; //USST-2728
                 mat.Legal_Owner__c = titleDealMap.get(mat.Title__c).Legal_Owner__c;
                 mat.Financial_Owner__c = titleDealMap.get(mat.Title__c).Financial_Owner__c;
             }
                 
             if(mat.Label_Code__c == null || mat.Label_Code__c == '')
             {
                 // Changed for REL-147
                 if(titleDealMap.containsKey(mat.Title__c) && titleDealMap.get(mat.Title__c) != null && 
                    titleDealMap.get(mat.Title__c).Origin_Code__c != null && originCodeLblCodeMap.containsKey(titleDealMap.get(mat.Title__c).Origin_Code__c) && originCodeLblCodeMap.get(titleDealMap.get(mat.Title__c).Origin_Code__c) != null) {
                    //USST-2728 --- start
                     if (originCodeLblCodeMap.get(titleDealMap.get(mat.Title__c).Origin_Code__c).Default_Deal_ID__c != null && originCodeLblCodeMap.get(titleDealMap.get(mat.Title__c).Origin_Code__c).Default_Deal_ID__c != '' && originCodeLblCodeMap.get(titleDealMap.get(mat.Title__c).Origin_Code__c).Default_Deal_ID__c == mat.Deal_ID__c) {
                         mat.Label_Code__c = originCodeLblCodeMap.get(titleDealMap.get(mat.Title__c).Origin_Code__c).Label_Code_2__c;
                     }
                     else {
                         mat.Label_Code__c = originCodeLblCodeMap.get(titleDealMap.get(mat.Title__c).Origin_Code__c).Label_Code__c;
                     }
                     //USST-2728 --- end
                 }
                 else if(titleDealMap.containsKey(mat.Title__c) && titleDealMap.get(mat.Title__c) != null && titleDealMap.get(mat.Title__c).Label_Code__c != null)
                     mat.Label_Code__c = titleDealMap.get(mat.Title__c).Label_Code__c;
                 else if(TriggerUtility.currentUser != null && TriggerUtility.currentUser.Label_Code__c != null)
                     mat.Label_Code__c = TriggerUtility.currentUser.Label_Code__c;
                 else if(!Test.isRunningTest())
                     mat.addError('Please provide Label Code in Material.');
             }           
         }
          else if((mat.Label_Code__c == null || mat.Label_Code__c == '') && mat.Title__c == null)
              {
                  mat.Label_Code__c = TriggerUtility.currentUser.Label_Code__c;
              }
     }
     
     /***********************************
     Method Name: updateLabelCode
     Purpose:Method to update Label Code
     ***********************************/
     public static void updateLabelCode(Material__c mat)
     {
         if(TriggerUtility.checkFromTemplate)    // Added for REL-147
             return;
     
         Deal__c parentdealRec;
         if(mat.Deal__c != null && fetchDataSet != null && fetchDataSet.get('Deal__c') != null)
             parentdealRec = (Deal__c) fetchDataSet.get('Deal__c').get(mat.Deal__c);
         SET<ID> pardealIds = new set<Id>();
         
         if((Trigger.isInsert || (Trigger.isUpdate && mat.Deal__c != ((Material__c)Trigger.oldMap.get(mat.Id)).Deal__c)) && mat.Deal__c != null)
         {
            
             Map<Id, Set<Id>> parentChildMap = new Map<Id, Set<Id>>();
             
             if(Trigger.isUpdate && matBomMap.get(mat.Id) != null && matBomMap.get(mat.Id).size() > 0)
             {
                 
                 for(BOM_Item__c bom : matBomMap.get(mat.Id))
                 {
                     if((bom.Material_Component__r.Material_Type__c ==  'ROH' || bom.Material_Component__r.Material_Type__c ==  'Z009') && (bom.Material_Component__r.Material_Status__c != 'Approved' && bom.Material_Component__r.Material_Status__c!= 'Processed in SAP' && bom.Material_Component__r.Component_Material__c==mat.id)){//REL-12 To check if the Original Parent is updated
                         if(!parentChildMap.containsKey(bom.Material__c))
                             parentChildMap.put(bom.Material__c, new Set<Id>());
                         parentChildMap.get(bom.Material__c).add(bom.Material_Component__c);
                     }                    
                 }
             }
            Map<Id, Material__c> updateableMaterialList = new Map<Id, Material__c>();
             
            if(mat.Deal__c != null && parentdealRec != null){
                 if (parentdealRec.Origin_Code__c == null) { // Changed for Deal
                    mat.addError('This Deal\'s Origin Code is not valid in the system. Please reach out to IT to resolve.');
                    return;
                }
                //USST-2728 --- start
                if (originCodeLblCodeMap.get(parentdealRec.Origin_Code__c) != null) {
                    if (originCodeLblCodeMap.get(parentdealRec.Origin_Code__c).Default_Deal_ID__c != null && originCodeLblCodeMap.get(parentdealRec.Origin_Code__c).Default_Deal_ID__c != '' && originCodeLblCodeMap.get(parentdealRec.Origin_Code__c).Default_Deal_ID__c == parentdealRec.Deal_ID__c) {
                        mat.Label_Code__c = originCodeLblCodeMap.get(parentdealRec.Origin_Code__c).Label_Code_2__c; // Changed for Deal
                    }
                    else {
                        mat.Label_Code__c = originCodeLblCodeMap.get(parentdealRec.Origin_Code__c).Label_Code__c; // Changed for Deal
                    }
                }
                //USST-2728 --- end
                
                if(originCodeSubLblCodeMap.containsKey(parentdealRec.Origin_Code__c) && mat.RecordTypeId != updateRecTypeId) //USST-2707
                    //USST-2728 --- start
                    if (originCodeSubLblCodeMap.get(parentdealRec.Origin_Code__c) != null) {
                        if (originCodeSubLblCodeMap.get(parentdealRec.Origin_Code__c).Default_Deal_ID__c != null && originCodeSubLblCodeMap.get(parentdealRec.Origin_Code__c).Default_Deal_ID__c != '' && originCodeSubLblCodeMap.get(parentdealRec.Origin_Code__c).Default_Deal_ID__c == parentdealRec.Deal_ID__c) {
                            mat.Sub_Label_Code_Lookup__c = originCodeSubLblCodeMap.get(parentdealRec.Origin_Code__c).Sub_Label_Code_2__c;   // Changed for Deal                     
                        }
                        else {
                            mat.Sub_Label_Code_Lookup__c = originCodeSubLblCodeMap.get(parentdealRec.Origin_Code__c).Sub_Label_Code__c;   // Changed for Deal                       
                        }
                    }
                    //USST-2728 --- end
                    
                else if(mat.RecordTypeId != updateRecTypeId) { //USST-2707
                    mat.Sub_Label_Code_Lookup__c = null;
                }
                    
                system.debug('legal owner populate');
                 mat.TM_Origin_Code__c = parentdealRec.Origin_Code__c;
                 mat.Legal_Owner__c = parentdealRec.Legal_Owner__c;
                 mat.Financial_Owner__c = parentdealRec.Financial_Owner__c;
                
                 if(parentChildMap.containsKey(mat.Id))
                 {
                     for(Id matId : parentChildMap.get(mat.Id))
                     {
                        Boolean childMatUpdated = false; // USST-2562
                         System.debug('****LblC> '+mat.Label_Code__c);
                         if(!updateableDataSet.containsKey('Material__c'))
                             updateableDataSet.put('Material__c', new Map<Id, SObject>());
                         
                         Material__c childMat;
                        if(!updateableDataSet.get('Material__c').containsKey(matId) )                           
                            childMat = new Material__c(Id=matId, Label_Code__c=mat.Label_Code__c, Sub_Label_Code_Lookup__c=mat.Sub_Label_Code_Lookup__c);  // Changed for Deal //USST-2884
                         else
                         {
                             childMat = (Material__c) updateableDataSet.get('Material__c').get(matId);
                            // USST-2562 - start
                            if(mat.Label_Code__c != childMat.Label_Code__c){ 
                                system.debug('165 enter');
                                childMat.Label_Code__c = mat.Label_Code__c;  // Changed for Deal
                                childMat.Sub_Label_Code_Lookup__c=mat.Sub_Label_Code_Lookup__c; //USST-2884
                                childMatUpdated = true;
                            }
                         }
                        System.debug('childMat-->'+childMat);
                        childMatLabelChangeMap.put(matId, childMat);
                        
                       // USST-2562 - end
                    }
                    
                 }
             }   
             
             if(mat.Label_Code__c == Null && TriggerUtility.currentUser != null){
                 mat.Label_Code__c = TriggerUtility.currentUser.Label_Code__c;
                 if(mat.Label_Code__c != null && lblCodeSubLblCodeIdMap.containsKey(mat.Label_Code__c) && subLblCodeMap.containsKey(lblCodeSubLblCodeIdMap.get(mat.Label_Code__c))&& mat.RecordTypeId != updateRecTypeId) //USST-2707
                     mat.Sub_Label_Code_Lookup__c = subLblCodeMap.get(lblCodeSubLblCodeIdMap.get(mat.Label_Code__c));
                 if(parentChildMap.containsKey(mat.Id))
                 {
                     for(Id matId : parentChildMap.get(mat.Id))
                     {
                        Boolean childMatUpdated = false; // USST-2562
                         if(!updateableDataSet.containsKey('Material__c'))
                             updateableDataSet.put('Material__c', new Map<Id, SObject>());
                         
                         Material__c childMat;
                        if(!updateableDataSet.get('Material__c').containsKey(matId)) {
                             childMat = new Material__c(Id=matId, Label_Code__c= parentdealRec.Label_Code__c);
                             childMatUpdated = true;
                        }
                         else
                         {
                             childMat = (Material__c) updateableDataSet.get('Material__c').get(matId);
                            // USST-2562 - start
                            if (childMat.Label_Code__c != null && childMat.Label_Code__c != '' && childMat.Label_Code__c != parentdealRec.Label_Code__c) {
                                childMat.Label_Code__c= parentdealRec.Label_Code__c;
                                childMatUpdated = true;
                            }
                         }
                        if (childMatUpdated) {
                            childMatLabelChangeMap.put(matId, childMat);
                        }
                        // USST-2562 - end
                     }
                 }
             }
             System.debug('updateableDataSet--->'+updateableDataSet.get('Material__c'));
         }
         else if(mat.Sub_Label_Code_Lookup__c == null) {
             
             if(mat.Label_Code__c != null && subLblCodeMap != null && lblCodeSubLblCodeIdMap != null && lblCodeSubLblCodeIdMap.containsKey(mat.Label_Code__c) && subLblCodeMap.containsKey(lblCodeSubLblCodeIdMap.get(mat.Label_Code__c))&& mat.RecordTypeId != updateRecTypeId){ //USST-2707
                 mat.Sub_Label_Code_Lookup__c =  subLblCodeMap.get(lblCodeSubLblCodeIdMap.get(mat.Label_Code__c));
             }
         }
     } 

     /***********************************
     Method Name: syncMaterialWithRelease
     Purpose:List of Plant, for which material will be associated.
     ***********************************/
     public static void syncMaterialWithRelease(Material__c mat)
     {
         Set<Id> relIds = new Set<Id>();
         Set<Id> dealIds = new Set<Id>();
         Set<Id> titleIds = new Set<Id>();
         
         if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
         {
             //Implemented STY-00579---
             if(mat.Material_Type__c =='FERT'){
                 mat.Type__c = 'Finished Good';
             }
             if(mat.Material_Type__c =='ROH' || mat.Material_Type__c =='Z009'){
                 mat.Type__c = 'Component';
             }
             //End STY-00579 --- 
             
             
             Release__c relMap;
             Deal__c dealMap;
         
             if(mat.Release__c != null){
                 relMap = (Release__c) fetchDataSet.get('Release__c').get(mat.Release__c);
             }
             
             if(mat.Deal__c != null){
                 dealMap = (Deal__c) fetchDataSet.get('Deal__c').get(mat.Deal__c);
             }
             
             
             // Update Deal id     
             if(mat.Item_Type__c != 'C - Components' && mat.Item_Type__c != 'M (Multipack)' && mat.Item_Type__c != 'D (Display Vehicle)' && TriggerUtility.checkFromUpdateMaterial == FALSE)
             {
                 if(TriggerUtility.currentUser != null){
                     if(mat.Release__c != null && relMap != null && relMap.Deal__c != null)
                     {
                        if(TriggerUtility.currentUser.UserRole.Name != 'G1200' && Trigger.isUpdate==false){//REL-126 shouldn't be called on update
                                System.debug('###Inside Sysnc release');
                                system.debug('legal owner populate');
                             mat.Deal__c = relMap.Deal__c;
                             mat.Legal_Owner__c = relMap.Deal__r.Legal_Owner__c;
                             mat.Financial_Owner__c = relMap.Deal__r.Financial_Owner__c;
                         }
                     }
                 }
                 
                 if(dealMap != null)
                 {
                     //Update Legal Owner  
                     if(dealMap != null && dealMap.Legal_Owner__c !=null) {
                         system.debug('legal owner populate');
                         mat.Legal_Owner__c = dealMap.Legal_Owner__c;
                     }
                     
                     //Update Legal Owner  
                     if(dealMap != null && dealMap.Financial_Owner__c !=null) 
                         mat.Financial_Owner__c = dealMap.Financial_Owner__c;
                     
                     //Update Origin Code  
                     if(dealMap != null && dealMap.Origin_Code__c !=null) 
                         mat.TM_Origin_Code__c = dealMap.Origin_Code__c;   
                 }
             }
         }
     }

     /***********************************
     Method Name: updateFunctionValue
     Purpose:Following method is responsible to update the Function Field value.
     ***********************************/
     public static void updateFunctionValue(Material__c mat)
     {
         if(!updateableDataSet.containsKey('Sales__c'))
             updateableDataSet.put('Sales__c', new Map<Id, SObject>());
         if(!updateableDataSet.containsKey('Plant__c'))
             updateableDataSet.put('Plant__c', new Map<Id, SObject>());
         if(!updateableDataSet.containsKey('Alternative_Unit_of_Measure__c'))
             updateableDataSet.put('Alternative_Unit_of_Measure__c', new Map<Id, SObject>());
         if(!updateableDataSet.containsKey('Valuation__c'))
             updateableDataSet.put('Valuation__c', new Map<Id, SObject>());
         
         if(Trigger.isBefore && Trigger.isInsert)
         {
             SObject instance = mat;
             instance.put('Function__c', '009');
             
             if((instance.get('BOM_Category__c') != null && String.valueOf(instance.get('BOM_Category__c')) != '') ||
                (instance.get('Plant__c') != null && String.valueOf(instance.get('Plant__c')) != '') ||
                (instance.get('BOM_Number__c') != null && String.valueOf(instance.get('BOM_Number__c')) != '') ||
                (instance.get('BOM_SAP_Status__c') != null && String.valueOf(instance.get('BOM_SAP_Status__c')) != '') ||
                (instance.get('BOM_Usage__c') != null && String.valueOf(instance.get('BOM_Usage__c')) != '') ||
                (instance.get('From_Lot_Size__c') != null && String.valueOf(instance.get('From_Lot_Size__c')) != '') ||
                (instance.get('BOM_Header_Text__c') != null && String.valueOf(instance.get('BOM_Header_Text__c')) != '') ||
                (instance.get('To_Lot_Size__c') != null && String.valueOf(instance.get('To_Lot_Size__c')) != '') ||
                (instance.get('BOM_Long_Text__c') != null && String.valueOf(instance.get('BOM_Long_Text__c')) != '') ||
                (instance.get('BOM_Deletion_Flag__c') != null && Boolean.valueOf(instance.get('BOM_Deletion_Flag__c'))) ||
                (instance.get('BOM_Quantity__c') != null) ||
                (instance.get('PIR_Created__c') != null && Boolean.valueOf(instance.get('PIR_Created__c'))) ||
                (instance.get('Alternative_BOM__c') != null && String.valueOf(instance.get('Alternative_BOM__c')) != '') ||
                (instance.get('Alternative_BOM_Text__c') != null && String.valueOf(instance.get('Alternative_BOM_Text__c')) != '') ||
                (instance.get('Valid_From__c') != null)
             )
             {
                 //instance.put('BOM_Function__c', '009');
             }
             Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
             if(instance.get('RecordTypeId') == recTypeId && instance.get('Deletion_Flag__c') == false)
             {
                 instance.put('Function__c', '004');
             }
         }
         else if(Trigger.isBefore && Trigger.isUpdate)
         {
             SObject newIns = mat;
             SObject oldIns = oldMat;
             Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
             if(newIns.get('RecordTypeId') == recTypeId && newIns.get('Deletion_Flag__c') == false)
             {
                 newIns.put('Function__c', '004');
             }
             // Check if deletion flag is checked.
             if(newIns.get('Deletion_Flag__c') != oldIns.get('Deletion_Flag__c') && Boolean.valueOf(newIns.get('Deletion_Flag__c')))
             {
                 newIns.put('Function__c', '003');
             }
             
             // Check if BOM Header is updated.
             if(newIns.get('BOM_Status__c') == 'Approved' && oldIns.get('BOM_Status__c')!='Processed in SAP' /*&& (oldIns.get('BOM_Number__c') == null || oldIns.get('BOM_Number__c') == '')*/) //Added bom number condition for USST-2622
             {          
                 newIns.put('BOM_Function__c', '009');
             }
             if(newIns.get('BOM_Status__c') == 'Processed in SAP')
             {
                newIns.put('BOM_Function__c', '023');
             }
             if(newIns.get('BOM_Status__c') == 'Processed in SAP'  && ((newIns.get('BOM_Category__c') != oldIns.get('BOM_Category__c')) ||
                (newIns.get('Plant__c') != oldIns.get('Plant__c')) ||
                (newIns.get('BOM_SAP_Status__c') != oldIns.get('BOM_SAP_Status__c')) ||
                (newIns.get('BOM_Usage__c') != oldIns.get('BOM_Usage__c')) ||
                (newIns.get('From_Lot_Size__c') != oldIns.get('From_Lot_Size__c')) ||
                (newIns.get('BOM_Header_Text__c') != oldIns.get('BOM_Header_Text__c')) ||
                (newIns.get('To_Lot_Size__c') != oldIns.get('To_Lot_Size__c')) ||
                (newIns.get('BOM_Long_Text__c') != oldIns.get('BOM_Long_Text__c')) ||
                (newIns.get('BOM_Deletion_Flag__c') != oldIns.get('BOM_Deletion_Flag__c')) ||
                (newIns.get('BOM_Quantity__c') != oldIns.get('BOM_Quantity__c')) ||
                (newIns.get('PIR_Created__c') != oldIns.get('PIR_Created__c')) ||
                (newIns.get('Alternative_BOM__c') != oldIns.get('Alternative_BOM__c')) ||
                (newIns.get('Alternative_BOM_Text__c') != oldIns.get('Alternative_BOM_Text__c')) ||
                (newIns.get('Valid_From__c') != oldIns.get('Valid_From__c')))
             )
             {
                 newIns.put('BOM_Function__c', '004');
             }
         }
         else if(Trigger.isAfter && Trigger.isUpdate)
         {
             List<Sales__c> updateableSalesList = new List<Sales__c>();
             List<Plant__c> updateablePlantList = new List<Plant__c>();
             List<Alternative_Unit_of_Measure__c> updateableAltMeasureList = new List<Alternative_Unit_of_Measure__c>();
             List<Valuation__c> updateableValuationList = new List<Valuation__c>();
             List<Sales__c> updateableSalesList1 = new List<Sales__c>();
             List<Plant__c> updateablePlantList1 = new List<Plant__c>();
             List<Alternative_Unit_of_Measure__c> updateableAltMeasureList1 = new List<Alternative_Unit_of_Measure__c>();
             List<Valuation__c> updateableValuationList1 = new List<Valuation__c>();
             
             Set<Id> updatedMatIds = new Set<Id>();
             Set<Id> updateChildObjsForaMatIds = new Set<Id>();
             Set<Id> deleteChildObjsForMatIds = new Set<Id>();
             
             SObject newIns = mat;
             SObject oldIns = oldMat;
             Material__c fetchedMaterial = (Material__c) fetchDataSet.get('Material__c').get(mat.Id);
             
             // Check if BOM Header is updated.
             if((newIns.get('BOM_Category__c') != oldIns.get('BOM_Category__c')) ||
                (newIns.get('Plant__c') != oldIns.get('Plant__c')) ||
                (newIns.get('BOM_Number__c') != oldIns.get('BOM_Number__c')) ||
                (newIns.get('BOM_SAP_Status__c') != oldIns.get('BOM_SAP_Status__c')) ||
                (newIns.get('BOM_Usage__c') != oldIns.get('BOM_Usage__c')) ||
                (newIns.get('From_Lot_Size__c') != oldIns.get('From_Lot_Size__c')) ||
                (newIns.get('BOM_Header_Text__c') != oldIns.get('BOM_Header_Text__c')) ||
                (newIns.get('To_Lot_Size__c') != oldIns.get('To_Lot_Size__c')) ||
                (newIns.get('BOM_Long_Text__c') != oldIns.get('BOM_Long_Text__c')) ||
                (newIns.get('BOM_Deletion_Flag__c') != oldIns.get('BOM_Deletion_Flag__c')) ||
                (newIns.get('BOM_Quantity__c') != oldIns.get('BOM_Quantity__c')) ||
                (newIns.get('PIR_Created__c') != oldIns.get('PIR_Created__c')) ||
                (newIns.get('Alternative_BOM__c') != oldIns.get('Alternative_BOM__c')) ||
                (newIns.get('Alternative_BOM_Text__c') != oldIns.get('Alternative_BOM_Text__c')) ||
                (newIns.get('Valid_From__c') != oldIns.get('Valid_From__c')))
             {
                 if(matBomMap.get(mat.Id) != null && matBomMap.get(mat.Id).size() > 0)
                 {
                     for(BOM_Item__c bom : matBomMap.get(mat.Id))
                     {
                         BOM_Item__c iBom;
                         if(!updateableDataSet.containsKey('BOM_Item__c'))
                             updateableDataSet.put('BOM_Item__c', new Map<Id, SObject>());
                         
                         if(!updateableDataSet.get('BOM_Item__c').containsKey(bom.Id))
                             iBom = new BOM_Item__c(Id=bom.Id, BOM_Function__c='004');
                         else
                         {
                             iBom = (BOM_Item__c) updateableDataSet.get('BOM_Item__c').get(bom.Id);
                             iBom.BOM_Function__c = '004';
                         }
                         updateableDataSet.get('BOM_Item__c').put(bom.Id, iBom);
                     }
                 }
             }
             
             // If record type is changed
             Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
             if(newIns.get('RecordTypeId') != oldIns.get('RecordTypeId') && newIns.get('RecordTypeId') == recTypeId)
             {
                 if(!updateableDataSet.containsKey('Sales__c'))
                     updateableDataSet.put('Sales__c', new Map<Id, SObject>());
                 if(!updateableDataSet.containsKey('Plant__c'))
                     updateableDataSet.put('Plant__c', new Map<Id, SObject>());
                 if(!updateableDataSet.containsKey('Alternative_Unit_of_Measure__c'))
                     updateableDataSet.put('Alternative_Unit_of_Measure__c', new Map<Id, SObject>());
                 if(!updateableDataSet.containsKey('Valuation__c'))
                     updateableDataSet.put('Valuation__c', new Map<Id, SObject>());
                 
                 // Fetching Sales records to update delete flag.
                 if(!fetchedMaterial.Sales__r.isEmpty())
                 {
                     for(Sales__c sales : fetchedMaterial.Sales__r)
                     {
                         Sales__c iSales;
                         if(!updateableDataSet.get('Sales__c').containsKey(sales.Id))
                             iSales = new Sales__c(Id=sales.Id, Function__c='004');
                         else
                         {
                             iSales = (Sales__c) updateableDataSet.get('Sales__c').get(sales.Id);
                             iSales.Function__c = '004';
                         }
                        if((fetchedMaterial.material_status__c != 'Processed in SAP') || (fetchedMaterial.material_status__c == 'Processed in SAP' && (TriggerUtility.currentUser.Profile.Name == 'Platform API' || TriggerUtility.currentUser.Profile.Name == 'System Administrator'))){  //USST-2846
                          updateableDataSet.get('Sales__c').put(sales.Id, iSales);
                        }
                     }
                 }
                 
                 // Fetching Plant records to update delete flag.
                 if(!fetchedMaterial.Plants__r.isEmpty())
                 {
                     for(Plant__c plant : fetchedMaterial.Plants__r)
                     {
                         Plant__c iPlant;
                         if(!updateableDataSet.get('Plant__c').containsKey(plant.Id))
                             iPlant = new Plant__c(Id=plant.Id, Function__c='004');
                         else
                         {
                             iPlant = (Plant__c) updateableDataSet.get('Plant__c').get(plant.Id);
                             iPlant.Function__c = '004';
                         }
                         updateableDataSet.get('Plant__c').put(plant.Id, iPlant);
                     }
                 }
                 
                 // Fetching Alternative unit of Measure records to update delete flag.
                 if(!fetchedMaterial.Alternative_Units_of_Measure__r.isEmpty())
                 {
                     for(Alternative_Unit_of_Measure__c alt : fetchedMaterial.Alternative_Units_of_Measure__r)
                     {
                         Alternative_Unit_of_Measure__c iAlt;
                         if(!updateableDataSet.get('Alternative_Unit_of_Measure__c').containsKey(alt.Id))
                             iAlt = new Alternative_Unit_of_Measure__c(Id=alt.Id, Function__c='004');
                         else
                         {
                             iAlt = (Alternative_Unit_of_Measure__c) updateableDataSet.get('Alternative_Unit_of_Measure__c').get(alt.Id);
                             iAlt.Function__c = '004';
                         }
                         updateableDataSet.get('Alternative_Unit_of_Measure__c').put(alt.Id, iAlt);
                     }
                 }
                 
                 // Fetching Valuation records to update delete flag.
                 if(!fetchedMaterial.Valuations__r.isEmpty())
                 {
                     for(Valuation__c val : fetchedMaterial.Valuations__r)
                     {
                         Valuation__c iVal;
                         if(!updateableDataSet.get('Valuation__c').containsKey(val.Id))
                             iVal = new Valuation__c(Id=val.Id, Function__c='004');
                         else
                         {
                             iVal = (Valuation__c) updateableDataSet.get('Valuation__c').get(val.Id);
                             iVal.Function__c = '004';
                         }
                         updateableDataSet.get('Valuation__c').put(val.Id, iVal);
                     }
                 }
             }
             
             if(newIns.get('Deletion_Flag__c') != oldIns.get('Deletion_Flag__c') && Boolean.valueOf(newIns.get('Deletion_Flag__c')))
             {
                 // Fetching Sales records to update delete flag.
                 if(!fetchedMaterial.Sales__r.isEmpty())
                 {
                     for(Sales__c sales : fetchedMaterial.Sales__r)
                     {
                         Sales__c iSales;
                         if(!updateableDataSet.get('Sales__c').containsKey(sales.Id))
                             iSales = new Sales__c(Id=sales.Id, Deletion_Flag__c=true);
                         else
                         {
                             iSales = (Sales__c) updateableDataSet.get('Sales__c').get(sales.Id);
                             iSales.Deletion_Flag__c = true;
                         }
                         if((fetchedMaterial.material_status__c != 'Processed in SAP') || (fetchedMaterial.material_status__c == 'Processed in SAP' && (TriggerUtility.currentUser.Profile.Name == 'Platform API' || TriggerUtility.currentUser.Profile.Name == 'System Administrator'))){ //USST-2846
                         updateableDataSet.get('Sales__c').put(sales.Id, iSales);
                         }
                     }
                 }
                 
                 // Fetching Plant records to update delete flag.
                 if(!fetchedMaterial.Plants__r.isEmpty())
                 {
                     for(Plant__c plant : fetchedMaterial.Plants__r)
                     {
                         Plant__c iPlant;
                         if(!updateableDataSet.get('Plant__c').containsKey(plant.Id))
                             iPlant = new Plant__c(Id=plant.Id, Deletion_Flag__c=true);
                         else
                         {
                             iPlant = (Plant__c) updateableDataSet.get('Plant__c').get(plant.Id);
                             iPlant.Deletion_Flag__c = true;
                         }
                         updateableDataSet.get('Plant__c').put(plant.Id, iPlant);
                     }
                 }
                 
                 // Fetching Alternative unit of Measure records to update delete flag.
                 if(!fetchedMaterial.Alternative_Units_of_Measure__r.isEmpty())
                 {
                     for(Alternative_Unit_of_Measure__c alt : fetchedMaterial.Alternative_Units_of_Measure__r)
                     {
                         Alternative_Unit_of_Measure__c iAlt;
                         if(!updateableDataSet.get('Alternative_Unit_of_Measure__c').containsKey(alt.Id))
                             iAlt = new Alternative_Unit_of_Measure__c(Id=alt.Id, Deletion_Flag__c=true);
                         else
                         {
                             iAlt = (Alternative_Unit_of_Measure__c) updateableDataSet.get('Alternative_Unit_of_Measure__c').get(alt.Id);
                             iAlt.Deletion_Flag__c = true;
                         }
                         updateableDataSet.get('Alternative_Unit_of_Measure__c').put(alt.Id, iAlt);
                     }
                 }
                 
                 // Fetching Valuation records to update delete flag.
                 if(!fetchedMaterial.Valuations__r.isEmpty())
                 {
                     for(Valuation__c val : fetchedMaterial.Valuations__r)
                     {
                         Valuation__c iVal;
                         if(!updateableDataSet.get('Valuation__c').containsKey(val.Id))
                             iVal = new Valuation__c(Id=val.Id, Deletion_Flag__c=true);
                         else
                         {
                             iVal = (Valuation__c) updateableDataSet.get('Valuation__c').get(val.Id);
                             iVal.Deletion_Flag__c = true;
                         }
                         updateableDataSet.get('Valuation__c').put(val.Id, iVal);
                     }
                 }
             }
         }
     }
     
     /***********************************
     Method Name: createClassificationRecord
     Purpose:Mathod to create Classification record 
     ***********************************/   
     public static void createClassificationRecord(Material__c mat)
     {
         Material__c each = (Material__c) fetchDataSet.get('Material__c').get(mat.Id);
         Id generalRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
         Id universalFinishedGoodRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('Universal Finished Good').getRecordTypeId();
         Id universalComponentId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('Universal Components').getRecordTypeId();
         Id updateRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
       
         if(each != null && each.RecordTypeId != updateRecordTypeId){
           
           if(!insertableDataSet.containsKey('Classification__c'))
               insertableDataSet.put('Classification__c', new List<SObject>());
           
           System.debug('####Asha - each.Material_Type__c'+each.Material_Type__c);
           Classification__c newUniversalFinishedGood = new Classification__c();
           Classification__c newUniversalComponents = new Classification__c();
           
           if(each.Title__c !=null){ 
               Classification__c newRecGeneral = new Classification__c();
               //Create Classification with Record Type = General
               newRecGeneral.RecordTypeId = generalRecordTypeId;
               newRecGeneral.Material__c = each.Id;
               if(each.Material_Type__c == 'FERT')
                   newRecGeneral.Packaging_Type_US__c = '03 - Snap Case';
               
             system.debug('=====GP run======'+each.Title__r.Genre_Primary__c+'===='+each.Title__r.Runtime_US__c);
             
               if(each.Territory__c == 'US' && each.Title__r.Genre_Primary__c != null){
                  newRecGeneral.Genre_US__c = each.Title__r.Genre_Primary__c;
               }    
               if(each.Title__r.Runtime_US__c!=null)
               newRecGeneral.Run_Time__c = each.Title__r.Runtime_US__c;
               
               if(each.Material_Type__c == 'FERT' && ((each.Item_Type__c == 'S (Single)' && each.Item_Code__c != 'BF - BABY FERT') || each.Item_Type__c == 'M (Multipack)') && 
                 each.Territory__c != null && each.Territory__c.contains('CDN') && LabelCode_Ignores_Regie__c.getInstance(each.Label_Code__c) == null)
                    newRecGeneral.Regie_Sticker_for_Canada__c = 'Y - Yes';
               
               insertableDataSet.get('Classification__c').add(newRecGeneral);
           } 
           //Create Classification with Record Type = Universal Finished Good
            newUniversalFinishedGood.RecordTypeId = universalFinishedGoodRecordTypeId;
            newUniversalFinishedGood.Material__c = each.Id;
            if(each.Label_Code__c!=null)
            newUniversalFinishedGood.Label_Code__c = each.Label_Code__c;
            if(each.Item_Type__c!=null)
            newUniversalFinishedGood.Item_Type__c = each.Item_Type__c;
            if(each.Item_Code__c!=null)
            newUniversalFinishedGood.Item_Code__c = each.Item_Code__c;
            if(each.Format__c!=null)
            newUniversalFinishedGood.Format__c = each.Format__c;
            if(each.Material_Type__c == 'FERT')
                newUniversalFinishedGood.Packaging_Type_US__c = '03 - Snap Case';
            if(each.Material_Type__c == 'FERT' && ((each.Item_Type__c == 'S (Single)' && each.Item_Code__c != 'BF - BABY FERT') || each.Item_Type__c == 'M (Multipack)') && each.Territory__c!=null &&
               each.Territory__c.contains('CDN') && LabelCode_Ignores_Regie__c.getInstance(each.Label_Code__c) == null)
                 newUniversalFinishedGood.Regie_Sticker_for_Canada__c = 'Y - Yes';
               
            insertableDataSet.get('Classification__c').add(newUniversalFinishedGood);
            
            if(each.Material_Type__c == 'ROH' || each.Material_Type__c == 'Z009'){
               
                newUniversalComponents.RecordTypeId =universalComponentId;
                newUniversalComponents.Material__c=each.id;
                if(each.Territory__c!=null && each.Territory__c!='US & CDN' ){
                    newUniversalComponents.Territory__c=each.Territory__c;
                }
                insertableDataSet.get('Classification__c').add(newUniversalComponents);
            }
       
         }
     }
         
     /***********************************
     Method Name: checkSpecialChars
     Purpose:STY-905 Method to check if BOM Long text contains special characters.
     ***********************************/   
     public static void checkSpecialChars(List<Material__c>matList,Boolean insertTrigger){
         
         if(TriggerUtility.checkFromTemplate)
             return;
         
         Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
         List<id>matids= new List<id>();
         if(!matList.isEmpty()){
         for(Material__c mat1: matList){
             
              if(mat1.recordtypeid==recTypeId && insertTrigger==true){
                  matids.add(mat1.id);
              }
              else if(mat1.BOM_Long_Text__c != null && insertTrigger==false ){
              
                 String bomTextRegEx=Label.SpecialCharacters_Regex;
                 Pattern MyPattern = Pattern.compile(bomTextRegEx);
                 Matcher MyMatcher = MyPattern.matcher(mat1.BOM_Long_Text__c);
                 Boolean result = MyMatcher.find();
                 if(result==true){
                     mat1.addError('You have entered an invalid character in BOM Long Text field (e.g., #, *, or |).Please correct and re-save.',false);
                 }
             }
         }
 
         if(!matids.isEmpty()){
             BOMLongTextHandler.deleteOldBOMLongText(matids);
             List<Material__c> parseMat = [Select id, BOM_Long_Text__c from Material__c where Id IN: MatIds];
             BOMLongTextHandler.parseLongText(parseMat);
         }
       }  
     }
     
     /***********************************
     Method Name: updateTMVersionG1200
     Purpose:Populate TM Version for G1200 Role 
     ***********************************/
     public static void updateTMVersionG1200(Material__c mat){
         if(TriggerUtility.currentUser != null && TriggerUtility.currentUser.UserRole.Name=='G1200' && TriggerUtility.currentUser.Label_Code__c=='89 - FUNIMATION' && !tmVersionList.isEmpty() && TriggerUtility.checkFromUpdateMaterial == false){
             mat.TM_Version_Lookup__c = tmVersionList[0].id;
         }        
     }
 
     /***********************************
     Method Name: updateDateFromRelease
     Purpose:updates dates from release
     ***********************************/
     public static void updateDateFromRelease(Material__c mat){

         
         if(!fetchDataSet.containsKey('Release__c') || mat.Release__c == null){
             return;         
         }
         
         Material__c eachMat = mat;

         
         if(eachMat != null && TriggerUtility.currentUser.Profile.Name != 'Platform API'){
         
             Release__c rel = (Release__c) fetchDataSet.get('Release__c').get(eachMat.release__c);
             if(rel == null)
                 return;
             
             Map<Id, Release__c> mapReleaseDetails = new Map<Id, Release__c>();
             mapReleaseDetails.put(rel.ID, rel);
         
             if(eachMat.release__c != null && mapReleaseDetails.containsKey(eachMat.release__c) && mapReleaseDetails.get(eachMat.release__c).First_Theatrical_Date__c != null && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                 eachMat.Theatrical_Release_Date__c = mapReleaseDetails.get(eachMat.release__c).First_Theatrical_Date__c;
             }
             if(eachMat.release__c != null && mapReleaseDetails.containsKey(eachMat.release__c) && mapReleaseDetails.get(eachMat.release__c).Internal_Announce_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                 eachMat.Internal_Announce_Date__c = mapReleaseDetails.get(eachMat.release__c).Internal_Announce_Date__c;
             }
             if(eachMat.release__c != null && mapReleaseDetails.containsKey(eachMat.release__c) && mapReleaseDetails.get(eachMat.release__c).Trade_Solicitation_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                 eachMat.Trade_Solicitation_Date__c = mapReleaseDetails.get(eachMat.release__c).Trade_Solicitation_Date__c;
             }
             
                        
             System.Debug('check format value '+ eachMat.Format__c);
            if(((Trigger.isInsert || Trigger.isUpdate ) && eachMat.Retailer_Rental__c != null && (eachMat.Retailer_Rental__c == '28R (28-DAY WINDOW RENTAL)' || eachMat.Retailer_Rental__c == 'XXR (WINDOWED RENTAL)')) || /*Adding ||isUpdate condition for USST-2436 */
                 (Trigger.isUpdate && eachMat.Retailer_Rental__c != null && ((Material__c)Trigger.OldMap.get(eachMat.ID)).Retailer_Rental__c != '28R (28-DAY WINDOW RENTAL)' && ((Material__c)Trigger.OldMap.get(eachMat.ID)).Retailer_Rental__c != 'XXR (WINDOWED RENTAL)'&& (eachMat.Retailer_Rental__c == '28R (28-DAY WINDOW RENTAL)' || eachMat.Retailer_Rental__c == 'XXR (WINDOWED RENTAL)'))){
                     system.debug('****************5 '+eachMat.Retailer_Rental__c);
                     system.debug('2315');
                 if(eachMat.release__c != null && mapReleaseDetails.containsKey(eachMat.release__c)){
                     if(mapReleaseDetails.get(eachMat.release__c).Windowed_Rental_Street_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                         eachMat.Street_Date__c = mapReleaseDetails.get(eachMat.release__c).Windowed_Rental_Street_Date__c;
                     }
                     else if(mapReleaseDetails.get(eachMat.release__c).Street_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                         eachMat.Street_Date__c = mapReleaseDetails.get(eachMat.release__c).Street_Date__c;
                     }
                     // Added the below piece of code for defect 2731 
                     if(mapReleaseDetails.get(eachMat.release__c).Windowed_Rental_Pre_Order_Close_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009'){
                         if(Trigger.isUpdate && eachMat.recordTypeId == updateRecTypeId && eachMat.Material_Status__c == 'Approved' && eachMat.Pre_Order_Close_Date__c != ((Material__c)Trigger.OldMap.get(eachMat.ID)).Pre_Order_Close_Date__c && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                             eachMat.Pre_Order_Close_Date__c = ((Material__c)Trigger.OldMap.get(eachMat.ID)).Pre_Order_Close_Date__c;
                             system.debug('***Pre_Order_Close_Date__c'+eachMat.Pre_Order_Close_Date__c);
                         }
                         else if(Trigger.isInsert && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                           eachMat.Pre_Order_Close_Date__c = mapReleaseDetails.get(eachMat.release__c).Windowed_Rental_Pre_Order_Close_Date__c;
                           system.debug('***Pre_Order_Close_Date__c'+eachMat.Pre_Order_Close_Date__c);
                         }
                     }
                     else if(mapReleaseDetails.get(eachMat.release__c).Pre_Order_Close_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                         eachMat.Pre_Order_Close_Date__c = mapReleaseDetails.get(eachMat.release__c).Pre_Order_Close_Date__c;
                         system.debug('**Pre_Order_Close_Date__c '+eachMat.Pre_Order_Close_Date__c);
                     }
                 }               
             }   
             else if (Trigger.isUpdate && eachMat.Retailer_Rental__c != null && (((Material__c)Trigger.OldMap.get(eachMat.ID)).Retailer_Rental__c == '28R (28-DAY WINDOW RENTAL)' || ((Material__c)Trigger.OldMap.get(eachMat.ID)).Retailer_Rental__c == 'XXR (WINDOWED RENTAL)') && (eachMat.Retailer_Rental__c != '28R (28-DAY WINDOW RENTAL)' && eachMat.Retailer_Rental__c != 'XXR (WINDOWED RENTAL)')){
                 system.debug('****************4 '+eachMat.Retailer_Rental__c);
                 if(eachMat.release__c != null && mapReleaseDetails.containsKey(eachMat.release__c)){
                     
                     if(eachMat.Format__c != null && (eachMat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || eachMat.Format__c == '14 - HD EST') && mapReleaseDetails.get(eachMat.release__c).EST_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                         eachMat.Street_Date__c = mapReleaseDetails.get(eachMat.release__c).EST_Date__c;
                     }
                     else if(eachMat.Format__c != null && (eachMat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || eachMat.Format__c == '14 - HD EST') && mapReleaseDetails.get(eachMat.release__c).EST_Date__c == null && mapReleaseDetails.get(eachMat.release__c).Street_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                         eachMat.Street_Date__c = mapReleaseDetails.get(eachMat.release__c).Street_Date__c;
                     }
                     else if(eachMat.Format__c != null && (eachMat.Format__c != '08 - EST (ELECTRONIC SELL THRU)' && eachMat.Format__c != '14 - HD EST') && mapReleaseDetails.get(eachMat.release__c).Street_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                         eachMat.Street_Date__c = mapReleaseDetails.get(eachMat.release__c).Street_Date__c;
                     }
                     
                     if(mapReleaseDetails.get(eachMat.release__c).Pre_Order_Close_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                         eachMat.Pre_Order_Close_Date__c = mapReleaseDetails.get(eachMat.release__c).Pre_Order_Close_Date__c;
                         system.debug('**Pre_Order_Close_Date__c '+eachMat.Pre_Order_Close_Date__c);
                     }
                 }               
             }   
             else if((Trigger.isInsert && eachMat.Format__c != null && (eachMat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || eachMat.Format__c == '14 - HD EST')) ||
                 
                 (Trigger.isUpdate && eachMat.Format__c != null && ((Material__c)Trigger.OldMap.get(eachMat.ID)).Format__c != '08 - EST (ELECTRONIC SELL THRU)' && ((Material__c)Trigger.OldMap.get(eachMat.ID)).Format__c != '14 - HD EST' && (eachMat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || eachMat.Format__c == '14 - HD EST'))){
              system.debug('**Pre_Order_Close_Date__c '+eachMat.Pre_Order_Close_Date__c);
              System.Debug('eachMat '+ eachMat); 
                    
                    
                 if(eachMat.release__c != null && mapReleaseDetails.containsKey(eachMat.release__c)) {
                 system.debug('I am checking here too ---');
                     if(mapReleaseDetails.get(eachMat.release__c).EST_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                         eachMat.Street_Date__c = mapReleaseDetails.get(eachMat.release__c).EST_Date__c;
                     }
                     else if(mapReleaseDetails.get(eachMat.release__c).Street_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                         eachMat.Street_Date__c = mapReleaseDetails.get(eachMat.release__c).Street_Date__c;
                     }
                     
                     if(mapReleaseDetails.get(eachMat.release__c).Pre_Order_Close_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                     // if(eachmat.recordTypeId != updateRecTypeId ){
                          eachMat.Pre_Order_Close_Date__c = mapReleaseDetails.get(eachMat.release__c).Pre_Order_Close_Date__c;
                          system.debug('**Pre_Order_Close_Date__c '+eachMat.Pre_Order_Close_Date__c);
                     // }
                         
                     }
                     
                     if((eachMat.Retailer_Rental__c == '28R (28-DAY WINDOW RENTAL)' || eachMat.Retailer_Rental__c == 'XXR (WINDOWED RENTAL)' ) && mapReleaseDetails.get(eachMat.release__c).Windowed_Rental_Street_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                         eachMat.Street_Date__c = mapReleaseDetails.get(eachMat.release__c).Windowed_Rental_Street_Date__c;
                     }
                     
                     if((eachMat.Retailer_Rental__c == '28R (28-DAY WINDOW RENTAL)' || eachMat.Retailer_Rental__c == 'XXR (WINDOWED RENTAL)') && mapReleaseDetails.get(eachMat.release__c).Windowed_Rental_Pre_Order_Close_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                     system.debug('I am checking here 2---'+system.now());
                         eachMat.Pre_Order_Close_Date__c = mapReleaseDetails.get(eachMat.release__c).Windowed_Rental_Pre_Order_Close_Date__c;
                         system.debug('**Pre_Order_Close_Date__c '+eachMat.Pre_Order_Close_Date__c);
                     }
                 }
             }    
             else if((Trigger.isInsert && eachMat.Format__c != null && (eachMat.Format__c != '08 - EST (ELECTRONIC SELL THRU)' && eachMat.Format__c != '14 - HD EST')) ||
                 (Trigger.isUpdate && eachMat.Format__c != null && (((Material__c)Trigger.OldMap.get(eachMat.ID)).Format__c == '08 - EST (ELECTRONIC SELL THRU)' || ((Material__c)Trigger.OldMap.get(eachMat.ID)).Format__c == '14 - HD EST') && (eachMat.Format__c != '08 - EST (ELECTRONIC SELL THRU)' && eachMat.Format__c != '14 - HD EST'))){
                    system.debug('****************2 '+eachMat.Retailer_Rental__c);
                 if(eachMat.release__c != null && mapReleaseDetails.containsKey(eachMat.release__c) && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false) { //USST-2856
                     eachMat.Street_Date__c = mapReleaseDetails.get(eachMat.release__c).Street_Date__c;
                 }
                 
                 if(eachMat.release__c!=null && mapReleaseDetails.get(eachMat.release__c).Pre_Order_Close_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                     eachMat.Pre_Order_Close_Date__c = mapReleaseDetails.get(eachMat.release__c).Pre_Order_Close_Date__c;
                     system.debug('**Pre_Order_Close_Date__c '+eachMat.Pre_Order_Close_Date__c);
                 }    
 
                 if(eachMat.Retailer_Rental__c != null && (eachMat.Retailer_Rental__c == '28R (28-DAY WINDOW RENTAL)' || eachMat.Retailer_Rental__c == 'XXR (WINDOWED RENTAL)') && mapReleaseDetails.get(eachMat.release__c).Windowed_Rental_Street_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                     eachMat.Street_Date__c = mapReleaseDetails.get(eachMat.release__c).Windowed_Rental_Street_Date__c;
                 }
                  
                 if(eachMat.Retailer_Rental__c != null && (eachMat.Retailer_Rental__c == '28R (28-DAY WINDOW RENTAL)' || eachMat.Retailer_Rental__c == 'XXR (WINDOWED RENTAL)') && mapReleaseDetails.get(eachMat.release__c).Windowed_Rental_Pre_Order_Close_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                 system.debug('I am checking here 3---'+system.now());
                     eachMat.Pre_Order_Close_Date__c = mapReleaseDetails.get(eachMat.release__c).Windowed_Rental_Pre_Order_Close_Date__c;
                     system.debug('***Pre_Order_Close_Date__c'+eachMat.Pre_Order_Close_Date__c);
                 }
             }
             else{ system.debug('****************1 '+eachMat.Retailer_Rental__c);      
                 if(eachMat.release__c != null && mapReleaseDetails.containsKey(eachMat.release__c) && mapReleaseDetails.get(eachMat.release__c).Street_Date__c != null &&  ((Trigger.isUpdate && ((Material__c)Trigger.OldMap.get(eachMat.ID)).Format__c != null && eachMat.Format__c == null) || (Trigger.isInsert && eachMat.Format__c == null)) && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                     eachMat.Street_Date__c = mapReleaseDetails.get(eachMat.release__c).Street_Date__c;
                     
                 }
                 
                 if(Trigger.isUpdate && eachMat.release__c != null && mapReleaseDetails.containsKey(eachMat.release__c) && eachmat.Retailer_Rental__c == null && ((Material__c)Trigger.OldMap.get(eachMat.ID)).Retailer_Rental__c != null && eachmat.Format__c != null){
                     if((eachMat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || eachMat.Format__c == '14 - HD EST') && mapReleaseDetails.get(eachMat.release__c).EST_Date__c  != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                     system.debug('I am checking here---12');
                         eachMat.Street_Date__c = mapReleaseDetails.get(eachMat.release__c).EST_Date__c;
                     }
                     else if (mapReleaseDetails.get(eachMat.release__c).Street_Date__c != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                         eachMat.Street_Date__c = mapReleaseDetails.get(eachMat.release__c).Street_Date__c;
                         system.debug('****************1 '+eachMat.Retailer_Rental__c); 
                     }
                 }
                 if(Trigger.isUpdate && eachMat.release__c != null && mapReleaseDetails.containsKey(eachMat.release__c)){
                   if((eachMat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || eachMat.Format__c == '14 - HD EST') && mapReleaseDetails.get(eachMat.release__c).EST_Date__c  != null && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && TriggerUtility.checkFromUpdateMaterial == false && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                         eachMat.Street_Date__c = mapReleaseDetails.get(eachMat.release__c).EST_Date__c;
                         system.debug('****************1 '+eachMat.Retailer_Rental__c); 
                     }
                 }
                 
                 if(eachMat.release__c != null && mapReleaseDetails.containsKey(eachMat.release__c) && mapReleaseDetails.get(eachMat.release__c).Pre_Order_Close_Date__c != null  && 
                    (Trigger.isInsert || (Trigger.isUpdate && eachMat.Street_Date__c != ((Material__c)Trigger.OldMap.get(eachMat.ID)).Street_Date__c)) && eachMat.Item_Code__c != 'BF - BABY FERT' && eachmat.Material_Type__c != 'ROH' && eachmat.Material_Type__c != 'Z009' && eachMat.Direct_Update_Request__c == false && eachMat.Deletion_Update_Request__c == false && eachMat.Request_For_Reactivation__c == false && eachMat.m2m5Update__c == false && eachMat.Mass_Update_Request__c == false){ //USST-2856
                     system.debug('I am checking here---13');
                     eachMat.Pre_Order_Close_Date__c = mapReleaseDetails.get(eachMat.release__c).Pre_Order_Close_Date__c;
                     system.debug('**Pre_Order_Close_Date__c '+eachMat.Pre_Order_Close_Date__c);
                 }       
             }
         }        
     }
 
     /***********************************
     Method Name: updateMaterialDate
     Purpose: Update Pre-order date and Original Release Date on material
     ***********************************/
     public static void updateMaterialDate(Material__c mat){       
        System.debug('mat::::::::::::::::::::::::::'+mat);
        
         Id updateRecordType = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
         if(TriggerUtility.checkFromTemplate)
             return;
         
         if(trigger.isInsert){
             if(TriggerUtility.currentUser != null && mat.Street_Date__c != null){
                 if(TriggerUtility.currentUser.Profile.Name !='Platform API' ){
                     mat.Pre_Order_Close_Date__c = mat.Street_Date__c - 42;
                     system.debug('********mat.Pre_Order_Close_Date__c'+mat.Pre_Order_Close_Date__c);
                     
                 }
                 if(mat.recordtypeid!=updateRecordType && mat.Retailer_Rental__c != '28R (28-DAY WINDOW RENTAL)' && mat.Retailer_Rental__c != 'XXR (WINDOWED RENTAL)' && mat.Format__c != '08 - EST (ELECTRONIC SELL THRU)' && mat.Format__c != '14 - HD EST' /* && mat.Street_Date__c >= Date.today()*/){ //USST-2436  , USST-2966
                     mat.Original_Release_Date__c = mat.Street_Date__c;
                     system.debug('mat.Original_Release_Date__c'+mat.Original_Release_Date__c);
                 }    
             } 
         }
         if(trigger.isUpdate){
           if(TriggerUtility.currentUser != null && mat.Street_Date__c != null && mat.Street_Date__c !=  ((Material__c)Trigger.OldMap.get(mat.id)).Street_Date__c){
                 if(TriggerUtility.currentUser.Profile.Name !='Platform API' ){
                    mat.Pre_Order_Close_Date__c = mat.Street_Date__c - 42;
                    system.debug('********mat.Pre_Order_Close_Date__c'+mat.Pre_Order_Close_Date__c);
                     if(mat.recordtypeid!=updateRecordType && ((mat.Retailer_Rental__c != '28R (28-DAY WINDOW RENTAL)' && mat.Retailer_Rental__c != 'XXR (WINDOWED RENTAL)') || (mat.Format__c != '08 - EST (ELECTRONIC SELL THRU)' && mat.Format__c != '14 - HD EST'))){ //USST-2436
                        mat.Original_Release_Date__c = mat.Street_Date__c;
                        system.debug('mat.Original_Release_Date__c'+mat.Original_Release_Date__c);
                     }
                   }
                 if(mat.recordtypeid!=updateRecordType && ((Material__c)Trigger.OldMap.get(mat.id)).Original_Release_Date__c != null &&
                    ((Material__c)Trigger.OldMap.get(mat.id)).Original_Release_Date__c >= Date.today() &&((mat.Retailer_Rental__c != '28R (28-DAY WINDOW RENTAL)' && mat.Retailer_Rental__c != 'XXR (WINDOWED RENTAL)') || (mat.Format__c != '08 - EST (ELECTRONIC SELL THRU)' && mat.Format__c != '14 - HD EST')) ){ //USST-2436
                     mat.Original_Release_Date__c = mat.Street_Date__c;
                     system.debug('mat.Original_Release_Date__c'+mat.Original_Release_Date__c);
               } 
                //USST-2492
               if(((Material__c)Trigger.OldMap.get(mat.id)).Street_Date__c != null && ((Material__c)Trigger.OldMap.get(mat.id)).Street_Date__c > Date.today() &&
                    ((Material__c)Trigger.newMap.get(mat.id)).Street_Date__c > ((Material__c)Trigger.OldMap.get(mat.id)).Street_Date__c )
                {
                    if (((mat.Retailer_Rental__c != '28R (28-DAY WINDOW RENTAL)' && mat.Retailer_Rental__c != 'XXR (WINDOWED RENTAL)') || (mat.Format__c != '08 - EST (ELECTRONIC SELL THRU)' && mat.Format__c != '14 - HD EST'))) { //USST-2436
                        mat.Original_Release_Date__c = mat.Street_Date__c;
                        system.debug('mat.Original_Release_Date__c'+mat.Original_Release_Date__c);
                    }
                } 
             } 
         }        
     }   
     
     /************************************************************
     Method Name: updateRecordTypeFilter
     Purpose: To update the record type filter based on record type
     **************************************************************/
     public static void updateRecordTypeFilter(Material__c mat){ 
     
         if(TriggerUtility.checkFromTemplate)
             return;
         
         if(mat.recordTypeId == reqRecTypeId){
             mat.Record_Type_Filter__c = 'Request';
         }
         else if(mat.recordTypeId == matRecTypeId){
             mat.Record_Type_Filter__c = 'Material';
         }
         if(mat.recordTypeId == updateRecTypeId){
             mat.Record_Type_Filter__c = 'Update';
         }      
     }
     
     /***********************************
     Method Name: createReleaseMaterial
     Purpose:This method is responsible to create Release Material once Release is provided or changed.
     ***********************************/
     public static void createReleaseMaterial(Material__c mat)
     {        
         if(!insertableDataSet.containsKey('Release_Material__c'))
             insertableDataSet.put('Release_Material__c', new List<SObject>());
         
         if(Trigger.isAfter && Trigger.isInsert)
         {
             if(mat.Release__c != null && mat.RecordTypeId != updateRecTypeId) 
             {
                 Release_Material__c  relMat = new Release_Material__c();
                 relMat.Material__c = mat.Id;
                 relMat.Release__c = mat.Release__c;
                 System.debug('insertableDataSet:'+insertableDataSet);
                 insertableDataSet.get('Release_Material__c').add(relMat);
                 
                 System.Debug('count @@@@');
             }
         }
         else if(Trigger.isAfter && Trigger.isUpdate)
         {
             if(mat.Release__c != oldMat.Release__c && mat.Release__c != null && mat.RecordTypeId != updateRecTypeId)
             {
                 Release_Material__c  relMat = new Release_Material__c();
                 relMat.Material__c = mat.Id;
                 relMat.Release__c = mat.Release__c;
                 
                 insertableDataSet.get('Release_Material__c').add(relMat);
             }
         }
         
     }
     
     /***********************************
     Method Name: updatePreOrderDatefromMaterial
     Purpose:Mathod to update Pre Order Date when Material Format Description changed
     ***********************************/ 
     public static void updatePreOrderDatefromMaterial(Material__c mat){
         
         if(TriggerUtility.currentUser.Name == 'API User' || mat.Format_Description__c == null)
             return;
         system.debug('******1893> '+mat+' :: '+fetchDataSet);
         Material__c eachMat = (Material__c) fetchDataSet.get('Material__c').get(mat.Id); 
         
         if(eachMat != null)
         { 
             if(!updateableDataSet.containsKey('Sales__c'))
                 updateableDataSet.put('Sales__c', new Map<Id, SObject>());
                 
             for(Sales__c eachSales : eachMat.Sales__r){
                 if(!updateableDataSet.get('Sales__c').containsKey(eachSales.Id)){
                     
                     // Added for RE-17
                     Boolean hasChanged = false;
                     if(eachMat.Internal_Announce_Date__c!=null && eachMat.Internal_Announce_Date__c != ((Material__c)trigger.oldMap.get(eachMat.id)).Internal_Announce_Date__c){
                         eachSales.Announcement_Date_US__c = eachMat.Internal_Announce_Date__c ;
                         hasChanged = true; // Added for RE-17
                     }
                     if(eachMat.Theatrical_Release_Date__c!=null  && eachMat.Theatrical_Release_Date__c != ((Material__c)trigger.oldMap.get(eachMat.id)).Theatrical_Release_Date__c){
                         eachSales.Theatrical_Release_Date__c = eachMat.Theatrical_Release_Date__c ;
                         hasChanged = true; // Added for RE-17 
                     } 
                     if(eachMat.Trade_Solicitation_Date__c!=null && eachMat.Trade_Solicitation_Date__c != ((Material__c)trigger.oldMap.get(eachMat.id)).Trade_Solicitation_Date__c){
                         eachSales.Solicitation_Date__c = eachMat.Trade_Solicitation_Date__c ; 
                         hasChanged = true; // Added for RE-17 
                     }
                     if(eachMat.Original_Release_Date__c!=null && eachMat.Original_Release_Date__c != ((Material__c)trigger.oldMap.get(eachMat.id)).Original_Release_Date__c){
                         eachSales.Original_Release_Date__c = eachMat.Original_Release_Date__c ;
                         hasChanged = true; // Added for RE-17
                     }
                     if(eachMat.Street_Date__c != null && eachMat.Street_Date__c != ((Material__c)trigger.oldMap.get(eachMat.id)).Street_Date__c){
                         eachSales.Street_Date__c = eachMat.Street_Date__c;
                         hasChanged = true; // Added for RE-17
                     }
                     if(eachMat.Pre_Order_Close_Date__c!= null && eachMat.Pre_Order_Close_Date__c != ((Material__c)trigger.oldMap.get(eachMat.id)).Pre_Order_Close_Date__c) {
                         eachSales.Pre_Order_Date__c= eachMat.Pre_Order_Close_Date__c;
                         hasChanged = true; // Added for RE-17
                     }   
                     
                     if(hasChanged){ // Added for RE-17
                        if((eachMat.material_status__c != 'Processed in SAP') || (eachMat.material_status__c == 'Processed in SAP' && (TriggerUtility.currentUser.Profile.Name == 'Platform API' || TriggerUtility.currentUser.Profile.Name == 'System Administrator'))){ //USST-2846
                         updateableDataSet.get('Sales__c').put(eachSales.Id, eachSales);
                        }
                     }  
                 }
             } 
         }
     }
     
     /***********************************
     Method Name: updateBomItemMaterialNumberReference
     Purpose:Mathod to update component number on bom item if its changed on component material
     ***********************************/
     public static void updateBomItemMaterialNumberReference(Material__c mat)
     {
         //in after update trigger context, if there is no change on material number and street date then just return the control
         if(Trigger.isAfter && Trigger.isUpdate && mat.Material_Number__c == oldMat.Material_Number__c && mat.Street_Date__c == oldMat.Street_Date__c){
             return;
         }
         
         map<id,Material__c> parentMatRec = new map<id,Material__c>();
        
         SET<ID> parMatIds = parentMatRec.keyset();
         if(mat.Street_Date__c == null || !fetchDataSet.get('Material__c').containsKey(mat.Id))
             return;
         
         if(!updateableDataSet.containsKey('BOM_Item__c'))
             updateableDataSet.put('BOM_Item__c', new Map<Id, SObject>());
         
         for(BOM_Item__c bom : ((Material__c) fetchDataSet.get('Material__c').get(mat.Id)).BOM_Items1__r)
         {               
             if(bom.Material_Component__c != null){
                 BOM_Item__c iBom;
                 if(!updateableDataSet.get('BOM_Item__c').containsKey(bom.Id))
                     iBom = new BOM_Item__c(Id=bom.Id, Component_Number__c=mat.Material_Number__c);
                 else
                 {
                     iBom = (BOM_Item__c) updateableDataSet.get('BOM_Item__c').get(bom.Id);
                     iBom.Component_Number__c = mat.Material_Number__c;
                 }
                 updateableDataSet.get('BOM_Item__c').put(bom.Id, iBom);
             }
         }         
     }
     
     /***********************************
     Method Name: updateTMVonRelease
     Purpose:Update TM Version for Release if TM Version is null and TM Version is present on Material
     ***********************************/
     public static void updateTMVonRelease(Material__c mat){
     
         if(TriggerUtility.checkFromTemplate)
             return;
         
         if(mat.TM_version__c == null || mat.Release__c == null){
             return;
         }
         
         Release__c rel = (Release__c) fetchDataSet.get('Release__c').get(mat.Release__c);
         if(rel != null) {
             if(!updateableDataSet.containsKey('Release__c'))
                 updateableDataSet.put('Release__c', new Map<Id, SObject>());
             
             if(rel.TM_Version__c == null){
                 Release__c iRel;
                 if(!updateableDataSet.get('Release__c').containsKey(rel.Id))
                     iRel = new Release__c(Id=rel.Id, TM_Version__c=mat.TM_version__c);
                 else
                 {
                     iRel = (Release__c) updateableDataSet.get('Release__c').get(rel.Id);
                     iRel.TM_Version__c = mat.TM_version__c;
                 }
                 updateableDataSet.get('Release__c').put(rel.Id, iRel);
             }
         }
     }
     
     /***********************************
     Method Name: plantUpdateForPhantomTrays
     Purpose:Update Plant records for Phantom Trays.
     ***********************************/
     public static void plantUpdateForPhantomTrays(Material__c mat){
         
         Material__c cMat = (Material__c) fetchDataSet.get('Material__c').get(mat.Id);
            
         if(cMat != null){
             if(!updateableDataSet.containsKey('Plant__c'))
                 updateableDataSet.put('Plant__c', new Map<Id, SObject>());
             
             for(Plant__c p : cMat.Plants__r){
                 if(cMat.Item_Type__c == 'D (Display Vehicle)' && cMat.Item_Code__c == 'FT - PHANTOM TRAY' && cMat.Material_Type__c == 'FERT' && p.Special_Procurement__c!='50 - Phantom assembly'){
                     Plant__c iPlant;
                     if(!updateableDataSet.get('Plant__c').containsKey(p.Id))
                         iPlant = new Plant__c(Id=p.Id, Special_Procurement__c='50 - Phantom assembly');
                     else
                     {
                         iPlant = (Plant__c) updateableDataSet.get('Plant__c').get(p.Id);
                         iPlant.Special_Procurement__c = '50 - Phantom assembly';
                     }
                     updateableDataSet.get('Plant__c').put(p.Id, iPlant);
                 }
             }
         }
     }
     
     /***********************************
     Method Name: updateSalesfromMaterial
     Purpose:updates Sales record from Material
     ***********************************/
     public static void updateSalesfromMaterial(Material__c mat){
         
         if(TriggerUtility.checkFromTemplate)
             return;
         
         if(TriggerUtility.currentUser.Name == 'API User')
             return;
         
         Material__c matl = (Material__c) fetchDataSet.get('Material__c').get(mat.Id);
         if(matl != null) {
             if(!updateableDataSet.containsKey('Sales__c'))
                 updateableDataSet.put('Sales__c', new Map<Id, SObject>());
             
             for(Sales__c s : matl.Sales__r){
                 Sales__c iSales;
                 if(!updateableDataSet.get('Sales__c').containsKey(s.Id))
                     iSales = new Sales__c(Id=s.Id);
                 else
                 {
                     iSales = (Sales__c) updateableDataSet.get('Sales__c').get(s.Id);
                 }
                 
                 iSales.Street_Date__c = matl.Street_Date__c;
                 iSales.Theatrical_Release_Date__c = matl.Theatrical_Release_Date__c;
                 iSales.Windowed_Rental_Pre_Order_Close_Date__c = matl.Windowed_Rental_Pre_Order_Close_Date__c;
                 iSales.Windowed_Rental_Street_Date__c = matl.Windowed_Rental_Street_Date__c;
                 iSales.VOD_Street_Date__c = matl.VOD_Street_Date__c;
                 iSales.Internal_Announce_Date__c = matl.Internal_Announce_Date__c;
                 iSales.Solicitation_Date__c = matl.Trade_Solicitation_Date__c;
                 iSales.In_Plant_Date__c = matl.In_Plant_Date__c;
                 iSales.Pre_Order_Date__c = matl.Pre_Order_Close_Date__c;
                 iSales.EST_Date__c = matl.EST_Date__c;
                 
                 if((matl.material_status__c != 'Processed in SAP') || (matl.material_status__c == 'Processed in SAP' && (TriggerUtility.currentUser.Profile.Name == 'Platform API' || TriggerUtility.currentUser.Profile.Name == 'System Administrator'))){ //USST-2846
                 updateableDataSet.get('Sales__c').put(s.Id, iSales);
                 }
             }
         }
     }
     
     /***********************************
     Method Name: updateMaterialCounterOnStatus
     Purpose:this method is responsible to update Release with its child material count.
     ***********************************/
     public static void updateMaterialCounterOnStatus(Set<Id> relIds)
     {
         if(TriggerUtility.checkFromTemplate)
             return;
         
         if(!updateableDataSet.containsKey('Release__c'))
             updateableDataSet.put('Release__c', new Map<Id, SObject>());
         
         for(Id relId : relIds)
         {
             System.debug('fetchDataSetInside'+fetchDataSet);
             Release__c rel = (Release__c) fetchDataSet.get('Release__c').get(relId);
             if(rel != null)
             {
                 Release__c relIns;
                 if(!updateableDataSet.get('Release__c').containsKey(rel.Id))
                     relIns = new Release__c(Id=rel.Id); 
                 else
                 {
                     relIns = (Release__c) updateableDataSet.get('Release__c').get(rel.Id);
                 }
                 
                 Integer countMats = 0;
                 for(Material__c iMat : rel.Materials__r)
                 {
                     if(statusToCheck.contains(iMat.Material_Status__c))
                         countMats ++;
                 }
                 relIns.Material_Counter__c = countMats;
                 
                 updateableDataSet.get('Release__c').put(rel.Id, relIns);
             }
         }
     }
     
     /*********************************************************************
     Method Name: updatePhantomTrayDates
     Purpose: To update the dates from Joint Corrugate to Phantom Tray
     **********************************************************************/
      public static void updatePhanatomTrayDates(Material__c mat){
         set<id> matId = new set<id>();
         if(TriggerUtility.checkFromCloning || TriggerUtility.CheckFromTemplate)
             return;
         
         Material__c fMat = (Material__c) fetchDataSet.get('Material__c').get(mat.Id);
         if(fMat != null){
             if(!updateableDataSet.containsKey('Material__c'))
                 updateableDataSet.put('Material__c', new Map<Id, SOBject>());
             if(matBomMap.get(mat.Id) != null && matBomMap.get(mat.Id).size() > 0)
             {
                 for(BOM_Item__c b : matBomMap.get(mat.Id)){
                     if(b.Material_Component__r.Item_Type__c == 'D (Display Vehicle)' && b.Material_Component__r.Item_Code__c == 'FT - PHANTOM TRAY' && b.Material_Component__r.Material_Type__c == 'FERT'){
                         if((Trigger.isInsert || (Trigger.isUpdate && mat.Street_Date__c != oldMat.Street_Date__c))){
                             Material__c iMat;
                             if(!updateableDataSet.get('Material__c').containsKey(b.Material_Component__c))
                                 iMat = new Material__c(Id=b.Material_Component__c);
                             else
                             {
                                 iMat = (Material__c) updateableDataSet.get('Material__c').get(b.Material_Component__c);
                             }
                             iMat.Street_Date__c = mat.Street_Date__c;
                             iMat.Pre_Order_Close_Date__c = mat.Pre_Order_Close_Date__c;
                             system.debug('**Pre_Order_Close_Date__c '+iMat.Pre_Order_Close_Date__c);
                             iMat.Original_Release_Date__c = mat.Original_Release_Date__c;
                             updateableDataSet.get('Material__c').put(b.Material_Component__c, iMat);
                             matId.add(iMat.id);
                         }
                     }
                 }
                 List<Sales__c> salesList = new List<Sales__c>();
                 // Changed for 101 Error
                 if (matId.size() > 0) {
                     for (Id childMatId : matId) {
                        Material__c ftMat = (Material__c) fetchDataSet.get('Material__c').get(childMatId);
                        if(updateableDataSet.get('Material__c').get(ftMat.Id) != null)
                        {
                             Material__c ftMat2 = (Material__c) updateableDataSet.get('Material__c').get(ftMat.Id);
                             for(Sales__c sales : ftMat.Sales__r)
                             {
                                 sales.Street_Date__c = ftMat2.Street_Date__c;
                                 sales.Pre_Order_Date__c = ftMat2.Pre_Order_Close_Date__c;
                                 sales.Original_Release_Date__c = ftMat2.Original_Release_Date__c;
                                 salesList.add(sales);
                             }
                        }
                     }
                     if(salesList.size() > 0) {
                        update salesList;
                     }
                 }
             }
         }   
     }

     
     public static Boolean executeForTest = FALSE;
     public static Map<Id, Material__c> testOldMatsMap;
     public static Map<Id, Material__c> testNewMatsMap;
     public static Set<Id> testMatIds;
     
     /***********************************
     Method Name: updateStatusOnIntegrationState
     Purpose:Following method is responsible to change Material status according to Integration State updated by TIBCO
     ***********************************/
     public static void updateStatusOnIntegrationState()
     {
         Set<Id> processedMatIds = new Set<Id>();
         
         if((Test.isRunningTest() && executeForTest) || (Trigger.isBefore && Trigger.isUpdate))
         {
             Set<Id> processingMatIds;
             
             System.debug('###updateStatusOnIntegrationState'+Trigger.isBefore+'##'+Trigger.isUpdate);
             if(Test.isRunningTest() && executeForTest)
                 processingMatIds = testMatIds;
             else
                 processingMatIds = Trigger.NewMap.keySet();
             
             for(Id recId : processingMatIds)
             {
                 Material__c newIns;
                 Material__c oldIns;
                 
                 if(Test.isRunningTest() && executeForTest )
                 {
                     newIns = testNewMatsMap.get(recId);
                     oldIns = testOldMatsMap.get(recId);
                 }
                 else
                 {
                     newIns = (Material__c) Trigger.NewMap.get(recId);
                     oldIns = (Material__c) Trigger.OldMap.get(recId);
                 }
                 
                  if(newIns.Material_Status__c != oldIns.Material_Status__c && ((newIns.Material_Status__c == 'Approved' && newIns.item_type__c=='S (Single)' && newIns.Deal_ID__c!=null && newIns.Title_Source__c!=null && newIns.Product_class__c!=null && newIns.TM_Version_Lookup__c != null)||
                 (newIns.Material_Status__c == 'Approved' && newIns.item_type__c=='M (Multipack)' && newIns.Title_Source__c!=null && newIns.Product_class__c!=null) || (newIns.Material_Status__c == 'Approved' && newIns.item_type__c=='D (Display Vehicle)') || (newIns.Material_Status__c == 'Approved' && (newIns.Material_Type__c == 'ROH' || newIns.Material_Type__c == 'Z009'))))
                 {
                     newIns.Material_Integration_State__c = 'N';
                 }
                 else if(newIns.Material_Integration_State__c != oldIns.Material_Integration_State__c)
                 {
                     if(newIns.Material_Integration_State__c == 'P')
                      {
                         Id materialRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
                         Id materialRequestRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();
                         if(oldIns.RecordTypeId == materialRequestRecordTypeId){
                             newIns.RecordTypeId = materialRecordTypeId;
                         }
                         newIns.Material_Status__c = 'Sent to SAP';
                     }
                     else if(newIns.Material_Integration_State__c == 'S')
                     {
                         newIns.Material_Status__c = 'Processed in SAP';
                         processedMatIds.add(recId);
                     }
                     else if(newIns.Material_Integration_State__c == 'E')
                     {
                         newIns.Material_Status__c = 'SAP Error';
                     }
                 }
                 
                 if(newIns.BOM_Status__c != oldIns.BOM_Status__c && newIns.BOM_Status__c == 'Approved')
                 {
                     newIns.BOM_Integration_State__c = 'N';
                 }
                 else if(newIns.BOM_Integration_State__c != oldIns.BOM_Integration_State__c)
                 {
                     if(newIns.BOM_Integration_State__c == 'P')
                     {
                         Id materialRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
                         Id materialRequestRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Request').getRecordTypeId();
                         if(oldIns.RecordTypeId == materialRequestRecordTypeId){
                             newIns.RecordTypeId = materialRecordTypeId;
                         }    
                         newIns.BOM_Status__c = 'Sent to SAP';
                     }
                     else if(newIns.BOM_Integration_State__c == 'S')
                     {
                         system.debug('2622-0614 :: '+newIns.BOM_Integration_State__c);
                         newIns.BOM_Status__c = 'Processed in SAP';
                     }
                     else if(newIns.BOM_Integration_State__c == 'E')
                     {
                         newIns.BOM_Status__c = 'SAP Error';
                     }
                 } 
             }
             
             // Update all child views' function to 023 where material's status is Processed in SAP
             if(processedMatIds.size() > 0)
             {
                 List<Sales__c> updateableSalesList = new List<Sales__c>();
                 List<Plant__c> updateablePlantList = new List<Plant__c>();
                 List<Classification__c> updateableClassList = new List<Classification__c>();
                 List<Alternative_Unit_of_Measure__c> updateableAUoMList = new List<Alternative_Unit_of_Measure__c>();
                 List<Valuation__c> updateableValuationList = new List<Valuation__c>();
                 Id classficationRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
                 
                 for(Material__c mat1 : [SELECT Id, 
                                        (SELECT Id FROM Sales__r WHERE Deletion_Flag__c=FALSE),
                                        (SELECT Id FROM Plants__r WHERE Deletion_Flag__c=FALSE),
                                        (SELECT Id FROM Classifications__r WHERE Deletion_Flag__c=FALSE AND RecordTypeId=:classficationRecordTypeId),
                                        (SELECT Id FROM Alternative_Units_of_Measure__r WHERE Deletion_Flag__c=FALSE),
                                        (SELECT Id FROM Valuations__r WHERE Deletion_Flag__c=FALSE)
                                        FROM Material__c
                                        WHERE Id IN :processedMatIds])
                 {
                     if(mat1.Sales__r != null && mat1.Sales__r.size() > 0 )
                     {
                         for(Sales__c sales : mat1.Sales__r)
                         {
                             sales.Function__c = '023';
                             updateableSalesList.add(sales);
                         }
                     }
                     
                     if(mat1.Plants__r != null && mat1.Plants__r.size() > 0)
                     {
                         for(Plant__c plant : mat1.Plants__r)
                         {
                             plant.Function__c = '023';
                             updateablePlantList.add(plant);
                         }
                     }
                     
                     if(mat1.Classifications__r != null && mat1.Classifications__r.size() > 0)
                     {
                         for(Classification__c cls : mat1.Classifications__r)
                         {
                             cls.Function__c = '023';
                             updateableClassList.add(cls);
                         }
                     }
                     
                     if(mat1.Alternative_Units_of_Measure__r != null && mat1.Alternative_Units_of_Measure__r.size() > 0)
                     {
                         for(Alternative_Unit_of_Measure__c auom : mat1.Alternative_Units_of_Measure__r)
                         {
                             auom.Function__c = '023';
                             updateableAUoMList.add(auom);
                         }
                     }
                     
                     if(mat1.Valuations__r != null && mat1.Valuations__r.size() > 0)
                     {
                         for(Valuation__c val : mat1.Valuations__r)
                         {
                             val.Function__c = '023';
                             updateableValuationList.add(val);
                         }
                     }
                 }
                 
                 TriggerUtility.initiatedFromMaterial = TRUE;
                 if(updateableSalesList.size() > 0){
                     TriggerUtility.doNotExecute = TRUE;
                     update updateableSalesList;
                     TriggerUtility.doNotExecute = FALSE;
                 }
                 if(updateablePlantList.size() > 0)
                     update updateablePlantList;
                 try {
                     System.debug('******updateableClassList> '+updateableClassList);
                     if(updateableClassList.size() > 0)
                     {
                         Database.update(updateableClassList, false);
                     }
                 } 
                 catch(Exception ex) {
                     System.debug('*******clsEx> '+ex.getMessage());
                 }
                 if(updateableAUoMList.size() > 0)
                     update updateableAUoMList;
                 if(updateableValuationList.size() > 0)
                     update updateableValuationList;
             }
         }
     }
     
     /*********************************************************************
     Method Name: unLockRecord
     Purpose: To unlock the records those are locked from approval process
     **********************************************************************/
     public static void unLockRecord(){  
         if (TriggerUtility.CheckfromTemplate || TriggerUtility.checkFromQueueable) {
             return;
         }
         
         // Added for RE-60
         AsyncMaterialUnlock matUnlockJob = new AsyncMaterialUnlock();
         matUnlockJob.materialIds = setMaterialID;
         System.enqueueJob(matUnlockJob);
     }
     
     /*********************************************************************
     Method Name: updateBOMStatusonEdit
     Purpose: To update the BOM status to In Progress
     **********************************************************************/
     public static void updateBOMStatusonEdit(Material__c mat){    
         if(TriggerUtility.CheckfromTemplate)
             return;
         
         if(mat.BOM_Status__c == 'Draft' && (mat.BOM_Usage__c != oldMat.BOM_Usage__c || mat.Brand_Group__c != oldMat.Brand_Group__c)){
             mat.BOM_Status__c = 'In Progress';
         }
     }
     
     /***********************************
     Method Name: updateComponentStatus
     Purpose:Update Status of component status.
     ***********************************/
     public static void updateComponentStatus(Material__c mat1){   
         if(TriggerUtility.CheckfromTemplate)
             return;
         
         if(!updateableDataSet.containsKey('Material__c'))
             updateableDataSet.put('Material__c', new Map<Id, SObject>());    
             
         if(matBomMap.get(mat1.Id) != null && matBomMap.get(mat1.Id).size() > 0)
         {
         for(BOM_Item__c bom : matBomMap.get(mat1.Id)){
            Boolean matUpdated = false; // USST-2562
             if(bom.Material_Component__r.Material_Type__c == 'ROH' || bom.Material_Component__r.Material_Type__c == 'Z009' || (bom.Material_Component__r.Material_Type__c == 'FERT' && bom.Material_Component__r.Item_Code__c == 'FT - PHANTOM TRAY')){
                 if(bom.Material__r.Material_Status__c == 'Processed in SAP' && bom.Material__r.Material_Number__c != null && bom.Material__r.Label_Code__c != null){
                                         
                     Material__c mat;
                     
                     if(!updateableDataSet.get('Material__c').containsKey(bom.Material_Component__c)){
                         mat = new Material__c(Id=bom.Material_Component__c);
                     }                       
                     else{
                         mat = (Material__c) updateableDataSet.get('Material__c').get(bom.Material_Component__c);
                     }
                     
                     if(bom.Material_Component__r.Material_Status__c == 'Submitted' || (bom.Material__r.CreatedBy.userRole.Name == 'G1200' && bom.Material_Component__r.Material_Status__c == 'Approved'))
                     {
                        if (mat.Material_Status__c != 'Approved') {
                            mat.Material_Status__c = 'Approved';
                            matUpdated = true; // USST-2562
                        }
                        if (mat.Material_Integration_State__c != 'N') {
                            mat.Material_Integration_State__c='N';
                            matUpdated = true; // USST-2562
                        }
                     }
                     
                     if(bom.Material_Component__r.Selection_Reference_Number__c == null || bom.Material_Component__r.Selection_Reference_Number__c == ''){
                        // USST-2562 - start
                        if (mat.Selection_Reference_Number__c != bom.Material__r.Material_Number__c) {
                            mat.Selection_Reference_Number__c = bom.Material__r.Material_Number__c;
                            matUpdated = true;                          
                        }
                    }
                    if (matUpdated) {
                        updateableDataSet.get('Material__c').put(bom.Material_Component__c, mat);
                        mat.Selection_Reference_Number__c = bom.Material__r.Material_Number__c;
                     }
                   // USST-2562 - end
                    
                 }
                 else if(bom.Material__r.Material_Status__c == 'SAP Error'){
                     Material__c mat;
                     
                     if(!updateableDataSet.get('Material__c').containsKey(bom.Material_Component__c)){
                         mat = new Material__c(Id=bom.Material_Component__c);
                     }                       
                     else{
                         mat = (Material__c) updateableDataSet.get('Material__c').get(bom.Material_Component__c);
                     }
                     
                     if(bom.Material_Component__r.Material_Status__c == 'Submitted'){
                         mat.Material_Status__c = 'Draft';
                        // USST-2562 - start
                        matUpdated = true; 
                    }
                    if (matUpdated) {
                        updateableDataSet.get('Material__c').put(bom.Material_Component__c, mat);
                     }
                   // USST-2562 - end
                    
                 }
             }           
         }
         }
     }
     
     /***********************************
     Method Name: checkDealIdPopulated
     Purpose: To check DealId is populated on the material.
     ***********************************/
     public static void checkDealIdPopulated(Material__c mat){    
         if(TriggerUtility.CheckfromTemplate)
             return;
     
         if(!insertableDataSet.containsKey('FeedItem'))
             insertableDataSet.put('FeedItem', new List<SObject>());
         
         Boolean hasIssueInSales = false;
         if(fetchDataSet.get('Material__c') != null && fetchDataSet.get('Material__c').get(mat.Id) != null && ((Material__c)fetchDataSet.get('Material__c').get(mat.Id)).sales__r != null)
         {
             for(Sales__c sl : ((Material__c)fetchDataSet.get('Material__c').get(mat.Id)).sales__r)
             {
                 if(sl.Material_Pricing_Group__c == null)
                     hasIssueInSales = true;
             }
         }
         
         //if material status is approved and deal is null for single
         if(mat.Material_status__c == 'Approved' && (mat.Deal_ID__c==null || mat.Title_Source__c==null || mat.Product_class__c==null || mat.TM_Version_Lookup__c == null || hasIssueInSales) && mat.item_type__c=='S (Single)'){
             if(mat.Deal_ID__c==null){
                 FeedItem post = new FeedItem();
                 post.ParentId=mat.id;
                 post.Body='Kindly update the Deal Id on the record';
                 
                 insertableDataSet.get('FeedItem').add(post);
                
             }  
             Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
             req1.setObjectId(mat.id);
             req1.setProcessDefinitionNameOrId('Material_Approval_Process_w_o_hierarchy3');
             req1.setSkipEntryCriteria(true);
             Approval.ProcessResult result = Approval.process(req1);                
         }            
         
         //if material is approved and title source is null for multipack
         if(mat.Material_status__c == 'Approved' && (mat.Title_Source__c==null || mat.Product_class__c==null || hasIssueInSales) && mat.item_type__c=='M (Multipack)' ){                
             Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
             req1.setObjectId(mat.id);
             req1.setProcessDefinitionNameOrId('Material_Approval_Process_w_o_hierarchy3');
             req1.setSkipEntryCriteria(true);
             Approval.ProcessResult result = Approval.process(req1);                
         }
     }
     
     /***********************************
     Method Name: updateTerritoryInChildComponents
     Purpose:Following method is responsible to fetch the complete hierarchy under material and update their territory to US & CDN.
     ***********************************/     
     private static Set<String> childMaterialTypes = new Set<String>{'ROH', 'Z009'};
     private static Boolean isChangeTerritoryMethodCalled = false;
     private static Set<Id> processedMatIds = new Set<Id>();
     public static void updateTerritoryInChildComponents(Set<Id> material4TerritoryChangeId)
     {
         if(isChangeTerritoryMethodCalled || TriggerUtility.checkFromCloning || TriggerUtility.CheckfromTemplate)
             return;
         
         isChangeTerritoryMethodCalled = true;
         processedMatIds.clear();
         
         fetchCompleteBOMHierarchy(material4TerritoryChangeId);
         
         List<Material__c> updateableMaterials = new List<Material__c>();
         if(processedMatIds.size() > 0)
         {
             Map<ID,Material__c> mapMaterialDetail = new Map<ID,Material__c>([Select id,Material_Status__c from Material__c where ID in:processedMatIds]);
             
             for(Id matId : processedMatIds)
             {
                 Material__c mat = new Material__c();
                 mat.Id = matId;
                 mat.Territory__c = 'US & CDN';
                 if(mapMaterialDetail.containsKey(mat.ID) && mapMaterialDetail.get(mat.ID).Material_Status__c == 'Processed in SAP'){
                     mat.Material_Integration_State__c = 'N';
                 }   
                 updateableMaterials.add(mat);
             }
             
             try
             {
                 TriggerUtility.allowAfterUpdateTriggerExecution = true;
                 Database.update(updateableMaterials, false);
                 TriggerUtility.allowAfterUpdateTriggerExecution = false;
             }
             catch(Exception ex)
             {}
         }
     }
     /***********************************
     Method Name: removeChildViews4TerritoryChange
     Purpose:removes child views for territory change on  material
     ***********************************/
     public static void removeChildViews4TerritoryChange(Map<Id, String> materialTerritoryReduceMap1)
     {
         if(TriggerUtility.CheckfromTemplate)
             return;
         
         List<Sales__c> updateableSalesList = new List<Sales__c>();
         List<Plant__c> updateablePlantList = new List<Plant__c>();
         List<Classification__c> updateableClassList = new List<Classification__c>();
         List<Alternative_Unit_of_Measure__c> updateableAUoMList = new List<Alternative_Unit_of_Measure__c>();
         List<Valuation__c> updateableValuationList = new List<Valuation__c>();
         
         List<Sales__c> deletableSalesList = new List<Sales__c>();
         List<Plant__c> deletablePlantList = new List<Plant__c>();
         List<Classification__c> deletableClassList = new List<Classification__c>();
         List<Alternative_Unit_of_Measure__c> deletableAUoMList = new List<Alternative_Unit_of_Measure__c>();
         List<Valuation__c> deletableValuationList = new List<Valuation__c>();
         
         Id classficationRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
         System.debug('*******classficationRecordTypeId> '+classficationRecordTypeId);
         for(Material__c mat : [SELECT Id, Name, Territory__c,
                                (SELECT Id, Territory__c, Deletion_Flag__c,Sales_Key__c FROM Sales__r WHERE Deletion_Flag__c=FALSE),
                                (SELECT Id, Territory__c, Deletion_Flag__c,Plant_Key__c FROM Plants__r WHERE Deletion_Flag__c=FALSE),
                                (SELECT Id, Territory__c, Deletion_Flag__c,Classification_Key__c FROM Classifications__r WHERE Deletion_Flag__c=FALSE AND RecordTypeId=:classficationRecordTypeId),
                                (SELECT Id, Territory__c, Deletion_Flag__c,Alternative_Unit_of_Measure__c,Unit_Key__c FROM Alternative_Units_of_Measure__r WHERE Deletion_Flag__c=FALSE),
                                (SELECT Id, Territory__c, Deletion_Flag__c,Valuation_Key__c FROM Valuations__r WHERE Deletion_Flag__c=FALSE)
                                FROM Material__c
                                WHERE Id IN :materialTerritoryReduceMap1.keySet()])
         {
             String curTerritory = materialTerritoryReduceMap1.get(mat.Id);
             if(mat.Sales__r != null && mat.Sales__r.size() > 0)
             {
                 for(Sales__c sales : mat.Sales__r)
                 {
                     if(sales.Territory__c == curTerritory)
                     {
                         if(sales.Sales_Key__c!=null && sales.Sales_Key__c!=''){
                         System.debug('##1406'+sales.Sales_Key__c);
                             sales.Deletion_Flag__c = true;
                             updateableSalesList.add(sales);
                         }else{
                             deletableSalesList.add(sales);
                         }
                         System.debug('##1406'+sales.Sales_Key__c+'##'+deletableSalesList);
                         System.debug('##1406'+updateableSalesList+'##'+deletableSalesList);
                     }
                 }
             }
             
             if(mat.Plants__r != null && mat.Plants__r.size() > 0)
             {
                 for(Plant__c plant : mat.Plants__r)
                 {
                     if(plant.Territory__c == curTerritory)
                     {
                         if(plant.Plant_Key__c!=null && plant.Plant_Key__c!=''){
                             plant.Deletion_Flag__c = true;
                             updateablePlantList.add(plant);
                         }
                         else{
                             deletablePlantList.add(plant);
                         }
                     }
                 }
             }
             
             if(mat.Alternative_Units_of_Measure__r != null && mat.Alternative_Units_of_Measure__r.size() > 0)
             {
                 for(Alternative_Unit_of_Measure__c auom : mat.Alternative_Units_of_Measure__r)
                 {
                     if(auom.Territory__c == curTerritory && auom.Alternative_Unit_of_Measure__c != 'EA - Each' && auom.Alternative_Unit_of_Measure__c != 'RSU - Retail Sellable Unit' && auom.Alternative_Unit_of_Measure__c != 'END - Exp# Disk' && auom.Alternative_Unit_of_Measure__c != 'ENU - Exp# Units' && auom.Unit_Key__c!='' && auom.Unit_Key__c!=null)
                     {
                         auom.Deletion_Flag__c = true;
                         updateableAUoMList.add(auom);
                     }
                     else if(auom.Territory__c == curTerritory && auom.Alternative_Unit_of_Measure__c != 'EA - Each' && auom.Alternative_Unit_of_Measure__c != 'RSU - Retail Sellable Unit' && auom.Alternative_Unit_of_Measure__c != 'END - Exp# Disk' && auom.Alternative_Unit_of_Measure__c != 'ENU - Exp# Units' && (auom.Unit_Key__c=='' || auom.Unit_Key__c==null)){
                         deletableAUoMList.add(auom);                   
                     }
                 }
             }
             
             if(mat.Valuations__r != null && mat.Valuations__r.size() > 0)
             {
                 for(Valuation__c val : mat.Valuations__r)
                 {
                     if(val.Territory__c == curTerritory)
                     {
                         if(val.Valuation_Key__c!=null && val.Valuation_Key__c!=''){
                             val.Deletion_Flag__c = true;
                             updateableValuationList.add(val);
                         }
                         else{
                             deletableValuationList.add(val);
                         }
                     }
                 }
             }
         }
         
         if(updateableSalesList.size() > 0)
             update updateableSalesList;
         if(updateablePlantList.size() > 0)
             update updateablePlantList;
         
         if(updateableAUoMList.size() > 0)
             update updateableAUoMList;
         if(updateableValuationList.size() > 0)
             update updateableValuationList;
             
         if(deletableSalesList.size() > 0)
             delete deletableSalesList;
         if(deletablePlantList.size() > 0)
             delete deletablePlantList;
          if(deletableAUoMList.size() > 0)
             delete deletableAUoMList;
         if(deletableValuationList.size() > 0)
             delete deletableValuationList;             
     }
     
     /***********************************
     Method Name: removeChildViews4MaterialDelete
     Purpose:removes child views for a material
     ***********************************/
     public static void removeChildViews4MaterialDelete(Set<Id> materialIds)
     {
         if(TriggerUtility.CheckfromTemplate)
             return;
         
         List<Sales__c> updateableSalesList = new List<Sales__c>();
         List<Plant__c> updateablePlantList = new List<Plant__c>();
         List<Classification__c> updateableClassList = new List<Classification__c>();
         List<Alternative_Unit_of_Measure__c> updateableAUoMList = new List<Alternative_Unit_of_Measure__c>();
         List<Valuation__c> updateableValuationList = new List<Valuation__c>();
         
         for(Material__c mat : [SELECT Id, Name, Territory__c,
                                (SELECT Id, Territory__c, Deletion_Flag__c FROM Sales__r WHERE Deletion_Flag__c=FALSE),
                                (SELECT Id, Territory__c, Deletion_Flag__c FROM Plants__r WHERE Deletion_Flag__c=FALSE),
                                (SELECT Id, Territory__c, Deletion_Flag__c FROM Classifications__r WHERE Deletion_Flag__c=FALSE),
                                (SELECT Id, Territory__c, Deletion_Flag__c FROM Alternative_Units_of_Measure__r WHERE Deletion_Flag__c=FALSE),
                                (SELECT Id, Territory__c, Deletion_Flag__c FROM Valuations__r WHERE Deletion_Flag__c=FALSE)
                                FROM Material__c
                                WHERE Id IN :materialIds])
         {
             if(mat.Sales__r != null && mat.Sales__r.size() > 0)
             {
                 for(Sales__c sales : mat.Sales__r)
                 {
                     sales.Deletion_Flag__c = true;
                     updateableSalesList.add(sales);
                 }
             }
             
             if(mat.Plants__r != null && mat.Plants__r.size() > 0)
             {
                 for(Plant__c plant : mat.Plants__r)
                 {
                     plant.Deletion_Flag__c = true;
                     updateablePlantList.add(plant);
                 }
             }
             
             if(mat.Classifications__r != null && mat.Classifications__r.size() > 0)
             {
                 for(Classification__c cls : mat.Classifications__r)
                 {
                     cls.Deletion_Flag__c = true;
                     updateableClassList.add(cls);
                 }
             }
             
             if(mat.Alternative_Units_of_Measure__r != null && mat.Alternative_Units_of_Measure__r.size() > 0)
             {
                 for(Alternative_Unit_of_Measure__c auom : mat.Alternative_Units_of_Measure__r)
                 {
                     auom.Deletion_Flag__c = true;
                     updateableAUoMList.add(auom);
                 }
             }
             
             if(mat.Valuations__r != null && mat.Valuations__r.size() > 0)
             {
                 for(Valuation__c val : mat.Valuations__r)
                 {
                     val.Deletion_Flag__c = true;
                     updateableValuationList.add(val);
                 }
             }
         }
         
         if(updateableSalesList.size() > 0)
             update updateableSalesList;
         if(updateablePlantList.size() > 0)
             update updateablePlantList;
         try {
             System.debug('******updateableClassList> '+updateableClassList);
             if(updateableClassList.size() > 0)
             {
                 Database.update(updateableClassList, true);
             }
         } 
         catch(Exception ex) {
             System.debug('*******clsEx> '+ex.getMessage());
         }
         if(updateableAUoMList.size() > 0)
             update updateableAUoMList;
         if(updateableValuationList.size() > 0)
             update updateableValuationList;
     }
     
     /***********************************
     Method Name: fetchCompleteBOMHierarchy
     Purpose:Fetches all the child materials for a material
     ***********************************/
     private static void fetchCompleteBOMHierarchy(Set<Id> processingMaterialIds)
     {
         Set<Id> nextLevelProcessingMaterialIds = new Set<Id>();
         Map<Id, List<BOM_Item__c>> matBomMap2 = new Map<Id, List<BOM_Item__c>>();
         for(BOM_Item__c bom : [SELECT Id, Material__c, Material_Component__c, Material_Component__r.Material_Type__c
                                 FROM BOM_Item__c
                                 WHERE Material__c IN :processingMaterialIds AND Material__r.Material_Type__c NOT IN: childMaterialTypes AND 
                                     Material_Component__c NOT IN :processedMatIds])
         {
             if(!matBomMap2.containsKey(bom.Material__c))
                 matBomMap2.put(bom.Material__c, new List<BOM_Item__c>());
             matBomMap2.get(bom.Material__c).add(bom);
         }
         
         // Fetch the child materials from BOM Items.
         for(Material__c mat : [SELECT Id
                                FROM Material__c
                                WHERE Id IN :processingMaterialIds AND Material_Type__c NOT IN: childMaterialTypes])
         {
             processedMatIds.add(mat.Id);
             
             if(matBomMap2.get(mat.Id) != null && matBomMap2.get(mat.Id).size() > 0)
             {
                 for(BOM_Item__c bom : matBomMap2.get(mat.Id))
                 {
                     if(!childMaterialTypes.contains(bom.Material_Component__r.Material_Type__c) && !processedMatIds.contains(bom.Material_Component__c))
                     {
                         nextLevelProcessingMaterialIds.add(bom.Material_Component__c);
                     }
                     else if(!processedMatIds.contains(bom.Material_Component__c))
                     {
                         processedMatIds.add(bom.Material_Component__c);
                     }
                 }
             }
         }
         
         if(nextLevelProcessingMaterialIds.size() > 0)
             fetchCompleteBOMHierarchy(nextLevelProcessingMaterialIds);
     }
     
     /***********************************
     Method Name: cancelUpdateMaterials
     Purpose: Following method cancels associated Update records if certain condition is met.
     ***********************************/ 
     public static void cancelUpdateMaterials()
     {
         if(TriggerUtility.CheckfromTemplate)
             return;
         
         // If any material found satisfying the criteria.
         if(matIds1.size() > 0)
         {
             // Querying to get all the materials having record type 'Update', material status is not either 'Processed in SAP' or 'Cancelled' and Original
             // Material Number is in the selected material id set.
             for(Material__c mat : [SELECT Id FROM Material__c 
                                    WHERE Original_Material_Number__c IN : matIds1 AND Material_Status__c != 'Processed in SAP' AND 
                                    Material_Status__c != 'Cancelled' AND RecordTypeId =: updateRecTypeId])
             {
                 Material__c updtMat;
                 if(!updateableDataSet.containsKey('Material__c'))
                     updateableDataSet.put('Material__c', new Map<Id, SObject>());                        
                 
                 if(!updateableDataSet.get('Material__c').containsKey(mat.ID)){
                     updtMat = mat;
                 }
                 else
                 {
                     updtMat = (Material__c) updateableDataSet.get('Material__c').get(mat.ID);
                 }         
                     
                 // Cancelling the material.
                 updtMat.Material_Status__c = 'Cancelled';
                 updtMat.SAP_Update_Indicator__c = False;
                 
                 
                 updateableDataSet.get('Material__c').put(mat.ID, updtMat); 
             }           
         }        
     }
     
     /***********************************
     Method Name: updateBOMFunction
     Purpose:To update Bom Function on the BOM item
     ***********************************/
     public static void updateBOMFunction(Material__c mat){
         if(TriggerUtility.CheckfromTemplate)
             return;
         
         if(fetchDataSet.containsKey('Material__c') && fetchDataSet.get('Material__c').containsKey(mat.ID) && mat.BOM_Function__c != oldMat.BOM_Function__c){
             if(matBomMap.get(mat.Id) != null && matBomMap.get(mat.Id).size() > 0)
             {
                 for(BOM_Item__c bm : matBomMap.get(mat.Id)){
                     BOM_Item__c updtBm;
                     if(!updateableDataSet.containsKey('BOM_Item__c'))
                         updateableDataSet.put('BOM_Item__c', new Map<Id, SObject>());                        
                     
                     if(!updateableDataSet.get('BOM_Item__c').containsKey(bm.ID)){
                         updtBm = bm;
                     }
                     else
                     {
                         updtBm = (BOM_Item__c) updateableDataSet.get('BOM_Item__c').get(bm.ID);
                     } 
                     
                     updtBm.BOM_Function__c = mat.BOM_Function__c;
                     updateableDataSet.get('BOM_Item__c').put(bm.ID, updtBm);                               
                 }
             }
         }
     }
         
     /***********************************
     Method Name: updateClassificationFields
     Purpose:Following method is responsible to set National vs Retailser field in classification.
     ***********************************/
     public static void updateClassificationFields(Material__c mat)
     {
         if(!Trigger.isUpdate || TriggerUtility.CheckfromTemplate)
             return;
         
         if(fetchDataSet.containsKey('Material__c') && fetchDataSet.get('Material__c').containsKey(mat.ID)){
             if(mat.Material_Type__c == 'FERT' && ((mat.Label_Code__c != oldMat.Label_Code__c && (mat.Label_Code__c == '59 - Paramount' || mat.Label_Code__c == '59 - Paramount')) ||
                (mat.Label_Code__c == '59 - Paramount' && mat.Retailer_Rental__c != oldMat.Retailer_Rental__c))){
                    
                for(Classification__c cls : ((Material__c) fetchDataSet.get('Material__c').get(mat.Id)).Classifications__r)
                {
                    if(cls.Deletion_Flag__c == FALSE && cls.RecordTypeId == classficationRecordTypeId1){
                        
                        Classification__c updtCls;
                        if(!updateableDataSet.containsKey('Classification__c'))
                             updateableDataSet.put('Classification__c', new Map<Id, SObject>());                        
                         
                         if(!updateableDataSet.get('Classification__c').containsKey(cls.ID)){
                             updtCls = cls;
                         }
                         else
                         {
                             updtCls = (Classification__c) updateableDataSet.get('Classification__c').get(cls.ID);
                         } 
                         
                         system.debug('Label Code ::'+mat.Label_Code__c);
                         system.debug('Retailer Rental ::'+mat.Retailer_Rental__c );
                         if(mat.Label_Code__c == '59 - Paramount' && mat.Retailer_Rental__c == null)
                             updtCls.National_vs_Retailer__c = 'N - National';
                         else if(mat.Label_Code__c == '59 - Paramount' && (mat.Retailer_Rental__c == 'REN (RENTAL)' || mat.Retailer_Rental__c == '28R (28-DAY WINDOW RENTAL)' || mat.Retailer_Rental__c == 'XXR (WINDOWED RENTAL)'))
                             updtCls.National_vs_Retailer__c = 'N - National';
                         else if(mat.Label_Code__c == '59 - Paramount' && mat.Retailer_Rental__c != null)
                             updtCls.National_vs_Retailer__c = 'R - Retailer Specific';
                         else 
                             updtCls.National_vs_Retailer__c = null;
                          system.debug('National vs Retailer ::'+updtCls.National_vs_Retailer__c);
                         updateableDataSet.get('Classification__c').put(cls.ID, updtCls); 
                    }
                }
            }
         }
     }
     
     /*********************************************************************
     Method Name: updateBOMStatusJointCorrugate
     Purpose: To update the BOM status in Joint Corrugate
     **********************************************************************/
     public static void updateBOMStatusJointCorrugate(){
         if(TriggerUtility.CheckfromTemplate)
             return;
         
         Set<Id> ftIds = new Set<Id>();
         Set<Id> jcIds = new Set<Id>();
         
         if(fetchDataSet.containsKey('Material__c')){
             for(Material__c mat :(List<Material__c>) fetchDataSet.get('Material__c').values()) {
                 if(mat.material_status__c=='Processed in SAP' && mat.Item_Type__c=='D (Display Vehicle)' && mat.material_number__c!='' && mat.material_number__c!=null && mat.Item_Code__c == 'FT - PHANTOM TRAY'){
                     for(BOM_Item__c bom : mat.BOM_Items1__r)
                     {
                         jcIds.add(bom.Material__c);
                     }
                     
                 }
             }
         }
         if (jcIds.size() > 0) { //Added for 101 error 04/10/2018
             for(Material__c parMat : [SELECT Id,BOM_status__c, (SELECT Id FROM BOM_Items__r WHERE Material_Component__r.material_number__c=null AND Material_Component__r.Item_Code__c='FT - PHANTOM TRAY' LIMIT 100) 
                                       FROM Material__c WHERE Id IN: jcIds])
             {
                 if(parMat.BOM_Items__r.size() == 0)
                 {
                     Material__c updtMat;
                     if(!updateableDataSet.containsKey('Material__c'))
                         updateableDataSet.put('Material__c', new Map<Id, SObject>());                        
                     
                     if(!updateableDataSet.get('Material__c').containsKey(parMat.ID)){
                         updtMat = parMat;
                     }
                     else
                     {
                         updtMat = (Material__c) updateableDataSet.get('Material__c').get(parMat.ID);
                     } 
                     if(updtMat.BOM_status__c=='Draft' || updtMat.BOM_status__c=='Sent Back'||updtMat.BOM_status__c=='In Progress'){
                         updtMat.BOM_status__c='Approved';
                         updtMat.BOM_Integration_State__c='N';
                     }
                     updateableDataSet.get('Material__c').put(parMat.ID, updtMat); 
                 }
             }
         }
     }
     
     /************************************************************
     Method Name: updateBomStatus
     Purpose: To update bom status for display vehicles
     **************************************************************/
     
     public static void updateBomStatus(){
         List<Material__c>updateMatBomStatus=new List<Material__c>();
         System.debug('##Inside updateBomStatus');
     
         Map<ID,Material__c> mapMatDetails = new Map<ID,Material__c>([select Id,material_status__c,Item_Type__c,material_number__c,BOM_status__c,Label_Code__c,Item_Code__c,(Select id from BOM_Items__r) from Material__c where ID in: Trigger.NewMap.keySet()]);
         
         for(Material__c mat : (List<Material__c>)Trigger.New){
             System.debug('#####'+mat.material_status__c+'##'+mat.Item_Type__c+'##'+mat.material_number__c);
             //for DF-02162 changed the BOM status check
             if(mat.material_status__c=='Processed in SAP' && mat.Item_Type__c=='D (Display Vehicle)' && mat.material_number__c!='' && mat.material_number__c!=null && mat.BOM_status__c!='Approved' && mat.Label_Code__c != '87 - JOINT CORR/MULTI-STUDIO' && mat.Item_Code__c != 'FT - PHANTOM TRAY' && mapMatDetails.get(mat.ID).BOM_Items__r.size() > 0
                 && (mat.bom_status__c=='Draft' || mat.bom_status__c=='In Progress')){
                 mat.BOM_status__c='Approved';
                 updateMatBomStatus.add(mat);
             }
         }
     }
     
     /***********************************
     Method Name: transferOwner
     Purpose:Transfer Ownership to API User for approved material
     ***********************************/
     public static void transferOwner(List<Material__c>matList){
         List<User> APIUser = [Select Id, Name From User Where Name = 'API User' limit 1];
         for(Material__c mat : matList){
             if(mat.Material_Status__c == 'Processed in SAP'){
                 mat.ownerId = APIUser.get(0).Id;
             }
         }
     }
     
     /***********************************
     Method Name: updatestatusFromSAP
     Purpose: Update material status from SAP
     ***********************************/
     public static void updatestatusFromSAP(List<Material__c> matList){
         Map<Id,Material__c> mapMaterial = new Map<Id,Material__c>( [Select id,(Select id,Material__c from BOM_Items__r LIMIT 1) FROM Material__c where id IN: matList ]);
         Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
         IF (TriggerUtility.currentUser != null){
             profileName = TriggerUtility.currentUser.Profile.Name;
         }
         List<Material__c> lstMatl = new List<Material__c>();
         for(Material__c matl : matList){
             system.debug('profile=== '+profileName);
             if(profileName == 'Platform API'){
                 system.debug('profile=== '+profileName); 
                 matl.Material_Status__c = 'Processed in SAP';
                 matl.Material_Integration_State__c = 'S';
                 matl.recordTypeId = recTypeId;
             }
         }
     }
      
     /***********************************
     Method Name: updatestatusFromSAP
     Purpose: Following method populates BOM header values for materials created from SAP.
     ***********************************/
     public static void populateBOMHeaderInSAPMaterial()
     {
         if(Trigger.isBefore && Trigger.isInsert && TriggerUtility.currentUser.Profile.Name == 'Platform API')
         {
             for(Material__c mat : (List<Material__c>) Trigger.New)
             {
                 if(mat.Material_Type__c == 'FERT')
                 {
                     if(mat.Territory__c != null)
                     {
                         if(mat.Territory__c.contains('US'))
                             mat.Plant__c = 'V000';
                         else
                             mat.Plant__c = 'V850';
                     }
                     mat.BOM_Usage__c = '3';
                     mat.Valid_From__c = Date.today();
                     mat.BOM_Status__c = 'Draft';
                     mat.BOM_Category__c = 'M';
                     mat.Alternative_BOM__c = '1';
                 }
                 else if(mat.Material_Type__c == 'ROH' || mat.Material_Type__c == 'Z009')
                 {
                     if(mat.Territory__c != null)
                     {
                         if(mat.Territory__c.contains('US'))
                             mat.Plant__c = 'V000';
                         else
                             mat.Plant__c = 'V850';
                     }
                     mat.Valid_From__c = Date.today();
                     mat.BOM_Status__c = 'Draft';
                 }
             }
         }
         if(Trigger.isBefore && Trigger.isUpdate && TriggerUtility.currentUser.Profile.Name == 'Platform API')
         {
             for(Material__c mat : (List<Material__c>) Trigger.New)
             {
                 if(mat.Material_Type__c == 'FERT')
                 {
                     if(mat.Territory__c != null && mat.Territory__c != ((Material__c)trigger.oldMap.get(mat.id)).Territory__c)
                     {
                         if(mat.Territory__c.contains('US'))
                             mat.Plant__c = 'V000';
                         else
                             mat.Plant__c = 'V850';
                     }
                 }
                 else if(mat.Material_Type__c == 'ROH' || mat.Material_Type__c == 'Z009')
                 {
                     if(mat.Territory__c != null && mat.Territory__c != ((Material__c)trigger.oldMap.get(mat.id)).Territory__c)
                     {
                         if(mat.Territory__c.contains('US'))
                             mat.Plant__c = 'V000';
                         else
                             mat.Plant__c = 'V850';
                     }
                 }
             }
         }
     }
     
     /***********************************
     Method Name: updatestatusFromSAP
     Purpose:Following method cancels associated Update records if certain condition is met.
     ***********************************/ 
     public static void cancelUpdateMaterials1()
     {
         // Executes only on material after update event.
         if(Trigger.IsAfter && Trigger.isUpdate)
         {
             // Fetching record type ids.
             Id materialRecordType = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
             Id updateRecordType = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
             Set<Id> matIds = new Set<Id>();
             
             // Iterating over updated materials.
             for(SObject rec : Trigger.New)
             {
                 Material__c mat = (Material__c) rec;
                 Material__c oldMat1 = (Material__c) Trigger.OldMap.get(mat.Id);
                 
                 // Checking is SAP Update Indicator is checked and material's record type is 'Material' 
                 if(mat.SAP_Update_Indicator__c != oldMat1.SAP_Update_Indicator__c && mat.SAP_Update_Indicator__c && mat.RecordTypeId == materialRecordType)
                 {
                     // Collecting ids.
                     matIds.add(mat.Id);
                 }
             }
             
             // If any material found satisfying the criteria.
             if(matIds.size() > 0)
             {
                 List<Material__c> updateableMaterials = new List<Material__c>();
                 
                 // Querying to get all the materials having record type 'Update', material status is not either 'Processed in SAP' or 'Cancelled' and Original
                 // Material Number is in the selected material id set.
                 for(Material__c mat : [SELECT Id FROM Material__c 
                                        WHERE Original_Material_Number__c IN :matIds AND Material_Status__c != 'Processed in SAP' AND 
                                        Material_Status__c != 'Cancelled' AND RecordTypeId =: updateRecordType])
                 {
                     // Cancelling the material.
                     mat.Material_Status__c = 'Cancelled';
                     mat.SAP_Update_Indicator__c = False;
                     updateableMaterials.add(mat);
                 }
                 
                 // If any material found in the updating list, update the same.
                 if(updateableMaterials.size() > 0)
                 {
                     update updateableMaterials;
                 }
             }
         }
     }
     
     /***********************************
     Method Name: updateComponentStatus
     Purpose:Update Status of component status.
     ***********************************/
     public static void updateComponentStatus(List<Material__c>matList){
         Map<Id, Material__c> lstMatl = new Map<Id, Material__c>();    
         List<id> idLst =new List<Id>();
         List<BOM_Item__c> bomList = [SELECT Id, Material_Component__c, Material__c, Material__r.Material_Status__c,Material__r.BOM_Status__c, Material__r.Material_Number__c, Material__r.Label_Code__c, Material_Component__r.Material_Status__c, 
                                      Material_Component__r.Selection_Reference_Number__c, Material_Component__r.Component_Material__c, Material__r.CreatedBy.userRole.Name FROM BOM_Item__c 
                                      WHERE Material__c IN: matList AND (Material_Component__r.Material_Type__c IN ('ROH', 'Z009') OR
                                      (Material_Component__r.Material_Type__c='FERT' AND Material_Component__r.Item_Code__c='FT - PHANTOM TRAY'))];
             system.debug('bomList '+bomList);
             if(bomList.size() > 0){
                 for(BOM_Item__c bom : bomList){
                     if(bom.Material__r.Material_Status__c == 'Processed in SAP' && bom.Material__r.Material_Number__c != null && bom.Material__r.Label_Code__c != null){
                         Material__c mat = new Material__c();
                         mat.id = bom.Material_Component__c;
                         if(bom.Material_Component__r.Material_Status__c == 'Submitted' || (bom.Material__r.CreatedBy.userRole.Name == 'G1200' && bom.Material_Component__r.Material_Status__c == 'Approved'))
                         {
                             mat.Material_Status__c = 'Approved';
                             mat.Material_Integration_State__c='N';
                         }
                         if(bom.Material_Component__r.Selection_Reference_Number__c == null || bom.Material_Component__r.Selection_Reference_Number__c == ''){
                             mat.Selection_Reference_Number__c = bom.Material__r.Material_Number__c;
                         }
                         system.debug('bomList '+mat);
                         lstMatl.put(mat.Id, mat);
                         system.debug('bomList '+lstMatl);
                         idLst.add(bom.Material_Component__c);
                     }
                     else if(bom.Material__r.Material_Status__c == 'SAP Error'){
                         Material__c mat = new Material__c();
                         mat.id = bom.Material_Component__c;
                         if(bom.Material_Component__r.Material_Status__c == 'Submitted'){
                             mat.Material_Status__c = 'Draft';
                         }
                         lstMatl.put(mat.Id, mat);
                         idLst.add(bom.Material_Component__c);
                     }
                 }
             }
             if(lstMatl.size() > 0){
                 TriggerUtility.checkMaterialBeforeUpdateTriggerExecuted = true;
                 update lstMatl.values();
             }
             if(idLst.size() > 0){
                 RecordLocker.unlock(idLst);
             }
         
     }
     
     /**************************************************************
     Method Name: updateBomItemMaterialNumberReference
     Purpose:Mathod to update component number on bom item if its changed on component material
     ***************************************************************/
     public static void updateBomItemMaterialNumberReference(list<Material__c> parMatrec)
     {
         map<id,Material__c> parentMatRec = new map<id,Material__c>();
         System.debug('##Asha - Inside updateBomItemMaterialNumberReference');
     
         for(Material__c eachmat : parMatrec)
         {
             if(eachmat.Material_Type__c != 'ZVSM'){
                 parentMatRec.put(eachmat.id,eachmat);  
             }
         }
     
         SET<ID> parMatIds = parentMatRec.keyset();
         System.debug('##Asha - parMatIds'+parMatIds);
         //Getting parent material record to update if child conatins Maretial status Heep        
         List<BOM_Item__c> updateBomList = new List<BOM_Item__c>();
     
     
         List<BOM_Item__c> bomItemRec = [SELECT Id,Component_Number__c,Material_Component__c,Material__c FROM BOM_Item__c WHERE Material_Component__c IN:parMatIds ]; 
         System.debug('##Asha - bomItemRec'+bomItemRec);
     
         for(BOM_Item__c eachmat : bomItemRec)
         {               
             if(eachmat.Material_Component__c!=null && eachmat.Component_Number__c==null){
                 eachmat.Component_Number__c = parentMatRec.get(eachmat.Material_Component__c).Material_Number__c;
                 updateBomList.add(eachmat);
             }
         }
     
         if(updateBomList.size()>0) {
             System.debug('##Asha - updateBomList');
             try{
                 Update updateBomList;
             }
             catch(System.DmlException ex){
                 System.debug(ex.getMessage());
             }  
         } 
     } 
          
      /***********************************
     Method Name: updateBOMFunction
     Purpose:To update Bom Function on the BOM item
     ***********************************/
     public static void updateBOMFunction(){
         Map<ID,Material__c> mapMatDetails = new Map<ID,Material__c>();
         List<BOM_Item__c> lstBMItm = new List<BOM_Item__c>();
         
         for(Material__c mat : (List<Material__c>)Trigger.New){
             if(((Material__c)Trigger.OldMap.get(mat.ID)).BOM_Function__c != mat.BOM_Function__c && !mapMatDetails.containsKey(mat.ID)){
                 mapMatDetails.put(mat.ID,mat);
             }           
         }
         
         if(!mapMatDetails.isEmpty()){
             for(BOM_Item__c bm : [Select ID,BOM_Function__c,Material__c from BOM_Item__c where Material__c in:mapMatDetails.keyset()]){             
                 if(mapMatDetails.containsKey(bm.Material__c)){
                     bm.BOM_Function__c = mapMatDetails.get(bm.Material__c).BOM_Function__c;
                     lstBMItm.add(bm);
                 }               
             }
             
             if(!lstBMItm.isEmpty()){
                 update lstBMItm;
             }
         }       
     }
     
     /*********************************************************************
     Method Name: updateBOMStatusJointCorrugate
     Purpose: To update the BOM status in Joint Corrugate
     **********************************************************************/
     public static void updateBOMStatusJointCorrugate1(){
         Set<Id> ftIds = new Set<Id>();
         
         System.debug('##1631 - updateBOMStatusJointCorrugate1');
         for(Material__c mat : (List<Material__c>)Trigger.New){
             if(mat.material_status__c=='Processed in SAP' && mat.Item_Type__c=='D (Display Vehicle)' && mat.material_number__c!='' && mat.material_number__c!=null && mat.Item_Code__c == 'FT - PHANTOM TRAY'){
                 ftIds.add(mat.Id);
             }
         }
         if(ftIds.size() > 0)
         {
             Set<Id> jcIds = new Set<Id>();
             for(BOM_Item__c bom : [Select Material__c FROM BOM_Item__c WHERE Material_Component__c IN :ftIds])
             {
                 jcIds.add(bom.Material__c);
             }
             
             List<Material__c> updateableJSMats = new List<Material__c>();
             for(Material__c parMat : [SELECT Id,BOM_status__c, (SELECT Id FROM BOM_Items__r WHERE Material_Component__r.material_number__c=null AND Material_Component__r.Item_Code__c='FT - PHANTOM TRAY' LIMIT 100) 
                                       FROM Material__c WHERE Id IN: jcIds])
             {
                 if(parMat.BOM_Items__r.size() == 0 && (parMat.BOM_status__c=='Draft' || parMat.BOM_status__c=='Sent Back'||parMat.BOM_status__c=='In Progress'))
                 {
                     System.debug('##1631 - parMat.BOM_Items__r'+parMat.BOM_Items__r.size()+parMat.BOM_status__c);
                     parMat.BOM_status__c='Approved';
                     parMat.BOM_Integration_State__c='N';
                     updateableJSMats.add(parMat);
                 }
             }
           
   
             if(updateableJSMats.size() > 0)
                 update updateableJSMats;
         }
     }
     
     /*********************************************************************
     Method Name: updateOriginalMaterial
     Purpose: Update details of original material
     **********************************************************************/
     public static void updateOriginalMaterial(List<Material__c> matList){
         system.debug('matList==== '+matList);
         Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
         Map<id,Material__c> updateMaterialList = new Map<id,Material__c>();
         List<Material__c> matlList = [Select id,street_date__c,Pre_Order_Close_Date__c,Original_Release_Date__c,Material_Status__c,Original_Material_Number__r.street_date__c,
                                        Original_Material_Number__r.Theatrical_Release_Date__c,Original_Material_Number__r.Pre_Order_Close_Date__c,Original_Material_Number__r.Internal_Announce_Date__c,
                                        Original_Material_Number__r.Original_Release_Date__c,Original_Material_Number__r.Trade_Solicitation_Date__c,
                                        Trade_Solicitation_Date__c,Theatrical_Release_Date__c,Original_Material_Number__c,lastModifiedBy.Name,Internal_Announce_Date__c 
                                        from Material__c where id IN: matList AND recordTypeId =: recTypeId];
         system.debug('matlList==== '+matlList);
         
         for(Material__c mat : matlList){
             Material__c originalMat = new Material__c();
             originalMat.id = mat.Original_Material_Number__c;
             
             system.debug('mat.Original_Release_Date__c'+((Material__c)trigger.oldMap.get(mat.id)).Original_Release_Date__c);
             system.debug('mat.Original_Release_Date__c'+mat.Original_Release_Date__c);
             
             if(originalMat.street_date__c != ((Material__c)trigger.oldMap.get(mat.id)).street_date__c && mat.lastModifiedBy.Name=='API User'){
                 originalMat.street_date__c = mat.street_date__c;
                 updateMaterialList.put(originalMat.id,originalMat);            } 
             if(originalMat.Pre_Order_Close_Date__c != ((Material__c)trigger.oldMap.get(mat.id)).Pre_Order_Close_Date__c && mat.lastModifiedBy.Name=='API User'){
                 originalMat.Pre_Order_Close_Date__c = mat.Pre_Order_Close_Date__c;
                 system.debug('**Pre_Order_Close_Date__c '+originalMat.Pre_Order_Close_Date__c);
                   system.debug('**Pre_Order_Close_Date__c '+mat.Material_Status__c);
                 updateMaterialList.put(originalMat.id,originalMat);
             } 
             if(mat.Original_Release_Date__c != ((Material__c)trigger.oldMap.get(mat.id)).Original_Release_Date__c && mat.lastModifiedBy.Name=='API User'){
                 originalMat.Original_Release_Date__c = mat.Original_Release_Date__c;
                 system.debug('mat.Original_Release_Date__c'+mat.Original_Release_Date__c);
                 updateMaterialList.put(originalMat.id,originalMat);
             } 
             if(originalMat.Trade_Solicitation_Date__c != ((Material__c)trigger.oldMap.get(mat.id)).Trade_Solicitation_Date__c && mat.lastModifiedBy.Name=='API User'){
                 originalMat.Trade_Solicitation_Date__c = mat.Trade_Solicitation_Date__c;
                 updateMaterialList.put(originalMat.id,originalMat);
             } 
             if(originalMat.Theatrical_Release_Date__c != ((Material__c)trigger.oldMap.get(mat.id)).Theatrical_Release_Date__c && mat.lastModifiedBy.Name=='API User'){
                 originalMat.Theatrical_Release_Date__c = mat.Theatrical_Release_Date__c;
                 updateMaterialList.put(originalMat.id,originalMat);
             }
              if(originalMat.Internal_Announce_Date__c != ((Material__c)trigger.oldMap.get(mat.id)).Internal_Announce_Date__c && mat.lastModifiedBy.Name=='API User'){
                 originalMat.Internal_Announce_Date__c = mat.Internal_Announce_Date__c;
                 updateMaterialList.put(originalMat.id,originalMat);
             }  
         }             
         system.debug('updateMaterialList==== '+updateMaterialList);                 
         if(!updateMaterialList.isEmpty()){
             update updateMaterialList.values();
         }
     }

     
     /******************************************************************
     Method Name: updateDeleteOriginalMaterial
     Purpose: To update the delete checkbox in Original Material
     *******************************************************************/
     public static void updateDeleteOriginalMaterial(){
         Map<ID,Material__c> mapMatDetails = new Map<ID,Material__c>(); 
         Id updRecTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Material').getRecordTypeId();
         // Below Attributes for Defect #2620
         set<Id> setMatId = new set<Id>();
         set<Id> setParentId = new set<Id>();
         List<BOM_Item__c> lstBomItem = new List<BOM_Item__c>();
         string parentId; 
         setParentId = new set<Id>();
         for(Material__c mat : (List<Material__c>)Trigger.New){
             Material__c matNew = new Material__c(Id = mat.id); //USST-3225
            parentId = mat.Component_Material__c;
            parentMatid = mat.Component_Material__c;
         
            system.debug('Checking null check---'+parentId + '---'+parentMatid +'---' );
             if(mat.recordTypeId == updRecTypeId && mat.Deletion_Flag__c == true){
                 matNew.Material_Status__c = 'Deleted'; //USST-3225
                 matNew.Function__c = '003'; //USST-3225
                 mapMatDetails.put(matNew.id,matNew); //USST-3225
             }
             if(mat.recordTypeId == updRecTypeId && mat.Deletion_Flag__c == false && mat.Material_Status__c == 'Deleted'){
                 matNew.Material_Status__c = 'Processed in SAP'; //USST-3225
                 matNew.Function__c = '023'; //USST-3225
                 mapMatDetails.put(matNew.id,matNew); //USST-3225
             }
             Database.update(mapMatDetails.values()); //USST-3225
             // Below Piece of code for Defect #2620
             if(mat.recordTypeId == updRecTypeId && mat.Material_Type__c !='FERT' && mat.Material_Status__c == 'Deleted'){
                 matNew.BOM_Deletion_Flag__c = True; //USST-3225
                 setMatId.add(matNew.id); //USST-3225
                 system.debug('Checking the id---'+mat.Component_Material__c);
                 if(mat.Component_Material__c != null){
                 system.debug('Inside---');
                 
                     setParentId.add(mat.Component_Material__c);
                 }
             }
         }
         List<Id> lstTemp = new List<Id>();
         lstTemp.addall(setParentId);
         system.debug('Checking something222----'+parentId );
         system.debug('size of the parent---' + '---');
         List<BOM_Item__c> lstBomItem3 = new List<BOM_Item__c>();
         List<BOM_Item__c> lstBomItem2 = new List<BOM_Item__c>();
         List<BOM_Item__c> lstBomItem4 = new List<BOM_Item__c>();
         List<BOM_Item__c> lstBomItem5 = new List<BOM_Item__c>();
         lstBomItem = [select id,name,Material_Component__c,Deletion_Flag__c,Material__c  from BOM_Item__c where Material__c != null and Material__c in: setMatId ];
         lstBomItem3  = [select id,name,Material_Component__c,Deletion_Flag__c,Material__c  from BOM_Item__c where  Material__c =: parentMatid  or Material__c =: parentid  ];
         system.debug('Size of the list----'+lstBomItem3.size());
         if(!lstBomItem3.isEmpty()){
            for(BOM_Item__c objBomItem :lstBomItem3 ){
                if(setMatId.contains(objBomItem.Material_Component__c)  ){
                    lstBomItem.add(objBomItem);
                }
            }
         }
         if(!lstBomItem.isEmpty()){
             for(BOM_Item__c objBomItem :lstBomItem ){
                 lstBomItem2.add(objBomItem);
             }
             Database.delete(lstBomItem2);
         }
         
         if(!mapMatDetails.isEmpty()){
             vProjectUtility.removeVMaterial(mapMatDetails.values(), null);
         }  
     }
   
     /***********************************
     Method Name: updateAlternativeUnitofMeasure
     Purpose:updates AlternativeUnitofMeasure record
     ***********************************/
     public static void updateAlternativeUnitofMeasure(list<Material__c> parMatrec)
     {
        map<id,Material__c> parentMatRec = new map<id,Material__c>();
        
        for(Material__c eachmat : parMatrec)
             {
                parentMatRec.put(eachmat.id,eachmat);  
             }
       
       SET<ID> parMatIds = parentMatRec.keyset();
      
        //Getting parent material record to update if child conatins Maretial status Heep        
       List<Alternative_Unit_of_Measure__c> updaterecList = new List<Alternative_Unit_of_Measure__c>();
      
     
       List<Alternative_Unit_of_Measure__c> altRec = [SELECT Id,Alternative_Unit_of_Measure__c,Material__c,Gross_Weight__c,Net_Weight__c FROM Alternative_Unit_of_Measure__c WHERE Material__c IN:parMatIds AND Alternative_Unit_of_Measure__c='EA - Each']; 
         System.debug('## Asha - altRec'+altRec);
         for(Alternative_Unit_of_Measure__c eachrec : altRec)
             {               
                      
               if(eachrec.Alternative_Unit_of_Measure__c=='EA - Each' && eachrec.Material__c != null && parentMatRec.get(eachrec.Material__c).Gross_Weight__c != null) 
                 eachrec.Gross_Weight__c =  parentMatRec.get(eachrec.Material__c).Gross_Weight__c;
               
               if(eachrec.Alternative_Unit_of_Measure__c=='EA - Each' && eachrec.Material__c != null && parentMatRec.get(eachrec.Material__c).Net_Weight__c != null) 
                 eachrec.Net_Weight__c =  parentMatRec.get(eachrec.Material__c).Net_Weight__c ; 
                 
                updaterecList.add(eachrec);   
             }
           
           
          if(updaterecList.size()>0) {
          try{
           Update updaterecList;
           }
           catch(System.DmlException ex){
            System.debug(ex.getMessage());
 
          }  
          }         
        
      }
      
     /***********************************
     Method Name: updatePlantandCreatePlanRecord
     Purpose:this method is responsible to create plant record if material is approved and having V000 plant.
     ***********************************/
     @InvocableMethod  
     public static void updatePlantandCreatePlanRecord(List<Material__c> materialRec )
     {
        if(TriggerUtility.checkFromCloning)
            return;
        
        set<id> matId = new set<Id>();
        set<id> parMatIds = new set<Id>();
        Map<id,Material__c> mapMatIds = new Map<Id,Material__c>();
        Set<id>relSet=new Set<id>();
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        Set<id>matZ009Set=new Set<id>();
        
        System.debug('##Asha - UpdatePlantandCreatePlantRecord');
        for(Material__c eachmat : materialRec )
             {
                parMatIds.add(eachmat.id);
               
              if((eachmat.Material_Status__c=='Submitted' || (eachmat.Material_Status__c=='Approved' && eachMat.Item_Type__c == 'D (Display Vehicle)')) && eachmat.recordtypeid !=recTypeId) {             
                 
                 if(eachmat.Material_Type__c =='FERT'){
                     relSet.add(eachmat.release__c);
                 }
               }  
             //Added for DF-2134 to work for Update recordtype materials too
             if((eachmat.Material_Status__c=='Approved' && eachmat.recordtypeid !=recTypeId) || (eachmat.Material_Status__c=='Approved' && eachmat.recordtypeid == recTypeId && eachmat.Territory__c == 'US & CDN')) {
               mapMatIds.put(eachmat.id,eachmat);   
               if(eachmat.Material_Type__c =='FERT' && (eachmat.Format__c == '02 - DVD' || eachmat.Format__c == '03 - COMBO PACK' || eachmat.Format__c == '09 - BLU-RAY' || eachmat.Format__c == '10 - HD HYBRID (DUAL FORMAT) DNU' || eachmat.Format__c == '11 - ULTRA HD 4K' || eachmat.Format__c == '98 - GWP' || eachmat.Format__c == '20 - CD (COMPACT DISC)'))
                   matId.add(eachmat.Id); 
               else if(eachmat.Material_Type__c =='ROH' || eachmat.Material_Type__c =='Z009'){
                       matId.add(eachmat.Id); 
                       if(eachmat.material_type__c=='Z009'){
                           matZ009Set.add(eachmat.Id);
                       }
                   }
               else if(eachmat.Territory__c =='CDN')  
                   matId.add(eachmat.Id);
               }
             }
    
      list< Plant__c> plantRec = [Select Plant__c,Id,ABC_Indicator__c,Allocated__c,Availability_Check__c,Bwd_Cons_Period__c,                                 Carton_Count__c,Consumption_Mode__c,Coverage_Prof__c,Deletion_Flag__c,Fixed_Lot_Size__c,
                                  FI_Year_Variant__c,Function__c,Fwd_Cons_Period__c,GR_Processing_Time__c,Indv_Colle__c, Component_Scrap_Percentage__c,
                                  Lot_Size__c,Material__c,Max_Lot_Size__c,Max_Stock_Level__c,Min_Lot_Size__c,Mixed_MRP__c,
                                  MRP_Controller__c,MRP_Group__c,MRP_Type__c,Period_Ind__c,Plant_Specific_Matl_Status__c,
                                  Plnd_Dely_time__c,Procurement_Type__c,Prod_Storage_Location__c,Profit_Center__c,Purchasing_Group__c,
                                  Reorder_Point__c,Requirements_Grouping__c,Rounding_Value__c,Safety_Stock__c,Schedule_Margin_Key__c,
                                  Special_Procurement__c,Splitting_Ind__c,Stor_Loc_EP__c,Strategy_Group__c,Valid_From__c
                                  from Plant__c Where Material__c In: matId];      
        
    
   list<Plant__c> insertNewPlant =  new List<Plant__c>();
   list<Valuation__c> insertNewValuation =  new List<Valuation__c>();
   if(plantRec.size()>0){
    for( Plant__c each : plantRec) { 
        System.debug('##Asha - inside plant Loop'+mapMatIds.get(each.Material__c).Sales_Org__c+' '+each.Plant__c+' '+each.Plant__c);
      //Added for DF-2134 to check also for US & CDN Update materials     
      if(((mapMatIds.get(each.Material__c).Sales_Org__c=='V100' && mapMatIds.get(each.Material__c).recordtypeid != recTypeId) || (mapMatIds.get(each.Material__c).recordtypeid == recTypeId && mapMatIds.get(each.Material__c).Sales_Org__c=='V800')) && each.Plant__c!= 'V850 - Technicolor Canada' && each.Plant__c =='V000 - Univ Studios HV Planning Plant'){
       for(Integer i=0;i<4;i++){
         
           Plant__c newPlant = new Plant__c();
           newPlant.ABC_Indicator__c=    each.ABC_Indicator__c;
           newPlant.Availability_Check__c =each.Availability_Check__c;
           newPlant.Bwd_Cons_Period__c = each.Bwd_Cons_Period__c;
           newPlant.Carton_Count__c = each.Carton_Count__c;
           newPlant.Consumption_Mode__c= each.Consumption_Mode__c;
           newPlant.Coverage_Prof__c = each.Coverage_Prof__c;    
           newPlant.Deletion_Flag__c = each.Deletion_Flag__c;
           newPlant.Fixed_Lot_Size__c = each.Fixed_Lot_Size__c;
           newPlant.FI_Year_Variant__c = each.FI_Year_Variant__c;
           newPlant.Function__c = '009';
           newPlant.Fwd_Cons_Period__c = each.Fwd_Cons_Period__c;
           newPlant.GR_Processing_Time__c = each.GR_Processing_Time__c;
           newPlant.Indv_Colle__c = each.Indv_Colle__c;
           newPlant.Lot_Size__c = each.Lot_Size__c;
           newPlant.Material__c = each.Material__c;
           newPlant.Max_Lot_Size__c = each.Max_Lot_Size__c;
           newPlant.Max_Stock_Level__c = each.Max_Stock_Level__c;
           newPlant.Min_Lot_Size__c = each.Min_Lot_Size__c;
           newPlant.Mixed_MRP__c = each.Mixed_MRP__c;
           newPlant.MRP_Controller__c =  each.MRP_Controller__c;
           newPlant.MRP_Group__c = each.MRP_Group__c;
           newPlant.MRP_Type__c = each.MRP_Type__c;
           newPlant.Period_Ind__c = each.Period_Ind__c;          
           newPlant.Component_Scrap_Percentage__c = each.Component_Scrap_Percentage__c;
           newPlant.Stor_Loc_EP__c = '0010';
           IF(mapMatIds.get(each.Material__c).Material_Type__c == 'FERT'){
               newPlant.Consumption_Mode__c = '1 - Backward consumption only';
           }
           
           if(i==0) 
           newPlant.Plant__c= 'V300 - Technicolor - TN';
           if(i==1) 
           newPlant.Plant__c= 'V400 - Technicolor';
           if(i==2) {
               newPlant.Plant__c= 'V500 - Technicolor';
               newPlant.Stor_Loc_EP__c = '0020';
           }
           if(i==3) 
           newPlant.Plant__c= 'V750 - TECHNICOLOR HES';
         
          
           newPlant.Plant_Specific_Matl_Status__c = each.Plant_Specific_Matl_Status__c;
           newPlant.Plnd_Dely_time__c = each.Plnd_Dely_time__c;
           newPlant.Procurement_Type__c = each.Procurement_Type__c;
           newPlant.Prod_Storage_Location__c = each.Prod_Storage_Location__c;
           newPlant.Profit_Center__c = each.Profit_Center__c;
           newPlant.Purchasing_Group__c = each.Purchasing_Group__c;
           newPlant.Reorder_Point__c = each.Reorder_Point__c;
           newPlant.Requirements_Grouping__c =  each.Requirements_Grouping__c;
           newPlant.Rounding_Value__c =  each.Rounding_Value__c;
           newPlant.Safety_Stock__c = each.Safety_Stock__c;
           newPlant.Schedule_Margin_Key__c = each.Schedule_Margin_Key__c;
           newPlant.Special_Procurement__c = each.Special_Procurement__c;
           newPlant.Splitting_Ind__c = each.Splitting_Ind__c;
           newPlant.Strategy_Group__c = each.Strategy_Group__c;
           newPlant.Valid_From__c = each.Valid_From__c;
 
           System.debug('newPlant  id ' + each .id+' Plant__c ************* string' + newPlant.Plant__c);
 
           insertNewPlant.add(newPlant); 
         }
          
       }
     
       
      }  
    }   
        if(insertNewPlant.size()>0){ 
              
          Insert insertNewPlant;
          
          list<Valuation__c> valRec= [Select Id,Function__c,Moving_Price__c,Origin_Group__c,Price_Unit__c,Pricing_Control__c,
          Standard_Price__c,Territory__c,Valuation_Class__c,Valuation_Type__c from Valuation__c Where Valuation_Area__c='V000' AND Material__c In: matId];
          
          for(Plant__c eachPlant :insertNewPlant){
              if(!matZ009Set.contains(eachPlant.Material__c)){
                  Valuation__c newRec= new Valuation__c();
                  if(eachPlant.Plant__c!=null)
                  newRec.Valuation_Area__c = eachPlant.Plant__c.substring(0,4); 
                  newRec.Material__c = eachPlant.Material__c;
                  if(valRec[0].Function__c!=null)
                  newRec.Function__c = '009';
                  if(valRec[0].Moving_Price__c!=null)
                  newRec.Moving_Price__c = valRec[0].Moving_Price__c;
                  if(valRec[0].Origin_Group__c!=null)
                  newRec.Origin_Group__c = valRec[0].Origin_Group__c;
                  if(valRec[0].Price_Unit__c!=null)
                  newRec.Price_Unit__c = valRec[0].Price_Unit__c;
                  if(valRec[0].Pricing_Control__c!=null)
                  newRec.Pricing_Control__c = valRec[0].Pricing_Control__c;
                  if(valRec[0].Standard_Price__c!=null)
                  newRec.Standard_Price__c = valRec[0].Standard_Price__c;
                  if(valRec[0].Territory__c!=null)
                  newRec.Territory__c = valRec[0].Territory__c;
                  if(valRec[0].Valuation_Class__c!=null)
                  newRec.Valuation_Class__c = valRec[0].Valuation_Class__c;
                  if(valRec[0].Valuation_Type__c!=null)
                  newRec.Valuation_Type__c  = valRec[0].Valuation_Type__c;
                  insertNewValuation.add(newRec);
                 } 
           
          }
          
         if(insertNewValuation.size()>0)
           Insert insertNewValuation; 
        }
    
     } 
     
     //Update component material status to Sent back when a parent material is rejected.
     public static void updateComponentOnSentBack(Set<Id>matIds){
         Set<Id>childMatIds=new Set<Id>();
         List<Material__c>childMatList=new List<Material__c>();
     
     
         if(!matIds.isEmpty()){
             for(Bom_item__c bItem:[Select material_component__c from Bom_item__c where material_component__r.Material_Type__c!='FERT' and material__c in:matIds and material__r.material_status__c='Sent Back']){
                 childMatIds.add(bItem.material_component__c);
             }
         
         }
         if(!childMatIds.isEmpty()){
             for(Material__c mat: [Select id,Material_status__c from Material__c where id in:childMatIds ]){
                 if(mat.material_status__c=='Submitted'){
                      mat.material_status__c='Sent Back'; 
                      childMatList.add(mat);  
                 }                
             }
         }
         
         if(!childMatList.isEmpty()){
             update childMatList;
         }
         
     }
     
     /***********************************
     Method Name: updatePreOrderDatefromMaterial1
     Purpose:Mathod to update Pre Order Date when Material Format Description changed
     ***********************************/ 
     public static void updatePreOrderDatefromMaterial1(list<Material__c> matRecList){
         set<Id> matId = new Set<Id>();
         list<Sales__c> updateSalesRec = new List<Sales__c>();
         set<id>salesIdSet=new set<id>();
        
         for(Material__c each : matRecList){
             if(each.Date_Change_Update__c == true){
                 matId.add(each.Original_Material_Number__c);
             }
            
         } 
         list<Material__c> matRec = [Select Id,Format__c,Release__c,Release__r.Pre_Order_Close_Date__c,Release__r.Street_Date__c,Theatrical_Release_Date__c,
                                     Release__r.First_Theatrical_Date__c,Release__r.Internal_Announce_Date__c,Release__r.Trade_Solicitation_Date__c,Retailer_Rental__c,
                                     Release__r.In_Plant_Date__c,Release__r.VOD_Street_Date__c,Original_Release_Date__c,Internal_Announce_Date__c,
                                    Release__r.Original_Release_Date__c,Material_Status__c, Street_Date__c,Pre_Order_Close_Date__c,Trade_Solicitation_Date__c,
                                    Release__r.EST_Date__c,Release__r.Windowed_Rental_Street_Date__c,Release__r.Windowed_Rental_Pre_Order_Close_Date__c
                                    from Material__c where Id IN:matId];      
         list<Sales__c> salesRecList =[Select Id,Street_Date__c ,Pre_Order_Date__c,Material__c,Original_Release_Date__c,Announcement_Date_US__c ,
                                      Theatrical_Release_Date__c,Solicitation_Date__c from Sales__c where Material__c In:matId];
         for(Material__c eachMat : matRec){ 
             for(Sales__c eachSales : salesRecList){
                 if(!salesIdSet.contains(eachSales.id)){
                     if(matId.size() > 0){                    
                         eachSales.Announcement_Date_US__c = eachMat.Internal_Announce_Date__c ;                      
                         eachSales.Theatrical_Release_Date__c = eachMat.Theatrical_Release_Date__c ;                     
                         eachSales.Solicitation_Date__c = eachMat.Trade_Solicitation_Date__c ;                      
                         eachSales.Original_Release_Date__c = eachMat.Original_Release_Date__c ;                      
                         eachSales.Street_Date__c = eachMat.Street_Date__c;                    
                         eachSales.Pre_Order_Date__c= eachMat.Pre_Order_Close_Date__c; 
                         system.debug('***Pre_Order_Close_Date__c'+eachMat.Pre_Order_Close_Date__c);
                         system.debug('***Pre_Order_Close_Date__c'+eachMat.Material_Status__c);
                         
                     }
                     updateSalesRec.add(eachSales);
                     salesIdSet.add(eachSales.id);   
                }
                else  
                {
                    continue;
                }
             } 
         } 
        
         if(updateSalesRec.size()>0){
             try{
                 Update updateSalesRec;
             }
             catch(System.DmlException ex){
                System.debug(ex.getMessage());
 
             } 
         }
       
     }
     
         /*************************************************************************
     Method Name: deleteRejectionChatter
     Purpose: To add chatter post when a deletion request is rejected by 
             MD(RE-39).
     *************************************************************************/
     public static void deleteRejectionChatter(List<Material__c> matList){
        system.debug('matList===== '+matList);  
        for( Material__c mat : matList ){
            if(mat.recordtypeid == updateRecTypeId && (((Material__c)trigger.oldMap.get(mat.id)).Partial_Deletion_Request__c == true || ((Material__c)trigger.oldMap.get(mat.id)).Deletion_Flag__c == true) && mat.material_status__c == 'Sent Back'){
                 system.debug('inside if');
                 FeedItem post = new FeedItem();
                 post.ParentId = mat.id;                
                 post.Body = 'This material has not been approved for deletion.';
                 insert post;
                 
                 FeedItem post1 = new FeedItem();
                 post1.ParentId = mat.Original_Material_Number__c;
                 post1.Body = 'This material has not been approved for deletion.';
                 insert post1;
            }
            if(mat.recordtypeid == updateRecTypeId && ((Material__c)trigger.oldMap.get(mat.id)).Request_For_Reactivation__c == true && mat.material_status__c == 'Sent Back'){
                 system.debug('inside if');
                 FeedItem post2 = new FeedItem();
                 post2.ParentId = mat.id;                
                 post2.Body = 'This material has not been approved for reactivation.';
                 insert post2;
                 
                 FeedItem post3 = new FeedItem();
                 post3.ParentId = mat.Original_Material_Number__c;
                 post3.Body = 'This material has not been approved for reactivation.';
                 insert post3;
            }    
        } 
     }
     
      //ReleaseForce 2.0 RE-111 delete Release Materials when material is deleted from SAP
     public static void deleteReleaseMaterial(Set<Id>matList){
         System.debug('deleteReleaseMaterial.....'+matList);
         
         List<Release_Material__c> relMatList=[Select id,Material__r.Material_Status__c from release_material__c where material__c in:matList and Material__r.Material_Status__c = 'Deleted'];
         
         if(!relMatList.isEmpty()){
             delete relMatList;
         }
         
     }
     
     //RE-148: Update the status when API user unchecks delete checkbox
     public static void updateMatStatusOnActivate(List<Material__c> mList){
         List<Material__c> matListToUpdate = new List<Material__c>();
         for(Material__c m : mList){
             if(m.deletion_flag__c == false && m.Material_Status__c == 'Deleted'){
                 m.Material_Status__c = 'Processed in SAP';
                 matListToUpdate.add(m);
             }
         }
         if(matListToUpdate.size() > 0){
             //update matListToUpdate; //USST-3229
         }
         
     }
     
     //ReleaseForce2.0 RE-50--- Insert contact information from Release in case of insert.
     public static void insertMaterialContacts(Set<Id>relid){
         Map<Id,Release__c>relMap=new Map<Id,Release__c>([Select id,Creative_Contact__c,Manufacturing_Contact__c,Marketing_Contact__c,Master_Data_Contact__c,Tech_Ops_Contact__c, Publicity_Contact__c from release__c where id in:relid]); //USST-3239
         
         for(Material__c mat:(List<Material__c>)trigger.new){
             if(relMap!=null && relMap.get(mat.release__c)!=null){
                 mat.Creative_Contact__c=relMap.get(mat.release__c).Creative_Contact__c;
             }
             if(relMap!=null && relMap.get(mat.release__c)!=null){
                 mat.Manufacturing_Contact__c=relMap.get(mat.release__c).Manufacturing_Contact__c;
             }
             if(relMap!=null && relMap.get(mat.release__c)!=null){
                 mat.Marketing_Contact__c=relMap.get(mat.release__c).Marketing_Contact__c;
             }
             if(relMap!=null && relMap.get(mat.release__c)!=null){
                 mat.Master_Data_Contact__c=relMap.get(mat.release__c).Master_Data_Contact__c;
             }
             if(relMap!=null && relMap.get(mat.release__c)!=null){
                 mat.Tech_Ops_Contact__c=relMap.get(mat.release__c).Tech_Ops_Contact__c;
             }
             //USST-3239 --- start
             if(relMap!=null && relMap.get(mat.release__c)!=null){
                 mat.Publicity_Contact__c=relMap.get(mat.release__c).Publicity_Contact__c;
             }
             //USST-3239 --- end
         }
     }
     
     //ReleaseForce 2.0 RE-10 method to fetch Deal Based on the DealName
     public static void fetchDealData(){
         Set<String> dealIDSet= new Set<String>{'PKGDEAL00083','PKGDEAL00085','PKGDEAL00247','PKGDEAL00252','PKGDEAL00082','PKGDEAL00065','PKGDEAL00272'}; //USST-3174
             for(Deal__c deal:[Select id,title__c,label_code__c,name,deal_id__c from deal__c where deal_id__c in:dealIDSet and title__c in:titleIdSet] ){
             if(dealDefaultMap.containsKey(deal.deal_id__c)){
                 dealDefaultMap.get(deal.deal_id__c).add(deal);
             }
             else{
                dealDefaultMap.put(deal.deal_id__c,new List<Deal__c>{deal});
             }
         }
         
         System.debug('##DealDefaultMap----'+dealDefaultMap);
     }
     
     
      /*************************************************************************
     USST-2766: External ID setup for TIBCO
     Method Name: handleTibcoUpdateFields
     Purpose: This method updates few fields on Material based on the values sent by TIBCO.
     *************************************************************************/
     /*public static void handleTibcoUpdateFields(){
        List<Material__c> lstMat = (List<Material__c>)Trigger.new;
        Material__c oldMat;
        
        ///////////////////////TM Version Lookup
        Map<ID,String> tmVersionIdTibco_Material_Map = new Map<ID,String>();
        Map<String,ID> tmVersionIdTibco_TMVersion_Map = new Map<String,ID>();
        List<TM_Version__c> lstTMVersions = new List<TM_Version__c>();
        
        ///////////////////////Sub-Label Code
        Map<ID,String> subLblCodeIdTibco_Material_Map = new Map<ID,String>();
        Map<String,ID> subLblCodeIdTibco_SubLblCodeId_Map = new Map<String,ID>();
        List<Sub_Label_Code__c> lstSubLblCodeIds = new List<Sub_Label_Code__c>();
        
        ///////////////////////Old Material No.
        Map<ID,String> matNumberTibco_Material_Map = new Map<ID,String>();
        Map<String,ID> matNumberTibco_MatId_Map = new Map<String,ID>();
        List<Material__c> lstMaterials = new List<Material__c>();
        
        ////////////////////////Alternative Legal Title
        Map<ID,String> altLeglTtlTibco_Material_Map = new Map<ID,String>();
        Map<String,ID> altLeglTtlTibco_AltLeglTtl_Map = new Map<String,ID>();
        List<Alternative_Legal_Title__c> lstAltLeglTtls = new List<Alternative_Legal_Title__c>();
        
        ////////////////////////Title
        Map<ID,String> sgennoTitleTibco_Material_Map = new Map<ID,String>();
        Map<String,ID> sgennoTitleTibco_Title_Map = new Map<String,ID>();
        List<Title__c> lstTitles = new List<Title__c>();
                
        /////////////////////////Deal
        Map<ID,String> dealIdTibco_Material_Map = new Map<ID,String>();
        Map<ID,String> tempDealIdTibco_Material_Map = new Map<ID,String>();
        Map<String,ID> dealIdTibco_Deal_Map = new Map<String,ID>();
        Map<ID,String> sgennoDealTibco_Material_Map = new Map<ID,String>();
        Map<String,ID> sgennoDealTibco_Title_Map = new Map<String,ID>();
        List<Deal__c> lstDeals = new List<Deal__c>();
        String sgennoDealCombo = '';
        
                
        
        List<Material__c> updateableMaterials = new List<Material__c>();
        
        for (Material__c mat : lstMat) {
            oldMat = (Material__c)Trigger.oldMap.get(mat.Id);
            
            ///////////////////////TM Version Lookup
            if (mat.TM_Version_Id_Tibco__c != oldMat.TM_Version_Id_Tibco__c) {
                String tmVersnLookupId = mat.TM_Version_Id_Tibco__c != 'NULL' ? String.valueOf(Integer.valueOf(mat.TM_Version_Id_Tibco__c)) : 'NULL'; //removing all leading zeros in tmVersionIdTibco field
                tmVersionIdTibco_Material_Map.put(mat.Id, tmVersnLookupId);              
            }
            ///////////////////////Sub-Label Code
            if(mat.Sub_Label_Code_Id_Tibco__c != oldMat.Sub_Label_Code_Id_Tibco__c) {
                subLblCodeIdTibco_Material_Map.put(mat.Id, mat.Sub_Label_Code_Id_Tibco__c);
            }
            ///////////////////////Old Material No.
            if (mat.Material_Number_Tibco__c != oldMat.Material_Number_Tibco__c) {
                matNumberTibco_Material_Map.put(mat.Id, mat.Material_Number_Tibco__c);
            }
            ////////////////////////Alternative Legal Title
            if (mat.Alternative_Legal_Title_Id_Tibco__c != oldMat.Alternative_Legal_Title_Id_Tibco__c) {
                altLeglTtlTibco_Material_Map.put(mat.Id, mat.Alternative_Legal_Title_Id_Tibco__c);
            }
            ////////////////////////Title
            if (mat.SGENNO_Title_Tibco__c != oldMat.SGENNO_Title_Tibco__c && mat.SGENNO_Title_Tibco__c != null && mat.SGENNO_Title_Tibco__c != '') {
                String sgenno = mat.SGENNO_Title_Tibco__c != 'NULL' ? String.valueOf(Integer.valueOf(mat.SGENNO_Title_Tibco__c)) : 'NULL'; //removing all leading zeros in sgennoTitleTibco field
                sgennoTitleTibco_Material_Map.put(mat.Id, sgenno);
            }
            /////////////////////////Deal
            if (mat.SGENNO_Deal_Tibco__c != oldMat.SGENNO_Deal_Tibco__c && mat.SGENNO_Deal_Tibco__c != null && mat.SGENNO_Deal_Tibco__c != '' && 
                mat.Deal_Id_Tibco__c != oldMat.Deal_Id_Tibco__c && mat.Deal_Id_Tibco__c != null && mat.Deal_Id_Tibco__c != '') {
                String sgenno = mat.SGENNO_Deal_Tibco__c != 'NULL' ? String.valueOf(Integer.valueOf(mat.SGENNO_Deal_Tibco__c)) : 'NULL'; //removing all leading zeros in sgennoDealTibco field
                sgennoDealCombo = sgenno + ' :: ' + mat.Deal_Id_Tibco__c;
                sgennoDealTibco_Material_Map.put(mat.Id, sgenno);
                dealIdTibco_Material_Map.put(mat.Id, mat.Deal_Id_Tibco__c );
                tempDealIdTibco_Material_Map.put(mat.Id, sgennoDealCombo );
            }
            
        }
        
        
        ///////////////////////TM Version Lookup
        if (tmVersionIdTibco_Material_Map.values().size() > 0) {
            lstTMVersions = [Select Id, TM_Version_ID__c from TM_Version__c where TM_Version_ID__c IN : tmVersionIdTibco_Material_Map.values() LIMIT 1000];
        }
        for (TM_Version__c tm : lstTMVersions) {
            tmVersionIdTibco_TMVersion_Map.put(tm.TM_Version_ID__c, tm.Id);
        }
        
        
        ///////////////////////Sub-Label Code
        if (subLblCodeIdTibco_Material_Map.values().size() > 0) {
            lstSubLblCodeIds = [Select Id, Sub_Label_Code_ID__c from Sub_Label_Code__c where Sub_Label_Code_ID__c IN : subLblCodeIdTibco_Material_Map.values() LIMIT 1000];
        }
        for (Sub_Label_Code__c sc : lstSubLblCodeIds) {
            subLblCodeIdTibco_SubLblCodeId_Map.put(sc.Sub_Label_Code_ID__c, sc.Id);
        }
        
        
        ///////////////////////Old Material No.
        if (matNumberTibco_Material_Map.values().size() > 0) {
            lstMaterials = [Select Id, Material_Number__c, RecordType.Name from Material__c where Material_Number__c IN : matNumberTibco_Material_Map.values() and RecordType.Name NOT IN ('Update') LIMIT 1000];
        }
        for (Material__c mt : lstMaterials) {
            matNumberTibco_MatId_Map.put(mt.Material_Number__c, mt.Id);
        }
        
        
        ////////////////////////Alternative Legal Title
        if (altLeglTtlTibco_Material_Map.values().size() > 0) {
            lstAltLeglTtls = [Select Id, Alternative_Legal_Title_ID__c from Alternative_Legal_Title__c where Alternative_Legal_Title_ID__c IN : altLeglTtlTibco_Material_Map.values() LIMIT 1000];
        }
        for (Alternative_Legal_Title__c alt : lstAltLeglTtls) {
            altLeglTtlTibco_AltLeglTtl_Map.put(alt.Alternative_Legal_Title_ID__c, alt.Id);
        }
        
        
        ////////////////////////Title
        if (sgennoTitleTibco_Material_Map.values().size() > 0) {
            lstTitles = [Select Id, SGENNO__c from Title__c where SGENNO__c IN : sgennoTitleTibco_Material_Map.values() LIMIT 1000];
        }
        for (Title__c ttl : lstTitles) {
            sgennoTitleTibco_Title_Map.put(ttl.SGENNO__c, ttl.Id);
        }
        
        
        /////////////////////////Deal
        if (sgennoDealTibco_Material_Map.values().size() > 0 && dealIdTibco_Material_Map.values().size() > 0) {
            lstTitles = [Select Id, SGENNO__c from Title__c where SGENNO__c IN : sgennoDealTibco_Material_Map.values() LIMIT 1000];
            lstDeals = [Select Id, Deal_Id__c, SGENNO__c from Deal__c where Deal_Id__c IN : dealIdTibco_Material_Map.values() LIMIT 1000];
        }
        for (Title__c ttl : lstTitles) {
            sgennoDealTibco_Title_Map.put(ttl.SGENNO__c, ttl.Id);
        }
        for (Deal__c d : lstDeals) {
            sgennoDealCombo = d.SGENNO__c + ' :: ' + d.Deal_Id__c;
            dealIdTibco_Deal_Map.put(sgennoDealCombo, d.Id);
        }
        
        
        
        for (Material__c mat : lstMat) {
            if (tmVersionIdTibco_TMVersion_Map.size() > 0) {
                mat.TM_Version_Lookup__c = tmVersionIdTibco_TMVersion_Map.get(tmVersionIdTibco_Material_Map.get(mat.Id));
            }
            else if ((mat.TM_Version_Id_Tibco__c).equalsIgnoreCase('NULL')) {
                mat.TM_Version_Lookup__c = null;
            }
            if (subLblCodeIdTibco_SubLblCodeId_Map.size() > 0) {
                mat.Sub_Label_Code_Lookup__c = subLblCodeIdTibco_SubLblCodeId_Map.get(subLblCodeIdTibco_Material_Map.get(mat.Id));
            }
            else if ((mat.Sub_Label_Code_Id_Tibco__c).equalsIgnoreCase('NULL')) {
                mat.Sub_Label_Code_Lookup__c = null;
            }
            if (matNumberTibco_MatId_Map.size() > 0) {
                mat.Old_Material_No__c = matNumberTibco_MatId_Map.get(matNumberTibco_Material_Map.get(mat.Id));
            }
            else if ((mat.Material_Number_Tibco__c).equalsIgnoreCase('NULL')) {
                mat.Old_Material_No__c = null;
                mat.Old_Material_Load__c = null;
            }
            if (altLeglTtlTibco_AltLeglTtl_Map.size() > 0) {
                mat.Alternative_Legal_Title_Lookup__c = altLeglTtlTibco_AltLeglTtl_Map.get(altLeglTtlTibco_Material_Map.get(mat.Id));
            }
            else if ((mat.Alternative_Legal_Title_Id_Tibco__c).equalsIgnoreCase('NULL')) {
                mat.Alternative_Legal_Title_Lookup__c = null;
            }
            if (sgennoTitleTibco_Title_Map.size() > 0) {
                mat.Title__c = sgennoTitleTibco_Title_Map.get(sgennoTitleTibco_Material_Map.get(mat.Id));
            }
            if (sgennoDealTibco_Title_Map.size() > 0 && dealIdTibco_Deal_Map.size() > 0) {
                mat.Title__c = sgennoDealTibco_Title_Map.get(sgennoDealTibco_Material_Map.get(mat.Id));
                mat.Deal__c = dealIdTibco_Deal_Map.get(tempDealIdTibco_Material_Map.get(mat.Id));
            }
        }
     }*/   

 }