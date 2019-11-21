({
    doInit : function(cmp , event, helper) {  
        var action = cmp.get("c.getRecTypeName");
        action.setParams({ recId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert("From server: " + JSON.stringify(response.getReturnValue()));
                var result = response.getReturnValue();//alert(result.RecordType.Name);
                cmp.set("v.promotion",result);
             var evt = $A.get("e.force:navigateToComponent");
             evt.setParams({
                 componentDef : (result.RecordType.Name=="National Promotion"?"c:DGF_TPRBundlePriceValidation":"c:DGF_AccountTPRBundleValidation"),
            componentAttributes: {
                recordId : cmp.get("v.recordId"),
                promotion : cmp.get("v.promotion")
            }
        });        
        evt.fire(); 
            }
            else if (state === "INCOMPLETE") {
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
            }
        });
        $A.enqueueAction(action);
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }
	
})