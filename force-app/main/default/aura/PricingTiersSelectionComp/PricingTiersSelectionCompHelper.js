({
	getPricingTierList : function(component) {
        component.set("v.noProducts",false);
        component.set("v.profileMatch",false);
        var msg = '';
        var profileAction = component.get("c.getUserProfile");
        profileAction.setCallback(this, function(profileActionResult){
            var state = profileActionResult.getState();
            if (state === "SUCCESS") 
            {
				//alert(profileActionResult.getReturnValue());
                if(profileActionResult.getReturnValue() == 'DD Product User'|| profileActionResult.getReturnValue() == 'System Administrator')
                {
            		//component.set("v.profileMatch",true);
                }else
                {
                    msg = 'Your profile doesn\'t have permissions to create pricing records.';
                    //component.set("v.messageType", "warning" );
                    //component.set("v.message","Your profile doesn't have permissions to create pricing records." );
                    //component.set("v.showError", true); 
                }
                var noProducts = false;
                var action = component.get("c.getPTRecords");
                var recId = component.get("v.recordId");
                var self = this;
                action.setParams({
                    "recId":recId
                });
                action.setCallback(this, function(actionResult){
                    component.set("v.ptRecords",actionResult.getReturnValue());
                    var lstRecords = component.get("v.ptRecords");
                    var selPType = '';             
                    
                    for(var  i = 0; i<lstRecords.length; i++)
                    {
                        if((lstRecords[i].isCreated == 'true' || lstRecords[i].isCreated == true) 
                           && selPType == '')
                        {
                            selPType = lstRecords[i].isCreated;
                        }
                        
                        if(lstRecords[i].isProductsExists == false)
                        {
                            noProducts = true;
                        }
                    }
                    
                    if(noProducts == true)
                    {
                        component.set("v.noProducts",true);
                        component.set("v.messageType", "error" );
                        component.set("v.message","Please add products to the Bundle." );
                        component.set("v.showError", true);
                    }
                    var iC = component.get("v.DTRecord.Initial_Pricing_Tier__c");
                    
                    if(selPType == 'true' || selPType == true || iC == 'Custom')
                    {
                        var opts = [
                            { "class": "optionClass", label: "Reprice", value: "Reprice", selected: "true" }
                        ];
                        component.find("input-id-01").set("v.options", opts);
                        component.set("v.selectedPType","Reprice");
                    }else
                    {
                        var opts = [
                            { "class": "optionClass", label: "Original", value: "Original", selected: "true" }
                            //,
                            //{ "class": "optionClass", label: "Reprice", value: "Reprice" }
                
                        ];
                        component.find("input-id-01").set("v.options", opts);
                        component.set("v.selectedPType","Original");
                    }
                    
        
                    //alert(iC+'=====');
                    /*if(iC == 'Custom')
                    {
                        var opts = [
                            { "class": "optionClass", label: "Reprice", value: "Reprice", selected: "true" }
                        ];
                        component.find("input-id-01").set("v.options", opts);
                        component.set("v.selectedPType","Reprice");
                    }else
                    {
                        var opts = [
                            { "class": "optionClass", label: "Original", value: "Original", selected: "true" }
                            //,
                            //{ "class": "optionClass", label: "Reprice", value: "Reprice" }
                            
                        ];
                        component.find("input-id-01").set("v.options", opts);
                        component.set("v.selectedPType","Original");
                    }*/
                    if(noProducts == false)
                    {
                        var productAction = component.get("c.getProductSel");
                        productAction.setParams({
                            "recId":component.get("v.recordId")
                        });
                        productAction.setCallback(this, function(productActionResult){
                            var state = productActionResult.getState();
                            if (state === "SUCCESS") 
                            {
                                //alert('==='+productActionResult.getReturnValue());
                                if(productActionResult.getReturnValue() == 'true' 
                                   || productActionResult.getReturnValue() == true)
                                {
                                    //component.set("v.profileMatch",true);
                                }else
                                {
                                    msg += '\n Missing Resolution.';
                                    
                                }
                            }
                            //alert(msg);
                            if(msg!=null && msg!='')
                            {
                                component.set("v.profileMatch",false);
                                component.set("v.messageType", "warning" );
                                component.set("v.message",msg );
                                component.set("v.showError", true);
                            }else
                            {
                                component.set("v.profileMatch",true);
                            }
                            
                        });
                        $A.enqueueAction(productAction);
                    }
                });
                $A.enqueueAction(action);
                
            }
            
        });
        $A.enqueueAction(profileAction);
        
        
        
        
    },
})