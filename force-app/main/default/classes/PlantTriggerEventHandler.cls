/*****************************************************************************************
Class Name: PlantTriggerEventHandler
Purpose: Handler class for plant trigger
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             03/09/2016                                    Initial Development
******************************************************************************************/
public class PlantTriggerEventHandler
{
    public static boolean vBoolIsClone = false;
    public static string uProfileName;
    
    static{ 
        //setting profile name
        IF (TriggerUtility.currentUser != null){
            uProfileName = TriggerUtility.currentUser.Profile.Name;
        }
    }
                                                                      
    /*****************************************************************
    Method Name: executeOnBeforeInsert
    Purpose: static method called on before insert
    ***************************************************************/
    public static void executeOnBeforeInsert(){
        //checking user profile
        if(uProfileName != 'Platform API')
        {
           Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
           Set<Id> matIds = new Set<Id>();
           for(Plant__c ins : (List<Plant__c>)Trigger.New)
           {
               if(ins.Material__c != null)
                   matIds.add(ins.Material__c);
           }
           Map<Id, Material__c> materialMap = new Map<Id, Material__c>([SELECT Id, RecordTypeId, Original_Material_Number__c, Original_Material_Number__r.Material_Status__c,
                                                                        Material_Type__c, Component_Type__c 
                                                                        FROM Material__c WHERE Id IN :matIds]);
           for(Plant__c ins : (List<Plant__c>)Trigger.New)
           {
               if((ins.Function__c == null || ins.Function__c.trim() == '') && 
                  ins.Material__c != null && materialMap.get(ins.Material__c).RecordTypeId == recTypeId && materialMap.get(ins.Material__c).Original_Material_Number__c != null)
               {
                   if(materialMap.get(ins.Material__c).Original_Material_Number__r.Material_Status__c == 'Processed in SAP')
                       ins.Function__c = '004';
                   else if(materialMap.get(ins.Material__c).Original_Material_Number__r.Material_Status__c == 'Sent to SAP' ||
                           materialMap.get(ins.Material__c).Original_Material_Number__r.Material_Status__c == 'SAP Error')
                   {
                       ins.Function__c = '004';
                   }
               }
               else
               {
                   if(ins.Function__c == null || ins.Function__c.trim() == '')
                       ins.Function__c = '009';
                 
                   if(ins.Plant__c == 'V500 - Technicolor')
                      ins.Stor_Loc_EP__c ='0020';
               }

               // Commented 9/22 to support demo JE
               if(ins.Plant__c != null && materialMap.get(ins.Material__c) != null)
                   ins.Plnd_Dely_time__c = getPlndDelyTime(materialMap.get(ins.Material__c), ins.Plant__c.subString(0, 4));
           }
        }   
    }
    
    /*****************************************************************
    Method Name: executeOnBeforeUpdate
    Purpose: static method called on before update 
    ***************************************************************/
    public static void executeOnBeforeUpdate(){
        
        if(!PlantTriggerEventHandler.vBoolIsClone)
        {
            Plant__c vPlantNew;
            Plant__c vPlantOld;
            
            String vProfName = [Select Profile.Name from User Where Id =: UserInfo.getUserId()].Profile.Name;
            
            
            Set<Id> vSetMatId = new Set<Id>();
            for(Plant__c vPlant: (List<Plant__c>)Trigger.New)
            {
                if(vPlant.Material__c != null)
                {
                    vSetMatId.add(vPlant.Material__c);
                }
            }
            
            Map<Id, Material__c> vMapIdMat = new Map<Id, Material__c>([Select Id, Material_Status__c from Material__c where Id In: vSetMatId]);
            
            
            for(Integer i=0; i<trigger.new.size(); i++)
            {
                vPlantNew = (Plant__c)trigger.new[i];
                vPlantOld = (Plant__c)trigger.Old[i];
                if(vPlantNew.Execute_Validation__c && vPlantNew.Execute_Validation__c == vPlantOld.Execute_Validation__c && vProfName != 'System Administrator' && vProfName != 'Platform API' && vMapIdMat.containsKey(vPlantNew.Material__c) && vMapIdMat.get(vPlantNew.Material__c).Material_Status__c == 'Processed in SAP')
                {
                    vPlantNew.addError('Plant cannot be edited as parent material is processed in SAP.');
                }
            }
        }
        
    
    
        //checking user profile
        if(uProfileName == 'Platform API')
        {
          for(Plant__c each: (List<Plant__c>)Trigger.New){
                each.Function__c = '023'; 
              }
        }
        else
        {
            Set<Id> matIds = new Set<Id>();
            for(Plant__c ins : (List<Plant__c>)Trigger.New)
            {
                if(ins.Material__c != null)
                    matIds.add(ins.Material__c);
            }
            Map<Id, Material__c> materialMap = new Map<Id, Material__c>([SELECT Id, Material_Type__c, Component_Type__c FROM Material__c WHERE Id IN :matIds]);
            for(Plant__c ins : (List<Plant__c>)Trigger.New)
            {
                if(ins.Function__c == '023')
                    ins.Function__c = '004';
                if(ins.Deletion_Flag__c)
                    ins.Function__c = '003';
                    
                // These lines commented on 9/22 to support demo JE               
                if(ins.Plant__c != null && materialMap.get(ins.Material__c) != null && materialMap.get(ins.Material__c).Material_Type__c == 'FERT')
                    ins.Plnd_Dely_time__c = getPlndDelyTime(materialMap.get(ins.Material__c), ins.Plant__c.subString(0, 4));
            }
        }   
    }
    
    // Following method determines the Planned Delivery Time value.
    private static String getPlndDelyTime(Material__c mat, String plantCode)
    {
        if(mat.Material_Type__c == 'FERT')
        {
            if(plantCode == 'V000' || plantCode == 'V300' || plantCode == 'V400' || plantCode == 'V500')
                return '7';
            else if(plantCode == 'V750' || plantCode == 'V850')
                return '14';
        }
        else
        {
            if(mat.Component_Type__c == 'MEGAPACK' || mat.Component_Type__c == 'ONPACK' || mat.Component_Type__c == 'ONPACK PRM' || mat.Component_Type__c == 'NATIONAL ONPACK/GWP' || 
               mat.Component_Type__c == 'RMF RETAILER EXCL. GWP' || mat.Component_Type__c == 'STEELBOOK')
                return '56';
            else if(mat.Component_Type__c == 'RIGID SLIPCASE')
                return '28';
            else if(mat.Component_Type__c == 'LONGBOX/GIFTBOX' || mat.Component_Type__c == 'SLIPCASE' || mat.Component_Type__c == 'DIGI-PACK')
                return '21';
            else if(mat.Component_Type__c == 'BELLY BAND' || mat.Component_Type__c == 'CORRUGATE')
                return '14';
            else if(mat.Component_Type__c == 'O-CARD' || mat.Component_Type__c == 'O-CARD W/FOIL')
                return '12';
        }
        return '7';
    }
}