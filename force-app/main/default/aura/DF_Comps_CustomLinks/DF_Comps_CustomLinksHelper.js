({
    Dealmethod: function(component, event, helper) {
        
        var action = component.get("c.getdealidcomps");
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
        
        var action = component.get("c.getFinancialsidcomps");
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
        
        var action = component.get("c.gettitleidcomps");
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
   Primarymethod: function(component, event, helper) {
        
        var action = component.get("c.getprimaryidcomps");
        action.setParams({
            "primarytermsprimaryId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                component.set("v.idx", response.getReturnValue());
                helper.Primary(component, event, helper);
            } 
            
        });
        $A.enqueueAction(action);
    },
    
    Primary: function(component, event, helper) {
        var idx = component.get("v.idx");
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idx,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    Riskmethod:function(component, event, helper) {
        
        var action = component.get("c.getRiskidcomps");
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