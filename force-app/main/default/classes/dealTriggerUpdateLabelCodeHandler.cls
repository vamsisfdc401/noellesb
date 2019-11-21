public without sharing class dealTriggerUpdateLabelCodeHandler
{
  
    //Mathod to update component number on bom item if its changed on component material   
    public static void updateDealIdonReleaseMaterial(list<Deal__c> dealRec)
    {
       TriggerUtility.initiatedFromDeal = true;    // Added for REL-174
       Set<Id> titleIds = new Set<Id>();
       Map<Id, Deal__c> dealTitleMap= new Map<Id, Deal__c>();
       list<Release__c> updateRelease = new list<Release__c>();
       list<Deal__c> updateCheckedDeal = new list<Deal__c>();
       Set<String> originCodeSet = new Set<String>();    // Changed for Deal
       
       for(Deal__c each : dealRec){
         if(each.Title__c!=null){
           titleIds.add(each.Title__c);
           // Changed for Deal
           if(each.Finance_Default_Deal__c == true) {
              dealTitleMap.put(each.Title__c, each);
              if (each.Origin_Code__c != null) {
                  originCodeSet.add(each.Origin_Code__c);
              }
              else {
                  each.addError('This Deal\'s Origin Code is not valid in the system. Please reach out to IT to resolve.');
              }
           }
         }   
       }
       
       //Update Pervious deal Finance Default Deal=false
       for(Deal__c eachDeal:[Select Id, Finance_Default_Deal__c, Title__c from Deal__c Where Title__c In: titleIds AND Finance_Default_Deal__c=True]){       
           
            if(dealTitleMap.containsKey(eachDeal.Title__c) && eachDeal.ID!=dealTitleMap.get(eachDeal.Title__c).Id){
             eachDeal.Finance_Default_Deal__c =False;
             updateCheckedDeal.add(eachDeal);
          }    
        }
      
        if (updateCheckedDeal.Size() > 0) {
            Update updateCheckedDeal;  
        }
        
        // Fetching origin code details. // Changed for Deal
        Map<String, Origin_Code__c> ocMap = new Map<String, Origin_Code__c>();
        if (originCodeSet.size() > 0) {
            for (Origin_Code__c oc : [SELECT Label_Code__c, Sub_Label_Code__c, Origin_Code__c, Label_Code_2__c, Default_Deal_ID__c  
                                      FROM Origin_Code__c
                                      WHERE Origin_Code__c IN: originCodeSet]) { //USST-2728 //USST-2669
                ocMap.put(oc.Origin_Code__c, oc);
            }
        }
        
        //Update Release deal     AND Deal__c = Null    // Changed for REL-174
        for(Release__c eachRel:[SELECT Id, Deal__c, Deal_ID__c, Title__c FROM Release__c 
                                WHERE Title__c IN: titleIds AND (Material_Counter__c = NULL OR Material_Counter__c = 0) AND Deal__c = null]) { // Changed for Deal //USST-2728
            if (dealTitleMap.get(eachRel.Title__c) != null && dealTitleMap.get(eachRel.Title__c).Origin_Code__c != null) {
                eachRel.Deal__c = dealTitleMap.get(eachRel.Title__c).Id;
                eachRel.Deal_ID__c = dealTitleMap.get(eachRel.Title__c).Deal_ID__c; //USST-2728
                //USST-2728 //USST-2669 --- start
                if (ocMap.get(dealTitleMap.get(eachRel.Title__c).Origin_Code__c).Default_Deal_ID__c != null && ocMap.get(dealTitleMap.get(eachRel.Title__c).Origin_Code__c).Default_Deal_ID__c != '' && ocMap.get(dealTitleMap.get(eachRel.Title__c).Origin_Code__c).Default_Deal_ID__c == eachRel.Deal_ID__c) {
                    system.debug('Enter 2728');
                    eachRel.Label_Code__c = ocMap.get(dealTitleMap.get(eachRel.Title__c).Origin_Code__c).Label_Code_2__c;    // Changed for Deal
                }
                else {
                    system.debug('Enter 2728');
                    eachRel.Label_Code__c = ocMap.get(dealTitleMap.get(eachRel.Title__c).Origin_Code__c).Label_Code__c;    // Changed for Deal
                }
                //USST-2728 //USST-2669 --- end
                updateRelease.add(eachRel); 
            }
        }
        if(updateRelease.size()>0) 
            Update updateRelease;  
      
        // Changed for REL-174
        //Update Material deal    AND Deal__c=Null
        Set<ID> setMatID = new Set<ID>();
        //List<Origin_Code__c> lstOrgCode = [select Sub_Label_Code__c, Origin_Code__c from Origin_Code__c]; //Added for REl-136
        for(Material__c eachmat:[Select Deal__c,Title__c,Release__c,Label_Code__c,Item_Type__c,Material_Status__c  
                                 from Material__c 
                                 Where Title__c In: titleIds AND (Material_Status__c='Draft' OR Material_Status__c='Sent Back' OR Material_Status__c='Submitted' ) AND 
                                     Item_Type__c = 'S (Single)' AND Deal__c = null]) { //Modified for REL-136 // Changed for Deal
            if(dealTitleMap.size() > 0){ //Removed eachmat.deal__c==null condition for usst-2477 //Modified for REL-136
                if(!setMatID.contains(eachmat.ID) && eachmat.Material_Status__c=='Submitted'){
                     setMatID.add(eachmat.ID);
                }
            }  
        }
        
        //USST-2883 --- start //Added below piece of code to prevent flex queue governor limit of 100.
        List<AsyncApexJob> flexQueueList = [SELECT Id FROM AsyncApexJob WHERE Status = 'Holding' FOR UPDATE];
        Integer flexQueueSize = flexQueueList.size();
        Integer start = System.Now().millisecond();
        if (flexQueueSize > 90) {
            while(System.Now().millisecond() < start+15000){ 
                //Do Nothing. Just wait for 15 seconds.
            }
        }
        //USST-2883 --- end
        
        // Initiating Batch Job to Update Associated Materials.    // Added for REL-174
        Database.executeBatch(new DealUpdateBatchHandler(titleIds, dealTitleMap), 50);
        
        //automatically approving the records // Changed for REL-174
        if(!setMatID.isEmpty()){
            List<Approval.ProcessWorkitemRequest> lstWorkItm = new List<Approval.ProcessWorkitemRequest>();
            
            Set<Id> workItemId = getWorkItemId(setMatID);
            
            if(!workItemId.isEmpty()){
                for(ID wrkItm: workItemId){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setComments('Approving request automatically.');
                    req.setAction('Approve');
                    req.setWorkitemId(wrkItm);
                    lstWorkItm.add(req);
                }
            }
            
            if(!lstWorkItm.isEmpty()){
                List<Approval.ProcessResult> result =  Approval.process(lstWorkItm);
            } 
        }
       
    }
    
    public static Set<Id> getWorkItemId(Set<Id> targetObjectId)
    {
        Set<Id> retVal = new Set<ID>();

        for(ProcessInstanceWorkitem workItem  : [Select Id,ProcessInstanceId,ActorId,Actor.Name from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in: targetObjectId AND Actor.Name = 'Deal Approver'])
        {
            if(!retVal.contains(workItem.ID)){
                 retVal.add(workItem.ID);
            }
        }

        return retVal;
    }
}