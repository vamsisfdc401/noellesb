({
	loadLMSInfo : function(component) {
        console.log('loadLMSInfo');
        console.log('loadWithoutBtn'+component.get("v.loadWithoutBtnClick"));
        console.log('LMSID'+component.get("v.LMSId"));
        var action = component.get("c.loadLMSDetails");
        action.setParams({"LMSId": component.get("v.LMSId")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state == "SUCCESS") {
                console.log('load LMS success');
                console.log(response.getReturnValue());
                component.set("v.LMS", response.getReturnValue());
                
                var action1 = component.get("c.loadSelectedProductRights");
                
                action1.setParams({"PRGId":component.get("v.LMS").Product_Rights_Group__c,"LMS":component.get("v.LMS")});
                
                action1.setCallback(this, function(response) {
                    console.log('product rights list'+response.getReturnValue());
                    component.set("v.selectedProducts", response.getReturnValue());
                    var action2 = component.get("c.loadRelatedProductRights");
                    console.log("selected products : "+component.get("v.selectedProducts"));
                    action2.setParams({"alreadySelectedProducts": JSON.stringify(component.get("v.selectedProducts")), 
                                       "ContractId": component.get("v.LMS").Contract__c});
                    console.log('get available products');
                    action2.setCallback(this, function(response) {
                    	console.log('available products : ');
                        console.log(response.getReturnValue());    
                    	component.set("v.products", response.getReturnValue());
                        //this.loadIPRights(component);
                        this.hideSpinner(component);
                    });
                    $A.enqueueAction(action2);
                });
                $A.enqueueAction(action1);
            }
        });
        $A.enqueueAction(action);
	},
    addProduct : function(component, index) {
        var selectedProducts = component.get("v.selectedProducts");
        var products = component.get("v.products");
        console.log(products);
        console.log(selectedProducts);
        
        //	Add the selected component to the selected Products list
        selectedProducts.push(products[index]);
        
        //	Remove the selected product from Available products
        products.splice(index, 1);
        
        //	Set updated record sets to UI attributes
        component.set("v.selectedProducts", selectedProducts);
        component.set("v.products", products);
    },
    addIP : function(component, index) {
        var selectedIntellectualProperties = component.get("v.selectedIntellectualProperties");
        var intellectualProperties = component.get("v.intellectualProperties");
        
        //	Add the selected component to the selected Products list
        selectedIntellectualProperties.push(intellectualProperties[index]);
        
        //	Remove the selected product from Available intellectualProperties
        intellectualProperties.splice(index, 1);
        
        //	Set updated record sets to UI attributes
        component.set("v.selectedIntellectualProperties", selectedIntellectualProperties);
        component.set("v.intellectualProperties", intellectualProperties);
    },
    removeProduct : function(component, index) {
        console.log('helper :'+index);
        var selectedProducts = component.get("v.selectedProducts");
        var products = component.get("v.products");
        
        //	Add the selected component to the selected Products list
        products.push(selectedProducts[index]);
        
        //	Remove the selected product from Available products
        selectedProducts.splice(index, 1);
        
        //	Set updated record sets to UI attributes
        component.set("v.selectedProducts", selectedProducts);
        component.set("v.products", products);
    },
    removeIP : function(component, index) {
        var selectedIntellectualProperties = component.get("v.selectedIntellectualProperties");
        var intellectualProperties = component.get("v.intellectualProperties");
        
        //	Add the selected component to the selected Products list
        intellectualProperties.push(selectedIntellectualProperties[index]);
        
        //	Remove the selected product from Available intellectualProperties
        selectedIntellectualProperties.splice(index, 1);
        
        //	Set updated record sets to UI attributes
        component.set("v.selectedIntellectualProperties", selectedIntellectualProperties);
        component.set("v.intellectualProperties", intellectualProperties);
    },
    searchProducts : function(component) {
        console.log('search entered');
        console.log('Team PWC '+JSON.stringify(component.get("v.LMS")));
        var action = component.get("c.getProductRights");
        action.setParams({"selectedProducts": JSON.stringify(component.get("v.selectedProducts")), 
                          "searchKey": component.get("v.searchKeyword"), 
                          "PRGId": component.get("v.LMS").Product_Rights_Group__c,
                          "contractId":component.get("v.LMS").Contract__c
                         });
        console.log('parameters set for search');                  
        action.setCallback(this, function(response) {
        	console.log('inside callback');
            console.log(response.getReturnValue());
            component.set("v.products", response.getReturnValue());
        });   
        $A.enqueueAction(action);
    },
    searchIPs : function(component) {
        console.log('IP search entered');
        
        console.log('PWC '+JSON.stringify(component.get("v.selectedProducts")));
        var action = component.get("c.getIPRights");
        action.setParams({"selectedIPRights": JSON.stringify(component.get("v.selectedIntellectualProperties")),
                          "searchKey": component.get("v.searchIPKey"), 
                          "PRGId": component.get("v.LMS").Product_Rights_Group__c,
                          "contractId": component.get("v.LMS").Contract__c,
                          "selectedProductGroup" : JSON.stringify(component.get("v.selectedProducts"))
                         });
        console.log('parameters set for search');
        console.log(component.get("v.selectedIntellectualProperties"));
        action.setCallback(this, function(response) {
        	console.log('inside callback');
            console.log(response.getReturnValue());
            component.set("v.intellectualProperties", response.getReturnValue());
        });   
        $A.enqueueAction(action);
    },
    loadIPRights: function(component) {
        var loadselectedIPData = component.get("c.loadSelectedIPRights");
        
        loadselectedIPData.setParams({"PRGId":component.get("v.LMS").Product_Rights_Group__c,
                                      "LMSId":component.get("v.LMS").Id});
        
        loadselectedIPData.setCallback(this, function(response) {
            component.set("v.selectedIntellectualProperties", response.getReturnValue());
            console.log('--------- ');
            console.log(response.getReturnValue());
            var loadIPData = component.get("c.loadRelatedIPRightsUpdated");
            
            console.log('===TEAM PWC SDC === '+JSON.stringify(component.get("v.selectedProducts")));
            loadIPData.setParams({"alreadySelectedProducts": JSON.stringify(component.get("v.selectedProducts")),                                   
                                  "PRGId": component.get("v.LMS").Product_Rights_Group__c, 
                                  "LMS":component.get("v.LMS"),
                                  "alreadySelectedIP":JSON.stringify(component.get("v.selectedIntellectualProperties"))
                                 });
            
            loadIPData.setCallback(this, function(response1) {
                console.log('================');
                console.log(response1.getReturnValue());
                
                component.set("v.intellectualProperties", response1.getReturnValue());
                component.set("v.isIPLoaded", "true");
                this.hideSpinner(component);
            });
            $A.enqueueAction(loadIPData);
             this.hideSpinner(component);
        });
        $A.enqueueAction(loadselectedIPData);
    },
    hideSpinner: function(cmponent) {
        //	Hide Spinner
        var appEvent = $A.get("e.c:LMSProduct_IPSave");
        console.log('event triggered');
        appEvent.setParams({ "actionType" : "hideSpinner" });
        appEvent.fire();
    },
    save: function(component) {
        var action = component.get("c.saveUpdated");
        action.setParams({"selectedProducts": JSON.stringify(component.get("v.selectedProducts")), 
                          "selectedIPs": JSON.stringify(component.get("v.selectedIntellectualProperties")), 
                          "LMSId":component.get("v.LMS").Id, 
                          "PRGId":component.get("v.LMS").Product_Rights_Group__c,
                          "contactId": component.get("v.LMS").Contract__c
                         });
        
        action.setCallback(this, function(response) {
            console.log(response.getReturnValue()); 
            var resp = response.getReturnValue();
            if(response.getReturnValue() == 'Success') {
                this.hideSpinner(component);
                
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
            this.navigateToLMS(component);
        });
        $A.enqueueAction(action);
    },
    navigateToLMS: function(component) {
        var LMSId = component.get("v.LMS").Id;        
        // changes related to GBS-733        
        var workspaceAPI = component.find("workspace"); 
        
        if(workspaceAPI != 'undefined'){
            var focusedTabId = '';
            var isconsole = '';               
            workspaceAPI.isConsoleNavigation().then(function(response) {                    
                console.log(response);
                isconsole = response;
                if(isconsole == true){
                    workspaceAPI.getFocusedTabInfo().then(function(response){
                        focusedTabId = response.tabId;                         
                        workspaceAPI.closeTab({tabId:focusedTabId});                        
                    })             
                    .catch(function(error) {                        
                        $A.get("e.force:closeQuickAction").fire(); 
                    });
                }
                
            })                
            .catch(function(error) {
                $A.get("e.force:closeQuickAction").fire(); 
            });
        }
        var navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({
            recordId: LMSId,
            slideDevName: "detail"
        });
        navEvent.fire();
        
    }
})