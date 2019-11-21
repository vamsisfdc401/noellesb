/*****************************************************************************************
Class Name: compareRelatedRecordsOnAcquisitionDeal 
Purpose: Apex Class to compare all the fields between the approved and working board pack and display the fields that do not match
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             4/08/2016            Ashwini                  Initial Development
******************************************************************************************/
public class compareRelatedRecordsOnAcquisitionDeal {
    
    public Acquisition_Deal__c currentAcqDealRecord{get;set;}
    //public Boolean isSF1{get; set;}
    //Related Title
    public Title__c titleRecordApproved{get;set;}
    public Title__c titleRecordNonApproved {get;set;}
    public List<Id> allassociatedTitleIds{get; set;}
    public List<String> notMatchingTitleAPIFieldNames {get; set;}
    public Map<String, String> TitleFieldsWithLabelMap {get; set;}
    public Map<String, String> approvedTitleFieldsWithData {get; set;}
    public Map<String, String> nonApprovedTitleFieldsWithData {get; set;}
    
    //Related Primary Term
    //public Title__c primTermRecordApproved{get;set;}
    //public Title__c primTermRecordNonApproved {get;set;}
    public List<Id> allassociatedPrimTermIds{get; set;}
    public List<String> notMatchingPrimTermAPIFieldNames {get; set;}
    public Map<String, String> PrimTermFieldsWithLabelMap {get; set;}
    public Map<String, String> approvedPrimTermFieldsWithData {get; set;}
    public Map<String, String> nonApprovedPrimTermFieldsWithData {get; set;}
    
    //Related Financials
    //public Financials__c financialRecordApproved{get;set;}
    //public Financials__c financialRecordNonApproved {get;set;}
    public List<Id> allassociatedfinancialIds{get; set;}
    public List<String> notMatchingfinancialAPIFieldNames {get; set;}
    public Map<String, String> financialFieldsWithLabelMap {get; set;}
    public Map<String, String> approvedfinancialFieldsWithData {get; set;}
    public Map<String, String> nonApprovedfinancialFieldsWithData {get; set;}
    
    //Related Comps
    //public Comps__c CompsRecordApproved{get;set;}
    //public Comps__c CompsRecordNonApproved {get;set;}
    public List<Id> allassociatedCompsIds{get; set;}
    public List<String> notMatchingCompsAPIFieldNames {get; set;}
    public Map<String, String> compsFieldsWithLabelMap {get; set;}
    public Map<String, String> approvedCompsFieldsWithData {get; set;}
    public Map<String, String> nonApprovedCompsFieldsWithData {get; set;}
    
    //Related Risk & Compliance
    //public Risk_Compliance__c RiskNCompRecordApproved{get;set;}
    //public Risk_Compliance__c RiskNCompRecordNonApproved {get;set;}
    public List<Id> allassociatedRiskNCompIds{get; set;}
    public List<String> notMatchingRiskNCompAPIFieldNames {get; set;}
    public Map<String, String> riskNCompFieldsWithLabelMap {get; set;}
    public Map<String, String> approvedRiskNCompFieldsWithData {get; set;}
    public Map<String, String> nonApprovedRiskNCompFieldsWithData {get; set;}
    
    /************************************
    Method Name: compareRelatedRecordsOnAcquisitionDeal
    Purpose: Constructor
    *************************************/  
    public compareRelatedRecordsOnAcquisitionDeal(ApexPages.StandardController controller) {
        this.currentAcqDealRecord = (Acquisition_Deal__c)controller.getRecord();
        
        currentAcqDealRecord = [Select id,Title_Context__c,Title_Approved__c,Primary_Term__c,Primary_Term_Approved__c,Financials__c,Financials_Approved__c,Risk_Compliance__c,Risk_Compliance_Approved__c,Comps__c,Comps_Approved__c from Acquisition_Deal__c where Id=:currentAcqDealRecord.id];
        
        //For Related Titles
        titleRecordApproved = new Title__c();
        titleRecordNonApproved = new Title__c();
        allassociatedTitleIds = new List<Id>();
        notMatchingTitleAPIFieldNames = new List <String>();        
        allassociatedTitleIds.add(currentAcqDealRecord.Title_Context__c);
        allassociatedTitleIds.add(currentAcqDealRecord.Title_Approved__c);        
        TitleFieldsWithLabelMap = new Map<String, String>();
        approvedTitleFieldsWithData = new Map<String, String>();
        nonApprovedTitleFieldsWithData = new Map<String, String>(); 
        
        //For Related Primary Terms
        allassociatedPrimTermIds = new List<Id>();
        notMatchingPrimTermAPIFieldNames = new List <String>();        
        allassociatedPrimTermIds.add(currentAcqDealRecord.Primary_Term__c);
        allassociatedPrimTermIds.add(currentAcqDealRecord.Primary_Term_Approved__c);        
        PrimTermFieldsWithLabelMap = new Map<String, String>();
        approvedPrimTermFieldsWithData = new Map<String, String>();
        nonApprovedPrimTermFieldsWithData = new Map<String, String>();
        
        //For Related Financials
        allassociatedFinancialIds = new List<Id>();
        notMatchingFinancialAPIFieldNames = new List <String>();       
        allassociatedFinancialIds.add(currentAcqDealRecord.Financials__c);
        allassociatedFinancialIds.add(currentAcqDealRecord.Financials_Approved__c);     
        FinancialFieldsWithLabelMap = new Map<String, String>();
        approvedFinancialFieldsWithData = new Map<String, String>();
        nonApprovedFinancialFieldsWithData = new Map<String, String>();
         
        //For Related Comps
        allassociatedCompsIds = new List<Id>();
        notMatchingCompsAPIFieldNames = new List <String>();       
        allassociatedCompsIds.add(currentAcqDealRecord.Comps__c);
        allassociatedCompsIds.add(currentAcqDealRecord.Comps_Approved__c);     
        CompsFieldsWithLabelMap = new Map<String, String>();
        approvedCompsFieldsWithData = new Map<String, String>();
        nonApprovedCompsFieldsWithData = new Map<String, String>();
        
        //For  Risk & Compliance
        allassociatedRiskNCompIds = new List<Id>();
        notMatchingRiskNCompAPIFieldNames = new List <String>();       
        allassociatedRiskNCompIds.add(currentAcqDealRecord.Risk_Compliance__c);
        allassociatedRiskNCompIds.add(currentAcqDealRecord.Risk_Compliance_Approved__c);     
        RiskNCompFieldsWithLabelMap = new Map<String, String>();
        approvedRiskNCompFieldsWithData = new Map<String, String>();
        nonApprovedRiskNCompFieldsWithData = new Map<String, String>(); 
        
        //system.debug('////isSf1 in controller'+isSF1 );   
        
           
    }
    
