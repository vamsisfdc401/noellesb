/**
*    @description   Material Status Validations
*    @Story     HEITCIRF-285
*    @author  SJ
*    Modification Log
*
*/
public class CIRFMaterialValidation {
    
    public static List<String> validMatStat = new List<String>{'NR','FR','NA','AA'};
    public static List<SAPZCMAT__c> SAPZCMATList;
    public static Map<Id,CIRF_Header__c> CirfHeaders;
    public static Map<Id, Material__c> MaterialMap;
    public static List<CIRF_Material__c> currentCIRFMatList;
    public static List<CIRF_Material__c> plannerCheckedCmats;
    public static String retailerSoldTo;
    public Static void CIRFMaterialValidationBefore(Map<Id,CIRF_Material__c> newMap,Map<Id,CIRF_Material__c> oldMap){
        System.debug('CIRFMaterialValidationBefore');
        List<Id> headerIds = new List<Id>();
        List<String> upcList = new List<String>();
        currentCIRFMatList = new List<CIRF_Material__c>();
        plannerCheckedCmats = new List<CIRF_Material__c>();
        for(CIRF_Material__c cmat : newMap.values()){
            //        System.debug('before cmat '+cmat);
            if(oldMap.get(cmat.Id).Material_Name__c != newMap.get(cmat.Id).Material_Name__c){
                cmat.Material_to_Forecast__c = null;
            }
            if(cmat.CIRF_Material_Status__c == 'Submitted'){
                headerIds.add(cmat.CIRF_Header__c);
                currentCIRFMatList.add(cmat);
                if(cmat.UPC__c!=null){
                    upcList.add(cmat.UPC__c);
                }
            }
            if((cmat.Planning_Approval__c == true && cmat.Planning_Approval__c != oldMap.get(cmat.id).Planning_Approval__c)||
               (cmat.Customer_Marketing_Approval__c == true && cmat.Customer_Marketing_Approval__c != oldMap.get(cmat.id).Customer_Marketing_Approval__c)){
                   plannerCheckedCmats.add(cmat);
               }
        }
        if(!currentCIRFMatList.isEmpty()){
            CirfHeaders = new map<Id,CIRF_Header__c>([select id,request_type__c,CIRF_Status__c,Territory__c,
                                                      CIRF_Start_Date__c,Revision__c,Retailer_Sold_To__c from 
                                                      CIRF_Header__c  where id in :headerIds]);
            retailerSoldTo = '00000'+(CirfHeaders.values()[0]).Retailer_Sold_To__c;
            System.debug(retailerSoldTo);
            Map<Id, CIRF_Material__c> cmatsForStatusCheck = new Map<Id, CIRF_Material__c>();
            System.debug('@@@@ SAPZCMATList' +SAPZCMATList);
            if(SAPZCMATList==null){
                //need to refine the query
                SAPZCMATList = [select Z_MAT_VFR__c, Z_MAT_VTO__c,  Z_SOLDTO__c, Z_MATERIAL__c, 
                                Z_CUSTMAT__c from SAPZCMAT__c where /*Z_CUSTMAT__c IN :upcList*/ Z_SOLDTO__c LIKE :retailerSoldTo];
            }
            System.debug('@@@@ '+SAPZCMATList);
            Map<String, List<SAPZCMAT__c>> sapList = new Map<string, List<SAPZCMAT__c>>();
            for(SAPZCMAT__c sap:SAPZCMATList){
                if(!sapList.containsKey(sap.Z_CUSTMAT__c)){
                    sapList.put(sap.Z_CUSTMAT__c, new List<SAPZCMAT__c>());
                }
                sapList.get(sap.Z_CUSTMAT__c).add(sap);
            }
            
            MaterialMap = null;
            
            if(MaterialMap==null){
                MaterialMap = new Map<Id,Material__c>([select id,Old_Material_No__c, Old_Material_No__r.Name, Old_Material_No__r.Forecasting_Relevant_Flag_US__c, Old_Material_No__r.Forecasting_Relevant_Flag_CDN__c, Old_Material_No__r.CIRF_US_D_Chain_Spec__c, Old_Material_No__r.CIRF_CDN_D_Chain_Spec__c, Name from material__c where id in (select material_name__c from cirf_material__C where id in :NewMap.keyset())]);
            }
            System.debug('before context list '+currentCIRFMatList);
            Map<Id,SAPZCMAT__c> finalSAPMap = new Map<Id,SAPZCMAT__c>();
            for(CIRF_Material__c cm : currentCIRFMatList) {
                if(cm.UPC__c != null && sapList.containsKey(cm.UPC__c)){
                    for(SAPZCMAT__c sp : sapList.get(cm.UPC__c)){
                        if(((Long.valueOf(sp.Z_SOLDTO__c)==Long.valueOf(CirfHeaders.get(cm.CIRF_Header__c).Retailer_Sold_To__c)) && sp.Z_MAT_VFR__c<CirfHeaders.get(cm.CIRF_Header__c).CIRF_Start_Date__c && sp.Z_MAT_VTO__c>CirfHeaders.get(cm.CIRF_Header__c).CIRF_Start_Date__c)){
                            finalSAPMap.put(cm.id,sp);
                        }
                    }
                }
            }
            
            for(CIRF_Material__c cm : currentCIRFMatList) {
                System.debug(MaterialMap.get(cm.Material_Name__c));
                //SJ - HEITCIRF-625 - added Merged Status
                if(CirfHeaders.get(cm.CIRF_Header__c).request_type__c=='Reset/Transition'&& (CirfHeaders.get(cm.CIRF_Header__c).CIRF_Status__c=='Submitted' || CirfHeaders.get(cm.CIRF_Header__c).CIRF_Status__c=='Merged')){
                    //if(CirfHeaders.get(cm.CIRF_Header__c).request_type__c !='Singles' && (CirfHeaders.get(cm.CIRF_Header__c).CIRF_Status__c=='Submitted' || CirfHeaders.get(cm.CIRF_Header__c).CIRF_Status__c=='Merged')){    
                    //Scenario 1
                    system.debug('123** scenario 1');
                    cmatsForStatusCheck.put(cm.id,cm);
                }
                else if(CirfHeaders.get(cm.CIRF_Header__c).request_type__c!='Reset/Transition'&& (CirfHeaders.get(cm.CIRF_Header__c).CIRF_Status__c=='Submitted' || CirfHeaders.get(cm.CIRF_Header__c).CIRF_Status__c=='Merged')){
                    //else if(CirfHeaders.get(cm.CIRF_Header__c).request_type__c =='Singles' && (CirfHeaders.get(cm.CIRF_Header__c).CIRF_Status__c=='Submitted' || CirfHeaders.get(cm.CIRF_Header__c).CIRF_Status__c=='Merged')){
                    //System.debug('@@@@ '+sapList.containsKey(cm.UPC__c) + ' '+cm.name);
                    //System.debug(cm.name + ' @@@@ '+ CirfHeaders.get(cm.CIRF_Header__c).CIRF_Status__c + ' '+cm.upc__c);
                    //System.debug(sapList.get(cm.UPC__c));
                    /*if(sapList.containsKey(cm.UPC__c) && ((Long.valueOf(sapList.get(cm.UPC__c).Z_SOLDTO__c)==Long.valueOf(CirfHeaders.get(cm.CIRF_Header__c).Retailer_Sold_To__c)) && sapList.get(cm.UPC__c).Z_MAT_VFR__c<CirfHeaders.get(cm.CIRF_Header__c).CIRF_Start_Date__c && sapList.get(cm.UPC__c).Z_MAT_VTO__c>CirfHeaders.get(cm.CIRF_Header__c).CIRF_Start_Date__c)){
                        system.debug('@@@@ scenario 2');
                        cm.Base_Material_Name__c=cm.Material_Name__c;
                        cm.Version_Material_Names__c=sapList.get(cm.UPC__c).Z_MATERIAL__c;
                        cm.Material_Name__c=cm.Version_Material_Names__c;
                        cmatsForStatusCheck.put(cm.id,cm); 
                    }*/
                    /*if(cm.UPC__c != null && sapList.containsKey(cm.UPC__c)){
                        for(SAPZCMAT__c sp : sapList.get(cm.UPC__c)){
                            if(((Long.valueOf(sp.Z_SOLDTO__c)==Long.valueOf(CirfHeaders.get(cm.CIRF_Header__c).Retailer_Sold_To__c)) && sp.Z_MAT_VFR__c<CirfHeaders.get(cm.CIRF_Header__c).CIRF_Start_Date__c && sp.Z_MAT_VTO__c>CirfHeaders.get(cm.CIRF_Header__c).CIRF_Start_Date__c)){
                                system.debug('@@@@ scenario 2');
                                cm.Base_Material_Name__c=cm.Material_Name__c;
                                cm.Version_Material_Names__c=sp.Z_MATERIAL__c;
                                cm.Material_Name__c=cm.Version_Material_Names__c;
                                cmatsForStatusCheck.put(cm.id,cm); 
                            }
                        }
                    }*/
                    if(finalSAPMap.containsKey(cm.id)){
                        system.debug('@@@@ scenario 2');
                        cm.Base_Material_Name__c=cm.Material_Name__c;
                        cm.Version_Material_Names__c=finalSAPMap.get(cm.id).Z_MATERIAL__c;
                        cm.Material_Name__c=cm.Version_Material_Names__c;
                        cmatsForStatusCheck.put(cm.id,cm); 
                    }
                    else{
                        //saplist does not contain UPC
                        //system.debug('debug -- cm: ' + cm);
                        if(CirfHeaders.get(cm.cirf_header__c).territory__c=='US' && cm.Forecasting_Relevant_Flag_US__c==true){
                            system.debug('scenario 3A');
                            cmatsForStatusCheck.put(cm.id,cm);
                        }
                        else if(CirfHeaders.get(cm.cirf_header__c).territory__c=='CDN' && cm.Forecasting_Relevant_Flag_CDN__c==true){
                            system.debug('scenario 3B');
                            cmatsForStatusCheck.put(cm.id,cm);
                        }
                        else if(MaterialMap.get(cm.Material_Name__c).Old_Material_No__c!=null && isSC4(MaterialMap,CirfHeaders,cm)){
                            System.debug('Scenario 4');
                            //cm.Base_Material_Name__c=cm.Material_Name__c;
                            //cm.Old_Material_Number_Name__c = MaterialMap.get(cm.Material_Name__c).Old_Material_No__r.Name;
                            //cm.Version_Material_Names__c=MaterialMap.get(cm.Material_Name__c).Old_Material_No__c;
                            //cm.Material_Name__c=oldMap.get(cm.id).Material_name__c;
                            //cm.Catalog_vs_VAS__c='VAS';
                            //cm.Unique_vs_National__c='Unique';
                            cm.Material_to_Forecast__c = MaterialMap.get(cm.Material_Name__c).Old_Material_No__r.Id;
                            cmatsForStatusCheck.put(cm.id,cm);         
                        }
                        else{
                            System.debug('relevant forecasting is false');
                            if(MaterialMap.get(cm.Material_Name__c).Old_Material_No__c==null){
                                System.debug('Scenario 5');
                                cmatsForStatusCheck.put(cm.id,cm);
                            }
                            else{
                                cmatsForStatusCheck.put(cm.id,cm);
                            }
                        }
                    }
                }
            }
            if(cmatsForStatusCheck != null && (!cmatsForStatusCheck.values().isEmpty())){
                system.debug('CIRFMaterialValidation - Call MaterialStatusCheck');
                //checkMatStatusCheck - Checks if StatusCheck needs to be called
                List<CIRF_Material__c> retList = checkMatStatusCheckBefore(cmatsForStatusCheck.values(),oldMap);
                if(!retList.isEmpty()){
                    CIRFMaterialStatusCheck.CIRFMaterialStatusCheckMethod(retList,oldMap);
                }
                //CIRFMaterialStatusCheck.processSKUMaterials(checkMatStatusCheckSubmitted(cmatsForStatusCheck.values(),oldMap));
            }
        }
    }
    
