public class CIRFCreateForecastRecords2 {
    
    public static CIRF_Header__c header;
    public static List<CIRF_Forecast_Group__mdt> Forecastgroup;
    public static List<CIRF_Material_Forecast__c> allrelCMF;
    public static List<CIRF_Material_Forecast__c> relCMF;
    public static List<CIRF_Material_Forecast__c> SplitForecastreclist;
    public static List<Material__c> Matlist;
    public static List<Bom_Item__C> bomList;
    public static Map<Id,Bom_Item__C> bomMap;
    public static Map<Id,Material__c> materialMap;
    
    public static List<CIRF_Material_Forecast__c> forecastToInsert;
    public static Map<Id,CIRF_Material_Forecast__c> forecastToUpdate;
    
    @AuraEnabled   
    @future
   
    Public static void CreateForRecords(ID recordId, boolean splitfrst){
        forecastToInsert = new List<CIRF_Material_Forecast__c>();
        forecastToUpdate = new Map<Id,CIRF_Material_Forecast__c>();
        List<Id> materialIds = new List<Id>();
        boolean split = splitfrst;
        header = [select id, CIRF_Status__c,CIRF_Start_Date__c,CIRF_In_Store__c,Request_Type__c,Retailer__c,Retailer_Group__c, Revision__c from CIRF_Header__c where id= :recordId];
        system.debug('header'+header);
        Map<Id,CIRF_Material__c> relCIRFMaterials = new Map<Id,CIRF_Material__c>([select id, name,split_forecast__c,Material_to_Forecast__c,Material_Name__c,Material_Status__c, CIRF_Header__c, CIRF_Material_Status__c, Units_to_Order__c,Replen_Units__c, Corrugate_Units__c, BOM_Required__c, Fully_built__c,Unique_vs_National__c   from CIRF_Material__c where CIRF_Header__c = :recordId AND CIRF_Material_Status__c in ('Loaded','Cancelled','Merged')]);
        system.debug('relCIRFMaterials'+relCIRFMaterials);
        Forecastgroup = [select Base_Date_Field__c, Calculation_Value__c, Operation__c,MasterLabel from CIRF_Forecast_Group__mdt];
        allrelCMF = [select Id,CIRF_Header__c,CIRF_Material__c,Forecast_Type__c,Group_Calculation__c,quantity__c, stage__C,Forecast_Amount__c,
                  Calculated_Date__c,Material_to_Forecast_Number__c, Archive_Date__c,Parent_Forecast_Material__c from CIRF_Material_Forecast__c where CIRF_Header__c = :recordId AND stage__c IN ('Loaded', 'Published','Completed')];
        system.debug('allrelCMF'+allrelCMF);
        relCMF = [select Id,CIRF_Header__c,CIRF_Material__c,Forecast_Type__c,Group_Calculation__c,quantity__c, stage__C,Forecast_Amount__c,
                  Calculated_Date__c,Material_to_Forecast_Number__c, Archive_Date__c,Parent_Forecast_Material__c from CIRF_Material_Forecast__c where CIRF_Material__c IN :relCIRFMaterials.keyset() AND stage__c IN ('Loaded', 'Published','Completed') AND (Parent_Forecast_Material__c = null or Parent_Forecast_Material__c = '')];
        system.debug('relCMF'+relCMF);
        SplitForecastreclist = [select Id,CIRF_Header__c,CIRF_Material__c,Forecast_Type__c,Parent_Forecast_Material__c,Group_Calculation__c,quantity__c, stage__C,Forecast_Amount__c,Calculated_Date__c,Material_to_Forecast_Number__c, Archive_Date__c from CIRF_Material_Forecast__c where CIRF_Material__c IN :relCIRFMaterials.keyset() AND stage__c IN ('Loaded', 'Published','Completed') 
                                AND (Parent_Forecast_Material__c != null or Parent_Forecast_Material__c != '')];
        system.debug('SplitForecastreclist'+SplitForecastreclist);
        for(CIRF_Material__c cmat : relCIRFMaterials.values()){
            if(cmat.Split_Forecast__c == true){
                materialIds.add(cmat.Material_Name__c);    
            }
        }
        Matlist = [select id, material_number__C, name from material__C where id 
                   in (select Material_Component__c from Bom_Item__C where material__c IN :materialIds) AND item_type__c in ('S (Single)','M (Multipack)') and item_code__c != 'BF - BABY FERT'];
        system.debug('Matlist'+Matlist );
        bomList = [select Material_Component__c, material__c from Bom_Item__C where material__c IN :materialIds];
        system.debug('bomList'+bomList );
        
        if(header.CIRF_Status__c == 'Cancelled')
        {
            CancelledCMATFrctRecords();
        }
        else
        {
         	for(CIRF_Material__c cmat : relCIRFMaterials.values())
            {
             //system.debug('Inside CreateForecastRecords');   
            CreateForecastRecords(cmat,split);
        	}   
        }
        //final Insert and Update
        
        system.debug('forecastToInsert:'+forecastToInsert );
        system.debug('forecastToUpdate:'+forecastToUpdate );
        if(!forecastToInsert.isEmpty()){
            insert forecastToInsert;
        }
        if(!forecastToUpdate.values().isEmpty()){
            update forecastToUpdate.values();
        }
    }
    