    /************************************
    Method Name: getisSF1
    Purpose: Determine if this is SF1 app
    *************************************/
    public Boolean getisSF1(){
        Boolean isSF1Page;
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
            String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
            ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
            (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
        ){
            isSF1Page= true;
        }else{
            isSF1Page= false;
        }
        system.debug('////isSf1'+isSF1Page); 
        return isSF1Page;  
    }
    
    /************************************
    Method Name: compareRelatedObjects
    Purpose: Call the methods to compare each board pack on the deal
    *************************************/   
    public void compareRelatedObjects(){
    compareRelatedTitles();
    compareRelatedPrimaryTerms();
    compareRelatedFinancials();
    compareRelatedComps();
    compareRelatedRiskNCompliance();
    
    }
    
    /************************************
    Method Name: compareRelatedTitles
    Purpose: Comapre the approved and working Title on the deal
    *************************************/
    public void compareRelatedTitles(){
    
        // Get all the Title fields 
        Map<String, Schema.SObjectField> allTitleFieldsMap = Schema.getGlobalDescribe().get('Title__c').getDescribe().Fields.getMap();        
        List <Schema.SObjectField> titleFields = allTitleFieldsMap.values();        
        List <String> titleAPIFieldNames = new List <String> ();
        String allTitlefields= '';  
        Map<String,Schema.DisplayType> titleFieldsWithTypeMap= new Map<String,Schema.DisplayType>();  
           
         
        // Go through all the title fields 
        for (Schema.SObjectField s : titleFields){
            // Put the title API name field in a list
            titleAPIFieldNames.add(s.getDescribe().getName());
            
            titleFieldsWithTypeMap.put(s.getDescribe().getName(),s.getDescribe().getType());
            
            TitleFieldsWithLabelMap.put(s.getDescribe().getName(),s.getDescribe().getLabel());
            
            //Get fields as a single strin for querying all the fields of Title
            allTitlefields += s.getDescribe().getName() + ',';
              
        }
        if (allTitlefields.endsWith(',')){allTitlefields= allTitlefields.substring(0,allTitlefields.lastIndexOf(','));}
        
        List<Title__c> assciatedAllTitles = new List<Title__c>();
         List<Title__c> approvedTitles = new List<Title__c>();        
        List<Title__c> nonApprovedTitles = new List<Title__c>();
        
        String query = 'Select '+allTitlefields+' from Title__c where ID IN :allassociatedTitleIds';
        
        assciatedAllTitles = Database.query(query);
        
        for(Title__c eachTitle: assciatedAllTitles ){
            if(eachTitle.Id==currentAcqDealRecord.Title_Approved__c){
                approvedTitles.add(eachTitle);
            }
            if(eachTitle.Id==currentAcqDealRecord.Title_Context__c){
                nonApprovedTitles.add(eachTitle);
            }            
        }        
        
        //Compare field values for each title on the acquisition deal        
        for (sObject titleRecord : approvedTitles)
        {
            // For each field
            for(String field : titleAPIFieldNames)            {   
                        
                if (nonApprovedTitles.size()>0 && titleRecord.get(field) != nonApprovedTitles[0].get(field) && field!='Id' && field!='RecordTypeId' && field!='LastModifiedById' && field!='LastReferencedDate' && field!='SystemModstamp' && field!='LastViewedDate' && field!='CreatedDate' && field!='LastModifiedDate')
                {   
                    
                    if(titleFieldsWithTypeMap.get(field)==Schema.DisplayType.String || titleFieldsWithTypeMap.get(field)==Schema.DisplayType.Picklist || titleFieldsWithTypeMap.get(field)==Schema.DisplayType.MultiPicklist || titleFieldsWithTypeMap.get(field)==Schema.DisplayType.TextArea){                  
                        if(String.Valueof((String)titleRecord.get(field))!=NULL){
                            approvedTitleFieldsWithData.put(field.trim(),String.Valueof((String)titleRecord.get(field))); 
                        } else {
                           approvedTitleFieldsWithData.put(field,'--');
                        }
                        if(String.ValueOf((String)nonApprovedTitles[0].get(field))!=NULL){                   
                            nonApprovedTitleFieldsWithData.put(field,String.ValueOf((String)nonApprovedTitles[0].get(field))); 
                        } else {
                           nonApprovedTitleFieldsWithData.put(field,'--');
                        }
                        
                    } else if(titleFieldsWithTypeMap.get(field)==Schema.DisplayType.Integer){
                    
                        Integer approvedvalue=(Integer)titleRecord.get(field);
                        Integer nonApprovedvalue=(Integer)nonApprovedTitles[0].get(field);
                        
                        if(String.Valueof(approvedvalue)!=NULL){
                            approvedTitleFieldsWithData.put(field,String.Valueof(approvedvalue));  
                        } else {
                           approvedTitleFieldsWithData.put(field,'--');
                        }   
                        if(String.Valueof(nonApprovedvalue)!=NULL){                
                            nonApprovedTitleFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                        } else {
                           approvedTitleFieldsWithData.put(field,'--');
                        }
                    
                    } else if(titleFieldsWithTypeMap.get(field)==Schema.DisplayType.DateTime){
                    
                       Datetime approvedvalue=(DateTime)titleRecord.get(field);
                       Datetime nonApprovedvalue=(DateTime)nonApprovedTitles[0].get(field);
                       
                       if(String.Valueof(approvedvalue)!=NULL){
                           approvedTitleFieldsWithData.put(field,String.Valueof(approvedvalue)); 
                       } else {
                           approvedTitleFieldsWithData.put(field,'--');
                       }
                       if(String.Valueof(nonApprovedvalue)!=NULL){                   
                           nonApprovedTitleFieldsWithData.put(field,String.ValueOf(nonApprovedvalue));
                       } else {
                           nonApprovedTitleFieldsWithData.put(field,'--');
                       }
                        
                    } else if(titleFieldsWithTypeMap.get(field)==Schema.DisplayType.Date){ 
                                       
                       Date approvedvalue=(Date)titleRecord.get(field);
                       Date nonApprovedvalue=(Date)nonApprovedTitles[0].get(field);
                       
                       if(String.Valueof(approvedvalue)!=NULL){
                           approvedTitleFieldsWithData.put(field,String.Valueof(approvedvalue)); 
                       } else {
                           approvedTitleFieldsWithData.put(field,'--');
                       }
                       if(String.Valueof(nonApprovedvalue)!=NULL){                   
                           nonApprovedTitleFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                       } else {
                           nonApprovedTitleFieldsWithData.put(field,'--');
                       }
                       
                    } else if(titleFieldsWithTypeMap.get(field)==Schema.DisplayType.Double  || titleFieldsWithTypeMap.get(field)==Schema.DisplayType.Percent || titleFieldsWithTypeMap.get(field)==Schema.DisplayType.Currency){
                        Double approvedvalue=(Double)titleRecord.get(field);
                        Double nonApprovedvalue=(Double)nonApprovedTitles[0].get(field);
                        
                        if(String.Valueof(approvedvalue)!=NULL){
                            approvedTitleFieldsWithData.put(field,String.Valueof(approvedvalue));  
                        } else {
                           approvedTitleFieldsWithData.put(field,'--');
                           }   
                        if(String.Valueof(nonApprovedvalue)!=NULL){                
                            nonApprovedTitleFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                        } else {
                           approvedTitleFieldsWithData.put(field,'--');
                        }                    
                    } else if(titleFieldsWithTypeMap.get(field)==Schema.DisplayType.Boolean){ 
                                       
                       Boolean approvedvalue=(Boolean)titleRecord.get(field);
                       Boolean nonApprovedvalue=(Boolean)nonApprovedTitles[0].get(field);
                       
                       if(String.Valueof(approvedvalue)!=NULL){
                           approvedTitleFieldsWithData.put(field,String.Valueof(approvedvalue)); 
                       } else {
                           approvedTitleFieldsWithData.put(field,'--');
                       }
                       if(String.Valueof(nonApprovedvalue)!=NULL){                   
                           nonApprovedTitleFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                       } else {
                           nonApprovedTitleFieldsWithData.put(field,'--');
                       }
                       
                    }                  
                }
            }
        }  
        notMatchingTitleAPIFieldNames.addAll(nonApprovedTitleFieldsWithData.keyset());      
    }
    
