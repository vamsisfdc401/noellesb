({
    doInit : function(component, event, helper) { 
        
        var action1 = component.get("c.fetchRelatedRecords");        
        action1.setParams({
            'recordID': component.get("v.recordId")  
        });        
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                component.set("v.recordsToDisplay", storeResponse); 
                component.set("v.numberOfRecords", storeResponse.length);                
            }    
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        }); 
        $A.enqueueAction(action1);
    },
    showAll : function(component, event) {
        var evt = $A.get("e.force:navigateToComponent");        
        evt.setParams({
            componentDef : "c:DGF_ProductVersionRelatedListComponent",
            componentAttributes: {
                recordId : component.get("v.recordId"),
                showViewAll : "false"
            }
        });        
        evt.fire(); 
    },    
    update : function (component, event, helper) {
        alert('location change');
        // Get the new location token from the event if needed
        var loc = event.getParam("token");
        $A.get('e.force:refreshView').fire();
    },
    showSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",true);
    },    
    hideSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",false);
    },
    scriptLoaded : function(component, event, helper) {
        component.set("v.isjQueryLoaded", true);
        console.log('event outside fired scriptloaded');  
        
        $("#fixTable1").tableHeadFixer({"left" : 1,"z-index" : 3});    
    }
})