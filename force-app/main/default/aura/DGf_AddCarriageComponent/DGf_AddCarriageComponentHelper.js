({
	searchProduct : function(component, event,btnID) {
        component.set("v.searchResultMaster",null);
        component.set("v.searchResult",null);
        component.set("v.numberOfRecord" , '0');
        var action = component.get("c.fetchProducts");
        action.setParams({
           'searchKeyWord': component.get("v.searchKeyword"),
            'buttonID': btnID,
            'productType' : component.get("v.selectProductType"),
            'fromDate' : component.get("v.from"),
            'untilDate' : component.get("v.until"),
            'accountId' : component.get("v.AccountId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {	
                var storeResponse = response.getReturnValue();
                console.log("response.getReturnValue()====>",response.getReturnValue());
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
                
                // set numberOfRecord attribute value with length of return value from server
                component.set("v.searchResultMaster", storeResponse);
                component.set("v.totalNumberOfRecord", storeResponse.length);
                
                //declaring variables required for show more
                var searchListLength = storeResponse.length;
                var pageSize = component.get("v.pageSize");
                var maxloop = 0;
                var recordsToDisplay = [];
                
                //if master data set and page size is equals or less
                if(searchListLength > 0 && searchListLength <= pageSize){
                    maxloop = searchListLength;
                }
                //if master data set contains more records then only load records equal to page size
                else if(searchListLength > 0 && searchListLength > pageSize){
                    maxloop = pageSize;
                }
                
                //if loop variable is not 0
                if(maxloop > 0){
                    //add record to display to an array
                    for(var i=0; i< maxloop; i++){
                        recordsToDisplay.push(storeResponse[i]);
                    }
                    
                    //set array to list which will be loaded on UI
                    component.set("v.searchResult", recordsToDisplay);
                    component.set("v.numberOfRecord", recordsToDisplay.length);
                }
                
            } 
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    getNextPage : function(component, event) {
        //getting record list
        var masterList = component.get("v.searchResultMaster") == null ? [] : component.get("v.searchResultMaster");
        var recordsToDisplay = component.get("v.searchResult") == null ? [] : component.get("v.searchResult");
        
        //declaring variables required for show more
        var masterListLength = masterList.length;
        var displayListLength = recordsToDisplay.length;
        var pageSize = component.get("v.pageSize");
        var maxloop = 0;
        
        //if length of master list is more than displayed list
        if(masterListLength > displayListLength){
            //getting size different
            var listLengthDif = masterListLength - displayListLength;
            
            //if size different is more than page size
            if(listLengthDif >= pageSize){
                maxloop = displayListLength + pageSize;
            }
            //if size difference is less than page size
            else if(listLengthDif < pageSize){
                maxloop = displayListLength + listLengthDif;
            }
            
            //creating list of records to be displayed
            for(var i=displayListLength; i < maxloop; i++){
                recordsToDisplay.push(masterList[i]);
            }
            
            //set array to list which will be loaded on UI
            component.set("v.searchResult", recordsToDisplay);
            component.set("v.numberOfRecord", recordsToDisplay.length);
        }
        else{
            //display info that no more records are there to be displayed 
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"info",
                "message": "Info! No more records to display."
            });
            toastEvent.fire();
        }
    },
    createandUpdateRecords : function(component, event) {
        var temp=component.get("v.searchResult");
        var jsontemp=[];
        for(i in temp){
            if(temp[i].estDate==''){
               temp[i].estDate=null; 
            }
            if(temp[i].vodStartDate==''){
               temp[i].vodStartDate=null; 
            }
            if(temp[i].vodEndDate==''){
               temp[i].vodEndDate=null; 
            }
            if(temp[i].ppvStartDate==''){
               temp[i].ppvStartDate=null; 
            }
            if(temp[i].ppvEndDate==''){
               temp[i].ppvEndDate=null; 
            }
            if(temp[i].pushStartDate==''){
               temp[i].pushStartDate=null; 
            }
            if(temp[i].pushEndDate==''){
               temp[i].pushEndDate=null; 
            }
            if(temp[i].x4kEST==''){
               temp[i].x4kEST=null; 
            }
            jsontemp.push(temp[i]);
        }
            var action = component.get("c.submitDetails");        
            action.setParams({
                'accountID': component.get("v.AccountId"),
                'strProductAccount': JSON.stringify(jsontemp),
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    var urlEvent = $A.get("e.force:navigateToURL");
                    
                    urlEvent.setParams({
                        "url": "/" + storeResponse,
                        "isredirect": "TRUE"
                    });
                    urlEvent.fire();
                }  
                else if ( state === "ERROR"){
                    component.set("v.isCodeError", true);
                    component.set("v.CodeError", response.getError()[0].message);
                    console.log("Error Message", response.getError()[0].message);
                }
            });        
            $A.enqueueAction(action); 
    },
    //USST-3066 start
    createUpdateRecordsAndContinue : function(component, event) {
        var temp=component.get("v.searchResult");
        var jsontemp=[];
        for(i in temp){
            if(temp[i].estDate==''){
               temp[i].estDate=null; 
            }
            if(temp[i].vodStartDate==''){
               temp[i].vodStartDate=null; 
            }
            if(temp[i].vodEndDate==''){
               temp[i].vodEndDate=null; 
            }
            if(temp[i].ppvStartDate==''){
               temp[i].ppvStartDate=null; 
            }
            if(temp[i].ppvEndDate==''){
               temp[i].ppvEndDate=null; 
            }
            if(temp[i].pushStartDate==''){
               temp[i].pushStartDate=null; 
            }
            if(temp[i].pushEndDate==''){
               temp[i].pushEndDate=null; 
            }
            if(temp[i].x4kEST==''){
               temp[i].x4kEST=null; 
            }
            jsontemp.push(temp[i]);
        }
            var action = component.get("c.submitDetails");        
            action.setParams({
                'accountID': component.get("v.AccountId"),
                'strProductAccount': JSON.stringify(jsontemp),
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
					var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":"success",
                        "message": "Save Successful."
                    });
                    toastEvent.fire();
                }  
                else if ( state === "ERROR"){
                    component.set("v.isCodeError", true);
                    component.set("v.CodeError", response.getError()[0].message);
                    console.log("Error Message", response.getError()[0].message);
                }
            });        
            $A.enqueueAction(action); 
    }
    //USST-3066 end
})