@isTest
public class test_CIRF_Utility {
        @isTest
        public Static void testReadCSV(){
            Test.startTest();
            String str = 'Material Description,Material Number,SRP,DRC,Account Retail Price,Promo Cost,Funding Notes,Units to Order,Replen Duration,Replen Units,Number of Regie Stickers,French Required\n'+
                '"""12TH MAN BD""",86507199000,10,11,20,6,Need more,11,1,20,5,FALSE\n'+
                '"""12TH MAN BD""",86507199000,10,11,20,6,Need more,12,1,20,5,FALSE\n'+
                '12TH MAN\n DVD,86507198000,20,21,40,6,Need more,21,2,20,5,FALSE\n'+
                '12TH MAN DVD,86507198000,20,21,40,6,Need more,22,2,20,5,FALSE\n'+
                '"PAPILLON (2017) ,DVD CDN",32201090000,30,21,60,6,Need more,31,3,20,5,FALSE\n'+
                '"PAPILLON (2017) ,DVD CDN",32201090000,30,21,60,6,Need more,32,3,20,5,FALSE\n'+
                '"BUY  BUST,"" BDC",80199705000,20,31,80,6,Need more,41,4,20,5,FALSE\n';
            List<List<String>> readList =  CIRF_Utility.ReadCSV(str);
            Test.stopTest();
        }
        
        
        @isTest
        public Static void testReviseCIRF(){
            
            Material__c mat = CIRF_TestDataFactory.createMaterial('US', 'Test Material', '1234', '61 - Universal Pictures', 'AA','');
            insert mat;
            Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'US', 'Test', '1234');
            insert acc;
            date startDate = date.newInstance(2018, 11, 15);
            date endDate = date.newInstance(2018, 11, 28);
            date insStoreDate = date.newInstance(2018, 11, 1);
            CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
            insert header;
            CIRF_Material__C cmat = CIRF_TestDataFactory.createCIRFMaterial(header.id, mat.id, 'Draft', 2, 2);
            insert cmat;
            CIRF_Corrugate__c ccorr =CIRF_TestDataFactory.createCIRFCorrugate(header.id,'test corrugate','Singles Request', 2);
            insert ccorr;
            Test.startTest();
            header.CIRF_Status__c = 'Submitted';
            update header;
            cmat.CIRF_Material_Status__c = 'Submitted';
            update cmat;
            CIRF_Utility.ReviseCIRF(header,false);
            CIRF_Utility.ReviseCIRF(header,true);
            Test.stopTest();
        }
        @isTest
        public static void testmapCSVHeaderToFieldName(){            
            date startDate = date.newInstance(2018, 11, 15);
            date endDate = date.newInstance(2018, 11, 28);
            date insStoreDate = date.newInstance(2018, 11, 1);
            Account acc = CIRF_TestDataFactory.createRetailerAccount('Test Retailer', 'US', 'Test', '1234');
            insert acc;
            CIRF_Header__c header = CIRF_TestDataFactory.createCIRFHeader('Test Header2', 'Corrugate', acc.id, startDate, endDate, insStoreDate, 'Draft' , false);
            insert header;
            List<String> headerVals = new List<String>{'Material Description','Material Number','SRP','DRC','Account Retail Price','Promo Cost','Funding Notes','Units to Order','Replen Duration','Replen Units','Number of Regie Stickers','French Required'};
            CIRF_Utility.mapCSVHeaderToFieldName(headerVals,'CIRF_Header__c');
            CIRF_Utility.GetPlanningGroupByLabelCode();
            CIRF_Utility.getGroupMemberEmails(new List<Id>());
        }
    }