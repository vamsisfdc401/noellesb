public class CIRFMaterialExceptionTriggerHandler extends TriggerHandler {
    public static boolean executedFromUpload = false;
    public CIRFMaterialExceptionTriggerHandler() {
        
    }
    
    public override void beforeInsert() {
        if(executedFromUpload){
            populateOriginalStatus();
        }
    }
    
    private void populateOriginalStatus() {
        List<Id> materialIds = new List<Id>();
        List<Id> retailerIds = new List<Id>();
        Date currentDate = date.TODAY();
        for(CIRF_Material_Exceptions__c cme : (List<CIRF_Material_Exceptions__c>) trigger.new){
            materialIds.add(cme.Material__c);
            retailerIds.add(cme.Retailer__c);
        }
        
        Map<Id, Account> accountsMap = new Map<Id, Account>([select id, territory__c from Account where id IN :retailerIds]);
        Map<Id, Material__c> materials = new Map<Id, Material__c>([select id, CIRF_US_D_Chain_Spec__c, CIRF_CDN_D_Chain_Spec__c from Material__c where id IN :materialIds]);
        List<CIRF_Material_Exceptions__c> activeCIRFMatExceptions = [select id, Material__c, Material__r.Material_Status__c, Original_Status__c from CIRF_Material_Exceptions__c where Material__c IN :materialIds and End_Date__c > :currentDate order by CreatedDate];
        Map<Id, CIRF_Material_Exceptions__c>  activeExceptionMap = new Map<Id, CIRF_Material_Exceptions__c>();
        for(CIRF_Material_Exceptions__c cme : activeCIRFMatExceptions){
            activeExceptionMap.put(cme.Material__c, cme);
        }
        for(CIRF_Material_Exceptions__c cme : (List<CIRF_Material_Exceptions__c>) trigger.new){
            if(activeExceptionMap.get(cme.Material__c)!=null){
                cme.Original_Status__c = (activeExceptionMap.get(cme.Material__c)).Original_Status__c;
            }
            else{
                if((accountsMap.get(cme.Retailer__c)).territory__c == 'US'){
                    cme.Original_Status__c = ((materials.get(cme.Material__c)).CIRF_US_D_Chain_Spec__c).substring(0,2);
                }
                else{
                    cme.Original_Status__c = ((materials.get(cme.Material__c)).CIRF_CDN_D_Chain_Spec__c).substring(0,2);
                }
            }
        }
    }
}