trigger AcquisitionDealTrigger on Acquisition_Deal__c (before Insert, before Update,after insert, after update) {
    
    /*if(Trigger.IsUpdate && Trigger.IsAfter ){
    List<Acquisition_Deal__c> updatedDeals = new List<Acquisition_Deal__c>();
    for(Acquisition_Deal__c eachDealNew : Trigger.New){
    // for(Acquisition_Deal__c eachDealOld : Trigger.Old){
    if(eachDealNew.Acquisition_Deal_Stage__c== 'Board Pack Preparation' && Trigger.OldMap.Get(eachDealNew.ID).Acquisition_Deal_Stage__c== 'Speculative'){
    if(eachDealNew.Title_Context__c != Trigger.OldMap.Get(eachDealNew.ID).Title_Context__c)
    updatedDeals.add(eachDealNew);
    }
    // }
    }
    system.debug('///updatedDeals'+updatedDeals);
    if(updatedDeals.size()>0){AcquisitionDealTriggerHandler.deleteDuplicateBoardPackRecords(updatedDeals);}
    
    }*/
    
    if(Trigger.IsBefore ){
        
        if(Trigger.IsInsert){
            
            for(Acquisition_Deal__c eachDeal : Trigger.New){
                if((eachDeal.On_Hold__c ==True || eachDeal.Dead__c ==True) && eachDeal.Acquisition_Deal_Stage__c != Null){
                    eachDeal.StageValueBeforeDeadOrOnHold__c = eachDeal.Acquisition_Deal_Stage__c;
                    if(eachDeal.On_Hold__c ==True)
                        eachDeal.Acquisition_Deal_Stage__c = 'On-Hold';
                    if(eachDeal.Dead__c ==True)
                        eachDeal.Acquisition_Deal_Stage__c = 'Cancelled'; 
                }  
            }
        }
        
        if(Trigger.IsUpdate){

            for(Acquisition_Deal__c eachDeal : Trigger.New){
                
                if(eachDeal.Acquisition_Deal_Stage__c != Null && ((eachDeal.On_Hold__c != Trigger.oldmap.get(eachDeal.Id).On_Hold__c && eachDeal.On_Hold__c ==True) || (eachDeal.Dead__c != Trigger.oldmap.get(eachDeal.Id).Dead__c && eachDeal.Dead__c ==True))){
                    
                    if(eachDeal.StageValueBeforeDeadOrOnHold__c==Null){eachDeal.StageValueBeforeDeadOrOnHold__c = Trigger.oldmap.get(eachDeal.Id).Acquisition_Deal_Stage__c;}
                    
                    if(eachDeal.On_Hold__c ==True)
                        eachDeal.Acquisition_Deal_Stage__c = 'On-Hold';
                    if(eachDeal.Dead__c ==True)
                        eachDeal.Acquisition_Deal_Stage__c = 'Cancelled';      
                }
                system.debug('////DealPriorStage'+eachDeal.StageValueBeforeDeadOrOnHold__c);
                if(eachDeal.StageValueBeforeDeadOrOnHold__c != Null && (eachDeal.On_Hold__c ==False && eachDeal.Dead__c ==False)){
                    eachDeal.Acquisition_Deal_Stage__c = eachDeal.StageValueBeforeDeadOrOnHold__c;
                    system.debug('////Inside eachDeal.Acquisition_Deal_Stage__c'+eachDeal.Acquisition_Deal_Stage__c);
                    eachDeal.StageValueBeforeDeadOrOnHold__c = Null ;
                    
                } else if(eachDeal.StageValueBeforeDeadOrOnHold__c != Null && (eachDeal.On_Hold__c ==True && eachDeal.Dead__c ==False)){
                    eachDeal.Acquisition_Deal_Stage__c = 'On-Hold';            
                    
                } else if(eachDeal.StageValueBeforeDeadOrOnHold__c != Null && (eachDeal.On_Hold__c ==False && eachDeal.Dead__c ==True)){
                    eachDeal.Acquisition_Deal_Stage__c = 'Cancelled'; 
                }
            }
            
            if(!PreventRecursive.preventRecursiveRun){
                PreventRecursive.preventRecursiveRun = true;             
                
                List<Summary__c> sumUpdatelst = new List<Summary__c>();
                
                sumUpdatelst = [SELECT Id, Name, Acquisition_Deal__c FROM Summary__c WHERE Acquisition_Deal__c = : trigger.new];
                
                if(sumUpdatelst.isEmpty()){
                    
                    List<Summary__c> sumlst = new List<Summary__c>();
                    
                    for(Acquisition_Deal__c acq : trigger.new){ 
                        sumlst.add(New Summary__c(Name = acq.Name, Acquisition_Deal__c = acq.Id, Recordtype = acq.RecordType));
                    }
                    
                    If(!sumlst.isEmpty()){
                        INSERT sumlst;
                    } 
                } 
            }
        }
    }
    
    If(Trigger.IsAfter){
        
        if(Trigger.IsInsert){
            
            List<Summary__c> sumlst = new List<Summary__c>();
            
            for(Acquisition_Deal__c acq : trigger.new){
                
                sumlst.add(New Summary__c(Name = acq.Name, Acquisition_Deal__c = acq.Id, Recordtype = acq.RecordType));
            }
            If(!sumlst.isEmpty()){
                INSERT sumlst;
            }
        }
    }
}