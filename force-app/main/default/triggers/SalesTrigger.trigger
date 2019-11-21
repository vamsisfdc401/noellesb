/*****************************************************************************************
Trigger Name: SalesTrigger
Purpose: Trigger handling Sales DML Events
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             02/08/2016                                    Initial Development
******************************************************************************************/
trigger SalesTrigger on Sales__c (before Insert, before Update, after Update,after Insert,before delete) 
{
    // Checking for restricting recursive call.
    if(!TriggerUtility.hasTriggerExecuted('Sales__c'))
    {
        String uProfileName;
    
        IF (TriggerUtility.currentUser != null){
            uProfileName = TriggerUtility.currentUser.Profile.Name;
        }
        
        // Handling Before events
        if(Trigger.isBefore)
        {
            // Scope for Before Insert
            if(Trigger.isInsert)
            {
                SalesTriggerHandler.executeOnBeforeInsert();
            }
            // Scope for Before Update
            else if(Trigger.isUpdate)
            {
                SalesTriggerHandler.executeOnBeforeUpdate();
            }
            if(Trigger.isDelete)
            {
                SalesTriggerHandler.executeOnBeforeDelete(Trigger.old);
            }
        }
        // Handling After events
        else
        {
            // Scope for After Insert
            if(Trigger.isInsert)
            {
                SalesTriggerHandler.executeOnAfterInsert();
                if(TriggerUtility.checkFromCloning){
                    TriggerUtility.doNotExecute = TRUE; 
                }
            }
            else if(Trigger.isUpdate && uProfileName == 'Platform API'){
                //SalesTriggerHandler.UpdateMaterialStatus(trigger.new);
                SalesTriggerHandler.updateStreetDateOnMaterial(trigger.new);
            }
            // Scope for After Update
            else if(Trigger.isUpdate && uProfileName != 'Platform API')
            {
                SalesTriggerHandler.executeOnAfterUpdate();
            }
            // Scope for After Delete
            else if(Trigger.isDelete)
            {
                
            }
        }
    }
    
    /*
     Below Commenetd code due to trigger was inActive. Going to use trigger for update date 
     Activated Trigger on 08/22/2016 -Durgesh
    */ 
      /*  Set<Id> materialIds = new Set<Id>();
    if(Trigger.IsInsert)
    {
        for(Sales__c sales : Trigger.New)
        {
            // If any of the sales DChain Spec is FR, change the parent material's DChain to FR.
            if(sales.D_Chain_Spec__c != null && sales.D_Chain_Spec__c.equalsIgnoreCase('FR - Future Release') &&
               sales.Material__c != null)
            {
                materialIds.add(sales.Material__c);
            }
        }
        
        // Updating the parent material status to FR.
        List<Material__c> updateableMaterials = new List<Material__c>();
        if(materialIds.size() > 0)
        {
            for(Id matId : materialIds)
            {
                Material__c mat = new Material__c();
                mat.Id = matId;
                mat.D_Chain_Spec__c = 'FR';
                
                updateableMaterials.add(mat);
            }
            
            update updateableMaterials;
        }
    }
    else if(Trigger.IsUpdate)
    {
        for(Id salesId : Trigger.newMap.keySet())
        {
            // If any of the sales DChain Spec is FR, change the parent material's DChain to FR.
            if(Trigger.newMap.get(salesId).D_Chain_Spec__c != Trigger.oldMap.get(salesId).D_Chain_Spec__c && 
               Trigger.newMap.get(salesId).Material__c != null)
            {
                materialIds.add(Trigger.newMap.get(salesId).Material__c);
            }
        }
        
        if(materialIds.size() > 0)
        {
            // Updating the parent material status to FR.
            List<Material__c> updateableMaterials = new List<Material__c>();
            for(Material__c mat : [SELECT Id, (SELECT Id FROM Sales__r WHERE D_Chain_Spec__c='FR - Future Release') 
                                   FROM Material__c WHERE Id IN :materialIds])
            {
                if(mat.sales__r.size() > 0)
                {
                    mat.D_Chain_Spec__c = 'FR';
                }
                else
                {
                    mat.D_Chain_Spec__c = '';
                }
                updateableMaterials.add(mat);
            }
            
            update updateableMaterials;
        }
    }*/
}