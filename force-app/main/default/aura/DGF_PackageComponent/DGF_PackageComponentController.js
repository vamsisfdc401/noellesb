({
    doInit : function(component, event, helper) {
        var action1 = component.get("c.fetchBonusRecords");
        action1.setParams({
            'recordID': component.get("v.recordId")  
        });
        var action2 = component.get("c.getRecordTypeId");
   
       var action4 = component.get("c.getProfileDetails");
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                component.set("v.recordsToDisplay", storeResponse); 
                component.set("v.numberOfRecords", storeResponse.length);   
                console.log(storeResponse);
                console.log(storeResponse.includes("CPE"));
                if(storeResponse.includes("CPE")){
                    component.set("v.cpe",true);
                } 
                if(storeResponse.includes("A la carte")){
                    component.set("v.alaCarte",true);
                } 
                if(storeResponse.includes("iTunes Extras")){
                    component.set("v.iTunes",true);
                } 
                if(storeResponse.includes("FOD")){
                    component.set("v.fod",true);
                } 
                if(storeResponse.includes("Pre-Order")){
                    component.set("v.preOrder",true);
                } 
                
            }    
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        }); 
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.recType",storeResponse);
            }    
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        }); 
    
       action4.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                //component.set("v.allRecords",storeResponse);
                component.set("v.restrictedProfile", storeResponse); 
                 component.set("v.isCodeError", false);
               
            }    
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        });
        $A.enqueueAction(action4);
        $A.enqueueAction(action1);
        $A.enqueueAction(action2);
    },
    createNewBonus : function (component,event,helper){
        component.set("v.isCodeError", false);
        
        var evt = $A.get("e.force:createRecord");
        evt.setParams({
            'entityApiName':'EPO_Bonus__c',
            'defaultFieldValues': {
                'Digital_Release__c':component.get("v.recordId")
                
            },
            'recordTypeId':component.get("v.recType")
        });
        
        evt.fire();
    },
    showSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",true);
    },    
    hideSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",false);
    },
    showBonusRecords : function(component,event,helper){
        component.set("v.isCodeError", false);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:DGF_BonusComponent",
            componentAttributes: {
                pkgName : event.target.name,
                releaseId : component.get("v.recordId")
            }
        });        
        evt.fire(); 
    },
    onCheck : function (component,event,helper){
        helper.checkBoxChange(component,event);
       
        
    },
    showAll: function(component,event,helper){
        component.set("v.isCodeError", false);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:DGF_BonusComponent",
            componentAttributes: {
                pkgName : "All",
                releaseId : component.get("v.recordId")
            }
        });        
        evt.fire(); 
    }
    
})