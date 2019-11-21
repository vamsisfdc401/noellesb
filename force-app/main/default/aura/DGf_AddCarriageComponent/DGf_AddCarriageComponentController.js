({
    doInit : function(component, event, helper) {
        var action = component.get("c.getUser");
        var action1 = component.get("c.getAccountName");
        action1.setParams({
            'accId' : component.get("v.AccountId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set user with return value from server.
                component.set("v.isNotAccountUser", storeResponse); 
            }            
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {	
                var accName = response.getReturnValue();
                component.set("v.accountName", accName);
            }
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
        $A.enqueueAction(action1);
    },
    Search : function(component, event, helper) {
        var btnID = event.target.id;
        component.set("v.showMoreButton",btnID);
        var searchKeyFld = component.find("searchId");
        var srcValue = searchKeyFld.get("v.value");
        if (btnID == 'btnSearch' && (srcValue == '' || srcValue == null)) {
            // display error message if input value is blank or null
            searchKeyFld.set("v.errors", [{
                message: "Enter Search Keyword."
            }]);
        } else {
            searchKeyFld.set("v.errors", null);
            // call helper method
            helper.searchProduct(component, event,btnID);
        }
    },
    onEnterClickSearch : function(component, event, helper) {        
        var searchKeyFld = component.find("searchId");
        var srcValue = searchKeyFld.get("v.value");
        component.set("v.showMoreButton",'btnSearch');
        if(event.getParams().keyCode == 13){
            if (srcValue == '' || srcValue == null) {
                // display error message if input value is blank or null
                searchKeyFld.set("v.errors", [{
                    message: "Enter Search Keyword."
                }]);
            } else {
                searchKeyFld.set("v.errors", null);
                // call helper method
                helper.searchProduct(component, event);
            }        
        }
    },
    showSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",true);
    },    
    hideSpinner : function (component, event, helper) {
        component.set("v.showSpinner",false);
    },
    onProductTypeChange : function(component, event, helper) {
        //getting selected value
        var selectedVal = component.find("prodType").get("v.value");
        //setting selected Product Type Value
        component.set("v.selectProductType",selectedVal);
    },
    gotoURL : function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var accountID = component.get("v.AccountId");
        
        urlEvent.setParams({
            "url": "/" + accountID,
            "isredirect": "TRUE"
        });
        urlEvent.fire();
    },
    saveRecordDetails : function(component, event, helper) {
        //getting all selected Product Accounts
        var selectedProductAccount = component.get("v.searchResult");
        
        //helper method to create and update records
        if(selectedProductAccount.length > 0){
            helper.createandUpdateRecords(component, event);
        }
    },
    //USST-3066 start
    saveAndContinue : function(component, event, helper) {
        //getting all selected Product Accounts
        var selectedProductAccount = component.get("v.searchResult");
        //helper method to create and update records
        if(selectedProductAccount.length > 0){
            helper.createUpdateRecordsAndContinue(component, event);
        }
    },
    //USST-3066 end
    scriptLoaded : function(component, event, helper) {
        component.set("v.isjQueryLoaded", true);
    },
    showMore : function (component, event, helper) { 
         // call helper method
         helper.getNextPage(component, event);
     },
    
})