({
    doInit: function(component, event, helper) {
        console.log('load steps');
        var use_steps = [];
        use_steps.push({num : 1, text : 'Upload CSV'});
        use_steps.push({num : 2, text : 'Process CSV'});
        use_steps.push({num : 3, text : 'Call Magic'});
        component.set("v.steps", use_steps);
        component.set("v.curStep", 1);
        

    },
    handleUploadFinished : function(component, event, helper) {
        console.log('process file');
        component.set("v.processing", true);
        component.set("v.curStep", 2);
        
    },
    handleNewUploadRecord : function(component, event, helper) {
        component.set("v.processing", false);
        var payload = event.getParams().response;
        console.log(payload.id);
        component.set("v.upload_record_id", payload.id);
    },
    eventReceived : function(component, event, helper) {
        var ParseResult = event.getParam("ParseResult");
        console.log('received event ' +  ParseResult.result);
        console.log(ParseResult);

        component.set("v.Result", ParseResult);
        console.log(ParseResult);
        
        // success or issues
        //component.set("v.curStep", 3);
    },
    batchProcessComplete : function(component, event, helper) {
        if(ParseResult.result == 'Success'){
    
            var upload_id = component.get('v.upload_record_id');
            console.log('upload_id  id: ' + upload_id);
            
            var action = component.get("c.callMagicForUpload");
            action.setParams({"uploadId" : upload_id});
            action.setCallback(this, function(response){
                var state=response.getState()
                if(state==='SUCCESS'){
                    
                    component.set("v.Result" , response.getReturnValue());
                    console.log(response.getReturnValue());
                    console.log('completed magic update');
                } else {
                    
                }
            });
            $A.enqueueAction(action); 

            component.set("v.processingMagic", true);
            component.set("v.curStep", 4);
        }
    }


})