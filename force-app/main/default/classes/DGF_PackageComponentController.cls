/*****************************************************************************************
Class Name: DGF_PackageComponentController
Purpose: Controller for displaying related Bonus Packages
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             28/06/2017           Prarthana                Initial Development
******************************************************************************************/
public with sharing class DGF_PackageComponentController {
    
    /***********************************
    Method Name: fetchBonusRecords
    Purpose: method to fetch related bonus records
    ***********************************/    
    @AuraEnabled public static list<String> fetchBonusRecords(ID recordID) {
        list<String>returnList = new list<String>();
        list<EPO_Bonus__c> bonusList = new list<EPO_Bonus__c>();
        set<String>pkgSet = new set<String>();
        //query for the bonus records under the release
        bonusList = [SELECT ID, Name, Digital_Release__c, Description__c, Package__c, Run_Time_min_sec__c FROM EPO_Bonus__c 
                     where Digital_Release__c=:recordID];
        if(!bonusList.isEmpty()) {
            for(EPO_Bonus__c bonus:bonusList) {
                if(bonus.package__c != null) {
                    list<String>packageList = bonus.package__c.split(';');
                    for(String p:packageList) {
                        pkgSet.add(p);
                    }
                }
            }
            
            returnList.addAll(pkgSet);
            
        }
        return returnList;
    }
    
    /***********************************
    Method Name: getBonusDetails
    Purpose: method to get the details of Bonus Records
    ***********************************/    
    @AuraEnabled public static list<EPO_Bonus__c>getBonusDetails(String releaseId, String pkgName) {
        list<EPO_Bonus__c> bonusList = new list<EPO_Bonus__c>();
        if(pkgName!='All') {
            bonusList=[SELECT ID, Name,Description__c, Run_Time_min_sec__c, Package__c from EPO_Bonus__c where Digital_Release__c=:releaseId 
                       and Package__c INCLUDES (:pkgName)];
        }
        else {
            bonusList = [SELECT ID, Name, Description__c, Run_Time_min_sec__c, Package__c from EPO_Bonus__c where Digital_Release__c=:releaseId];
        }
        return bonusList;
    }
    
    /***********************************
    Method Name: getRecordTypeId
    Purpose: method to get recordType of the Bonus
    ***********************************/    
    @AuraEnabled public static Id getRecordTypeId() {
        Id FilmRecTypeId = Schema.SObjectType.EPO_Bonus__c.getRecordTypeInfosByName().get('Film Bonus').getRecordTypeId();    
        return FilmRecTypeId;
    }
    /***********************************
    Method Name: getRecordTypeId
    Purpose: method to get recordType of the Bonus
    ***********************************/    
    @AuraEnabled public static String getReleaseName(String releaseId) {
        Digital_Release__c rel = [SELECT ID, Name from Digital_Release__c where id=:releaseId];
        return rel.Name;
    }
    
    
    /***********************************
    Method Name: createBonusRecord
    Purpose: method to create Bonus Shell Record
    ***********************************/  
    @AuraEnabled public static list<String> createBonusRecord(String recordID, String packageSelected,list<String> pkgList) {
        //get recordType ID of Bonus
        Id FilmRecTypeId = Schema.SObjectType.EPO_Bonus__c.getRecordTypeInfosByName().get('Film Bonus').getRecordTypeId(); 
        //query for the release
        Digital_Release__c rel = [SELECT ID, US_EPO_Date__c, US_EST_Date__c, US_VOD_Start_Date__c from Digital_Release__c where id=:recordID];
        //create a new bonus record
        EPO_Bonus__c bonus = new EPO_Bonus__c(Name = packageSelected+' Package',Package__c = packageSelected,Digital_Release__c = recordID,recordTypeId = FilmRecTypeId);
        //default the dates from the release
        if(packageSelected == 'iTunes Extras') {
            bonus.Platform__c = 'EST';
        }
        if(packageSelected == 'Pre-Order') {
            bonus.Start_Date__c = rel.US_EPO_Date__c;
        }
        else if(packageSelected == 'iTunes Extras' || packageSelected == 'A la carte' || packageSelected == 'CPE') {
            bonus.Start_Date__c=rel.US_EST_Date__c;
        }
        
        bonus.VOD_Start_Date__c =rel.US_VOD_Start_Date__c;  
        
        try {
            database.insert(bonus);
            pkgList.add(packageSelected);
        }
        catch(Exception e) {
             throw new AuraHandledException(e.getMessage());
        }
        return pkgList;
    }
    
    /***********************************
        Method Name: getProfileDetails
        Purpose: method to get the profile of logged in user
        ***********************************/  
    @AuraEnabled public static boolean getProfileDetails() {
        User u = [Select id, name, Profile.Name from User where ID =:userinfo.getUserID()];
        if(u != null && (u.Profile.Name == DGF_Constants.PROFILE_PRODUCT_USER || u.Profile.Name == DGF_Constants.PROFILE_SYS_ADMIN || 
                         u.Profile.Name =='DD Marketing User')) {
            return false;
        }
        else{
            return true;
        }
    }
    
    /***********************************
    Method Name: removePackage
    Purpose: method to remove the package
    ***********************************/  
    @AuraEnabled public Static list<String>removePackage(String recordID,String packageRemoved,list<String>pkgList) {
        list<EPO_Bonus__c>updateList = new list<EPO_Bonus__c>();
        list<EPO_Bonus__c>deleteList = new list<EPO_Bonus__c>();
        list<String>returnList = new list<String>();
        //query for the bonus records under the release
        list<EPO_Bonus__c>bonusList = [SELECT ID,Name,Package__c from EPO_Bonus__c where Digital_release__c=:recordID];
        for(EPO_Bonus__c bonus :bonusList ) {
            //if the bonus contains only the unchecked package then add the bonus to the delete list
            if(bonus.Package__c != null &&  bonus.Package__c.contains(packageRemoved) && !bonus.Package__c.contains(';')) {
                deleteList.add(bonus);
            }
            //remove the unchecked package
            else if(bonus.Package__c != null && bonus.Package__c.contains(packageRemoved) && bonus.Package__c.contains(';')) {
                list<String>pkList=bonus.Package__c.split(';');
                bonus.Package__c = '';
                for(String s :pkList) {
                    if(s!=packageRemoved) {
                        if(bonus.Package__c == '') {
                            bonus.Package__c = s;
                        }
                        else {
                            bonus.Package__c += ';'+s;
                        }
                    }
                }
                updateList.add(bonus);
            }
        }
        for(String p:pkgList ) {
            if(p!=packageRemoved) {
                returnList.add(p);
            }
        }
        try {
            if(!updateList.isEmpty()) {
                database.update(updateList);
            }
            if(!deleteList.isEmpty()) {
                database.delete(deleteList);
            }
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return returnList;
    }
    
}