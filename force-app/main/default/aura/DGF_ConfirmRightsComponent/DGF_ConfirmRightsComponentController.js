({
    doInit : function(component, event, helper) {  
        
        var action = component.get("c.updateRightsValidated");
        action.setParams({
            'recordId': component.get("v.recordId") 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Rights validated."
                });
                toastEvent.fire();
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