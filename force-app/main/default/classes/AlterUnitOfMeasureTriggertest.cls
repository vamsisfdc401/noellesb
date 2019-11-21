@isTest
private class AlterUnitOfMeasureTriggertest{

    @isTest
    static void testMethod_1()
    {
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        system.debug('Title created' +objTitle.id);
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
         Sub_Label_Code__c sg= new Sub_Label_Code__c();
        sg.Name = 'ACQUIRED LIBRARY TV';
        sg.Sub_Label_Code_ID__c = '87';
        Insert sg;
        
        Alternative_Legal_Title__c alt= new Alternative_Legal_Title__c();
        alt.Name ='"CROCODILE" DUNDEE II';
        alt.Alternative_Legal_Title_ID__c = '00352450';
        Insert alt;
        
        Material__c eachMat = new Material__c();
        eachMat.Release__c = objRelease.id;
        eachMat.Material_Type__c='FERT';
        eachMat.Material_Status__c='Processed in SAP';
        eachMat.name='Test1';
        eachMat.SGENNO__c='12113';               
        eachMat.Street_Date__c=date.today();                
        eachMat.Item_Type__c='S (Single)';               
        eachMat.Item_Code__c='SE - TV SINGLE EPISODES';                
        eachMat.General_Item_Category_Group__c='NORM';                
        eachMat.Format__c='02 - DVD';                
        eachMat.Technical_Format__c='01 - FULL FRAME';                 
        eachMat.Product_Class__c='02 - HIT';               
        eachMat.Title_Source__c='02 - TELEVISION';               
        eachMat.Deal_ID__c='11313';               
        eachMat.TM_Origin_Code__c='010 - Universal Pictures';                
        //eachMat.Label_Code__c='15 - Ficel Marketing';
        eachMat.Label_Code__c='24 - PURE FLIX';               
        eachMat.Sub_Label_Code_Lookup__c=sg.id;                
        eachMat.Cross_Ref_Type__c='USHV';                
        eachMat.Base_Unit_of_Measure__c='EA';             
        eachMat.Material_Group__c='55111514 - Product Duplication - Motion pictures on Digital Video';               
        eachMat.Division__c='Di';                
        eachMat.Xplant_Material_Status__c='NA';                 
        eachMat.Xplant_Valid_From__c=date.today();                
        eachMat.Gross_Weight__c=1;                
        eachMat.Net_Weight__c=1;                
        eachMat.Alternative_Legal_Title_Lookup__c=alt.Id;
        eachMat.Create_Version__c=True;                
        eachMat.X_Dchain_Status__c='NA';                
        eachMat.X_Dchain_Valid_From__c=date.today();                
        eachMat.Purchase_Value_Key__c='aa';                 
        eachMat.Transportation_Group__c='as';
        eachMat.Weight_Unit__c = 'G - Gram';
        eachMat.Plant__c = 'as';
        //eachMat.SGENNO_ReadOnly__c =
        eachMat.Valid_From__c = system.today();
        eachMat.Title__c =objTitle.id;
        eachMat.Industry_Sector__c = 'a';
        eachMat.BOM_Usage__c = 'a';
        eachMat.BOM_Category__c = 'a';
        eachMat.Layer__c ='as';
        eachMat.TM_Status__c ='01 - APPROVED';
        eachMat.Territory__c='US';
        //eachMat.BOM_Quantity__c = 12;        // added on 20 dec 
        //eachMat.Prior_BOM_Quantity__c = '3'; // added on 20 dec 
        Insert eachMat;
        
        Alternative_Unit_of_Measure__c aum=new Alternative_Unit_of_Measure__c();
        aum.material__c=eachMat.id;
        insert aum;
        
      }
      
