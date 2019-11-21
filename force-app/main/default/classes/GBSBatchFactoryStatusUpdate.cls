/*****************************************************************************************
Class Name: GBSBatchFactoryStatusUpdate
Purpose: This class handles the business logic for updating the Factory Status when 
Approval Expiration date on latest workflow is today.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             05/06/2018           Ashok Raghavan          Initial Development (GBS 276)
2.0             08/28/2018           Ashok Raghavan          GBS-750
******************************************************************************************/
global class GBSBatchFactoryStatusUpdate implements Database.Batchable<sObject> 
 {
    global Database.QueryLocator start(Database.BatchableContext BC) {
       String query = 'Select id from Factory__c where Approval_Expiration_Date__c = today';
        return Database.getQueryLocator(query);
    }
     global void execute(Database.BatchableContext BC, List<Factory__c> Factorylist) {
        set<id> FactoryIds = new set <id>();
        Map<id,string> MapFactory = new Map<id,string>();
        Map<String,string> MapActiontoStatus = new Map<string,string>();
        Map<string,string> MapNewFactoryStatus = new Map<string,string>();
        
        If (!Factorylist.isempty()){
            for(Factory__c wrk : Factorylist){
                FactoryIds.add(wrk.ID);
            }
        }   
      
      
        If (!FactoryIds.isempty()){
             
            Set<Factory__c> ListFactory = new Set<Factory__c> ( [ Select id,Name, (Select Action_Status__c from Workflows__r where Action_Status__c != null and GBS_Current_Workflow__c = true)  from Factory__c  where id IN :FactoryIds ]);
            
            for (Factory__c wrk: ListFactory){
               
                If (!wrk.Workflows__r.isempty()){
                MapFactory.put(wrk.Id,wrk.Workflows__r[0].Action_Status__c);
                }
            }
        }
       
        If(!MapFactory.isempty()){
            List<Factory__c> RetriveFactorytoupdate = [Select id,Factory_Status__c from Factory__c where ID IN :MapFactory.keySet()];
        
            //Get all custom settings
            for(FactoryActiontoStatus__c customRules : FactoryActiontoStatus__c.getAll().values()) {
                MapActiontoStatus.put(customRules.Action_Status_del__c,customRules.Factory_Status__c);
            }
             
                for( string Fid:MapFactory.Keyset()) {
                        MapNewFactoryStatus.put(Fid,MapActiontoStatus.get(MapFactory.get(Fid)));
                }
            
             List<Factory__c> Factorylisttoupdate = new List<Factory__C>();
               for (Factory__c Factory: RetriveFactorytoupdate){
                  {
                         Factory.Factory_Status__c =  MapNewFactoryStatus.get(Factory.id);
                         Factorylisttoupdate.add(Factory);
                     }
                 }
            update Factorylisttoupdate;
         }
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}