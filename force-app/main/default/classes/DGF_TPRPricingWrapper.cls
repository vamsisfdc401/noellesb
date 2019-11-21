/*****************************************************************************************
Class Name: DGF_TPRPricingWrapper
Purpose: Preparing the wrapper for TPR Pricing
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             04/08/2017           Prarthana                Initial Development
******************************************************************************************/
public with sharing class DGF_TPRPricingWrapper {
    //wrapper class for mapping product and pricing records
    public class ProductPricingWrapper {
        @AuraEnabled public string productName {get;set;}
        @AuraEnabled public string productID {get;set;}
        @AuraEnabled public string productRecTypeID {get;set;} //DFOR-1506
        @AuraEnabled public string promoID{get;set;}
        @AuraEnabled public String promoTerr{get;set;} //DFOR-1379
        @AuraEnabled public string id{get;set;}
        @AuraEnabled public String startDate{get;set;}
        @AuraEnabled public String endDate{get;set;}
        @AuraEnabled public Date tprStart{get;set;}
        @AuraEnabled public Date tprEnd{get;set;}
        @AuraEnabled public string collStartDate{get;set;}
        @AuraEnabled public string collEndDate{get;set;}
        @AuraEnabled public string usESTSDTPRID{get;set;}
        @AuraEnabled public string usESTHDTPRID{get;set;}
        @AuraEnabled public string usESTUHDTPRID{get;set;}
        @AuraEnabled public string usEST3DTPRID{get;set;}
        @AuraEnabled public string caESTSDTPRID{get;set;}
        @AuraEnabled public string caESTHDTPRID{get;set;}
        @AuraEnabled public string caESTUHDTPRID{get;set;}
        @AuraEnabled public string caEST3DTPRID{get;set;}
        @AuraEnabled public string usVODSDTPRID{get;set;}
        @AuraEnabled public string usVODHDTPRID{get;set;}
        @AuraEnabled public string usVODUHDTPRID{get;set;}
        @AuraEnabled public string usVOD3DTPRID{get;set;}
        @AuraEnabled public string caVODSDTPRID{get;set;}
        @AuraEnabled public string caVODHDTPRID{get;set;}
        @AuraEnabled public string caVODUHDTPRID{get;set;}
        @AuraEnabled public string caVOD3DTPRID{get;set;}
        @AuraEnabled public string usESTSDTPRiTunesID{get;set;}
        @AuraEnabled public string usESTHDTPRiTunesID{get;set;}
        @AuraEnabled public string usESTUHDTPRiTunesID{get;set;}
        @AuraEnabled public string usEST3DTPRiTunesID{get;set;}
        @AuraEnabled public string caESTSDTPRiTunesID{get;set;}
        @AuraEnabled public string caESTHDTPRiTunesID{get;set;}
        @AuraEnabled public string caESTUHDTPRiTunesID{get;set;}
        @AuraEnabled public string caEST3DTPRiTunesID{get;set;}
        //est 
        @AuraEnabled public string usESTSDWSP{get;set;}
        @AuraEnabled public string usESTSDSRP{get;set;}
        @AuraEnabled public string usESTSDWSPTPR{get;set;}
        @AuraEnabled public string usESTSDSRPTPR{get;set;}
        @AuraEnabled public string usESTHDWSP{get;set;}
        @AuraEnabled public string usESTHDSRP{get;set;}
        @AuraEnabled public string usESTHDWSPTPR{get;set;}
        @AuraEnabled public string usESTHDSRPTPR{get;set;}
        @AuraEnabled public string caESTSDWSP{get;set;}
        @AuraEnabled public string caESTSDSRP{get;set;}
        @AuraEnabled public string caESTSDWSPTPR{get;set;}
        @AuraEnabled public string caESTSDSRPTPR{get;set;}
        @AuraEnabled public string caESTHDWSP{get;set;}
        @AuraEnabled public string caESTHDSRP{get;set;}
        @AuraEnabled public string caESTHDWSPTPR{get;set;}
        @AuraEnabled public string caESTHDSRPTPR{get;set;}
        @AuraEnabled public string usESTUHDWSP{get;set;}
        @AuraEnabled public string usESTUHDSRP{get;set;}
        @AuraEnabled public string usESTUHDWSPTPR{get;set;}
        @AuraEnabled public string usESTUHDSRPTPR{get;set;}
        @AuraEnabled public string usEST3DWSP{get;set;}
        @AuraEnabled public string usEST3DSRP{get;set;}
        @AuraEnabled public string usEST3DWSPTPR{get;set;}
        @AuraEnabled public string usEST3DSRPTPR{get;set;}
        @AuraEnabled public string caESTUHDWSP{get;set;}
        @AuraEnabled public string caESTUHDSRP{get;set;}
        @AuraEnabled public string caESTUHDWSPTPR{get;set;}
        @AuraEnabled public string caESTUHDSRPTPR{get;set;}
        @AuraEnabled public string caEST3DWSP{get;set;}
        @AuraEnabled public string caEST3DSRP{get;set;}
        @AuraEnabled public string caEST3DWSPTPR{get;set;}
        @AuraEnabled public string caEST3DSRPTPR{get;set;}
        
        //vod
        @AuraEnabled public string usVODSDWSP{get;set;}
        @AuraEnabled public string usVODSDSRP{get;set;}
        @AuraEnabled public string usVODSDWSPTPR{get;set;}
        @AuraEnabled public string usVODSDSRPTPR{get;set;}
        @AuraEnabled public string usVODHDWSP{get;set;}
        @AuraEnabled public string usVODHDSRP{get;set;}
        @AuraEnabled public string usVODHDWSPTPR{get;set;}
        @AuraEnabled public string usVODHDSRPTPR{get;set;}
        @AuraEnabled public string caVODSDWSP{get;set;}
        @AuraEnabled public string caVODSDSRP{get;set;}
        @AuraEnabled public string caVODSDWSPTPR{get;set;}
        @AuraEnabled public string caVODSDSRPTPR{get;set;}
        @AuraEnabled public string caVODHDWSP{get;set;}
        @AuraEnabled public string caVODHDSRP{get;set;}
        @AuraEnabled public string caVODHDWSPTPR{get;set;}
        @AuraEnabled public string caVODHDSRPTPR{get;set;}
        @AuraEnabled public string usVODUHDWSP{get;set;}
        @AuraEnabled public string usVODUHDSRP{get;set;}
        @AuraEnabled public string usVODUHDWSPTPR{get;set;}
        @AuraEnabled public string usVODUHDSRPTPR{get;set;}
        @AuraEnabled public string usVOD3DWSP{get;set;}
        @AuraEnabled public string usVOD3DSRP{get;set;}
        @AuraEnabled public string usVOD3DWSPTPR{get;set;}
        @AuraEnabled public string usVOD3DSRPTPR{get;set;}
        @AuraEnabled public string caVODUHDWSP{get;set;}
        @AuraEnabled public string caVODUHDSRP{get;set;}
        @AuraEnabled public string caVODUHDWSPTPR{get;set;}
        @AuraEnabled public string caVODUHDSRPTPR{get;set;}
        @AuraEnabled public string caVOD3DWSP{get;set;}
        @AuraEnabled public string caVOD3DSRP{get;set;}
        @AuraEnabled public string caVOD3DWSPTPR{get;set;}
        @AuraEnabled public string caVOD3DSRPTPR{get;set;}
        
        //est itunes
        @AuraEnabled public string usESTSDWSP_iTunes{get;set;}
        @AuraEnabled public string usESTSDSRP_iTunes{get;set;}
        @AuraEnabled public string usESTSDWSPTPR_iTunes{get;set;}
        @AuraEnabled public string usESTSDSRPTPR_iTunes{get;set;}
        @AuraEnabled public string usESTHDWSP_iTunes{get;set;}
        @AuraEnabled public string usESTHDSRP_iTunes{get;set;}
        @AuraEnabled public string usESTHDWSPTPR_iTunes{get;set;}
        @AuraEnabled public string usESTHDSRPTPR_iTunes{get;set;}
        @AuraEnabled public string caESTSDWSP_iTunes{get;set;}
        @AuraEnabled public string caESTSDSRP_iTunes{get;set;}
        @AuraEnabled public string caESTSDWSPTPR_iTunes{get;set;}
        @AuraEnabled public string caESTSDSRPTPR_iTunes{get;set;}
        @AuraEnabled public string caESTHDWSP_iTunes{get;set;}
        @AuraEnabled public string caESTHDSRP_iTunes{get;set;}
        @AuraEnabled public string caESTHDWSPTPR_iTunes{get;set;}
        @AuraEnabled public string caESTHDSRPTPR_iTunes{get;set;}
        @AuraEnabled public string usESTUHDWSP_iTunes{get;set;}
        @AuraEnabled public string usESTUHDSRP_iTunes{get;set;}
        @AuraEnabled public string usESTUHDWSPTPR_iTunes{get;set;}
        @AuraEnabled public string usESTUHDSRPTPR_iTunes{get;set;}
        @AuraEnabled public string usEST3DWSP_iTunes{get;set;}
        @AuraEnabled public string usEST3DSRP_iTunes{get;set;}
        @AuraEnabled public string usEST3DWSPTPR_iTunes{get;set;}
        @AuraEnabled public string usEST3DSRPTPR_iTunes{get;set;}
        @AuraEnabled public string caESTUHDWSP_iTunes{get;set;}
        @AuraEnabled public string caESTUHDSRP_iTunes{get;set;}
        @AuraEnabled public string caESTUHDWSPTPR_iTunes{get;set;}
        @AuraEnabled public string caESTUHDSRPTPR_iTunes{get;set;}
        @AuraEnabled public string caEST3DWSP_iTunes{get;set;}
        @AuraEnabled public string caEST3DSRP_iTunes{get;set;}
        @AuraEnabled public string caEST3DWSPTPR_iTunes{get;set;}
        @AuraEnabled public string caEST3DSRPTPR_iTunes{get;set;}
        
        //iTunes tier
        @AuraEnabled public String  USSDiTunesTier{get;set;}
        @AuraEnabled public String  USSDiTunesTierTPR{get;set;}
        @AuraEnabled public String  USHDiTunesTier{get;set;}
        @AuraEnabled public String  USHDiTunesTierTPR{get;set;}
        @AuraEnabled public String  CASDiTunesTier{get;set;}
        @AuraEnabled public String  CASDiTunesTierTPR{get;set;}
        @AuraEnabled public String  CAHDiTunesTier{get;set;}
        @AuraEnabled public String  CAHDiTunesTierTPR{get;set;}
        @AuraEnabled public String edited{get;set;}
        @AuraEnabled public Boolean dateChanged{get;set;}
        @AuraEnabled public Promotion_Product__c pp{get;set;}
        // 1/9/2019
        @AuraEnabled public String startEndDiff{get;set;}
        
        public ProductPricingWrapper() {
            dateChanged = false;
            usESTSDWSP = 'N/A';
            usESTSDSRP = 'N/A';
            usESTHDWSP = 'N/A';
            usESTHDSRP = 'N/A';
            usESTUHDWSP = 'N/A';
            usESTUHDSRP = 'N/A';
            usEST3DWSP = 'N/A';
            usEST3DSRP = 'N/A';
            usESTSDWSP_iTunes = 'N/A';
            usESTSDSRP_iTunes = 'N/A';
            usESTHDWSP_iTunes = 'N/A';
            usESTHDSRP_iTunes = 'N/A';
            usESTUHDWSP_iTunes = 'N/A';
            usESTUHDSRP_iTunes = 'N/A';
            usEST3DWSP_iTunes = 'N/A';
            usEST3DSRP_iTunes = 'N/A';
            caESTSDWSP = 'N/A';
            caESTSDSRP = 'N/A';
            caESTHDWSP = 'N/A';
            caESTHDSRP = 'N/A';
            caESTUHDWSP = 'N/A';
            caESTUHDSRP = 'N/A';
            caEST3DWSP = 'N/A';
            caEST3DSRP = 'N/A';
            caESTSDWSP_iTunes = 'N/A';
            caESTSDSRP_iTunes = 'N/A';
            caESTHDWSP_iTunes = 'N/A';
            caESTHDSRP_iTunes = 'N/A';
            caESTUHDWSP_iTunes = 'N/A';
            caESTUHDSRP_iTunes = 'N/A';
            caEST3DWSP_iTunes = 'N/A';
            caEST3DSRP_iTunes = 'N/A';
            usVODSDWSP = 'N/A';
            usVODSDSRP = 'N/A';
            usVODHDWSP = 'N/A';
            usVODHDSRP = 'N/A';
            usVODUHDWSP = 'N/A';
            usVODUHDSRP = 'N/A';
            usVOD3DWSP = 'N/A';
            usVOD3DSRP = 'N/A';
            caVODUHDWSP = 'N/A';
            caVODUHDSRP = 'N/A';
            caVOD3DWSP = 'N/A';
            caVOD3DSRP = 'N/A';
            caVODSDWSP ='N/A';
            caVODSDSRP = 'N/A';
            caVODHDWSP = 'N/A';
            caVODHDSRP = 'N/A';
            USSDiTunesTier = 'N/A';
            USSDiTunesTierTPR = 'N/A';
            USHDiTunesTier = 'N/A';
            USHDiTunesTierTPR = 'N/A';
            CASDiTunesTier = 'N/A';
            CASDiTunesTierTPR = 'N/A';
            CAHDiTunesTier = 'N/A';
            CAHDiTunesTierTPR = 'N/A';
            usESTSDWSPTPR_iTunes = 'N/A';
            usESTHDWSPTPR_iTunes = 'N/A';
            caESTSDWSPTPR_iTunes = 'N/A';
            caESTHDWSPTPR_iTunes = 'N/A';
            usESTUHDWSPTPR_iTunes = 'N/A';
            usEST3DWSPTPR_iTunes = 'N/A';
            caESTUHDWSPTPR_iTunes = 'N/A';
            caEST3DWSPTPR_iTunes = 'N/A';
            startEndDiff = 'N/A';
        }
    }
    /***********************************
    Method Name: setDefaultWrapperValues
    Purpose: method to set default values in wrapper
    ***********************************/   
    @AuraEnabled public static void setDefaultWrapperValues(Promotion_Product__c promotionProd, ProductPricingWrapper pw,Product__c prod) {
        Id FreeEpisodeId = Schema.SObjectType.Promotion__c.getRecordTypeInfosByName().get(DGF_Constants.FREE_EPISODE).getRecordTypeId();
        if(prod.US_Platform_offering__c == null || promotionProd.Promotion__r.recordTypeId == FreeEpisodeId ) {
            pw.usESTSDWSPTPR = 'N/A';
            pw.usESTSDSRPTPR = 'N/A';
            pw.usESTHDWSPTPR = 'N/A';
            pw.usESTHDSRPTPR = 'N/A';
            pw.usESTUHDWSPTPR = 'N/A';
            pw.usESTUHDSRPTPR = 'N/A';
            pw.usEST3DWSPTPR = 'N/A';
            pw.usEST3DSRPTPR = 'N/A';
            pw.usESTSDWSPTPR_iTunes = 'N/A';
            pw.usESTSDSRPTPR_iTunes = 'N/A';
            pw.usESTHDWSPTPR_iTunes = 'N/A';
            pw.usESTHDSRPTPR_iTunes = 'N/A';
            pw.usESTUHDWSPTPR_iTunes = 'N/A';
            pw.usESTUHDSRPTPR_iTunes = 'N/A';
            pw.usEST3DWSPTPR_iTunes = 'N/A';
            pw.usEST3DSRPTPR_iTunes = 'N/A';
            pw.usVODSDWSPTPR = 'N/A';
            pw.usVODSDSRPTPR = 'N/A';
            pw.usVODHDWSPTPR = 'N/A';
            pw.usVODHDSRPTPR = 'N/A';
            pw.usVODUHDWSPTPR = 'N/A';
            pw.usVODUHDSRPTPR = 'N/A';
            pw.usVOD3DWSPTPR = 'N/A';
            pw.usVOD3DSRPTPR = 'N/A';
        }
        //if US Platform Offering is selected
        else if(prod.US_Platform_offering__c != null || promotionProd.Promotion__r.recordTypeId != FreeEpisodeId) {
            //if only EST is selected set VOD TPR Prices to N/A
            if(prod.US_Platform_offering__c.contains(DGF_Constants.PLATFORM_EST) && !prod.US_Platform_offering__c.contains(DGF_Constants.PLATFORM_VOD)) {
                pw.usVODSDWSPTPR = 'N/A';
                pw.usVODSDSRPTPR = 'N/A';
                pw.usVODHDWSPTPR = 'N/A';
                pw.usVODHDSRPTPR = 'N/A';
                pw.usVODUHDWSPTPR = 'N/A';
                pw.usVODUHDSRPTPR = 'N/A';
                pw.usVOD3DWSPTPR = 'N/A';
                pw.usVOD3DSRPTPR = 'N/A';
            }
            if(!prod.SD__c) {
                pw.usESTSDWSPTPR = 'N/A';
                pw.usESTSDSRPTPR = 'N/A';
                pw.usESTSDWSPTPR_iTunes = 'N/A';
                pw.usESTSDSRPTPR_iTunes = 'N/A';
            }
            if(!prod.HD__c) {
                pw.usESTHDWSPTPR = 'N/A';
                pw.usESTHDSRPTPR = 'N/A';
                pw.usESTHDWSPTPR_iTunes = 'N/A';
                pw.usESTHDSRPTPR_iTunes = 'N/A';
            }
            if(!prod.UHD__c) {
                pw.usESTUHDWSPTPR = 'N/A';
                pw.usESTUHDSRPTPR = 'N/A';
                pw.usESTUHDSRPTPR_iTunes = 'N/A';
                pw.usESTUHDWSPTPR_iTunes = 'N/A';
            }
            if(!prod.X3D__c) {
                pw.usEST3DWSPTPR = 'N/A';
                pw.usEST3DSRPTPR = 'N/A';
                pw.usEST3DWSPTPR_iTunes = 'N/A';
                pw.usEST3DSRPTPR_iTunes = 'N/A';  
            }
            
            //if only VOD is selected set EST TPR Prices to N/A
            if(prod.US_Platform_offering__c.contains(DGF_Constants.PLATFORM_VOD) && !prod.US_Platform_offering__c.contains(DGF_Constants.PLATFORM_EST)) {
                pw.usESTSDWSPTPR = 'N/A';
                pw.usESTSDSRPTPR = 'N/A';
                pw.usESTHDWSPTPR = 'N/A';
                pw.usESTHDSRPTPR = 'N/A';
                pw.usESTUHDWSPTPR = 'N/A';
                pw.usESTUHDSRPTPR = 'N/A';
                pw.usEST3DWSPTPR = 'N/A';
                pw.usEST3DSRPTPR = 'N/A';
                pw.usESTSDWSPTPR_iTunes = 'N/A';
                pw.usESTSDSRPTPR_iTunes = 'N/A';
                pw.usESTHDWSPTPR_iTunes = 'N/A';
                pw.usESTHDSRPTPR_iTunes = 'N/A';
                pw.usESTUHDWSPTPR_iTunes = 'N/A';
                pw.usESTUHDSRPTPR_iTunes = 'N/A';
                pw.usEST3DWSPTPR_iTunes = 'N/A';
                pw.usEST3DSRPTPR_iTunes = 'N/A';
            }
            if(!prod.SD__c) {
                pw.usVODSDWSPTPR = 'N/A';
                pw.usVODSDSRPTPR = 'N/A';
            }
            if(!prod.HD__c) {
                pw.usVODHDWSPTPR = 'N/A';
                pw.usVODHDSRPTPR = 'N/A';
            }
            if(!prod.UHD__c) {
                pw.usVODUHDWSPTPR = 'N/A';
                pw.usVODUHDSRPTPR = 'N/A';
            }
            if(!prod.X3D__c) {
                pw.usVOD3DWSPTPR = 'N/A';
                pw.usVOD3DSRPTPR = 'N/A';
            }
        }
        //if CA Platform offerig is null, set all CA TPR Prices to N/A
        if(prod.CA_Platform_offering__c == null || promotionProd.Promotion__r.recordTypeId == FreeEpisodeId) {
            pw.caESTSDWSPTPR = 'N/A';
            pw.caESTSDSRPTPR = 'N/A';
            pw.caESTHDWSPTPR = 'N/A';
            pw.caESTHDSRPTPR = 'N/A';
            pw.caESTUHDWSPTPR = 'N/A';
            pw.caESTUHDSRPTPR = 'N/A';
            pw.caEST3DWSPTPR = 'N/A';
            pw.caEST3DSRPTPR = 'N/A';
            pw.caESTSDWSPTPR_iTunes = 'N/A';
            pw.caESTSDSRPTPR_iTunes = 'N/A';
            pw.caESTHDWSPTPR_iTunes = 'N/A';
            pw.caESTHDSRPTPR_iTunes = 'N/A';
            pw.caESTUHDWSPTPR_iTunes = 'N/A';
            pw.caESTUHDSRPTPR_iTunes = 'N/A';
            pw.caEST3DWSPTPR_iTunes = 'N/A';
            pw.caEST3DSRPTPR_iTunes = 'N/A';
            pw.caVODSDWSPTPR = 'N/A';
            pw.caVODSDSRPTPR = 'N/A';
            pw.caVODHDWSPTPR = 'N/A';
            pw.caVODHDSRPTPR = 'N/A';
            pw.caVODUHDWSPTPR = 'N/A';
            pw.caVODUHDSRPTPR = 'N/A';
            pw.caVOD3DWSPTPR = 'N/A';
            pw.caVOD3DSRPTPR = 'N/A';
        }
        //if CA platform offering is selected
        else if(prod.CA_Platform_offering__c != null || promotionProd.Promotion__r.recordTypeId != FreeEpisodeId) {
            //if only EST is selected then set VOD TPR Prices to NA
            if(prod.CA_Platform_offering__c.contains(DGF_Constants.PLATFORM_EST) && !prod.CA_Platform_offering__c.contains(DGF_Constants.PLATFORM_VOD)) {
                pw.caVODSDWSPTPR = 'N/A';
                pw.caVODSDSRPTPR = 'N/A';
                pw.caVODHDWSPTPR = 'N/A';
                pw.caVODHDSRPTPR = 'N/A';
                pw.caVODUHDWSPTPR = 'N/A';
                pw.caVODUHDSRPTPR = 'N/A';
                pw.caVOD3DWSPTPR = 'N/A';
                pw.caVOD3DSRPTPR = 'N/A';
            }
            if(!prod.SD__c) {
                pw.caESTSDWSPTPR = 'N/A';
                pw.caESTSDSRPTPR = 'N/A';
                pw.caESTSDWSPTPR_iTunes = 'N/A';
                pw.caESTSDSRPTPR_iTunes = 'N/A';
            }
            if(!prod.HD__c) {
                pw.caESTHDWSPTPR = 'N/A';
                pw.caESTHDSRPTPR = 'N/A';
                pw.caESTHDWSPTPR_iTunes = 'N/A';
                pw.caESTHDSRPTPR_iTunes = 'N/A';
            }
            if(!prod.UHD__c) {
                pw.caESTUHDWSPTPR = 'N/A';
                pw.caESTUHDSRPTPR = 'N/A';
                pw.caESTUHDSRPTPR_iTunes = 'N/A';
                pw.caESTUHDWSPTPR_iTunes = 'N/A';
            }
            if(!prod.X3D__c) {
                pw.caEST3DWSPTPR = 'N/A';
                pw.caEST3DSRPTPR = 'N/A';
                pw.caEST3DWSPTPR_iTunes = 'N/A';
                pw.caEST3DSRPTPR_iTunes = 'N/A';
            }
            
            //if only VOD is selected then set EST TPR Prices to NA
            if(prod.CA_Platform_offering__c.contains(DGF_Constants.PLATFORM_VOD) && !prod.CA_Platform_offering__c.contains(DGF_Constants.PLATFORM_EST)) {
                pw.caESTSDWSPTPR = 'N/A';
                pw.caESTSDSRPTPR = 'N/A';
                pw.caESTHDWSPTPR = 'N/A';
                pw.caESTHDSRPTPR = 'N/A';
                pw.caESTUHDWSPTPR = 'N/A';
                pw.caESTUHDSRPTPR = 'N/A';
                pw.caEST3DWSPTPR = 'N/A';
                pw.caEST3DSRPTPR = 'N/A';
                pw.caESTSDWSPTPR_iTunes = 'N/A';
                pw.caESTSDSRPTPR_iTunes = 'N/A';
                pw.caESTHDWSPTPR_iTunes = 'N/A';
                pw.caESTHDSRPTPR_iTunes = 'N/A';
                pw.caESTUHDWSPTPR_iTunes = 'N/A';
                pw.caESTUHDSRPTPR_iTunes = 'N/A';
                pw.caEST3DWSPTPR_iTunes = 'N/A';
                pw.caEST3DSRPTPR_iTunes = 'N/A';
            }
            if(!prod.SD__c) {
                pw.caVODSDWSPTPR = 'N/A';
                pw.caVODSDSRPTPR = 'N/A';
            }
            if(!prod.HD__c) {
                pw.caVODHDWSPTPR = 'N/A';
                pw.caVODHDSRPTPR = 'N/A';
            }
            if(!prod.UHD__c) {
                pw.caVODUHDWSPTPR = 'N/A';
                pw.caVODUHDSRPTPR = 'N/A';
            }
            if(!prod.X3D__c) {
                pw.caVOD3DWSPTPR = 'N/A';
                pw.caVOD3DSRPTPR = 'N/A';
            }
        }
    }
    
    /***********************************
    Method Name: stampWrapperValues
    Purpose: method to stamp the WSP and SRP Values in the wrapper
    ***********************************/   
    @AuraEnabled public static void stampWrapperValues(ProductPricingWrapper pw,Pricing__c pr,Promotion_product__c promotionProd) {
        if((pr.price_type__c == DGF_Constants.ORIGINAL || pr.price_type__c == DGF_Constants.REPRICE) ) {
            //for resolution SD
            if(pr.Resolution__c == DGF_Constants.SD   &&  ( pr.Valid_From__c < promotionProd.TPR_End_Date__c && (pr.Valid_To__c >= promotionProd.TPR_End_Date__c || pr.Valid_To__c == null)) ) {
                if(pr.territory__c == DGF_Constants.TERRITORY_US) {
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST ) {
                       if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.usESTSDWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.usESTSDSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                        }
                        else {
                            
                            pw.usESTSDWSP_iTunes = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.usESTSDSRP_iTunes = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                            pw.USSDiTunesTier = (String.valueOf(pr.iTunes_Tier__c) != null)?String.valueOf(pr.iTunes_Tier__c):'N/A';
                        }
                    }
                    else {
                        pw.usVODSDWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                        pw.USVODSDSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                    }
                }
                else {
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                        if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.caESTSDWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.caESTSDSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                        }
                        else {
                            pw.caESTSDWSP_iTunes = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.caESTSDSRP_iTunes = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                            pw.CASDiTunesTier = (String.valueOf(pr.iTunes_Tier__c) != null)?String.valueOf(pr.iTunes_Tier__c):'N/A';
                        }
                    }
                    else { 
                        pw.caVODSDWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                        pw.caVODSDSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                    }
                }
            }
            //for resolution HD
            else if(pr.Resolution__c == DGF_Constants.HD    &&  ( pr.Valid_From__c < promotionProd.TPR_End_Date__c && (pr.Valid_To__c >= promotionProd.TPR_End_Date__c || pr.Valid_To__c == null))) {
                if(pr.territory__c == DGF_Constants.TERRITORY_US) {
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                        if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.usESTHDWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.usESTHDSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                        }
                        else {
                            pw.usESTHDWSP_iTunes = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.usESTHDSRP_iTunes = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                            pw.USHDiTunesTier = (String.valueOf(pr.iTunes_Tier__c) != null)?String.valueOf(pr.iTunes_Tier__c):'N/A';
                        }
                    }
                    else {
                        pw.usVODHDWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                        pw.usVODHDSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                    }
                }
                else{
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                        if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.caESTHDWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.caESTHDSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                        }
                        else {
                            pw.caESTHDWSP_iTunes = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.caESTHDSRP_iTunes = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                            pw.CAHDiTunesTier = (String.valueOf(pr.iTunes_Tier__c) != null)?String.valueOf(pr.iTunes_Tier__c):'N/A';
                        }
                    }
                    else {
                        pw.caVODHDWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                        pw.caVODHDSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                    }
                }
            }
            // for UHD
            else if(pr.Resolution__c == DGF_Constants.UHD  &&  ( pr.Valid_From__c < promotionProd.TPR_End_Date__c && 
            (pr.Valid_To__c >= promotionProd.TPR_End_Date__c || pr.Valid_To__c == null))) {
                if(pr.territory__c == DGF_Constants.TERRITORY_US) {
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                        if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.usESTUHDWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.usESTUHDSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                        }
                        else {
                            pw.usESTUHDWSP_iTunes = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.usESTUHDSRP_iTunes = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                        }
                    }
                    else {
                        pw.usVODUHDWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                        pw.usVODUHDSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                    }
                }
                else {
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                        if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.caESTUHDWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            
                            pw.caESTUHDSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                        }
                        else {
                            pw.caESTUHDWSP_iTunes = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.caESTUHDSRP_iTunes = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                        }
                    }
                    else {
                        pw.caVODUHDWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                        pw.caVODUHDSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                    }
                }
            }
            //for 3D
            else if(pr.Resolution__c == DGF_Constants.X3D  &&  ( pr.Valid_From__c < promotionProd.TPR_End_Date__c && 
             (pr.Valid_To__c >= promotionProd.TPR_End_Date__c || pr.Valid_To__c == null))) {
                if(pr.territory__c == DGF_Constants.TERRITORY_US) {
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                        if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.usEST3DWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.usEST3DSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                        }
                        else {
                            pw.usEST3DWSP_iTunes = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.usEST3DSRP_iTunes = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                        }
                    }
                    else {
                        pw.usVOD3DWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                        pw.usVOD3DSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                    }
                }
                else {
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                        if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.caEST3DWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.caEST3DSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                        }
                        else {
                            pw.caEST3DWSP_iTunes = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.caEST3DSRP_iTunes = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                        }
                    }
                    else {
                        pw.caVOD3DWSP = (pr.WSP__c != null)?'$'+String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                        pw.caVOD3DSRP = (pr.SRP__c != null)?'$'+String.valueOf((pr.SRP__c).setScale(2)): 'N/A';
                    }
                }
            }
            
            
        }
        
        //get the prices for the TPR records 
        else if((pr.price_type__c == DGF_Constants.TPR_National || pr.price_type__c == DGF_Constants.TPR_Account) && 
                pr.promotion__c == promotionProd.Promotion__c) {
            //for SD
            if(pr.Resolution__c == DGF_Constants.SD ) {
                if(pr.territory__c == DGF_Constants.TERRITORY_US) {
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                        if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.usESTSDWSPTPR = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)):null;
                            pw.usESTSDSRPTPR = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.usESTSDTPRID = pr.id;
                        }
                        else {
                            pw.usESTSDWSPTPR_iTunes = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.usESTSDSRPTPR_iTunes = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.usESTSDTPRiTunesID = pr.id;
                            pw.USSDiTunesTierTPR = (String.valueOf(pr.iTunes_Tier__c) != null)?String.valueOf(pr.iTunes_Tier__c):'N/A';
                        }
                        
                    }
                    else {
                        pw.usVODSDWSPTPR = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): null;
                        pw.USVODSDSRPTPR = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                        pw.USVODSDTPRID = pr.id;
                    }
                }
                else {
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                        if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.caESTSDWSPTPR = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): null;
                            pw.caESTSDSRPTPR = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.caESTSDTPRID = pr.id;
                        }
                        else {
                            pw.caESTSDWSPTPR_iTunes = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.caESTSDSRPTPR_iTunes = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.caESTSDTPRiTunesId = pr.id;
                            pw.CASDiTunesTierTPR = (String.valueOf(pr.iTunes_Tier__c) != null)?String.valueOf(pr.iTunes_Tier__c):'N/A';
                        }
                    }
                    else {
                        pw.caVODSDWSPTPR = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): null;
                        pw.caVODSDSRPTPR = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                        pw.caVODSDTPRID = pr.id;
                    }
                }
            }
            //for HD
            else if(pr.Resolution__c == DGF_Constants.HD) {
                if(pr.territory__c == DGF_Constants.TERRITORY_US) {
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                        if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.usESTHDWSPTPR = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): null;
                            pw.usESTHDSRPTPR = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.usESTHDTPRID = pr.id;
                        }
                        else {
                            pw.usESTHDWSPTPR_iTunes = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.usESTHDSRPTPR_iTunes = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.usESTHDTPRiTunesID = pr.id;
                            pw.USHDiTunesTierTPR = (String.valueOf(pr.iTunes_Tier__c) != null)?String.valueOf(pr.iTunes_Tier__c):'N/A';
                        }
                    }
                    else {
                        pw.usVODHDWSPTPR = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): null;
                        pw.usVODHDSRPTPR = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                        pw.usVODHDTPRID = pr.id;
                    }
                }
                else {
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                        if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.caESTHDWSPTPR = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): null;
                            pw.caESTHDSRPTPR = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.caESTHDTPRID = pr.id;
                        }
                        else {
                            pw.caESTHDWSPTPR_iTunes = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.caESTHDSRPTPR_iTunes = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.caESTHDTPRiTunesID = pr.id;
                            pw.CAHDiTunesTierTPR = (String.valueOf(pr.iTunes_Tier__c) != null)?String.valueOf(pr.iTunes_Tier__c):'N/A';
                        }
                    }
                    else{
                        pw.caVODHDWSPTPR = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): null;
                        pw.caVODHDSRPTPR = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                        pw.caVODHDTPRId = pr.id;
                    }
                }
            }
            //for UHD
            else if(pr.Resolution__c == DGF_Constants.UHD ) {
                if(pr.territory__c == DGF_Constants.TERRITORY_US) {
                    
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                        if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.usESTUHDWSPTPR = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): null;
                            pw.usESTUHDSRPTPR = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.usESTUHDTPRID = pr.id;
                        }
                        else {
                            pw.usESTUHDWSPTPR_iTunes=(pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.usESTUHDSRPTPR_iTunes=(pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.usESTUHDTPRiTunesID=pr.id;
                        }
                    }
                    else {
                        pw.usVODUHDWSPTPR = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): null;
                        pw.usVODUHDSRPTPR = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                        pw.usVODUHDTPRID = pr.id;
                    }
                }
                else {
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                        if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.caESTUHDWSPTPR = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): null;
                            pw.caESTUHDSRPTPR = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.caESTUHDTPRID = pr.id;
                        }
                        else{
                            pw.caESTUHDWSPTPR_iTunes = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.caESTUHDSRPTPR_iTunes = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.caESTUHDTPRiTunesID = pr.id;
                        }
                    }
                    else {
                        pw.caVODUHDWSP = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): null;
                        pw.caVODUHDSRP = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                        pw.caVODUHDTPRID = pr.id;
                    }
                }
            }
            //for 3D
            else if(pr.Resolution__c == DGF_Constants.X3D) {
                if(pr.territory__c == DGF_Constants.TERRITORY_US) {
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                        if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.usEST3DWSPTPR = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): null;
                            pw.usEST3DSRPTPR = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.usEST3DTPRID = pr.id;
                        }
                        else {
                            pw.usEST3DWSPTPR_iTunes = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.usEST3DSRPTPR_iTunes = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.usEST3DTPRiTunesID = pr.id;
                        }
                    }
                    else {
                        pw.usVOD3DWSPTPR = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): null;
                        pw.usVOD3DSRPTPR = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                        pw.usVOD3DTPRID = pr.id;
                    }
                }
                else {
                    if(pr.platform__c == DGF_Constants.PLATFORM_EST) {
                        if( pr.Account__c != DGF_Constants.iTUNES) {
                            pw.caEST3DWSPTPR = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): null;
                            pw.caEST3DSRPTPR = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.caEST3DTPRID = pr.id;
                        }
                        else {
                            pw.caEST3DWSPTPR_iTunes = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): 'N/A';
                            pw.caEST3DSRPTPR_iTunes = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                            pw.caEST3DTPRiTunesID = pr.id;
                        }
                    }
                    else {
                        pw.caVOD3DWSPTPR = (pr.WSP__c != null)?String.valueOf((pr.WSP__c).setScale(2)): null;
                        pw.caVOD3DSRPTPR = (pr.SRP__c != null)?String.valueOf((pr.SRP__c).setScale(2)): null;
                        pw.caVOD3DTPRID = pr.id;
                    }
                }
            }                                        
        }
    }   
}