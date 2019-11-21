/*****************************************************************************************
Trigger Name: ValuationTrigger 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             03/09/2016                                    Initial Development
******************************************************************************************/
trigger ValuationTrigger on Valuation__c (before Insert, before update) 
{     
     String profileName;
     
     //storing profile name
     IF (TriggerUtility.currentUser != null){
        profileName = TriggerUtility.currentUser.Profile.Name;
     }
    
     System.Debug('Check Profile Value>>>>> '+profileName);
    
    //context variable check for insert event    
    if(Trigger.IsInsert){
       Set<Id> matIds = new Set<Id>();
       for(Valuation__c ins : Trigger.New)
       {
           if(ins.Material__c != null)
               matIds.add(ins.Material__c);
       }
       Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
       Map<Id, Material__c> materialMap = new Map<Id, Material__c>([SELECT Id, RecordTypeId, Original_Material_Number__c, Original_Material_Number__r.Material_Status__c 
                                                                    FROM Material__c WHERE Id IN :matIds]);
       
       for(Valuation__c ins : Trigger.New)
       {
          //for API user setting function value
          if(profileName == 'Platform API'){
              //ins.Function__c = '023';
          }
          //for users other than API setting function value
          else{
              if((ins.Function__c == null || ins.Function__c.trim() == '') &&
                 ins.Material__c != null && materialMap.get(ins.Material__c).RecordTypeId == recTypeId && materialMap.get(ins.Material__c).Original_Material_Number__c != null)
              {
                   if(materialMap.get(ins.Material__c).Original_Material_Number__r.Material_Status__c == 'Processed in SAP')
                       ins.Function__c = '004';
                   else if(materialMap.get(ins.Material__c).Original_Material_Number__r.Material_Status__c == 'Sent to SAP' ||
                           materialMap.get(ins.Material__c).Original_Material_Number__r.Material_Status__c == 'SAP Error')
                   {
                       /*if(ins.Valuation_Key__c != null)
                           ins.Function__c = '004';
                       else
                           ins.Function__c = '009';*/
                       ins.Function__c = '004';
                   }
              }
              else if(ins.Function__c == null || ins.Function__c.trim() == '')
                  ins.Function__c = '009';
          }    
       }
    } 
    //context variable check for update event
    else if(Trigger.IsUpdate){
 
        for(Valuation__c ins : Trigger.New)
        {
          //for API user setting function value
          if(profileName == 'Platform API'){
              ins.Function__c = '023';
          }
          //for users other than API setting function value
          else{
            if(ins.Function__c == '023')
                ins.Function__c = '004';
            if(ins.Deletion_Flag__c)
                ins.Function__c = '003';
          }      
        }
    }
}