    /************************************
    Method Name: compareRelatedPrimaryTerms
    Purpose: Comapre the approved and working Primary Terms on the deal
    *************************************/
    public void compareRelatedPrimaryTerms(){
    
        // Get all the Primary Term fields 
        Map<String, Schema.SObjectField> allPrimTermFieldsMap = Schema.getGlobalDescribe().get('Primary_Terms__c').getDescribe().Fields.getMap();        
        List <Schema.SObjectField> primaryTermFields = allPrimTermFieldsMap.values();        
        List <String> primaryTermAPIFieldNames = new List <String> ();
        String allPrimTermfields= '';  
        Map<String,Schema.DisplayType> primaryTermFieldsWithTypeMap= new Map<String,Schema.DisplayType>();  
           
         
        // Go through all the Primary Term fields 
        for (Schema.SObjectField s : primaryTermFields){
            // Put the Primary Term API name field in a list
            primaryTermAPIFieldNames.add(s.getDescribe().getName());
            
            primaryTermFieldsWithTypeMap.put(s.getDescribe().getName(),s.getDescribe().getType());
            
            PrimTermFieldsWithLabelMap.put(s.getDescribe().getName(),s.getDescribe().getLabel());
            
            //Get fields as a single strin for querying all the fields of PrimTerm
            allPrimTermfields += s.getDescribe().getName() + ',';
              
        }
        if (allPrimTermfields.endsWith(',')){allPrimTermfields= allPrimTermfields.substring(0,allPrimTermfields.lastIndexOf(','));}
        
        List<Primary_Terms__c> assciatedAllPrimTerms = new List<Primary_Terms__c>();
        List<Primary_Terms__c> approvedPrimTerms = new List<Primary_Terms__c>();        
        List<Primary_Terms__c> nonApprovedPrimTerms = new List<Primary_Terms__c>();
        
        String query = 'Select '+allPrimTermfields+' from Primary_Terms__c where ID IN :allassociatedPrimTermIds';
        
        assciatedAllPrimTerms = Database.query(query);
        
        for(Primary_Terms__c eachPrimTerm: assciatedAllPrimTerms ){
            if(eachPrimTerm.Id==currentAcqDealRecord.Primary_Term_Approved__c){
                approvedPrimTerms.add(eachPrimTerm);
            }
            if(eachPrimTerm.Id==currentAcqDealRecord.Primary_Term__c){
                nonApprovedPrimTerms.add(eachPrimTerm);
            }            
        }        
        
        //Compare field values for each primaryTerm on the acquisition deal        
        for (sObject primaryTermRecord : approvedPrimTerms)
        {
            // For each field
            for(String field : primaryTermAPIFieldNames)            {   
                        
                if (nonApprovedPrimTerms.size()>0 && primaryTermRecord.get(field) != nonApprovedPrimTerms[0].get(field) && field!='Id' && field!='RecordTypeId' && field!='LastModifiedById' && field!='LastReferencedDate' && field!='SystemModstamp' && field!='LastViewedDate' && field!='CreatedDate' && field!='LastModifiedDate')
                {   
                    
                    if(primaryTermFieldsWithTypeMap.get(field)==Schema.DisplayType.String || primaryTermFieldsWithTypeMap.get(field)==Schema.DisplayType.Picklist || primaryTermFieldsWithTypeMap.get(field)==Schema.DisplayType.MultiPicklist || primaryTermFieldsWithTypeMap.get(field)==Schema.DisplayType.TextArea){                  
                        if(String.Valueof((String)primaryTermRecord.get(field))!=NULL){
                            approvedPrimTermFieldsWithData.put(field.trim(),String.Valueof((String)primaryTermRecord.get(field))); 
                        } else {
                           approvedPrimTermFieldsWithData.put(field,'--');
                        }
                        if(String.ValueOf((String)nonApprovedPrimTerms[0].get(field))!=NULL){                   
                            nonApprovedPrimTermFieldsWithData.put(field,String.ValueOf((String)nonApprovedPrimTerms[0].get(field))); 
                        } else {
                           nonApprovedPrimTermFieldsWithData.put(field,'--');
                        }
                        
                    } else if(primaryTermFieldsWithTypeMap.get(field)==Schema.DisplayType.Integer){
                    
                        Integer approvedvalue=(Integer)primaryTermRecord.get(field);
                        Integer nonApprovedvalue=(Integer)nonApprovedPrimTerms[0].get(field);
                        
                        if(String.Valueof(approvedvalue)!=NULL){
                            approvedPrimTermFieldsWithData.put(field,String.Valueof(approvedvalue));  
                        } else {
                           approvedPrimTermFieldsWithData.put(field,'--');
                        }   
                        if(String.Valueof(nonApprovedvalue)!=NULL){                
                            nonApprovedPrimTermFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                        } else {
                           approvedPrimTermFieldsWithData.put(field,'--');
                        }
                    
                    } else if(primaryTermFieldsWithTypeMap.get(field)==Schema.DisplayType.DateTime){
                    
                       Datetime approvedvalue=(DateTime)primaryTermRecord.get(field);
                       Datetime nonApprovedvalue=(DateTime)nonApprovedPrimTerms[0].get(field);
                       
                       if(String.Valueof(approvedvalue)!=NULL){
                           approvedPrimTermFieldsWithData.put(field,String.Valueof(approvedvalue)); 
                       } else {
                           approvedPrimTermFieldsWithData.put(field,'--');
                       }
                       if(String.Valueof(nonApprovedvalue)!=NULL){                   
                           nonApprovedPrimTermFieldsWithData.put(field,String.ValueOf(nonApprovedvalue));
                       } else {
                           nonApprovedPrimTermFieldsWithData.put(field,'--');
                       }
                        
                    } else if(primaryTermFieldsWithTypeMap.get(field)==Schema.DisplayType.Date){ 
                                       
                       Date approvedvalue=(Date)primaryTermRecord.get(field);
                       Date nonApprovedvalue=(Date)nonApprovedPrimTerms[0].get(field);
                       
                       if(String.Valueof(approvedvalue)!=NULL){
                           approvedPrimTermFieldsWithData.put(field,String.Valueof(approvedvalue)); 
                       } else {
                           approvedPrimTermFieldsWithData.put(field,'--');
                       }
                       if(String.Valueof(nonApprovedvalue)!=NULL){                   
                           nonApprovedPrimTermFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                       } else {
                           nonApprovedPrimTermFieldsWithData.put(field,'--');
                       }
                       
                    } else if(primaryTermFieldsWithTypeMap.get(field)==Schema.DisplayType.Double  || primaryTermFieldsWithTypeMap.get(field)==Schema.DisplayType.Percent || primaryTermFieldsWithTypeMap.get(field)==Schema.DisplayType.Currency){
                        Double approvedvalue=(Double)primaryTermRecord.get(field);
                        Double nonApprovedvalue=(Double)nonApprovedPrimTerms[0].get(field);
                        
                        if(String.Valueof(approvedvalue)!=NULL){
                            approvedPrimTermFieldsWithData.put(field,String.Valueof(approvedvalue));  
                        } else {
                           approvedPrimTermFieldsWithData.put(field,'--');
                           }   
                        if(String.Valueof(nonApprovedvalue)!=NULL){                
                            nonApprovedPrimTermFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                        } else {
                           approvedPrimTermFieldsWithData.put(field,'--');
                        }                    
                    }  else if(primaryTermFieldsWithTypeMap.get(field)==Schema.DisplayType.Boolean){ 
                                       
                       Boolean approvedvalue=(Boolean)primaryTermRecord.get(field);
                       Boolean nonApprovedvalue=(Boolean)nonApprovedPrimTerms[0].get(field);
                       
                       if(String.Valueof(approvedvalue)!=NULL){
                           approvedPrimTermFieldsWithData.put(field,String.Valueof(approvedvalue)); 
                       } else {
                           approvedPrimTermFieldsWithData.put(field,'--');
                       }
                       if(String.Valueof(nonApprovedvalue)!=NULL){                   
                           nonApprovedPrimTermFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                       } else {
                           nonApprovedPrimTermFieldsWithData.put(field,'--');
                       }
                       
                    }                 
                }
            }
        }  
        notMatchingPrimTermAPIFieldNames.addAll(nonApprovedPrimTermFieldsWithData.keyset());      
    }
    
