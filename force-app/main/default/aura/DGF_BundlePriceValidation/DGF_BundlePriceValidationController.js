({
	loadData : function(component, event, helper) {
		var action1 = component.get('c.validateTitlePricingBundle');
        var action = component.get('c.validateBundleRelease');
        action.setParams({
                bundleProductId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {            
            	var storeResponse = response.getReturnValue();            	
            	//component.set("v.isNotProductUser", storeResponse);
            	
            	if(storeResponse!='undefined' && storeResponse!= '' && storeResponse ==='PASS'){
            		action1.setParams({
            			bundleProductId : component.get("v.recordId")
            		});
            		action1.setCallback(this, function(response) {
			        //store state of response
			        var state = response.getState();
			        if (state === "SUCCESS") {
			          //set response value in wrapperList attribute on component.
			             //component.set('v.pricingWrapper', response.getReturnValue());
			             var priceWrapperResponse = response.getReturnValue();
			             if(priceWrapperResponse!='undefined' && priceWrapperResponse.length  == 1){
			            	 console.log('priceWrapperResponse' + priceWrapperResponse.length);
			            	 if(priceWrapperResponse[0].name == "PASS"){
			            		 component.set('v.successResponse', priceWrapperResponse[0].validationNotes);
			            		 component.set('v.displaySuccessMsg', "TRUE");
			            	 }else{
			            		 component.set('v.displayValidationMsg', "TRUE"); 
			            		 component.set('v.pricingWrapper', response.getReturnValue());
			            	 }
			             }else if(priceWrapperResponse!='undefined' && priceWrapperResponse.length  > 1){
			            	 component.set('v.displayValidationMsg', "TRUE"); 
			            	 component.set('v.pricingWrapper', response.getReturnValue());
			             }
			        }
			      });
			      $A.enqueueAction(action1);            	
            	}else{
            		component.set('v.displayErrorMsg', "TRUE"); 
            		component.set('v.successResponse', storeResponse);
            	}
            }
        }); 
        $A.enqueueAction(action);
            
      
	      
    },
})