({
    Dealmethod: function(component, event, helper) {
        
        var action = component.get("c.getdealidrisk");
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
        
        var action = component.get("c.getFinancialsidrisk");
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
        
        var action = component.get("c.gettitleidrisk");
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
        
        var action = component.get("c.getcompsidrisk");
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
   Primarymethod:function(component, event, helper){
        
        var action = component.get("c.getprimaryidrisk");
        action.setParams({
            "primarytermsprimaryId":component.get("v.recordId")
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
    
    Primary:function(component, event, helper){
        var idx = component.get("v.idx");
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": idx,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})