({
    accept : function(component, event, helper) {
        var close = $A.get("e.force:closeQuickAction");
        var toastEvent = $A.get("e.force:showToast");
        var navEvt = $A.get("e.force:refreshView ");
        //Stop for non draft orders
        if (component.get("v.OrderStatus") == "Draft"){
            toastEvent.setParams({
                title : 'Error Message!',
                message: 'Please delete Draft Orders',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
            close.fire();
        } else if (component.get("v.OrderStatus") == "Pending Approval"){
            toastEvent.setParams({
                title : 'Error Message!',
                message: 'Please Recall Approvals and then Delete this Order',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
            close.fire();
        } else if (component.get("v.OrderStatus") == "Partially Shipped" || component.get("v.OrderStatus") == "Fully Shipped"){
                toastEvent.setParams({
                    title : 'Error Message!',
                    message: 'Partially Shipped / Fully Shipped Orders cannot be cancelled',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                close.fire();
        } else {
            if (component.get("v.IsPromoAdmin") == false){
                toastEvent.setParams({
                    title : 'Error Message!',
                    message: 'Only Administrators can Cancel Non Draft Orders',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                close.fire();
            } else {
                var action = component.get("c.CancelPromoOrder");
                action.setParams({ PromoOrderId : component.get("v.recordId") });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        navEvt.setParams({
                            "recordId":  component.get("v.recordId")
                        });
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Order Cancelled successfully',
                            type: 'success',
                            mode: 'dismissible'
                        });
                        close.fire();
                        toastEvent.fire();
                        navEvt.fire(); 
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                        toastEvent.setParams({
                            title : 'Error Message!',
                            message: 'Unable to Cancel this Order. Please contact a System Administrator',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        close.fire();
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },
    
    doInit : function(component, event, helper) {
        var action = component.get("c.IsUserPromoAdmin");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.IsPromoAdmin", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        var action1 = component.get("c.OrderStatus");
        action1.setParams({ PromoOrderId : component.get("v.recordId") });
        action1.setCallback(this, function(response) {
            var state1 = response.getState();
            if (state1 === "SUCCESS") {
                component.set("v.OrderStatus", response.getReturnValue());
            }
        });
        $A.enqueueAction(action1);
    },
    
    cancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },

})