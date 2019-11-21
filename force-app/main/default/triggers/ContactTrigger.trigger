trigger ContactTrigger on Contact (before insert, after insert, before update, after update, before delete,after delete) {

    //USST-3149 --- start
    Boolean execute = true;
    Id GBS_Agent_RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('GBS Agent').getRecordTypeId(); 
    Id GBS_Audit_Firm_RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('GBS Audit Firm').getRecordTypeId(); 
    Id GBS_Contact_RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('GBS Contact').getRecordTypeId(); 
    Id GBS_Dealmaker_RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('GBS Dealmaker').getRecordTypeId(); 
    Id GBS_Factory_RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('GBS Factory').getRecordTypeId(); 
    Id GBS_Licensee_RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('GBS Licensee').getRecordTypeId(); 
    Id GBS_Trade_Office_RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('GBS Trade Office').getRecordTypeId(); 
    Id RSG_Contact_RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('RSG Contact').getRecordTypeId(); 
    
    Set<ID> gbsRecTypeIds = new Set<ID>();
    gbsRecTypeIds.add(GBS_Agent_RecordTypeId);
    gbsRecTypeIds.add(GBS_Audit_Firm_RecordTypeId);
    gbsRecTypeIds.add(GBS_Contact_RecordTypeId);
    gbsRecTypeIds.add(GBS_Dealmaker_RecordTypeId);
    gbsRecTypeIds.add(GBS_Factory_RecordTypeId);
    gbsRecTypeIds.add(GBS_Licensee_RecordTypeId);
    gbsRecTypeIds.add(GBS_Trade_Office_RecordTypeId);
    gbsRecTypeIds.add(RSG_Contact_RecordTypeId);
    
    if (!Trigger.isDelete && gbsRecTypeIds.size() > 0) {
        for (Contact con : Trigger.New) {
            if (!gbsRecTypeIds.contains(con.RecordTypeId)) { //not coming from GBS
                execute = false;
                break;
            }
        }   
    }
    else if (Trigger.isDelete && gbsRecTypeIds.size() > 0) {
        for (Contact con : Trigger.Old) {
            if (!gbsRecTypeIds.contains(con.RecordTypeId)) { //not coming from GBS
                execute = false;
                break;
            }
        }   
    }
    //USST-3149 --- end
    if (execute) { //USST-3149
        //check before context
        if (trigger.isBefore){
            if(trigger.isDelete){
                //GBS-467 Concatenate Contract Agent Contact emails to a Contract            
                GBSContactTriggerHandler.checkContactChildRecords();
            }
            else{
                //GBS-634 create a default gbscontact recordtype and later update to its related parent object
                GBSContactTriggerHandler.buildContactRecordType();
                GBSContactTriggerHandler.setPrivateContactAccount(); 
            }
        }
        
        //check after context
        if (trigger.isAfter){
            if(trigger.isDelete)
                GBSContactTriggerHandler.buildFactoryContactString(Trigger.old);
            else {
                GBSContactTriggerHandler.buildFactoryContactString(Trigger.new);
            }
            //GBS-407 modified method name from buildContactEmailString() to buildContactEmailAndNames()
            GBSContactTriggerHandler.buildContactEmailAndNames();
        }
        
        //GBS-635
        if(trigger.isAfter == true && (trigger.isUpdate == true || trigger.isInsert == true)){        
               GBSContactTriggerHandler.createOrUpdateContractObject();
        }
    }
}