    Public static void CreateForecastRecords(CIRF_Material__c relcmat, boolean splitfrst){
        try{
            string newgrp;
            string forecasttype;
            boolean split = splitfrst;
            System.debug('type  '+header.Request_Type__c);
            //Scenario 1: header.request type = 'Comingled Virtual Corrugate'
            if(header.Request_Type__c == 'Comingled Virtual Corrugate' ){
                newgrp = 'Group B';
                forecasttype = 'INIT';
                extCreateForecastMDT(newgrp,relcmat,forecasttype,split);
                //system.debug('Comingled VC Inside Replen');
                if(relcmat.BOM_Required__c == false){
                    newgrp = 'Group RC';
                    forecasttype = 'Replen';
                    extCreateForecastMDT(newgrp, relcmat,forecasttype,split ); 
                }
                else if(relcmat.Unique_vs_National__c == 'National'){
                    newgrp = 'Group RD';
                    forecasttype = 'Replen';
                    extCreateForecastMDT(newgrp, relcmat,forecasttype, split); 
                }
                else {
                    newgrp = 'Group RE';
                    forecasttype = 'Replen';
                    extCreateForecastMDT(newgrp, relcmat,forecasttype,split ); 
                }                                
            }     
            //Scenario 2: 
            else{
                if(relcmat.CIRF_Material_Status__c == 'Merged')
                {
                    MergedCMATFrctRecords(relcmat, header.Revision__c);
                }
                else if (relcmat.BOM_Required__c == false){
                    newgrp = 'Group C';
                    forecasttype = 'INIT';                            
                    extCreateForecastMDT(newgrp, relcmat,forecasttype,split);
                }
                else if (relcmat.Unique_vs_National__c == 'Unique') {
                    newgrp = 'Group D';
                    forecasttype = 'INIT';
                    extCreateForecastMDT(newgrp, relcmat,forecasttype,split);
                }
                else if (relcmat.Fully_Built__c == true){
                    newgrp = 'Group D';
                    forecasttype = 'INIT';
                    extCreateForecastMDT(newgrp, relcmat,forecasttype,split);
                }
                else if(relcmat.Unique_vs_National__c == 'National'){
                    if(header.Retailer_Group__c != ''){
                        newgrp = header.Retailer_Group__c;
                        forecasttype = 'INIT';
                        extCreateForecastMDT(newgrp, relcmat,forecasttype,split);
                    }
                }
                if(relcmat.BOM_Required__c == false){
                    newgrp = 'Group RC';
                    forecasttype = 'Replen';
                    extCreateForecastMDT(newgrp, relcmat,forecasttype,split);
                }
                else if (relcmat.Unique_vs_National__c == 'National'){
                    newgrp = 'Group RD';
                    forecasttype = 'Replen';
                    extCreateForecastMDT(newgrp, relcmat,forecasttype,split);
                }
                else if (relcmat.Unique_vs_National__c == 'Unique'){
                    newgrp = 'Group RE';
                    forecasttype = 'Replen';
                    extCreateForecastMDT(newgrp, relcmat,forecasttype,split);
                }     
            }
        }catch(exception e){}
    }
    
