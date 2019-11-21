@isTest 
public class StatusupdatecirfheaderbatchTest {
    static CIRF_Header__c CirfHeader;
    static Account acctRetailer;
    static Material__c Material;
    static CIRF_Material__c CirfMat;
    static testmethod void  testMethod_1()
    {
        try{
            acctRetailer=CIRF_TestDataFactory.createRetailerAccount('test','US','Group 4','25221112');
            insert acctRetailer;
            CirfHeader=CIRF_TestDataFactory.createCIRFHeader('CIRFTest','Comingled Virtual Corrugate',acctRetailer.Id,system.today()-100,system.today()-99,system.today()-120,'Loaded',true);
            insert CirfHeader;
            Material=CIRF_TestDataFactory.createMaterial('US','universal','12324', '24 - PURE FLIX', '122',null);
            insert Material; 
            CirfMat=CIRF_TestDataFactory.createCIRFMaterial(CirfHeader.Id,Material.id,'Cancelled',0,2);
            CirfMat.split_forecast__c = false;
            insert CirfMat;
        }catch(exception ex){
            system.debug('Error line : '+ex.getLineNumber()+'==Error Message= '+ex.getMessage());
        }
        Test.startTest();
        Statusupdatecirfheaderbatch j= new Statusupdatecirfheaderbatch();
        DataBase.executeBatch(j);
        Test.stopTest();
    }
}