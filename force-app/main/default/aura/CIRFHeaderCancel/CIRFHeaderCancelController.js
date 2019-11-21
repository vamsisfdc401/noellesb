({
    doInit : function(component, event, helper) {
        component.set("v.showButtons", true);
        component.set("v.Spinner", false);
        
        helper.callServer(component,"c.getCancelReasonPicklist",function(response){
            var opts = [];
            opts.push({
                class : "optionClass",
                label : '--NONE--',
                value : ''
            });
            component.set("v.cancelReason",'');
            for (var i = 0; i < response.length; i++) {
                opts.push({
                    class: "optionClass",
                    label: response[i],
                    value: response[i]
                });
            }
            component.find('reason').set("v.options", opts);
        },{
            
        });
    },
    
    onPicklistChange: function(component, event, helper) {
        var pickval = event.getSource().get("v.value");
        component.set("v.cancelReason",pickval);
    },
    
    validateRecord : function(component, event, helper) {
        //component.set("v.showButtons", false);
        //component.set("v.Spinner", true);
        var recId = component.get("v.recordId");
        var cancelReason = component.get("v.cancelReason");
        var reasonField = component.find("reason");
        if($A.util.isEmpty(reasonField.get("v.value"))){
            //component.set("v.errorMessages",'Revision reason is required');
            reasonField.set("v.errors", [{message:"Cancellation reason can't be blank"}]);
        }
        else{
            //alert(recId);
            helper.callServer(component,'c.cancelHeader',function(response){
                var toastEvent = $A.get("e.force:showToast");
                if(response == 'success') {
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                    toastEvent.setParams({
                        title : 'SUCCESS!',
                        message: 'Header has been Cancelled',
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
                recordId : recId,
                cancelReason : cancelReason
            });
        }
        //component.set("v.showButtons", true);
        //component.set("v.Spinner", false);
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