    Public static string extCreateForecastMDT(string grp, CIRF_Material__c cmat,string ftype, boolean splitfrst){
        decimal calcvalue;
        string operation;
        date calcdate;       
        string newgrp;
        string baseDateField;
        string forecasttype = ftype;
        //string IdMat = cmatid;
        newgrp = grp;
        boolean split = splitfrst;
        
        for (CIRF_Forecast_Group__mdt frctgrp :Forecastgroup) {
            if (frctgrp.MasterLabel == newgrp){
                baseDateField =  frctgrp.Base_Date_Field__c;
                calcvalue =  frctgrp.Calculation_Value__c;
                operation =  frctgrp.Operation__c;  
                newgrp = frctgrp.MasterLabel;
                //system.debug('Inside EXT: Group -'+newgrp);
                if (operation == 'Add'){
                    if(baseDateField == 'CIRF_Start_Date__c'){
                        calcdate = header.CIRF_Start_Date__c + Integer.valueOf(calcvalue);                
                    }
                    else if (baseDateField == 'CIRF_In_Store__c'){
                        calcdate = header.CIRF_In_Store__c + Integer.valueOf(calcvalue);    
                    }
                    else {
                        calcdate = system.Today() + Integer.valueOf(calcvalue);
                    }
                }
                if (operation == 'Subtract'){
                    if(baseDateField == 'CIRF_Start_Date__c'){
                        calcdate = header.CIRF_Start_Date__c - Integer.valueOf(calcvalue);                
                    }
                    else if (baseDateField == 'CIRF_In_Store__c'){
                        calcdate = header.CIRF_In_Store__c - Integer.valueOf(calcvalue);    
                    }
                    else{
                        calcdate = system.Today() - Integer.valueOf(calcvalue);
                    }
                    
                } 
                if(calcdate <= System.today() + 7){
                    calcdate = System.today() + 7;
                    newgrp = 'Group Z';
                    if(forecasttype == 'INIT'){
                        InitForecastRecords(calcdate,newgrp,cmat,header.revision__c,forecasttype, split);  
                        return ('Success');    
                    }
                    else{
                        ReplenFrstRecords(calcdate,newgrp,cmat,header.revision__c, forecasttype, split);
                        return ('Success');
                    }
                }
                else{
                    if(forecasttype == 'INIT'){
                        InitForecastRecords(calcdate,newgrp,cmat,header.revision__c,forecasttype, split);  
                        return ('Success');    
                    }
                    else{
                        ReplenFrstRecords(calcdate,newgrp,cmat,header.revision__c, forecasttype, split);
                        return ('Success');
                    }
                }
            }
        }      return('success');
    }
    Public static string InitForecastRecords(Date calcdate,string grp,CIRF_Material__c cmat,decimal revision,string ftype, boolean splitfrst){
        string calcgrp = grp;
        date calcdt = calcdate; 
        //id cmatid = recordid;
        string forecasttype = ftype;
        decimal revisionnr = revision;
        boolean split = splitfrst;
        
        List<CIRF_Material_Forecast__c> Forecastreclist = new List<CIRF_Material_Forecast__c>();
        List<CIRF_Material_Forecast__c> Forecastreclist2 = new List<CIRF_Material_Forecast__c>();
        List<CIRF_Material_Forecast__c> Forecastreclist3 = new List<CIRF_Material_Forecast__c>();
        List<CIRF_Material_Forecast__c> Forecastreclist4 = new List<CIRF_Material_Forecast__c>();
        Material__c mat = new Material__c();
        //system.debug('CMAT: '+CMAT);
        List<CIRF_Material_Forecast__c> relCMFinit = getCustomizedForecasts(cmat.id,'Initial Ship');
        //system.debug('relCMFinit: '+relCMFinit);
        List<CIRF_Material_Forecast__c> relCMFcorr = getCustomizedForecasts(cmat.id,'Corrugate');
        //system.debug('relCMFcorr: '+relCMFcorr);
        if(cmat.CIRF_Material_Status__c == 'Cancelled'){
            //CancelledCMATFrctRecords(cmat.id, revisionnr);
            for(CIRF_Material_Forecast__c cfm : allrelCMF)
                {
                    if(cfm.CIRF_Material__c == cmat.Id && cfm.Forecast_Type__c != 'Replenishment')
                    {
                    	CancelFrctRecords(cmat, cfm, revisionnr, cfm.Forecast_Type__c);    
                    }
                }
        }
        /*else if(cmat.CIRF_Material_Status__c == 'Merged'){
            MergedCMATFrctRecords(cmat, revisionnr);
        }*/
        else if(cmat.CIRF_Material_Status__c == 'Loaded'){
            if(cmat.Units_to_Order__c > 0 ) {
                if(relCMFinit.isEmpty()){
                    CIRF_Material_Forecast__c frct2 = new CIRF_Material_Forecast__c();
                    frct2.CIRF_Material__c = cmat.Id;
                    frct2.CIRF_Header__c = cmat.CIRF_Header__c;
                    //frct2.Material_to_Forecast_Number__c=cmat.Material_Name__c;
                    frct2.Material_to_Forecast_Number__c=cmat.Material_to_Forecast__c;
                    frct2.Forecast_Type__c='Initial Ship';
                    frct2.Group_Calculation__c = calcgrp;
                    frct2.Calculated_Date__c= calcdt;
                    frct2.quantity__c = cmat.Units_to_Order__c;
                    if(cmat.Material_Status__c == 'NR' || cmat.Material_Status__c == 'FR' || cmat.Material_Status__c == 'AA' || cmat.Material_Status__c == 'NA'){
                        frct2.Stage__c = 'Published';    
                    }
                    else{
                        frct2.Stage__c = 'Loaded';
                    }
                    frct2.Revision_Number__c = revision;
                    forecastToInsert.add(frct2);
                    //insert Forecastreclist;
                    
                    if(cmat.split_forecast__c == true){
                        List<CIRF_Material_Forecast__c> SplitForecastreclist = new List<CIRF_Material_Forecast__c>();
                        for(BOM_Item__c Bom :bomList){
                            if(Bom.Material__c == cmat.Material_Name__c){
                                for(Material__c cm : Matlist) {
                                    if(cm.id == Bom.Material_Component__c){
                                        system.debug('cm:'+cm);
                                        CIRF_Material_Forecast__c splitfrct = new CIRF_Material_Forecast__c();
                                        splitfrct.CIRF_Material__c = cmat.Id;
                                        splitfrct.Material_to_Forecast_Number__c = cm.id;
                                        splitfrct.Parent_Forecast_Material__c = frct2.Id;
                                        splitfrct.CIRF_Header__c = cmat.CIRF_Header__c;
                                        splitfrct.Forecast_Type__c = 'Initial Ship';
                                        splitfrct.Group_Calculation__c = calcgrp;
                                        splitfrct.Calculated_Date__c = calcdt;
                                        splitfrct.quantity__c = cmat.Units_to_Order__c;
                                        splitfrct.Revision_Number__c = revision;
                                        if(cmat.Material_Status__c == 'NR' || cmat.Material_Status__c == 'FR' || cmat.Material_Status__c == 'AA' || cmat.Material_Status__c == 'NA'){
                                            splitfrct.Stage__c = 'Published';
                                        }
                                        else{
                                            splitfrct.Stage__c = 'Loaded';
                                        }
                                        system.debug(splitfrct);
                                        forecastToInsert.add(splitfrct);
                                    }
                                }   
                            }
                        }//insert SplitForecastreclist;    
                    }
                }
                else{
                    ReviseFrstRecords(calcdt,calcgrp,cmat,revisionnr, relCMFinit, split);
                }
            }
            else if(cmat.Units_to_Order__c == 0 && !relCMFinit.isEmpty() ){
                ReviseFrstRecords(calcdt,calcgrp,cmat,revisionnr, relCMFinit, split);
            }
            if(cmat.Corrugate_Units__c > 0 ) {
                if(relCMFcorr.isEmpty()){
                    CIRF_Material_Forecast__c frct1 = new CIRF_Material_Forecast__c();
                    frct1.CIRF_Material__c = cmat.Id;
                    frct1.CIRF_Header__c = cmat.CIRF_Header__c;
                    //frct1.Material_to_Forecast_Number__c=cmat.Material_Name__c;
                    frct1.Material_to_Forecast_Number__c=cmat.Material_to_Forecast__c;
                    frct1.Forecast_Type__c='Corrugate';
                    frct1.Group_Calculation__c = calcgrp;
                    frct1.Calculated_Date__c= calcdt;   
                    if(cmat.Material_Status__c == 'NR' || cmat.Material_Status__c == 'FR' || cmat.Material_Status__c == 'AA' || cmat.Material_Status__c == 'NA'){
                        frct1.Stage__c = 'Published';    
                    }
                    else{
                        frct1.Stage__c = 'Loaded';
                    }
                    frct1.quantity__c = cmat.Corrugate_Units__c;
                    frct1.Revision_Number__c = revision;
                    system.debug(frct1);                
                    forecastToInsert.add(frct1);
                    //insert Forecastreclist2;
                    if(cmat.split_forecast__c == true){
                        List<CIRF_Material_Forecast__c> SplitForecastreclist1 = new List<CIRF_Material_Forecast__c>();
                        for(BOM_item__c Bom: Bomlist){
                            if(Bom.Material__c == cmat.Material_Name__c){
                                for(Material__c cm : Matlist) {   
                                    if(cm.id == Bom.Material_Component__c){
                                        CIRF_Material_Forecast__c splitfrct1 = new CIRF_Material_Forecast__c();
                                        splitfrct1.CIRF_Material__c = cmat.Id;
                                        splitfrct1.Material_to_Forecast_Number__c = cm.id;
                                        splitfrct1.Parent_Forecast_Material__c = frct1.Id;
                                        splitfrct1.CIRF_Header__c = cmat.CIRF_Header__c;
                                        splitfrct1.Forecast_Type__c = 'Corrugate';
                                        splitfrct1.Group_Calculation__c = calcgrp;
                                        splitfrct1.Calculated_Date__c = calcdt;
                                        splitfrct1.quantity__c = cmat.Units_to_Order__c;
                                        splitfrct1.Revision_Number__c = revision;
                                        if(cmat.Material_Status__c == 'NR' || cmat.Material_Status__c == 'FR' || cmat.Material_Status__c == 'AA' || cmat.Material_Status__c == 'NA'){
                                            splitfrct1.Stage__c = 'Published';
                                        }
                                        else{
                                            splitfrct1.Stage__c = 'Loaded';
                                        }
                                        forecastToInsert.add(splitfrct1);       
                                    }
                                }        
                            }
                        }
                        //insert SplitForecastreclist1;
                    }
                }
                else{
                    ReviseFrstRecords(calcdt,calcgrp,cmat,revisionnr, relCMFcorr, split);
                }
            }
            else if(cmat.Corrugate_Units__c == 0 && !relCMFcorr.isEmpty() ){
                ReviseFrstRecords(calcdt,calcgrp,cmat,revisionnr, relCMFcorr, split);
            }
        }
        return('success');
    }
    