    public Static void CIRFMaterialValidationAfter(Map<Id,CIRF_Material__c> newMap,Map<Id,CIRF_Material__c> oldMap){
        System.debug('CIRFMaterialValidationAfter');
        List<Id> headerIds = new List<Id>();
        List<String> upcList = new List<String>();
        for(CIRF_Material__c cmat : newMap.values()){
            headerIds.add(cmat.CIRF_Header__c);
            if(cmat.UPC__c!=null){
                upcList.add(cmat.UPC__c);
            }
        }
        if(!currentCIRFMatList.isEmpty()){
            Map<Id, CIRF_Material__c> cmatsForStatusCheck = new Map<Id, CIRF_Material__c>();
            //if(CirfHeaders==null){
            CirfHeaders = new map<Id,CIRF_Header__c>([select id,request_type__c,CIRF_Status__c,Territory__c,
                                                      CIRF_Start_Date__c,Revision__c,Retailer_Sold_To__c from 
                                                      CIRF_Header__c  where id in :headerIds]);
            retailerSoldTo = '00000'+(CirfHeaders.values()[0]).Retailer_Sold_To__c;
            System.debug(retailerSoldTo);
            //}
            if(SAPZCMATList==null){
                SAPZCMATList = [select Z_MAT_VFR__c, Z_MAT_VTO__c,  Z_SOLDTO__c, Z_MATERIAL__c, 
                                Z_CUSTMAT__c from SAPZCMAT__c where /*Z_CUSTMAT__c IN :upcList*/ Z_SOLDTO__c LIKE :retailerSoldTo];
            }
            Map<String, List<SAPZCMAT__c>> sapList = new Map<string, List<SAPZCMAT__c>>();
            for(SAPZCMAT__c sap:SAPZCMATList){
                if(!sapList.containsKey(sap.Z_CUSTMAT__c)){
                    sapList.put(sap.Z_CUSTMAT__c, new List<SAPZCMAT__c>());
                }
                sapList.get(sap.Z_CUSTMAT__c).add(sap);
            }
            // System.debug('123** After'+CirfHeaders);
            
            System.debug('123** After'+CirfHeaders);
            if(MaterialMap==null){
                MaterialMap = new Map<Id,Material__c>([select id,Old_Material_No__c, Old_Material_No__r.Material_Description_Unique__c, Old_Material_No__r.Forecasting_Relevant_Flag_US__c, Old_Material_No__r.Forecasting_Relevant_Flag_CDN__c, Old_Material_No__r.CIRF_US_D_Chain_Spec__c, Old_Material_No__r.CIRF_CDN_D_Chain_Spec__c, Material_Description_Unique__c from material__c where id in (select material_name__c from cirf_material__C where id in :NewMap.keyset())]);
            }
            System.debug('after context list currentCIRFMatList'+currentCIRFMatList);
            
            Map<Id,SAPZCMAT__c> finalSAPMap = new Map<Id,SAPZCMAT__c>();
            for(CIRF_Material__c cm : currentCIRFMatList) {
                if(cm.UPC__c != null && sapList.containsKey(cm.UPC__c)){
                    for(SAPZCMAT__c sp : sapList.get(cm.UPC__c)){
                        if(((Long.valueOf(sp.Z_SOLDTO__c)==Long.valueOf(CirfHeaders.get(cm.CIRF_Header__c).Retailer_Sold_To__c)) && sp.Z_MAT_VFR__c<CirfHeaders.get(cm.CIRF_Header__c).CIRF_Start_Date__c && sp.Z_MAT_VTO__c>CirfHeaders.get(cm.CIRF_Header__c).CIRF_Start_Date__c)){
                            finalSAPMap.put(cm.id,sp);
                        }
                    }
                }
            }
            
            for(CIRF_Material__c cm : currentCIRFMatList) 
            {
                System.debug('123** After');
                System.debug('123** '+cm.CIRF_Header__c);
                System.debug('123** '+CirfHeaders.get(cm.CIRF_Header__c));
                //SJ - HEITCIRF-625 - added Merged Status
                if(CirfHeaders.get(cm.CIRF_Header__c).request_type__c=='Reset/Transition'&& (CirfHeaders.get(cm.CIRF_Header__c).CIRF_Status__c=='Submitted') || CirfHeaders.get(cm.CIRF_Header__c).CIRF_Status__c=='Merged'){
                    //Scenario 1
                    system.debug('scenario 1');
                    cmatsForStatusCheck.put(cm.id,cm);
                }
                else if(CirfHeaders.get(cm.CIRF_Header__c).request_type__c!='Reset/Transition'&& (CirfHeaders.get(cm.CIRF_Header__c).CIRF_Status__c=='Submitted') || CirfHeaders.get(cm.CIRF_Header__c).CIRF_Status__c=='Merged'){
                    /*if(sapList.containsKey(cm.UPC__c) && ((sapList.get(cm.UPC__c).Z_SOLDTO__c==CirfHeaders.get(cm.CIRF_Header__c).Retailer_Sold_To__c) && sapList.get(cm.UPC__c).Z_MAT_VFR__c<CirfHeaders.get(cm.CIRF_Header__c).CIRF_Start_Date__c && sapList.get(cm.UPC__c).Z_MAT_VTO__c>CirfHeaders.get(cm.CIRF_Header__c).CIRF_Start_Date__c)){
                        system.debug('scenario 2');
                        cmatsForStatusCheck.put(cm.id,cm); 
                    }*/
                    /*if(cm.UPC__c != null && sapList.containsKey(cm.UPC__c)){
                        for(SAPZCMAT__c sp : sapList.get(cm.UPC__c)){
                            if(((Long.valueOf(sp.Z_SOLDTO__c)==Long.valueOf(CirfHeaders.get(cm.CIRF_Header__c).Retailer_Sold_To__c)) && sp.Z_MAT_VFR__c<CirfHeaders.get(cm.CIRF_Header__c).CIRF_Start_Date__c && sp.Z_MAT_VTO__c>CirfHeaders.get(cm.CIRF_Header__c).CIRF_Start_Date__c)){
                                system.debug('scenario 2');
                                cmatsForStatusCheck.put(cm.id,cm); 
                            }
                        }
                    }*/
                    if(finalSAPMap.containsKey(cm.id)){
                        system.debug('scenario 2');
                        cmatsForStatusCheck.put(cm.id,cm); 
                    }
                    else{
                        //saplist does not contain UPC
                        if(CirfHeaders.get(cm.cirf_header__c).territory__c=='US' && cm.Forecasting_Relevant_Flag_US__c==true){
                            system.debug('scenario 3A');
                            cmatsForStatusCheck.put(cm.id,cm);
                        }
                        else if(CirfHeaders.get(cm.cirf_header__c).territory__c=='CDN' && cm.Forecasting_Relevant_Flag_CDN__c==true){
                            system.debug('scenario 3B');
                            cmatsForStatusCheck.put(cm.id,cm);
                        }
                        else if(MaterialMap != null && cm != null && MaterialMap.containsKey(cm.Material_Name__c) &&
                                MaterialMap.get(cm.Material_Name__c).Old_Material_No__c!=null && isSC4(MaterialMap,CirfHeaders,cm)){
                                    //MaterialMap.containsKey(cm.Material_Name__c) && (MaterialMap.get(cm.Material_Name__c).Old_Material_No__c!=null || MaterialMap.get(cm.Material_Name__c).Old_Material_No__c!='') && isSC4(MaterialMap,CirfHeaders,cm)){
                                    System.debug('Scenario 4');
                                    cmatsForStatusCheck.put(cm.id,cm);
                                }
                        else{
                            System.debug('relevant forecasting is false');
                            if(MaterialMap.containsKey(cm.Material_Name__c) && MaterialMap.get(cm.Material_Name__c).Old_Material_No__c==null){
                                System.debug('Scenario 5');
                                cmatsForStatusCheck.put(cm.id,cm);
                            }
                            else{
                                cmatsForStatusCheck.put(cm.id,cm);
                            }
                        }
                    }
                }
            }
            if(cmatsForStatusCheck != null && (!cmatsForStatusCheck.values().isEmpty())){
                //checkMatStatusCheck - Checks if StatusCheck needs to be called
                System.debug('oldMap vinay:'+oldMap);
                List<CIRF_Material__c> retList = checkMatStatusCheckAfter(cmatsForStatusCheck.values(),oldMap);
                if(!retList.isEmpty()){
                    CIRFMaterialStatusCheck.CIRFMaterialStatusCheckAfter(retList,oldMap);
                }
                List<CIRF_Material__c> retList2 = checkMatStatusCheckSubmitted(cmatsForStatusCheck.values(),oldMap);
                if(!retList2.isEmpty()){
                    CIRFMaterialStatusCheck.processSKUMaterialsSubmitted(retList2);
                }
            }
            if(plannerCheckedCmats != null && (!plannerCheckedCmats.isEmpty())){
                System.debug('++++ planner ran');
                //CIRFMaterialStatusCheck.SKUMaterialExceptionApproval(plannerCheckedCmats);
            }
        }
    }
    
