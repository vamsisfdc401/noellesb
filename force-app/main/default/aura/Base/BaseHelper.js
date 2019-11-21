({
	callServer : function(component,method,callback,params) {
        console.log('Base Component');
        console.log(method);
        var action = component.get(method);
        
        if (params) {
            action.setParams(params);
            console.log('params');
        }
        console.log(JSON.stringify(action.getParams()));
        action.setCallback(this,function(response) {
            var state = response.getState();
            
        console.log(state);
        console.log(response.getReturnValue());
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
})