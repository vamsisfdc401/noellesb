/*****************************************************************************************
Class Name: TMVersionExt
Purpose: Used for linking material to TM version
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             11/09/2016           Pawel                    Initial Development
******************************************************************************************/
public with sharing class TMVersionExt {
    
    public Material__c material {get;set;}
    public String tmVersion {get;set;}
    public String SUCCESS {get;set;}
    public List<SelectOption> tmVersionOpt {get;set;}
    public Release__c release {get;set;}
    public Boolean refreshPage { get; set;}
    public List<Material__c>   materials ;
    public set<Id> relId = new set<Id>();
    public Boolean isReleaseWindow {get {
        if(isReleaseWindow == null) {
            isReleaseWindow =false;
        }
        return isReleaseWindow;
    } set;}
    
    public Boolean isMaterialWindow {get {
        if(isMaterialWindow == null) {
            isMaterialWindow =false;
        }
        return isMaterialWindow;
    } set;}
    
    // Following method is extension constructor of the class.
    public TMVersionExt(ApexPages.StandardController controller) {
        SUCCESS = 'false';
        refreshPage=false;
        ID objId =  controller.getId();
        String ObjName =String.valueOf(objId.getsObjectType());
        if(ObjName == 'Material__c') {
            isMaterialWindow =true;
        } else if(ObjName == 'Release__c') {
            isReleaseWindow =true;
        }
        if(isMaterialWindow) {
            materials = [select id,SGENNO_ReadOnly__c,TM_Version_Lookup__c,Title__c,TM_Version_Lookup__r.name, Material_Status__c,release__r.Title__c,release__r.TM_Version__c,release__c from Material__c where id= :objId ];
            if(materials.size() >0) {
                material = materials[0];
                relId.add(material.release__c); 
                if(material.release__c!=null && material.release__r.Title__c != null){
                    tmVersionOpt = TMVersionUtil.getTmVersionTitle(material.release__r.Title__c);
                }else if(material.Title__c != null){
                    tmVersionOpt = TMVersionUtil.getTmVersionTitle(material.Title__c);
                }
            }
        }else  if(isReleaseWindow) {
            List<Release__c>   releaseList = [select id,Title__c,TM_Version__c,TM_Version__r.name from Release__c where id= :objId ];
            if(releaseList.size() >0) {
                release = releaseList[0];
                tmVersionOpt = TMVersionUtil.getTmVersionTitle(release.Title__c);
                System.debug('##############tmVersionOpt'+tmVersionOpt);
                
            }
        }
    }
    
    // Following method handles the cancellation process.
    public PageReference cancel() {       
        refreshPage=true;
        return null;
    }    
    
    // Below method handles the complexity of Saving TM Version record.
    public PageReference SaveTM(){
        SUCCESS = 'false';
        
        list<Release__c > updateRel = new List<Release__c>();
        if(TMVersionUtil.Blank == tmVersion) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,
                                                       'Please Select TM version'));
            return null;
        }
        // Checking if material is windowed.
        if(isMaterialWindow) {
            
            material.TM_Version_Lookup__c = tmVersion;
            for(Release__c each : [Select Id,TM_Version__c from Release__c where Id IN:relId]){
                each.TM_Version__c =  tmVersion;             
                updateRel.add(each); 
            }
            try{
                update updateRel;  
                update material;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,
                                                           'TM version added successfully'));
                SUCCESS = 'true';
                
                PageReference materialPage = Page.TMVersion;
                materialPage.getParameters().put('Id',material.id);
                materialPage.setRedirect(true);
                return materialPage;
                
            } catch(Exception ex) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Record is locked.'));
            } 
        }else if (isReleaseWindow) {
            release.TM_Version__c = tmVersion;
            try{
                
                update release;
                
                PageReference releasePage = Page.ReleaseTMVersion;
                releasePage.getParameters().put('Id',release.id);
                releasePage.setRedirect(true);
                return releasePage;
            } catch(Exception ex) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Record is locked.'));
            } 
        }
        return null;
        
    }
}