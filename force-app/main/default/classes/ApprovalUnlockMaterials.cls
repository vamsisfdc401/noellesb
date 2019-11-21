/*****************************************************************************************
Class Name: ApprovalUnlockMaterials
Purpose: This class handles to unlock materials in system mode. Called from with sharing classes
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             5/29/2017           Dinakar              Initial Development
******************************************************************************************/
public without sharing class ApprovalUnlockMaterials{
    public static void materialUnlock(List<ID> lstRecordsToUnlock){
        List<Material__c> lstMaterial = [select id from material__c where id in :lstRecordsToUnlock];
        for (Material__c mat : lstMaterial ) {
            if (Approval.isLocked(mat)) {
                Approval.unlock(mat.id);
            }
        }
        
    }

}