    Public static string ReplenFrstRecords(Date calcdate,string grp,CIRF_Material__c cmat,decimal revision,string ftype, boolean splitfrst){
        string calcgrp = grp;
        date calcdt = calcdate; 
        decimal revisionnr = revision;
        string forecasttype = ftype;
        boolean split = splitfrst;
        List<CIRF_Material_Forecast__c> Forecastreclist1 = new List<CIRF_Material_Forecast__c>();
        List<CIRF_Material_Forecast__c> Forecastreclist2 = new List<CIRF_Material_Forecast__c>();
        List<CIRF_Material_Forecast__c> relCMFreplen = getCustomizedForecasts(cmat.id,'Replenishment');
        //system.debug('relCMFreplen: '+relCMFreplen);
        Material__c mat = new Material__c();
        if(cmat.CIRF_Material_Status__c == 'Cancelled'){
            //CancelledCMATFrctRecords(cmat.id, revisionnr);
            for(CIRF_Material_Forecast__c cfm : allrelCMF)
                {
                    if(cfm.CIRF_Material__c == cmat.Id && cfm.Forecast_Type__c == 'Replenishment')
                    {
                    	CancelFrctRecords(cmat, cfm, revisionnr, cfm.Forecast_Type__c);    
                    }
                }
        }
       /* else if(cmat.CIRF_Material_Status__c == 'Merged'){
            MergedCMATFrctRecords(cmat, revisionnr);
        }*/
        else if(cmat.CIRF_Material_Status__c == 'Loaded'){
            CIRF_Material_Forecast__c frct = new CIRF_Material_Forecast__c();
            if(relCMFreplen.isEmpty() && cmat.Replen_Units__c > 0){
                frct.CIRF_Material__c = cmat.Id;
                frct.CIRF_Header__c = cmat.CIRF_Header__c;
                //frct.Material_to_Forecast_Number__c=cmat.Material_Name__c;
                frct.Material_to_Forecast_Number__c=cmat.Material_to_Forecast__c;
                frct.Forecast_Type__c='Replenishment';
                frct.Group_Calculation__c = calcgrp;
                frct.Calculated_Date__c= calcdt;
                frct.quantity__c = cmat.Replen_Units__c;
                if(cmat.Material_Status__c == 'NR' || cmat.Material_Status__c == 'FR' || cmat.Material_Status__c == 'AA' || cmat.Material_Status__c == 'NA'){
                    frct.Stage__c = 'Published';
                }
                else{
                    frct.Stage__c = 'Loaded';
                }
                frct.Revision_Number__c = revision;
                forecastToInsert.add(frct);
                //insert Forecastreclist1;
                if(cmat.split_forecast__c == true){
                    List<CIRF_Material_Forecast__c> SplitForecastreclist2 = new List<CIRF_Material_Forecast__c>();
                    for(BOM_Item__C Bom: Bomlist){
                        if(Bom.Material__c == cmat.Material_Name__c){
                            for(Material__c cm : Matlist) {
                                if(cm.id == Bom.Material_Component__c){
                                    CIRF_Material_Forecast__c splitfrct2 = new CIRF_Material_Forecast__c();
                                    splitfrct2.CIRF_Material__c = cmat.Id;
                                    splitfrct2.Material_to_Forecast_Number__c = cm.id;
                                    splitfrct2.CIRF_Header__c = cmat.CIRF_Header__c;
                                    splitfrct2.Forecast_Type__c = 'Replenishment';
                                    splitfrct2.Parent_Forecast_Material__c = frct.Id;
                                    splitfrct2.Group_Calculation__c = calcgrp;
                                    splitfrct2.Calculated_Date__c = calcdt;
                                    splitfrct2.quantity__c = cmat.Units_to_Order__c;
                                    splitfrct2.Revision_Number__c = revision;
                                    if(cmat.Material_Status__c == 'NR' || cmat.Material_Status__c == 'FR' || cmat.Material_Status__c == 'AA' || cmat.Material_Status__c == 'NA'){
                                        splitfrct2.Stage__c = 'Published';
                                    }
                                    else{
                                        splitfrct2.Stage__c = 'Loaded';
                                    }
                                    forecastToInsert.add(splitfrct2);
                                }
                            }     
                        }
                    }
                    //insert SplitForecastreclist2;
                }
            }
            else{
                ReviseFrstRecords(calcdt,calcgrp,cmat,revisionnr,relCMFreplen, split);
            }
        }
        return('success');
    }
    