    public static boolean isSC4(Map<Id,Material__c> MaterialMap, Map<Id,CIRF_Header__c> CirfHeaders, CIRF_Material__c cm){
        system.debug('****MaterialMap' + MaterialMap);
        system.debug('****CirfHeaders' + CirfHeaders);
        system.debug('****cm' + cm);
        String omn = MaterialMap.get(cm.Material_Name__c).Old_Material_No__c;
        String matd = MaterialMap.get(cm.Material_Name__c).Name;
        String omnd = MaterialMap.get(cm.Material_Name__c).Old_Material_No__r.Name == null ? '' : MaterialMap.get(cm.Material_Name__c).Old_Material_No__r.Name;
        String usDChainSpec = MaterialMap.get(cm.Material_Name__c).Old_Material_No__r.CIRF_US_D_Chain_Spec__c == null ? '' : MaterialMap.get(cm.Material_Name__c).Old_Material_No__r.CIRF_US_D_Chain_Spec__c.substring(0,2);
        String cdDChainSpec = MaterialMap.get(cm.Material_Name__c).Old_Material_No__r.CIRF_CDN_D_Chain_Spec__c == null ? '' : MaterialMap.get(cm.Material_Name__c).Old_Material_No__r.CIRF_CDN_D_Chain_Spec__c.substring(0,2);
        Boolean usr = (CirfHeaders.get(cm.cirf_header__c).territory__c=='US' && MaterialMap.get(cm.Material_Name__c).Old_Material_No__r.Forecasting_Relevant_Flag_US__c == true);
        Boolean cdr = (CirfHeaders.get(cm.cirf_header__c).territory__c=='CDN' && MaterialMap.get(cm.Material_Name__c).Old_Material_No__r.Forecasting_Relevant_Flag_CDN__c == true);
        //Boolean uvm = (CirfHeaders.get(cm.cirf_header__c).territory__c=='US' && validMatStat.contains((MaterialMap.get(cm.Material_Name__c).Old_Material_No__r.CIRF_US_D_Chain_Spec__c).substring(0,2)));
        Boolean uvm = (CirfHeaders.get(cm.cirf_header__c).territory__c=='US' && validMatStat.contains((usDChainSpec)));
        //Boolean cvm = (CirfHeaders.get(cm.cirf_header__c).territory__c=='CA' && validMatStat.contains((MaterialMap.get(cm.Material_Name__c).Old_Material_No__r.CIRF_CDN_D_Chain_Spec__c).substring(0,2)));
        Boolean cvm = (CirfHeaders.get(cm.cirf_header__c).territory__c=='CDN' && validMatStat.contains((cdDChainSpec)));
        system.debug('omn'+omn);
        system.debug('matd'+matd);
        system.debug('usr'+usr);
        system.debug('cdr'+cdr);
        system.debug('uvm'+uvm);
        system.debug('cvm'+cvm);
        if(omn!=null && omnd!=matd && (usr||cdr||uvm||cvm)){
            return true;
        }
        return false;
    }
    
