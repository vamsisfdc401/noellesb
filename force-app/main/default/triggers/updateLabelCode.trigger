/*****************************************************************************************
TriggerName: updateLabelCode
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             30/07/2016           Ipsita                    Initial Development
******************************************************************************************/
trigger updateLabelCode on Deal__c (before Insert, before Update,after Insert,after Update) 
{
    Set<String> originCodeSet = new Set<String>();
    Map<String, Origin_Code__c> originLabelCodeMap = new Map<String, Origin_Code__c>();
    if(Trigger.IsBefore){    
        // Below code handles the before insert event.
        if(Trigger.isInsert)
        {
            for(Deal__c deal : Trigger.New)
            {
                if(deal.Origin_Code__c != null && deal.Origin_Code__c.trim() != '')
                {
                    originCodeSet.add(deal.Origin_Code__c);
                }
            }
            
            getOriginLabelCodeMapping();
            
            // Assigning label code depending on deal's origin code
            for(Deal__c deal : Trigger.New)
            {
                if(deal.Origin_Code__c != null && deal.Origin_Code__c.trim() != '' && 
                   originLabelCodeMap.containsKey(deal.Origin_Code__c))
                {
                    //USST-2728 --- start
                    if (originLabelCodeMap.get(deal.Origin_Code__c).Default_Deal_ID__c != null && originLabelCodeMap.get(deal.Origin_Code__c).Default_Deal_ID__c != '' && originLabelCodeMap.get(deal.Origin_Code__c).Default_Deal_ID__c == deal.Deal_ID__c) {
                        deal.Label_Code__c = originLabelCodeMap.get(deal.Origin_Code__c).Label_Code_2__c;
                    }
                    else {
                        deal.Label_Code__c = originLabelCodeMap.get(deal.Origin_Code__c).Label_Code__c;
                    }
                    //USST-2728 --- end
                }
            }
        }
        // Below code handles the before update event.
        else if(Trigger.isUpdate)
        {
            for(Id dealId : Trigger.NewMap.keySet())
            {
                if(Trigger.OldMap.get(dealId).Origin_Code__c != Trigger.NewMap.get(dealId).Origin_Code__c && 
                   Trigger.NewMap.get(dealId).Origin_Code__c != null && Trigger.NewMap.get(dealId).Origin_Code__c.trim() != '')
                {
                    originCodeSet.add(Trigger.NewMap.get(dealId).Origin_Code__c);
                }
            }
            
            getOriginLabelCodeMapping();
            
            // Assigning label code depending on deal's origin code changes.
            for(Id dealId : Trigger.NewMap.keySet())
            {
                if(Trigger.OldMap.get(dealId).Origin_Code__c != Trigger.NewMap.get(dealId).Origin_Code__c && 
                   Trigger.NewMap.get(dealId).Origin_Code__c != null && Trigger.NewMap.get(dealId).Origin_Code__c.trim() != '' && 
                   originLabelCodeMap.containsKey(Trigger.NewMap.get(dealId).Origin_Code__c))
                {
                    //USST-2728 --- start
                    if (originLabelCodeMap.get(Trigger.NewMap.get(dealId).Origin_Code__c).Default_Deal_ID__c != null && originLabelCodeMap.get(Trigger.NewMap.get(dealId).Origin_Code__c).Default_Deal_ID__c != '' && originLabelCodeMap.get(Trigger.NewMap.get(dealId).Origin_Code__c).Default_Deal_ID__c == Trigger.NewMap.get(dealId).Deal_ID__c) {
                        Trigger.NewMap.get(dealId).Label_Code__c = originLabelCodeMap.get(Trigger.NewMap.get(dealId).Origin_Code__c).Label_Code_2__c;
                    }
                    else {
                        Trigger.NewMap.get(dealId).Label_Code__c = originLabelCodeMap.get(Trigger.NewMap.get(dealId).Origin_Code__c).Label_Code__c;
                    }
                    //USST-2728 --- end
                }
            }
        }
    } 
    // Following code executes on after event
    if(Trigger.IsAfter){
        // Below code handles the after insert event.
        if(Trigger.IsInsert){
            dealTriggerUpdateLabelCodeHandler.updateDealIdonReleaseMaterial(Trigger.New);
        }
        // Below code handles the after update event.
        if(Trigger.IsUpdate){
            list<Deal__c> listDealRec = new list<Deal__c >();
            for(Deal__c deal : Trigger.New)
            {
                if(deal.Finance_Default_Deal__c != trigger.oldmap.get(deal.Id).Finance_Default_Deal__c && deal.Finance_Default_Deal__c==True) { // Changed for Deal
                    if(deal.Origin_Code__c != null) {
                        listDealRec.add(deal);
                    }
                    else {
                        deal.addError('This Deal\'s Origin Code is not valid in the system. Please reach out to IT to resolve.');
                    }
                }
            }
             
            if(listDealRec.size()>0)
                dealTriggerUpdateLabelCodeHandler.updateDealIdonReleaseMaterial(listDealRec);   
        }
    } 
   
    // Following method is responsible to get the mapping between origin code and label code.
    private void getOriginLabelCodeMapping()
    {
        for(Origin_Code__c oc : [SELECT Origin_Code__c, Label_Code__c, Label_Code_2__c, Default_Deal_ID__c 
                                 FROM Origin_Code__c
                                 WHERE Origin_Code__c IN :originCodeSet]) //USST-2728
        {
            originLabelCodeMap.put(oc.Origin_Code__c, oc); //USST-2728
        }
    }
}