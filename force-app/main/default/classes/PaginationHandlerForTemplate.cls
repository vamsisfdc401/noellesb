/*****************************************************************************************
Class Name: PaginationHandlerForTemplate
Purpose: Apex class for handling pagination for Template materials.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             05/10/2017           Suman                    Initial Development
******************************************************************************************/
public with sharing class PaginationHandlerForTemplate {

    /****private variables****/    // Changed for REL-127
    private List<TemplateWizardController.MaterialDetail> recordList {
        get {
            List<TemplateWizardController.MaterialDetail> curMatList = originalRecordList.values();
            curMatList.sort();
            return curMatList;
        } set;
    }
    private Map<String, TemplateWizardController.MaterialDetail> originalRecordList; 
    private Integer counter = 0;
    
    /****public variables****/     
    public Integer pageSize {get; private set;}
    public Integer currentPageNumber {get; set;}
    
    /************************************
    Method Name: PaginationHandlerForTemplate
    Purpose: Constructor
    *************************************/    
    public PaginationHandlerForTemplate() {
        pageSize = 5;
        currentPageNumber = 1;
        recordList = new List<TemplateWizardController.MaterialDetail>();
        originalRecordList = new Map<String, TemplateWizardController.MaterialDetail>();
    }
    
    /************************************
    Method Name: assignRecordList
    Purpose: setting record list
    *************************************/
    public void assignRecordList(Map<String, TemplateWizardController.MaterialDetail> originalRecordList) {
        this.originalRecordList = originalRecordList;
    }
    
    /************************************
    Method Name: numberOfRecords
    Purpose: number of records
    *************************************/
    public Integer numberOfRecords {
        get {
            return recordList.size();
        }
        private set;
    }
    
    /************************************
    Method Name: numberOfPages
    Purpose: total number of pags
    *************************************/
    public Integer numberOfPages  {
        get {
            if (pageSize <= 0) {
                return recordList.size();
            }
            Integer rem = math.mod(recordList.size(), pageSize);
            Integer div = recordList.size()/pageSize;
            return (rem == 0 ? div : (div + 1));
        }
        private set;
    }
    
    /************************************
    Method Name: updatePaginationCounter
    Purpose: update counter value
    *************************************/
    public void updatePaginationCounter() {
        counter = (currentPageNumber - 1) * pageSize;
    }
    
    /************************************
    Method Name: getRecordsInPage
    Purpose: get list of records to be populated on page
    *************************************/
    public List<TemplateWizardController.MaterialDetail> getRecordsInPage(Integer pageNumber) {
        if(pageNumber > 0) {
            Integer startIndex = (pageNumber - 1) * pageSize;
            Integer endIndex = (pageNumber * pageSize) - 1;
            
            if (endIndex > (recordList.size() - 1)) {
                endIndex = recordList.size() - 1;
            }
            
            List<TemplateWizardController.MaterialDetail> pageRecords = new List<TemplateWizardController.MaterialDetail>();
            Integer j = 0;
            for (Integer i = startIndex; i <= endIndex; i ++) {
                pageRecords.add(recordList[i]);
            }
            return pageRecords;
        }
        return null;
    }
    
    /************************************
    Method Name: getData
    Purpose: get records on page
    *************************************/
    public List<TemplateWizardController.MaterialDetail> getData() {
        return getRecordsInPage(currentPageNumber);
    }
    
    /************************************
    Method Name: nextPage
    Purpose: for navigating to next page
    *************************************/
    public void nextPage() {
        if ((currentPageNumber + 1) <= numberOfPages) {
            currentPageNumber ++;
        }
        counter = counter + pageSize;
    }
    
    /************************************
    Method Name: previousPage
    Purpose: for navigating to previous page
    *************************************/
    public void previousPage() {
        if ((currentPageNumber - 1) >= 0) {
            currentPageNumber --;
        }
        counter = counter - pageSize;
    }
    
    /************************************
    Method Name: firstPage
    Purpose: for navigating to first page
    *************************************/
    public void firstPage() {
        currentPageNumber = 1;
        counter = 0;
    }
    
    /************************************
    Method Name: lastPage
    Purpose: for navigating to last page
    *************************************/
    public void lastPage() {
        currentPageNumber = numberOfPages;
        
        if (math.mod(recordList.size(), pageSize) == 0) {
            counter = pageSize * ((recordList.size()/pageSize)-1);
        } else if (math.mod(recordList.size(), pageSize) != 0) {
            counter = pageSize * ((recordList.size()/pageSize));
        }
    }
    
    /************************************
    Method Name: getDisableNext
    Purpose: disbale next button
    *************************************/  
    public Boolean getDisableNext() {   
        if ((counter + pageSize) >= recordList.size()) {
            return FALSE;
        }
        else {
            return TRUE;
        }
    }
    
    /************************************
    Method Name: getDisablePrevious
    Purpose: for rendering pagination buttons
    *************************************/  
    public Boolean getDisablePrevious() {   
        if(counter == 0) {
            return FALSE;
        }
        else {
            return TRUE;
        }
    }
    
    /************************************
    Method Name: getPageList
    Purpose: get list of pages
    *************************************/
    public List<SelectOption> getPageList() {
        List<SelectOption> tempOpList = new List<SelectOption>();
        if (numberOfPages > 0) {
            for (Integer i = 1; i <= numberOfPages; i ++) {
                tempOpList.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
            }
        }
        
        return tempOpList;
    }
}