    Public static string ReviseFrstRecords(Date calcdate,string grp,CIRF_Material__c relcirfmat, decimal revision, list<cirf_material_forecast__C> frct, boolean splitfrst){
        try{
            string calcgrp = grp;
            date calcdt = calcdate;
            decimal revisionnr = revision;
            List<CIRF_Material_Forecast__c> relCMFs = frct;
            //system.debug('relCMFs' +relCMFs);
            boolean split = splitfrst;
            if(relcirfmat.CIRF_Material_Status__c == 'Cancelled'){
                //CancelledCMATFrctRecords(relcirfmat.id, revisionnr);
                for(CIRF_Material_Forecast__c cfm : allrelCMF)
                {
                    if(cfm.CIRF_Material__c == relcirfmat.Id)
                    {
                    	CancelFrctRecords(relcirfmat, cfm, revisionnr, cfm.Forecast_Type__c);    
                    }
                }
            }
            else{   
                for(CIRF_Material_Forecast__c cfm : relCMFs){
                    if(cfm.Forecast_Type__c == 'Initial Ship'){
                        if(relcirfmat.Units_to_Order__c > 0){
                            if(relcirfmat.Units_to_Order__c != cfm.Quantity__c || calcdate != cfm.Calculated_Date__c || relcirfmat.Material_to_Forecast__c != cfm.Material_to_Forecast_Number__c || split == true){
                                
                                ArchiveInsertFrstRecords(calcdt,calcgrp,cfm.Forecast_Type__c,relcirfmat, cfm, revisionnr, split);
                            }
                        }
                        else if (relcirfmat.Units_to_Order__c == 0){
                            if(relcirfmat.Units_to_Order__c != cfm.Quantity__c){
                                CancelFrctRecords(relcirfmat, cfm, revisionnr, cfm.Forecast_Type__c);
                            }
                        }
                    }
                    else if(cfm.Forecast_Type__c == 'Corrugate' ){
                        if(relcirfmat.Corrugate_Units__c > 0 ){
                            if(relcirfmat.Corrugate_Units__c != cfm.Quantity__c || calcdate != cfm.Calculated_Date__c  || relcirfmat.Material_to_Forecast__c != cfm.Material_to_Forecast_Number__c || split == true){
                                ArchiveInsertFrstRecords(calcdt,calcgrp,cfm.Forecast_Type__c,relcirfmat, cfm, revisionnr,split);    
                            }
                        }
                        else if (relcirfmat.Corrugate_Units__c == 0){
                            if(relcirfmat.Corrugate_Units__c != cfm.Quantity__c){
                                CancelFrctRecords(relcirfmat, cfm, revisionnr,cfm.Forecast_Type__c);
                            }
                        }
                    }
                    else if(cfm.Forecast_Type__c == 'Replenishment'){
                        if(relcirfmat.Replen_Units__c > 0){
                            if(relcirfmat.Replen_Units__c != cfm.Quantity__c || calcdate != cfm.Calculated_Date__c  || relcirfmat.Material_to_Forecast__c != cfm.Material_to_Forecast_Number__c || split == true){
                                ArchiveInsertFrstRecords(calcdt,calcgrp,cfm.Forecast_Type__c,relcirfmat, cfm, revisionnr,split);    
                            }
                        }
                        else if (relcirfmat.Replen_Units__c == 0){
                            if(relcirfmat.Replen_Units__c != cfm.Quantity__c){
                                CancelFrctRecords(relcirfmat, cfm, revisionnr, cfm.Forecast_Type__c);
                            }
                        }
                    }
                }
            }            
        }catch(exception e){}
        return('success');
    }
    
