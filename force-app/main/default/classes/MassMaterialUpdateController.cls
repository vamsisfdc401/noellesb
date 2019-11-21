/*****************************************************************************************
Class Name: MassMaterialUpdateController
Purpose: Apex class for handling Mass Material Update functional pages and logic.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/11/2017           Suman                    Initial Development
******************************************************************************************/
public with sharing class MassMaterialUpdateController 
{
    // Private Variables
    @TestVisible private Boolean forceInclude = false;
    private String retUrl;
    private String[] csvFileLines {get;set;}
    private Set<String> materialNumberSet;
    private Set<String> filteredMatNoSet;
    private Map<String, Id> materialNoInstanceMap;
    private Map<String, String> matNoTerritoryMap;  // Added for REL-103
    private Map<String, String> matNoItemTypeMap; //USST-2828
    private Map<String, String> matNoLabelCodeMap; //USST-3021
    private Map<String, String> matNoSubLabelMap; //USST-3021
    private String matTypeSet = '';
    private User currentUser;
    
    // Public Variables
    public Mass_Update_Header__c header {get; set;}
    public Id recId {get; private set;}
    public Boolean allowToGoNext {get; private set;}
    public Blob csvFileBody {get;set;}
    public string csvAsString {get;set;}
    public string csvContentType {get;set;}
    public Boolean hasError {get; private set;}
    public List<ValidationMessage> errorMessages {get; private set;}
    // Added for REL-103
    public Boolean isPHEUser {
        get {
            return (currentUser != null && currentUser.Profile.Name == 'Third Party User' && currentUser.Label_Code__c == '59 - Paramount');
        }
        private set;
    }
    public Integer totalUniqueMatNos {
        get {
            return (materialNumberSet != null ? materialNumberSet.size() : 0);
        }
        private set;
    }
    public Integer totalEligibleMatNos {
        get {
            return (materialNoInstanceMap != null ? materialNoInstanceMap.size() : 0);
        }
        private set;
    }
    public Integer totalErroneousMatNos {
        get {
            return (totalUniqueMatNos - totalEligibleMatNos);
        }
        private set;
    }
    
    // Empty Constructor
    public MassMaterialUpdateController()
    {
        retUrl = apexpages.currentpage().getparameters().get('retURL');
        recId = apexpages.currentpage().getparameters().get('id');
        if(recId != null)
        {
            header = [SELECT Id, Name, Description__c, Content_Material_Type__c, Status__c FROM Mass_Update_Header__c WHERE Id=:recId];
            if(header != null && header.Content_Material_Type__c != null)
            {
                matTypeSet = header.Content_Material_Type__c;
            }
        }
        else
            header = new Mass_Update_Header__c();
        hasError = false;
        allowToGoNext = false;
        errorMessages = new List<ValidationMessage>();
        
        // Fetching current user details.
        currentUser = [SELECT Id, Profile.Name, UserRole.Name, Label_Code__c, Brand_Group__c, Master_Data__c FROM User WHERE ID =:userInfo.getUserID()];       
    }
    
    // Following method is responsible to save the header.
    public void saveHeader()
    {
        if(header != null && recId == null)
        {
            try
            {
                insert header;
                recId = header.Id;
                header = [SELECT Id, Name, Description__c, Content_Material_Type__c, Status__c FROM Mass_Update_Header__c WHERE Id=:recId];
            }
            catch(exception ex){            
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: '+ex.getMessage()));              
            }
        }
    }
    
    // Following method is responsible to find materials and initiating the request creation.
    public PageReference btnUploadCSV() {    // Changed for REL-190
        try {
            //Initializing variables and collections
            csvFileLines = new String[]{};
            materialNumberSet = new Set<String>();
            filteredMatNoSet = new Set<String>();
            materialNoInstanceMap = new Map<String, Id>();
            matNoTerritoryMap = new Map<String, String>();  // Added for REL-103
            matNoItemTypeMap = new Map<String, String>(); //USST-2828
            matNoLabelCodeMap = new Map<String, String>(); //USST-3021
            matNoSubLabelMap = new Map<String, String>(); //USST-3021
            
            
            //reading csv file
            if(string.valueof(csvFileBody) != null && string.valueof(csvFileBody) != ''){
                csvAsString = csvFileBody.toString();
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please upload valid file.')); 
                return null;  
            }    
            
            csvFileLines = csvAsString.split('\n');
            
            //looping over csv file and adding criteria to a set
            for(Integer i = 1; i < csvFileLines.size(); i ++){                
                string[] csvRecordData = csvFileLines[i].split(',');
                String val = (csvRecordData[0]).trim().replaceAll('"', '');
                
                // If value is already added in the list, ignore.
                if(materialNumberSet.contains(val) || val == '')
                    continue;
                materialNumberSet.add(val);
            }
            
            // Validationg the uploaded data.
            if(materialNumberSet.size() > 0)
            {
                if(isValidMaterialSet(materialNumberSet))
                {
                    saveMaterialRequests();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Requests are uploaded successfully.'));
                    return submit();    // Changed for REL-190
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please find the below errors.'));
                    hasError = true;
                }
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Please upload the file with data.'));
            }
        }
        catch(exception ex){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Please contact system admin. '+ex.getMessage()));              
        }
        return null;    // Changed for REL-190
    }
    
    /*****************************************************************
    Method Name: isValidMaterialSet
    Purpose : Following method is used for validating the material set in CSV.
    **************************************************************/
    public Boolean isValidMaterialSet(Set<String> materialNumberSet)
    {
        errorMessages.clear();
        hasError = false;
        filteredMatNoSet.addAll(materialNumberSet);
        
        // Checking if the material numbers are there in system.
        for(Material__c mat : MassMaterialUpdateUtility.fetchMaterials(filteredMatNoSet))
        {
            materialNoInstanceMap.put(mat.Material_Number__c, mat.Id);
            // Specific to test case.
            if(Test.isRunningTest() && forceInclude)
                matNoTerritoryMap.put(mat.Material_Number__c, mat.Territory__c);
        }
        
        // Checking material number available in user's access level.
        Set<String> availableMatNos = new Set<String>();
        Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        //USST-3021 --- start
        List<ID> paramountSubLabelCodeIDs = new List<ID>();
        List<Sub_Label_Code__c> paramountSublabelCodes = [Select Id, Name, Sub_Label_Code_ID__c from Sub_Label_Code__c where Name LIKE '%PAR - %' OR Sub_Label_Code_ID__c = '59'];
        for (Sub_Label_Code__c sc : paramountSublabelCodes) {
            paramountSubLabelCodeIDs.add(sc.Id);
        }
        //USST-3021 --- end
        for(Material__c mat : [SELECT Id, Material_Number__c, Material_Type__c, Territory__c, Item_Type__c, Sub_Label_Code_Lookup__c, Label_Code__c  
                               FROM Material__c 
                               WHERE Material_Number__c IN: filteredMatNoSet AND RecordTypeId!=:recTypeId AND Material_Status__c!='Deleted']) //USST-2828 //USST-3021
        {
            availableMatNos.add(mat.Material_Number__c);
            String matType;
            if(mat.Material_Type__c == 'FERT')
                matType = 'FERT';
            else if(mat.Material_Type__c == 'ROH' || mat.Material_Type__c == 'Z009')
                matType = 'COMP';
            if(!matTypeSet.contains(matType))
            {
                if(matTypeSet.trim() != '')
                    matTypeSet += ';';
                matTypeSet += matType;
            }
            matNoTerritoryMap.put(mat.Material_Number__c, mat.Territory__c);
            matNoItemTypeMap.put(mat.Material_Number__c, mat.Item_Type__c);
            matNoLabelCodeMap.put(mat.Material_Number__c, mat.Label_Code__c); //USST-3021
            matNoSubLabelMap.put(mat.Material_Number__c, String.valueOf(mat.Sub_Label_Code_Lookup__c)); //USST-3021
        }
        
        // Test Purpose
        Set<String> erroneousMatNos = new Set<String>();
        // Validating material number availablity.
        for(String matNo : filteredMatNoSet)
        {
            if(!materialNoInstanceMap.containsKey(matNo))
            {
                ValidationMessage msg = new ValidationMessage();
                msg.materialNumber = matNo;
                msg.errorMessage = 'This material number does not exist in the system.';
                errorMessages.add(msg);
            }
            // If user does not have access to the records.
            else if(!availableMatNos.contains(matNo))
            {
                if(Test.isRunningTest() && forceInclude)
                    erroneousMatNos.add(matNo);
                
                if((Test.isRunningTest() && !forceInclude) || !Test.isRunningTest())
                    materialNoInstanceMap.remove(matNo);
                
                ValidationMessage msg = new ValidationMessage();
                msg.materialNumber = matNo;
                msg.errorMessage = 'User does not have access to this material number.';
                errorMessages.add(msg);
            }
            //USST-2828 --- start
            else if (matNoItemTypeMap.get(matNo) == 'D (Display Vehicle)' && matNoTerritoryMap.get(matNo) == 'US & CDN') {
                if((Test.isRunningTest() && !forceInclude) || !Test.isRunningTest())
                    materialNoInstanceMap.remove(matNo);
                
                ValidationMessage msg = new ValidationMessage();
                msg.materialNumber = matNo;
                msg.errorMessage = 'Update Material cannot be created for Display Vehicle with US & CDN territory';
                errorMessages.add(msg);
            }
            //USST-2828 --- end
            //USST-3021 --- start
            else if (matNoItemTypeMap.get(matNo) == 'D (Display Vehicle)' && paramountSubLabelCodeIDs.size() > 0 && paramountSubLabelCodeIDs.contains(matNoSubLabelMap.get(matNo)) && matNoLabelCodeMap.get(matNo) != '59 - Paramount') {
                if((Test.isRunningTest() && !forceInclude) || !Test.isRunningTest())
                    materialNoInstanceMap.remove(matNo);
                
                ValidationMessage msg = new ValidationMessage();
                msg.materialNumber = matNo;
                msg.errorMessage = 'Update Material cannot be created. If the Item Type is Display and the Sub-Label Code is for Paramount, then the Label Code must be 59 - Paramount.';
                errorMessages.add(msg);
            }
            //USST-3021 --- end
        }
        
        // Changed for REL-103
        // Filter out the material numbers having already active (Open) material update request.
        for(Material_Update_Request__c mreq : MassMaterialUpdateUtility.fetchMaterialRequests(materialNoInstanceMap.keySet(), 'Open'))
        {
            // If territory is not defined.
            if(matNoTerritoryMap.get(mreq.Material_Number__c) == null)
            {
                ValidationMessage msg = new ValidationMessage();
                msg.materialNumber = mreq.Material_Number__c;
                msg.errorMessage = 'This material doesnot have territory defined.';
                errorMessages.add(msg);
            }
            else
            {
                if((mreq.Sales_Org__c == 'V100' && matNoTerritoryMap.get(mreq.Material_Number__c).containsIgnoreCase('US')) ||
                   (mreq.Sales_Org__c == 'V800' && matNoTerritoryMap.get(mreq.Material_Number__c).containsIgnoreCase('CDN')))
                {
                    filteredMatNoSet.remove(mreq.Material_Number__c);
                    materialNoInstanceMap.remove(mreq.Material_Number__c);
                    
                    ValidationMessage msg = new ValidationMessage();
                    msg.materialNumber = mreq.Material_Number__c;
                    msg.errorMessage = 'There is an existing update request ('+ mreq.Name + (isPHEUser ? ' for Sales Org: '+mreq.Sales_Org__c : '') +' under '+ mreq.Mass_Update_Header__r.Name +') for the same material.';
                    errorMessages.add(msg);
                }
            }
        }
        
        // Removing erroneous data
        if(Test.isRunningTest() && forceInclude && erroneousMatNos.size() > 0)
        {
            for(String matNo : erroneousMatNos)
                materialNoInstanceMap.remove(matNo);
        }
        
        if(errorMessages.size() > 0)
            return false;
        return true;
    }
    
    /*****************************************************************
    Method Name: ProceedAnyWay
    Purpose : Following method is used for go ahead with remaining data if having any error.
    **************************************************************/
    public PageReference proceedAnyWay() {    // Changed for REL-190
        saveMaterialRequests();
        hasError = false;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Requests are uploaded successfully.'));
        return submit();    // Changed for REL-190
    }
    
    /*****************************************************************
    Method Name: saveMaterialRequests
    Purpose : Following method is used to create material update request from material numbers.
    **************************************************************/
    public void saveMaterialRequests()
    {
        if(materialNoInstanceMap.size() == 0)
            return;
        
        header.Content_Material_Type__c = matTypeSet;
        update header;
        
        List<Material_Update_Request__c> insertableRequests = new List<Material_Update_Request__c>();
        for(String matNo : materialNoInstanceMap.keySet())
        {
            // Changed for REL-103
            String territory = matNoTerritoryMap.get(matNo);
            if(isPHEUser || territory != 'US & CDN')
            {
                Material_Update_Request__c req = new Material_Update_Request__c();
                req.Mass_Update_Header__c = header.Id;
                req.Material_Number__c = matNo;
                req.Source_Material__c = materialNoInstanceMap.get(matNo);
                String slOrg = 'V100';
                if(territory == 'CDN')
                    slOrg = 'V800';
                req.Sales_Org__c = slOrg;
                insertableRequests.add(req);
            }
            // If Non-PHE user requesting for US & CDN material.
            else
            {
                Material_Update_Request__c req1 = new Material_Update_Request__c();
                req1.Mass_Update_Header__c = header.Id;
                req1.Material_Number__c = matNo;
                req1.Source_Material__c = materialNoInstanceMap.get(matNo);
                req1.Sales_Org__c = 'V100';
                insertableRequests.add(req1);
                Material_Update_Request__c req2 = new Material_Update_Request__c();
                req2.Mass_Update_Header__c = header.Id;
                req2.Material_Number__c = matNo;
                req2.Source_Material__c = materialNoInstanceMap.get(matNo);
                req2.Sales_Org__c = 'V800';
                insertableRequests.add(req2);
            }
        }
        
        if(insertableRequests.size() > 0)
            insert insertableRequests;
        
        allowToGoNext = true;
    }
    
    /************************ Redirect Operations *************************/
    // It is responsible to handle the submit operation.
    public PageReference submit()
    {
        if(header.Id != null)
            return new PageReference('/'+header.Id);
        return cancel();
    }
    
    // Handle the cancel action.
    public PageReference cancel()
    {
        if(retUrl != null)
        {
            if(retUrl.contains('MassUpdateHeaderView'))
                return new PageReference('/apex'+retURL);
            return new PageReference(retURL);
        }
        return new PageReference('/home/home.jsp');
    }
    
    // Following class to grab the errorneous material numbers.
    public class ValidationMessage
    {
        public String materialNumber {get; set;}
        public String errorMessage {get; set;}
    }
}