/*****************************************************************************************
Class Name: FutureMaterial 
Purpose: This class is called from Material Trigger to unlock material records.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             17/01/2016           Ipsita                   Initial Development
******************************************************************************************/
public class FutureMaterial {

    // Following method is responsible to unlock material record.
    @future
    public static void unlockMaterial(set<id> Materials){
        
        List<Material__c> lstMaterial = [select id, Name, Unlock_Me__c,material_status__c from material__c where id in :Materials ];
        
        for( Material__c mat : lstMaterial ){
            if (mat.Unlock_Me__c){
                Approval.Unlock(mat.id);
                //mat.Unlock_Me__c = false;
                //TriggerUtility.doNotExecute =true;
                //update mat;
            }          
        }        
    }
    
}