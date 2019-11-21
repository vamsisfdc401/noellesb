({
    doInit : function(component, event, helper) {  
        
        var action = component.get("c.getUserAccess");
        
        action.setParams({
            'recordId': component.get("v.recordId"),
            'isCloneProcess': "true"
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                
                if(storeResponse == null || storeResponse == ''){
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:DGF_ClonePromotionComponent",
                        componentAttributes: {
                            recordId : component.get("v.recordId"),
                            isCloneProcess : true,
                            isredirect : false
                        }
                    });        
                    evt.fire(); 
                }
                else{
                     component.set("v.isCodeError", true);
                    //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                    component.set("v.CodeError", storeResponse);
                    console.log("Error Message", storeResponse);
                }
            }            
        });
        $A.enqueueAction(action);        
    }
})