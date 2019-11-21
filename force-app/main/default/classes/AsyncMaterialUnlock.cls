/*****************************************************************************************
Class Name: AsyncMaterialUnlock
Purpose: Apex class to unlock material asynchronusly.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             20/06/2017           Suman                    Initial Development
******************************************************************************************/
public class AsyncMaterialUnlock implements Queueable {
    
    public Set<Id> materialIds;
    
    /************************************
    Method Name: execute
    Purpose: this method invoked to populate the default fields on plant record   
    *************************************/
    public void execute(QueueableContext context) {
        if(materialIds == null || materialIds.size() == 0)
            return;
        
        List<Material__c> lstMaterial = [select id, Name, Unlock_Me__c,material_status__c from material__c where id in :materialIds];
        
        for( Material__c mat : lstMaterial ){
            if (mat.Unlock_Me__c){
                Approval.Unlock(mat.id);
            }          
        }        
    }
}