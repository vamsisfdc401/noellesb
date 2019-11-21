/*****************************************************************************************
Class Name: DGF_QueueableRFAndDGFIntegration 
Purpose: Apex class to excute RF and DGF integration functionality asynchronusly.
           This class is called from ReleaseForce trigger on Release__c object. 
           Only after context events are handled in this queueable class.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             01/12/2017           Mohit                    Initial Development
******************************************************************************************/
public class DGF_QueueableRFAndDGFIntegration implements Queueable {

    //variable declaration
    public Map<Id, Release__c> mapReleaseOld;
    public Map<Id, Release__c> mapReleaseNew;
    public string triggerContext;
    public Map<Id, Release__c> mapReleaseOld1 = new Map<Id, Release__c>();
    public Map<Id, Release__c> mapReleaseNew1 = new Map<Id, Release__c>();

    /***********************************
    Method Name: execute
    Purpose: Declaring core method that is called by system. Based on trigger context respective method will be called.
    ***********************************/
    public void execute(QueueableContext context) {  
        try {
            if(triggerContext == DGF_Constants.AFTER_UPDATE || triggerContext == DGF_Constants.AFTER_INSERT) {
                Set<Id> relIdSet = new Set<Id>();
                if(mapReleaseNew != null) {
                    for(Release__c rel : mapReleaseNew.values()) {
                        mapReleaseNew1.put(rel.Id,rel);
                        if(triggerContext == DGF_Constants.AFTER_UPDATE && rel.Release_Sync__c!=null && !mapReleaseNew.keySet().contains(rel.Release_Sync__c)) {
                            relIdSet.add(rel.Release_Sync__c);
                        }
                    }
                }
                if(mapReleaseOld != null) { 
                    for(Release__c rel : mapReleaseOld.values()) {
                        mapReleaseOld1.put(rel.Id,rel);
                    }
                }
                
                List<Release__c> relList = [SELECT Acquisition__c,Alternate_EST_Date__c,Alternate_Physical_Street_Date__c,Alternate_VOD_Date__c,Association_Needed__c,
                A_K_A__c,Box_Office_Filter__c,Brand_Group__c,Cancel_Release__c,Component__c,CreatedById,CreatedDate,CurrencyIsoCode,Deal_ID__c,Deal_Indicator__c,
                Deal__c,Digital_PIN_Date__c,Digital_Release__c,Digital__c,Discs__c,Distribution_Rights__c,Distributor_Short_Name__c,Distributor__c,
                DOM_Box_Office_Total__c,DOM_Open_W_E_Total__c,Early_Awareness_Date__c,EST_Date__c,EST_to_BD_DVD__c,EST_to_PIN_Window__c,Expiration_Date__c,
                First_International_Release_Date__c,First_Theatrical_Date__c,Formats__c,Format_Name__c,Format__c,Genre__c,HD__c,Id,Internal_Announce_Date__c,
                INT_Box_Office_Total__c,In_Plant_Date__c,IsDeleted,Label_Code__c,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,
                LastViewedDate,Linear_Premiere_Date__c,Master_Schedule_Indicator__c,materialcount__c,Material_Counter__c,Name,
                Online_Consumer_Solicitation_Date__c,Order_of_Data__c,Original_Release_Date__c,OwnerId,Physical_Street_Date__c,Pretty_Indicator__c,
                Previous_Street_Date__c,Pre_Order_Close_Date__c,Product_Type__c,Project_Type__c,Promotion_End_Date__c,Promotion_Name_Abbreviation__c,
                Promotion_Type__c,Rating__c,RecordTypeId,Release_Patterns__c,Release_Status__c,Release_Sync__c,Release__c,RMF__c,SD__c,
                SGENNO_ReadOnly__c,SGENNO__c,Street_Date__c,Sync_Dates__c,SystemModstamp,Template_Type__c,Territory__c,Theatrical_Dates__c,Theatrical_Release_Dates__c,
                Theatrical_to_BD_DVD__c,Theatrical_to_VOD__c,Title_ID__c,Title__c,TM_Version__c,Trade_Solicitation_Date__c,UHD__c,User_Brand_Group__c,
                Visual_Format__c,VOD_Street_Date__c,V_Project_Number__c,v_Project_Required__c,v_Project__c,Windowed_Rental_Pre_Order_Close_Date__c,
                Windowed_Rental_Street_Date__c,Window_Type__c,WW_Box_Office_Total__c,X3D__c,SVOD_Start_Date__c,PTV_SOD_End_Date__c,VOD_End_Date__c,Hotel_End_Date__c,PTV_SOD_Provider__c FROM Release__c
                                WHERE Id IN : relIdSet]; //USST-3106
                for(Release__c rel : relList) {
                    DGF_AutoReleaseCreationHandler.dummyReleaseIdSet.add(rel.Id);
                    mapReleaseNew1.put(rel.Id,rel);
                    Release__c cloneRel = rel.clone();
                    cloneRel.Digital__c = false;
                    mapReleaseOld1.put(rel.Id,cloneRel);
                }
                system.debug('relList is ' + relList);
                system.debug('mapReleaseNew is ' + mapReleaseNew);
            }
            //if after insert context
            if (triggerContext != null && triggerContext == DGF_Constants.AFTER_INSERT) {
                DGF_AutoReleaseCreationHandler.executeOnAfterInsert(mapReleaseNew1, triggerContext);         
            }
            //if after update context
            else if (triggerContext != null && triggerContext == DGF_Constants.AFTER_UPDATE) {
                DGF_AutoReleaseCreationHandler.executeOnAfterUpdate(mapReleaseOld1, mapReleaseNew1, triggerContext);          
            }
            //if after delete context
            else if (triggerContext != null && triggerContext == DGF_Constants.AFTER_DELETE) {
                DGF_AutoReleaseCreationHandler.executeOnAfterDelete(mapReleaseOld, triggerContext);         
            }      
        }
        catch (Exception ex) {
            DGF_ExceptionLogController.createExceptionLog('RF and DGF Integration ' + triggerContext,'DGF_QueueableRFAndDGFIntegration',ex.getMessage());
        }        
    }
}