trigger RST_PlayWeek_Trigger on RST_Play_Week__c (before insert, after insert, 
                                                  before update, after update,
                                                  before delete, after delete,
                                                  after undelete) 
{
    new RST_Playweek_TriggerHandler().run();
}