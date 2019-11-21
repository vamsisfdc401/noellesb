({
	doInit : function(component, event, helper) {
		 var action1 = component.get("c.getBonusDetails");
         action1.setParams({
            'releaseId': component.get("v.releaseId"),
             'pkgName' : component.get("v.pkgName")
        });
        var action2 =  component.get("c.getReleaseName");
          action2.setParams({
            'releaseId': component.get("v.releaseId")
          });
        
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                component.set("v.bonusList", storeResponse);  
                //$A.get('e.force:refreshView').fire();
              /* if(component.get("v.isjQueryLoaded")){
                    window.setTimeout(function(){
                        $("#fixTable3").tableHeadFixer({"left" : 1,"z-index" : 3});
                    },100);
                }         */       
            }    
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        }); 
         $A.enqueueAction(action1);
         action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                component.set("v.releaseName", storeResponse);  
                //$A.get('e.force:refreshView').fire();
              /* if(component.get("v.isjQueryLoaded")){
                    window.setTimeout(function(){
                        $("#fixTable3").tableHeadFixer({"left" : 1,"z-index" : 3});
                    },100);
                }         */       
            }    
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        }); 
         $A.enqueueAction(action2);
	},
     showSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",true);
    },    
    hideSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",false);
    }
})