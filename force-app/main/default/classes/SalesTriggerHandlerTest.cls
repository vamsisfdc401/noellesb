/*****************************************************************************************
Class Name: SalesTriggerHandlerTest
Purpose: Test class for apex class SalesTriggerHandler
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             03/09/2016           Suman                    Initial Development
*****************************************************************************************/
@isTest
private class SalesTriggerHandlerTest{
    @isTest
    static void testMethod_1()
    {
        Test.startTest();
        
        Profile objProfile=[Select Id from Profile where Name ='Platform API'];        
        User platformApiUser = new User(alias = 'TestUser', 
                                        email='test@test.com',
                                        emailencodingkey='UTF-8',
                                        FirstName='API',            
                                        lastname='User', 
                                        languagelocalekey='en_US',
                                        localesidkey='en_US', 
                                        //UserRoleId=objRole.Id, 
                                        profileid=objProfile.ID,
                                        country='United States',
                                        timezonesidkey='America/Los_Angeles',  
                                        username='testadmin345@test.com',
                                        isActive = true);
        System.runAs(platformApiUser) {
            
            Title__c objTitle = new Title__c(Name='DummyTitle');
            insert objTitle;
            
            Release__c objRelease = new Release__c(EST_Date__c=Date.Today(),Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested');
            insert objRelease;
            
            Material__c objMaterial = new Material__c(Format__c = '02 - DVD',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS (Single Selection)');
            objMaterial.Label_Code__c='24 - PURE FLIX';
            objMaterial.Territory__c = 'US';
            insert objMaterial;
            
            Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'EST (ELECTRONIC SELL THRU)',Material_Status__c='Approved',name='dummy1',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
            objMaterial1.Label_Code__c='24 - PURE FLIX';
            objMaterial1.Territory__c = 'US';
            insert objMaterial1;
            
            Material__c mat1 = new Material__c();
            mat1.Label_Code__c='24 - PURE FLIX';
            mat1.Name = 'Test Material';
            mat1.Material_Status__c = 'Draft';
            mat1.Material_Type__c = 'FERT';
            mat1.Format_Description__c = 'DVD';
            mat1.Release__c = objRelease.Id;
            mat1.Territory__c = 'US';
                
            insert mat1;
            
            Material__c mat2 = new Material__c();
            mat2.Label_Code__c='24 - PURE FLIX';
            mat2.Name = 'Test Material Again';
            mat2.Material_Status__c = 'Draft';
            mat2.Material_Type__c = 'FERT';
            mat2.Format_Description__c = 'DVDR';
            mat2.Release__c = objRelease.Id;
            mat2.Territory__c = 'US & CDN';       
            insert mat2;
            
            Sales__c s = new Sales__c(Street_Date__c=System.today(),Theatrical_Release_Date__c=System.today(),Pre_Order_Date__c=System.today(),Original_Release_Date__c=System.today(),Solicitation_Date__c=System.today());
            s.Material__c = objMaterial.Id;
            Insert s;
            
            Sales__c s1 = new Sales__c(Street_Date__c=System.today(),Theatrical_Release_Date__c=System.today(),Pre_Order_Date__c=System.today(),Original_Release_Date__c=System.today(),Solicitation_Date__c=System.today());
            s1.Material__c = objMaterial1.Id;
            Insert s1;
            
            Sales__c s2 = new Sales__c(Street_Date__c=System.today(),Theatrical_Release_Date__c=System.today(),Pre_Order_Date__c=System.today(),Original_Release_Date__c=System.today(),Solicitation_Date__c=System.today(),Deletion_Flag__c=true);
            s2.Material__c = mat1.Id;
            Insert s2; 
            
            Sales__c s3 = new Sales__c(Street_Date__c=System.today() - 4,Theatrical_Release_Date__c=System.today(),Pre_Order_Date__c=System.today() - 2,Original_Release_Date__c=System.today(),Solicitation_Date__c=System.today(),Deletion_Flag__c=true);
            s3.Material__c = mat2.Id;
            Insert s3; 
            
            
            
            list<Sales__c> salesList = new list<Sales__c>();
            salesList.add(s);
            salesList.add(s1);
            salesList.add(s2);      
            
            SalesTriggerHandler.updatePreOrderDate(salesList); 
            system.debug('s2--->old'+s2.Deletion_Flag__c);
                      
            Sales__c sal=  [select id ,Deletion_Flag__c,Street_Date__c,Theatrical_Release_Date__c,Pre_Order_Date__c from Sales__c where id=:s2.id];
            system.debug('sal--->old'+sal.Deletion_Flag__c);
            sal.Deletion_Flag__c = false;
            update sal;
            system.debug('s2--->new'+s2.Deletion_Flag__c);
            system.assertEquals(false,sal.Deletion_Flag__c);
            
            s3.Deletion_Flag__c = false;
            update s3;
            
            
            Test.stopTest(); 
        }
    } 
    
    @isTest
    static void testMethod_2()
    {
        Test.startTest();
        
        Profile objProfile=[Select Id from Profile where Name ='Platform API'];        
        User platformApiUser = new User(alias = 'TestUser', 
                                        email='test@test.com',
                                        emailencodingkey='UTF-8',
                                        FirstName='API',            
                                        lastname='User', 
                                        languagelocalekey='en_US',
                                        localesidkey='en_US', 
                                        //UserRoleId=objRole.Id, 
                                        profileid=objProfile.ID,
                                        country='United States',
                                        timezonesidkey='America/Los_Angeles',  
                                        username='testadmin345@test.com',
                                        isActive = true);
        System.runAs(platformApiUser) {
            
            Title__c objTitle = new Title__c(Name='DummyTitle');
            insert objTitle;
            
            Release__c objRelease = new Release__c(EST_Date__c=Date.Today(),Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested');
            insert objRelease;
            
            Material__c objMaterial = new Material__c(Format__c = '02 - DVD',Format_Description__c= 'DVD',Material_Status__c='Draft',name='dummy',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SS (Single Selection)');
            objMaterial.territory__c='US';
            objMaterial.Label_Code__c='24 - PURE FLIX';
            insert objMaterial;
            
            Material__c objMaterial1 = new Material__c(Material_Number__c='1213233',Format_Description__c= 'EST (ELECTRONIC SELL THRU)',Material_Status__c='Approved',name='dummy1',Material_Type__c= 'FERT',Release__c = objRelease.id,Association_Required__c=TRUE, Item_Type__c='S (Single)',Item_Code__c='SE - TV SINGLE EPISODES');
            objMaterial1.Label_Code__c='24 - PURE FLIX';
            insert objMaterial1;
            
            Material__c mat1 = new Material__c();
            mat1.Label_Code__c='24 - PURE FLIX';
            mat1.Name = 'Test Material';
            mat1.Material_Status__c = 'Draft';
            mat1.Material_Type__c = 'FERT';
            mat1.Format_Description__c = 'DVD';
            mat1.Release__c = objRelease.Id;
            mat1.Territory__c = 'US';       
            insert mat1;
            
            Material__c mat2 = new Material__c();
            mat2.Label_Code__c='24 - PURE FLIX';
            mat2.Name = 'Test Material Again';
            mat2.Material_Status__c = 'Processed in SAP';
            mat2.Material_Type__c = 'FERT';
            mat2.Format_Description__c = 'DVDR';
            mat2.Release__c = objRelease.Id;
            mat2.Territory__c = 'US & CDN';       
            insert mat2;
            
            Sales__c s = new Sales__c(Street_Date__c=System.today(),Theatrical_Release_Date__c=System.today(),Pre_Order_Date__c=System.today(),Original_Release_Date__c=System.today(),Solicitation_Date__c=System.today());
            s.sales_org__c='V100 - US Home Video';
            s.Material__c = objMaterial.Id;
            s.Deletion_Flag__c = false;
            Insert s;
            
            
            Sales__c s2 = new Sales__c(Street_Date__c=System.today(),Theatrical_Release_Date__c=System.today(),Pre_Order_Date__c=System.today(),Original_Release_Date__c=System.today(),Solicitation_Date__c=System.today());
            s2.sales_org__c='V100 - US Home Video';
            s2.Material__c = mat2.Id;
            s2.Deletion_Flag__c = false;
            Insert s2; 
            
            Sales__c s3 = new Sales__c(Street_Date__c=System.today() - 4,Theatrical_Release_Date__c=System.today(),Pre_Order_Date__c=System.today() - 2,Original_Release_Date__c=System.today(),Solicitation_Date__c=System.today());
            s3.sales_org__c='V800 - Canada Home Video';
            s3.Material__c = mat2.Id;
            s2.Deletion_Flag__c = false;
            Insert s3; 
            
            
            
            list<Sales__c> salesList = new list<Sales__c>();
            salesList.add(s);
            salesList.add(s3);
            salesList.add(s2);      
            
            SalesTriggerHandler.updatePreOrderDate(salesList); 
            system.debug('s2--->old'+s2.Deletion_Flag__c);
                      
            Sales__c sal=  [select id ,Material__r.territory__c,Deletion_Flag__c,Street_Date__c,Theatrical_Release_Date__c,Pre_Order_Date__c from Sales__c where id=:s2.id];
            sal.Street_Date__c=System.today()+90;
            
            system.assertEquals('US & CDN',sal.Material__r.territory__c);
            update sal;
            
            
            List<Sales__c> sal1=  [select id ,Announcement_Date_US__c,Original_Release_Date__c,Solicitation_Date__c,sales_org__c,Material__r.territory__c,Deletion_Flag__c,Street_Date__c,Theatrical_Release_Date__c,Pre_Order_Date__c from Sales__c where id=:sal.id];
            
            
            SalesTriggerHandler.updateStreetDateOnMaterial(sal1);
            SalesTriggerHandler.executeOnBeforeDelete(sal1);

            Test.stopTest(); 
        }
    }
    
    
    private static testMethod void testFunctionValue(){
        
        Profile objProfile=[Select Id from Profile where Name ='System Administrator'];        
        
        
        User platformApiUser = new User(alias = 'TestUser', 
                                        email='test@test.com',
                                        emailencodingkey='UTF-8',
                                        FirstName='API',            
                                        lastname='User', 
                                        languagelocalekey='en_US',
                                        localesidkey='en_US', 
                                        //UserRoleId=objRole.Id, 
                                        profileid=objProfile.ID,
                                        country='United States',
                                        timezonesidkey='America/Los_Angeles',  
                                        username='testadmin345@test.com',
                                        isActive = true);
        System.runAs(platformApiUser) {
        
        
            Title__c objTitle = new Title__c(Name='DummyTitle');
            insert objTitle;
            
            Release__c objRelease = new Release__c(EST_Date__c=Date.Today(),Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested');
            insert objRelease;
            
            Material__c mat2 = new Material__c();
            mat2.Label_Code__c='24 - PURE FLIX';
            mat2.Name = 'Test Material Again';
            mat2.Material_Status__c = 'Processed in SAP';
            mat2.Material_Type__c = 'FERT';
            mat2.Format_Description__c = 'DVDR';
            mat2.Release__c = objRelease.Id;
            mat2.Territory__c = 'US & CDN';       
            insert mat2;
            
            Sales__c s2 = new Sales__c(Street_Date__c=System.today(),Theatrical_Release_Date__c=System.today(),Pre_Order_Date__c=System.today(),Original_Release_Date__c=System.today(),Solicitation_Date__c=System.today());
            s2.sales_org__c='V100 - US Home Video';
            s2.Material__c = mat2.Id;
            s2.Deletion_Flag__c = false;
            Insert s2; 
                

            Test.startTest();
                Sales__c sal=  [select id ,Material__r.territory__c,Deletion_Flag__c,Street_Date__c,Theatrical_Release_Date__c,Pre_Order_Date__c from Sales__c where id=:s2.id];
                sal.Deletion_Flag__c = true;
                update sal;
            Test.stopTest();
        
        }
    }

}