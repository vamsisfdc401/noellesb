({
    showSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",true);
    },    
    hideSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",false);
    },
    cancelDeletion : function(component, event, helper) {               
        //calling helper
        helper.redirectToRelease(component, event);
    },
    performDeletion : function(component, event, helper) {               
        //calling helper
        helper.deleteReleaseAndRelatedRecords(component, event);
    },
    doInit : function(component, event, helper) { 
        var action = component.get("c.hasDeleteAccess");
        action.setParams({
            'releaseID': component.get("v.recordId")  
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {	
                var storeResponse = response.getReturnValue();                
                component.set("v.hasDeleteAccess",storeResponse);                
            }
        }); 
        $A.enqueueAction(action);
    }
})