    /************************************
    Method Name: compareRelatedFinancials
    Purpose: Comapre the approved and working Financials on the deal
    *************************************/
    public void compareRelatedFinancials(){
    
        // Get all the Financials fields 
        Map<String, Schema.SObjectField> allfinancialFieldsMap = Schema.getGlobalDescribe().get('Financials__c').getDescribe().Fields.getMap();        
        List <Schema.SObjectField> financialFields = allfinancialFieldsMap.values();        
        List <String> financialAPIFieldNames = new List <String> ();
        String allfinancialfields= '';  
        Map<String,Schema.DisplayType> financialFieldsWithTypeMap= new Map<String,Schema.DisplayType>();  
           
         
        // Go through all the Financials fields 
        for (Schema.SObjectField s : financialFields){
            // Put the Financials API name field in a list
            financialAPIFieldNames.add(s.getDescribe().getName());
            
            financialFieldsWithTypeMap.put(s.getDescribe().getName(),s.getDescribe().getType());
            
            financialFieldsWithLabelMap.put(s.getDescribe().getName(),s.getDescribe().getLabel());
            
            //Get fields as a single strin for querying all the fields of financial
            allfinancialfields += s.getDescribe().getName() + ',';
              
        }
        if (allfinancialfields.endsWith(',')){allfinancialfields= allfinancialfields.substring(0,allfinancialfields.lastIndexOf(','));}
        
        List<Financials__c> assciatedAllfinancials = new List<Financials__c>();
        List<Financials__c> approvedfinancials = new List<Financials__c>();        
        List<Financials__c> nonApprovedfinancials = new List<Financials__c>();
        
        String query = 'Select '+allfinancialfields+' from Financials__c where ID IN :allassociatedfinancialIds';
        
        assciatedAllfinancials = Database.query(query);
        
        for(Financials__c eachfinancial: assciatedAllfinancials ){
            if(eachfinancial.Id==currentAcqDealRecord.Financials_Approved__c){
                approvedfinancials.add(eachfinancial);
            }
            if(eachfinancial.Id==currentAcqDealRecord.Financials__c){
                nonApprovedfinancials.add(eachfinancial);
            }            
        }        
        
        //Compare field values for each financial on the acquisition deal        
        for (sObject financialRecord : approvedfinancials)
        {
            // For each field
            for(String field : financialAPIFieldNames)            {   
                        
                if (nonApprovedfinancials.size()>0 && financialRecord.get(field) != nonApprovedfinancials[0].get(field) && field!='Id' && field!='RecordTypeId' && field!='LastModifiedById' && field!='LastReferencedDate' && field!='SystemModstamp' && field!='LastViewedDate' && field!='CreatedDate' && field!='LastModifiedDate')
                {   
                    
                    if(financialFieldsWithTypeMap.get(field)==Schema.DisplayType.String || financialFieldsWithTypeMap.get(field)==Schema.DisplayType.Picklist || financialFieldsWithTypeMap.get(field)==Schema.DisplayType.MultiPicklist || financialFieldsWithTypeMap.get(field)==Schema.DisplayType.TextArea){                  
                        if(String.Valueof((String)financialRecord.get(field))!=NULL){
                            approvedfinancialFieldsWithData.put(field.trim(),String.Valueof((String)financialRecord.get(field))); 
                        } else {
                           approvedfinancialFieldsWithData.put(field,'--');
                        }
                        if(String.ValueOf((String)nonApprovedfinancials[0].get(field))!=NULL){                   
                            nonApprovedfinancialFieldsWithData.put(field,String.ValueOf((String)nonApprovedfinancials[0].get(field))); 
                        } else {
                           nonApprovedfinancialFieldsWithData.put(field,'--');
                        }
                        
                    } else if(financialFieldsWithTypeMap.get(field)==Schema.DisplayType.Integer){
                    
                        Integer approvedvalue=(Integer)financialRecord.get(field);
                        Integer nonApprovedvalue=(Integer)nonApprovedfinancials[0].get(field);
                        
                        if(String.Valueof(approvedvalue)!=NULL){
                            approvedfinancialFieldsWithData.put(field,String.Valueof(approvedvalue));  
                        } else {
                           approvedfinancialFieldsWithData.put(field,'--');
                        }   
                        if(String.Valueof(nonApprovedvalue)!=NULL){                
                            nonApprovedfinancialFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                        } else {
                           approvedfinancialFieldsWithData.put(field,'--');
                        }
                    
                    } else if(financialFieldsWithTypeMap.get(field)==Schema.DisplayType.DateTime){
                    
                       Datetime approvedvalue=(DateTime)financialRecord.get(field);
                       Datetime nonApprovedvalue=(DateTime)nonApprovedfinancials[0].get(field);
                       
                       if(String.Valueof(approvedvalue)!=NULL){
                           approvedfinancialFieldsWithData.put(field,String.Valueof(approvedvalue)); 
                       } else {
                           approvedfinancialFieldsWithData.put(field,'--');
                       }
                       if(String.Valueof(nonApprovedvalue)!=NULL){                   
                           nonApprovedfinancialFieldsWithData.put(field,String.ValueOf(nonApprovedvalue));
                       } else {
                           nonApprovedfinancialFieldsWithData.put(field,'--');
                       }
                        
                    } else if(financialFieldsWithTypeMap.get(field)==Schema.DisplayType.Date){ 
                                       
                       Date approvedvalue=(Date)financialRecord.get(field);
                       Date nonApprovedvalue=(Date)nonApprovedfinancials[0].get(field);
                       
                       if(String.Valueof(approvedvalue)!=NULL){
                           approvedfinancialFieldsWithData.put(field,String.Valueof(approvedvalue)); 
                       } else {
                           approvedfinancialFieldsWithData.put(field,'--');
                       }
                       if(String.Valueof(nonApprovedvalue)!=NULL){                   
                           nonApprovedfinancialFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                       } else {
                           nonApprovedfinancialFieldsWithData.put(field,'--');
                       }
                       
                    } else if(financialFieldsWithTypeMap.get(field)==Schema.DisplayType.Double  || financialFieldsWithTypeMap.get(field)==Schema.DisplayType.Percent || financialFieldsWithTypeMap.get(field)==Schema.DisplayType.Currency){
                        Double approvedvalue=(Double)financialRecord.get(field);
                        Double nonApprovedvalue=(Double)nonApprovedfinancials[0].get(field);
                        
                        if(String.Valueof(approvedvalue)!=NULL){
                            approvedfinancialFieldsWithData.put(field,String.Valueof(approvedvalue));  
                        } else {
                           approvedfinancialFieldsWithData.put(field,'--');
                           }   
                        if(String.Valueof(nonApprovedvalue)!=NULL){                
                            nonApprovedfinancialFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                        } else {
                           approvedfinancialFieldsWithData.put(field,'--');
                        }                    
                    } else if(financialFieldsWithTypeMap.get(field)==Schema.DisplayType.Boolean){ 
                                       
                       Boolean approvedvalue=(Boolean)financialRecord.get(field);
                       Boolean nonApprovedvalue=(Boolean)nonApprovedfinancials[0].get(field);
                       
                       if(String.Valueof(approvedvalue)!=NULL){
                           approvedfinancialFieldsWithData.put(field,String.Valueof(approvedvalue)); 
                       } else {
                           approvedfinancialFieldsWithData.put(field,'--');
                       }
                       if(String.Valueof(nonApprovedvalue)!=NULL){                   
                           nonApprovedfinancialFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                       } else {
                           nonApprovedfinancialFieldsWithData.put(field,'--');
                       }
                       
                    } 
                                      
                }
            }
        }
        
        notMatchingfinancialAPIFieldNames.addAll(nonApprovedfinancialFieldsWithData.keyset());
        
        system.debug('///approvedfinancialFieldsWithData.keyset()'+approvedfinancialFieldsWithData.keyset());
        system.debug('///approvedfinancialFieldsWithData'+approvedfinancialFieldsWithData);
        system.debug('///nonApprovedfinancialFieldsWithData.keyset()'+nonApprovedfinancialFieldsWithData.keyset());
        system.debug('///nonApprovedfinancialFieldsWithData'+nonApprovedfinancialFieldsWithData);        
    }
    
