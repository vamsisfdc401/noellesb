({
    scriptLoaded : function(component, event, helper) {
        component.set("v.isjQueryLoaded", true);
    },
    showSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",true);
    },    
    hideSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",false);
    },
    onEnterClickSearch : function(component, event, helper) {        
        var searchKeyFld = component.find("searchId");
        var srcValue = searchKeyFld.get("v.value");
        var objName = component.get("v.selectedObject");
        
        if(event.getParams().keyCode == 13){
            if (srcValue == '' || srcValue == null) {
                // display error message if input value is blank or null
                searchKeyFld.set("v.errors", [{
                    message: "Enter Search Keyword."
                }]);
            } else {
                searchKeyFld.set("v.errors", null);                
                helper.searchRecords(component, event, 'search');                
            }        
        }
    },
    Search : function(component, event, helper) {
        var searchKeyFld = component.find("searchId");
        var srcValue = searchKeyFld.get("v.value");
        var objName = component.get("v.selectedObject");
        
        if (srcValue == '' || srcValue == null) {
            // display error message if input value is blank or null
            searchKeyFld.set("v.errors", [{
                message: "Enter Search Keyword."
            }]);
        } else {
            searchKeyFld.set("v.errors", null);
            
            helper.searchRecords(component, event, 'search');
        }
    },
    Filter : function(component, event, helper) {
        var searchKeyFld = component.find("searchId");
        var srcValue = searchKeyFld.get("v.value");
        
        var frmDtId = component.find("fromDT");
        var frmDtVal = frmDtId.get("v.value");
        
        var toDtId = component.find("toDT"); 
        var toDtval = toDtId.get("v.value");        
        
        var objName = component.get("v.selectedObject");
        
        if (srcValue == '' || srcValue == null) {
            // display error message if input value is blank or null
            searchKeyFld.set("v.errors", [{
                message: "Enter Search Keyword."
            }]);
        } else {
            searchKeyFld.set("v.errors", null);
            
            if((frmDtVal == '' || frmDtVal == null) && (toDtval == '' || toDtval == null)){
                frmDtId.set("v.errors", [{
                    message: "Enter atleast one of the date field."
                }]);
                toDtId.set("v.errors", [{
                    message: "Enter atleast one of the date field."
                }]);
            }
            else{               
                frmDtId.set("v.errors", null);
                toDtId.set("v.errors", null);
                helper.searchRecords(component, event, 'filter');
            }            
        }
    },
    onSelectObjectChange : function(component, event, helper) {
        //alert(component.get("v.selectedObject"));
        var objName = component.get("v.selectedObject");
        
        if(objName == 'Title'){
            component.set("v.isTitleSearch",true);
            component.set("v.isProductSearch",false);
            component.set("v.isPromotionSearch",false);
        }
        else if(objName == 'Product'){
            component.set("v.isTitleSearch",false);
            component.set("v.isProductSearch",true);
            component.set("v.isPromotionSearch",false);
        }
        else if(objName == 'Promotion'){
            component.set("v.isTitleSearch",false);
            component.set("v.isProductSearch",false);
            component.set("v.isPromotionSearch",true);
        }
        
        var resetList = [];
        
        component.set("v.searchResult",resetList);
        component.set("v.selectedResultList",resetList);
        component.set("v.numberOfRecord",0);
        component.set("v.totalNumberOfRecord", 0);
        component.set("v.selectedRecordCount",0);
        component.set("v.fromDate",null);
        component.set("v.toDate",null);
        component.set("v.Message", false);
        component.set("v.searchKeyword",null);        
        component.set("v.userInputTags",null);
        component.set("v.selectedField",'Name');
        component.set("v.searchResultMaster",null);
        component.set("v.userInputExistingTags",null);
        component.set("v.showEixstingTagInput", false);
        component.set("v.showConfirmationPopup", false);
    },
    onSelectOperationChange : function(component, event, helper) {
        var operationType = component.get("v.selectedOperation");
        
        if(operationType == 'Add'){
            component.set("v.showEixstingTagInput", false);
            component.set("v.tagFieldLabel", "Add Tags");   
            component.set("v.showConfirmationPopup", false);            
        }
        else if(operationType == 'Update'){
            component.set("v.showEixstingTagInput", true);
            component.set("v.tagFieldLabel", "Add Tags");    
            component.set("v.showConfirmationPopup", false); 
        }   
        else if(operationType == 'Remove'){
            component.set("v.showEixstingTagInput", false);
            component.set("v.tagFieldLabel", "Remove Tags");  
            component.set("v.showConfirmationPopup", false); 
        }  
    },
    onSelectFieldChange : function(component, event, helper) {
        var objName = component.get("v.selectedObject");
        
        if(objName == 'Title'){
            var searchKeyFld = component.find("selectTitleField");
            var srcValue = searchKeyFld.get("v.value");
            component.set("v.selectedField",srcValue);
        }
        else if(objName == 'Product'){
            var searchKeyFld = component.find("selectProdField");
            var srcValue = searchKeyFld.get("v.value");
            component.set("v.selectedField",srcValue);
        }
        else if(objName == 'Promotion'){
            var searchKeyFld = component.find("selectPromotionField");
            var srcValue = searchKeyFld.get("v.value");
            component.set("v.selectedField",srcValue);
        }
    },
    addSelectedRecord : function(component, event, helper) {
        //getting the index of record to be added
        var index = event.target.dataset.index;
        
        //calling helper
        helper.addRecord(component, index,helper);
    },
    removeSelectedRecord : function(component, event, helper) {
        //getting the index of record to be added
        var index = event.target.dataset.index;
        
        //calling helper
        helper.removeRecord(component, index,helper);
        component.set("v.Message",false);
    },
    selectAll : function(component, event, helper) {               
        //calling helper
        helper.selectAllRecords(component, event,helper);
    },
    removeAll : function(component, event, helper) {               
        //calling helper
        helper.removeAllRecords(component, event,helper);
        component.set("v.Message",false);
    },
    update : function(component, event, helper) {  
        var tagVal = component.get("v.userInputTags");
        var existingTagVal = component.get("v.userInputExistingTags");
        var operationType = component.get("v.selectedOperation");
        
        //if new tag field is null
        if(tagVal == null || tagVal == ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"error",
                "message": "Error! Enter tags to update."
            });
            toastEvent.fire();
        }
        else {
            //for adding new tags called helper
            if (operationType == 'Add') {
                //calling helper
                helper.updateRecords(component, event);
            }
            //for removing tags shoe modal popups
            else if (operationType == 'Remove') {
                var msg = 'Are you sure you want to remove ' + tagVal + ' from the selected records?';
                component.set("v.showConfirmationPopup", true);
                component.set("v.confirmationMessage",msg);
            }
            //for updating existing tags
            else if (operationType == 'Update') {
                //if existing tags is null then show error 
                if(existingTagVal == null || existingTagVal == ''){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":"error",
                        "message": "Error! Enter existing tags to update."
                    });
                    toastEvent.fire();
                }
                else {
                    helper.updateRecords(component, event);
                }
            }
        }       
    },
    cancel : function(component, event, helper) {  
        $A.get('e.force:refreshView').fire();
    },
    showMore : function(component, event, helper) {      
        helper.showMoreRecords(component, event); 
    },
    hidePopup : function(component, event, helper) {  
        component.set("v.showConfirmationPopup", false);
    },
    removeTags : function(component, event, helper) {  
        component.set("v.showConfirmationPopup", false);
        helper.updateRecords(component, event);
    },
    /*
     * @author: Vaibhav B
     * @Story #: DFOR-1035
     * @purpose: sort of search result by header column for Product List.
    */
    sort : function(component,event,helper) {        
        helper.sort(component,event,helper,component.get("v.searchResultMaster"),false,'');
    },
    /*
     * @author: Vaibhav B
     * @Story #: DFOR-1035
     * @purpose: sort of selected result by header column for Product List.
    */
    selectedSort : function(component,event,helper) {        
        helper.sort(component,event,helper,component.get("v.selectedResultList"),true,'selected');
    },
    /*
     * @author: Vaibhav B
     * @purpose: sort of search result by header column for Title List.
    */
    titleSort : function(component,event,helper) {
        helper.sort(component,event,helper,component.get("v.searchResultMaster"),false,'Title');
    },
    /*
     * @author: Vaibhav B
     * @purpose: sort of selected result by header column for Title List.
    */
    selectedTitleSort : function(component,event,helper) {
        helper.sort(component,event,helper,component.get("v.selectedResultList"),true,'selectedTitle');
    },
    /*
     * @author: Vaibhav B
     * @purpose: sort of search result by header column for Promotion List.
    */
    promotionSort : function(component,event,helper) {
        helper.sort(component,event,helper,component.get("v.searchResultMaster"),false,'Promotion');
    },
    /*
     * @author: Vaibhav B
     * @purpose: sort of selected result by header column for Promotion List.
    */
    selectedPromotionSort : function(component,event,helper) {
        helper.sort(component,event,helper,component.get("v.selectedResultList"),true,'selectedpromotion');
    }
})