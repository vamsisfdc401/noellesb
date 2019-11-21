({
	checkAppStatus : function(component, event, helper) {
		var action = component.get("c.getAppStatus");
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.appInactiveMsg", response.getReturnValue());
             }
        });
        $A.enqueueAction(action);
	}
})