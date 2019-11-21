/*****************************************************************************************
Class Name: MaterialRequestTriggerHandler
Purpose: This Class is for handling Material Update Request's trigger logic.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             10/23/2017           Suman                    Initial Development
******************************************************************************************/
public class MaterialRequestTriggerHandler
{
    /***********************************
    Method Name: executeOnBeforeInsert
    Purpose:Should execute only for before update event.
    ***********************************/    
    public static void executeOnBeforeUpdate()
    {
        Set<Id> headerIds = new Set<Id>();
        Set<String> materialNos = new Set<String>();
        Map<Id, Map<String, List<Material_Update_Request__c>>> headerMatNoRequestMap = new Map<Id, Map<String, List<Material_Update_Request__c>>>();
        
        for(Id mreqId : Trigger.NewMap.keySet())
        {
            // Fetching the request instances.
            Material_Update_Request__c nMreq = (Material_Update_Request__c) Trigger.NewMap.get(mreqId);
            Material_Update_Request__c oMreq = (Material_Update_Request__c) Trigger.OldMap.get(mreqId);
            
            Boolean hasValue = false;
            for(MassUpdateFieldMapping__c mapping : MassUpdateFieldMapping__c.getall().values())
            {
                String fieldApi = mapping.Request_Field_API__c;
                if(nMreq.get(fieldApi) != null)
                {
                    hasValue = true;
                    break;
                }
            }
            
            // Modifying the Request updated value.
            nMreq.Request_Updated__c = hasValue;
            
            if(nMreq.Material_Number__c != null && nMreq.Material_Number__c.trim() != '' && nMreq.Request_Status__c == 'Open')
            {
                headerIds.add(nMreq.Mass_Update_Header__c);
                materialNos.add(nMreq.Material_Number__c);
            }
        }
        
        for(Material_Update_Request__c curMreq : [SELECT Id, Component__c, Mass_Update_Header__c, Material_Group_2__c, Material_Group_3__c, Material_Group_5__c,  Material_Number__c,
                                                  Material_Type__c, MPM__c, MRP_Controller__c, Operations_Group__c, Source_Material__c, Purchasing_Group__c, Request_Status__c,
                                                  Request_Updated__c, Sales_Org__c, Sales_Planning_Group__c, Special_Procurement__c, Subformat__c, Technical_Format__c
                                                  FROM Material_Update_Request__c 
                                                  WHERE Request_Status__c='Open' AND Mass_Update_Header__c IN :headerIds AND Material_Number__c IN :materialNos])
        {    
            if(Trigger.NewMap.containsKey(curMreq.Id))
                curMreq = (Material_Update_Request__c) Trigger.NewMap.get(curMreq.Id);
            
            // Collecting same material number requests to validate duplicate value in same field.
            if(!headerMatNoRequestMap.containsKey(curMreq.Mass_Update_Header__c))
                headerMatNoRequestMap.put(curMreq.Mass_Update_Header__c, new Map<String, List<Material_Update_Request__c>>());
            if(!headerMatNoRequestMap.get(curMreq.Mass_Update_Header__c).containsKey(curMreq.Material_Number__c))
                headerMatNoRequestMap.get(curMreq.Mass_Update_Header__c).put(curMreq.Material_Number__c, new List<Material_Update_Request__c>());
            headerMatNoRequestMap.get(curMreq.Mass_Update_Header__c).get(curMreq.Material_Number__c).add(curMreq);
        }
        
        Map<String, String> fieldsToCheck = new Map<String, String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Material_Update_Request__c').getDescribe().fields.getMap();
        // Collecting fields to validate.
        for(MassUpdateFieldMapping__c mapping : MassUpdateFieldMapping__c.getall().values())
        {
            if(mapping.Transaction_Object_API__c == 'Material__c' || mapping.Transaction_Object_API__c == 'Classification__c')
                fieldsToCheck.put(mapping.Request_Field_API__c, fieldMap.get(mapping.Request_Field_API__c).getDescribe().getLabel());
        }
        
        // Validating duplicate value in same field.
        for(Id headerId : headerMatNoRequestMap.keySet())
        {
            for(String matNo : headerMatNoRequestMap.get(headerId).keySet())
            {
                // If there are 2 mass reques for a single material number.
                List<Material_Update_Request__c> reqList = headerMatNoRequestMap.get(headerId).get(matNo);
                if(reqList != null && reqList.size() > 1)
                {
                    // Iterating over fields to check.
                    for(String fieldApi : fieldsToCheck.keySet())
                    {
                        List<Object> prevVals = new List<Object>();
                        Material_Update_Request__c contextIns;
                        
                        try
                        {
                            for(Material_Update_Request__c req : reqList)
                            {
                                if(Trigger.NewMap.containsKey(req.Id))
                                    contextIns = (Material_Update_Request__c) Trigger.NewMap.get(req.Id);
                                Object curVal = req.get(fieldApi);
                                // If there is any previous value, check that is different or not.
                                if(prevVals.size() > 0)
                                {
                                    Boolean isDifferent = false;
                                    // Comparing current with previous values.
                                    for(Object prevVal : prevVals)
                                    {
                                        if(curVal != null && String.valueOf(curVal).trim() != '' && prevVal != curVal)
                                        {
                                            isDifferent = true;
                                            break;
                                        }
                                    }
                                    
                                    if(isDifferent)
                                    {
                                        throw new ApplicationException('There are different values in field: \''+fieldsToCheck.get(fieldApi)+'\' for material number: '+matNo+'.');
                                    }
                                }
                                
                                // Adding element for next iteration.
                                if(curVal != null && String.valueOf(curVal).trim() != '')
                                    prevVals.add(curVal);
                            }
                        }
                        catch(Exception ex)
                        {
                            if(contextIns != null)
                                contextIns.addError(ex.getMessage());
                        }
                    }
                }
            }
        }
    }
}