      @isTest
    static void testMethod_2()
    {
        Title__c objTitle = new Title__c(Name='DummyTitle',Active_Flag__c=true,SGENNO__c='12345');
        insert objTitle;
        
        system.debug('Title created' +objTitle.id);
        
        Release__c objRelease = new Release__c(Internal_Announce_Date__c=Date.Today()-3,Name='Test Release',Street_Date__c = Date.Today(),Brand_Group__c='Family',Project_Type__c = 'New Release Mattel',Release_Status__c='Materials Not Requested',EST_Date__c=Date.Today());
        insert objRelease;
        
         Sub_Label_Code__c sg= new Sub_Label_Code__c();
        sg.Name = 'ACQUIRED LIBRARY TV';
        sg.Sub_Label_Code_ID__c = '87';
        Insert sg;
        
        Alternative_Legal_Title__c alt= new Alternative_Legal_Title__c();
        alt.Name ='"CROCODILE" DUNDEE II';
        alt.Alternative_Legal_Title_ID__c = '00352450';
        Insert alt;
        
        Material__c eachMat = new Material__c();
        eachMat.Release__c = objRelease.id;
        eachMat.Material_Type__c='FERT';
        eachMat.Material_Status__c='Draft';
        eachMat.name='Test1';
        eachMat.SGENNO__c='12113';               
        eachMat.Street_Date__c=date.today();                
        eachMat.Item_Type__c='S (Single)';               
        eachMat.Item_Code__c='SE - TV SINGLE EPISODES';                
        eachMat.General_Item_Category_Group__c='NORM';                
        eachMat.Format__c='02 - DVD';                
        eachMat.Technical_Format__c='01 - FULL FRAME';                 
        eachMat.Product_Class__c='02 - HIT';               
        eachMat.Title_Source__c='02 - TELEVISION';               
        eachMat.Deal_ID__c='11313';               
        eachMat.TM_Origin_Code__c='010 - Universal Pictures';                
        //eachMat.Label_Code__c='15 - Ficel Marketing';
        eachMat.Label_Code__c='24 - PURE FLIX';               
        eachMat.Sub_Label_Code_Lookup__c=sg.id;                
        eachMat.Cross_Ref_Type__c='USHV';                
        eachMat.Base_Unit_of_Measure__c='EA';             
        eachMat.Material_Group__c='55111514 - Product Duplication - Motion pictures on Digital Video';               
        eachMat.Division__c='Di';                
        eachMat.Xplant_Material_Status__c='NA';                 
        eachMat.Xplant_Valid_From__c=date.today();                
        eachMat.Gross_Weight__c=1;                
        eachMat.Net_Weight__c=1;                
        eachMat.Alternative_Legal_Title_Lookup__c=alt.Id;
        eachMat.Create_Version__c=True;                
        eachMat.X_Dchain_Status__c='NA';                
        eachMat.X_Dchain_Valid_From__c=date.today();                
        eachMat.Purchase_Value_Key__c='aa';                 
        eachMat.Transportation_Group__c='as';
        eachMat.Weight_Unit__c = 'G - Gram';
        eachMat.Plant__c = 'as';
        //eachMat.SGENNO_ReadOnly__c =
        eachMat.Valid_From__c = system.today();
        eachMat.Title__c =objTitle.id;
        eachMat.Industry_Sector__c = 'a';
        eachMat.BOM_Usage__c = 'a';
        eachMat.BOM_Category__c = 'a';
        eachMat.Layer__c ='as';
        eachMat.TM_Status__c ='01 - APPROVED';
        eachMat.Territory__c='US';
        //eachMat.BOM_Quantity__c = 12;        // added on 20 dec 
        //eachMat.Prior_BOM_Quantity__c = '3'; // added on 20 dec 
        Insert eachMat;
        
        Alternative_Unit_of_Measure__c aum=new Alternative_Unit_of_Measure__c();
        aum.material__c=eachMat.id;
        aum.Alternative_Unit_of_Measure__c='EA - Each';
        insert aum;
        
        Alternative_Unit_of_Measure__c aum11=new Alternative_Unit_of_Measure__c();
        aum11.material__c=eachMat.id;
        aum11.Alternative_Unit_of_Measure__c='EA - Each';
        insert aum11;
        
        
        Alternative_Unit_of_Measure__c aum1=[Select id,Alternative_Unit_of_Measure__c from Alternative_Unit_of_Measure__c where id=:aum.id];
        aum1.Alternative_Unit_of_Measure__c='CAR - Carton';
        update aum1;
      }  
        
    }