({
    doInit: function(component, event, helper) {
        var action = component.get('c.getSeasonOptions');
        action.setParams({recId : component.get("v.recordId")});
        
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if(state === "SUCCESS"){           
                component.set('v.releaseOptions', response.getReturnValue());
            } else if (state === "ERROR") {
                //otherwise write errors to console for debugging
                alert('Problem with connection. Please try again. Error Code: relIPViewHelper.getIPList.action.setCallback');
                resultsToast.setParams({
                    "title": "Error",
                    "message": "Invention contacts failed to load due to: " + JSON.stringify(result.error)
                });
                resultsToast.fire();
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
        
    },
    handleClick : function(component, event, helper) {         
        
        var action = component.get("c.clonePricingRecords");       
        action.setParams({             
            recId :  component.get("v.recordId"),
            seasonId : component.get("v.selRelease")
        });
        
        action.setCallback(this,function(a){
            var state = a.getState();
            
            if(state == "SUCCESS"){
                if(a.getReturnValue() == 'CA/US Launch Date')
                {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "Error",
                        "message": " Missing EST Launch Date(s) on Digital Release."
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                } if(a.getReturnValue() == 'No Records Found')
                {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "warning!",
                        "type": "warning",
                        "message": " There was no pricing records to clone from previous season ."
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                } if(a.getReturnValue() =='Created') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": " Successfully Cloned Pricing Records from previous season !."
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }
            }
            else if(state == "ERROR"){
                
                //alert('Error in calling server side action');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "Error while cloning pricing records from previous season."
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    removeCSS :function(Component, event, helper){
        
        $A.get("e.force:closeQuickAction").fire();
    },
    selectPickList : function(Component, event, helper){
        console.log('The selected Record Type is: ' +Component.get("v.selRelease"));  
        
    }
})