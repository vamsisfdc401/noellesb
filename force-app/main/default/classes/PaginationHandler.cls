/*****************************************************************************************
Class Name: PaginationHandler
Purpose: Apex class for handling pagination
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             27/02/2017           Suman/Mohit              Initial Development
******************************************************************************************/
public class PaginationHandler
{
    /****private variables****/
    private List<MaterialFERTWrapper> recordList;  
    private Integer counter = 0;
    
    /****public variables****/     
    public Integer pageSize;
    public Integer currentPageNumber {get; set;}
    
    /************************************
    Method Name: PaginationHandler
    Purpose: Constructor
    *************************************/    
    public PaginationHandler()
    {
        pageSize = 5;
        currentPageNumber = 1;
        recordList = new List<MaterialFERTWrapper>();
    }
    
    /************************************
    Method Name: assignRecordList
    Purpose: setting record list
    *************************************/
    public void assignRecordList(List<MaterialFERTWrapper> recordList)
    {
        this.recordList = recordList;
    }
    
    /************************************
    Method Name: numberOfRecords
    Purpose: number of records
    *************************************/
    public Integer numberOfRecords
    {
        get {
            return recordList.size();
        }
        private set;
    }
    
    /************************************
    Method Name: numberOfPages
    Purpose: total number of pags
    *************************************/
    public Integer numberOfPages 
    {
        get {
            if(pageSize <= 0)
                return recordList.size();
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
    public void updatePaginationCounter()
    {
        counter = (currentPageNumber - 1) * pageSize;
    }
    
    /************************************
    Method Name: getRecordsInPage
    Purpose: get list of records to be populated on page
    *************************************/
    public List<MaterialFERTWrapper> getRecordsInPage(Integer pageNumber)
    {
        System.debug('*****1> '+recordList);
        if(pageNumber > 0)
        {
            Integer startIndex = (pageNumber - 1) * pageSize;
            Integer endIndex = (pageNumber * pageSize) - 1;
            
            if(endIndex > (recordList.size() - 1))
            {
                endIndex = recordList.size() - 1;
            }
            System.debug('*****2> '+startIndex+' :: '+endIndex);
            
            List<MaterialFERTWrapper> pageRecords = new List<MaterialFERTWrapper>();
            Integer j = 0;
            for(Integer i = startIndex; i <= endIndex; i ++)
            {
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
    public List<MaterialFERTWrapper> getData()
    {
        return getRecordsInPage(currentPageNumber);
    }
    
    /************************************
    Method Name: nextPage
    Purpose: for navigating to next page
    *************************************/
    public void nextPage()
    {
        if((currentPageNumber + 1) <= numberOfPages)
            currentPageNumber ++;
        
        counter = counter + pageSize;
    }
    
    /************************************
    Method Name: previousPage
    Purpose: for navigating to previous page
    *************************************/
    public void previousPage()
    {
        if((currentPageNumber - 1) >= 0)
            currentPageNumber --;
            
        counter = counter - pageSize;
    }
    
    /************************************
    Method Name: firstPage
    Purpose: for navigating to first page
    *************************************/
    public void firstPage()
    {
        currentPageNumber = 1;
        counter = 0;
    }
    
    /************************************
    Method Name: lastPage
    Purpose: for navigating to last page
    *************************************/
    public void lastPage()
    {
        currentPageNumber = numberOfPages;
        
        if(math.mod(recordList.size(), pageSize) == 0){
            counter = pageSize * ((recordList.size()/pageSize)-1);
        } else if (math.mod(recordList.size(), pageSize) != 0){
            counter = pageSize * ((recordList.size()/pageSize));
        }
    }
    
    /************************************
    Method Name: getDisableNext
    Purpose: disbale next button
    *************************************/  
    public Boolean getDisableNext(){   
        if((counter + pageSize) >= recordList.size())
            return FALSE;
        else
            return TRUE;
    }
    
    /************************************
    Method Name: getDisablePrevious
    Purpose: for rendering pagination buttons
    *************************************/  
    public Boolean getDisablePrevious(){   
        if(counter == 0)
            return FALSE;
        else
            return TRUE;
    }
    
    /************************************
    Method Name: getPageList
    Purpose: get list of pages
    *************************************/
    public List<SelectOption> getPageList()
    {
        List<SelectOption> tempOpList = new List<SelectOption>();
        if(numberOfPages > 0)
        {
            for(Integer i = 1; i <= numberOfPages; i ++)
            {
                tempOpList.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
            }
        }
        
        return tempOpList;
    }
}