    /************************************
    Method Name: compareRelatedComps
    Purpose: Comapre the approved and working Comps on the deal
    *************************************/
    public void compareRelatedComps(){
    
        // Get all the Comps fields 
        Map<String, Schema.SObjectField> allCompsFieldsMap = Schema.getGlobalDescribe().get('Comps__c').getDescribe().Fields.getMap();        
        List <Schema.SObjectField> CompsFields = allCompsFieldsMap.values();        
        List <String> CompsAPIFieldNames = new List <String> ();
        String allCompsfields= '';  
        Map<String,Schema.DisplayType> CompsFieldsWithTypeMap= new Map<String,Schema.DisplayType>();  
           
         
        // Go through all the Comps fields 
        for (Schema.SObjectField s : CompsFields){
            // Put the Comps API name field in a list
            CompsAPIFieldNames.add(s.getDescribe().getName());
            
            CompsFieldsWithTypeMap.put(s.getDescribe().getName(),s.getDescribe().getType());
            
            CompsFieldsWithLabelMap.put(s.getDescribe().getName(),s.getDescribe().getLabel());
            
            //Get fields as a single strin for querying all the fields of Comps
            allCompsfields += s.getDescribe().getName() + ',';
              
        }
        if (allCompsfields.endsWith(',')){allCompsfields= allCompsfields.substring(0,allCompsfields.lastIndexOf(','));}
        
        List<Comps__c> assciatedAllCompss = new List<Comps__c>();
        List<Comps__c> approvedCompss = new List<Comps__c>();        
        List<Comps__c> nonApprovedCompss = new List<Comps__c>();
        
        String query = 'Select '+allCompsfields+' from Comps__c where ID IN :allassociatedCompsIds';
        
        assciatedAllCompss = Database.query(query);
        
        for(Comps__c eachComps: assciatedAllCompss ){
            if(eachComps.Id==currentAcqDealRecord.Comps_Approved__c){
                approvedCompss.add(eachComps);
            }
            if(eachComps.Id==currentAcqDealRecord.Comps__c){
                nonApprovedCompss.add(eachComps);
            }            
        }        
        
        //Compare field values for each Comps on the acquisition deal        
        for (sObject CompsRecord : approvedCompss)
        {
            // For each field
            for(String field : CompsAPIFieldNames)            {   
                        
                if (nonApprovedCompss.size()>0 && CompsRecord.get(field) != nonApprovedCompss[0].get(field) && field!='Id' && field!='RecordTypeId' && field!='LastModifiedById' && field!='LastReferencedDate' && field!='SystemModstamp' && field!='LastViewedDate' && field!='CreatedDate' && field!='LastModifiedDate')
                {   
                    
                    if(CompsFieldsWithTypeMap.get(field)==Schema.DisplayType.String || CompsFieldsWithTypeMap.get(field)==Schema.DisplayType.Picklist || CompsFieldsWithTypeMap.get(field)==Schema.DisplayType.MultiPicklist || CompsFieldsWithTypeMap.get(field)==Schema.DisplayType.TextArea){                  
                        if(String.Valueof((String)CompsRecord.get(field))!=NULL){
                            approvedCompsFieldsWithData.put(field.trim(),String.Valueof((String)CompsRecord.get(field))); 
                        } else {
                           approvedCompsFieldsWithData.put(field,'--');
                        }
                        if(String.ValueOf((String)nonApprovedCompss[0].get(field))!=NULL){                   
                            nonApprovedCompsFieldsWithData.put(field,String.ValueOf((String)nonApprovedCompss[0].get(field))); 
                        } else {
                           nonApprovedCompsFieldsWithData.put(field,'--');
                        }
                        
                    } else if(CompsFieldsWithTypeMap.get(field)==Schema.DisplayType.Integer){
                    
                        Integer approvedvalue=(Integer)CompsRecord.get(field);
                        Integer nonApprovedvalue=(Integer)nonApprovedCompss[0].get(field);
                        
                        if(String.Valueof(approvedvalue)!=NULL){
                            approvedCompsFieldsWithData.put(field,String.Valueof(approvedvalue));  
                        } else {
                           approvedCompsFieldsWithData.put(field,'--');
                        }   
                        if(String.Valueof(nonApprovedvalue)!=NULL){                
                            nonApprovedCompsFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                        } else {
                           approvedCompsFieldsWithData.put(field,'--');
                        }
                    
                    } else if(CompsFieldsWithTypeMap.get(field)==Schema.DisplayType.DateTime){
                    
                       Datetime approvedvalue=(DateTime)CompsRecord.get(field);
                       Datetime nonApprovedvalue=(DateTime)nonApprovedCompss[0].get(field);
                       
                       if(String.Valueof(approvedvalue)!=NULL){
                           approvedCompsFieldsWithData.put(field,String.Valueof(approvedvalue)); 
                       } else {
                           approvedCompsFieldsWithData.put(field,'--');
                       }
                       if(String.Valueof(nonApprovedvalue)!=NULL){                   
                           nonApprovedCompsFieldsWithData.put(field,String.ValueOf(nonApprovedvalue));
                       } else {
                           nonApprovedCompsFieldsWithData.put(field,'--');
                       }
                        
                    } else if(CompsFieldsWithTypeMap.get(field)==Schema.DisplayType.Date){ 
                                       
                       Date approvedvalue=(Date)CompsRecord.get(field);
                       Date nonApprovedvalue=(Date)nonApprovedCompss[0].get(field);
                       
                       if(String.Valueof(approvedvalue)!=NULL){
                           approvedCompsFieldsWithData.put(field,String.Valueof(approvedvalue)); 
                       } else {
                           approvedCompsFieldsWithData.put(field,'--');
                       }
                       if(String.Valueof(nonApprovedvalue)!=NULL){                   
                           nonApprovedCompsFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                       } else {
                           nonApprovedCompsFieldsWithData.put(field,'--');
                       }
                       
                    } else if(CompsFieldsWithTypeMap.get(field)==Schema.DisplayType.Double  || CompsFieldsWithTypeMap.get(field)==Schema.DisplayType.Percent || CompsFieldsWithTypeMap.get(field)==Schema.DisplayType.Currency){
                        Double approvedvalue=(Double)CompsRecord.get(field);
                        Double nonApprovedvalue=(Double)nonApprovedCompss[0].get(field);
                        
                        if(String.Valueof(approvedvalue)!=NULL){
                            approvedCompsFieldsWithData.put(field,String.Valueof(approvedvalue));  
                        } else {
                           approvedCompsFieldsWithData.put(field,'--');
                           }   
                        if(String.Valueof(nonApprovedvalue)!=NULL){                
                            nonApprovedCompsFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                        } else {
                           approvedCompsFieldsWithData.put(field,'--');
                        }                    
                    } else if(CompsFieldsWithTypeMap.get(field)==Schema.DisplayType.Boolean){ 
                                       
                       Boolean approvedvalue=(Boolean)CompsRecord.get(field);
                       Boolean nonApprovedvalue=(Boolean)nonApprovedCompss[0].get(field);
                       
                       if(String.Valueof(approvedvalue)!=NULL){
                           approvedCompsFieldsWithData.put(field,String.Valueof(approvedvalue)); 
                       } else {
                           approvedCompsFieldsWithData.put(field,'--');
                       }
                       if(String.Valueof(nonApprovedvalue)!=NULL){                   
                           nonApprovedCompsFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                       } else {
                           nonApprovedCompsFieldsWithData.put(field,'--');
                       }
                       
                    }                   
                }
            }
        }
        notMatchingCompsAPIFieldNames.addAll(nonApprovedCompsFieldsWithData.keyset());        
    }
    
