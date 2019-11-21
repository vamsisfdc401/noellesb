/**********************************************************************************************************************
Class Name: BatchMassEmailCommunication
Purpose: Batch class to send email notification to users belongs to public group for created release at end of the day.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             16/10/2017           Jyothsna             Initial Development
***********************************************************************************************************************/
global without sharing class BatchMassEmailCommunication implements Database.Batchable<sObject>, Database.Stateful {
    //global class to store release details associate materials and components
    global class ReleaseHistory {
        global Release__c releaseRecord;
        global List<MaterialHistory> materials;
    }
    
    //global class to store materials and associated components
    global class MaterialHistory {
        global Material__c materialRecord;
        global List<Material__c> lstaddcomponent;
    }
    global List<ReleaseHistory> lstRelHistory = new List<ReleaseHistory>();
        
    // Fetching the complete context data.
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id CompRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Competitive').getRecordTypeId();       
        return Database.getQueryLocator('SELECT Id, Name, Brand_Group__c, Online_Consumer_Solicitation_Date__c, Street_Date__c,' + 
        'CreatedDate, LastModifiedDate FROM Release__c where RecordTypeId != :CompRecordTypeId AND CreatedDate = TODAY'); 
    }
        
    // Executing the batch process.
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try {
            // Grabing the record type id of Update material.
            Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
            Date todayDate = System.today();
            Set<Id> setRelIds = new Set<Id>();
            Set<Id> setMatIds = new Set<Id>();
            Set<Id> setCurrentRelIds = new Set<Id>();
            Map<String, Release__c> mapReleases = new Map<String, Release__c>();
            map<Id,List<Material__c>>  mapMaterialsAssociateToRel = new map<Id,List<Material__c>>();
            List<Material__History> lstMatHistory = new List<Material__History>();
            for (Release__c rel : (List<Release__c>) scope) {
                setRelIds.add(rel.Id);
                mapReleases.put(rel.Id, rel);
            }
                        
            Map<Id, Release_Material__c> mapReleaseMaterials = new Map<Id, Release_Material__c>
            ([Select Id, Material__c, Release__c FROM Release_Material__c WHERE Release__c IN :setRelIds]);
            for (Release_Material__c  relmat: mapReleaseMaterials.values()) {
                setMatIds.add(relmat.Material__c);
            }
                        
            //fetching materials which are processed in SAP
            Map<Id, Material__c> mapMaterials = new Map<Id, Material__c>([Select Id, Name, RecordTypeId, Item_Code__c, Material_Status__c, 
                                                                        Material_Number__c, Release__c, CreatedDate, LastModifiedDate,Component_Type__c  
                                                                        FROM Material__c WHERE RecordTypeId != :recTypeId and 
                                                                        Id IN :setMatIds and Material_Status__c IN ('Processed in SAP')]);
                        
            Map<Id,BOM_Item__c> mapBOMItems = new Map<Id,BOM_Item__c>([Select Id, Name, Material__c, Material_Component__c, Component_Number__c, 
                                                                      Material_Number__c 
                                                                      FROM BOM_Item__c 
                                                                      WHERE (Material__c IN : mapMaterials.keySet() OR 
                                                                      Material_Component__c IN : mapMaterials.keySet())]);  
            
            Boolean isChild = false;
            //list to hold direct materials associated to release
            List<Id> lstDirectMaterials = new List<Id>();
            for (Material__c mat1 : mapMaterials.values()) {   
                isChild = false;
                for (BOM_Item__c bom : mapBOMItems.values()) {
                    if (mat1.Id == bom.Material_Component__c) {
                        isChild = true;
                    }
                }
                if (!isChild) {
                    lstDirectMaterials.add(mat1.Id);    
                }   
            }
            
            for (Id matId : lstDirectMaterials) {
                if (mapMaterialsAssociateToRel.containsKey(mapMaterials.get(matId).Release__c)) {
                    (mapMaterialsAssociateToRel.get(mapMaterials.get(matId).Release__c)).add(mapMaterials.get(matId));
                }
                else {
                    List<Material__c> tempMat = new List<Material__c>();
                    tempMat.add(mapMaterials.get(matId));
                    mapMaterialsAssociateToRel.put(mapMaterials.get(matId).Release__c,tempMat);
                }   
            }   
            
            //Map holds direct material associated to release and their components
            Map<Id,List<Material__c>> lstMatTree = new Map<Id,List<Material__c>>();
            for(Id mat : lstDirectMaterials) {
                for(BOM_Item__c bom : mapBOMItems.values()) {
                    if(mat == bom.Material__c && bom.Material_Component__c != null) {
                        if(lstMatTree.containsKey(mat)) {
                            if(mapMaterials.get(bom.Material_Component__c) != null) {
                                (lstMatTree.get(mat)).add(mapMaterials.get(bom.Material_Component__c));
                            }   
                        }
                        else {
                            if(mapMaterials.get(bom.Material_Component__c) != null) { 
                                List<Material__c> tempMat = new List<Material__c>();
                                tempMat.add(mapMaterials.get(bom.Material_Component__c));
                                lstMatTree.put(mat,tempMat);
                            }   
                        }
                    }   
                }   
            }
            
            for(Release__c rel : mapReleases.values()) {
                List<MaterialHistory> lstmaterials = new List<MaterialHistory>();
                List<Material__c> lstcomponents;  // added as part of REL-194
                if(mapMaterialsAssociateToRel.keySet().contains(rel.Id)) {
                    for(Material__c mat: mapMaterialsAssociateToRel.get(rel.Id)) {
                        lstcomponents = new List<Material__c>(); // added as part of REL-194
                        if(lstMatTree.keySet().contains(mat.Id)) {
                            for(Material__c comp: lstMatTree.get(mat.Id)) {
                                //associating components whose ITEM CODE is DISC
                                if(comp.Item_Code__c == 'DS - DISC') {
                                    lstcomponents.add(comp);    
                                }   
                            }   
                        }
                        MaterialHistory tempMatHistory = new MaterialHistory();
                        tempMatHistory.materialRecord = mat;
                        tempMatHistory.lstaddcomponent = lstcomponents;
                        lstmaterials.add(tempMatHistory);
                    }
                }
                ReleaseHistory tempRelHistory = new ReleaseHistory();
                tempRelHistory.releaseRecord =  rel;
                tempRelHistory.materials = lstmaterials;
                lstRelHistory.add(tempRelHistory);
            }
        }
        // Managing the error.
        catch(Exception ex)
        {
            System.debug('-----ERROR> '+ex.getMessage());
        }
    }
    
    // Final method to be called once batch is complete.
    global void finish(Database.BatchableContext BC)
    {
        
        try {
            if(lstRelHistory.size()>0) {
                Set<String> lstPublicGroup = new Set<String>();
                lstPublicGroup.add(ReleaseTriggerHandler.UPHE_Biz_Comm_Public_Group);
                lstPublicGroup.add(ReleaseTriggerHandler.UPHE_Tech_Ops_Public_Group);
                Set<Id> setRelIds = new Set<Id>();
                Set<Id> setUserIds = new Set<Id>();
                List<EntitySubscription> lstUsersFollowRelease = new List<EntitySubscription>();
                map<Id,List<Id>> mapUsersFollowRelease = new map<Id,List<Id>>();
                Set<Id> setUsersPublicGroup = new Set<Id>();
                map<Id,String> mapUserEmail = new map<Id,String>();
                
                //set which hold users belongs to given public group
                setUsersPublicGroup = ReleaseTriggerHandler.userOfPublicGroup(lstPublicGroup);
                for(ReleaseHistory relhistory: lstRelHistory) {
                    setRelIds.add(relhistory.releaseRecord.Id); 
                }   
                //fetching users following releases
                lstUsersFollowRelease = [Select id,ParentId,SubscriberId from EntitySubscription where ParentId IN :setRelIds LIMIT 1000];
                                
                for(EntitySubscription follow : lstUsersFollowRelease) {
                    if(mapUsersFollowRelease.containsKey(follow.ParentId)) {
                        mapUsersFollowRelease.get(follow.ParentId).add(follow.SubscriberId);
                    }
                    else {
                        List<Id> tempId = new List<Id>();
                        tempId.add(follow.SubscriberId);
                        mapUsersFollowRelease.put(follow.ParentId,tempId);
                    }   
                    setUserIds.add(follow.SubscriberId);    
                }
                List<User> lstUserRecords = [Select id,Email from User where Id IN : setUserIds];
                for(User usr : lstUserRecords) {
                    mapUserEmail.put(usr.Id,usr.Email);
                }
               
                List<Messaging.SingleEmailMessage> lstEmailMessages = new List<Messaging.SingleEmailMessage>();
                Time defaultTime = Time.newInstance(0,0,0,0);
                for(ReleaseHistory relhistory: lstRelHistory) {
                    Set<String> setUserEmailIds = new Set<String> ();
                    List<String> lstUserEmailIds = new List<String> ();
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    String emailBody;
                    //Email notification will be send to the users following releases and belongs to public groups
                    if(mapUsersFollowRelease.keySet().contains(relhistory.releaseRecord.Id)) {
                        for(Id usrId: mapUsersFollowRelease.get(relhistory.releaseRecord.Id)) {
                            setUserEmailIds.add(mapUserEmail.get(usrId));
                        }
                        lstUserEmailIds.addAll(setUserEmailIds);
                        message.toAddresses = lstUserEmailIds;
                        message.subject = 'Release Created : ' + relhistory.releaseRecord.Name;
                        emailBody = '<p> <font size="3" face="verdana"> The following are Release updates </font> </p> '; 
                        emailBody = emailBody + '<p> &nbsp; &nbsp; <font size="2" face="verdana"> Release Name : <b>' + 
                                    relhistory.releaseRecord.Name + '</b> </font> </p>'; //REL-194
                        emailBody = emailBody + '<p> &nbsp; &nbsp; <font size="2" face="verdana"> Street Date : <b>' + 
                                    Datetime.newInstance(relhistory.releaseRecord.Street_Date__c,defaultTime).format('MMMM d, YYYY') + 
                                    '</b> </font> </p>'; //REL-194
                        for(MaterialHistory matHistory : relhistory.materials) {
                            emailBody = emailBody + '<p> &nbsp; &nbsp; &nbsp; &nbsp; <font size="2" face="verdana"> Material Description : <b>' + 
                            matHistory.materialRecord.Name + '</b>'; //REL-194
                            emailBody = emailBody + ' Material Number : <b>' + 
                            matHistory.materialRecord.Material_Number__c + '</b> </font> </p>'; 
                            for(Material__c mat : matHistory.lstaddcomponent) {
                                emailBody = emailBody + '<p> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <font size="2" face="verdana"> Component Description : <b>' +
                                mat.Name + '</b>'; 
                                emailBody = emailBody + ' Component Number : <b>' +
                                mat.Material_Number__c + '</b></font> </p>'; //REL-194
                            }   
                        }
                    }
                    message.htmlBody = emailBody;
                    if(message.toAddresses != null && message.toAddresses.size() > 0) {
                        lstEmailMessages.add(message);
                    }   
                    message = null;
                    lstUserEmailIds.clear();
                    emailBody = '';
                }
                if(lstEmailMessages != null && lstEmailMessages.size()>0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmailMessages);
                    if (results[0].success) {
                        System.debug('The email was sent successfully.');
                    } 
                    else {
                        System.debug('The email failed to send: ' + results[0].errors[0].message);
                    }   
                }
            }   
        }
        // Managing the error.
        catch(Exception ex)
        {
            System.debug('-----ERROR> '+ex.getMessage());
        }
    }
}