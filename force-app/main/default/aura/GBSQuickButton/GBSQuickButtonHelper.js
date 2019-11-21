({
	closeModalPopup : function(component) {
		//var cmpTarget = component.find('Modalbox');
        //var cmpBack = component.find('Modalbackdrop');
        //$A.util.removeClass(cmpBack,'slds-backdrop--open');
        //$A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
        
        console.log('closemodalpopup');
        
        var appEvent = $A.get("e.c:LMSProduct_IPSave");
        console.log('event triggered');
        appEvent.setParams({ "actionType" : "GoToLMS" });
        appEvent.fire();
        
       // component.set("v.loadModal", "false");
	},
    hideSpinner: function(component) {
        var spinner = component.find("mySpinner");
        console.log(spinner);
        $A.util.toggleClass(spinner, "slds-hide");
    },
    showSpinner: function(component) {
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})