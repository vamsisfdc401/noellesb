({
	getpricingTierList : function(component, event, helper) {
        helper.getPricingTierList(component);
    },
    onSingleSelectChange: function(component) {
         var selectCmp = component.find("input-id-01");
         
         component.set("v.selectedPType", selectCmp.get("v.value"));
	},
    onCheckboxChange : function(component, event, helper) {
        //Gets the checkbox group based on the checkbox id
		var availableCheckboxes = component.find('cboxRow');
        var resetCheckboxValue  = false;
        if (Array.isArray(availableCheckboxes)) {
            //If more than one checkbox available then individually resets each checkbox 
            availableCheckboxes.forEach(function(checkbox) {
                checkbox.set('v.value', resetCheckboxValue);
            }); 
        } else {
            //if only one checkbox available then it will be unchecked
            availableCheckboxes.set('v.value', resetCheckboxValue);
        }
        //mark the current checkbox selection as checked
        event.getSource().set("v.value",true);
	},
    processSlctd : function(component, event, helper) {
        
        var lstptRecords = component.get("v.ptRecords");
        console.log('====================='+JSON.stringify(lstptRecords));        
        var selectedIds = '';
        var fDate = component.find("expdate").get("v.value");
        
        if(fDate == null || fDate == '')
        {
             
            component.set("v.messageType", "error" );
            component.set("v.message","Please provide valid date." );
            component.set("v.showError", true);
            setTimeout(
                $A.getCallback(function() {
                    component.set("v.showError", false);
                }), 2000
            );
            return;
        }
        
        var caAD = component.get("v.DTRecord.CA_Bundle_Avail_Date__c");
        var usAD = component.get("v.DTRecord.US_Bundle_Avail_Date__c");
        var compDate;
        var usMsg = '';
        var caMsg = '';
        if((caAD ==''|| caAD == null) && (usAD =='' || usAD == null)){
            component.set("v.messageType", "error" );
            component.set("v.message"," Missing US Or CA  Bundle Avail Dates" );
            component.set("v.showError", true);
            setTimeout(
                $A.getCallback(function() {
                    component.set("v.showError", false);
                }), 6000
            );
            return;
        }
        /* Not Required
        if(!$A.util.isEmpty(caAD) && !$A.util.isUndefined(caAD) 
           && !$A.util.isEmpty(usAD) && !$A.util.isUndefined(usAD)){
            if(new Date(caAD) >= new Date(usAD)) {
                //compDate = caAD;
                compDate = usAD;
            }else
            {
                compDate = caAD;
                //compDate = usAD;
            }
            usMsg = 'Your US Bundle Avail Date is '+usAD;
            caMsg = 'Your CA Bundle Avail Date is '+caAD;
        }else if(!$A.util.isEmpty(caAD) && !$A.util.isUndefined(caAD) 
           && ($A.util.isEmpty(usAD) || $A.util.isUndefined(usAD))){
        	compDate = caAD;
            usMsg = '';
            caMsg = 'Your CA Bundle Avail Date is '+caAD;
        }else if(($A.util.isEmpty(caAD) || $A.util.isUndefined(caAD)) 
           && !$A.util.isEmpty(usAD) && !$A.util.isUndefined(usAD)){
        	compDate = usAD;
            usMsg = 'Your US Bundle Avail Date is '+usAD;
            caMsg = '';
        }
        //alert(caAD+'====='+usAD+'===='+compDate+'===='+fDate);
        if(!$A.util.isEmpty(compDate) && !$A.util.isUndefined(compDate))
        {
            //var usMsg = 'Your US Bundle Avail Date is '+usAD;
            //var caMsg = 'Your CA Bundle Avail Date is '+caAD;
            var msgA = usMsg+'\n'+caMsg+'.\n Price Effective Date must be equal to or greater than the US or CA Bundle Avail Date ';
            if(new Date(compDate) > new Date(fDate)) {
            	component.set("v.messageType", "error" );
                component.set("v.message",msgA );
                component.set("v.showError", true);
                setTimeout(
                    $A.getCallback(function() {
                        component.set("v.showError", false);
                    }), 6000
                );
                return;
            }
        }  */  
        
        if(!$A.util.isEmpty(lstptRecords) && !$A.util.isUndefined(lstptRecords)){
            var processSelected = true;
            var nonSelected = false;
            for(var  i = 0; i<lstptRecords.length; i++)
            {
             	if(lstptRecords[i].isSelected == true)
                {
                    nonSelected = true;
                }
            }
        	for(var  i = 0; i<lstptRecords.length; i++)
            {
             	if(lstptRecords[i].isSelected == true)
                {
                    selectedIds = lstptRecords[i].ptId;
                    //alert(lstptRecords[i].ptId);
                    if(lstptRecords[i].ptId == 'Temp')
                    {
                        //alert(JSON.stringify(lstptRecords[i]));
                                                                      
                        if(lstptRecords[i].ptName == '')
                        {
                            component.set("v.messageType", "error" );
                            component.set("v.message","Please provide valide name." );
                            component.set("v.showError", true);
                            setTimeout(
                                $A.getCallback(function() {
                                    component.set("v.showError", false);
                                }), 2000
                            );
                            return;
                        }
                        
                         
                        console.log('======='+JSON.stringify(lstptRecords[i]));
                          if( lstptRecords[i].uSSDWSP == '' && lstptRecords[i].uSSDSRP == ''
                           && lstptRecords[i].uSHDWSP == '' && lstptRecords[i].uSHDSRP == ''
                           && lstptRecords[i].uSUHDWSP == '' && lstptRecords[i].cAUHDSRP == ''
                           && lstptRecords[i].uSUHDSRP == '' && lstptRecords[i].cASDWSP == ''
                           && lstptRecords[i].cASDSRP == ''&& lstptRecords[i].cAHDWSP == ''
                           &&  lstptRecords[i].cAHDSRP == '' && lstptRecords[i].cAUHDWSP == '')
                        {
                             
                            processSelected = false;
                            
                            //alert(JSON.stringify(lstptRecords[i]));
                            
                        }
                    }
                }
            }
            
            if(nonSelected == false)
            {
                component.set("v.messageType", "error" );
                component.set("v.message","Please select one pricing tier." );
                component.set("v.showError", true);
                setTimeout(
                    $A.getCallback(function() {
                        component.set("v.showError", false);
                    }), 2000
                );
                return;
            }
            if(processSelected == false)
            {
                component.set("v.messageType", "error" );
                component.set("v.message","Please provide at least one price." );
                component.set("v.showError", true);
                setTimeout(
                    $A.getCallback(function() {
                        component.set("v.showError", false);
                    }), 2000
                );
                return;
            }
            //alert('selectedIds===='+component.find("expdate").get("v.value"));
            if(selectedIds!=null && selectedIds!='')
            {
                //alert(JSON.stringify(lstptRecords));
                var recId = component.get("v.recordId");
                 
                var action = component.get("c.savePricingTiers");
                action.setParams({
                    lstPts : JSON.stringify(lstptRecords),
                    dRRecId : recId,
                    selPType :component.get("v.selectedPType"),
                    seltoday : component.find("expdate").get("v.value")
                });
                action.setCallback(this,function(a){
                    var state = a.getState();
                    if(state == "SUCCESS"){
                        if(a.getReturnValue() == 'true' 
                           || a.getReturnValue() == true)
                        {
                            //alert('Success in calling server side action');
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "type": "success",
                                "message": "Pricing Records created Successfully!."
                            });
                            toastEvent.fire();
                            $A.get("e.force:closeQuickAction").fire();
                        }else if(a.getReturnValue() == 'false' 
                           || a.getReturnValue() == false)
                        {
                            component.set("v.messageType", "error" );
                			component.set("v.message","Missing Platform Offering." );
                			component.set("v.showError", true);
                			setTimeout(
                   			 $A.getCallback(function() {
                        		component.set("v.showError", false);
                    		}), 2000
                		);
               			 return;
                           /* var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "type": "error",
                                "message": "Missing Platform Offering."
                            });
                            toastEvent.fire();
                            $A.get("e.force:closeQuickAction").fire(); 
                            */
                        }else if(a.getReturnValue() == 'Pricing records exists')
                        {
                            component.set("v.messageType", "error" );
                			component.set("v.message","Price Effective Date for reprice must be greater than original valid from date." );
                			component.set("v.showError", true);
                			setTimeout(
                   			 $A.getCallback(function() {
                        		component.set("v.showError", false);
                    		}), 2000
                		);
               			 return;
                           /* var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "type": "error",
                                "message": "Price Effective Date for reprice must be greater than original valid from date."
                            });
                            toastEvent.fire();
                            $A.get("e.force:closeQuickAction").fire();
                            */
                        }
                    } else if(state == "ERROR"){
                         
                        //alert('Error in calling server side action');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": "An error has occured, Please contact an Administrator."
                        });
                        //Price Effective Date for reprice must be greater than original valid from date
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }
                });
                $A.enqueueAction(action);
            }
            
            
        }
    }
})