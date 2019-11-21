public class PromotionProductDataUpdateBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext pobjCntxt){
        return Database.getQueryLocator('SELECT Id FROM Promotion__c');
    }
    public void execute(Database.BatchableContext pobjCntxt,List<Promotion__c> pLisrPromos){
        List<Promotion_Product__c> listPromoProds = new List<Promotion_Product__c>();
        String strPromoId;
        Integer intCounter = 0;
        
        for(Promotion_Product__c loopPromoProd : [SELECT Id,Promotion__c,Sort_Index__c FROM Promotion_Product__c WHERE Promotion__c IN :pLisrPromos ORDER BY Promotion__c]){
            if(strPromoId == loopPromoProd.Promotion__c){
                loopPromoProd.Sort_Index__c = intCounter++;
            }
            else{
                strPromoId = loopPromoProd.Promotion__c;
                intCounter = 0;
                loopPromoProd.Sort_Index__c = intCounter++;
            }
            listPromoProds.add(loopPromoProd);
        }
        if(!listPromoProds.isEmpty()){
            update listPromoProds;
        }
    }
    public void finish(Database.BatchableContext pobjCntxt){
        
    }
}