/*****************************************************************************************
Class Name: PaginationHandlerForError
Purpose: Apex class for handling error message pagination.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             20/09/2017           Suman                    Initial Development
******************************************************************************************/
public with sharing class PaginationHandlerForError
{
    /****private variables****/
    private List<MassCloningSelectionController.ErrorMessage> recordMap;
    private List<MassCloningSelectionController.ErrorMessage> recordList {
        get {
            if (recordMap == null) {
                return new List<MassCloningSelectionController.ErrorMessage>();
            }
            else {
                return recordMap;
            }
        }
        set;
    } 
        
    private Integer counter = 0;
    
    /****public variables****/     
    public Integer pageSize;
    public Integer currentPageNumber {get; set;}
    
    /************************************
    Method Name: PaginationHandlerForError
    Purpose: Constructor
    *************************************/    
    public PaginationHandlerForError() {
        pageSize = 20;
        currentPageNumber = 1;
    }
    
    /************************************
    Method Name: assignRecordList
    Purpose: setting record list
    *************************************/
    public void assignRecordList(List<MassCloningSelectionController.ErrorMessage> recordMap) {
        this.recordMap = recordMap;
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
    public Integer numberOfPages {
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
    public List<MassCloningSelectionController.ErrorMessage> getRecordsInPage(Integer pageNumber) {
        if (pageNumber > 0) {
            Integer startIndex = (pageNumber - 1) * pageSize;
            Integer endIndex = (pageNumber * pageSize) - 1;
            
            if (endIndex > (recordList.size() - 1)) {
                endIndex = recordList.size() - 1;
            }
            
            List<MassCloningSelectionController.ErrorMessage> pageRecords = new List<MassCloningSelectionController.ErrorMessage>();
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
    public List<MassCloningSelectionController.ErrorMessage> getData() {
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
        if (counter == 0) {
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