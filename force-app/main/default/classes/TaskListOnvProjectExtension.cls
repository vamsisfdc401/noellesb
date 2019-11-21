/*****************************************************************************************
Class Name: TaskListOnvProjectExtension 
Purpose: Apex class task list view
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             21/10/2016           Mohit                    Initial Development
******************************************************************************************/
public with sharing class TaskListOnvProjectExtension {
    
    /****private variables****/
    private ID vProjectID; //vProject record ID
    private v_Project_Request__c vProjectDetails; //vProject record details
    private ApexPages.StandardController controller {get; set;}   //controller instance 
    private Integer limitSize = 10;//Number of records to be displayed
    
    
    /*** public variables ***/
    public String sortField{set;get;} //sort field
    public String sortDirection{set;get;} //sort direction
    private List<Task> lstTaskRecords; //all the records
    public List<Task> lstTaskToDisplay{get;set;} //list of records to display
    public Integer totalSize {get;set;} //To Store the total number of records available
    public Integer counter {get;set;}//TO track the number of records parsed 
    public Integer pageNumber {get;set;} //current page number
    public ID recordID{get;set;} //record ID from VF page passed as parameter
    
    /*****************************************************************
    Method Name: TaskListOnvProjectExtension
    Purpose : constructor of class
    ***************************************************************/
    public TaskListOnvProjectExtension(ApexPages.StandardController controller) {
        try{
            this.controller = controller;
            //getting v-Project record details
            this.vProjectDetails = (v_Project_Request__c)controller.getRecord();
            
            //getting v-Project record ID
            vProjectID = vProjectDetails.ID;
            
            //setting default field and direction
            sortField = 'Subject';
            sortDirection = 'ASC';
            
            //calling maethod to populate task records
            getTaskRecords();
        }
        catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please contact system administrator. '+ ex.getMessage()));        
        }         
    }
    
    /************************************
    Method Name: getTaskRecords
    Purpose: getting task details
    *************************************/  
    private void getTaskRecords(){
        try{
            //Intializing variables
            lstTaskToDisplay = new List<Task>(); 
            lstTaskRecords = new List<Task>();
            totalSize = 0; 
            counter = 0;
            pageNumber = 0;
            
            //building SOQL
            String SOQL = 'Select id,subject,status,priority,activity_description__c,Owner.Name from task where Status != \'Completed\' AND ' + ' whatid =' + '\'' + vProjectID + '\'' + ' order by ' + sortField + ' ' + sortDirection + ' NULLS LAST Limit 1000';
            //getting records
            lstTaskRecords = Database.Query(SOQL);
            
            //checking if list not empty
            if(!lstTaskRecords.isEmpty()){
                totalSize = lstTaskRecords.size();
                pageNumber = 1;
                
                //Intial adding of tasks to display
                //check the total records are more than limitSize and assign the records
                //if number of total records are more than records per page then populating only first set of records
                if((counter+limitSize) <= totalSize){
                    for(Integer i=0;i<limitSize;i++){
                        lstTaskToDisplay.add(lstTaskRecords.get(i));
                    }
                }
                //if total records are less than records per page
                else{ 
                    for(Integer i=0;i<totalSize;i++){
                        lstTaskToDisplay.add(lstTaskRecords.get(i));
                    }
                }        
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'No records found.'));        
            }
        }
        catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please contact system administrator. '+ ex.getMessage()));        
        } 
    }    
    
    /************************************
    Method Name: toggleSort
    Purpose: sorting records
    *************************************/  
    public void toggleSort(){
        //settting sort direction
        sortDirection = sortDirection.equalsIgnoreCase('ASC') ? 'DESC' : 'ASC';
        //getting task records
        getTaskRecords();
    }
    
    /************************************
    Method Name: first
    Purpose: navigating to first page
    *************************************/  
    public void first(){
        //initializing variables
        lstTaskToDisplay.clear();
        counter=0;
        pageNumber = 1;
        
        //if number of total records are more than records per page then populating only first set of records
        if((counter + limitSize) <= totalSize){       
            for(Integer i=0;i<limitSize;i++){
                lstTaskToDisplay.add(lstTaskRecords.get(i));
            }
        }
        //if total records are less than records per page
        else{       
            for(Integer i=0;i<totalSize;i++){
                lstTaskToDisplay.add(lstTaskRecords.get(i));
            }
        }
    }    
    
    /************************************
    Method Name: next
    Purpose: navigating to next page
    *************************************/  
    public void next(){  
        //Initializing variables 
        lstTaskToDisplay.clear();
        counter = counter + limitSize;
        pageNumber = pageNumber + 1;
        
        //Popualting next set of records
        if((counter+limitSize) <= totalSize){
            for(Integer i=counter;i<(counter+limitSize);i++){
                lstTaskToDisplay.add(lstTaskRecords.get(i));
            }
        }
        //populating records if last set of records are left
        else{
            for(Integer i=counter;i<totalSize;i++){
                lstTaskToDisplay.add(lstTaskRecords.get(i));
            }
        }
    }  
    
    /************************************
    Method Name: previous
    Purpose: navigating to previous page
    *************************************/  
    public void previous(){  
        //initializing variables 
        lstTaskToDisplay.clear();
        pageNumber = pageNumber - 1;        
        counter = counter-limitSize;       
        
        //navigating to previous page
        for(Integer i=counter;i<(counter+limitSize); i++){
            lstTaskToDisplay.add(lstTaskRecords.get(i));
        }
    }
    
    /************************************
    Method Name: last 
    Purpose: navigating to last page
    *************************************/  
    public void last (){
        //Initializing variables   
        lstTaskToDisplay.clear();        
        pageNumber =  totalSize/limitSize;
        
        //Setting counter and page number value
        if(math.mod(totalSize , limitSize) == 0){
            counter = limitSize * ((totalSize/limitSize)-1);
        } else if (math.mod(totalSize , limitSize) != 0){
            counter = limitSize * ((totalSize/limitSize));
            pageNumber = pageNumber + 1;
        }
        
        //setting last set of records
        for(Integer i=counter-1;i<totalSize-1;i++){
            lstTaskToDisplay.add(lstTaskRecords.get(i));
        }       
    }    
    
    /************************************
    Method Name: getDisableNext
    Purpose: for rendering pagination buttons
    *************************************/  
    public Boolean getDisableNext(){   
        if((counter + limitSize) >= totalSize )
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
    Method Name: updateTask
    Purpose: for updating a task
    *************************************/  
    public void updateTask(){
        try{
            //if list not empty
            if(!lstTaskToDisplay.isEmpty()){
                //looping over list
                for(Task tk : lstTaskToDisplay){
                    //comparing taskID
                    if(tk.ID == recordID){
                        //updating task record, showing confirmation message and breaking the flow
                        update tk;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM,'Record saved successfully.'));        
                        break;
                    }
                }
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'No records found.'));        
            }  
        }
        catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please contact system administrator. '+ ex.getMessage()));
            //return null;                   
        }  
        
        getTaskRecords();
        //pageReference pg = new Pagereference('/apex/TaskListOnvProject?id='+vProjectID);
        //pg.setRedirect(TRUE);
        //return null;         
    }
    
    /************************************
    Method Name: closeTask
    Purpose: for closing a task
    *************************************/  
    public void closeTask(){   
        try{         
            //checking if list not empty
            if(!lstTaskToDisplay.isEmpty()){
                //looping over list
                for(Task tk : lstTaskToDisplay){
                    //comparing task ID
                    if(tk.ID == recordID){
                        //changing task status to completed, showing confirmation message and breaking flow
                        Task objTask = new Task();
                        objTask.ID = tk.ID;
                        objTask.Status = 'Completed';
                        
                        update objTask;
                        tk.Status = 'Completed';
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM,'Record closed successfully.'));        
                        break;
                    }
                }        
            }   
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'No records found.'));        
            }
        }
        catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please contact system administrator. '+ ex.getMessage()));        
        }
    }
}