    /************************************
    Method Name: compareRelatedRiskNCompliance
    Purpose: Comapre the approved and working Risk & Compliance on the deal
    *************************************/
    public void compareRelatedRiskNCompliance(){
    
        // Get all the Risk & Compliance fields 
        Map<String, Schema.SObjectField> allRiskNCompFieldsMap = Schema.getGlobalDescribe().get('Risk_Compliance__c').getDescribe().Fields.getMap();        
        List <Schema.SObjectField> RiskNCompFields = allRiskNCompFieldsMap.values();        
        List <String> RiskNCompAPIFieldNames = new List <String> ();
        String allRiskNCompfields= '';  
        Map<String,Schema.DisplayType> RiskNCompFieldsWithTypeMap= new Map<String,Schema.DisplayType>();  
           
         
        // Go through all the Risk & Compliance fields 
        for (Schema.SObjectField s : RiskNCompFields){
            // Put the Risk & Compliance API name field in a list
            RiskNCompAPIFieldNames.add(s.getDescribe().getName());
            
            RiskNCompFieldsWithTypeMap.put(s.getDescribe().getName(),s.getDescribe().getType());
            
            RiskNCompFieldsWithLabelMap.put(s.getDescribe().getName(),s.getDescribe().getLabel());
            
            //Get fields as a single strin for querying all the fields of Risk & Compliance
            allRiskNCompfields += s.getDescribe().getName() + ',';
              
        }
        if (allRiskNCompfields.endsWith(',')){allRiskNCompfields= allRiskNCompfields.substring(0,allRiskNCompfields.lastIndexOf(','));}
        
        List<Risk_Compliance__c> assciatedAllRiskNComps = new List<Risk_Compliance__c>();
        List<Risk_Compliance__c> approvedRiskNComps = new List<Risk_Compliance__c>();        
        List<Risk_Compliance__c> nonApprovedRiskNComps = new List<Risk_Compliance__c>();
        
        String query = 'Select '+allRiskNCompfields+' from Risk_Compliance__c where ID IN :allassociatedRiskNCompIds';
        
        assciatedAllRiskNComps = Database.query(query);
        
        for(Risk_Compliance__c eachRiskNComp: assciatedAllRiskNComps ){
            if(eachRiskNComp.Id==currentAcqDealRecord.Risk_Compliance_Approved__c){
                approvedRiskNComps.add(eachRiskNComp);
            }
            if(eachRiskNComp.Id==currentAcqDealRecord.Risk_Compliance__c){
                nonApprovedRiskNComps.add(eachRiskNComp);
            }            
        }        
        
        //Compare field values for each Risk & Compliance on the acquisition deal        
        for (sObject RiskNCompRecord : approvedRiskNComps)
        {
            // For each field
            for(String field : RiskNCompAPIFieldNames)            {   
                        
                if (nonApprovedRiskNComps.size()>0 && RiskNCompRecord.get(field) != nonApprovedRiskNComps[0].get(field) && field!='Id' && field!='RecordTypeId' && field!='LastModifiedById' && field!='LastReferencedDate' && field!='SystemModstamp' && field!='LastViewedDate' && field!='CreatedDate' && field!='LastModifiedDate')
                {   
                    
                    if(RiskNCompFieldsWithTypeMap.get(field)==Schema.DisplayType.String || RiskNCompFieldsWithTypeMap.get(field)==Schema.DisplayType.Picklist || RiskNCompFieldsWithTypeMap.get(field)==Schema.DisplayType.MultiPicklist || RiskNCompFieldsWithTypeMap.get(field)==Schema.DisplayType.TextArea){                  
                        if(String.Valueof((String)RiskNCompRecord.get(field))!=NULL){
                            approvedRiskNCompFieldsWithData.put(field.trim(),String.Valueof((String)RiskNCompRecord.get(field))); 
                        } else {
                           approvedRiskNCompFieldsWithData.put(field,'--');
                        }
                        if(String.ValueOf((String)nonApprovedRiskNComps[0].get(field))!=NULL){                   
                            nonApprovedRiskNCompFieldsWithData.put(field,String.ValueOf((String)nonApprovedRiskNComps[0].get(field))); 
                        } else {
                           nonApprovedRiskNCompFieldsWithData.put(field,'--');
                        }
                        
                    } else if(RiskNCompFieldsWithTypeMap.get(field)==Schema.DisplayType.Integer){
                    
                        Integer approvedvalue=(Integer)RiskNCompRecord.get(field);
                        Integer nonApprovedvalue=(Integer)nonApprovedRiskNComps[0].get(field);
                        
                        if(String.Valueof(approvedvalue)!=NULL){
                            approvedRiskNCompFieldsWithData.put(field,String.Valueof(approvedvalue));  
                        } else {
                           approvedRiskNCompFieldsWithData.put(field,'--');
                        }   
                        if(String.Valueof(nonApprovedvalue)!=NULL){                
                            nonApprovedRiskNCompFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                        } else {
                           approvedRiskNCompFieldsWithData.put(field,'--');
                        }
                    
                    } else if(RiskNCompFieldsWithTypeMap.get(field)==Schema.DisplayType.DateTime){
                    
                       Datetime approvedvalue=(DateTime)RiskNCompRecord.get(field);
                       Datetime nonApprovedvalue=(DateTime)nonApprovedRiskNComps[0].get(field);
                       
                       if(String.Valueof(approvedvalue)!=NULL){
                           approvedRiskNCompFieldsWithData.put(field,String.Valueof(approvedvalue)); 
                       } else {
                           approvedRiskNCompFieldsWithData.put(field,'--');
                       }
                       if(String.Valueof(nonApprovedvalue)!=NULL){                   
                           nonApprovedRiskNCompFieldsWithData.put(field,String.ValueOf(nonApprovedvalue));
                       } else {
                           nonApprovedRiskNCompFieldsWithData.put(field,'--');
                       }
                        
                    } else if(RiskNCompFieldsWithTypeMap.get(field)==Schema.DisplayType.Date){ 
                                       
                       Date approvedvalue=(Date)RiskNCompRecord.get(field);
                       Date nonApprovedvalue=(Date)nonApprovedRiskNComps[0].get(field);
                       
                       if(String.Valueof(approvedvalue)!=NULL){
                           approvedRiskNCompFieldsWithData.put(field,String.Valueof(approvedvalue)); 
                       } else {
                           approvedRiskNCompFieldsWithData.put(field,'--');
                       }
                       if(String.Valueof(nonApprovedvalue)!=NULL){                   
                           nonApprovedRiskNCompFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                       } else {
                           nonApprovedRiskNCompFieldsWithData.put(field,'--');
                       }
                       
                    } else if(RiskNCompFieldsWithTypeMap.get(field)==Schema.DisplayType.Double || RiskNCompFieldsWithTypeMap.get(field)==Schema.DisplayType.Percent || RiskNCompFieldsWithTypeMap.get(field)==Schema.DisplayType.Currency){
                        Double approvedvalue=(Double)RiskNCompRecord.get(field);
                        Double nonApprovedvalue=(Double)nonApprovedRiskNComps[0].get(field);
                        
                        if(String.Valueof(approvedvalue)!=NULL){
                            approvedRiskNCompFieldsWithData.put(field,String.Valueof(approvedvalue));  
                        } else {
                           approvedRiskNCompFieldsWithData.put(field,'--');
                           }   
                        if(String.Valueof(nonApprovedvalue)!=NULL){                
                            nonApprovedRiskNCompFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                        } else {
                           approvedRiskNCompFieldsWithData.put(field,'--');
                        }                    
                    }   else if(RiskNCompFieldsWithTypeMap.get(field)==Schema.DisplayType.Boolean){ 
                                       
                       Boolean approvedvalue=(Boolean)RiskNCompRecord.get(field);
                       Boolean nonApprovedvalue=(Boolean)nonApprovedRiskNComps[0].get(field);
                       
                       if(String.Valueof(approvedvalue)!=NULL){
                           approvedRiskNCompFieldsWithData.put(field,String.Valueof(approvedvalue)); 
                       } else {
                           approvedRiskNCompFieldsWithData.put(field,'--');
                       }
                       if(String.Valueof(nonApprovedvalue)!=NULL){                   
                           nonApprovedRiskNCompFieldsWithData.put(field,String.ValueOf(nonApprovedvalue)); 
                       } else {
                           nonApprovedRiskNCompFieldsWithData.put(field,'--');
                       }
                       
                    }                 
                }
            }
        }   
        notMatchingRiskNCompAPIFieldNames.addAll(nonApprovedRiskNCompFieldsWithData.keyset());     
    }
}