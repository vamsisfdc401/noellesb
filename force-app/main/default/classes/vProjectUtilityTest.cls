/*****************************************************************************************
Class Name: vProjectUtilityTest
Purpose: Test class for apex class vProjectUtility 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             29/11/2016           Suman                    Initial Development
******************************************************************************************/
@isTest
public class vProjectUtilityTest
{
    @isTest
    static void testCreateVProject_1()
    {       
        Title__c objTitle = new Title__c(Name='DummyTitle', Active_Flag__c=TRUE,SGENNO__c='12345');
        insert objTitle;
        
        Deal__c dealObj = new Deal__c(Primary_Deal__c = TRUE , Title__c = objTitle.Id);
        insert(dealObj);
        
        Release__c objRelease = new Release__c(Name='Test Release', Street_Date__c=Date.Today(), Brand_Group__c='Universal Pictures', Project_Type__c='New Release', Release_Status__c='Materials Requested', v_Project_Required__c=TRUE, Label_Code__c='61 - Universal Pictures', Territory__c='US');
        insert objRelease; 
        
        Release__c objRelease2 = new Release__c(Name='Test Release', Street_Date__c=Date.Today(), Brand_Group__c='Universal Pictures', Project_Type__c='Catalog', Release_Status__c='Materials Requested', v_Project_Required__c=TRUE, Label_Code__c='61 - Universal Pictures', Territory__c='CDN');
        insert objRelease2;
        
        List<Material__c> insertableMats = new List<Material__c>();
        
        Material__c matFERT1 = new Material__c(name='Test FERT 1', Material_Description_Unique__c='Test FERT 1', Material_Type__c= 'FERT', Release__c=objRelease.id, Territory__c='US', Item_type__c='M (Multipack)', Item_Code__c='CL - COLLECTION PACK', Material_Status__c='Draft', Format_Description__c='DVD');
        insertableMats.add(matFERT1);
        
        Material__c matFERT2 = new Material__c(name='Test FERT 2', Material_Description_Unique__c='Test FERT 2', Material_Type__c= 'FERT', Release__c=objRelease2.id, Title__c=objTitle.Id, Territory__c='US', Item_type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Material_Status__c='Processed in SAP', Format_Description__c='DVDR');
        matFERT2.Material_Number__c = '31211211';
        insertableMats.add(matFERT2);
        TriggerUtility.doNotExecute = TRUE;
        insert insertableMats;
        TriggerUtility.doNotExecute = TRUE;
        
        Test.startTest();
        
        vProjectUtility.createVProject(new List<Release__c>{objRelease});
        vProjectUtility.createVProject(new List<Release__c>{objRelease2});
        
        vProjectUtility.addVMaterials(new List<Material__c>{matFERT1}, new Map<Id, Set<Id>>{matFERT1.Id=>new Set<Id>{objRelease.Id}});
        vProjectUtility.addVMaterials(new List<Material__c>{matFERT2}, new Map<Id, Set<Id>>{matFERT2.Id=>new Set<Id>{objRelease2.Id}});
        
        Test.stopTest();
    }
    