    public static List<CIRF_Material__c> checkMatStatusCheckBefore(List<CIRF_Material__c> cmats, Map<Id,CIRF_Material__c> matOldMap){
        List<CIRF_Material__c> finalMats = new List<CIRF_Material__c>();
        for(CIRF_Material__c cm : cmats) {
            CIRF_Material__c oldMaterial = matOldMap.get(cm.id);
            //System.debug('sttrus '+cm.name+' '+cm.Planning_Approval__c+ ' '+oldMaterial.Planning_Approval__c);
            //System.debug('sttrus '+cm.name+' '+cm.CIRF_Material_Status__c+ ' '+oldMaterial.CIRF_Material_Status__c);
            //if((cm.CIRF_Material_Status__c == 'Submitted') || 
            if((cm.CIRF_Material_Status__c == 'Submitted' && oldMaterial.CIRF_Material_Status__c == 'Draft') ||
               (cm.CIRF_Material_Status__c == 'Loaded' && oldMaterial.CIRF_Material_Status__c == 'Draft') ||
               (cm.CIRF_Material_Status__c == 'Submitted' && oldMaterial.CIRF_Material_Status__c == 'Submitted') ||
               (cm.Customer_Marketing_Approval__c == true && cm.Customer_Marketing_Approval__c != oldMaterial.Customer_Marketing_Approval__c) ||
               (cm.Planning_Approval__c == true && cm.Planning_Approval__c != oldMaterial.Planning_Approval__c) ||
               cm.Material_Name__c != oldMaterial.Material_Name__c || cm.Units_to_Order__c != oldMaterial.Units_to_Order__c ||
               cm.Replen_Units__c != oldMaterial.Replen_Units__c){
                   finalMats.add(cm);
               }
        }
        return finalMats;
        
    }
    
