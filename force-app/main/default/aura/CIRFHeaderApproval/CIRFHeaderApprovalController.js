({
    doInit : function(component, event, helper) {
        component.set("v.showButtons", true);
        component.set("v.Spinner", false);
    },
    
    validateRecord : function(component, event, helper) {
        component.set("v.showButtons", false);
        component.set("v.Spinner", true);
        var recId = component.get("v.recordId");
        //alert(recId);
        helper.callServer(component,'c.checkValidations',function(response){
            var toastEvent = $A.get("e.force:showToast");
            if(response == 'success') {
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                toastEvent.setParams({
                    title : 'SUCCESS!',
                    message: 'You have submitted this CIRF! Yay! Any changes after this point will count towards your revisions.',
                    type: 'success',
                    mode: 'dismissible'
                });
            }
            else {
                $A.get("e.force:closeQuickAction").fire();
                toastEvent.setParams({
                    title : 'Error Message!',
                    message: response,
                    type: 'error',
                    mode: 'dismissible'
                });
            }
            toastEvent.fire();
        },{
            recordId : recId
        })
    },
    
    closePopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    showSpinner: function(component, event, helper) { 
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){   
        component.set("v.Spinner", false);
    }
})