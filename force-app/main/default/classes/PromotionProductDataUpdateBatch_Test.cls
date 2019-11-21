@isTest
public class PromotionProductDataUpdateBatch_Test {
    public static testMethod void testBatch(){
		Promotion__c objPromo = new Promotion__c();
        objPromo.RecordTypeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get('Account Promotion').getRecordTypeId();
        objPromo.End_Date__c = Datetime.now().addDays(10).date();
        objPromo.Name = 'Test Promo';
        objPromo.Promotion_Type__c = 'TPR';
        objPromo.Start_Date__c = Datetime.now().addDays(1).date();
        insert objPromo;
        
        Product__c objProd = new Product__c();
        objProd.Name = 'Test Prod';
        insert objProd;
        
        
        Promotion_Product__c objPromoProd = new Promotion_Product__c();
        objPromoProd.Product__c =objProd.Id;
        objPromoProd.Promotion__c = objPromo.Id;
        insert objPromoProd;
        
        Test.startTest();
        	Database.executeBatch(new PromotionProductDataUpdateBatch());
        Test.stopTest();
    }
}