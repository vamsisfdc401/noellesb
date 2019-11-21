/*****************************************************************************************
Class Name: importDataFromCSVController 
Purpose: Apex class referenced in VF Page ImportFinancialSummaryData to handle the import of Financial Summary fields 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             4/08/2016            Ashwini                  Initial Development
******************************************************************************************/
public class importDataFromCSVController {

    
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public string csvFileName{get;set;}
    public String[] csvFileLines{get;set;}
    public set<String> fieldsNotMatched{get; set;}
    public Boolean allowUploadFinancialData{get; set;}
    
    public Financials__c currentFinancialRecord{get;set;}
    
    /************************************
    Method Name: importDataFromCSVController
    Purpose: Constructor
    *************************************/ 
    public importDataFromCSVController(ApexPages.StandardController controller) {
        csvFileLines = new String[]{}; 
        fieldsNotMatched = new Set<String>();      
        this.currentFinancialRecord = (Financials__c)controller.getRecord();
        ID loggedInUserRole = UserInfo.getUserRoleId();
        //ID loggedInUserProfile = UserInfo.getProfileId();
        
        if(loggedInUserRole==Label.RoleId_FPA_Team_Read_Only_Member ){
            allowUploadFinancialData = false;
        }
        if(allowUploadFinancialData==false){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'User with role "FP&A Read Only Team Member" cannot upload financial information, please click the button below to return to the deal!')); 
        }
        else{
            allowUploadFinancialData = true;
        }
 
    }
    
    /************************************
    Method Name: importCSVFile
    Purpose: Method which spilts the input CSV file and maps the data with the fields based on the column headers
    *************************************/
    public void importCSVFile(){
    system.debug('//Blob content'+csvFileBody);
       try{
           csvAsString = csvFileBody.toString();
           csvFileLines = csvAsString.split('\n'); 
           system.debug('/////csvFileName'+csvFileName);
           
           
           Map<String, Schema.SObjectField> allfieldsMap = Schema.getGlobalDescribe().get('Financials__c').getDescribe().Fields.getMap();
           Map<String, String> allFieldsLabelToApiNameMap = new Map<String, String>();
           
           if (allfieldsMap!= null){
            for (Schema.SObjectField ft : allfieldsMap.values()){ // loop through all field tokens (ft)
             
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)  
                if (fd.isUpdateable()){ // check if field can be updated 
                    allFieldsLabelToApiNameMap.put(fd.getLabel(),fd.getName());    
                }               
            }
           }         
           
           Map<String, String> labelWithData = new Map<String, String>();
           string[] csvFileFieldLabels = csvFileLines[0].split(',');
           string[] csvRecordData = csvFileLines[1].split(',');          
           
           
           for(Integer i=0;i<csvFileFieldLabels.size();i++){
               labelWithData.put(csvFileFieldLabels[i].trim(),csvRecordData[i].trim());  
               fieldsNotMatched.add(csvFileFieldLabels[i].trim());            
           }    
           
           for(String lab : labelWithData.keyset()){
                   system.debug('labelWithData.get(lab)'+labelWithData.get(lab));
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Revenue_Theatrical__c'){                                               
                   currentFinancialRecord.X1st_year_Revenue_Theatrical__c = Decimal.valueof(labelWithData.get(lab).trim());  
                   fieldsNotMatched.remove(lab);                 
                   }      
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Revenue_Video__c'){  
                   currentFinancialRecord.X1st_year_Revenue_Video__c = Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Revenue_Television_and_Digital__c'){  
                   currentFinancialRecord.X1st_year_Revenue_Television_and_Digital__c = Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_Year_Revenue_Other__c'){  
                   currentFinancialRecord.X1st_Year_Revenue_Other__c = Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Margin_Theatrical__c'){  
                   currentFinancialRecord.X1st_year_Margin_Theatrical__c= Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Margin_Video__c'){  
                   currentFinancialRecord.X1st_year_Margin_Video__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }                                    
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_Year_Margin_Other__c'){  
                   currentFinancialRecord.X1st_Year_Margin_Other__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Margin_International_FTV__c'){  
                   currentFinancialRecord.X1st_year_Margin_International_FTV__c= Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Margin_International_PTV__c'){  
                   currentFinancialRecord.X1st_year_Margin_International_PTV__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_yr_Margin_International_TVODDigital__c'){  
                   currentFinancialRecord.X1st_yr_Margin_International_TVODDigital__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Margin_International_SVOD__c'){  
                   currentFinancialRecord.X1st_year_Margin_International_SVOD__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Margin_Domestic_FTV__c'){  
                   currentFinancialRecord.X1st_year_Margin_Domestic_FTV__c= Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Margin_Domestic_PTV__c'){  
                   currentFinancialRecord.X1st_year_Margin_Domestic_PTV__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Margin_Domestic_TVOD_Digital__c'){  
                   currentFinancialRecord.X1st_year_Margin_Domestic_TVOD_Digital__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Margin_Domestic_SVOD__c'){  
                   currentFinancialRecord.X1st_year_Margin_Domestic_SVOD__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Margin_Recoupable_Costs__c'){  
                   currentFinancialRecord.X1st_year_Margin_Recoupable_Costs__c= Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Margin_Non_Recoupable_Costs__c'){  
                   currentFinancialRecord.X1st_year_Margin_Non_Recoupable_Costs__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Margin_Mechanicals__c'){  
                   currentFinancialRecord.X1st_year_Margin_Mechanicals__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_MG__c'){  
                   currentFinancialRecord.X1st_year_MG__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Overages__c'){  
                   currentFinancialRecord.X1st_year_Overages__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Net_OCF__c'){ 
                   currentFinancialRecord.X1st_year_Net_OCF__c= Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Contribution__c'){ 
                   currentFinancialRecord.X1st_year_Contribution__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_ROI__c'){ 
                   currentFinancialRecord.X1st_year_ROI__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }                  
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X1st_year_Cash_on_Cash__c'){ 
                   currentFinancialRecord.X1st_year_Cash_on_Cash__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   //Second year fields
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Revenue_Theatrical__c'){                                               
                   currentFinancialRecord.X2nd_year_Revenue_Theatrical__c = Decimal.valueof(labelWithData.get(lab).trim());  
                   fieldsNotMatched.remove(lab);                 
                   }      
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Revenue_Video__c'){  
                   currentFinancialRecord.X2nd_year_Revenue_Video__c = Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Revenue_Television_and_Digital__c'){  
                   currentFinancialRecord.X2nd_year_Revenue_Television_and_Digital__c = Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_Year_Revenue_Other__c'){  
                   currentFinancialRecord.X2nd_Year_Revenue_Other__c = Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Margin_Theatrical__c'){  
                   currentFinancialRecord.X2nd_year_Margin_Theatrical__c= Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Margin_Video__c'){  
                   currentFinancialRecord.X2nd_year_Margin_Video__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }                                    
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_Year_Margin_Other__c'){  
                   currentFinancialRecord.X2nd_Year_Margin_Other__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Margin_International_FTV__c'){  
                   currentFinancialRecord.X2nd_year_Margin_International_FTV__c= Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Margin_International_PTV__c'){  
                   currentFinancialRecord.X2nd_year_Margin_International_PTV__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_yr_Margin_International_TVOD_Digita__c'){  
                   currentFinancialRecord.X2nd_yr_Margin_International_TVOD_Digita__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Margin_International_SVOD__c'){  
                   currentFinancialRecord.X2nd_year_Margin_International_SVOD__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Margin_Domestic_FTV__c'){  
                   currentFinancialRecord.X2nd_year_Margin_Domestic_FTV__c= Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Margin_Domestic_PTV__c'){  
                   currentFinancialRecord.X2nd_year_Margin_Domestic_PTV__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Margin_Domestic_TVOD_Digital__c'){  
                   currentFinancialRecord.X2nd_year_Margin_Domestic_TVOD_Digital__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Margin_Domestic_SVOD__c'){  
                   currentFinancialRecord.X2nd_year_Margin_Domestic_SVOD__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Margin_Recoupable_Costs__c'){  
                   currentFinancialRecord.X2nd_year_Margin_Recoupable_Costs__c= Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Margin_Non_Recoupable_Costs__c'){  
                   currentFinancialRecord.X2nd_year_Margin_Non_Recoupable_Costs__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Margin_Mechanicals__c'){  
                   currentFinancialRecord.X2nd_year_Margin_Mechanicals__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_MG__c'){  
                   currentFinancialRecord.X2nd_year_MG__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Overages__c'){  
                   currentFinancialRecord.X2nd_year_Overages__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Net_OCF__c'){ 
                   currentFinancialRecord.X2nd_year_Net_OCF__c= Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Contribution__c'){ 
                   currentFinancialRecord.X2nd_year_Contribution__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_ROI__c'){ 
                   currentFinancialRecord.X2nd_year_ROI__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }                  
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='X2nd_year_Cash_on_Cash__c'){ 
                   currentFinancialRecord.X2nd_year_Cash_on_Cash__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   
                   //Ultimate Financial Summary fields 
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Revenue_Theatrical__c'){ 
                   currentFinancialRecord.Revenue_Theatrical__c = Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Revenue_Video__c'){ 
                   currentFinancialRecord.Revenue_Video__c = Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Revenue_Television_and_Digital__c'){ 
                   currentFinancialRecord.Revenue_Television_and_Digital__c = Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Revenue_Other__c'){ 
                   currentFinancialRecord.Revenue_Other__c = Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Margin_Theatrical__c'){ 
                   currentFinancialRecord.Margin_Theatrical__c= Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Margin_Video__c'){
                   currentFinancialRecord.Margin_Video__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Margin_International_TVOD_Digital__c'){
                   currentFinancialRecord.Margin_International_TVOD_Digital__c= Decimal.valueof(labelWithData.get(lab).trim()); 
                   fieldsNotMatched.remove(lab);   
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Margin_Other__c'){
                   currentFinancialRecord.Margin_Other__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Margin_International_FTV__c'){
                   currentFinancialRecord.Margin_International_FTV__c= Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Margin_International_PTV__c'){
                   currentFinancialRecord.Margin_International_PTV__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }                              
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Margin_International_SVOD__c'){
                   currentFinancialRecord.Margin_International_SVOD__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Margin_Domestic_FTV__c'){
                   currentFinancialRecord.Margin_Domestic_FTV__c= Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Margin_Domestic_PTV__c'){
                   currentFinancialRecord.Margin_Domestic_PTV__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Margin_Domestic_TVOD_Digital__c'){
                   currentFinancialRecord.Margin_Domestic_TVOD_Digital__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);                  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Margin_Domestic_SVOD__c'){
                   currentFinancialRecord.Margin_Domestic_SVOD__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Margin_Recoupable_Costs__c'){
                   currentFinancialRecord.Margin_Recoupable_Costs__c= Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Margin_Non_Recoupable_Costs__c'){
                   currentFinancialRecord.Margin_Non_Recoupable_Costs__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Margin_Mechanicals__c'){
                   currentFinancialRecord.Margin_Mechanicals__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }                   
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='MG__c'){
                   currentFinancialRecord.MG__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Overages__c'){
                   currentFinancialRecord.Overages__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }                   
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Net_OCF__c'){
                   currentFinancialRecord.Net_OCF__c= Decimal.valueof(labelWithData.get(lab).trim()) ;
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Contribution__c'){
                   currentFinancialRecord.Contribution__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);  
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='ROI__c'){
                   currentFinancialRecord.ROI__c= Decimal.valueof(labelWithData.get(lab).trim());
                   fieldsNotMatched.remove(lab);                     
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Cash_on_Cash__c'){
                   currentFinancialRecord.Cash_on_Cash__c= Decimal.valueof(labelWithData.get(lab).trim()); 
                   fieldsNotMatched.remove(lab);                   
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Total_Marketing_Budget__c'){
                   currentFinancialRecord.Total_Marketing_Budget__c= Decimal.valueof(labelWithData.get(lab).trim()); 
                   fieldsNotMatched.remove(lab);                   
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Marketing_Percent__c'){
                   currentFinancialRecord.Marketing_Percent__c= Decimal.valueof(labelWithData.get(lab).trim()); 
                   fieldsNotMatched.remove(lab);                   
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Central_Origination_Costs__c'){
                   currentFinancialRecord.Central_Origination_Costs__c= Decimal.valueof(labelWithData.get(lab).trim()); 
                   fieldsNotMatched.remove(lab);                   
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Central_Marketing_Costs__c'){
                   currentFinancialRecord.Central_Marketing_Costs__c= Decimal.valueof(labelWithData.get(lab).trim()); 
                   fieldsNotMatched.remove(lab);                   
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Local_Marketing_Costs__c'){
                   currentFinancialRecord.Local_Marketing_Costs__c= Decimal.valueof(labelWithData.get(lab).trim()); 
                   fieldsNotMatched.remove(lab);                   
                   }
                   if(labelWithData.get(lab)!='' && labelWithData.get(lab)!=NULL && allFieldsLabelToApiNameMap.get(lab)=='Theatrical_Marketing_Costs__c'){
                   currentFinancialRecord.Theatrical_Marketing_Costs__c= Decimal.valueof(labelWithData.get(lab).trim()); 
                   fieldsNotMatched.remove(lab);                   
                   }
           }
           
        update currentFinancialRecord;
        
        if(fieldsNotMatched.size()>=1){
        ApexPages.Message infoMessage = new ApexPages.Message(ApexPages.severity.INFO,'The file <b>'+csvFileName+'</b> has been partially imported as the following fields '+fieldsNotMatched+' did not match with any field labels on Salesforce or there was no data entered for these fields in the file,please check the column labels and update again if necessary.');
        ApexPages.addMessage(infoMessage);
        } else{
        ApexPages.Message infoMessage = new ApexPages.Message(ApexPages.severity.INFO,'The file <b>'+csvFileName+'</b> has been imported successfully, click the button "Back to Financial Data Record" to navigate back to the financial record');
        ApexPages.addMessage(infoMessage);
        }
        
        }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occurred while importing data, please make sure the input file : <b>'+csvFileName+'</b> is correct.');
            ApexPages.addMessage(errorMessage);
        }  
        
  }
        /************************************
        Method Name: returnToRecord
        Purpose: Method to return to the current Financial record
        *************************************/
       public Pagereference returnToRecord(){
           Pagereference currentFinancialDetailPage = new Pagereference('/'+currentFinancialRecord.id);
           return currentFinancialDetailPage;
       }
}