public class RTImage {
    Inventory__c parse = [SELECT Id, Primary_image_ID__c FROM Inventory__c LIMIT 1];

}