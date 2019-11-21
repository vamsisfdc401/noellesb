({
    processRawCSV : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var use_recordId = (recordId) ? recordId : component.get("v.use_recordId");
        console.log('got for ' + use_recordId);
        
        console.log('run processRawCSV_Batch');
        var action = component.get("c.processRawCSV_Batch");
        console.log('set params upload id : ' + use_recordId);
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

                var event = $A.get("e.c:RST_Event");
                event.setParams({"ParseResult": response.getReturnValue()});
                event.fire();

            } else {
                console.log('error');

            }

            

        });
        $A.enqueueAction(action); 

    }
})