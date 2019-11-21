/*****************************************************************************************
Class Name: ReleaseTriggerHandler
Purpose: This class handles the business logic for Release Trigger.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             23/08/2016           Ipsita Mishra              Initial Development
******************************************************************************************/
public with sharing class ReleaseTriggerHandler{
    public static Map<id,Material__c> relMaterialMap = new Map<id,Material__c>();
    public static Map<id,Material__c> relMaterialMapnoApproval = new Map<id,Material__c>();
    public static Map<String,material__c>materialUpdateMap=new Map<String,material__c>(); //changes for USST-2861
    ReleaseTriggerHandler releaseHandler=new ReleaseTriggerHandler();
    public static Set<Id>materialIdSetExisting=new Set<Id>();
    public static List<Sales__c>insertableSales=new List<Sales__c>();
    public static List<Classification__c >insertableClassification=new List<Classification__c>();
    public static List<Alternative_Unit_of_Measure__c>insertableAUoMs=new List<Alternative_Unit_of_Measure__c>();
    public static List<Valuation__c>insertableVals=new List<Valuation__c>();
    public static List<Plant__c>insertablePlant=new List<Plant__c>();
    @testVisible
    private static boolean checkChildView =false;
    public static List<Material__c> matToUpdateList = new List<Material__c>();
    public static Boolean allDateUpdate=false;
    public static Map<String, Schema.SObjectType> allObjs = Schema.getGlobalDescribe();    //REL-43
    public static Schema.Describesobjectresult discResUser = allObjs.get('User').getDescribe();  //REL-43
    public static final string UPHE_Biz_Comm_Public_Group = 'UPHE Biz Comm'; //REL-43
    public static final string UPHE_Tech_Ops_Public_Group = 'UPHE Tech Ops'; //REL-43
    public static final string Master_Data_Public_Group = 'Master Data'; //REL-43
    public static final string Catalog_Planning_Public_Group = 'Universal New Release Planning'; //REL-43
    public static final string Release_Planning_Public_Group = 'Universal Catalog Planning Group'; //REL-43
    public static final string RF_Catalog_Planning_PHE = 'Catalog Planning-PHE'; //USST-2760
    public static final string Master_Data_PHE = 'Master Data-PHE'; //USST-2760
    public static final string RF_NR_Planning_PHE = 'NR Planning-PHE'; //USST-2760
    public static final string RF_All_NR_Planning = 'All NR Planning'; //USST-2891
    public static final string RF_NR_Planning_Partners = 'NR Planning-Partners'; //USST-2891
    public static final string RF_NR_Planning_UNI = 'NR Planning-UNI'; //USST-2891
    public static final string Master_Data_BPO = 'Master Data-BPO'; //USST-2891
    public static final string Master_Data_Partners = 'Master Data-Partners'; //USST-2891
    public static final string Master_Data_UNI = 'Master Data-UNI'; //USST-2891
    
    public static Set<ID> matsToCreateUpdate = new Set<ID>(); //USST-2793
    public static List<Sales__c> globalSalesList = new List<Sales__c>();  //USST-2861
    public static List<Plant__c> globalplantList = new List<Plant__c>();//USST-2861
    public static List<Classification__c> globalclassificationList = new List<Classification__c>();//USST-2861
    public static List<Valuation__c> globalvaluationList = new List<Valuation__c>();//USST-2861
    public static List<Alternative_Unit_of_Measure__c> globalAUOMList = new List<Alternative_Unit_of_Measure__c>();//USST-2861
    
    /************************************
    Method Name: updateBrandGroup
    Purpose:For Updating BrandGroup and Project Type on Release 
    *************************************/ 
    public static void updateBrandGroup(List<Release__c>releaseList){
        User u = TriggerUtility.currentUser;
        if(u!=null && u.brand_group__c!=null){
            for(Release__c rel:releaseList){
                if(rel.brand_group__c == null){
                    rel.brand_group__c=u.brand_group__c;
                }
                if(rel.brand_group__c == 'Catalog' && (rel.Project_Type__c == null || rel.Project_Type__c == '')) {
                    rel.Project_Type__c = 'Catalog';
                }
                else if(rel.Project_Type__c == null || rel.Project_Type__c == '') {
                    rel.Project_Type__c='New Release';
                }
            }
        }

    }
    
    /************************************
    Method Name: populateDealOnBIBU
    Purpose:method to populate deal on release
    *************************************/
    public static void populateDealOnBIBU(){
        if (TriggerUtility.initiatedFromDeal) {    // Changed for Deal
            return;
        }
        
        Set<Id> setDealId = new Set<Id>();
        Set<ID> setTitleID = new Set<ID>();
        Map<Id, Deal__c> dealTitleMap= new Map<Id, Deal__c>();
        Map<Id, Deal__c> dealMap= new Map<Id, Deal__c>();
        Set<String> originCodeSet = new Set<String>();
        Map<String, Origin_Code__c> ocMap = new Map<String, Origin_Code__c>();
        
        for(Release__c rel : (List<Release__c>)Trigger.New){
            if (rel.Title__c != null && !setTitleID.contains(rel.Title__c)) {
                setTitleID.add(rel.Title__c);
            }
            if (rel.Deal__c != null) {
                setDealId.add(rel.Deal__c);
            }
        }
        
        // Fetching deal from title.
        if(!setTitleID.isEmpty()){
            for(Deal__c eachDeal : [SELECT Id, Origin_Code__c, Title__c, Label_Code__c, Deal_ID__c FROM Deal__c WHERE Title__c In :setTitleID AND Finance_Default_Deal__c=true]){ //USST-2728
                dealTitleMap.put(eachDeal.Title__c, eachDeal);
                if (eachDeal.Origin_Code__c != null) {    // Changed for Deal
                    originCodeSet.add(eachDeal.Origin_Code__c);
                }
            }
        }
        
        // Fetching Deal details. Changed for deal 
        if (setDealId.size() > 0) {
            for(Deal__c eachDeal : [SELECT Id, Origin_Code__c, Title__c, Label_Code__c 
                                    FROM Deal__c WHERE Id IN: setDealId]) {
                dealMap.put(eachDeal.Id, eachDeal);
                if (eachDeal.Origin_Code__c != null) {
                    originCodeSet.add(eachDeal.Origin_Code__c);
                }
            }
        }
        
        // Fetching Origin Code details. Changed for Deal
        if (originCodeSet.size() > 0) {
            for (Origin_Code__c oc : [SELECT Label_Code__c, Sub_Label_Code__c, Origin_Code__c, Label_Code_2__c, Default_Deal_ID__c  
                                      FROM Origin_Code__c
                                      WHERE Origin_Code__c IN: originCodeSet]) { //USST-2728
                ocMap.put(oc.Origin_Code__c, oc);
            }
        }
        System.debug('*****ocMap> '+ocMap); 
        
        for(Release__c eachRel : (List<Release__c>) Trigger.new) {
            if(eachRel.Deal__c == null && dealTitleMap.get(eachRel.Title__c) != null){
                if (dealTitleMap.get(eachRel.Title__c).Origin_Code__c == null) {    // Changed for Deal
                    eachRel.addError('This Deal\'s Origin Code is not valid in the system. Please reach out to IT to resolve.');
                }
                else {
                    eachRel.Deal__c = dealTitleMap.get(eachRel.Title__c).Id;
                    eachRel.Deal_ID__c = dealTitleMap.get(eachRel.Title__c).Deal_ID__c; //USST-2728
                    if(ocMap.containsKey(dealTitleMap.get(eachRel.Title__c).Origin_Code__c)) {
                        //USST-2728 --- start
                        if (ocMap.get(dealTitleMap.get(eachRel.Title__c).Origin_Code__c).Default_Deal_ID__c != null && ocMap.get(dealTitleMap.get(eachRel.Title__c).Origin_Code__c).Default_Deal_ID__c != '' && ocMap.get(dealTitleMap.get(eachRel.Title__c).Origin_Code__c).Default_Deal_ID__c == eachRel.Deal_ID__c) {
                            eachRel.Label_Code__c = ocMap.get(dealTitleMap.get(eachRel.Title__c).Origin_Code__c).Label_Code_2__c;
                        }
                        else {
                            eachRel.Label_Code__c = ocMap.get(dealTitleMap.get(eachRel.Title__c).Origin_Code__c).Label_Code__c;
                        }
                        //USST-2728 --- end
                    }
                }
            }
            // Changed for Deal
            else if(eachRel.Deal__c != null && dealMap.containsKey(eachRel.Deal__c)) {
                if (dealMap.get(eachRel.Deal__c).Origin_Code__c == null) {
                    eachRel.addError('This Deal\'s Origin Code is not valid in the system. Please reach out to IT to resolve.');
                }
                else if (ocMap.get(dealMap.get(eachRel.Deal__c).Origin_Code__c).Label_Code__c != null) {
                    //USST-2728 --- start
                    if (ocMap.get(dealMap.get(eachRel.Deal__c).Origin_Code__c).Default_Deal_ID__c != null && ocMap.get(dealMap.get(eachRel.Deal__c).Origin_Code__c).Default_Deal_ID__c != '' && ocMap.get(dealMap.get(eachRel.Deal__c).Origin_Code__c).Default_Deal_ID__c == eachRel.Deal_ID__c) {
                        eachRel.Label_Code__c = ocMap.get(dealMap.get(eachRel.Deal__c).Origin_Code__c).Label_Code_2__c;
                    }
                    else {
                        eachRel.Label_Code__c = ocMap.get(dealMap.get(eachRel.Deal__c).Origin_Code__c).Label_Code__c;
                    }
                    //USST-2728 --- end
                }
            }   
        }   
    }

    /***************************************************
    Method Name: calculateKeyDatesonRelease
    Purpose:to set date fields on release
    ****************************************************/
    public static void calculateKeyDatesonRelease(List<Release__c> lstRelease){
        for(Release__c rel : lstRelease){
            // Changed for RE-60
            if(SyncRelease__c.getInstance('Release_Sync')!=null && SyncRelease__c.getInstance('Release_Sync').Sync_Release__c && rel.Sync_Dates__c && rel.Territory__c == 'CDN')
                continue;
            
            if(trigger.isBefore){
                if(trigger.isInsert){
                    if(rel.Street_Date__c != null){
                        rel.Pre_Order_Close_Date__c = rel.Street_Date__c - 42;
                        rel.Internal_Announce_Date__c = rel.Street_Date__c - 91;
                        rel.Trade_Solicitation_Date__c = rel.Street_Date__c - 84;
                        rel.In_Plant_Date__c = rel.Street_Date__c - 63;
                        if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV'){
                            rel.Windowed_Rental_Street_Date__c = rel.Street_Date__c + 28;
                            rel.Windowed_Rental_Pre_Order_Close_Date__c = rel.Street_Date__c - 14;
                            rel.VOD_Street_Date__c = rel.Street_Date__c;
                        }
                        rel.Original_Release_Date__c = rel.Street_Date__c;
                        if(rel.brand_group__c!=null && (rel.brand_group__c=='Universal Pictures'||rel.brand_group__c=='Partners')){
                            rel.Online_Consumer_Solicitation_Date__c=rel.Street_Date__c-63;
                        }else if(rel.brand_group__c!=null && (rel.brand_group__c=='Family'||rel.brand_group__c=='1440'||rel.brand_group__c=='Catalog'||rel.brand_group__c=='TV')){
                            rel.Online_Consumer_Solicitation_Date__c=rel.Street_Date__c-84;
                        }
                        //USST-2972 --- start
                        else if (rel.brand_group__c!=null && rel.brand_group__c == 'Content Group') {
                            if (rel.First_Theatrical_Date__c != null) {
                                rel.Online_Consumer_Solicitation_Date__c=rel.First_Theatrical_Date__c + 3;
                                if (rel.Territory__c == 'US') {
                                    rel.VOD_Street_Date__c = rel.First_Theatrical_Date__c;
                                    rel.EST_Date__c = rel.First_Theatrical_Date__c;
                                }
                                else {
                                    rel.VOD_Street_Date__c = rel.Street_Date__c;
                                    rel.EST_Date__c = rel.Street_Date__c;
                                }
                            }
                            else {
                                rel.Online_Consumer_Solicitation_Date__c=rel.Street_Date__c - 81;
                                rel.VOD_Street_Date__c = rel.Street_Date__c;
                                rel.EST_Date__c = rel.Street_Date__c;
                            }
                            rel.Windowed_Rental_Street_Date__c = null;
                            rel.Windowed_Rental_Pre_Order_Close_Date__c = null;
                        }
                        //USST-2972 --- end
                    } 
                }
                if(trigger.isUpdate){
                    if((rel.Street_Date__c != null && (rel.Street_Date__c !=  ((Release__c)Trigger.OldMap.get(rel.id)).Street_Date__c)) || rel.brand_group__c!=((Release__c)Trigger.OldMap.get(rel.id)).brand_group__c){
                        rel.Pre_Order_Close_Date__c = rel.Street_Date__c - 42;
                        rel.Internal_Announce_Date__c = rel.Street_Date__c - 91;
                        rel.Trade_Solicitation_Date__c = rel.Street_Date__c - 84;
                        rel.In_Plant_Date__c = rel.Street_Date__c - 63;
                        if(rel.Brand_Group__c!='Catalog' && rel.Brand_Group__c!='TV'){
                            rel.Windowed_Rental_Street_Date__c = rel.Street_Date__c + 28;
                            rel.Windowed_Rental_Pre_Order_Close_Date__c = rel.Street_Date__c - 14;
                            rel.VOD_Street_Date__c = rel.Street_Date__c;
                        }
                        if(((Release__c)Trigger.OldMap.get(rel.id)).Street_Date__c >= Date.Today())
                            rel.Original_Release_Date__c = rel.Street_Date__c;
                        if(rel.brand_group__c!=null && (rel.brand_group__c=='Universal Pictures'||rel.brand_group__c=='Partners')){ //commented brand group condition for USST-2545
                            rel.Online_Consumer_Solicitation_Date__c=rel.Street_Date__c-63;
                        }else if(rel.brand_group__c!=null && (rel.brand_group__c=='Family'||rel.brand_group__c=='1440'||rel.brand_group__c=='Catalog'||rel.brand_group__c=='TV')){ //commented brand group condition for USST-2545
                            rel.Online_Consumer_Solicitation_Date__c=rel.Street_Date__c-84;
                        }
                        //USST-2972 --- start
                        else if (rel.brand_group__c!=null && rel.brand_group__c == 'Content Group') {
                            if (rel.First_Theatrical_Date__c != null) {
                                rel.Online_Consumer_Solicitation_Date__c=rel.First_Theatrical_Date__c + 3;
                                if (rel.Territory__c == 'US') {
                                    rel.VOD_Street_Date__c = rel.First_Theatrical_Date__c;
                                    rel.EST_Date__c = rel.First_Theatrical_Date__c;
                                }
                                else {
                                    rel.VOD_Street_Date__c = rel.Street_Date__c;
                                    rel.EST_Date__c = rel.Street_Date__c;
                                }
                            }
                            else {
                                rel.Online_Consumer_Solicitation_Date__c=rel.Street_Date__c - 81;
                                rel.VOD_Street_Date__c = rel.Street_Date__c;
                                rel.EST_Date__c = rel.Street_Date__c;
                            }
                            rel.Windowed_Rental_Street_Date__c = null;
                            rel.Windowed_Rental_Pre_Order_Close_Date__c = null;
                        }
                        //USST-2972 --- end
                    }
                    //USST-2972 --- start
                    if(rel.First_Theatrical_Date__c !=  ((Release__c)Trigger.OldMap.get(rel.id)).First_Theatrical_Date__c && rel.brand_group__c == 'Content Group'){
                        if (rel.First_Theatrical_Date__c != null) {
                            rel.Online_Consumer_Solicitation_Date__c=rel.First_Theatrical_Date__c + 3;
                            if (rel.Territory__c == 'US') {
                                rel.VOD_Street_Date__c = rel.First_Theatrical_Date__c;
                                rel.EST_Date__c = rel.First_Theatrical_Date__c;
                            }
                            else {
                                rel.VOD_Street_Date__c = rel.Street_Date__c;
                                rel.EST_Date__c = rel.Street_Date__c;
                            }
                        }
                        else if (rel.Street_Date__c != null) {
                            rel.Online_Consumer_Solicitation_Date__c=rel.Street_Date__c - 81;
                            rel.VOD_Street_Date__c = rel.Street_Date__c;
                            rel.EST_Date__c = rel.Street_Date__c;
                        }
                        rel.Windowed_Rental_Street_Date__c = null;
                        rel.Windowed_Rental_Pre_Order_Close_Date__c = null;
                    }
                    //USST-2972 --- end
                }
            }

        }

    }  

    /***************************************************
    Method Name: createSalesClone
    Purpose:to create clone of sales record
    ****************************************************/
    public static void createSalesClone(){
        
        String qry='Select '+ getFieldsSOQL('Sales__c')+' from Sales__c where material__c in:materialIdSetExisting';
        System.debug('##createSalesClone '+getFieldsSOQL('Sales__c'));
        System.debug('updatesales'+qry);
        for(Sales__c sales:Database.query(qry)){
            if((materialUpdateMap.containsKey(sales.material__c)) || test.isRunningTest()){
                Sales__c salesClone=sales.clone(false,false,false,false);
                System.debug('##createSalesClone'+salesClone);
                salesClone.material__c=materialUpdateMap.get(sales.material__c).id;
                System.debug('##createSalesClone_Material'+materialUpdateMap.get(sales.material__c));
                salesClone.Function__c = '004';
                insertableSales.add(salesClone);
                System.debug('##insertableSales'+insertableSales);
            }
        }

    }

    /***************************************************
    Method Name: createPlantClone
    Purpose:to create clone of plant record
    ****************************************************/
    public static void createPlantClone(){
        List<String> validPlants = new List<String>{'V000 - Univ Studios HV Planning Plant', 'V300 - Technicolor - TN', 'V400 - Technicolor', 'V500 - Technicolor', 'V750 - TECHNICOLOR HES', 'V850 - Technicolor Canada'}; //USST-2738
        Map<ID, Set<String>> mapMatValidPlants = new Map<ID, Set<String>> (); //USST-2793
        String qry='Select '+ getFieldsSOQL('Plant__c')+' from Plant__c where material__c in:materialIdSetExisting and Plant__c in:validPlants'; //USST-2738
        //USST-2793 --- start
        for (ID matId : matsToCreateUpdate) {
            mapMatValidPlants.put(matId, new Set<String>{'V000 - Univ Studios HV Planning Plant', 'V300 - Technicolor - TN', 'V400 - Technicolor', 'V500 - Technicolor', 'V750 - TECHNICOLOR HES', 'V850 - Technicolor Canada'});
        }
        //USST-2793 --- end
        for(Plant__c plant:Database.query(qry)){
            if (mapMatValidPlants.get(plant.material__c) != null && mapMatValidPlants.get(plant.material__c).contains(String.valueOf(plant.Plant__c))) { //USST-2793
                if((materialUpdateMap.containsKey(plant.material__c)) || test.isRunningTest()){
                    Plant__c plantClone=plant.clone(false,false,false,false);
                    plantClone.material__c=materialUpdateMap.get(plant.material__c).id;//changes for USST-2861
                    plantClone.Function__c = '004';
                    insertablePlant.add(plantClone);
                }
                mapMatValidPlants.get(plant.material__c).remove(String.valueOf(plant.Plant__c)); //USST-2793
            }
            
        }

    }

    /***************************************************
    Method Name: createClassificationClone
    Purpose:to create clone of classification record
    ****************************************************/
    public static void createClassificationClone(){
        String qry='Select '+ getFieldsSOQL('Classification__c')+' from Classification__c where material__c in:materialIdSetExisting';

        for(Classification__c cls:Database.query(qry)){
            if((materialUpdateMap.containsKey(cls.material__c)) || test.isRunningTest()){
                Classification__c clsClone=cls.clone(false,false,false,false);
                clsClone.material__c=materialUpdateMap.get(cls.material__c).id;//changes for USST-2861
                clsClone.Function__c = '004';
                insertableClassification.add(clsClone);
            }
        }

    }

    /***************************************************
    Method Name: createAltUnitMeasClone
    Purpose:to create clone of alternate unit of measure record
    ****************************************************/   
    public static void createAltUnitMeasClone(){
        String qry='Select '+getFieldsSOQL('Alternative_Unit_of_Measure__c')+' from Alternative_Unit_of_Measure__c where material__c in:materialIdSetExisting';

        for(Alternative_Unit_of_Measure__c auom : Database.query(qry)){
            if((materialUpdateMap.containsKey(auom.material__c)) || test.isRunningTest()){
                Alternative_Unit_of_Measure__c auomClone=auom.clone(false,false,false,false);
                auomClone.material__c=materialUpdateMap.get(auom.material__c).id;//changes for USST-2861
                auomClone.Function__c = '004';
                insertableAUoMs.add(auomClone);
            }
        }

    }
    
    /***************************************************
    Method Name: createValuationClone
    Purpose:to create clone of valuation record
    ****************************************************/
    public static void createValuationClone(){
        List<String> validValuations = new List<String> {'V000', 'V300', 'V400', 'V500', 'V750', 'V850'}; //USST-2738
        Map<ID, Set<String>> mapMatValidValuations = new Map<ID, Set<String>> (); //USST-2793
        String qry='Select '+ getFieldsSOQL('Valuation__c')+' from Valuation__c where material__c in:materialIdSetExisting and Valuation_Area__c in:validValuations'; //USST-2738
        //USST-2793 --- start
        for (ID matId : matsToCreateUpdate) {
            mapMatValidValuations.put(matId, new Set<String>{'V000', 'V300', 'V400', 'V500', 'V750', 'V850'});
        }
        //USST-2793 --- end
        for(Valuation__c val:Database.query(qry)){
            if (mapMatValidValuations.get(val.material__c) != null && mapMatValidValuations.get(val.material__c).contains(String.valueOf(val.Valuation_Area__c))) { //USST-2793
                if((materialUpdateMap.containsKey(val.material__c)) || test.isRunningTest()){
                    Valuation__c valClone=val.clone(false,false,false,false);
                    valClone.material__c=materialUpdateMap.get(val.material__c).id;//changes for USST-2861
                    valClone.Function__c = '004';
                    insertableVals.add(valClone);
                }
                mapMatValidValuations.get(val.material__c).remove(String.valueOf(val.Valuation_Area__c)); //USST-2793
            }
        }

    }

    /***************************************************
    Method Name: getFieldsSOQL
    Purpose:to get all creatable fields
    ****************************************************/
    public static string getFieldsSOQL(String objectName){

        String selects = '';

        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();      
        list<string> selectFields = new list<string>();

        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isAccessible() && fd.getName() != 'Material_Description_Unique__c' && fd.getName() != 'Id' && fd.getName()!='OwnerId'){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }

        }

        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){
                selects = selects.substring(0,selects.lastIndexOf(','));
            }            
        }

        if(selects == null || selects == ''){
        selects = 'id';
        }

        return selects;        
    }  
    
    
    
    /***************************************************
    Method Name: cancelRelease
    Purpose:Checks for Materials on Cancelling a Release
    ****************************************************/

    public static void cancelRelease(List<Release__c> lstRelease){
        Map<Id, List<Material__c>> relMatMap = new Map<Id, List<Material__c>>();
        Map<Id, Map<Id, Id>> relMatIdMap = new Map<Id, Map<Id, Id>>();
        Map<Id, Set<Id>> matRelIdMap = new Map<Id, Set<Id>>();
        Map<Id, v_Material__c> matVMatMap = new Map<Id, v_Material__c>();
        Set<Id> orginalMatIds = new Set<Id>();
        Map<Id, Material__c> originalUpdatedMatMap = new Map<Id, Material__c>();
        List<Material__c> deleteMaterialsList = new List<Material__c>();
        set<Material__c> deleteMaterialsset = new set<Material__c>(); // Added for USST-2841
        List<Release_Material__c> deleteRelMatList = new List<Release_Material__c>();
        set<Release_Material__c> deleteRelMatset = new set<Release_Material__c>(); // Added for USST-2841
        for(Release_Material__c relMat : [Select Id, Release__c, Material__c, Material__r.Material_Status__c 
                                          from Release_Material__c where Release__c IN: lstRelease])
        {
            if(!relMatMap.containsKey(relMat.Release__c))
            {
                relMatMap.put(relMat.Release__c, new List<Material__c>());
                relMatIdMap.put(relMat.Release__c, new Map<Id, Id>());
            }
            Material__c mat = new Material__c(Id=relMat.Material__c, Material_Status__c=relMat.Material__r.Material_Status__c);
            relMatMap.get(relMat.Release__c).add(mat);
            relMatIdMap.get(relMat.Release__c).put(mat.Id, relMat.Id);
            orginalMatIds.add(mat.Id);
        }
        if(orginalMatIds.size() > 0)
        {
            //added for RE-35
            for(Release_Material__c mat : [SELECT Id, Material__c,Release__c FROM Release_Material__c
                                           WHERE Material__c IN: orginalMatIds])
            {
                if(!matRelIdMap.containsKey(mat.material__c)){
                    matRelIdMap.put(mat.material__c, new Set<Id>());
                }
                matRelIdMap.get(mat.material__c).add(mat.release__c);
            }
            
            for(Material__c mat : [SELECT Id, Original_Material_Number__c, Deletion_Flag__c, Material_Status__c
                                   FROM Material__c 
                                   WHERE Original_Material_Number__c IN: orginalMatIds AND Deletion_Flag__c=true AND Material_Status__c='Submitted'
                                   ORDER BY CreatedDate Asc])
            {
                originalUpdatedMatMap.put(mat.Original_Material_Number__c, mat);
            }
        }
        List<v_Material__c> updateableVMats = new List<v_Material__c>();
        List<Release__c> relList = new List<Release__c>();
        List<Release__c> lstRelToUpdate = new List<Release__c>(); //DFOR-1528
        for(Release__c rel : lstRelease){
            Release__c newRel = new Release__c (Id=rel.id); //DFOR-1528
            if(rel.Cancel_Release__c == true){
                if(relMatMap.containsKey(rel.Id)){
                    Integer deletedMatCount = 0;
                    for(Material__c mat : relMatMap.get(rel.Id)){
                        //updated condition for RE-35
                        if(matRelIdMap.get(mat.Id) != null && matRelIdMap.get(mat.Id).size() == 1 && 
                           (mat.Material_Status__c == 'Draft' || mat.Material_Status__c == 'Sent Back' || mat.Material_Status__c == 'Submitted')){ 
                            if(relMatIdMap.get(rel.Id) != null && relMatIdMap.get(rel.Id).get(mat.Id) != null){
                                deleteRelMatList.add(new Release_Material__c(Id=relMatIdMap.get(rel.Id).get(mat.Id)));
                            }   
                            deleteMaterialsList.add(mat);
                        }
                        //updated condition for RE-35
                        else if(matRelIdMap.get(mat.Id) != null && matRelIdMap.get(mat.Id).size() > 1 && 
                                (mat.Material_Status__c == 'Draft' || mat.Material_Status__c == 'Sent Back' || mat.Material_Status__c == 'Submitted')){
                            if(relMatIdMap.get(rel.Id) != null && relMatIdMap.get(rel.Id).get(mat.Id) != null){
                                deleteRelMatList.add(new Release_Material__c(Id=relMatIdMap.get(rel.Id).get(mat.Id)));
                            }
                        }
                        if(mat.Material_Status__c == 'Processed in SAP' || mat.Material_Status__c == 'Approved'){
                            deleteRelMatList.add(new Release_Material__c(Id=relMatIdMap.get(rel.Id).get(mat.Id)));
                        }
                        if(mat.Material_Status__c == 'Deleted' || originalUpdatedMatMap.containsKey(mat.Id)){
                            deletedMatCount ++;
                        }
                    }

                    // If all the materials under release are deleted, cancel release.
                    if(relMatMap.get(rel.Id) != null)
                    {
                        newRel.Master_Schedule_Indicator__c = 'EXCLUDE'; //DFOR-1528
                        newRel.Pretty_Indicator__c = 'EXCLUDE'; //DFOR-1528
                        newRel.release_status__c = 'Cancelled'; //DFOR-1528
                    }
                }
                else if(!relMatMap.containsKey(rel.Id)){
                    newRel.Master_Schedule_Indicator__c = 'EXCLUDE'; //DFOR-1528
                    newRel.Pretty_Indicator__c = 'EXCLUDE'; //DFOR-1528
                    newRel.release_status__c = 'Cancelled'; //DFOR-1528
                } 
                
                //DFOR-1494 - cancel Sync to DF
                if(newRel.release_status__c == 'Cancelled'){ //DFOR-1528
                    newRel.Digital__c = false; //DFOR-1528
                }
                lstRelToUpdate.add(newRel); //DFOR-1528
            }
        }
        if (lstRelToUpdate.size()> 0) { 
            update lstRelToUpdate; //DFOR-1528
        }
        //added for RE-35
        if(deleteRelMatList.size() >0){
          deleteRelMatset.addAll(deleteRelMatList); // Added for USST-2841
          deleteRelMatList.clear();// Added for USST-2841
          deleteRelMatList.addAll(deleteRelMatset);// Added for USST-2841
          delete deleteRelMatList;
        }
        //added for RE-35
        if(deleteMaterialsList.size() > 0){
          deleteMaterialsset.addAll(deleteMaterialsList);// Added for USST-2841
          deleteMaterialsList.clear();// Added for USST-2841
          deleteMaterialsList.addAll(deleteMaterialsset);// Added for USST-2841
          delete deleteMaterialsList;
        }
    }   

   /***************************************************
    Method Name: createChildViews
    Purpose:code to create child views for udpate material
    ****************************************************/
    public static void createChildViews(){
        if(checkChildView){
            return;
        }
        checkChildView =true;
        createSalesClone();
        createValuationClone();
        createAltUnitMeasClone();
        createClassificationClone();
        createPlantClone();
        checkChildView =false; //USST-2799
    }
    
    /************************************
    Method Name: updateMaterialDate
    Purpose: to update date fields on material object
    *************************************/ 
    public static void updateMaterialDate(Set<Id> releaseId){
        List<Release__c> releaseLst = new List<Release__c>();
        Map<Id, Map<Id, Material__c>> relMatListToUpdate = new Map<Id, Map<Id, Material__c>>();
        Map<Id, Map<String, Material__c>> relMatListToSubmit= new Map<Id, Map<String,Material__c>>();
        Map<Id, Map<String, Material__c>> relMatListToApprove= new Map<Id, Map<String,Material__c>>();
        Map<Id, Material__c> matListToUpdate = new Map<Id, Material__c>();
        Map<String, Material__c> matListToSubmit= new Map<String,Material__c>();
        Map<String, Material__c> matListToApprove= new Map<String,Material__c>();
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        Set<Id> materialIdSet=new Set<Id>();
        TriggerUtility.checkFromUpdateMaterial = TRUE;
        Map<id,List<Material__c>>updateMatMap=new Map<id,List<Material__c>>();
        List<Material__c>updatetoApprove=new List<Material__c>();
        Set<Id>toUpdateIds=new Set<Id>();
        Map<String,Set<Id>>materialMap= new Map<String,Set<Id>>();
        Set<Id>updateMatList=new Set<Id>();
        List<Material__c> chatterFeedLstMat = new List<Material__c>(); //USST-2547

        String allFields=getFieldsSOQL('Material__c');
        String queryReleaseDetails='Select id,name, Street_Date__c,First_Theatrical_Date__c,Windowed_Rental_Pre_Order_Close_Date__c,Windowed_Rental_Street_Date__c,Label_Code__c,'+
        'VOD_Street_Date__c,Internal_Announce_Date__c,Trade_Solicitation_Date__c,In_Plant_Date__c,Pre_Order_Close_Date__c,EST_Date__c,(Select '+allFields+' from Materials__r)'+
        ' from Release__c where id In:releaseId';    

        releaseLst=Database.Query(queryReleaseDetails);

        for(Release__c rel : releaseLst){
            
            if((rel.street_date__c != null && rel.street_date__c != ((Release__c)trigger.oldMap.get(rel.id)).street_date__c) || 
                (rel.Pre_Order_Close_Date__c != null && rel.Pre_Order_Close_Date__c != ((Release__c)trigger.oldMap.get(rel.id)).Pre_Order_Close_Date__c) ||
                (rel.Trade_Solicitation_Date__c != null && rel.Trade_Solicitation_Date__c != ((Release__c)trigger.oldMap.get(rel.id)).Trade_Solicitation_Date__c) ||
                (rel.Internal_Announce_Date__c != null && rel.Internal_Announce_Date__c != ((Release__c)trigger.oldMap.get(rel.id)).Internal_Announce_Date__c) ||
                (rel.First_Theatrical_Date__c != null && rel.First_Theatrical_Date__c != ((Release__c)trigger.oldMap.get(rel.id)).First_Theatrical_Date__c) || (test.isRunningTest())){
                
                allDateUpdate=true;
            }
            else {
                allDateUpdate=false;
            }

            for(Material__c mat : rel.Materials__r){
                
                //Releaseforce 2.0 RE-19  below logic assists to make updates depending on the date changes the associated materials will updated or Update materials will be created for the same
                if(allDateUpdate==true || test.isRunningTest()){
                    updateMatList.add(mat.id);
                }
                else if((rel.EST_Date__c!=null && rel.EST_Date__c!=((Release__c)trigger.oldMap.get(rel.id)).EST_Date__c) 
                            && (mat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || mat.Format__c == '14 - HD EST') && allDateUpdate==false)
                {
                    updateMatList.add(mat.id);
                }
                else if((((rel.Windowed_Rental_Street_Date__c!=null && rel.Windowed_Rental_Street_Date__c!=((Release__c)trigger.oldMap.get(rel.id)).Windowed_Rental_Street_Date__c)
                        ||(rel.Windowed_Rental_Pre_Order_Close_Date__c!=null && rel.Windowed_Rental_Pre_Order_Close_Date__c!=((Release__c)trigger.oldMap.get(rel.id)).Windowed_Rental_Pre_Order_Close_Date__c)) && 
                        (mat.Retailer_Rental__c == '28R (28-DAY WINDOW RENTAL)' || mat.Retailer_Rental__c == 'XXR (WINDOWED RENTAL)') && allDateUpdate==false) || test.isRunningTest()){
                        updateMatList.add(mat.id);
                }
                if(mat.material_status__c!='Draft' && mat.material_status__c!='Submitted' && mat.recordTypeId!=recTypeId && mat.material_type__c!='ROH'&& mat.material_type__c!='Z009'){
                    materialIdSetExisting.add(mat.id);
                }
            }
        }         

        for(Material__c mat:[select id,material_status__c,recordTypeId,Theatrical_Release_Date__c,Internal_Announce_Date__c,Trade_Solicitation_Date__c,Street_Date__c,Pre_Order_Close_Date__c,Original_Material_Number__c
        from material__c where Original_Material_Number__c in:materialIdSetExisting and recordTypeId =: recTypeId and material_status__c='Submitted']){
            if(updateMatMap.containskey(mat.Original_Material_Number__c)){
                updateMatMap.get(mat.Original_Material_Number__c).add(mat);
            }
            else{
                updateMatMap.put(mat.Original_Material_Number__c,new List<Material__c>{mat});
            }
        }         
        Map<Id, Boolean> relIssueMap = new Map<Id, Boolean>();
        for(Release__c rel : releaseLst){
            Boolean hasMaterialWithNoMatNumber = false;
            Boolean hasMaterialWithnonFR = false;
            for(Material__c mat : rel.Materials__r){
                //For materials in Draft status
                if(hasMaterialWithNoMatNumber)
                    continue;
                
                if((mat.material_status__c=='Draft' || mat.material_status__c=='Submitted' || mat.material_status__c=='Sent Back') && mat.recordTypeId!=recTypeId &&  (!updateMatList.isEmpty() && updateMatList.contains(mat.id))){ //Added sent back for USST-2664
                    if(rel.First_Theatrical_Date__c != null){
                        mat.Theatrical_Release_Date__c = rel.First_Theatrical_Date__c;
                    }
                    if(rel.Internal_Announce_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                        mat.Internal_Announce_Date__c = rel.Internal_Announce_Date__c;
                    }
                    if(rel.Trade_Solicitation_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                        mat.Trade_Solicitation_Date__c = rel.Trade_Solicitation_Date__c;
                    }
                    system.debug('inside retailer rental' +mat.Retailer_Rental__c);
                    if(mat.Retailer_Rental__c == '28R (28-DAY WINDOW RENTAL)' || mat.Retailer_Rental__c == 'XXR (WINDOWED RENTAL)'){
                        if(rel.Windowed_Rental_Street_Date__c != null && rel.Windowed_Rental_Street_Date__c != ((Release__c)trigger.oldMap.get(rel.id)).Windowed_Rental_Street_Date__c && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                            mat.Street_Date__c = rel.Windowed_Rental_Street_Date__c;
                            mat.Original_Release_Date__c = rel.Street_Date__c; // USST-2436
                        }
                        if(rel.Windowed_Rental_Pre_Order_Close_Date__c != null && rel.Windowed_Rental_Pre_Order_Close_Date__c != ((Release__c)trigger.oldMap.get(rel.id)).Windowed_Rental_Pre_Order_Close_Date__c && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){ 
                            mat.Pre_Order_Close_Date__c = rel.Windowed_Rental_Pre_Order_Close_Date__c;
                        }
                        else{
                            if(rel.Windowed_Rental_Street_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                                mat.Street_Date__c = rel.Windowed_Rental_Street_Date__c;
                            }
                            else if(rel.Street_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                                mat.Street_Date__c = rel.Street_Date__c;
                            }
                            if(rel.Windowed_Rental_Pre_Order_Close_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                                mat.Pre_Order_Close_Date__c = rel.Windowed_Rental_Pre_Order_Close_Date__c;
                            }
                            else if(rel.Pre_Order_Close_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                                mat.Pre_Order_Close_Date__c = rel.Pre_Order_Close_Date__c;
                            }
                        }
                    }
                    else if(mat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || mat.Format__c == '14 - HD EST' ){
                        if(rel.EST_Date__c != null /*&& rel.EST_Date__c != ((Release__c)trigger.oldMap.get(rel.id)).EST_Date__c*/ && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){ //USST-3032
                            mat.Street_Date__c = rel.EST_Date__c;
                            if (rel.EST_Date__c != ((Release__c)trigger.oldMap.get(rel.id)).EST_Date__c) //USST-3038
                                mat.Original_Release_Date__c = rel.Street_Date__c;
                        }
                        else if(rel.Street_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                            mat.Street_Date__c = rel.Street_Date__c;
                        }
                        else{
                            mat.Street_Date__c = null;
                        }
                    }
                    else{
                        if(rel.Street_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                            mat.Street_Date__c = rel.Street_Date__c;
                        }
                        if(rel.Pre_Order_Close_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                            mat.Pre_Order_Close_Date__c = rel.Pre_Order_Close_Date__c;
                        }
                    }
                    if(!relMatListToUpdate.containsKey(rel.Id))
                        relMatListToUpdate.put(rel.Id, new Map<Id, Material__c>());
                    relMatListToUpdate.get(rel.Id).put(mat.id, mat);
                }
                else if(mat.material_status__c!='Draft' && mat.material_status__c!='Submitted' && mat.material_status__c!='Sent Back' && mat.material_status__c!='Deleted' && mat.material_status__c!='Sent Back' && mat.recordTypeId!=recTypeId && mat.Item_Code__c != 'BF - BABY FERT' && mat.material_type__c!='ROH'&& mat.material_type__c!='Z009' 
                        && (updateMatMap==null || updateMatMap!=null && !updateMatMap.containskey(mat.id) && (!updateMatList.isEmpty() && updateMatList.contains(mat.id)))){ //Added baby fert condition for USST-2554 //Added sent back for USST-2664
                    if(mat.Material_Number__c == null)
                    {
                        hasMaterialWithNoMatNumber = true;
                        continue;
                    }
                    
                    materialIdSetExisting.add(mat.id);
                    matsToCreateUpdate.add(mat.id); //USST-2793
                    Material__c matCopy = mat.clone(false,false,false,false);
                    matCopy.Original_Material_Number__c = mat.id;
                    matCopy.Date_Change_Update__c = true;
                    matCopy.release__c = rel.id;
                    matCopy.recordTypeId = recTypeId;
                    matCopy.ownerid=UserInfo.getUserId();
                    matCopy.send_direct_to_SAP__c=false;
                    matCopy.Record_Type_Filter__c='Update';
                     matCopy.Function__c = '004';
                     matCopy.Brand_Group__c = '';
                     matCopy.Sub_Label_Code_Lookup__c=mat.Sub_Label_Code_Lookup__c; //USST-2707

                    if(rel.First_Theatrical_Date__c != null){
                        matCopy.Theatrical_Release_Date__c = rel.First_Theatrical_Date__c;
                    }
                    if(rel.Internal_Announce_Date__c != null){
                        matCopy.Internal_Announce_Date__c = rel.Internal_Announce_Date__c;
                    }
                    if(rel.Trade_Solicitation_Date__c != null){
                        matCopy.Trade_Solicitation_Date__c = rel.Trade_Solicitation_Date__c;
                    }
                    if(matCopy.Retailer_Rental__c == '28R (28-DAY WINDOW RENTAL)' || matCopy.Retailer_Rental__c == 'XXR (WINDOWED RENTAL)'){ 
                        if(rel.Windowed_Rental_Street_Date__c != null && rel.Windowed_Rental_Street_Date__c != ((Release__c)trigger.oldMap.get(rel.id)).Windowed_Rental_Street_Date__c){
                            matCopy.Street_Date__c = rel.Windowed_Rental_Street_Date__c;
                        }
                        if(rel.Windowed_Rental_Pre_Order_Close_Date__c != null && rel.Windowed_Rental_Pre_Order_Close_Date__c != ((Release__c)trigger.oldMap.get(rel.id)).Windowed_Rental_Pre_Order_Close_Date__c){ 
                            matCopy.Pre_Order_Close_Date__c = rel.Windowed_Rental_Pre_Order_Close_Date__c;
                        }
                        else{
                            if(rel.Windowed_Rental_Street_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                                matCopy.Street_Date__c = rel.Windowed_Rental_Street_Date__c;
                            }
                            else if(rel.Street_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                                matCopy.Street_Date__c = rel.Street_Date__c;
                            }
                            if(rel.Windowed_Rental_Pre_Order_Close_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                                matCopy.Pre_Order_Close_Date__c = rel.Windowed_Rental_Pre_Order_Close_Date__c;
                            }
                            else if(rel.Pre_Order_Close_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                                 matCopy.Pre_Order_Close_Date__c = rel.Pre_Order_Close_Date__c;
                            }
                        }
                    }
                    else if(matCopy.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || matCopy.Format__c == '14 - HD EST' ){
                        if(rel.EST_Date__c != null /*&& rel.EST_Date__c != ((Release__c)trigger.oldMap.get(rel.id)).EST_Date__c*/){ //USST-3032
                            matCopy.Street_Date__c = rel.EST_Date__c;
                        }
                        else if(rel.Street_Date__c != null){
                            matCopy.Street_Date__c = rel.Street_Date__c;
                        }
                        else{
                            matCopy.Street_Date__c = null;
                        }
                    }
                    else{
                        if(rel.Street_Date__c != null){
                            matCopy.Street_Date__c = rel.Street_Date__c;
                        }
                        if(rel.Pre_Order_Close_Date__c != null){
                            matCopy.Pre_Order_Close_Date__c = rel.Pre_Order_Close_Date__c;
                        }
                    } //USST-2492
                    if(((Release__c)trigger.oldMap.get(rel.id)).Street_Date__c != null && ((Release__c)trigger.oldMap.get(rel.id)).Street_Date__c > Date.today() &&
                        rel.Street_Date__c > ((Release__c)trigger.oldMap.get(rel.id)).Street_Date__c )
                        {
                         matCopy.Original_Release_Date__c = rel.Street_Date__c;
                        } 
                    //If Internal Announce Date is less than today
                        
                    if((Date.TODAY() > rel.Internal_Announce_Date__c || rel.Internal_Announce_Date__c==Date.TODAY()) && (matCopy.Format__c != '08 - EST (ELECTRONIC SELL THRU)' && matCopy.Format__c != '14 - HD EST') && (matCopy.Item_Type__c!='D (Display Vehicle)')/*RE-27 D Type will always be auto_approved*/){
                        matCopy.material_status__c='Draft';
                        if(!relMatListToSubmit.containsKey(rel.Id) )
                            relMatListToSubmit.put(rel.Id, new Map<String, Material__c>());
                        if(!relMatListToSubmit.get(rel.Id).containsKey(matCopy.name)){                      
                            Material__c tempMat = matCopy;
                            relMatListToSubmit.get(rel.Id).put(tempMat.name,tempMat);
                        }
                    }
                    //If Internal Announce Date is greater than today

                    if(Date.TODAY() < rel.Internal_Announce_Date__c || matCopy.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || matCopy.Format__c == '14 - HD EST' || matCopy.Item_Type__c=='D (Display Vehicle)' /*RE-27 Auto Approve Dtype*/){
                        matCopy.material_status__c='Draft';
                        if(!relMatListToApprove.containsKey(rel.Id))
                            relMatListToApprove.put(rel.Id, new Map<String, Material__c>());
                        if(!relMatListToApprove.get(rel.Id).containsKey(matCopy.name)){
                            //USST-2828 - start
                            if (matCopy.Item_Type__c == 'D (Display Vehicle)' && matCopy.Territory__c == 'US & CDN') {
                                //do nothing
                            }
                            else {
                                Material__c tempMat = matCopy;
                                //System.debug('##tempMat'+tempMat);
                                relMatListToApprove.get(rel.Id).put(tempMat.name,tempMat);
                            }
                            //USST-2828 - end
                        }
                    }    
                }   
                else if(mat.material_status__c!='Draft' && mat.material_status__c!='Submitted' && mat.material_status__c!='Sent Back' && mat.material_status__c!='Deleted' && mat.recordTypeId!=recTypeId && mat.material_type__c!='ROH'&& mat.material_type__c!='Z009' 
                && updateMatMap!=null && updateMatMap.containskey(mat.id) && (!updateMatList.isEmpty() && updateMatList.contains(mat.id))){ //Added sent back for USST-2664

                    Material__c matUpdate=updateMatMap.get(mat.id)[0];
                    matUpdate.Execute_Validation_Rule__c=false;
                    if(rel.First_Theatrical_Date__c != null){
                        matUpdate.Theatrical_Release_Date__c = rel.First_Theatrical_Date__c;
                    }
                    if(rel.Internal_Announce_Date__c != null){
                        matUpdate.Internal_Announce_Date__c = rel.Internal_Announce_Date__c;
                    }
                    if(rel.Trade_Solicitation_Date__c != null){
                        matUpdate.Trade_Solicitation_Date__c = rel.Trade_Solicitation_Date__c;
                    }
                    if(mat.Retailer_Rental__c == '28R (28-DAY WINDOW RENTAL)' || mat.Retailer_Rental__c == 'XXR (WINDOWED RENTAL)') { 
                        if(rel.Windowed_Rental_Street_Date__c != null && rel.Windowed_Rental_Street_Date__c != ((Release__c)trigger.oldMap.get(rel.id)).            Windowed_Rental_Street_Date__c){
                            matUpdate.Street_Date__c = rel.Windowed_Rental_Street_Date__c;
                        }
                        if(rel.Windowed_Rental_Pre_Order_Close_Date__c != null && rel.Windowed_Rental_Pre_Order_Close_Date__c != ((Release__c)trigger.oldMap.get(rel.id)).Windowed_Rental_Pre_Order_Close_Date__c){ 
                            matUpdate.Pre_Order_Close_Date__c = rel.Windowed_Rental_Pre_Order_Close_Date__c;
                        }
                        else{
                            if(rel.Windowed_Rental_Street_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                                matUpdate.Street_Date__c = rel.Windowed_Rental_Street_Date__c;
                            }
                            else if(rel.Street_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                                matUpdate.Street_Date__c = rel.Street_Date__c;
                            }
                            if(rel.Windowed_Rental_Pre_Order_Close_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                                matUpdate.Pre_Order_Close_Date__c = rel.Windowed_Rental_Pre_Order_Close_Date__c;
                            }
                            else if(rel.Pre_Order_Close_Date__c != null && mat.Item_Code__c != 'BF - BABY FERT' && mat.Material_Type__c != 'ROH' && mat.Material_Type__c != 'Z009'){
                                matUpdate.Pre_Order_Close_Date__c = rel.Pre_Order_Close_Date__c;
                            }
                        }
                    }
                    else if(mat.Format__c == '08 - EST (ELECTRONIC SELL THRU)' || mat.Format__c == '14 - HD EST' ){
                        if(rel.EST_Date__c != null /*&& rel.EST_Date__c != ((Release__c)trigger.oldMap.get(rel.id)).EST_Date__c*/){ //USST-3032
                            matUpdate.Street_Date__c = rel.EST_Date__c;
                            if (rel.EST_Date__c != ((Release__c)trigger.oldMap.get(rel.id)).EST_Date__c) //USST-3038
                                matUpdate.Original_Release_Date__c = rel.Street_Date__c;
                        }
                        else if(rel.Street_Date__c != null){
                            matUpdate.Street_Date__c = rel.Street_Date__c;
                        }
                        else{
                            matUpdate.Street_Date__c = null;
                        }
                    }
                    else{
                        if(rel.Street_Date__c != null){
                            matUpdate.Street_Date__c = rel.Street_Date__c;
                        }
                        if(rel.Pre_Order_Close_Date__c != null){
                           matUpdate.Pre_Order_Close_Date__c = rel.Pre_Order_Close_Date__c;
                        }
                    }
                    if(!relMatListToUpdate.containsKey(rel.Id))
                        relMatListToUpdate.put(rel.Id, new Map<Id, Material__c>{matUpdate.id =>matUpdate});
                    else    
                        relMatListToUpdate.get(rel.Id).put(matUpdate.id,matUpdate);
                }

            }   
            
            relIssueMap.put(rel.Id, hasMaterialWithNoMatNumber);
            if(hasMaterialWithNoMatNumber)
                Trigger.newMap.get(rel.Id).addError('Edit cannot be saved because one or more Materials do not have Material Numbers in Release: '+rel.Name);
    
        }
        
        for(Id relId : relIssueMap.keySet())
        {
            if(!relIssueMap.get(relId))
            {
                if(relMatListToUpdate.get(relId) != null && relMatListToUpdate.get(relId).size() > 0)
                {
                    for(Id matId : relMatListToUpdate.get(relId).keySet())
                    {
                        
                        matListToUpdate.put(matId, relMatListToUpdate.get(relId).get(matId));
                    }
                }
                if(relMatListToApprove.get(relId) != null && relMatListToApprove.get(relId).size() > 0)
                {
                    for(String matNm : relMatListToApprove.get(relId).keySet())
                    {
                        matListToApprove.put(matNm, relMatListToApprove.get(relId).get(matNm));
                    }
                }
                if(relMatListToSubmit.get(relId) != null && relMatListToSubmit.get(relId).size() > 0)
                {
                    for(String matNm : relMatListToSubmit.get(relId).keySet())
                    {
                        matListToSubmit.put(matNm, relMatListToSubmit.get(relId).get(matNm));
                    }
                }
            }
        }
        
        if(matListToUpdate.size() > 0){
            for(Material__c m : matListToUpdate.values()){
            }
            Database.Update(matListToUpdate.values(),FALSE);
        } 
        if(matListToApprove.size() > 0){
            system.debug('##matListToApprove'+matListToApprove.values());
            Database.Insert(matListToApprove.values(),FALSE);
            for(Material__c matApprove:matListToApprove.values()){
                materialUpdateMap.put(matApprove.Original_Material_Number__c,matApprove);//changes for USST-2861
            }
             createChildViews();
             //USST-2799 --- start
             //insert child sales records
            if(!insertableSales.isEmpty()){
                system.debug('insertableSales'+insertableSales);
                globalSalesList.addAll(insertableSales); //USST-2861
                insertableSales.clear();
            }
            //insert child plant records
            if(!insertablePlant.isEmpty()){
                globalplantList.addAll(insertablePlant);//USST-2861
                insertablePlant.clear();
            }
            //insert child Classification records
            if(!insertableClassification.isEmpty()){
                globalclassificationList.addAll(insertableClassification);//USST-2861
                insertableClassification.clear();
            }
            //insert child Alternate Unit of Measure records
            if(!insertableAUoMs.isEmpty()){
                globalAUOMList.addAll(insertableAUoMs);//USST-2861
                insertableAUoMs.clear();
            }
            //insert child valuation records
            if(!insertableVals.isEmpty()){
                globalvaluationList.addAll(insertableVals);//USST-2861
                insertableVals.clear();
            }
            
            materialUpdateMap.clear();
             //USST-2799 --- end
        }  
        if(matListToSubmit.size() > 0){

            Database.Insert(matListToSubmit.values(),TRUE);

            for(Material__c matNew : matListToSubmit.values()){
                materialUpdateMap.put(matNew.Original_Material_Number__c,matNew);//changes for USST-2861
                }
            createChildViews();
            //USST-2799 --- start
            //insert child sales records
            if(!insertableSales.isEmpty()){
                system.debug('insertableSales'+insertableSales);
                globalSalesList.addAll(insertableSales); //USST-2861
                insertableSales.clear();
            }
            
            //insert child plant records
            if(!insertablePlant.isEmpty()){
                globalplantList.addAll(insertablePlant);//USST-2861
                insertablePlant.clear();
            }
            
                
            //insert child Classification records
            if(!insertableClassification.isEmpty()){
                globalclassificationList.addAll(insertableClassification);//USST-2861
                insertableClassification.clear();
            }
            
            if (!globalclassificationList.isEmpty())    //USST-2861
                database.upsert(globalclassificationList,true);  //USST-2861
                
            //insert child Alternate Unit of Measure records
            if(!insertableAUoMs.isEmpty()){
                globalAUOMList.addAll(insertableAUoMs);//USST-2861
                insertableAUoMs.clear();
            }
            
                
            //insert child valuation records
            if(!insertableVals.isEmpty()){
                globalvaluationList.addAll(insertableVals);//USST-2861
                insertableVals.clear();
            }
            
                
            
            materialUpdateMap.clear();
            //USST-2799 --- end
        }
        if (!globalSalesList.isEmpty()) //USST-2861
                database.upsert(globalSalesList,true); //USST-2861
        if (!globalplantList.isEmpty())    //USST-2861
                database.upsert(globalplantList,true);  //USST-2861
        if (!globalclassificationList.isEmpty())    //USST-2861
                database.upsert(globalclassificationList,true);  //USST-2861
        if (!globalAUOMList.isEmpty())    //USST-2861
                database.upsert(globalAUOMList,true);  //USST-2861
        if (!globalvaluationList.isEmpty())    //USST-2861
                database.upsert(globalvaluationList,true);  //USST-2861
        if(matToUpdateList.size() >0){
            update matToUpdateList;
        }
        

        //USST-2547---start
        if(matListToSubmit.size() > 0) {
            sendChatterFeedOnUpdateRequests(matListToSubmit.values());  
        }
        //USST-2547---end
        
        Set<Id> unlockMatIds = new Set<Id>();    // Added for RE-60
       for(Material__c matNew : matListToSubmit.values()){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(matNew.id);
            req1.setProcessDefinitionNameOrId('Material_Approval_Process_w_o_hierarchy3');
            req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);
            // Added for RE-60
            unlockMatIds.add(matNew.id);
        }
        // Added for RE-60
        if(unlockMatIds.size() > 0 && !TriggerUtility.checkFromQueueable)
        {
            AsyncMaterialUnlock matUnlockJob = new AsyncMaterialUnlock();
            matUnlockJob.materialIds = unlockMatIds;
            
        }
           
        for(Material__c matNew : matListToApprove.values()){
            matNew.Material_status__c='Approved';
            matNew.Material_Integration_State__c='N';
            updatetoApprove.add(matNew);
        }
         if(!updatetoApprove.isEmpty()){
            update updatetoApprove;
        }      
        
    } 
    
     //ReleaseForce2.0 RE-50--- Update contact information from Release in case of udpate.
    public static void udpateContactsToMaterial(Set<Id>releaseId){
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId(); //USST-2610
        List<Material__c> updateMatList=new List<Material__c>();
        Set<Id> matIds=new Set<Id>();
               
        if(!releaseId.isEmpty()){   
        
            for(Material__c mat: [Select Creative_Contact__c,Manufacturing_Contact__c,Marketing_Contact__c,Master_Data_Contact__c,Tech_Ops_Contact__c,Publicity_Contact__c,
                                        release__r.Creative_Contact__c,release__r.Manufacturing_Contact__c,release__r.Marketing_Contact__c,release__r.Master_Data_Contact__c,
                                        release__r.Tech_Ops_Contact__c,release__r.Publicity_Contact__c from Material__c where release__c in:releaseId AND (recordtypeid!=:recTypeId )]){ //Added recordtype condition for USST-2610 //USST-3239
                                            
                        mat.Creative_Contact__c=mat.release__r.Creative_Contact__c;
                        mat.Manufacturing_Contact__c=mat.release__r.Manufacturing_Contact__c;       
                        mat.Marketing_Contact__c = mat.release__r.Marketing_Contact__c;
                        mat.Master_Data_Contact__c=mat.release__r.Master_Data_Contact__c;
                        mat.Tech_Ops_Contact__c=mat.release__r.Tech_Ops_Contact__c;
                        mat.Publicity_Contact__c=mat.release__r.Publicity_Contact__c; //USST-3239
                        updateMatList.add(mat);
            }
        }
        if(!updateMatList.isEmpty()){
            update updateMatList;
        }
    }
    
    // Following method synchronizes the release dates from Release Sync. Added for RE-60
    public static void syncReleaseDates()
    {
        // If org wide settings does not support release sync, it returns.
        if(SyncRelease__c.getInstance('Release_Sync')!=null && !SyncRelease__c.getInstance('Release_Sync').Sync_Release__c)
            return;
            
        Set<Id> sourceReleaseIds = new Set<Id>();
        Set<Id> relId = new Set<Id>();
        Set<Integer> activeUpdateReleases = new Set<Integer>(); // If update is happening, it collects all the release ids need to be changed. (to reduce condition evaluation again)
        
        // Fetching child releases for context releases.
        List<Release__c> childUpdateableRelList = new List<Release__c>();
        List<Release__c> updateSyncReleases = new List<Release__c>();
        Map<Id, Release__c> releaseChildMap;
        if(Trigger.isUpdate)
            releaseChildMap = new Map<Id, Release__c>([SELECT Id, (SELECT Id FROM Sync_Releases__r WHERE Sync_Dates__c=TRUE) 
                                                       FROM Release__c WHERE Id IN: Trigger.newMap.keySet()]);
        
        for(Release__c rel : (List<Release__c>) Trigger.New)
        {
            Release__c oldRel;
            if(Trigger.isUpdate)
                oldRel = (Release__c) Trigger.oldMap.get(rel.Id);
            
            // If a new parent association is happening for synchronization of Dates.
            if(((Trigger.isBefore && Trigger.isInsert) || 
                (Trigger.isBefore && Trigger.isUpdate && (rel.Sync_Dates__c != oldRel.Sync_Dates__c || rel.Release_Sync__c != oldRel.Release_Sync__c))) && // On update if any of the mensioned field getting changed
               rel.Sync_Dates__c && rel.Release_Sync__c != null)
            {
                if(rel.Territory__c == 'CDN')    // modified RE-60
                {
                    sourceReleaseIds.add(rel.Release_Sync__c);
                    activeUpdateReleases.add(System.hashCode(rel));
                }
            }
            // modified RE-60
            // If one of the sync field is updated, other one will be changed to null. OR if release is cancelled, make sync fields empty.
            else if(Trigger.isBefore && Trigger.isUpdate && (((rel.Sync_Dates__c != oldRel.Sync_Dates__c && !rel.Sync_Dates__c) ||
                    (rel.Release_Sync__c != oldRel.Release_Sync__c && rel.Release_Sync__c == null)) || (oldRel.Cancel_Release__c != rel.Cancel_Release__c && rel.Cancel_Release__c)))
            {
                rel.Sync_Dates__c = FALSE;
                rel.Release_Sync__c = null;
            }
            // modified RE-60
            // Once any release sync field updated with new release, it should update other side too.
            else if(((Trigger.isAfter && Trigger.isInsert) || 
                     (Trigger.isAfter && Trigger.isUpdate && (rel.Sync_Dates__c != oldRel.Sync_Dates__c || rel.Release_Sync__c != oldRel.Release_Sync__c))) && // On update if any of the mensioned field getting changed
                    rel.Sync_Dates__c && rel.Release_Sync__c != null)
            {
                // If update happens in CDN release, the sync fields should be changed in child.
                if(rel.Territory__c == 'CDN')
                {
                    updateSyncReleases.add(new Release__c(Id=rel.Release_Sync__c, Release_Sync__c=rel.Id, Sync_Dates__c=TRUE));
                }
                // If update happens in US release, the dates get changed in child.
                else if(rel.Territory__c == 'US')
                {
                    Release__c associatedRel = new Release__c(Id=rel.Release_Sync__c, Release_Sync__c=rel.Id, Sync_Dates__c=TRUE);
                    for(ReleaseSyncDateField__c dateFld : ReleaseSyncDateField__c.getall().values())
                    {
                        associatedRel.put(dateFld.Field_Api__c, rel.get(dateFld.Field_Api__c));
                    }
                    childUpdateableRelList.add(associatedRel);
                }
            }
            // If parent is updated and having child release to be synced.
            else if(Trigger.isAfter && Trigger.isUpdate && releaseChildMap.get(rel.Id) != null && releaseChildMap.get(rel.Id).Sync_Releases__r != null &&
                    releaseChildMap.get(rel.Id).Sync_Releases__r.size() > 0)    
            {
                // If parent is cancelled, make child's sync field empty. 
                if(((rel.Sync_Dates__c != oldRel.Sync_Dates__c && !rel.Sync_Dates__c) ||
                    (rel.Release_Sync__c != oldRel.Release_Sync__c && rel.Release_Sync__c == null)) || (oldRel.Cancel_Release__c != rel.Cancel_Release__c && rel.Cancel_Release__c))
                {
                    for(Release__c chRel : releaseChildMap.get(rel.Id).Sync_Releases__r)
                    {
                        chRel.Sync_Dates__c = FALSE;
                        chRel.Release_Sync__c = null;
                        chRel.digital__c = false; //DFOR-1494
                        childUpdateableRelList.add(chRel);
                        relId.add(chRel.Id);
                    }
                }
                else
                {
                    if(rel.Territory__c == 'US')    // modified RE-60
                    {
                        for(Release__c chRel : releaseChildMap.get(rel.Id).Sync_Releases__r)
                        {
                            for(ReleaseSyncDateField__c dateFld : ReleaseSyncDateField__c.getall().values())
                            {
                                if(dateFld.Sync_On_Update__c)
                                {
                                    chRel.put(dateFld.Field_Api__c, rel.get(dateFld.Field_Api__c));
                                }
                            }
                            childUpdateableRelList.add(chRel);
                            relId.add(chRel.Id);
                        }
                    }
                }
            }
        }
        
        if(updateSyncReleases.size() > 0)
        {
            TriggerUtility.doNotExecute = TRUE;
            update updateSyncReleases;
            TriggerUtility.doNotExecute = FALSE;
        }
        if(childUpdateableRelList.size() > 0 && !TriggerUtility.checkFromQueueable)
        {
            AsyncReleaseUpdate relUpdateJob = new AsyncReleaseUpdate();
            relUpdateJob.updateableReleaseList = childUpdateableRelList;
            System.enqueueJob(relUpdateJob);
        }
        
        // If CDN is updated with new US Release, fetch US release Dates and Update.
        if(sourceReleaseIds.size() > 0)
        {
            // Build query to fetch date fields from source releases.
            String qry = 'SELECT Id';
            for(ReleaseSyncDateField__c dateFld : ReleaseSyncDateField__c.getall().values())
            {
                if((Trigger.isInsert && dateFld.Sync_On_Insert__c) || (Trigger.isUpdate && dateFld.Sync_On_Update__c))
                    qry += ',' + dateFld.Field_Api__c;
            }
            qry += ' FROM Release__c WHERE Id IN: sourceReleaseIds AND Cancel_Release__c=FALSE';
            
            Map<Id, Release__c> sourceReleaseMap = new Map<Id, Release__c>((List<Release__c>) Database.query(qry));
            
            for(Release__c rel : (List<Release__c>) Trigger.New)
            {
                if(activeUpdateReleases.contains(System.hashCode(rel)))
                {
                    Release__c srcRel = sourceReleaseMap.get(rel.Release_Sync__c);
                    if(srcRel == null) 
                        continue;
                    for(ReleaseSyncDateField__c dateFld : ReleaseSyncDateField__c.getall().values())
                    {
                        if(((Trigger.isInsert && dateFld.Sync_On_Insert__c) || (Trigger.isUpdate && dateFld.Sync_On_Update__c)) && srcRel.get(dateFld.Field_Api__c) != null)
                        {
                            rel.put(dateFld.Field_Api__c, srcRel.get(dateFld.Field_Api__c));
                        }
                    }
                }
            }
        }
    }
    
    
     /***************************************************
    Added for REL-43
    Method Name: userOfPublicGroup
    Purpose: returns users belongs to public group
    ****************************************************/
    public static Set<Id> userOfPublicGroup (Set<String> lstPublicGroup)
    {
        Set<Id> userIds = new Set<Id>();
        Map<Id, Group> mapGroups = new Map<Id, Group>([Select Id,Name from Group where Name IN :lstPublicGroup and Type <> 'Queue']);//USST-2971
        Map<Id,GroupMember> mapGroupMembers = new Map<Id,GroupMember>([Select Id, GroupId,UserOrGroupId from GroupMember where GroupId IN :mapGroups.keySet()]);
        for(GroupMember mem : mapGroupMembers.values())
        {
            if(String.valueof(mem.UserOrGroupId).startsWith(discResUser.getKeyPrefix()))
            {
                userIds.add(mem.UserOrGroupId);
            }
        }
        return userIds;
    }
   
    /*******************************************************************************************************************
    Added for REL-43
    Method Name: EmailCommunicationOnFieldChange
    Purpose: Email communication to the users belongs to public group when there is change in street date and Online Consumer Solicitation Date
    ********************************************************************************************************************/
    public static void EmailCommunicationOnFieldChange (Map<Id,Release__c> lstOldRelease, map<Id,Release__c> lstNewRelease)
    {
        try
        {
            //USST-2743 //USST-2760 --- start
            Map<Id,Release__c> paramountReleases = new Map<Id,Release__c>(); 
            Map<Id,Release__c> oldparamountReleases = new Map<Id,Release__c>();
            Map<Id,Release__c> otherReleases = new Map<Id,Release__c>(); 
            Map<Id,Release__c> oldotherReleases = new Map<Id,Release__c>();
            List<Release__c> finalReleases = new List<Release__c>(); 
            system.debug('list new rel :: '+ lstNewRelease.values());
            for (Release__c rel : lstNewRelease.values()) {
                system.debug('label code rel :: '+ rel.Label_Code__c);
                if (rel.Label_Code__c == '59 - Paramount') {
                    paramountReleases.put(rel.id,rel);
                }
                else if (Email_Notify_Label_Codes__c.getInstance(rel.Label_code__c) != null && rel.Label_Code__c != null && rel.Label_Code__c != '') {
                    otherReleases.put(rel.id,rel);
                }
            }
            
            for (Release__c rel : lstOldRelease.values()) {
                system.debug('label code rel :: '+ rel.Label_Code__c);
                if (rel.Label_Code__c == '59 - Paramount') {
                    oldparamountReleases.put(rel.id,rel);
                }
                else if (Email_Notify_Label_Codes__c.getInstance(rel.Label_code__c) != null && rel.Label_Code__c != null && rel.Label_Code__c != '') {
                    oldotherReleases.put(rel.id,rel);
                }
            }
            
            if (paramountReleases.size() > 0) {
                ParamountEmailCommunicationOnFieldChange(paramountReleases);
            }
            if (otherReleases.size() > 0) {
            //USST-2743 //USST-2760 --- end
                TriggerUtility.checkMassChatterPost = TRUE;
                Id CompRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Competitive').getRecordTypeId();
                List<EntitySubscription> lstUsersFollowRelease = new List<EntitySubscription>();
                map<Id,Set<Id>> mapUsersFollowRelease = new map<Id,Set<Id>>();
                Set<String> lstPublicGroup = new Set<String>();
                Set<String> lstPublicGroup1 = new Set<String>();
                Set<Id> setUsersBizComm = new Set<Id>();
                Set<Id> setUsersPublicGroup = new Set<Id>();
                            
                Set<String> BizCommEmails = new Set<String>();
                Set<String> masterDataGroupEmails = new Set<String>();
                            
                Set<Id> setUsersMasterAndPlanningGroup = new Set<Id>();
                Set<String> masterAndPlanningGroupEmails = new Set<String>();
                
                lstPublicGroup1.add(Master_Data_Public_Group);
                lstPublicGroup1.add(Catalog_Planning_Public_Group);
                lstPublicGroup1.add(Release_Planning_Public_Group);
                lstPublicGroup1.add(RF_All_NR_Planning);//USST-2891
                lstPublicGroup1.add(RF_NR_Planning_Partners);//USST-2891
                lstPublicGroup1.add(RF_NR_Planning_PHE);//USST-2891
                lstPublicGroup1.add(RF_NR_Planning_UNI);//USST-2891
                lstPublicGroup1.add(Master_Data_BPO);//USST-2891
                lstPublicGroup1.add(Master_Data_Partners);//USST-2891
                lstPublicGroup1.add(Master_Data_PHE);//USST-2891
                lstPublicGroup1.add(Master_Data_UNI);//USST-2891
                lstPublicGroup1.add(UPHE_Biz_Comm_Public_Group);//for 101 error USST-2894
                
                setUsersMasterAndPlanningGroup = userOfPublicGroup(lstPublicGroup1);
                            
                Set<Id> setUsersIds = new Set<Id>();
                                
                lstUsersFollowRelease = [Select id,ParentId,SubscriberId from EntitySubscription where ParentId IN :trigger.oldmap.keyset() LIMIT 1000];
                system.debug('follow users :: '+ lstUsersFollowRelease );
                for(EntitySubscription follow : lstUsersFollowRelease)
                {
                    if(mapUsersFollowRelease.containsKey(follow.ParentId))  
                        {
                            mapUsersFollowRelease.get(follow.ParentId).add(follow.SubscriberId);
                        }
                        else
                        {
                            Set<Id> tempId = new Set<Id>();
                            tempId.add(follow.SubscriberId);
                            mapUsersFollowRelease.put(follow.ParentId,tempId);
                        }
                    setUsersIds.add(follow.SubscriberId);       
                }

                setUsersIds.addAll(setUsersMasterAndPlanningGroup);
                for(Release__c newrel : otherReleases.values()) //USST-2743
                {
                    if(newrel.Marketing_Contact__c != null) 
                    {
                        setUsersIds.add(newrel.Marketing_Contact__c);   
                    }
                    if(newrel.Creative_Contact__c != null)  
                    {
                        setUsersIds.add(newrel.Creative_Contact__c);    
                    }   
                }   
                
                map<Id,User> mapUserRecords = new map<Id,User>([Select id,Email,Name from User where Id IN : setUsersIds]);
                map<Id,String> mapUserEmail = new map<Id,String>();
                for(User usr : mapUserRecords.Values())
                {
                    mapUserEmail.put(usr.Id,usr.Email);
                }
                for(Id usrId: setUsersMasterAndPlanningGroup)
                {
                    masterAndPlanningGroupEmails.add(mapUserEmail.get(usrId));  
                }
                            
                List<Messaging.SingleEmailMessage> lstEmailMessages = new List<Messaging.SingleEmailMessage>();
                Time defaultTime = Time.newInstance(0,0,0,0);
                Release__c oldrel = new Release__c() ;
                for(Release__c newrel : otherReleases.values()) //USST-2743
                {   
                    oldrel = (release__c)oldotherReleases.get(newrel.Id); 
                    system.debug('street'+oldrel.Street_Date__c);
                    system.debug('street new'+newrel.Street_Date__c);
                    Set<String> setUserEmailIds = new Set<String> ();
                    List<String> lstUserEmailIds = new List<String> ();
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    String emailBody;
                    
                    if(newrel.RecordTypeId != CompRecordTypeId && newrel.Street_Date__c != ((Release__c)Trigger.OldMap.get(newrel.Id)).Street_Date__c)
                    {
                        //Email notification will be send to the users following releases and belongs to public groups
                        if(mapUsersFollowRelease.keySet().contains(newrel.Id))
                        {
                            for(Id usrId: mapUsersFollowRelease.get(newrel.Id))
                            {
                                setUserEmailIds.add(mapUserEmail.get(usrId));
                            }
                        }
                        //Email notification will be send to the users of public groups 'Master Data'
                        setUserEmailIds.addAll(masterAndPlanningGroupEmails);
                        //Email notification will be send to the Marketing Contact and Creative Contact of Release
                        if(newrel.Marketing_Contact__c != null)
                        {
                            setUserEmailIds.add(mapUserEmail.get(newrel.Marketing_Contact__c));
                        }
                        if(newrel.Creative_Contact__c != null)
                        {
                            setUserEmailIds.add(mapUserEmail.get(newrel.Creative_Contact__c));
                        }   
                        lstUserEmailIds.addAll(setUserEmailIds);
                        system.debug('street'+oldrel.Street_Date__c);
                        system.debug('street new'+newrel.Street_Date__c);
                        IF(oldrel.Online_Consumer_Solicitation_Date__c  != newrel.Online_Consumer_Solicitation_Date__c && oldrel.Street_Date__c == newrel.Street_Date__c){
                        system.debug('street* inside'+oldrel.Street_Date__c); 
                        //do nothing
                        } Else{
                            lstUserEmailIds.add('GuadBPOMasterDataUNI@technicolor.com');
                            lstUserEmailIds.add('vamsi.marala@nbcuni.com');
                            system.debug('street* outside'+oldrel.Street_Date__c); 
                           system.debug('lstUserEmailIds* outside'+lstUserEmailIds); 
                        }
                        message.toAddresses = lstUserEmailIds;
                        system.debug('message.toAddresses'+message.toAddresses);
                        message.subject = 'Street Date Change: ' + newrel.Name;
                        emailBody = '<p> <font size="2" face="verdana"> Release Name: ' + newrel.Name + ' </font> </p>';
                        if(newrel.Territory__c != null)
                        {
                            emailBody = emailBody + '<br /> <p> <font size="2" face="verdana"> Territory: ' + newrel.Territory__c + '</font> </p>'; 
                        }
                        else
                        {
                            emailBody = emailBody + '<br /> <p> <font size="2" face="verdana"> Territory: </font> </p>'; 
                        }
                        emailBody = emailBody + '<p> <font size="2" face="verdana"> Today\'s Date: ' + System.now().format('MMMM d, YYYY') + '</font> </p>';
                        if(newrel.Previous_Street_Date__c != null){
                        emailBody = emailBody + '<p> <font size="2" face="verdana"> Previous Street Date: ' + Datetime.newInstance(newrel.Previous_Street_Date__c,defaultTime).format('MMMM d, YYYY') + '</font> </p>'; 
                        } Else{
                        emailBody = emailBody + '<p> <font size="2" face="verdana"> Previous Street Date: </font> </p>'; 
                        }
                        if(newrel.Street_Date__c != null){
                        emailBody = emailBody + '<p> <font size="2" face="verdana"> <b> New Street Date: ' + Datetime.newInstance(newrel.Street_Date__c,defaultTime).format('MMMM d, YYYY') + '</b> </font> </p>'; //REL-193 
                         } else{
                         emailBody = emailBody + '<p> <font size="2" face="verdana"> <b> New Street Date: </b> </font> </p>'; //REL-193 
                         }
                        if(((Release__c)Trigger.OldMap.get(newrel.Id)).Online_Consumer_Solicitation_Date__c == null && newrel.Online_Consumer_Solicitation_Date__c == null)
                        {
                            emailBody = emailBody + '<br /> <p> <font size="2" face="verdana"> Previous Online Consumer Solicitation Date: ' + '   ' + '</font> </p>'; 
                            emailBody = emailBody + '<p> <font size="2" face="verdana"> <b> New Online Consumer Solicitation Date: ' + '   ' + '</b> </font> </p>'; //REL-193
                        }
                        else if(((Release__c)Trigger.OldMap.get(newrel.Id)).Online_Consumer_Solicitation_Date__c == null)
                        {
                            emailBody = emailBody + '<br /> <p> <font size="2" face="verdana"> Previous Online Consumer Solicitation Date: ' + '   ' + '</font> </p>';
                            emailBody = emailBody + '<p> <font size="2" face="verdana"> <b> New Online Consumer Solicitation Date: ' + Datetime.newInstance(newrel.Online_Consumer_Solicitation_Date__c,defaultTime).format('MMMM d, YYYY') + '</b> </font> </p>';  //REL-193 
                            
                        }
                        else if(newrel.Online_Consumer_Solicitation_Date__c == null)
                        {
                            emailBody = emailBody + '<br /> <p> <font size="2" face="verdana"> Previous Online Consumer Solicitation Date: ' + Datetime.newInstance(((Release__c)Trigger.OldMap.get(newrel.Id)).Online_Consumer_Solicitation_Date__c,defaultTime).format('MMMM d, YYYY') + '</font> </p>';
                            emailBody = emailBody + '<p> <font size="2" face="verdana"> <b> New Online Consumer Solicitation Date: ' + '   ' + '</b> </font> </p>'; //REL-193 
                        }
                        else    
                        {
                            emailBody = emailBody + '<br /><p> <font size="2" face="verdana"> Previous Online Consumer Solicitation Date: ' + Datetime.newInstance(((Release__c)Trigger.OldMap.get(newrel.Id)).Online_Consumer_Solicitation_Date__c,defaultTime).format('MMMM d, YYYY') + '</font> </p>'; 
                            emailBody = emailBody + '<p> <font size="2" face="verdana"> <b> New Online Consumer Solicitation Date: ' + Datetime.newInstance(newrel.Online_Consumer_Solicitation_Date__c,defaultTime).format('MMMM d, YYYY') + '</b> </font> </p>'; //REL-193

                        }
                    
                        if(newrel.Marketing_Contact__c != null)
                        {
                            emailBody = emailBody + '<br /> <p> <font size="2" face="verdana"> Marketing Contact: ' + mapUserRecords.get(newrel.Marketing_Contact__c).Name + '</font> </p>';
                        }
                        else
                        {
                            emailBody = emailBody + '<br /> <p> <font size="2" face="verdana"> Marketing Contact: </font> </p>';
                        }
                        if(newrel.V_Project_Number__c != null)
                        {
                            emailBody = emailBody + '<p> <font size="2" face="verdana"> V-Project Number: ' + newrel.V_Project_Number__c + '</font> </p>';  
                        }
                        else
                        {
                            emailBody = emailBody + '<p> <font size="2" face="verdana"> V-Project Number: </font> </p>';    
                        }
                                            
                        message.htmlBody = emailBody;
                        system.debug('message.toAddresses'+message.toAddresses);
                        if(message.toAddresses != null && message.toAddresses.size() > 0)   
                        {
                            
                            lstEmailMessages.add(message);
                        }   
                        message = null;
                        lstUserEmailIds.clear();
                        emailBody = '';
                                            
                    }
                }
                if(lstEmailMessages != null && lstEmailMessages.size() > 0)
                {
                    
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmailMessages);
                
                    if (results[0].success) {
                    } else {
                    }   
                } 
            }
              
        }
        catch(exception ex){            
        }  
    }
    
    
    /*******************************************************************************************************************
    Added for USST-2760
    Method Name: ParamountEmailCommunicationOnFieldChange
    Purpose: Email communication to the users belongs to public group when there is change in street date and Online Consumer Solicitation Date of Paramount Release
    ********************************************************************************************************************/
    public static void ParamountEmailCommunicationOnFieldChange (Map<id,Release__c> lstNewRelease)
    {
        try
        {
            TriggerUtility.checkMassChatterPost = TRUE;
            Id CompRecordTypeId = Schema.SObjectType.Release__c.getRecordTypeInfosByName().get('Competitive').getRecordTypeId();
            List<EntitySubscription> lstUsersFollowRelease = new List<EntitySubscription>();
            map<Id,Set<Id>> mapUsersFollowRelease = new map<Id,Set<Id>>();
            Set<String> lstPublicGroup = new Set<String>();
            Set<Id> setUsersPublicGroup = new Set<Id>();
                        
            Set<String> publicGroupEmails = new Set<String>();
            
            lstPublicGroup.add(RF_Catalog_Planning_PHE);
            lstPublicGroup.add(Master_Data_PHE);
            lstPublicGroup.add(RF_NR_Planning_PHE);
            lstPublicGroup.add(Master_Data_BPO);//USST-2891
            lstPublicGroup.add(Master_Data_Partners);//USST-2891
            lstPublicGroup.add(Master_Data_Public_Group);//USST-2891
            lstPublicGroup.add(Master_Data_UNI);//USST-2891
            
            setUsersPublicGroup = userOfPublicGroup(lstPublicGroup);
          
            Set<Id> setUsersIds = new Set<Id>();

            setUsersIds.addAll(setUsersPublicGroup);

            for(Release__c newrel : lstNewRelease.values())
            {
                if(newrel.Marketing_Contact__c != null) 
                {
                    setUsersIds.add(newrel.Marketing_Contact__c);   
                }
                if(newrel.Creative_Contact__c != null)  
                {
                    setUsersIds.add(newrel.Creative_Contact__c);    
                }   
            }   
            
            map<Id,User> mapUserRecords = new map<Id,User>([Select id,Email,Name from User where Id IN : setUsersIds]);
            map<Id,String> mapUserEmail = new map<Id,String>();
            for(User usr : mapUserRecords.Values())
            {
                mapUserEmail.put(usr.Id,usr.Email);
            }
            for(Id usrId: setUsersPublicGroup)
            {
                publicGroupEmails.add(mapUserEmail.get(usrId));  
            }
                        
            List<Messaging.SingleEmailMessage> lstEmailMessages = new List<Messaging.SingleEmailMessage>();
            Time defaultTime = Time.newInstance(0,0,0,0);
            for(Release__c newrel : lstNewRelease.values())
            {
                Set<String> setUserEmailIds = new Set<String> ();
                List<String> lstUserEmailIds = new List<String> ();
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                String emailBody;
                
                if(newrel.RecordTypeId != CompRecordTypeId && newrel.Street_Date__c != ((Release__c)Trigger.OldMap.get(newrel.Id)).Street_Date__c)
                {
                    //Email notification will be send to the users following releases and belongs to public groups
                    if(mapUsersFollowRelease.keySet().contains(newrel.Id))
                    {
                        for(Id usrId: mapUsersFollowRelease.get(newrel.Id))
                        {
                            setUserEmailIds.add(mapUserEmail.get(usrId));
                        }
                    }

                    setUserEmailIds.addAll(publicGroupEmails);
                    //Email notification will be send to the Marketing Contact and Creative Contact of Release
                    if(newrel.Marketing_Contact__c != null)
                    {
                        setUserEmailIds.add(mapUserEmail.get(newrel.Marketing_Contact__c));
                    }
                    if(newrel.Creative_Contact__c != null)
                    {
                        setUserEmailIds.add(mapUserEmail.get(newrel.Creative_Contact__c));
                    }   
                    lstUserEmailIds.addAll(setUserEmailIds);
                    lstUserEmailIds.add('GuadBPOMasterDataUNI@technicolor.com');
                    lstUserEmailIds.add('vamsi.marala@nbcuni.com');
                    message.toAddresses = lstUserEmailIds;
                    message.subject = 'Street Date Change: ' + newrel.Name;
                    emailBody = '<p> <font size="2" face="verdana"> Release Name: ' + newrel.Name + ' </font> </p>';
                    if(newrel.Territory__c != null)
                    {
                        emailBody = emailBody + '<br /> <p> <font size="2" face="verdana"> Territory: ' + newrel.Territory__c + '</font> </p>'; 
                    }
                    else
                    {
                        emailBody = emailBody + '<br /> <p> <font size="2" face="verdana"> Territory: </font> </p>'; 
                    }
                    emailBody = emailBody + '<p> <font size="2" face="verdana"> Today\'s Date: ' + System.now().format('MMMM d, YYYY') + '</font> </p>'; 
                    if(newrel.Previous_Street_Date__c != null){
                    emailBody = emailBody + '<p> <font size="2" face="verdana"> Previous Street Date: ' + Datetime.newInstance(newrel.Previous_Street_Date__c,defaultTime).format('MMMM d, YYYY') + '</font> </p>'; 
                    }Else{
                     emailBody = emailBody + '<p> <font size="2" face="verdana"> <b> New Street Date: </b> </font> </p>'; //REL-193 
                    }
                    if(newrel.Street_Date__c != null){
                    emailBody = emailBody + '<p> <font size="2" face="verdana"> <b> New Street Date: ' + Datetime.newInstance(newrel.Street_Date__c,defaultTime).format('MMMM d, YYYY') + '</b> </font> </p>'; //REL-193
                    }else{
                    emailBody = emailBody + '<p> <font size="2" face="verdana"> <b> New Street Date: </b> </font> </p>'; //REL-193
                    }                   
                    if(newrel.Marketing_Contact__c != null)
                    {
                        emailBody = emailBody + '<br /> <p> <font size="2" face="verdana"> Marketing Contact: ' + mapUserRecords.get(newrel.Marketing_Contact__c).Name + '</font> </p>';
                    }
                    else
                    {
                        emailBody = emailBody + '<br /> <p> <font size="2" face="verdana"> Marketing Contact: </font> </p>';
                    }
                    if(newrel.V_Project_Number__c != null)
                    {
                        emailBody = emailBody + '<p> <font size="2" face="verdana"> V-Project Number: ' + newrel.V_Project_Number__c + '</font> </p>';  
                    }
                    else
                    {
                        emailBody = emailBody + '<p> <font size="2" face="verdana"> V-Project Number: </font> </p>';    
                    }
                                        
                    message.htmlBody = emailBody;
                    if(message.toAddresses != null && message.toAddresses.size() > 0)   
                    {
                        lstEmailMessages.add(message);
                    }   
                    message = null;
                    lstUserEmailIds.clear();
                    emailBody = '';
                                        
                }
            }
            if(lstEmailMessages != null && lstEmailMessages.size() > 0)
            {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmailMessages);
            
                if (results[0].success) {
                } else {
                }   
            }   
        }
        catch(exception ex){            
        }  
    }
    
    /*****************************************************************
    Method Name: sendChatterFeedOnUpdateRequests
    Purpose : USST-2547 Chatter post on update material for Field Change on Release
    ***************************************************************/
    public static void sendChatterFeedOnUpdateRequests(List<Material__c> matList){
                    
        Time defaultTime = Time.newInstance(0,0,0,0);
        List<FeedItem> chatterFeedList = new List<FeedItem>();
        List<ID> updateMatIDs = new List<ID>();
        List<ID> originalMatIDs = new List<ID>();
        List<Material__c> originalMatsLst = new List<Material__c>();
        Set<Material__c> originalMatsSet = new Set<Material__c>();
        
        for (Material__c mat : matList) {
            updateMatIDs.add(mat.Id);
            originalMatIDs.add(mat.Original_Material_Number__c);
        }
        
        originalMatsLst = [Select Id, Street_Date__c, Original_Release_Date__c, Pre_Order_Close_Date__c from Material__c where Id IN: originalMatIDs];
        originalMatsSet.addAll(originalMatsLst);
        
        for (Material__c updMt : matList) {
            for (Material__c orgMt : originalMatsSet) {
                if (updMt.Original_Material_Number__c == orgMt.Id) {
                    if (updMt.street_date__c != null && updMt.Original_Release_Date__c != null && updMt.Pre_Order_Close_Date__c != null && updMt.street_date__c != orgMt.street_date__c && updMt.Original_Release_Date__c != orgMt.Original_Release_Date__c && updMt.Pre_Order_Close_Date__c != orgMt.Pre_Order_Close_Date__c) {
                        FeedItem post = new FeedItem();
                        post.ParentId=updMt.id;
                        post.Body='Street Date has been updated from '+Datetime.newInstance(orgMt.street_date__c , defaultTime).format('MMMM d, YYYY')+' to '+Datetime.newInstance(updMt.street_date__c , defaultTime).format('MMMM d, YYYY')+ '\n' +'Original Release Date has been updated from '+Datetime.newInstance(orgMt.Original_Release_Date__c , defaultTime).format('MMMM d, YYYY')+' to '+Datetime.newInstance(updMt.Original_Release_Date__c , defaultTime).format('MMMM d, YYYY')+ '\n' + 'Pre-Order Close Date has been updated from '+Datetime.newInstance(orgMt.Pre_Order_Close_Date__c , defaultTime).format('MMMM d, YYYY')+' to '+Datetime.newInstance(updMt.Pre_Order_Close_Date__c , defaultTime).format('MMMM d, YYYY');
                        
                        chatterFeedList.add(post);
                    }
                    else {
                        if(updMt.street_date__c != null && updMt.street_date__c != orgMt.street_date__c){
                            FeedItem post = new FeedItem();
                            post.ParentId=updMt.id;
                            post.Body='Street Date has been updated from '+Datetime.newInstance(orgMt.street_date__c , defaultTime).format('MMMM d, YYYY')+' to '+Datetime.newInstance(updMt.street_date__c , defaultTime).format('MMMM d, YYYY');
                            chatterFeedList.add(post);
                        }
                        if(updMt.Original_Release_Date__c != null && updMt.Original_Release_Date__c != orgMt.Original_Release_Date__c){
                            FeedItem post = new FeedItem();
                            post.ParentId=updMt.id;
                            post.Body='Original Release Date has been updated from '+Datetime.newInstance(orgMt.Original_Release_Date__c , defaultTime).format('MMMM d, YYYY')+' to '+Datetime.newInstance(updMt.Original_Release_Date__c , defaultTime).format('MMMM d, YYYY');
                            chatterFeedList.add(post);
                        }
                        if(updMt.Pre_Order_Close_Date__c != null && updMt.Pre_Order_Close_Date__c != orgMt.Pre_Order_Close_Date__c){
                            FeedItem post = new FeedItem();
                            post.ParentId=updMt.id;
                            post.Body='Pre-Order Close Date has been updated from '+Datetime.newInstance(orgMt.Pre_Order_Close_Date__c , defaultTime).format('MMMM d, YYYY')+' to '+Datetime.newInstance(updMt.Pre_Order_Close_Date__c , defaultTime).format('MMMM d, YYYY');
                            chatterFeedList.add(post);
                        }
                    }
                    
                    originalMatsSet.remove(orgMt); //reducing load on for loop
                }
            }
        }
        
        if(!chatterFeedList.isEmpty()){
            insert chatterFeedList;
        }
    }
}