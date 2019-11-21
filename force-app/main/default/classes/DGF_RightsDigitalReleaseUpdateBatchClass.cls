/***********************************************************************
 Class Name:DGF_RightsDigitalReleaseUpdateBatchClass
 Purpose:Batch Class to update Rights in Digital Force
************************************************************************
version  DateModified     ModifiedBy           Change
1.0		 10/23/2018       Naga				    Initial Development DFOR-1652

************************************************************************/
global class DGF_RightsDigitalReleaseUpdateBatchClass implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC) {
    	String query = 'SELECT Id,Title__c FROM Right__c';
        System.debug('Start method');
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Right__c> Rightlst) {
        System.debug('Execute  method');
        Set<Id> ttlIdSet = new Set<Id>();
        map<String,list<Right__c>> rtsMap = new map<String,list<Right__c>>();
        for(Right__c ri : Rightlst)
        {        
            ttlIdSet.add(ri.Title__c);
        }
        System.debug('Title IDs----'+ttlIdSet);
        try {
            if(ttlIdSet!=null && ttlIdSet.size()>0)
            {
                system.debug('ttlIdSet====='+ttlIdSet);
                List<Digital_Release__c> lstDRrecs = new List<Digital_Release__c>();
                list<Title__c> lstTtl = [SELECT Id, (SELECT Id, name, Platform__c, Territory__c, Rights__c 
                                                     FROM Rights__r) 
                                         FROM Title__c
                                         WHERE Id IN: ttlIdSet];
                
                if(lstTtl!=null && lstTtl.size()>0)
                {
                    for(Title__c ttl: lstTtl)
                    {
                        rtsMap.put(ttl.id, ttl.Rights__r);
                    }
                }
                
                for (Digital_Release__c dg : [SELECT Id,Title__c,US_EST_Rights__c,US_VOD_Rights__c,
                                              CA_EST_Rights__c,CA_VOD_Rights__c,Rights_Validated__c 
                                              FROM Digital_Release__c 
                                             WHERE Title__c IN: ttlIdSet]) 
                {
                    if(!rtsMap.isEmpty() && rtsMap.containsKey(dg.Title__c))
                    {
                        List<Right__c> rLst = rtsMap.get(dg.Title__c);
            			if(rLst!=null && rLst.size()>0)
                        {
                            dg.US_EST_Rights__c = FALSE;
                            dg.US_VOD_Rights__c = FALSE;
                            dg.CA_EST_Rights__c = FALSE;
                            dg.CA_VOD_Rights__c = FALSE;
                            
                            for (Right__c rght : rLst) {
                                
                                if (rght.Territory__c == DGF_Constants.TERRITORY_US) {                      
                                    if (rght.Platform__c == DGF_Constants.PLATFORM_VOD && rght.Rights__c == TRUE)  {
                                        dg.US_VOD_Rights__c = TRUE;
                                    }                            
                                    else if (rght.Platform__c == DGF_Constants.PLATFORM_EST && rght.Rights__c == TRUE) {  
                                        dg.US_EST_Rights__c = TRUE; 
                                    }
                                }
                                else if (rght.Territory__c == DGF_Constants.TERRITORY_CA) {                       
                                    if (rght.Platform__c == DGF_Constants.PLATFORM_VOD && rght.Rights__c == TRUE) {
                                        dg.CA_VOD_Rights__c = TRUE;
                                    }                            
                                    else if (rght.Platform__c == DGF_Constants.PLATFORM_EST && rght.Rights__c == TRUE) { 
                                        dg.CA_EST_Rights__c = TRUE;        
                                    }                        
                                }  
                            }
                            
                            if (dg.US_EST_Rights__c && dg.US_VOD_Rights__c && dg.CA_EST_Rights__c 
                                && dg.CA_VOD_Rights__c && dg.Rights_Validated__c == FALSE) {
                                dg.Rights_Validated__c = TRUE;
                            }    
                            
                            lstDRrecs.add(dg);
                        }
                    }
                } 
                
                if(lstDRrecs!=null && lstDRrecs.size()>0)
                {
                    system.debug('========='+lstDRrecs);
                    update lstDRrecs;
                    
                }
                    
            }
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        System.debug('Finsied update');
            
  	}
}