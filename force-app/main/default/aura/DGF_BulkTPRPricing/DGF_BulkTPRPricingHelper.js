({
    showMoreRecords : function(component,event){
        //getting record list
        var masterList = component.get("v.searchResultMaster") == null ? [] : component.get("v.searchResultMaster");
        var recordsToDisplay = component.get("v.prodResultList") == null ? [] : component.get("v.prodResultList");
        
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
            component.set("v.prodResultList", recordsToDisplay);
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
    addSelectedProduct : function(component, index,helper) {
        //getting the complete result list
        var prodResults = component.get("v.prodResultList") == null ? [] : component.get("v.prodResultList");
        
        //getting selected title versions
        var selectedProd = component.get("v.selectedRecList") == null ? [] : component.get("v.selectedRecList");
        var searchResultMaster = component.get("v.searchResultMaster"); //Story DFOR-1035
        //checking for a valid index
        if (index > -1) {
            //adding record to selected list
            selectedProd.push(prodResults[index]);
            //removing record from search list
            prodResults.splice(index, 1);
            searchResultMaster.splice(index, 1); //Story DFOR-1035
        } 
        helper.rearrange(component,helper,selectedProd,searchResultMaster); //Story DFOR-1035         
    },
    
    removeSelectedProduct : function(component, index,helper) {
        //getting the complete result list
        var prodResults = component.get("v.prodResultList") == null ? [] : component.get("v.prodResultList");
        var searchResultMaster = component.get("v.searchResultMaster") == null ? [] : component.get("v.searchResultMaster"); //Story DFOR-1035
        //getting selected title versions
        var selectedProd = component.get("v.selectedRecList") == null ? [] : component.get("v.selectedRecList");
        
        //checking for a valid index
        if (index > -1) {
            //adding record to selected list
            prodResults.push(selectedProd[index]);
            searchResultMaster.push(selectedProd[index]); //Story DFOR-1035
            //removing record from search list
            selectedProd.splice(index, 1);
        } 
        if(prodResults.length<component.get("v.pageSize")) {
            component.set("v.numberOfRecord",component.get("v.pageSize"));
        }
        helper.rearrange(component,helper,selectedProd,searchResultMaster); //Story DFOR-1035  
    },
    selectAllProducts : function(component,event,helper){
        var prodResults=component.get("v.prodResultList") == null ? [] : component.get("v.prodResultList");
        var searchResultMaster = component.get("v.searchResultMaster") == null ? [] : component.get("v.searchResultMaster"); //Story DFOR-883
        var selectedProd = component.get("v.selectedRecList") == null ? [] : component.get("v.selectedRecList");        
        for(var i = 0; i < prodResults.length; i++){  
            selectedProd.push(prodResults[i]);
        }
        searchResultMaster.splice(0,prodResults.length);
        helper.rearrange(component,helper,selectedProd,searchResultMaster); //Story DFOR-883           
    },
    removeAllProducts : function(component,event,helper){
        var selectedProd = component.get("v.selectedRecList") == null ? [] : component.get("v.selectedRecList");
        var searchResultMaster = component.get("v.searchResultMaster") == null ? [] : component.get("v.searchResultMaster"); //Story DFOR-883
        var prodResults = component.get("v.prodResultList") == null ? [] : component.get("v.prodResultList");
        if(prodResults.length<component.get("v.pageSize")) {
            component.set("v.numberOfRecord",component.get("v.pageSize"));
        }
        for(var i = 0; i < selectedProd.length; i++){  
            searchResultMaster.push(selectedProd[i]);
        }
        helper.rearrange(component,helper,[],searchResultMaster);   //Story DFOR-883
    },
    //Story DFOR-1035 start
    /*
     * @author: Vaibhav B
     * @Story #: DFOR-1035
     * @purpose: hide all the up and down arrows on search result header
    */
    clearOrder : function(component,event,helper) {
        var columns = $A.get("$Label.c.DGF_BulkTPRHeaderColumns");
        var cols = columns.split(',');
        for(var i = 0;i < cols.length;i++) { 
            $A.util.addClass(component.find(cols[i]), 'slds-hide');     
        }
    },
    /*
     * @author: Vaibhav B
     * @Story #: DFOR-1035
     * @purpose: hide all the up and down arrows on selected header
    */
    clearOrderSelected : function(component,event,helper) {
        var columns = $A.get("$Label.c.DGF_BulkTPRHeaderColumns");
        var cols = columns.split(',');
        for(var i = 0;i < cols.length;i++) { 
            $A.util.addClass(component.find('selected'+cols[i]), 'slds-hide');     
        }        
    },
    /*
     * @author: Vaibhav B
     * @Story #: DFOR-1035
     * @purpose: sorts Master result list according to selected field and specified order.
     * sort order 'True' means assending order and 'False' as decending
    */
    sortByField : function(component,helper,fieldName,sortOrder,searchResult,isForSelectedRecords) {
        var pricingColumns = $A.get("$Label.c.DGF_PricingColumns");
        searchResult.sort(function(a, b){
            var element1;
            var element2;
            if(pricingColumns.lastIndexOf(fieldName) == -1) {
                element1 = a[fieldName] == null ? '' : a[fieldName].toLowerCase();
                element2 = b[fieldName] == null ? '' : b[fieldName].toLowerCase();
            }
            else {
                element1 = a[fieldName] != 'N/A' && a[fieldName] != null && a[fieldName] != '' && a[fieldName].length > 0 ? a[fieldName].substr(0, a[fieldName].length) : 0.0;
                element2 = b[fieldName] != 'N/A' && b[fieldName] != null && b[fieldName] != '' && b[fieldName].length > 0 ? b[fieldName].substr(0, b[fieldName].length) : 0.0;
                element1 = parseFloat(element1);
                element2 = parseFloat(element2);
            }
            return element1 == element2 ? 0 : element1 < element2 ? -1 : 1;            
        })
        if(!sortOrder) {
            searchResult.reverse();
        }
        helper.setRecords(component,helper,searchResult,isForSelectedRecords);       
    },
    /*
     * @author: Vaibhav B
     * @Story #: DFOR-1035
     * @purpose: generic method to set component variables or call sort depending is list is to be sorted or not
    */
    rearrange : function(component,helper,selectedProd,searchResultMaster) {
        if(component.get("v.selectedRowRecords") != 'none') {
            helper.sortByField(component,helper,component.get("v.selectedRowRecords").substr('selected'.length,component.get("v.selectedRowRecords").length),component.get('v.assendingSelectedRecords'),selectedProd,true);
        }
        else {
            helper.setRecords(component,helper,selectedProd,true);
        }
        if(component.get("v.selectedRow") != 'none') {
            helper.sortByField(component,helper,component.get("v.selectedRow"),component.get('v.assending'),searchResultMaster,false);
        }
        else {
            helper.setRecords(component,helper,searchResultMaster,false);
        }
    },
    /*
     * @author: Vaibhav B
     * @Story #: DFOR-1035
     * @purpose: set records in available and selected list
    */
    setRecords : function (component,helper,newResult,isForSelectedRecords) {
        if(!isForSelectedRecords) {
            var searchResultClone = [];
            for(var i = 0;i < component.get("v.numberOfRecord") && i < newResult.length;i++) {
                searchResultClone.push(newResult[i]);
            }
            component.set("v.prodResultList",[]);
            component.set("v.prodResultList",searchResultClone);
            component.set("v.searchResultMaster",newResult);
            component.set("v.numberOfRecord",searchResultClone.length);
            component.set("v.totalNumberOfRecord",newResult.length);            
        }
        else {
            component.set("v.selectedRecList",newResult);
            component.set("v.selectedRecordCount",newResult.length);            
        }         
    },
    /*
     * @author: Vaibhav B
     * @Story #: DFOR-1035
     * @purpose: set columns being sorted and call sortByField
    */
    sort: function(component,event,helper,searchResult,isForSelectedRecords,prefix) {
        var target = event.currentTarget.id;
        if(searchResult == null || searchResult.length == 0) {
            return;
        }
        var selectedColumn = isForSelectedRecords == true ? component.get('v.selectedRowRecords') : component.get('v.selectedRow');
        var sortOrder = true;
        if(selectedColumn == target) {
            sortOrder = isForSelectedRecords == true ? !component.get('v.assendingSelectedRecords') : !component.get('v.assending');
        } 
        if(isForSelectedRecords) {
            component.set("v.assendingSelectedRecords",sortOrder);
            component.set("v.selectedRowRecords",target);
            helper.clearOrderSelected(component,event,helper);
        }
        else {
            component.set("v.assending",sortOrder);
            component.set("v.selectedRow",target);
            helper.clearOrder(component,event,helper);
        }
        $A.util.removeClass(component.find(target), 'slds-hide');
        helper.sortByField(component,helper,target.substr(prefix.length,target.length),sortOrder,searchResult,isForSelectedRecords);
    }
    //Story DFOR-1035 end
})