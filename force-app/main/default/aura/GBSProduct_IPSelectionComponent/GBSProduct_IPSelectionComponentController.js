({ 
    doInit : function(component, event, helper) { 
        //var lmsId = component.get("v.LMSId");
        console.log('Product Selection component started'); 
        helper.loadLMSInfo(component);
    },
    addSelectedProduct : function(component, event, helper) {
        //getting the index of record to be added
        var index = event.target.dataset.index;
        
        //calling helper to add product
        helper.addProduct(component, index);
    },
    addSelectedIP : function(component, event, helper) {
        //getting the index of record to be added
        var index = event.target.dataset.index;
        
        //calling helper to add product
        helper.addIP(component, index);
    },
    selectAllProducts: function(component, event, helper) {
      	var availableProducts = component.get("v.products");
        var selectedProducts = component.get("v.selectedProducts");
        
        selectedProducts = selectedProducts.concat(availableProducts);
        console.log('selectedProducts: '+selectedProducts);
        availableProducts = [];
        
        component.set("v.products", availableProducts);
        component.set("v.selectedProducts", selectedProducts);
    },
    selectAllIPs: function(component, event, helper) {
      	var selectedIntellectualProperties = component.get("v.selectedIntellectualProperties");
        var intellectualProperties = component.get("v.intellectualProperties");
        
        selectedIntellectualProperties = selectedIntellectualProperties.concat(intellectualProperties);
        
        intellectualProperties = [];
        
        component.set("v.intellectualProperties", intellectualProperties);
        component.set("v.selectedIntellectualProperties", selectedIntellectualProperties);
    },
    removeAllProducts: function(component, event, helper) {
      	var availableProducts = component.get("v.products");
        var selectedProducts = component.get("v.selectedProducts");
        
        availableProducts = availableProducts.concat(selectedProducts);
        
        selectedProducts = [];
        
        component.set("v.products", availableProducts);
        component.set("v.selectedProducts", selectedProducts);
    },
    removeAllIPs: function(component, event, helper) {
      	var selectedIntellectualProperties = component.get("v.selectedIntellectualProperties");
        var intellectualProperties = component.get("v.intellectualProperties");
        
        intellectualProperties = intellectualProperties.concat(selectedIntellectualProperties);
        
        selectedIntellectualProperties = [];
        
        component.set("v.intellectualProperties", intellectualProperties);
        component.set("v.selectedIntellectualProperties", selectedIntellectualProperties);
    },
    removeSelectedProduct : function(component, event, helper) {
        //getting the index of record to be removed
        var index = event.target.dataset.index;
        
        //calling helper to remove product
        helper.removeProduct(component, index);
    },
    removeSelectedIP : function(component, event, helper) {
        //getting the index of record to be removed
        var index = event.target.dataset.index;
        
        //calling helper to remove product
        helper.removeIP(component, index);
    },
    onEnterClickSearch : function(component, event, helper) {        
        if(event.getParams().keyCode == 13){
            // call helper method
            helper.searchProducts(component);         
        }
    },
    onEnterClickSearch_IP: function(component, event, helper) {
        if(event.getParams().keyCode == 13){
            // call helper method
            helper.searchIPs(component);         
        }
    },
    searchProducts : function(component, event, helper) {
        // call helper method
        helper.searchProducts(component); 
    },
    searchIPRights: function(component, event, helper) {
    	helper.searchIPs(component);    
    },
    handleEvent: function(component, event, helper) {
        var paramFromEvent = event.getParam("actionType");
        
        console.log('event param : '+paramFromEvent);
        
        if(paramFromEvent == 'saveAndExit') {
            var action = component.get("c.saveSelectedProductsUpdated");
            action.setParams({"selectedProducts": JSON.stringify(component.get("v.selectedProducts")),
                              "LMSId":component.get("v.LMS").Id, 
                              "PRGId":component.get("v.LMS").Product_Rights_Group__c
                             });
            
            action.setCallback(this, function(response) {
                console.log(response.getReturnValue()); 
                var resp = response.getReturnValue();
                if(response.getReturnValue() == 'Success') {
                    helper.hideSpinner(component);
                    
                    //	Show Error Message
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "title": "Success:",
                        "message": "Save successful!"
                    });
                    toastEvent.fire();
                    
                    /*var appEvent = $A.get("e.c:LMSProduct_IPSave");
                    console.log('event triggered');
                    appEvent.setParams({ "actionType" :  'closePopup'});
                    appEvent.fire();*/
                    $A.get("e.force:closeQuickAction").fire();
                    //handler.navigateToLMS(component);
                }
                else {
                    //	Show Error Message
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error:",
                        "message": resp
                    });
                    toastEvent.fire();
                }
                helper.navigateToLMS(component);
            });
            $A.enqueueAction(action);
        }
        else if(paramFromEvent == 'Next') {
            console.log('next');
            //if(!component.get("v.isIPLoaded"))
            	helper.loadIPRights(component);
            //else {
                helper.hideSpinner(component);
            //}
            component.set("v.currentStep", 2);
        }
        else if(paramFromEvent == 'Back') {
            component.set("v.currentStep", 1);
        }
        else if(paramFromEvent == 'save') {           
        	helper.save(component);	        
        }
        else if(paramFromEvent == 'GoToLMS') {           
        	helper.navigateToLMS(component);
        }
    }
})