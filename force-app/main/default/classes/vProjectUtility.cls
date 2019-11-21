/*****************************************************************************************
Class Name: vProjectUtility
Purpose: This class handles the business logic for vproject classes.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             21/10/2016           Ipsita Mishra              Initial Development
******************************************************************************************/
public without sharing class vProjectUtility{
    private static List<v_Material__c> insertableVMaterials = new List<v_Material__c>();
    private static Set<Id> vList = new Set<Id>();
    private static List<Task> insertableTasks = new List<Task>();
    
    /*This method is called from the release trigger to create a v-project record when
    the v-project required is true and release status is Materials Requested*/
    public static void createVProject(List<Release__c> relList){
    system.debug('Check Point 1');
        List<v_Project_Request__c> vprjList = new List<v_Project_Request__c>();
        List<Material__c> matList = new List<Material__c>();
        Map<Id, Set<Id>> mapMatRelRelationship = new Map<Id, Set<Id>>();
        List<Release_Material__c> relMatList = [Select id,Release__c,Material__c,Material__r.Material_Status__c,Material__r.Item_Type__c,Material__r.Name,Material__r.Item_Code__c,
                                                Material__r.Title__c, Material__r.Release__c,Material__r.Pre_Order_Close_Date__c, Material__r.Material_Number__c,Material__r.Internal_Announce_Date__c, Material__r.Territory__c from Release_Material__c where release__c IN: relList];
        for(Release__c rel : relList){
            if(rel.v_Project_Required__c == true && rel.v_Project__c == null && rel.Release_Status__c == 'Materials Requested'){
                v_Project_Request__c vprj = new v_Project_Request__c();
                vprj.Release__c = rel.id;
                vprj.SAP_Project_Description__c = rel.Name;
                vprj.Project_Studio__c = '001';
                if(rel.label_Code__c == '62 - Focus'){
                    vprj.Project_Studio__c = '005';
                }
                if(rel.Project_Type__c == 'New Release'){
                    vprj.Project_Class__c = 'HIT';
                    vprj.Project_Sub_Class__c = 'HIT';
                }
                else if(rel.Project_Type__c == 'Catalog'){
                    vprj.Project_Class__c = 'Catalog';
                    vprj.Project_Sub_Class__c = 'Core Catalog';
                }
                if(rel.Territory__c == 'US'){
                    vprj.Sales_Org__c = 'US';
                }
                else if(rel.Territory__c == 'CDN'){
                    vprj.Sales_Org__c = 'CDN';
                }
                if(rel.Street_Date__c != null){
                    vprj.Project_Finish_Date__c = rel.Street_Date__c + 240;
                    vprj.POS_Order_End_Date__c = rel.Street_Date__c + 180;
                    vprj.Return_End_Date__c = rel.Street_Date__c + 240;
                }
                vprj.Project_Category__c = 'V006';
                vprj.Title__c = rel.Title__c;
                vprj.Label_Code__c = rel.Label_Code__c;
                vprjList.add(vprj); 
            }
        }
        //check the list size and insert v-project
        if(vprjList.size() > 0){
            insert vprjList;
            
            //insert a task to create the v-project in SAP
            List<Task> insertableTasks = new List<Task>();
            for(v_Project_Request__c vproject : vprjList){
                insertableTasks.add(new Task(WhatId=vproject.id, Subject='Create v-Project', Activity_Description__c='Please create this V-Project in SAP and enter the v-Project number returned onto this request'));
            }
            
            if(insertableTasks.size() > 0){
                vProjectUtility.createTask(insertableTasks);
            }
        }
        
        //if the release has a release material associated, call addVMaterials method
        if(relMatList.size() > 0){
        system.debug('Check point 2---');
            for(Release_Material__c relMat: relMatList){
                set<Id> relId = new Set<Id>();
                Material__c m = new Material__c();
                m.Id = relMat.Material__c;
                m.Material_Status__c = relMat.Material__r.Material_Status__c;
                m.Item_Type__c = relMat.Material__r.Item_Type__c;
                m.Title__c = relMat.Material__r.Title__c;
                m.Release__c = relMat.Material__r.Release__c;
                m.Internal_Announce_Date__c = relMat.Material__r.Internal_Announce_Date__c;
                m.Territory__c = relMat.Material__r.Territory__c;
                m.Name = relMat.Material__r.Name;
                m.Item_Code__c = relMat.Material__r.Item_Code__c;
                m.Material_Number__c = relMat.Material__r.Material_Number__c;
                m.Pre_Order_Close_Date__c = relMat.Material__r.Pre_Order_Close_Date__c;
                if(!mapMatRelRelationship.containsKey(relMat.Material__c)){
                    mapMatRelRelationship.put(relMat.Material__c, new Set<Id>());
                }
                mapMatRelRelationship.get(relMat.Material__c).add(relMat.Release__c);
                matList.add(m);
            }
            if (matList.size() > 0 && mapMatRelRelationship.size() > 0) { //added for 101 error - USST-2780
                addVMaterials(matList,mapMatRelRelationship); 
            }
        }
    }  
    
    //Method to create a task when a v-project is created or updated.
    public static void createTask(List<Task> taskList){
        System.Debug('check entry point '+taskList);
        //query for API User ID
        //List<User> APIUser = [Select Id, Name From User Where Name = 'API User' limit 1];  //commented for 101 error 04/10/2018
        for(Task objTask : taskList)
        {
            objTask.Status = 'Not Started';
            objTask.Priority = 'Normal';
            //Set owner to API User RB2
            objTask.ownerID = Label.API_USER_ID; //APIUser.get(0).Id; //changed for 101 error 04/10/2018
        }
        
        if(taskList.size() > 0){
            upsert taskList;
        }
    }
    
    //Method to update the v-project lookup on the release
    public static void updateReleaseVProject(List<v_Project_Request__c> vProjectList){
        List<Release__c> relList = new List<Release__c>();
        if(!vProjectList.isEmpty()){
            for(v_Project_Request__c vprj : vProjectList){
                if(vprj.release__c != null && vprj.release__r.v_Project__c == null){
                    Release__c rel = new Release__c();
                    rel.id = vprj.release__c;
                    rel.v_Project__c = vprj.id;
                    relList.add(rel);
                }
            }
        }
        if(relList.size() > 0){
            update relList; 
        }
    }
    
    //Method to create a v-material.
    public static void addVMaterials(List<Material__c> matList, Map<Id, Set<Id>> mapMatRelRelationship)
    {
       system.debug('Check point 3---');
        Map<Id, List<v_Material__c>> matVMatMap = new Map<Id, List<v_Material__c>>();
        Set<Id> titleIds = new Set<Id>();
        Set<Id> releaseIds = new Set<Id>();
        for(v_Material__c vMat : [Select ID, Material__c, Status__c, Material__r.Name, v_Project__c, v_Project__r.Status__c, v_Project__r.Release__c,
                                  v_Material_Status__c, Material__r.Item_Type__c, Material__r.Material_Number__c, Material__r.Release__c, Material__r.Title__c,Material__r.Territory__c,
                                  Material__r.Material_Status__c, Marked_for_Inactivation__c, v_Project__r.Project_Finish_Date__c,Material__r.Material_Type__c 
                                  from v_Material__c where Material__c IN:matList AND v_Material_Status__c != 'Pending'])
        {
            if(!matVMatMap.containsKey(vMat.Material__c))
                matVMatMap.put(vMat.Material__c, new List<v_Material__c>());
            
            matVMatMap.get(vMat.Material__c).add(vMat);
        }
        
        for(Material__c mat : matList)
        {
            if(mat.Title__c != null)
                titleIds.add(mat.Title__c);
            if(mat.Release__c != null)
                releaseIds.add(mat.Release__c);
        }
        
        //Map to store the id and v-project
        Map<Id, List<v_Project_Request__c>> titleVProjectMap = new Map<Id, List<v_Project_Request__c>>();
        Map<Id, List<v_Project_Request__c>> releaseVProjectMap = new Map<Id, List<v_Project_Request__c>>();
        if(titleIds.size() > 0)
        {
            for(v_Project_Request__c vProj : [SELECT Id, Title__c, Project_Finish_Date__c, Sales_Org__c, Project_Class__c
                                              FROM v_Project_Request__c WHERE Title__c IN :titleIds AND Status__c!='Inactive'])
            {
                if(!titleVProjectMap.containsKey(vProj.Title__c))
                    titleVProjectMap.put(vProj.Title__c, new List<v_Project_Request__c>());
                titleVProjectMap.get(vProj.Title__c).add(vProj);
            }
            
        }
        
        if(releaseIds.size() > 0)
        {
            for(v_Project_Request__c vProj : [SELECT Id, Title__c, Project_Finish_Date__c, Sales_Org__c, Project_Class__c, Release__c
                                              FROM v_Project_Request__c WHERE Release__c IN :releaseIds AND Status__c!='Inactive'])
            {
                if(!releaseVProjectMap.containsKey(vProj.Release__c))
                    releaseVProjectMap.put(vProj.Release__c, new List<v_Project_Request__c>());
                releaseVProjectMap.get(vProj.Release__c).add(vProj);
            }
        }
        
        Map<Id, List<v_Project_Request__c>> relVProjMap = new Map<Id, List<v_Project_Request__c>>();
        if(mapMatRelRelationship != null)
        {
            Set<Id> relIds = new Set<Id>();
            for(Set<Id> relIdSet : mapMatRelRelationship.values())
            {
                relIds.addAll(relIdSet);
            }
            
            if(relIds.size() > 0)
            {
                for(v_Project_Request__c vProj : [SELECT Id, Release__c,Sales_Org__c,Project_Finish_Date__c  
                                                  FROM v_Project_Request__c WHERE Release__c IN :relIds AND Status__c!='Inactive'])
                {
                    if(!relVProjMap.containsKey(vProj.Release__c))
                        relVProjMap.put(vProj.Release__c, new List<v_Project_Request__c>());
                    relVProjMap.get(vProj.Release__c).add(vProj);
                }
                
            }
        }
        
        Map<Id, v_Material__c> updateableVMaterials = new Map<Id, v_Material__c>();
        /*Set<Id> vList = new Set<Id>();
        List<Task> insertableTasks = new List<Task>();*/
        for(Material__c mat : matList)
        {
            system.debug('mat=== ' +mat.Item_Type__c);
            if(mat.Item_Type__c == 'D (Display Vehicle)' || mat.Item_Code__c == 'BF - BABY FERT'){
                continue;
            }
            else if((mat.Item_Type__c == 'S (Single)' || mat.Item_Type__c == 'M (Multipack)')){
                Boolean executeSysgenScope = true;
                
                // If material has VMaterials.
                if(matVMatMap.containsKey(mat.Id))
                {
                    executeSysgenScope = false;
                    for(v_Material__c vMat : matVMatMap.get(mat.Id))
                    {
                        Boolean isUpdated = false;
                        
                        if(vMat.Marked_for_Inactivation__c || (vMat.v_Project__r.Project_Finish_Date__c != null && vMat.v_Project__r.Project_Finish_Date__c < Date.today()))
                        {
                            vMat.Status__c = 'Inactive';
                            isUpdated = true;
                            System.debug('*****Executed IF_11');
                        }
                        else
                        {
                            if(vMat.Material__r.Material_Number__c != null && !vMat.Marked_for_Inactivation__c)
                            {
                                vMat.Status__c = 'Active';
                                isUpdated = true;
                                insertableTasks.add(new Task(WhatId=vMat.v_Project__c, Subject='Create WBSE', Activity_Description__c='Please add  a WBSE for ' + mat.Material_Number__c +' - '+ mat.Name));
                                vList.add(vMat.v_Project__c);
                            }
                            else if(vMat.Material__r.Material_Number__c == null && !vMat.Marked_for_Inactivation__c)
                            {
                                vMat.Status__c = 'Pending';
                                isUpdated = true;
                            }
                            System.debug('*****Executed IF_12');
                        }
                        
                        if(vMat.Status__c == 'Active' && mapMatRelRelationship == null && vMat.v_Project__c != null){
                            if(!vList.contains(vMat.v_Project__c)){
                                vList.add(vMat.v_Project__c); 
                            }
                            System.debug('*****Executed IF_21');
                        }
                        else if(vMat.Status__c == 'Inactive' && mapMatRelRelationship != null)
                        {
                            Boolean criteriaMatched = false;
                            for(Id relId : mapMatRelRelationship.get(mat.Id))
                            {
                                if(vMat.v_Project__r.Release__c == relId && vMat.v_Project__r.Status__c != 'Inactive')
                                {
                                    vMat.Marked_for_Inactivation__c = false;
                                    isUpdated = true;
                                    criteriaMatched = true;
                                    //if material status is processed in SAP, change the v-material status to active and create a task for the v-project
                                    if(vMat.Material__r.Material_Number__c != null)
                                    {
                                        vMat.Status__c = 'Active';
                                        String taskSubject = 'Reactivate WBSE';
                                        //Updated Activity Description RB2
                                        insertableTasks.add(new Task(WhatId=vMat.v_Project__c, Subject=taskSubject, Activity_Description__c='Please Reactivate the WBSE for ' + mat.Material_Number__c +' - '+ mat.Name));
                                        vList.add(vMat.v_Project__c);
                                    }
                                    break;
                                }
                            }
                            
                            if(!criteriaMatched)
                            {
                                for(Id relId : mapMatRelRelationship.get(mat.Id))
                                {
                                    if(vMat.v_Project__r.Release__c != relId && vMat.v_Project__r.Status__c != 'Inactive')
                                        executeSysgenScope = true;
                                }
                            }
                            System.debug('*****Executed IF_22');
                        }
                        
                        if(isUpdated)
                            updateableVMaterials.put(vMat.Id, vMat);
                    }
                }
                // If material has Sysgen No./Title
                if(executeSysgenScope)
                {
                    Boolean vMatCreated = false;
                    //If material has Title
                    if(mat.Title__c != null && titleVProjectMap.containsKey(mat.Title__c))
                    {
                        for(v_Project_Request__c vProj : titleVProjectMap.get(mat.Title__c))
                        {
                            if(mapMatRelRelationship != null)
                            {
                            system.debug('Check point 4---');
                                for(Id relId : mapMatRelRelationship.get(mat.Id))
                                {
                                    if((relVProjMap.containsKey(relId)) && (mat.Pre_Order_Close_Date__c < vProj.Project_Finish_Date__c) && (((mat.Territory__c == 'US' || mat.Territory__c =='US & CDN') && vProj.Sales_Org__c == 'US') || ((mat.Territory__c == 'CDN' || mat.Territory__c =='US & CDN') && vProj.Sales_Org__c == 'CDN')) && (vProj.Project_Class__c == 'HIT'))
                                    {
                                    system.debug('Check point 5---');
                                        createVMaterial(mat.Id,vProj.Id,mat.Material_Number__c,mat.Name,mat.Material_Status__c);
                                        vMatCreated = true;
                                        break;
                                    } 
                                }
                            }else if((mat.Pre_Order_Close_Date__c < vProj.Project_Finish_Date__c) && (((mat.Territory__c == 'US' || mat.Territory__c =='US & CDN') && vProj.Sales_Org__c == 'US') || ((mat.Territory__c == 'CDN' || mat.Territory__c =='US & CDN') && vProj.Sales_Org__c == 'CDN')) && (vProj.Project_Class__c == 'HIT'))
                            {
                            system.debug('Check point 6---');
                                createVMaterial(mat.Id,vProj.Id,mat.Material_Number__c,mat.Name,mat.Material_Status__c);
                                vMatCreated = true;
                            }
                            
                            if(vMatCreated)
                                break;
                        }
                        if(!vMatCreated && mat.Release__c != null && releaseVProjectMap.containsKey(mat.Release__c))
                        {
                        system.debug('Check point 7---');
                            for(v_Project_Request__c vProj : releaseVProjectMap.get(mat.Release__c))
                            {
                                if(mapMatRelRelationship != null)
                                {
                                    for(Id relId : mapMatRelRelationship.get(mat.Id))
                                    {
                                        if((relVProjMap.containsKey(relId)) && (mat.Pre_Order_Close_Date__c < vProj.Project_Finish_Date__c) && (((mat.Territory__c == 'US' || mat.Territory__c =='US & CDN') && vProj.Sales_Org__c == 'US') || ((mat.Territory__c == 'CDN' || mat.Territory__c =='US & CDN')  && vProj.Sales_Org__c == 'CDN')))
                                        {
                                        system.debug('Check point 8---');
                                            createVMaterial(mat.Id,vProj.Id,mat.Material_Number__c,mat.Name,mat.Material_Status__c);
                                            vMatCreated = true;
                                            break;
                                        } 
                                    }
                                } else if((mat.Pre_Order_Close_Date__c < vProj.Project_Finish_Date__c) && (((mat.Territory__c == 'US' || mat.Territory__c =='US & CDN') && vProj.Sales_Org__c == 'US') || ((mat.Territory__c == 'CDN' || mat.Territory__c =='US & CDN') && vProj.Sales_Org__c == 'CDN')))
                                {
                                system.debug('Check point 9---');
                                    createVMaterial(mat.Id,vProj.Id,mat.Material_Number__c,mat.Name,mat.Material_Status__c);
                                    vMatCreated = true;
                                }
                                
                                if(vMatCreated)
                                    break;
                            }
                        } else if(!vMatCreated) {
                            for(v_Project_Request__c vProj : titleVProjectMap.get(mat.Title__c))
                            {
                                if(mapMatRelRelationship != null)
                                {
                                    for(Id relId : mapMatRelRelationship.get(mat.Id))
                                    {
                                        if((relVProjMap.containsKey(relId)) && (mat.Pre_Order_Close_Date__c < vProj.Project_Finish_Date__c) && (((mat.Territory__c == 'US' || mat.Territory__c =='US & CDN') && vProj.Sales_Org__c == 'US') || ((mat.Territory__c == 'CDN' || mat.Territory__c =='US & CDN') && vProj.Sales_Org__c == 'CDN')))
                                        {
                                        system.debug('Check point 10---');
                                            createVMaterial(mat.Id,vProj.Id,mat.Material_Number__c,mat.Name,mat.Material_Status__c);
                                            vMatCreated = true;
                                            break;
                                        } 
                                    }
                                } else if((mat.Pre_Order_Close_Date__c < vProj.Project_Finish_Date__c) && (((mat.Territory__c == 'US' || mat.Territory__c =='US & CDN') && vProj.Sales_Org__c == 'US') || ((mat.Territory__c == 'CDN' || mat.Territory__c =='US & CDN') && vProj.Sales_Org__c == 'CDN')))
                                {
                                system.debug('Check point 11---');
                                    createVMaterial(mat.Id,vProj.Id,mat.Material_Number__c,mat.Name,mat.Material_Status__c);
                                    vMatCreated = true;
                                }
                                
                                if(vMatCreated)
                                    break;
                            }
                        }
                        
                    } else if(mapMatRelRelationship != null)
                    {
                        for(Id relId : mapMatRelRelationship.get(mat.Id))
                        {
                            if(relVProjMap.containsKey(relId))
                            {
                                for(v_Project_Request__c vProj : relVProjMap.get(relId))
                                {
                                    if((mat.Pre_Order_Close_Date__c < vProj.Project_Finish_Date__c) && (((mat.Territory__c == 'US' || mat.Territory__c =='US & CDN') && vProj.Sales_Org__c == 'US') || ((mat.Territory__c == 'CDN' || mat.Territory__c =='US & CDN') && vProj.Sales_Org__c == 'CDN'))){
                                    system.debug('Check point 12---');
                                        createVMaterial(mat.Id,vProj.Id,mat.Material_Number__c,mat.Name,mat.Material_Status__c);
                                        vMatCreated = true;
                                        break;   
                                    }
                                    
                                }
                            }
                            
                            if(vMatCreated)
                                break;
                        }
                    }else if(releaseVprojectMap != null && releaseVProjectMap.containskey(mat.Release__c)){
                        for(v_Project_Request__c vProj : releaseVProjectMap.get(mat.Release__c))
                        {
                            System.debug('&&&&&& Material Internal Announce Date'+mat.Internal_Announce_Date__c+' '+vProj.Project_Finish_Date__c);
                            if((mat.Pre_Order_Close_Date__c < vProj.Project_Finish_Date__c) && (((mat.Territory__c == 'US' || mat.Territory__c =='US & CDN')  && vProj.Sales_Org__c == 'US') || ((mat.Territory__c == 'CDN' || mat.Territory__c =='US & CDN') && vProj.Sales_Org__c == 'CDN')))
                            {
                            system.debug('Check point 13---');
                                createVMaterial(mat.Id,vProj.Id,mat.Material_Number__c,mat.Name,mat.Material_Status__c);
                                vMatCreated = true;
                            }
                            if(vMatCreated)
                                break;
                        }
                        
                    } 
                }
            }
        }
         /*************/
        
        if(insertableTasks.size() > 0)
            vProjectUtility.createTask(insertableTasks);
        
        if(insertableVMaterials.size() > 0){
        system.debug('Check point 14---');
            //insert insertableVMaterials;
            upsert insertableVMaterials;
            system.debug('Check point 15---'+insertableVMaterials[0].id);
        }
       // if(!vList.isEmpty())
           // allocateVMaterials(vList); //commented for 101 error - USST-2780
        
        /*************/
        
        /*if(insertableTasks.size() > 0){
            vProjectUtility.createTask(insertableTasks);
        }*/
        
        if(updateableVMaterials.size() > 0)
        {
            update updateableVMaterials.values();
        }
        
        if(!vList.isEmpty()){
            allocateVMaterials(vList);
        }
        
    }
    //Method to calculate the allocation percentage on the v-project record.
    public static void allocateVMaterials(set<Id> vProjectId)
    {
        Map<ID,String> mapObjID = new Map<ID,string>();
        List<Task> insertableTasks = new List<Task>();
        Map<Id, List<v_Material__c>> vProjMaterialMap = new Map<Id, List<v_Material__c>>();
        
        for(v_Material__c vMat : [SELECT Id, Status__c, Material__c, Material__r.Name, v_Project__c FROM v_Material__c WHERE v_Project__c IN: vProjectId LIMIT 10000])
        {
            if(!vProjMaterialMap.containsKey(vMat.v_Project__c))
                vProjMaterialMap.put(vMat.v_Project__c, new List<v_Material__c>());
            vProjMaterialMap.get(vMat.v_Project__c).add(vMat);
        }
        
        for(v_Project_Request__c vProject : [SELECT Id, Title__c, 
                                             (SELECT Id FROM Tasks) 
                                             FROM v_Project_Request__c 
                                             WHERE Id in: vProjectId]) {
                                                 if(vProject != null)
                                                 {
                                                     List<v_Material__c> pendingVMats = new List<v_Material__c>();
                                                     List<v_Material__c> activeVMats = new List<v_Material__c>();
                                                     
                                                     List<v_Material__c> associatedVMats;
                                                     if(vProjMaterialMap.containsKey(vProject.Id))
                                                         associatedVMats = vProjMaterialMap.get(vProject.Id);
                                                     
                                                     if(associatedVMats != null && associatedVMats.size() > 0)
                                                     {
                                                         for(v_Material__c vMat : associatedVMats)
                                                         {
                                                             if(vMat.Status__c == 'Pending')
                                                                 pendingVMats.add(vMat);
                                                             else if(vMat.Status__c == 'Active')
                                                                 activeVMats.add(vMat);
                                                         }
                                                     }
                                                     
                                                     // Checking if there is any v-Material pending in v-Project.
                                                    //Commented for RE-39
                                                     /*if(pendingVMats.size() > 0)
                                                     {
                                                         return;
                                                     }*/
                                                     if(activeVMats.size() > 0)
                                                     {
                                                         String taskSubject = 'Update Allocation %';
                                                         if(!mapObjID.containsKey(vProject.ID)){
                                                             mapObjID.put(vProject.ID,taskSubject);
                                                         }
                                                         
                                                         
                                                         // If V-Project has SYSGEN.
                                                         if(vProject.Title__c != null)
                                                         {
                                                             insertableTasks.add(new Task(WhatId=vproject.id, Subject=taskSubject, Activity_Description__c='Set generic DVD material allocation to 100%'));
                                                         }
                                                         else
                                                         {
                                                             // If there is active vMaterial(s), create task(s).
                                                             if(activeVMats.size() > 0)
                                                             {
                                                                 Decimal allocation = decimal.valueOf(100) / activeVMats.size();
                                                                 
                                                                 for(v_Material__c vMat : activeVMats)
                                                                 {
                                                                     String taskDescription = 'Set ' + vMat.Material__r.Name + ' allocation to ' + allocation.setScale(2) + '.';
                                                                     insertableTasks.add(new Task(WhatId=vproject.id, Subject=taskSubject, Activity_Description__c=taskDescription));
                                                                 }
                                                             }
                                                         }
                                                     }
                                                 }                                            
                                             }
        
        if(!mapObjID.isEmpty()){
            deleteTask(mapObjID);
        }
        
        if(insertableTasks.size() > 0)
            createTask(insertableTasks);
    }
    //Method to delete an existing task on the v-project record
    public static void deleteTask(Map<ID,String> mapObjID){             
        if(mapObjID != null){
            List<Task> taskList = [Select id from Task where whatId in: mapObjID.keyset() and Subject in: mapObjID.values() and Status = 'Not Started'];
            if(taskList.size() > 0){
                delete taskList;
            }
        }
    }
    
    //Method to update the v-project dates if street date/ pre-order date is changed on a release
    public static void updateVProjectfromRelease(List<Release__c> rList){
        List<v_Project_Request__c> vprList = new List<v_Project_Request__c>();
        Map<ID,String> mapObjID = new Map<ID,string>();
        
        for(Release__c r : rList){
            if(r.v_Project__c != null  &&  ((r.Street_Date__c != Trigger.oldMap.get(r.Id).get('Street_Date__c')) || (r.Pre_Order_Close_Date__c != Trigger.oldMap.get(r.Id).get('Pre_Order_Close_Date__c')))){
                
                if(!mapObjID.containsKey(r.v_Project__c)){
                    mapObjID.put(r.v_Project__c,'Update v-Project Date Fields');
                }
                
                v_Project_Request__c vpr = new v_Project_Request__c();
                vpr.id = r.v_Project__c;
                if(r.Street_Date__c != null && r.Street_Date__c != Trigger.OldMap.get(r.id).get('Street_Date__c')){
                    vpr.Project_Finish_Date__c = r.Street_Date__c + 240;
                    vpr.POS_Order_End_Date__c = r.Street_Date__c + 180;
                    vpr.Return_End_Date__c = r.Street_Date__c + 240;
                }
                vprList.add(vpr);
                system.debug('vprList== '+vprList);
            }
        }
        
        if(vprList.size() > 0){
            update vprList;
        }
        
    }
    
    //Method to delete the v-material record and create a task
    public static void removeVMaterial(List<Material__c> lstMaterialDetails, Map<ID,SET<ID>> mapMatRelRelationship){
        if(!lstMaterialDetails.isEmpty()){
            
            List<v_Material__c> lstVMaterial = new List<v_Material__c>();
            for(v_Material__c vMaterial : [Select ID, Material__c, Status__c, Material__r.Name,Material__r.Material_number__c, v_Project__c, v_Project__r.Status__c, v_Project__r.Release__c 
                                           from v_Material__c where Material__c IN:lstMaterialDetails])//Added Material__r.Material_number__c as part of  RE-12
            {
                if(mapMatRelRelationship !=null && mapMatRelRelationship.size() > 0)
                {
                    if(mapMatRelRelationship.containsKey(vMaterial.Material__c) && mapMatRelRelationship.get(vMaterial.Material__c).contains(vMaterial.v_Project__r.Release__c))
                    {
                        lstVMaterial.add(vMaterial);
                    }
                }
                else
                {
                    lstVMaterial.add(vMaterial);
                }
            }
            
            List<v_Material__c> lstToDelete = new List<v_Material__c>();
            List<v_Material__c> lstToUpdate = new List<v_Material__c>();
            Set<ID> setAllocateVProjectID = new Set<ID>(); 
            List<Task> insertableTasks = new List<Task>();          
            system.debug('lstVMaterial=== '+lstVMaterial);
            for(v_Material__c vm : lstVMaterial ){
                //Commented for RE-39
                /*if(vm.v_Project__r.Status__c == 'Pending'){
                    lstToDelete.add(vm);
                }*/
                system.debug('status=== '+vm.status__c);
                if(vm.Status__c != 'Inactive'){
                    vm.Status__c = 'Inactive';
                    vm.Marked_for_Inactivation__c = TRUE;
                    
                    lstToUpdate.add(vm);
                    
                    //Releaseforce2.0 ----> RE-12 ----> Updated task description with Material number of the material when the associated VMaterial will be removed.
                    
                    if(vm.Material__r.Material_number__c != null && vm.Material__r.Material_number__c!=''){
                        system.debug('inside if');
                        insertableTasks.add(new Task(WhatId=vm.v_Project__c, Subject='Remove WBSE From Project',Activity_Description__c='Please mark the following WBSE as inactive: ' +vm.Material__r.Material_number__c+' - '+vm.Material__r.Name + '.' ));
                    }
                    else{
                        system.debug('inside else');
                        //insertableTasks.add(new Task(WhatId=vm.v_Project__c, Subject='Remove WBSE From Project',Activity_Description__c='Please mark the following WBSE as inactive: ' + vm.Material__r.Name + '.' )); //USST-2501
                    }
                }
                system.debug('setAllocateVProjectID== '+setAllocateVProjectID); 
                if(!setAllocateVProjectID.contains(vm.v_Project__c)){
                    setAllocateVProjectID.add(vm.v_Project__c);
                }            
            }
            
           /* if(!lstToDelete.isEmpty()){
                delete lstToDelete;
            }*/
            
            if(!lstToUpdate.isEmpty()){
                update lstToUpdate;
            }
            system.debug('setAllocateVProjectID== '+setAllocateVProjectID); 
            if(!setAllocateVProjectID.isEmpty()){
                allocateVMaterials(setAllocateVProjectID);
            }
            system.debug('insertableTasks== '+insertableTasks); 
            if(insertableTasks.size() > 0){
                vProjectUtility.createTask(insertableTasks);
            }
            if(!setAllocateVProjectID.isEmpty()){
                allocateVMaterials(setAllocateVProjectID);
            }
        }        
    }
    
    //Method to create a task when any of the field are updated on the v-project record.
    public static Boolean shouldExecute = true;
    public static void updateVProject(List<v_Project_Request__c> vprjList){
        if(!shouldExecute)
            return;
        
        system.debug('inside method updateVProject');
        List<v_Project_Request__c> vprList = new List<v_Project_Request__c>();
        Map<ID,String> mapObjID = new Map<ID,string>();
        
        for(v_Project_Request__c r : vprjList){
            if(r.Street_Date__c != null && (r.Street_Date__c != Trigger.oldMap.get(r.Id).get('Street_Date__c')) || 
               (r.Pre_Order_Date__c != null && (r.Pre_Order_Date__c != Trigger.oldMap.get(r.Id).get('Pre_Order_Date__c'))) || 
               //(r.Active_Task_Count__c != null && (r.Active_Task_Count__c != Trigger.oldMap.get(r.Id).get('Active_Task_Count__c'))) ||
               (r.Label_Code__c != null && (r.Label_Code__c != Trigger.oldMap.get(r.Id).get('Label_Code__c'))) || 
               (r.Original_Release_Date__c != null && (r.Original_Release_Date__c != Trigger.oldMap.get(r.Id).get('Original_Release_Date__c'))) || 
               (r.POS_Order_End_Date__c != null && (r.POS_Order_End_Date__c != Trigger.oldMap.get(r.Id).get('POS_Order_End_Date__c'))) || 
               (r.Project_Category__c != null && (r.Project_Category__c != Trigger.oldMap.get(r.Id).get('Project_Category__c'))) || 
               (r.Project_Class__c != null && (r.Project_Class__c != Trigger.oldMap.get(r.Id).get('Project_Class__c'))) || 
               (r.Project_Finish_Date__c != null && (r.Project_Finish_Date__c != Trigger.oldMap.get(r.Id).get('Project_Finish_Date__c'))) || 
               (r.Project_Studio__c != null && (r.Project_Studio__c != Trigger.oldMap.get(r.Id).get('Project_Studio__c'))) || 
               (r.Project_Sub_Class__c != null &&(r.Project_Sub_Class__c != Trigger.oldMap.get(r.Id).get('Project_Sub_Class__c'))) || 
               (r.Release__c != null && (r.Release__c != Trigger.oldMap.get(r.Id).get('Release__c'))) || 
               (r.Return_End_Date__c != null && (r.Return_End_Date__c != Trigger.oldMap.get(r.Id).get('Return_End_Date__c'))) || 
               (r.Sales_Org__c != null && (r.Sales_Org__c != Trigger.oldMap.get(r.Id).get('Sales_Org__c'))) || 
               (r.SAP_Project_Description__c != null && (r.SAP_Project_Description__c != Trigger.oldMap.get(r.Id).get('SAP_Project_Description__c'))) || 
               //(r.Status__c != null && (r.Status__c != Trigger.oldMap.get(r.Id).get('Status__c'))) || 
               (r.Title__c != null && (r.Title__c != Trigger.oldMap.get(r.Id).get('Title__c'))) || 
               (r.Total_Allocation_Percentage__c != null && (r.Total_Allocation_Percentage__c != Trigger.oldMap.get(r.Id).get('Total_Allocation_Percentage__c')))){ 
               //(r.v_Project_Number__c != null && (r.v_Project_Number__c != Trigger.oldMap.get(r.Id).get('v_Project_Number__c'))) || 
               //(r.v_Project_Status__c != null && (r.v_Project_Status__c != Trigger.oldMap.get(r.Id).get('v_Project_Status__c')))
               
                   system.debug('inside method updateVProject for loop');
                   if(!mapObjID.containsKey(r.id)){
                       mapObjID.put(r.id,'Update v-Project Date Fields');
                   }
                   
                   v_Project_Request__c vpr = new v_Project_Request__c();
                   vpr.id = r.id;
                   if(r.Street_Date__c != null && r.Street_Date__c != Trigger.OldMap.get(r.id).get('Street_Date__c')){
                       vpr.Project_Finish_Date__c = r.Street_Date__c + 240;
                       vpr.POS_Order_End_Date__c = r.Street_Date__c + 180;
                       vpr.Return_End_Date__c = r.Street_Date__c + 240;
                       vpr.Project_Studio__c = '001';
                       if(vpr.Label_Code__c == '62 - Focus'){
                           vpr.Project_Studio__c = '005';
                       }
                   }
                   vprList.add(vpr);
                   system.debug('vprList== '+vprList);
               }
        }
        
        if(!mapObjID.isEmpty()){
            deleteTask(mapObjID);
        }
        
        if(vprList.size() > 0){
            update vprList;
        }
        
        List<Task> insertableTasks = new List<Task>();
        for(v_Project_Request__c vproject : vprjList){
            if(vproject.OwnerId != Trigger.oldMap.get(vproject.Id).get('OwnerId') || vproject.v_Project_Number__c != Trigger.oldMap.get(vproject.Id).get('v_Project_Number__c'))
                continue;
            insertableTasks.add(new Task(WhatId=vproject.id, Subject='Update v-Project Date Fields', Activity_Description__c='Please ensure SAP matches all fields in v-Project header'));
        }
        
        if(insertableTasks.size() > 0)
            createTask(insertableTasks);
    }
    //Method to create v-material called from addVMaterial method
    public static void createVMaterial(Id matID,Id vProjId,String matNumber,String matName,String matStatus){
        
        v_Material__c vMat = new v_Material__c();
        vMat.Material__c = matID;
        vMat.v_Project__c = vProjId;
        if(matNumber != null)
        {
            vMat.Status__c = 'Active';
            //Updated Activity Description RB2
            insertableTasks.add(new Task(WhatId=vProjId, Subject='Create WBSE', Activity_Description__c='Please add  a WBSE for ' + matNumber +' - '+ matName));
            vList.add(vProjId);
        }
        else
            vMat.Status__c = 'Pending';
        
        insertableVMaterials.add(vMat);
    }
    
        //Releaseforce2.0 ----> RE-11 ----> Add Task to cancel the V-project if Release gets cancelled and the associated vMaterials are all inactive.
    public static void cancelVProject(Set<id>releaseId){
        Set<Id>vProjectIdSet= new Set<Id>();
        List<id> vProjectList=new List<id>();
        Set<Id>vProjActiveId=new Set<Id>();
        List<Task> insertableTasks = new List<Task>();
        List<v_Project_Request__c> updatevProjectList=new List<v_Project_Request__c>();
        
        for(v_Project_Request__c vProj:[Select id from v_Project_Request__c where Release__c in:releaseId]){
            vProjectIdSet.add(vProj.id);
        }
        
        for(v_Material__c vMat:[Select id,Status__c,v_Project__c from v_Material__c where v_Project__c in:vProjectIdSet and Status__c!='Inactive']){
            vProjActiveId.add(vMat.v_Project__c);
        }
        
        if(!vProjActiveId.isEmpty()){
            vProjectIdSet.removeAll(vProjActiveId); 
        }
        
        if(!vProjectIdSet.isEmpty()){
            vProjectList.addAll(vProjectIdSet);
            for(Id vProjId: vProjectList){
                insertableTasks.add(new Task(WhatId=vProjId, Subject='Cancel V-Project', Activity_Description__c='Please cancel this V-Project '));
            }   
        }
        
        if(insertableTasks.size() > 0){
            vProjectUtility.createTask(insertableTasks);
        }
        
        for(v_Project_Request__c vProjUpdate:[Select id,Project_Finish_Date__c from v_Project_Request__c where id in:vProjectIdSet]){
            vProjUpdate.Project_Finish_Date__c=system.today();
            updatevProjectList.add(vProjUpdate);
        }    
        
        if(!updatevProjectList.isEmpty()){
            update updatevProjectList;
        }
    }
}