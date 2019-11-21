({
    doInit: function(component, event, helper) {
    	console.log(component.get("v.recordId"));
        var loadFlag = component.get("v.loadWithoutBtnClick");
        //alert(loadFlag);
        //component.set("v.loadWithoutBtnClick", "false");
        if(loadFlag) { 
            var action = component.get("c.openmodal");
            $A.enqueueAction(action);
        }
        
    },
    closeModal:function(component,event,helper){    
        helper.closeModalPopup(component);
    },
    handleEvent:function(component,event,helper){    
        console.log('hide spinner');
        var paramFromEvent = event.getParam("actionType");
        if(paramFromEvent == 'closePopup')	
        	helper.closeModalPopup(component);
        else if(paramFromEvent == 'hideSpinner')
            helper.hideSpinner(component);	
    },
    openmodal: function(component,event,helper) {
        component.set("v.loadModal", "true");
        component.set("v.currentStep", 1);
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    },
    saveProducts: function(component, event, helper) {
        helper.showSpinner(component);
        var appEvent = $A.get("e.c:LMSProduct_IPSave");
        console.log('event triggered');
        appEvent.setParams({ "actionType" : "saveAndExit" });
        appEvent.fire();
    },
    saveIPs: function(component, event, helper) {
    	helper.showSpinner(component);
        var appEvent = $A.get("e.c:LMSProduct_IPSave");
        console.log('event triggered');
        appEvent.setParams({ "actionType" : "save" });
        appEvent.fire();	    
    },
    goToStep2: function(component, event, helper) {
        helper.showSpinner(component);
        var appEvent = $A.get("e.c:LMSProduct_IPSave");
        console.log('event triggered');
        appEvent.setParams({ "actionType" : "Next" });
        appEvent.fire();
        component.set("v.currentStep", 2);
        
    },
    goToStep1: function(component, event, helper) {
        var appEvent = $A.get("e.c:LMSProduct_IPSave");
        console.log('event triggered');
        appEvent.setParams({ "actionType" : "Back" });
        appEvent.fire();
        component.set("v.currentStep", 1);
    }
})