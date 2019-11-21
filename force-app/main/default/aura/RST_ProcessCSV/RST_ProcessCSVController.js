({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var use_recordId = (recordId) ? recordId : component.get("v.use_recordId");
        console.log('got for ' + use_recordId);

        //var action = component.get("c.processCSVforFile");
        var action = component.get("c.processCSVLines");
        
        action.setParams({
            "fileUploadId" : use_recordId
        });
        
        action.setCallback(this, function(response){
            console.log(response.getReturnValue());
            var state=response.getState();
            var returnMessage;
            if(state==='SUCCESS'){
                component.set("v.ParseResults" , response.getReturnValue());
                console.log("send event here");

                helper.processRawCSV(component);
                /*
                var event = $A.get("e.c:RST_Event");
                event.setParams({"ParseResult": response.getReturnValue()});
                event.fire();
                */
                
            } else {
                console.log('error');

            }

            

        });
        $A.enqueueAction(action); 

    }
})