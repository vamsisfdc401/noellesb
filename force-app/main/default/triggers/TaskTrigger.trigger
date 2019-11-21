trigger TaskTrigger on Task (before insert, before update, after insert, after update, after delete) {
    String recordTypeId;
    list<Task> newTasklist = (List<Task>) trigger.new;
   	list<Task> oldTasklist = (List<Task>) trigger.old;
    if (trigger.isInsert || trigger.isUpdate) {
        	recordTypeId = (String) newTasklist[0].RecordTypeId;
        }
        else {
            recordTypeId = (String) oldTasklist[0].RecordTypeId;
        }
    if(Label.CIRF_Triggers_ON_OFF == 'ON' && recordTypeId != null && Label.CIRF_Task_RecordType_Ids.contains(recordTypeId)){
        new TaskTriggerHandler().run();
    }    
    /*  AL - 10/10/2018 - HEITCIRF-170 - Move the below logic to Trigger Handler*/
    //SJ - moved the code from trigger handler to try to resolve null pointer
    //Get the v-Project Ids associated to trigger.new
    Set<Id> vId = new Set<Id>();
    Schema.sObjectType vType = v_Project_Request__c.sObjectType;
    List<Task> tList = new List<Task>(); //moved list to here for 101 error 04/10/2018
    List<v_Project_Request__c> vList = new List<v_Project_Request__c>(); //moved list to here for 101 error 04/10/2018
    
    if(Trigger.IsInsert || Trigger.IsUpdate)
    {
        for (Task t : trigger.new){
           
            if(t.WhatId != NULL && t.WhatId.getSObjectType() == vType){
                vId.add(t.whatId);
            }
        }
    }
    else if(Trigger.IsDelete)
    {
        for (Task t : trigger.old){
     
            if(t.WhatId != NULL && t.WhatId.getSObjectType() == vType){
                vId.add(t.whatId);
            }
        }
    }

    //Get the Tasks related to those v-Projects
    if (vId.size() >0) { //Added for 101 error 04/10/2018
        tList = [Select Id, whatId, Status from Task WHERE (whatId IN :vId AND Status <> 'Completed')]; //changed for 101 error 04/10/2018
        //construct List to put task counts on
        vList = [Select Id, Active_Task_Count__c from v_Project_Request__c WHERE Id IN :vId]; //changed for 101 error 04/10/2018
    }
    //Iterate through the v-Projects and Tasks to add to the count on the v-Project
    if (vList.size() > 0) { //Added for 101 error 04/10/2018
        for (v_Project_Request__c v : vList){
            //Reset count to zero
            v.Active_Task_Count__c = 0;
    
            //increment count on v-Project
            if (tList.size() > 0) { //Added for 101 error 04/10/2018
                for(Task t: tList){
                    if(t.whatId == v.Id){
                        v.Active_Task_Count__c = v.Active_Task_Count__c +1;
                    }
                }
            }
        }
    }
    vProjectUtility.shouldExecute = FALSE;
    if (vList.size() > 0) { //Added for 101 error 04/10/2018
        update vList;
    }
}