    Public static string ArchiveInsertFrstRecords(Date calcdate,string grp,string ftype,cirf_material__C cmat, cirf_material_forecast__C cfm, decimal revision, boolean splitfrst){
        try{
            string calcgrp = grp;
            date calcdt = calcdate;
            string forecasttype = ftype;
            boolean split = splitfrst;
            
            List<CIRF_Material_Forecast__c> Forecastreclist3 = new List<CIRF_Material_Forecast__c>();
            List<CIRF_Material_Forecast__c> Forecastreclist4 = new List<CIRF_Material_Forecast__c>();
            CIRF_Material_Forecast__c cfmrec = cfm;
            CIRF_Material__c relcmat = cmat;
            if (split == false){
                cfmrec.Stage__c = 'Archived';
                cfmrec.Archive_Date__c = DateTime.now();
                //forecastToUpdate.add(cfmrec);
                forecastToUpdate.put(cfmrec.id,cfmrec);
                //update Forecastreclist3;
                
                CIRF_Material_Forecast__c frct = new CIRF_Material_Forecast__c();
                if(forecasttype == 'Initial Ship'){
                    frct.Forecast_Type__c = forecasttype;
                    frct.quantity__C = relcmat.Units_to_Order__c; 
                }
                else if(forecasttype == 'Corrugate'){
                    frct.Forecast_Type__c = forecasttype;
                    frct.quantity__C = relcmat.Corrugate_Units__c; 
                }
                else if(forecasttype == 'Replenishment'){
                    frct.Forecast_Type__c = forecasttype;
                    frct.quantity__C = relcmat.Replen_Units__c; 
                }
                frct.CIRF_Material__c = relcmat.Id;
                frct.CIRF_Header__c = relcmat.CIRF_Header__c;
                //frct.Material_to_Forecast_Number__c=relcmat.Material_Name__c;
                frct.Material_to_Forecast_Number__c=relcmat.Material_to_Forecast__c;
                frct.Group_Calculation__c = calcgrp;
                frct.Calculated_Date__c= calcdt;
                if(relcmat.Material_Status__c == 'NR' || relcmat.Material_Status__c == 'FR' || relcmat.Material_Status__c == 'NA' || relcmat.Material_Status__c == 'AA'){
                    frct.Stage__c = 'Published';    
                }
                else{
                    frct.Stage__c = 'Loaded';
                }
                frct.Revision_Number__c = revision;
                forecastToInsert.add(frct);
                //Insert Forecastreclist4;
            }
            //Split Forecast
            //System.debug('forrr '+cmat.split_forecast__c + ' '+cmat.name);
            if(cmat.split_forecast__c == true){
                List<CIRF_Material_Forecast__c> SplitFrctlist = new List<CIRF_Material_Forecast__c>();
                string fortype = 'Split';
                system.debug('SplitForecastreclist'+SplitForecastreclist);
                if(!SplitForecastreclist.isEmpty()){
                    for (CIRF_Material_Forecast__c cm : SplitForecastreclist){
                        if(cm.CIRF_Material__c == cmat.Id){
                            CIRF_Material_Forecast__c splitfrct = new CIRF_Material_Forecast__c();
                            cm.Stage__c = 'Archived';
                            cm.Archive_Date__c = DateTime.now();
                            //forecastToUpdate.add(cm);
                            forecastToUpdate.put(cm.id,cm);
                            //update SplitFrctlist;  
                        }
                    }
                }
                List<CIRF_Material_Forecast__c> SplitForecastreclist3 = new List<CIRF_Material_Forecast__c>();
                for(BOM_Item__c Bom: Bomlist){
                    system.debug('Bom:'+Bom);
                    system.debug('CMAT:'+cmat);
                    if(Bom.Material__c == cmat.Material_Name__c){
                        for(Material__c cm1 : Matlist) {
                            system.debug('cm1:'+cm1);
                            if(cm1.id == Bom.Material_Component__c){
                                CIRF_Material_Forecast__c splitfrct3 = new CIRF_Material_Forecast__c();
                                splitfrct3.CIRF_Material__c = cmat.Id;
                                splitfrct3.Material_to_Forecast_Number__c = cm1.id;
                                splitfrct3.Parent_Forecast_Material__c = cfmrec.Id;
                                splitfrct3.CIRF_Header__c = cmat.CIRF_Header__c;
                                if(forecasttype == 'Initial Ship'){
                                    splitfrct3.Forecast_Type__c = forecasttype;
                                    splitfrct3.quantity__C = relcmat.Units_to_Order__c; 
                                }
                                else if(forecasttype == 'Corrugate'){
                                    splitfrct3.Forecast_Type__c = forecasttype;
                                    splitfrct3.quantity__C = relcmat.Corrugate_Units__c; 
                                }
                                else if(forecasttype == 'Replenishment'){
                                    splitfrct3.Forecast_Type__c = forecasttype;
                                    splitfrct3.quantity__C = relcmat.Replen_Units__c; 
                                }
                                splitfrct3.Group_Calculation__c = calcgrp;
                                splitfrct3.Calculated_Date__c = calcdt;
                                splitfrct3.Revision_Number__c = revision;
                                if(cmat.Material_Status__c == 'NR' || cmat.Material_Status__c == 'FR' || cmat.Material_Status__c == 'AA' || cmat.Material_Status__c == 'NA'){
                                    splitfrct3.Stage__c = 'Published';
                                }
                                else{
                                    splitfrct3.Stage__c = 'Loaded';
                                }
                                forecastToInsert.add(splitfrct3);
                            }
                        }        
                    }
                }//insert SplitForecastreclist3;
            }
        } catch(exception e){
            
        }
        return('success');
    }
    
