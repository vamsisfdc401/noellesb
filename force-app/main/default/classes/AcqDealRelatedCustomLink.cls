/*==========================================================================
Class Name: AcqDealRelatedCustomLink
Created By: Elavarasan 
Created Date: 04/03/2018 
Description: This AcqDealRelatedCustomLink class used to Custom related List Component.
====================================================================================================================*/
public class  AcqDealRelatedCustomLink
{
    //-------------------------------------------- PrimaryTerms-------------------------------------------------------------//    
    @AuraEnabled
    public static Id  getdealid(ID primarytermsId){
        
        Primary_Terms__c primaryItems = [SELECT Id, createddate, Acquisition_Deal__c, Board_Pack_Version__c FROM Primary_Terms__c WHERE Id =: primarytermsId];
        Acquisition_Deal__c acqDeal = [SELECT Id FROM Acquisition_Deal__c WHERE Id =: primaryItems.Acquisition_Deal__c];
        return(acqDeal.Id); 
    }
    
    @AuraEnabled
    public static Id  getFinancialsid(ID primarytermsFinId){
        Primary_Terms__c primaryItems = [SELECT Id,createddate,Acquisition_Deal__c,Board_Pack_Version__c FROM Primary_Terms__c WHERE Id =: primarytermsFinId]; 
        Financials__c financial = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Financials__c WHERE Board_Pack_Version__c =: primaryItems.Board_Pack_Version__c AND Acquisition_Deal__c =: primaryItems.Acquisition_Deal__c]; 
        return(financial.Id);
    }
    
    @AuraEnabled
    public static Id  getTitleid(ID primarytermsTitleId){
        Primary_Terms__c primaryItems = [SELECT Id,createddate,Acquisition_Deal__c,Board_Pack_Version__c FROM Primary_Terms__c WHERE Id =: primarytermsTitleId];
        Title__c title = [SELECT Id,LAQ_Acquisition_Deal__c,LAQ_Board_Pack_Version__c FROM Title__c  WHERE LAQ_Board_Pack_Version__c =: primaryItems.Board_Pack_Version__c AND LAQ_Acquisition_Deal__c =: primaryItems.Acquisition_Deal__c];
        return(title.id);
    }
    
    @AuraEnabled
    public static Id  getcompsid(ID primarytermscompsId){
        Primary_Terms__c primaryItems = [SELECT Id,createddate,Acquisition_Deal__c,Board_Pack_Version__c FROM Primary_Terms__c WHERE Id =: primarytermscompsId];
        Comps__c comps = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Comps__c WHERE Board_Pack_Version__c =: primaryItems.Board_Pack_Version__c AND Acquisition_Deal__c =: primaryItems.Acquisition_Deal__c];
        return(comps.Id);
    }
    
    @AuraEnabled
    public static Id  getRiskid(ID primarytermsRiskId){
        Primary_Terms__c primaryItems = [SELECT Id,createddate,Acquisition_Deal__c,Board_Pack_Version__c FROM Primary_Terms__c WHERE Id =: primarytermsRiskId];
        Risk_Compliance__c riskComp = [SELECT Id,Acquisition_Deal__c,Board_Pack_Version__c FROM Risk_Compliance__c WHERE Board_Pack_Version__c =: primaryItems.Board_Pack_Version__c AND Acquisition_Deal__c =: primaryItems.Acquisition_Deal__c];
        return(riskComp.Id);
    }
    
    //-------------------------------------------- Title-------------------------------------------------------------// 
    
    @AuraEnabled
    public static Id  getdealidtitle(ID primarytermsId){
        
        Title__c Title = [SELECT Id, createddate, LAQ_Acquisition_Deal__c, LAQ_Board_Pack_Version__c FROM Title__c WHERE Id =: primarytermsId];
        Acquisition_Deal__c acqDeal = [SELECT Id FROM Acquisition_Deal__c WHERE Id =: Title.LAQ_Acquisition_Deal__c];
        return(acqDeal.Id); 
    }
    
    @AuraEnabled
    public static Id  getFinancialsidtitle(ID primarytermsFinId){
        Title__c Title = [SELECT Id, createddate, LAQ_Acquisition_Deal__c, LAQ_Board_Pack_Version__c FROM Title__c WHERE Id =: primarytermsFinId];
        Financials__c financial = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Financials__c WHERE Board_Pack_Version__c =: Title.LAQ_Board_Pack_Version__c  AND Acquisition_Deal__c =: Title.LAQ_Acquisition_Deal__c]; 
        return(financial.Id);
    }
    
    @AuraEnabled
    public static Id  getprimaryidtitle(ID primarytermsprimaryId){
        Title__c Title = [SELECT Id, createddate, LAQ_Acquisition_Deal__c, LAQ_Board_Pack_Version__c FROM Title__c WHERE Id =: primarytermsprimaryId];
        Primary_Terms__c primaryItems = [SELECT Id,createddate,Acquisition_Deal__c,Board_Pack_Version__c FROM Primary_Terms__c WHERE Acquisition_Deal__c =:Title.LAQ_Acquisition_Deal__c AND Board_Pack_Version__c=:Title.LAQ_Board_Pack_Version__c];
        return(primaryItems.id);
    }
    
    @AuraEnabled
    public static Id  getcompsidtitle(ID primarytermscompsId){
        Title__c Title = [SELECT Id, createddate, LAQ_Acquisition_Deal__c, LAQ_Board_Pack_Version__c FROM Title__c WHERE Id =: primarytermscompsId];
        Comps__c comps = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Comps__c WHERE Board_Pack_Version__c =: Title.LAQ_Board_Pack_Version__c AND Acquisition_Deal__c =: Title.LAQ_Acquisition_Deal__c];
        return(comps.Id);
    }
    
    @AuraEnabled
    public static Id  getRiskidtitle(ID primarytermsRiskId){
        Title__c Title = [SELECT Id, createddate, LAQ_Acquisition_Deal__c, LAQ_Board_Pack_Version__c FROM Title__c WHERE Id =: primarytermsRiskId];
        Risk_Compliance__c riskComp = [SELECT Id,Acquisition_Deal__c,Board_Pack_Version__c FROM Risk_Compliance__c WHERE Board_Pack_Version__c =: Title.LAQ_Board_Pack_Version__c AND Acquisition_Deal__c =: Title.LAQ_Acquisition_Deal__c];
        return(riskComp.Id);
    } 
    //-------------------------------------------- Financials-------------------------------------------------------------//
    @AuraEnabled
    public static Id  getdealidfinancial(ID primarytermsId){
        
        Financials__c financial = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Financials__c WHERE Id=:primarytermsId]; 
        Acquisition_Deal__c acqDeal = [SELECT Id FROM Acquisition_Deal__c WHERE Id =: financial.Acquisition_Deal__c];
        return(acqDeal.Id); 
    }
    
    @AuraEnabled
    public static Id  gettitleidfinancial(ID primarytermsTitleId){
        Financials__c financial = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Financials__c WHERE Id=:primarytermsTitleId];
        Title__c Title = [SELECT Id, createddate, LAQ_Acquisition_Deal__c, LAQ_Board_Pack_Version__c FROM Title__c WHERE LAQ_Board_Pack_Version__c=: financial.Board_Pack_Version__c AND LAQ_Acquisition_Deal__c=:financial.Acquisition_Deal__c]; 
        return(Title.Id);
    }
    
    @AuraEnabled
    public static Id  getprimaryidfinancial(ID primarytermsprimaryId){
        Financials__c financial = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Financials__c WHERE Id=:primarytermsprimaryId];
        Primary_Terms__c primaryItems = [SELECT Id,createddate,Acquisition_Deal__c,Board_Pack_Version__c FROM Primary_Terms__c WHERE Acquisition_Deal__c =:financial.Acquisition_Deal__c AND Board_Pack_Version__c=:financial.Board_Pack_Version__c];
        return(primaryItems.id);
    }
    
    @AuraEnabled
    public static Id  getcompsidfinancial(ID primarytermscompsId){
        Financials__c financial = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Financials__c WHERE Id=:primarytermscompsId];
        Comps__c comps = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Comps__c WHERE Board_Pack_Version__c =: financial.Board_Pack_Version__c AND Acquisition_Deal__c =: financial.Acquisition_Deal__c];
        return(comps.Id);
    }
    
    @AuraEnabled
    public static Id  getRiskidfinancial(ID primarytermsRiskId){
        Financials__c financial = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Financials__c WHERE Id=:primarytermsRiskId];
        Risk_Compliance__c riskComp = [SELECT Id,Acquisition_Deal__c,Board_Pack_Version__c FROM Risk_Compliance__c WHERE Board_Pack_Version__c =:financial.Board_Pack_Version__c AND Acquisition_Deal__c =:financial.Acquisition_Deal__c];
        return(riskComp.Id);
    }
    //-------------------------------------------- comps-------------------------------------------------------------//
    
    @AuraEnabled
    public static Id  getdealidcomps(ID primarytermsId){
        
        Comps__c comps = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Comps__c WHERE Id=:primarytermsId]; 
        Acquisition_Deal__c acqDeal = [SELECT Id FROM Acquisition_Deal__c WHERE Id =: comps.Acquisition_Deal__c];
        return(acqDeal.Id); 
    }
    
    @AuraEnabled
    public static Id  gettitleidcomps(ID primarytermsTitleId){
        Comps__c comps = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Comps__c WHERE Id=:primarytermsTitleId];
        Title__c Title = [SELECT Id, createddate, LAQ_Acquisition_Deal__c, LAQ_Board_Pack_Version__c FROM Title__c WHERE LAQ_Board_Pack_Version__c=:comps.Board_Pack_Version__c AND LAQ_Acquisition_Deal__c=:comps.Acquisition_Deal__c]; 
        return(Title.Id);
    }
    
    @AuraEnabled
    public static Id  getprimaryidcomps(ID primarytermsprimaryId){
        Comps__c comps = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Comps__c WHERE Id=:primarytermsprimaryId];
        Primary_Terms__c primaryItems = [SELECT Id,createddate,Acquisition_Deal__c,Board_Pack_Version__c FROM Primary_Terms__c WHERE Acquisition_Deal__c =:comps.Acquisition_Deal__c AND Board_Pack_Version__c=:comps.Board_Pack_Version__c];
        return(primaryItems.id);
    }
    
    @AuraEnabled
    public static Id  getFinancialsidcomps(ID primarytermsFinId){
        Comps__c comps = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Comps__c WHERE Id=:primarytermsFinId];
        Financials__c financial = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Financials__c WHERE Board_Pack_Version__c =: comps.Board_Pack_Version__c AND Acquisition_Deal__c =: comps.Acquisition_Deal__c]; 
        return(financial.Id);
    }
    
    @AuraEnabled
    public static Id  getRiskidcomps(ID primarytermsRiskId){
        Comps__c comps = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Comps__c WHERE Id=:primarytermsRiskId];
        Risk_Compliance__c riskComp = [SELECT Id,Acquisition_Deal__c,Board_Pack_Version__c FROM Risk_Compliance__c WHERE Board_Pack_Version__c =:comps.Board_Pack_Version__c AND Acquisition_Deal__c =:comps.Acquisition_Deal__c];
        return(riskComp.Id);
    }
    
    //-------------------------------------------- Risk and Compilance-------------------------------------------------------------//
    
    @AuraEnabled
    public static Id  getdealidrisk(ID primarytermsId){
        Risk_Compliance__c riskComp = [SELECT Id,Acquisition_Deal__c,Board_Pack_Version__c FROM Risk_Compliance__c WHERE id=:primarytermsId];
        Acquisition_Deal__c acqDeal = [SELECT Id FROM Acquisition_Deal__c WHERE Id =: riskComp.Acquisition_Deal__c];
        return(acqDeal.Id); 
    }
    
    @AuraEnabled
    public static Id  gettitleidrisk(ID primarytermsTitleId){
        Risk_Compliance__c riskComp = [SELECT Id,Acquisition_Deal__c,Board_Pack_Version__c FROM Risk_Compliance__c WHERE id=:primarytermsTitleId];
        Title__c Title = [SELECT Id, createddate, LAQ_Acquisition_Deal__c, LAQ_Board_Pack_Version__c FROM Title__c WHERE LAQ_Board_Pack_Version__c=:riskComp.Board_Pack_Version__c AND LAQ_Acquisition_Deal__c=:riskComp.Acquisition_Deal__c]; 
        return(Title.Id);
    }
    
    @AuraEnabled
    public static Id  getprimaryidrisk(ID primarytermsprimaryId){
        Risk_Compliance__c riskComp = [SELECT Id,Acquisition_Deal__c,Board_Pack_Version__c FROM Risk_Compliance__c WHERE id=:primarytermsprimaryId];
        Primary_Terms__c primaryItems = [SELECT Id,createddate,Acquisition_Deal__c,Board_Pack_Version__c FROM Primary_Terms__c WHERE Board_Pack_Version__c =: riskComp.Board_Pack_Version__c AND Acquisition_Deal__c =: riskComp.Acquisition_Deal__c];
        return(primaryItems.id);
    }
    
    @AuraEnabled
    public static Id  getFinancialsidrisk(ID primarytermsFinId){
        Risk_Compliance__c riskComp = [SELECT Id,Acquisition_Deal__c,Board_Pack_Version__c FROM Risk_Compliance__c WHERE id=:primarytermsFinId];
        Financials__c financial = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Financials__c WHERE Board_Pack_Version__c =: riskComp.Board_Pack_Version__c AND Acquisition_Deal__c =: riskComp.Acquisition_Deal__c]; 
        return(financial.Id);
    }
    
    @AuraEnabled
    public static Id  getcompsidrisk(ID primarytermscompsId){
        Risk_Compliance__c riskComp = [SELECT Id,Acquisition_Deal__c,Board_Pack_Version__c FROM Risk_Compliance__c WHERE id=:primarytermscompsId];
        Comps__c comps = [SELECT Id,Board_Pack_Version__c,Acquisition_Deal__c FROM Comps__c WHERE Board_Pack_Version__c =: riskComp.Board_Pack_Version__c AND Acquisition_Deal__c =: riskComp.Acquisition_Deal__c];
        return(comps.Id);
    }
}