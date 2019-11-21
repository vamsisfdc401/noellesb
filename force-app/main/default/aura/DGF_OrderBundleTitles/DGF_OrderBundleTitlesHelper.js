({
    cancelPage : function(component,event){ 		
        var digiReleaseId = component.get("v.recordId");        
        var urlEvent = $A.get("e.force:navigateToURL");
        if(urlEvent) {
        	urlEvent.setParams({
            	"url": "/" + digiReleaseId
            });
            urlEvent.fire();
            $A.get('e.force:refreshView').fire();                        
         } 
    }, 
    
    searchTitle : function(component, event){
    
    	var action1 = component.get("c.searchTitles");
        action1.setParams({
            'searchKeyWord': component.get("v.searchKeyword")  
        });
        
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {            	
                var storeRes = response.getReturnValue();                        
                if(storeRes != null && storeRes.length > 0){ 
                   // component.set("v.allTitles",storeRes) ; 
                    var titleOptions = [];
                    titleOptions = component.get("v.listOptions");
                    //console.log('assigning from get>>' + titleOptions);
                    
                    for(var i=0;i<storeRes.length;i++){
                        titleOptions.push({"class": "optionClass",
                                       label: storeRes[i],
                                       value: storeRes[i]});
                    }                    
                    component.set("v.listOptions", titleOptions);
                }else{                
                	component.set("v.isCodeError", true);
                	component.set("v.CodeError", 'No Match Found');                
                }                        
            }else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        });
        $A.enqueueAction(action1);
    }    
    
})