    public static List<CIRF_Material__c> checkMatStatusCheckAfter(List<CIRF_Material__c> cmats, Map<Id,CIRF_Material__c> matOldMap){
        List<CIRF_Material__c> finalMats = new List<CIRF_Material__c>();
        for(CIRF_Material__c cm : cmats) {
            CIRF_Material__c oldMaterial = matOldMap.get(cm.id);
            //System.debug(cm.name);
            //System.debug(cm.Planning_Approval__c);
            //System.debug('oldddd '+oldMaterial);
            //System.debug(oldMaterial.Planning_Approval__c);
            //System.debug('sttrus '+cm.name+' '+cm.Planning_Approval__c+ ' '+oldMaterial.Planning_Approval__c);
            //System.debug('sttrus '+cm.name+' '+cm.CIRF_Material_Status__c+ ' '+oldMaterial.CIRF_Material_Status__c);
            //if((cm.CIRF_Material_Status__c == 'Submitted') || 
            if((cm.CIRF_Material_Status__c == 'Submitted' && oldMaterial.CIRF_Material_Status__c == 'Draft') ||
               (cm.CIRF_Material_Status__c == 'Loaded' && oldMaterial.CIRF_Material_Status__c == 'Draft') ||
               /*(cm.CIRF_Material_Status__c == 'Submitted' && oldMaterial.CIRF_Material_Status__c == 'Submitted') ||*/
               (cm.Customer_Marketing_Approval__c == true && cm.Customer_Marketing_Approval__c != oldMaterial.Customer_Marketing_Approval__c) ||
               (cm.Planning_Approval__c == true && cm.Planning_Approval__c != oldMaterial.Planning_Approval__c) ||
               cm.Material_Name__c != oldMaterial.Material_Name__c || cm.Units_to_Order__c != oldMaterial.Units_to_Order__c ||
               cm.Replen_Units__c != oldMaterial.Replen_Units__c){
                   finalMats.add(cm);
               }
        }
        system.debug('finalMats:'+finalMats);
        return finalMats;
        
    }
    
    public static List<CIRF_Material__c> checkMatStatusCheckSubmitted(List<CIRF_Material__c> cmats, Map<Id,CIRF_Material__c> matOldMap){
        List<CIRF_Material__c> finalMats = new List<CIRF_Material__c>();
        for(CIRF_Material__c cm : cmats){
            CIRF_Material__c oldMaterial = matOldMap.get(cm.id);
            System.debug('stttus '+cm.name+' '+cm.CIRF_Material_Status__c+ ' '+oldMaterial.CIRF_Material_Status__c);
            //if((cm.CIRF_Material_Status__c == 'Submitted') || 
            if((cm.CIRF_Material_Status__c == 'Submitted' && oldMaterial.CIRF_Material_Status__c == 'Draft') || 
               cm.Material_Name__c != oldMaterial.Material_Name__c || cm.Units_to_Order__c != oldMaterial.Units_to_Order__c ||
               cm.Replen_Units__c != oldMaterial.Replen_Units__c){
                   finalMats.add(cm);
               }
        }
        return finalMats;
    }
}