    Public static string MergedCMATFrctRecords(CIRF_Material__c cmat, decimal revision){
        decimal revisionnr = revision;
        //system.debug('MergedCMATFrctRecords-cmat: '+cmat);
        List<CIRF_Material_Forecast__c> Forecastreclist = new List<CIRF_Material_Forecast__c>();
        //List<CIRF_Material_Forecast__c> relCMFs = getCustomizedForecasts(cmat.id,null); 
        //system.debug('relCMFs '+allrelCMF);
        if (!allrelCMF.isEmpty()){
            for(CIRF_Material_Forecast__c cfm : allrelCMF){
                cfm.Archive_Date__c = DateTime.now();
                cfm.Stage__c = 'Archived';
                //forecastToUpdate.add(cfm);
                forecastToUpdate.put(cfm.id,cfm);
                //update Forecastreclist;
            }
        }
        return('success');
    }
    Public static string CancelledCMATFrctRecords(){
        //decimal revisionnr = revision;
        List<CIRF_Material_Forecast__c> Forecastreclist3 = new List<CIRF_Material_Forecast__c>();
        List<CIRF_Material_Forecast__c> Forecastreclist4 = new List<CIRF_Material_Forecast__c>();
        //List<CIRF_Material_Forecast__c> relCMFs = getCustomizedForecasts(recordid,null); 
        for(CIRF_Material_Forecast__c cfm : allrelCMF){
            	CIRF_Material_Forecast__c frct = new CIRF_Material_Forecast__c();
                frct.CIRF_Header__c = cfm.CIRF_Header__c;
                frct.CIRF_Material__c = cfm.CIRF_Material__c;
                frct.Archive_Date__c = cfm.Archive_Date__c;
                frct.Calculated_Date__c = cfm.Calculated_Date__c;
                frct.Group_Calculation__c = cfm.Group_Calculation__c;
                frct.Forecast_Type__c = cfm.Forecast_Type__c;
                frct.Quantity__c = cfm.Quantity__c;
                frct.Material_to_Forecast_Number__c = cfm.Material_to_Forecast_Number__c;
                frct.Stage__c = 'Cancelled';
                frct.Revision_Number__c = header.Revision__c;
                //Forecastreclist3.add(frct);
                forecastToInsert.add(frct);
                cfm.Archive_Date__c = DateTime.now();
                cfm.Stage__c = 'Archived';
                //forecastToUpdate.add(cfm);                    
                forecastToUpdate.put(cfm.id,cfm);                    
            
            //update Forecastreclist4;
        }
        //insert Forecastreclist3;
        
        return('success');
    }
    