    @isTest
    static void testCreateVProject_2()
    {       
        Title__c objTitle = new Title__c(Name='DummyTitle', Active_Flag__c=TRUE,SGENNO__c='12345');
        insert objTitle;
        
        Deal__c dealObj = new Deal__c(Primary_Deal__c = TRUE , Title__c = objTitle.Id);
        insert(dealObj);
        
        Release__c objRelease = new Release__c(Name='Test Release', Street_Date__c=Date.Today(), Brand_Group__c='Universal Pictures', Project_Type__c='New Release', Release_Status__c='Materials Requested', v_Project_Required__c=TRUE, Label_Code__c='61 - Universal Pictures', Territory__c='US');
        insert objRelease; 
        
        Release__c objRelease2 = new Release__c(Name='Test Release', Street_Date__c=Date.Today(), Brand_Group__c='Universal Pictures', Project_Type__c='New Release', Release_Status__c='Materials Requested', v_Project_Required__c=TRUE, Label_Code__c='61 - Universal Pictures', Territory__c='US');
        insert objRelease2;
        
        v_Project_Request__c vProjTitle1 = new v_Project_Request__c(Title__c=objTitle.Id, Project_Finish_Date__c=Date.today().addDays(1), Release__c=objRelease2.Id);
        insert vProjTitle1;
        
        List<Material__c> insertableMats = new List<Material__c>();
        
        Material__c matFERT1 = new Material__c(name='Test FERT 1', Material_Description_Unique__c='Test FERT 1', Material_Type__c= 'FERT', Release__c=objRelease.id, Territory__c='US', Item_type__c='M (Multipack)', Item_Code__c='CL - COLLECTION PACK', Material_Status__c='Draft', Format_Description__c='DVD');
        TriggerUtility.doNotExecute=true;
        insert matFERT1;
        TriggerUtility.doNotExecute=false;
        
                
        Material__c matFERT2 = new Material__c(name='Test FERT 2', Material_Description_Unique__c='Test FERT 2', Material_Type__c= 'FERT', Release__c=objRelease2.id, Title__c=objTitle.Id, Territory__c='US', Item_type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Material_Status__c='Processed in SAP', Format_Description__c='DVD', Internal_Announce_Date__c=Date.today());
        TriggerUtility.doNotExecute=true;
        insert matFERT2;
        TriggerUtility.doNotExecute=false;
        
        Release_Material__c relMat = new Release_Material__c(Release__c = objRelease.id,Material__c = matFERT1.id);
        insert relMat;
        
        Release_Material__c relMat1 = new Release_Material__c(Release__c = objRelease2.id,Material__c = matFERT2.id);
        insert relMat1;
        
        Material__c matFERTupdate = new Material__c(id = matFERT1.id,material_number__c = '87654321000');
        update matFERTupdate;
        
        Test.startTest();
        
        vProjectUtility.createVProject(new List<Release__c>{objRelease});
        vProjectUtility.createVProject(new List<Release__c>{objRelease2});
        
        vProjectUtility.addVMaterials(new List<Material__c>{matFERT1}, new Map<Id, Set<Id>>{matFERT1.Id=>new Set<Id>{objRelease.Id}});
        v_Material__c vMat = new v_Material__c();
        vMat.Material__c = matFERT2.Id;
        vMat.v_Project__c = vProjTitle1.Id;
        vMat.Status__c = 'Active';
        insert vMat;
        vProjectUtility.addVMaterials(new List<Material__c>{matFERT2}, new Map<Id, Set<Id>>{matFERT2.Id=>new Set<Id>{objRelease2.Id}});
        
        vMat.Marked_for_Inactivation__c = TRUE;
        vProjectUtility.addVMaterials(new List<Material__c>{matFERT2}, new Map<Id, Set<Id>>{matFERT2.Id=>new Set<Id>{objRelease2.Id}});
        
        vProjectUtility.removeVMaterial(new List<Material__c>{matFERT1, matFERT2}, new Map<Id, Set<Id>>{matFERT1.Id=>new Set<Id>{objRelease.Id}, matFERT2.Id=>new Set<Id>{objRelease2.Id}});
        
        Test.stopTest();
    }
    
    @isTest
    static void testCreateVProject_3()
    {    
        TriggerUtility.doNotExecute = TRUE;
        Title__c objTitle = new Title__c(Name='DummyTitle', Active_Flag__c=TRUE,SGENNO__c='12345');
        insert objTitle;
        
        Release__c objRelease = new Release__c(Name='Test Release', Street_Date__c=Date.Today(), Brand_Group__c='Universal Pictures', Project_Type__c='New Release', Release_Status__c='Materials Requested', v_Project_Required__c=FALSE, Label_Code__c='61 - Universal Pictures', Territory__c='US');
        insert objRelease; 
        
        Release__c objRelease2 = new Release__c(Name='Test Release', Street_Date__c=Date.Today(), Brand_Group__c='Universal Pictures', Project_Type__c='New Release', Release_Status__c='Materials Requested', v_Project_Required__c=TRUE, Label_Code__c='61 - Universal Pictures', Territory__c='US');
        objRelease2.Title__c = objTitle.id;  // added to fix error 
        insert objRelease2; 
        
        v_Project_Request__c vProjTitle1 = new v_Project_Request__c(Title__c=objTitle.Id, Project_Finish_Date__c=Date.today().addDays(1), Release__c=objRelease2.Id);
        insert vProjTitle1;
        
        Material__c matFERT1 = new Material__c(name='Test FERT 1', Material_Description_Unique__c='Test FERT 1', Material_Type__c= 'FERT', Release__c=objRelease.id, Title__c=objTitle.Id, Territory__c='US', Item_type__c='S (Single)', Item_Code__c='SS - SINGLE SELECTION', Material_Status__c='Draft', Format_Description__c='DVD');
        insert matFERT1;
        
        
        matFERT1.Internal_Announce_Date__c = SYSTEM.TODAY();// added to fix error
        matFERT1.Pre_Order_Close_Date__c = SYSTEM.TODAY();
        matFERT1.Material_Number__c = '1237812631';  // added to fix error
        matFERT1.Material_Status__c='Processed in SAP';
        update matFERT1;
        TriggerUtility.doNotExecute = FALSE;
        
        Test.startTest();
        
        objRelease.v_Project_Required__c = TRUE;
        update objRelease;
        vProjectUtility.createVProject(new List<Release__c>{objRelease});
        
        vProjectUtility.addVMaterials(new List<Material__c>{matFERT1}, new Map<Id, Set<Id>>{matFERT1.Id=>new Set<Id>{objRelease.Id}});
        system.assertNotEquals(null,matFERT1);
        v_Material__c vMat = [SELECT Id FROM v_Material__c WHERE Material__c=:matFERT1.Id];
        system.assertNotEquals(null,vMat);
        vMat.Marked_for_Inactivation__c = TRUE;
        update vMat;
        
        vProjectUtility.addVMaterials(new List<Material__c>{matFERT1}, new Map<Id, Set<Id>>{matFERT1.Id=>new Set<Id>{objRelease.Id}});
        
        Test.stopTest();
    }
}