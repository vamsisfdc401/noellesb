({
    accept : function(component, event, helper) {
        if (component.get("v.ThresholdValue") == 0){
            var close = $A.get("e.force:closeQuickAction");
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message!',
                message: 'Your approval limit has not been set. Please contact an administrator for help',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
            close.fire();
        } else {
            var action = component.get("c.submitAndProcessApprovalRequest");
            action.setParams({ promoid : component.get("v.recordId") });
            // Create a callback that is executed after 
            // the server-side action returns
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    var close = $A.get("e.force:closeQuickAction");
                    var navEvt = $A.get("e.force:refreshView ");
                    navEvt.setParams({
                        "recordId":  component.get("v.recordId")
                        
                    });
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Order submitted for Approvals',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    close.fire();
                    toastEvent.fire();
                    navEvt.fire(); 
                }
                
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                        var close = $A.get("e.force:closeQuickAction");
                        var toastEvent1 = $A.get("e.force:showToast");
                        toastEvent1.setParams({
                            title : 'Error Message!',
                            message: 'Unable to Submit this Order for Approvals. Please try again later',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        toastEvent1.fire();
                        close.fire();
                    }
            });
            $A.enqueueAction(action);
        }
    },
    
    cancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    doInit: function(component, event, helper){
        var action = component.get("c.ThresholdOfSubmitter");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ThresholdValue", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})