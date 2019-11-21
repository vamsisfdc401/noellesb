({
    searchTitle : function(component, event) {
        var action = component.get("c.fetchTitleVersions");
        var action1 = component.get("c.getESTTierValues");
        var action2 = component.get("c.getReleaseType");
        
        action.setParams({
            'releaseID': component.get("v.releaseRecordId"),
            'searchKeyWord': component.get("v.searchKeyword")  
        });
        action2.setParams({
            'releaseID': component.get("v.releaseRecordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var storeResponse = response.getReturnValue();
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                    component.set("v.searchResult", null);
                    component.set("v.numberOfRecord", 0);
                } else {
                    component.set("v.Message", false);
                }
                // set numberOfRecord attribute value with length of return value from server
                //component.set("v.numberOfRecord", storeResponse.length);
                // set searchResult list with return value from server.
                
                storeResponse.sort(function(a, b){
                    return a.titleName == b.titleName ? 0 : a.titleName < b.titleName ? -1 : 1;
                })
                
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
                
                component.set("v.selectVersionVal","None")
                
            } 
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                component.set("v.estTier", storeResponse); 
            }            
        });        
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                
                //if not TV then EST Tier field will be rendered                
                if(storeResponse != "TV" && storeResponse != "Bundle"){
                    component.set("v.isNotTVRecordType", true);
                }
                
                //if Bundle then only lead title column will be displayed
                if(storeResponse == "Bundle"){
                    component.set("v.isBundleProduct", true);
                }                 
            }            
        });
        $A.enqueueAction(action);
        $A.enqueueAction(action1);
        $A.enqueueAction(action2);
    },   
    showMoreRecords : function(component, event) {
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
    addTitleVersion : function(component, index) {
        //getting the complete result list
        var resultTitleVersions = component.get("v.searchResult") == null ? [] : component.get("v.searchResult");
        
        //getting selected title versions
        var selectedTitleVersions = component.get("v.selectedResultList") == null ? [] : component.get("v.selectedResultList");
        
        //getting all title versions
        var searchResultMaster = component.get("v.searchResultMaster") == null ? [] : component.get("v.searchResultMaster"); //Story DFOR-883
        
        //get release type
        var isNOTTV = component.get("v.isNotTVRecordType");
        
        var isDuplicate = false;
        
        //checking for a valid index
        if (index > -1) {
            
            for(var i = 0 ; i < selectedTitleVersions.length ; i++){
                if(resultTitleVersions[index].versionID == selectedTitleVersions[i].versionID){
                    isDuplicate = true;
                    break;
                }
            }
            
            if(!isDuplicate){
                //adding record to selected list
                selectedTitleVersions.push(resultTitleVersions[index]);
                //removing record from search list
                resultTitleVersions.splice(index, 1);
                //Story DFOR-883 start 
                searchResultMaster.splice(index,1); 
                if(searchResultMaster.length>resultTitleVersions.length) {
                    resultTitleVersions.push(searchResultMaster[resultTitleVersions.length]);
                }
                //Story DFOR-883 end
                //conditionally render EST Tier Picklist
                if(selectedTitleVersions.length == 1 && isNOTTV == true){
                    component.set("v.renderESTTier",true);  
                }
                else{
                    component.set("v.renderESTTier",false);  
                } 
                
                //if it isa bundle then show lead title option
                if(selectedTitleVersions.length > 1){
                    component.set("v.isBundleProduct", true);
                }
                else{
                    component.set("v.isBundleProduct", false);
                }
                
                //conditionally render version field
                if(selectedTitleVersions.length == 1 && component.get("v.isNotTVRecordType") == true && selectedTitleVersions[0].isOriginalVersion == false){
                    component.set("v.renderVersion",true);
                }
                else{
                    component.set("v.renderVersion",false);
                }
                
                //setting the component list
                component.set("v.selectedResultList",selectedTitleVersions);  
                component.set("v.searchResult",resultTitleVersions); 
                component.set("v.searchResultMaster",searchResultMaster);  //Story DFOR-883
                
                component.set("v.numberOfRecord",resultTitleVersions.length);  
                component.set("v.selectedRecordCount",selectedTitleVersions.length); 
                component.set("v.totalNumberOfRecord",searchResultMaster.length);  //Story DFOR-883
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"error",
                    "message": "Error! Record already added."
                });
                toastEvent.fire();
            }               
        } 
    },
    
    removeTitleVersion : function(component, index) {
        //getting the complete result list
        var resultTitleVersions = component.get("v.searchResult") == null ? [] : component.get("v.searchResult");
        //Story DFOR-883 start
        var resultLength=resultTitleVersions.length;
        if(resultTitleVersions.length < component.get("v.pageSize")) {
            resultLength=component.get("v.pageSize");
        }
        //Story DFOR-883 end
        //getting all title versions
        var searchResultMaster = component.get("v.searchResultMaster") == null ? [] : component.get("v.searchResultMaster"); //Story DFOR-883
        
        //getting selected title versions
        var selectedTitleVersions = component.get("v.selectedResultList") == null ? [] : component.get("v.selectedResultList");
        
        //get release type
        var isNOTTV = component.get("v.isNotTVRecordType");
        
        var isDuplicate = false;
        
        //checking for a valid index
        if (index > -1) {
            for(var i = 0 ; i < resultTitleVersions.length ; i++){
                if(resultTitleVersions[i].versionID == selectedTitleVersions[index].versionID) {
                    isDuplicate = true;
                    break;
                }
            }
            
            if(!isDuplicate) {
                //add record back to search list
                resultTitleVersions.push(selectedTitleVersions[index]);
                searchResultMaster.push(selectedTitleVersions[index]); //Story DFOR-883
                //removing record from selected list
                selectedTitleVersions.splice(index, 1);
            }
            else{               
                //removing record from selected list
                selectedTitleVersions.splice(index, 1);
            }
            
        }
        
        //conditionally render EST Tier Picklist
        if(selectedTitleVersions.length == 1 && isNOTTV == true) {
            component.set("v.renderESTTier",true);  
        }
        else{
            component.set("v.renderESTTier",false);  
        } 
        
        //conditionally render version field
        if(selectedTitleVersions.length == 1 && component.get("v.isNotTVRecordType") == true && selectedTitleVersions[0].isOriginalVersion == false){
            component.set("v.renderVersion",true);
        }
        else{
            component.set("v.renderVersion",false);
        }
        
        //if it isa bundle then show lead title option
        if(selectedTitleVersions.length > 1){
            component.set("v.isBundleProduct", true);
        }
        else{
            component.set("v.isBundleProduct", false);
        }
        
        searchResultMaster.sort(function(a, b){
            return a.titleName == b.titleName ? 0 : a.titleName < b.titleName ? -1 : 1;
        })
        var resultTitleVersionsClone=[];
        for(var i = 0; i < resultLength && i < searchResultMaster.length; i++) {
            resultTitleVersionsClone.push(searchResultMaster[i]);
        }
        //setting the component list
        component.set("v.selectedResultList",selectedTitleVersions);  
        component.set("v.searchResult",resultTitleVersionsClone); 
        component.set("v.searchResultMaster",searchResultMaster);  //Story DFOR-883
        
        component.set("v.numberOfRecord",resultTitleVersionsClone.length);  
        component.set("v.selectedRecordCount",selectedTitleVersions.length); 
        component.set("v.totalNumberOfRecord",searchResultMaster.length);  //Story DFOR-883
    },
    createRecords : function(component, event) {
        if(component.get("v.isBtnDisable") == false){
            var action = component.get("c.submitDetails");        
            action.setParams({
                'releaseID': component.get("v.releaseRecordId"),
                'strProductVersion': JSON.stringify(component.get("v.selectedResultList")),
                'strESTTier': component.get("v.selectESTTierVal"),
                'strVersion': component.get("v.selectVersionVal")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    var urlEvent = $A.get("e.force:navigateToURL");
                    
                    urlEvent.setParams({
                        "url": "/" + component.get("v.releaseRecordId"),
                        "isredirect": "TRUE"
                    });
                    urlEvent.fire();                    
                    
                }  
                else if ( state === "ERROR"){
                    component.set("v.isCodeError", true);
                    //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                    component.set("v.CodeError", response.getError()[0].message);
                    console.log("Error Message", response.getError()[0].message);
                }
            });        
            $A.enqueueAction(action); 
        }
        
    },
    selectAllTitlVersions : function(component, event) {
        //getting the complete result list
        var resultTitleVersions = component.get("v.searchResult") == null ? [] : component.get("v.searchResult");
        var searchResultMaster = component.get("v.searchResultMaster") == null ? [] : component.get("v.searchResultMaster"); //Story DFOR-883
        //getting selected title versions
        var selectedTitleVersions = component.get("v.selectedResultList") == null ? [] : component.get("v.selectedResultList");
        
        //get release type
        var isNOTTV = component.get("v.isNotTVRecordType");
        
        var isDuplicateScenario = false;
        
        //adding all titles to select list
        for(var i = 0; i < resultTitleVersions.length; i++){  
            var isDuplicate = false;
            
            for(var j = 0; j < selectedTitleVersions.length; j++){
                if(resultTitleVersions[i].versionID == selectedTitleVersions[j].versionID){
                    isDuplicateScenario = true;
                    isDuplicate = true;
                }
            }
            
            if(!isDuplicate){
                //adding record to selected list
                selectedTitleVersions.push(resultTitleVersions[i]);  
            }
        }
        //Story DFOR-883 start
        searchResultMaster.splice(0,resultTitleVersions.length); 
        var searchResultArr = [];
        for(var i=0;i<resultTitleVersions.length && i<searchResultMaster.length;i++) {
            searchResultArr.push(searchResultMaster[i]);
        }
        //Story DFOR-883 end
        //conditionally render EST Tier Picklist
        if(selectedTitleVersions.length == 1 && isNOTTV == true){
            component.set("v.renderESTTier",true);  
        }
        else{
            component.set("v.renderESTTier",false);  
        } 
        
        //conditionally render version field
        if(selectedTitleVersions.length == 1 && component.get("v.isNotTVRecordType") == true && selectedTitleVersions[0].isOriginalVersion == false){
            component.set("v.renderVersion",true);
        }
        else{
            component.set("v.renderVersion",false);
        }
        
        //if it isa bundle then show lead title option
        if(selectedTitleVersions.length > 1){
            component.set("v.isBundleProduct", true);
        }
        else{
            component.set("v.isBundleProduct", false);
        }
        
        //setting the component list
        component.set("v.selectedResultList",selectedTitleVersions);  
        component.set("v.searchResult",searchResultArr); 
        component.set("v.searchResultMaster",searchResultMaster);
        component.set("v.totalNumberOfRecord",searchResultMaster.length); //Story DFOR-883
        component.set("v.numberOfRecord",searchResultArr.length);  
        component.set("v.selectedRecordCount",selectedTitleVersions.length); 
        
        if(isDuplicateScenario){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"info",
                "message": "Info! Records already added have been skipped."
            });
            toastEvent.fire();
        }
    },
    removeAllTitlVersions : function(component, event) {
        //getting the complete result list
        var resultTitleVersions = component.get("v.searchResult") == null ? [] : component.get("v.searchResult");
        //Story DFOR-883 start
        var resultLength=resultTitleVersions.length;
        if(resultTitleVersions.length<component.get("v.pageSize")) {
            resultLength=component.get("v.pageSize");
        }
        //Story DFOR-883 end
        //getting selected title versions
        var selectedTitleVersions = component.get("v.selectedResultList") == null ? [] : component.get("v.selectedResultList");
        var searchResultMaster = component.get("v.searchResultMaster") == null ? [] : component.get("v.searchResultMaster"); //Story DFOR-883
        //get release type
        var isNOTTV = component.get("v.isNotTVRecordType");
        
        //adding all titles to select list
        for(var i = 0; i < selectedTitleVersions.length; i++){ 
            var isDuplicate = false;
            for(var j = 0; j < resultTitleVersions.length; j++){
                if(resultTitleVersions[j].versionID == selectedTitleVersions[i].versionID){                 
                    isDuplicate = true;
                }
            }    
            
            if(!isDuplicate){
                //adding record to selected list
                resultTitleVersions.push(selectedTitleVersions[i]);  
                searchResultMaster.push(selectedTitleVersions[i]); //Story DFOR-883
            }
        }
        
        var selectResultArr = [];
        
        
        component.set("v.renderESTTier",false); 
        
        //remove version field on remove all
        component.set("v.renderVersion",false);
        
        //lead title column should not be displayed if all the records have been removed
        component.set("v.isBundleProduct", false);
        //Story DFOR-883 start
        searchResultMaster.sort(function(a, b){
            return a.titleName == b.titleName ? 0 : a.titleName < b.titleName ? -1 : 1;
        })
        var resultTitleVersionsClone=[];
        for(var i=0;i<resultLength;i++) {
            resultTitleVersionsClone.push(searchResultMaster[i]);
        }
        //Story DFOR-883 end
        //setting the component list
        component.set("v.selectedResultList",selectResultArr);  
        component.set("v.searchResult",resultTitleVersionsClone); 
        component.set("v.searchResultMaster",searchResultMaster);  //Story DFOR-883
        
        component.set("v.numberOfRecord",resultTitleVersionsClone.length);  
        component.set("v.selectedRecordCount",selectResultArr.length); 
        component.set("v.totalNumberOfRecord",searchResultMaster.length);  //Story DFOR-883
    },
    setLeadTitle : function(component, event) {
        //getting selected title versions
        var selectedTitleVersions = component.get("v.selectedResultList");
        
        //getting all checkbox components
        var checkCmp = component.find("checkbox");
        
        //getting the count of selected lead title checkbox
        var count = 0;        
        for(var i = 0; i < selectedTitleVersions.length; i++){
            if(selectedTitleVersions[i].isLeadTitle == true){
                count = count + 1;
            }            
        }
        
        //showing error if more than one lead title is selected
        if(count > 1){
            component.set("v.isCodeError", true);
            component.set("v.CodeError", "Maximum one lead title can be selected.");
            component.set("v.isBtnDisable", true);
        }
        else{
            component.set("v.isCodeError", false);
            component.set("v.isBtnDisable", false);
        }        
        component.set("v.selectedResultList",selectedTitleVersions); 
    },
    
    createNoVersionProduct : function(component,event){
        var action = component.get("c.saveNoVersionProduct");
        action.setParams({
            'releaseID': component.get("v.releaseRecordId")
        });
        action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    var urlEvent = $A.get("e.force:navigateToURL");
                    
                    urlEvent.setParams({
                        "url": "/" + component.get("v.releaseRecordId"),
                        "isredirect": "TRUE"
                    });
                    urlEvent.fire();
                   
                }  
                else if ( state === "ERROR"){
                    component.set("v.isCodeError", true);
                    //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                    component.set("v.CodeError", response.getError()[0].message);
                    console.log("Error Message", response.getError()[0].message);
                }
            });        
            $A.enqueueAction(action); 
    }
})