({
    doInit: function(component, event, helper) {
        // Prepare a new record from template
        component.find("contactRecordCreator").getNewRecord(
            "Digital_Release__c", // sObject type (objectApiName)
            null,      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newDR");
                var error = component.get("v.newDRError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }
                console.log("Record template initialized: " + rec.sobjectType);
            })
        );
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
    handleSaveContact: function(component, event, helper) {
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        //alert(JSON.stringify(eventFields));
        //console.log(JSON.stringify(eventFields));
        var msg = '';
         if($A.util.isEmpty(eventFields["Name"]) || $A.util.isUndefined(eventFields["Name"])){
            msg = 'Please provide Release Name';
        }        
        if($A.util.isEmpty(eventFields["Title__c"]) || $A.util.isUndefined(eventFields["Title__c"])){
            msg += '\nPlease select Title';
        }        
        if(!$A.util.isEmpty(msg) && !$A.util.isUndefined(msg))
        {
            component.set("v.messageType", "error" );
            component.set("v.message",msg );
            component.set("v.showError", true);            
            setTimeout(
                $A.getCallback(function() {
                    component.set("v.showError", false);
                }), 5000
            );
            return;
        }else
        {
            var action = component.get("c.saveRec");
            action.setParams({
                recId : component.get("v.recordId"),
                strName : eventFields["Name"],
                strTitle : eventFields["Title__c"],
                seasonId : component.get("v.selRelease")
            });
            action.setCallback(this,function(a){
                var state = a.getState();
                if(state == "SUCCESS"){
                    if(a.getReturnValue() == 'No Records Found')
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "warning!",
                            "type": "warning",
                            "message": "There is no Previous Season record to clone from ."
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }                      
                    else
                    {
                        var recName = a.getReturnValue();
                       // alert('---'+recName);
                        var res=recName.split(" "); 
                          var strName1= eventFields["Name"];
							//alert(strName1);                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Success',                             
                            message: "test",
                            messageTemplate:'{1}',
                            messageTemplateData: ['Salesforce Lightning', {
                                url: 'http://uphe--stage.lightning.force.com/one/one.app?source=alohaHeader#/sObject/'+res[0],
                                label: ' '  +strName1+ '  ',
                            }],
                            duration:' 5000',                         
                            type: 'success',    
                            mode: 'pester'     
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                    }                     
                    
                } else if(state == "ERROR"){
                    
                    //alert('Error in calling server side action');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": "Error while saving record."
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
            });
            $A.enqueueAction(action);
        }
    }
})