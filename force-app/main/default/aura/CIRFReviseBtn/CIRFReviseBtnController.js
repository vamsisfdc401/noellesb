({
    
    doInit : function(component, event, helper) {
        component.set("v.showButtons", true);
        component.set("v.Spinner", false);
        //document.getElementById('modalwrap').style.overflow="hidden";
        helper.callServer(component,"c.getRevisionReasonPicklist",function(response){
            var opts = [];
            opts.push({
                class : "optionClass",
                label : '--NONE--',
                value : ''
            });
            component.set("v.revisionReason",'');
            
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
        component.set("v.revisionReason",pickval);
    },
    
    ReviseCIRF : function(component, event, helper) {
        var recId = component.get("v.recordId")  ;
        var revisionReason = component.get("v.revisionReason");
        var revisionField = component.find("reason");
        if($A.util.isEmpty(revisionField.get("v.value"))){
            //component.set("v.errorMessages",'Revision reason is required');
            revisionField.set("v.errors", [{message:"Revision reason can't be blank"}]);

        }
        //alert(recId);
        else{
            helper.callServer(component,'c.checkRevision',function(response){
                var toastEvent = $A.get("e.force:showToast");
                if(response != 'success') {
                    $A.get("e.force:closeQuickAction").fire();
                    toastEvent.setParams({
                        title : 'Error Message!',
                        message: response,
                        type: 'error',
                        mode: 'dismissible'
                    });
                }
                else {
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                    toastEvent.setParams({
                        title : 'Success!',
                        message: 'Success',
                        type: 'success',
                        mode: 'dismissible'
                    });
                }
                toastEvent.fire();
                //$A.get("e.force:closeQuickAction").fire();
            },{
                recordId : recId,
                revisionReason : revisionReason
            });
        }
    },
    
    closePopup : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    showSpinner: function(component, event, helper) { 
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){   
        component.set("v.Spinner", false);
    },
})