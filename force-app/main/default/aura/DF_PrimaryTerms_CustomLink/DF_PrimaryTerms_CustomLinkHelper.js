({
    Dealmethod: function(component, event, helper) {
        
        var action = component.get("c.getdealid");
        action.setParams({
            "primarytermsId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                component.set("v.idx", response.getReturnValue());
                helper.Deal(component, event, helper);
            } 
            
        });
        $A.enqueueAction(action);
    },
    
    Deal: function(component, event, helper) {
        var idx = component.get("v.idx");
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idx,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    Financialmethod: function(component, event, helper) {
        
        var action = component.get("c.getFinancialsid");
        action.setParams({
            "primarytermsFinId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                component.set("v.idx", response.getReturnValue());
                helper.Financial(component, event, helper);
            } 
            
        });
        $A.enqueueAction(action);
    },
    
    Financial: function(component, event, helper) {
        var idx = component.get("v.idx");
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idx,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    
    Titlemethod: function(component, event, helper) {
        
        var action = component.get("c.getTitleid");
        action.setParams({
            "primarytermsTitleId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                component.set("v.idx", response.getReturnValue());
                helper.Title(component, event, helper);
            } 
            
        });
        $A.enqueueAction(action);
    },
    
    Title: function(component, event, helper) {
        var idx = component.get("v.idx");
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idx,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    Compsmethod:function(component, event, helper) {
        
        var action = component.get("c.getcompsid");
        action.setParams({
            "primarytermscompsId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                component.set("v.idx", response.getReturnValue());
                helper.Comps(component, event, helper);
            } 
            
        });
        $A.enqueueAction(action);
    },
    
    Comps: function(component, event, helper) {
        var idx = component.get("v.idx");
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idx,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    Riskmethod:function(component, event, helper) {
        
        var action = component.get("c.getRiskid");
        action.setParams({
            "primarytermsRiskId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                component.set("v.idx", response.getReturnValue());
                helper.Risk(component, event, helper);
            } 
            
        });
        $A.enqueueAction(action);
    },
    
    Risk:function(component, event, helper) {
        var idx = component.get("v.idx");
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idx,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})