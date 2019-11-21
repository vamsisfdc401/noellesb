/*****************************************************************************************
Class Name: DGF_PackageComponentControllerTest
Purpose: Test class for apex class DGF_PackageComponentController
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             29/06/2017           Prarthana               Initial Development
******************************************************************************************/
@isTest(seeAllData=FALSE)
public with sharing class DGF_PackageComponentControllerTest {
    /***********************************
    Method Name: scenario1
    Purpose: method to test scenarios for DFOR-420 and DFOR-421
    ***********************************/
    static testMethod void scenario1(){
        Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get('Film').getRecordTypeId();  
        //create digital release of type film
        list<Digital_Release__c>rel=DGF_TestDataUtility.createDigitalRelease(1, FilmRecTypeId);
        insert rel;
        //create a bonus record associated to the release
        EPO_Bonus__c bonus=new EPO_Bonus__c(Name='test',Digital_Release__c=rel[0].id,Package__c='CPE;FOD');
        insert bonus;
        list<String>pkgList=new list<String>();
        test.startTest();
        pkgList=DGF_PackageComponentController.fetchBonusRecords(rel[0].id);
        DGF_PackageComponentController.getBonusDetails(rel[0].id, 'CPE');
        DGF_PackageComponentController.getBonusDetails(rel[0].id, 'viewAll');
        DGF_PackageComponentController.getRecordTypeId();
        DGF_PackageComponentController.createBonusRecord(rel[0].id, 'iTunes Extras',pkgList );
        DGF_PackageComponentController.removePackage(rel[0].id, 'CPE', pkgList);
        DGF_PackageComponentController.removePackage(rel[0].id, 'iTunes Extras', pkgList);
        DGF_PackageComponentController.getProfileDetails();
        DGF_PackagecomponentController.getReleaseName(rel[0].id);
        //query for the number of bonus records
        Integer i=[SELECT count() from EPO_Bonus__c where Digital_Release__c=:rel[0].id];
        System.assertEquals(1, i);
        test.stopTest();
    }
}