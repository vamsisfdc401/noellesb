/*****************************************************************************************
Class Name: TemplateWizardController
Purpose: This is the controller of Template Creation Wizard.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             10/03/2017           Suman                    Initial Development
******************************************************************************************/
public with sharing class TemplateWizardController {
    
    // Private Variables
    private Boolean hasError = false;
    private Boolean confirmWarning = false;
    private Boolean hasCloneExecuted = false;
    @testVisible private String retUrl;
    @testVisible private String cloneSourceId;
    private Integer localMatId = 0;
    private Integer localCompId = 0;
    private String selectedBrandGroup = '';
    @testVisible private Map<String, MaterialDetail> materials;
    
    // Public Variables
    public User currentUser {get; private set;}
    public Id recId {get; private set;}
    public Boolean isNewTemplate {get; private set;}
    public Boolean isCloningContext {get; private set;}
    public Material_Template__c template {get; set;}
    public Material_Detail__c curMatDetail {get; set;}
    public Integer curMatQty {get; set;}
    public List<ComponentDetail> associatedComponents {get; set;}
    public Integer compIndex {get; set;}
    public String selectedMatId {get; set;}
    public Boolean isParamountUser {get; set;} //USST-2783
    public List<MaterialDetail> sortedMaterials {    // Added for REL-127
        get {
            List<MaterialDetail> tmpList = new List<MaterialDetail>();
            if (materials != null && materials.size() > 0) {
                tmpList = materials.values();
                tmpList.sort();
            }
            return tmpList;
        }
        private set;
    }
    public Integer totalMaterials {
        get {
            return (materials != null ? materials.size() : 0);
        }
        private set;
    }
    public Boolean isPHEUser {
        get {
            return (currentUser != null && currentUser.Profile.Name == 'Third Party User' && currentUser.Label_Code__c == '59 - Paramount');
        }
        private set;
    }
    public Boolean hasEditAccess {
        get {
            if (recId != null) {
                List<UserRecordAccess> accs = [SELECT RecordId, HasEditAccess 
                                               FROM UserRecordAccess 
                                               WHERE UserId=:currentUser.Id AND RecordId=:recId];
                if (accs != null && accs.size() > 0) {
                    return accs[0].HasEditAccess;
                }
            }
            // For new template, give access to true.
            return true;
        } 
        private set;
    }
    // Changes for REL-131
    public List<SelectOption> availableBrandGroups {
        get {
            List<SelectOption> tmpList = new List<SelectOption>();
            // If current user is from Paramount team.
            tmpList.add(new SelectOption('', '--None--'));
            if (isPHEUser) {
                for (Paramount_Brand_Group__c pBrand : [SELECT Name FROM Paramount_Brand_Group__c ORDER BY Sequence__c]) {
                    tmpList.add(new SelectOption(pBrand.Name, pBrand.Name));
                }
            }
            // If current user is from Universal team.
            else {
                for (Universal_Brand_Group__c uBrand : [SELECT Name FROM Universal_Brand_Group__c ORDER BY Sequence__c]) {
                    tmpList.add(new SelectOption(uBrand.Name, uBrand.Name));
                }
            }
            return tmpList;
        } set;
    }
    public PaginationHandlerForTemplate templatePagination {get; set;}
    
    // Constructor
    public TemplateWizardController(ApexPages.StandardController stdController) {
        // Fetching current user details.
        currentUser = [SELECT Id, Profile.Name, UserRole.Name, Label_Code__c, Brand_Group__c, Master_Data__c 
                       FROM User 
                       WHERE ID =:userInfo.getUserID()];       
        //USST-2783 --- start
        if (currentUser.Label_Code__c == '59 - Paramount'){
            isParamountUser = true;
        }
        //USST-2783 --- end
        
        templatePagination = new PaginationHandlerForTemplate();
        materials = new Map<String, MaterialDetail>();
        templatePagination.assignRecordList(materials);
        
        recId = stdController.getId();
        retUrl = apexpages.currentpage().getparameters().get('retURL');
        
        // Getting cloning details.
        cloneSourceId = apexpages.currentpage().getparameters().get('cloneSourceId');
        isCloningContext = false;
        
        // If processing existing record.
        if (recId != null) {
            isNewTemplate = false;
            // Fetching header template details.
            if (!Test.isRunningTest()) {
                stdController.addFields(new List<String>{'Id', 'Name', 'Template_Name__c', 'Brand_Group__c', 'Is_Active__c', 'OwnerId'});
                template = (Material_Template__c) stdController.getRecord();
            }
            else {
                template = [SELECT Id, Name, Template_Name__c, Brand_Group__c, Is_Active__c, OwnerId
                            FROM Material_Template__c WHERE Id=:recId];
            }
            selectedBrandGroup = template.Brand_Group__c;
            
            // Fetching associated materials and their child components.
            getExistingStructure();
        }
        // If executing under cloning context.
        else if (cloneSourceId != null) {
            try {
                Id clnSourceId = Id.valueOf(String.escapeSingleQuotes(cloneSourceId));
                isCloningContext = true;
                isNewTemplate = true;
                
                // Fetching source template details.
                List<Material_Template__c> srcTemplate = [SELECT Name, Template_Name__c, Brand_Group__c, Is_Active__c 
                                                          FROM Material_Template__c
                                                          WHERE Id=:clnSourceId];
                // Basic Setup.
                if (srcTemplate != null && srcTemplate.size() > 0) {
                    template = srcTemplate[0].clone();
                    selectedBrandGroup = template.Brand_Group__c;
                    template.Is_Active__c = true;
                    template.OwnerId = currentUser.Id;
                }
            }
            catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: '+ex.getMessage()));
            }
        }
        else {
            isNewTemplate = true;
            // Instantiating new template instance.
            template = new Material_Template__c();
            template.Brand_Group__c = currentUser.Brand_Group__c;
            if (template.Brand_Group__c != null) {
                selectedBrandGroup = template.Brand_Group__c;
                BrandGroupAbbreviationMapping__c abbrObj = BrandGroupAbbreviationMapping__c.getInstance( template.Brand_Group__c );
                if (abbrObj != null) {
                    template.Template_Name__c = abbrObj.Abbreviation__c + ': ';
                }
            }
            template.Is_Active__c = true;
            template.OwnerId = currentUser.Id;
        }
    }
    
    // *******************************************************
    // ***************** Operational Methods *****************
    // *******************************************************
    // Following method configures the materials and components from source to cloned one.
    private void configureCloneMaterials() {
        try {
            Map<Material_Detail__c, List<Component_Detail__c>> clonedMatComponents = new Map<Material_Detail__c, List<Component_Detail__c>>();
            List<Material_Detail__c> insertableMatDetails = new List<Material_Detail__c>();
            List<Component_Detail__c> insertableCompDetails = new List<Component_Detail__c>();
            
            // Fetching souce template materials and their child components.
            for (Material_Detail__c matDet : [SELECT Format__c, Item_Code__c, Item_Type__c, Quantity__c, Retailer_Rental__c, Sequence__c, Subformat__c, Sales_Planning_Group__c, 
                                             (SELECT Component_Type__c, Existing_Component__c, Sequence__c
                                              FROM Component_Details__r)
                                             FROM Material_Detail__c
                                             WHERE Material_Template__c=:cloneSourceId
                                            ]) { //Added subformat and sales planning group for USST-2783
                // Cloned Material.
                Material_Detail__c clonedMatDet = matDet.clone();
                clonedMatDet.Material_Template__c = recId;
                
                insertableMatDetails.add(clonedMatDet);
                
                if (matDet.Component_Details__r != null && matDet.Component_Details__r.size() > 0) {
                    clonedMatComponents.put(clonedMatDet, matDet.Component_Details__r);
                }
            }
            
            // Inserting cloned material details.
            if (insertableMatDetails.size() > 0) {
                insert insertableMatDetails;
            }
            
            // Preparing cloned child components.
            for (Material_Detail__c matDet : clonedMatComponents.keySet()) {
                for (Component_Detail__c compDet : clonedMatComponents.get(matDet)) {
                    Component_Detail__c clonedCompDet = compDet.clone();
                    clonedCompDet.Material_Detail__c = matDet.Id;
                    insertableCompDetails.add(clonedCompDet);
                }
            }
            
            // Inserting cloned component details.
            if (insertableCompDetails.size() > 0) {
                insert insertableCompDetails;
            }
            
            // Fetching associated materials and their child components.
            getExistingStructure();
        }
        catch (Exception ex) {
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: '+ex.getMessage()));
        }
    }
    
    // Following method fetches existing structure.
    private void getExistingStructure() {
        for (Material_Detail__c matDet : [SELECT Id, Format__c, Item_Code__c, Item_Type__c, Quantity__c, Retailer_Rental__c, Sequence__c, Subformat__c, Sales_Planning_Group__c, 
                                 (SELECT Id, Component_Type__c, Existing_Component__c, Existing_Component__r.Name, Sequence__c,
                                  Is_Existing__c, Existing_Component__r.Material_Number__c, Material_Detail__c 
                                  FROM Component_Details__r ORDER BY Sequence__c)
                                 FROM Material_Detail__c
                                 WHERE Material_Template__c=:recId
                                 ORDER BY Sequence__c
                                ]) { //Added subformat and sales planning group for USST-2783
            // Preparing material instance.
            MaterialDetail ins = new MaterialDetail(matDet);
            
            // Preparing child components.
            if (matDet.Component_Details__r != null && matDet.Component_Details__r.size() > 0) {
                for (Component_Detail__c compDet : matDet.Component_Details__r) {
                    ins.childComponents.put(compDet.Id, new ComponentDetail(compDet));
                }
            }
            materials.put(matDet.Id, ins);
        }
    }
    
    // Following method handles the Template commit in system.
    public void saveTemplate() {
        hasError = false;
        confirmWarning = false;
        try {
            // Validate Template information.
            if (template.Template_Name__c == null || template.Template_Name__c.trim() == '') {
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: Please provide the template name.'));              
                return;
            }
            else if (template.Brand_Group__c == null) {
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: Please choose the brand group.'));
                return;
            }
            
            // Prepare template name.
            BrandGroupAbbreviationMapping__c abbrObj = BrandGroupAbbreviationMapping__c.getInstance( template.Brand_Group__c );
            String brandAbbr = '';
            if (abbrObj != null) {
                brandAbbr = abbrObj.Abbreviation__c;
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'Brand Group abbreviation is not found.'));
            }
            if (!template.Template_Name__c.startsWith(brandAbbr)) {
                template.Template_Name__c = brandAbbr + ': ' + template.Template_Name__c;
            }
            
            // Checking Template name duplicasy
            if (TemplateUtility.isDuplicateTemplate(template.Template_Name__c, recId)) {
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 
                                    'ERROR: Template Name: '+template.Template_Name__c+' is duplicate in the system.'));
                return;
            }
            
            // Saving the template.
            upsert template;
            recId = template.Id;
        }
        catch (DmlException dex) {
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: '+dex.getDmlMessage(0)));              
        }
        catch (Exception ex) {
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: '+ex.getMessage()));              
        }
    }
    
    // Following method handles the material and its components commit in system.
    public void saveMaterial() {
        hasError = false;
        confirmWarning = false;
        
        // Validate Material. 
        if (curMatDetail.Item_Code__c == null) {
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: Please choose the material item code.'));
            return;
        }
        else if (curMatDetail.Format__c == null) {
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: Please choose the material format.'));
            return;
        }
        else if (curMatDetail.Item_Code__c == 'BF - BABY FERT' && curMatDetail.Format__c != 'DVD') {
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 
                                'ERROR: Material format should be set to DVD when creating a Baby FERT.'));
            return;
        }
        else if (curMatQty <= 0 || curMatQty > 100) {
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: Please choose quantity between 1 to 100.'));
            return;
        }
        // Assigning quantity field.
        curMatDetail.Quantity__c = curMatQty;
        
        // Validate components.
        for (ComponentDetail compDet : associatedComponents) {
            if((compDet.isExisting && compDet.instance.Existing_Component__c == null) || 
               (!compDet.isExisting && compDet.instance.Component_Type__c == null)) {
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 
                                    'ERROR: Please choose component type or existing component, else remove the component line.'));
                return;
            }
        }
        
        try {
            // Upserting the current material.
            upsert curMatDetail;
            
            // updating the component details with material detail Id.
            List<Component_Detail__c> compDetList = new List<Component_Detail__c>();
            for (ComponentDetail compDet : associatedComponents) {
                if (compDet.instance.Material_Detail__c == null) {
                    compDet.instance.Material_Detail__c = curMatDetail.Id;
                }
                compDetList.add(compDet.instance);
            }
            
            // Commiting the changes.
            upsert compDetList;
            
            // Pushing chnages in wrapper.
            MaterialDetail matDet = new MaterialDetail(curMatDetail.clone(true, false, false, false));
            for (ComponentDetail compDet : associatedComponents) {
                matDet.childComponents.put(compDet.instance.Id, compDet);
            }
            materials.put(curMatDetail.Id, matDet);
        }
        catch (DmlException dex) {
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: '+dex.getDmlMessage(0)));              
        }
        catch (Exception ex) {
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: '+ex.getMessage()));              
        }
    }
    
    // Following method helps to add new component.
    public void addComponent() {
        ComponentDetail comp = new ComponentDetail(new Component_Detail__c(Sequence__c=(associatedComponents.size() + 1)));     // REL-127 
        associatedComponents.add(comp);
    }
    
    // Following method helps to add existing component.
    public void addExistingComponent() {
        ComponentDetail comp = new ComponentDetail(new Component_Detail__c(Sequence__c=(associatedComponents.size() + 1)));     // REL-127
        comp.isExisting = true;
        associatedComponents.add(comp);
    }
    
    // Following method helps to extract the material number from selected component.
    public void fetchCompDetails() {
        if (associatedComponents != null && associatedComponents.size() > 0 && compIndex != null && 
           associatedComponents[compIndex] != null && associatedComponents[compIndex].instance.Existing_Component__c != null) {
            List<Material__c> comps = [SELECT Name, Material_Number__c 
                                       FROM Material__c 
                                       WHERE Id=:associatedComponents[compIndex].instance.Existing_Component__c];
            if (comps != null && comps.size() > 0) {
                if (comps[0].Material_Number__c != null) {
                    associatedComponents[compIndex].matNumber = comps[0].Material_Number__c;
                }
                associatedComponents[compIndex].compName = comps[0].Name;
            }
        }
    }
    
    // Following method removes the selected component.
    public void removeComponent() {
        if (associatedComponents != null && associatedComponents.size() > 0 && compIndex != null && 
           associatedComponents[compIndex] != null) {
            if (associatedComponents[compIndex].instance.Id != null) {
                delete associatedComponents[compIndex].instance;
            }
            associatedComponents.remove(compIndex);
            
            // Rearranging sequence of remaining components. // REL-127
            if (associatedComponents != null && associatedComponents.size() > 0) {
                Integer compSeq = 1;
                List<Component_Detail__c> upCompList = new List<Component_Detail__c>();
                associatedComponents.sort();
                for (ComponentDetail compDet : associatedComponents) {
                    Component_Detail__c compDetIns = compDet.instance;
                    compDetIns.Sequence__c = compSeq;
                    if (compDetIns.Id != null) {
                        upCompList.add(compDetIns);
                    }
                    compSeq ++;
                }
                
                // Commiting sequence changes
                if (upCompList.size() > 0) {
                    update upCompList;
                }
            }
        }
    }
    
    // Following method helps to add a new material.
    public PageReference addMaterial() {
        curMatDetail = new Material_Detail__c(Material_Template__c=recId, Item_Type__c='S (Single)', Sequence__c=(materials.size() + 1));   // REL-127
        curMatQty = 1;
        associatedComponents = new List<ComponentDetail>();
        return new PageReference('/apex/TemplateDesigner');
    }
    
    // Following method helps to edit the selected material.
    public PageReference editMaterial() {
        if (selectedMatId != null && materials.containsKey(selectedMatId)) {
            hasError = false;
            curMatDetail = materials.get(selectedMatId).instance;
            curMatQty = Integer.valueOf(curMatDetail.Quantity__c);
            associatedComponents = new List<ComponentDetail>();
            if (materials.get(selectedMatId).childComponents != null && materials.get(selectedMatId).childComponents.size() > 0) {
                associatedComponents = materials.get(selectedMatId).childComponents.values();
                associatedComponents.sort(); // Added for REL-127
            }
            return new PageReference('/apex/TemplateDesigner');
        }
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: The material detail record is not found.'));
        return null;
    }
    
    // Following method helps to delete the selected material.
    public void deleteMaterial() {
        if (selectedMatId != null && materials.containsKey(selectedMatId)) {
            hasError = false;
            
            try {
                // Removing material from system.
                delete materials.get(selectedMatId).instance;
                
                // Removing the same from map.
                materials.remove(selectedMatId);
                
                // Setting previous page if there is no child left in this page after deletion
                List<MaterialDetail> pageData = templatePagination.getData();
                if (pageData == null || pageData.size() == 0) {
                    templatePagination.previousPage();
                    Integer noOfPages = templatePagination.numberOfPages;
                }
                // Added for REL-127
                // Rearranging the material sequence
                if (materials != null && materials.size() > 0) {
                    Integer curSeq = 1;
                    List<Material_Detail__c> upMatDetList = new List<Material_Detail__c>();
                    List<MaterialDetail> tmpList = materials.values();
                    tmpList.sort();
                    for (MaterialDetail matDet : tmpList) {
                        Material_Detail__c matDetIns = matDet.instance;
                        if (matDetIns.Id != null) {
                            matDetIns.Sequence__c = curSeq;
                            upMatDetList.add(matDetIns);
                        }
                        curSeq ++;
                    }
                    
                    // Commiting sequence change.
                    if (upMatDetList.size() > 0) {
                        update upMatDetList;
                    }
                }
            }
            catch (DmlException dex) {
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: '+dex.getDmlMessage(0)));              
            }
            catch (Exception ex) {
                hasError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: '+ex.getMessage()));              
            }
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'ERROR: The material detail record is not found.'));
        }
    }
    
    // Following method handles the change of Brand Group in Template.
    public void handleBrandGroupChange() {
        // Brand group is empty.
        if (template.Brand_Group__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Please choose the brand group.'));
            return;
        }
        
        // Evaluating selected brand group abbreviation.
        String selBrandAbbr = '';
        if (selectedBrandGroup != null && selectedBrandGroup.trim() != '') {
            selBrandAbbr = BrandGroupAbbreviationMapping__c.getInstance( selectedBrandGroup ).Abbreviation__c;
        }
        
        // Evaluating selected brand group abbreviation.
        String curBrandAbbr = BrandGroupAbbreviationMapping__c.getInstance( template.Brand_Group__c ).Abbreviation__c;
        
        // Evaluating Template name according to naming convension.
        if (selBrandAbbr != '' && template.Template_Name__c.startsWith(selBrandAbbr)) {
            template.Template_Name__c = template.Template_Name__c.replace(selBrandAbbr, curBrandAbbr);
        }
        else {
            template.Template_Name__c = curBrandAbbr + ': ' + template.Template_Name__c;
        }
        
        // Reassigning selected brand group.
        selectedBrandGroup = template.Brand_Group__c;
    }
    
    // Added for REL-135
    // Following method is used to save the template changes.
    public void saveAction() {
        hasError = false;
        saveTemplate();
        
        // Show success message on proper saving.
        if (!hasError) {
            // If executing from cloning context.
            if (isCloningContext && !hasCloneExecuted) {
                configureCloneMaterials();
                if (hasError) {
                    return;
                }
                else {
                    hasCloneExecuted = true;
                }
            }
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Template is saved successfully.'));
        }
    }
    
    // ******************************************************
    // ***************** Navigation Methods *****************
    // ******************************************************
    // Redirect from first to second page.
    public PageReference redirectFirstToSecondPage() {
        saveTemplate();
        
        if (!hasError) {
            curMatDetail = new Material_Detail__c(Material_Template__c=recId, Item_Type__c='S (Single)');
            curMatQty = 1;
            associatedComponents = new List<ComponentDetail>();
            
            // If executing from cloning context.
            if (isCloningContext && !hasCloneExecuted) {
                configureCloneMaterials();
                hasCloneExecuted = true;
            }
            
            // Added for REL-127
            curMatDetail.Sequence__c = (materials.size() + 1);
            
            return new PageReference('/apex/TemplateDesigner');
        }
        return null;
    }
    
    // Redirect from second to third page.
    public PageReference redirectFirstToThirdPage()
    {
        if (!hasError || (hasError && confirmWarning)) {
            return new PageReference('/apex/TemplateReview');
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 'Please save the changes, otherwise they will be lost. To still proceed, please click it again.'));              
            confirmWarning = true;
        }
        return null;
    }
    
    // Redirect from second to first page.
    public PageReference redirectSecondToFirstPage() {
        if (!hasError || (hasError && confirmWarning)) {
            return new PageReference('/apex/TemplateDescriptor');
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 
                                'Please save the changes, otherwise they will be lost. To still proceed, please click it again.'));              
            confirmWarning = true;
        }
        return null;
    }
    
    // Redirect from second to third page.
    public PageReference redirectSecondToThirdPage() {
        if (!hasError || (hasError && confirmWarning)) {
            return new PageReference('/apex/TemplateReview');
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, 
                                'Please save the changes, otherwise they will be lost. To still proceed, please click it again.'));              
            confirmWarning = true;
        }
        return null;
    }
    
    // Redirect from second to review page.
    public PageReference saveNavigateReviewPage() {
        saveMaterial();
        
        if (!hasError) {
            curMatDetail = new Material_Detail__c(Material_Template__c=recId, Item_Type__c='S (Single)', Sequence__c = (materials.size() + 1));
            curMatQty = 1;
            associatedComponents = new List<ComponentDetail>();
            
            return new PageReference('/apex/TemplateReview');
        }
        return null;
    }
    
    // Redirect from second page to itself.
    public PageReference saveNRepeatPage() {
        saveMaterial();
        
        if (!hasError) {
            curMatDetail = new Material_Detail__c(Material_Template__c=recId, Item_Type__c='S (Single)', Sequence__c = (materials.size() + 1));
            curMatQty = 1;
            associatedComponents = new List<ComponentDetail>();
            
            return new PageReference('/apex/TemplateDesigner');
        }
        return null;
    }
    
    // Redirect from Third to first page.
    public PageReference redirectThirdToFirstPage() {
        return new PageReference('/apex/TemplateDescriptor');
    }
    
    // Navigate to exit point.
    public PageReference completeTask() {
        if (isNewTemplate) {
            return new PageReference('/'+recId);
        }
        else if (retUrl != null) {
            if (retUrl.contains('TemplateDescriptor')) {
                return new PageReference('/apex'+retURL);
            }
            return new PageReference(retURL);
        }
        return new PageReference('/home/home.jsp');
    }
    
    // Handle the cancel action.
    public PageReference cancel() {
        if (retUrl != null) {
            if(retUrl.contains('TemplateDescriptor')) {
                return new PageReference('/apex'+retURL);
            }
            return new PageReference(retURL);
        }
        return new PageReference('/home/home.jsp');
    }
    
    // ***************************************************
    // ***************** Wrapper Classes *****************
    // ***************************************************
    // Material wrapper
    public class MaterialDetail implements Comparable {
        public Boolean isExisting {get; private set;}
        public Material_Detail__c instance {
            get; 
            set {
                instance = value;
                isExisting = false;
                if (instance.Id != null) {
                    isExisting = true;
                }
            }
        }
        private Map<String, ComponentDetail> childComponents;   // Changed for REL-127
        public List<ComponentDetail> sortedComponentList {      // Added for REL-127
            get {
                List<ComponentDetail> compList = this.childComponents.values();
                compList.sort();
                return compList;
            }
            set;
        }
        public Integer totalChildCount {
            get {
                return childComponents.size();
            }
            private set;
        }
        
        // Constructor
        public MaterialDetail(Material_Detail__c instance)
        {
            this.instance = instance;
            childComponents = new Map<String, ComponentDetail>();
        }
        
        // Interface method helps to sort. 
        public Integer compareTo(Object obj) 
        {
            MaterialDetail mat = (MaterialDetail) obj;
            if (mat.instance.Sequence__c == null || this.instance.Sequence__c == null) {
                return 1;
            }
            Integer curVal = Integer.valueOf(String.valueOf(mat.instance.Sequence__c));
            Integer comparingVal = Integer.valueOf(this.instance.Sequence__c);
            
            if (curVal == comparingVal) {
                return 0;
            }
            else if (curVal > comparingVal) {
                return -1;
            }
            return 1;
        }
    }
    
    // Component wrapper
    public class ComponentDetail implements Comparable {
        public Boolean isExisting {get; set;}
        public String compName {get; private set;}
        public String matNumber {get; private set;}
        public Component_Detail__c instance {get; set;}
        
        // Constructor
        public ComponentDetail(Component_Detail__c instance) {
            this.instance = instance;
            this.isExisting = false;
            if (instance.Is_Existing__c) {
                this.isExisting = true;
            }
            if (instance.Existing_Component__r.Name != null) {
                this.compName = instance.Existing_Component__r.Name;
            }
            if (instance.Existing_Component__r.Material_Number__c != null) {
                this.matNumber = instance.Existing_Component__r.Material_Number__c;
            }
        }
        
        // Interface method helps to sort. 
        public Integer compareTo(Object obj) {
            ComponentDetail mat = (ComponentDetail) obj;
            if (mat.instance.Sequence__c == null || this.instance.Sequence__c == null) {
                return 1;
            }
            Integer curVal = Integer.valueOf(String.valueOf(mat.instance.Sequence__c));
            Integer comparingVal = Integer.valueOf(this.instance.Sequence__c);
            
            if (curVal == comparingVal) {
                return 0;
            }
            else if (curVal > comparingVal) {
                return -1;
            }
            return 1;
        }
    }
}