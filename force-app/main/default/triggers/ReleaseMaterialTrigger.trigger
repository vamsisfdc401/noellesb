/*****************************************************************************************
Trigger Name: ReleaseMaterialTrigger
Purpose: Trigger handling Release Material DML Events
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             02/08/2016                                    Initial Development
******************************************************************************************/

trigger ReleaseMaterialTrigger on Release_Material__c (After Insert, After Delete) 
{
    if(!TriggerUtility.hasTriggerExecuted('Release_Material__c'))
    {
        if(Trigger.isAfter && Trigger.isInsert)
        {
            Map<Id, Set<Id>> materialReleaseMap = new Map<Id, Set<Id>>();
            Map<Id, Set<Id>> releaseMaterialMap = new Map<Id, Set<Id>>();
            Set<Id> matIds = new Set<Id>();
            
            for(Release_Material__c relMat : Trigger.new)
            {
                matIds.add(relMat.Material__c);
                
                if(!materialReleaseMap.containsKey(relMat.Material__c))
                {
                    materialReleaseMap.put(relMat.Material__c, new Set<Id>());
                }
                materialReleaseMap.get(relMat.Material__c).add(relMat.Release__c);
                
                if(!releaseMaterialMap.containsKey(relMat.Release__c))
                    releaseMaterialMap.put(relMat.Release__c, new Set<Id>());
                releaseMaterialMap.get(relMat.Release__c).add(relMat.Material__c);
            }
            
            Map<Id,Material__c> mapMatList = new Map<Id,Material__c>([SELECT Id, Name, Material_Status__c,Pre_Order_Close_Date__c, Item_Type__c,Material_Type__c, Title__c, Release__c, Internal_Announce_Date__c,Item_Code__c, Territory__c,Material_Number__c
                                         FROM Material__c WHERE Id IN: matIds]);
            vProjectUtility.addVMaterials(mapMatList.values(), materialReleaseMap);
            
            List<Release__c> updateableReleaseList = new List<Release__c>();
            for(Id relId : releaseMaterialMap.keySet()){
                Boolean hasProcessedMat = false;
                for(Id matId : releaseMaterialMap.get(relId)) {
                    if(mapMatList.containsKey(matId) && mapMatList.get(matId).Material_Type__c == 'FERT' && 
                       mapMatList.get(matId).Material_Status__c != 'Draft' && mapMatList.get(matId).Material_Status__c != 'Sent Back')
                    {
                        hasProcessedMat = true;
                        break;
                    }
                }
                
                if(hasProcessedMat)
                {
                    Release__c rel = new Release__c(Id=relId, Release_Status__c='Materials Requested');
                    updateableReleaseList.add(rel);
                }
            }
            
            if(updateableReleaseList.size() > 0)
                update updateableReleaseList;
        }
        else if(Trigger.isAfter && Trigger.isDelete)
        {
            Map<Id, Set<Id>> materialReleaseMap = new Map<Id, Set<Id>>();
            Set<Id> matIds = new Set<Id>();
            //Added for Activity Related changes on 10thNov.
            List<Task> taskList = new List<Task>();
            Map<Id,Material__c>materialMap = new Map<Id,Material__c>();
            Set<Id> relIds = new Set<Id>();
            List<Material__c> matList = new List<Material__c> ();
            
            for(Release_Material__c relMat : Trigger.old)
            {
                matIds.add(relMat.Material__c);
                relIds.add(relMat.release__c);//Added for Activity Related changes on 10thNov
                
                if(!materialReleaseMap.containsKey(relMat.Material__c))
                {
                    materialReleaseMap.put(relMat.Material__c, new Set<Id>());
                }
                materialReleaseMap.get(relMat.Material__c).add(relMat.Release__c);
                               
            }
            //Added for Activity Related changes on 10thNov
            for(Material__c mat :[SELECT Id, Name, Material_Status__c, Item_Type__c, Title__c, Internal_Announce_Date__c, Component_Type__c, Format__c,Item_Code__c,
                                      Material_Number__c, Street_Date__c, Label_Code__c FROM Material__c WHERE Id IN: matIds]) {
                   matList.add(mat);
                   if (mat.Material_Status__c == 'Processed in SAP') {
                   		materialMap.put(mat.id,mat);                      
                   }  	
           }
           //Commented on 10th Nov - this has been moved to the above loop
            /*List<Material__c> matList = [SELECT Id, Name, Material_Status__c, Item_Type__c, Title__c, Internal_Announce_Date__c
                                         FROM Material__c WHERE Id IN: matIds];*/
                                                                       
            vProjectUtility.removeVMaterial(matList, materialReleaseMap);
            
            
            //Added below code for Activity Related changes on 10thNov
            Map<Id,Release__c> releaseMap = new Map<Id,Release__c> ([Select Id, Name from Release__c where id in : relIds]);
            
            for (Release_Material__c relMat : Trigger.old) {
            	if (materialMap != null && materialMap.containsKey(relMat.Material__c)){
            		Task objTask = new Task();
                objTask.Subject = 'Material Removed';
                objTask.Description = 'Material Name: '+ materialMap.get(relMat.Material__c).Name + '\n' + 'Removed By '+ userinfo.getName() + '\n' + 'DateTime: ' + DateTime.Now() ;
                objTask.Activity_Description__c = 'Material Name:'+ materialMap.get(relMat.Material__c).Name + 'Removed By: '+ userinfo.getName() ;
                objTask.Activity_Description__c = objTask.Activity_Description__c.left(120);
                objTask.WhatId = Id.valueof(relMat.Release__c);
                objTask.Status = 'Completed';
                objTask.Component_Type__c=materialMap.get(relMat.Material__c).Component_Type__c;
                objTask.Format__c=materialMap.get(relMat.Material__c).Format__c;
                objTask.Item_Code__c=materialMap.get(relMat.Material__c).Item_Code__c;
                objTask.Material_Number__c=materialMap.get(relMat.Material__c).Material_Number__c;
                 if (releaseMap != null && releaseMap.containsKey(relMat.release__c)) {
                    objTask.Release_Name__c = releaseMap.get(relMat.release__c).Name;
                 }
                objTask.Street_Date__c = materialMap.get(relMat.Material__c).Street_Date__c;
                objTask.material__c =relMat.Material__c;
                objTask.Label_Code__c = materialMap.get(relMat.Material__c).Label_Code__c;
                objTask.MaterialDescription_SmartSheet__c = materialMap.get(relMat.Material__c).name;
                taskList.add(objTask);
            	}
            }
            
            if (!taskList.isEmpty()){
            	insert taskList;
            }
            
        }
    }
}