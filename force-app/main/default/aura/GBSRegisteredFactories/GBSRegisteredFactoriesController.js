({
    doInit : function(component, event, helper)  {
        // in the server-side controller
        var action = component.get("c.GetActiveFactories");
        action.setParams({ LicenseeId : component.get("v.recordId") });
        
        var action2 = component.get("c.GetInActiveFactories");
        action2.setParams({ LicenseeId : component.get("v.recordId") });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
          
                // from the server
                component.set('v.acfactlist', response.getReturnValue());
                 $A.enqueueAction(action2);
                // action is complete
            }
          
        });
          action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
          
                // from the server
                component.set('v.infactlist', response.getReturnValue());
                // action is complete
            }
          
        });

        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    }
})