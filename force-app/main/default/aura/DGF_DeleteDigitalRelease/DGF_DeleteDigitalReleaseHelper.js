({
	redirectToRelease : function(component, event) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var releaseID = component.get("v.recordId");
        
        urlEvent.setParams({
            "url": "/" + releaseID,
            "isredirect": "TRUE"
        });
        urlEvent.fire();		
	},
    deleteReleaseAndRelatedRecords : function(component, event) {
		var action = component.get("c.deleteRelease");
        
        action.setParams({
            'releaseID': component.get("v.recordId")  
        });
               
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {	
                var storeResponse = response.getReturnValue();
                var urlEvent = $A.get("e.force:navigateToURL");
                
                urlEvent.setParams({
                    "url": "/" + storeResponse,
                    "isredirect": "TRUE"
                });
                urlEvent.fire();
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