    Public static string CancelFrctRecords(cirf_material__C cmat, cirf_material_forecast__C cirffm, decimal revision, string ftype){
        try{
            decimal revisionnr = revision;
            string forecasttype = ftype;
            CIRF_Material__c relcmat = cmat;
            List<CIRF_Material_Forecast__c> Forecastreclist = getCustomizedForecasts(cmat.id,forecasttype);
            List<CIRF_Material_Forecast__c> Forecastreclist3 = new List<CIRF_Material_Forecast__c>();
            List<CIRF_Material_Forecast__c> Forecastreclist4 = new List<CIRF_Material_Forecast__c>();
            if(!Forecastreclist.isEmpty()){
                for(CIRF_Material_Forecast__c cfm :Forecastreclist){
                    CIRF_Material_Forecast__c frct = new CIRF_Material_Forecast__c();
                    frct.CIRF_Header__c = cfm.CIRF_Header__c;
                    frct.CIRF_Material__c = cfm.CIRF_Material__c;
                    frct.Archive_Date__c = cfm.Archive_Date__c;
                    frct.Calculated_Date__c = cfm.Calculated_Date__c;
                    frct.Group_Calculation__c = cfm.Group_Calculation__c;
                    frct.Forecast_Type__c = cfm.Forecast_Type__c;
                    frct.Quantity__c = cfm.Quantity__c;
                    frct.Material_to_Forecast_Number__c = cfm.Material_to_Forecast_Number__c;
                    frct.Stage__c = 'Cancelled';
                    frct.Revision_Number__c = revisionnr;
                    //Forecastreclist3.add(frct);
                    forecastToInsert.add(frct);
                    if(cfm.Archive_Date__c == null){
                        cfm.Archive_Date__c = DateTime.now();
                        cfm.Stage__c = 'Archived';
                        //forecastToUpdate.add(cfm);
                        forecastToUpdate.put(cfm.id,cfm);
                        //update Forecastreclist4;
                    } 
                } //insert Forecastreclist3;
            }
        }catch(exception e){}
        return('success');
    }
    
    public static List<CIRF_Material_Forecast__c> getCustomizedForecasts(Id cmatId, String forecastType){
        List<CIRF_Material_Forecast__c> custFor = new List<CIRF_Material_Forecast__c>();
        
        for(CIRF_Material_Forecast__c cmf : relCMF){
            if(forecastType != null && cmf.CIRF_Material__c == cmatId && cmf.Forecast_Type__c == forecastType){
                custFor.add(cmf);
            }
        }
        return custFor;
    }
}