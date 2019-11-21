({
    checkBoxChange : function(component,event) {
        var src=event.getSource();
        console.log(src.getLocalId());
        var checkCmp = component.find(src.getLocalId());
        
        console.log(checkCmp.get("v.value"));
        
        if(checkCmp.get("v.value")){
            var action1 = component.get("c.createBonusRecord");
            action1.setParams({
                'recordID': component.get("v.recordId"),
                'packageSelected' : src.getLocalId(),
                'pkgList' : component.get("v.recordsToDisplay")
            });
            action1.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    // set searchResult list with return value from server.
                    component.set("v.recordsToDisplay", storeResponse); 
                    component.set("v.numberOfRecords", storeResponse.length);   
                    console.log(storeResponse);
                    component.set("v.isCodeError", false);
                    
                }    
                else if (state === "ERROR"){
                    component.set("v.isCodeError", true);
                    //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                    component.set("v.CodeError", response.getError()[0].message);
                    console.log("Error Message", response.getError()[0].message);
                }
            }); 
            $A.enqueueAction(action1);
            
        }
        else{
            var action2 = component.get("c.removePackage");
            action2.setParams({
                'recordID': component.get("v.recordId"),
                'packageRemoved' : src.getLocalId(),
                'pkgList' : component.get("v.recordsToDisplay")
            });
            action2.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    // set searchResult list with return value from server.
                    component.set("v.recordsToDisplay", storeResponse); 
                    component.set("v.numberOfRecords", storeResponse.length);   
                    console.log(storeResponse);
                    component.set("v.isCodeError", false);
                    
                }    
                else if (state === "ERROR"){
                    if(response.getError()[0].message.includes('INSUFFICIENT')){
                        component.set("v.isCodeError", true);
                        component.set("v.CodeError", 'Insufficient Privileges');
                        if(src.getLocalId()=='CPE'){
                            component.set("v.cpe",true);
                        }
                        else  if(src.getLocalId()=='iTunes Extras'){
                            component.set("v.iTunes",true);
                        }
                         else  if(src.getLocalId()=='A la carte'){
                            component.set("v.alaCarte",true);
                        }
                         else  if(src.getLocalId()=='FOD'){
                            component.set("v.fod",true);
                        } 
                             else  if(src.getLocalId()=='Pre-Order'){
                            component.set("v.preOrder",true);
                        }
                    }
                    else{
                        component.set("v.isCodeError", true);
                        component.set("v.CodeError", response.getError()[0].message);
                        
                    }
                    
                    //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                    
                    
                    
                }
            }); 
            $A.enqueueAction(action2);
            
            
            
        }
        
        
    }
})