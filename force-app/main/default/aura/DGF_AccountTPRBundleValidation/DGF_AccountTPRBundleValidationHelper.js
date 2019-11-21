({
	validateAccount : function(component, event, acctId) {
		component.set('v.paginationList', null);
		var pageSize = component.get("v.pageSize");
		//alert('in account2');
		var action = component.get("c.validateBundlesInAccountTPR");
        action.setParams({ promotionId : component.get("v.recordId"),
                          AccountId : acctId});
        action.setCallback(this, function(response) {
            var state = response.getState();
           // alert('state' + state);
            if (state === "SUCCESS") {
                console.log("From server: " + JSON.stringify(response.getReturnValue()));
                //var result = response.getReturnValue();
			          //set response value in wrapperList attribute on component.
			             //component.set('v.pricingWrapper', response.getReturnValue());
			 	var bundleWrapperResponse = response.getReturnValue();
				 console.log('bundleWrapperResponse' + bundleWrapperResponse);
				
				 if(bundleWrapperResponse!='undefined'){
					// component.set('v.displayValidationMsg', "TRUE"); 
					 component.set("v.bundleWrapper", bundleWrapperResponse);
	                 component.set("v.totalSize", component.get("v.bundleWrapper").length);
	                 component.set("v.start",0);
	                 component.set("v.end",pageSize-1);
	                 var bundleWrapperSize = component.get("v.bundleWrapper").length;
	                 if(bundleWrapperSize>5){
	                	 pageSize = 5;
	                 }else{
	                	 pageSize = bundleWrapperSize;
	                 }
	                 var paginationList = [];
	                 for(var i=0; i< pageSize; i++)
	                 {
	                  paginationList.push(response.getReturnValue()[i]);    
	                  }
	                 component.set('v.paginationList', paginationList);
	
					 //component.set('v.pricingWrapper', response.getReturnValue());
				 }           
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } 
        });
        $A.enqueueAction(action);
	}
})