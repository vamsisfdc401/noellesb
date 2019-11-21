({
    init: function(component, event, helper){
    var prgDiv = component.find('prgId');
    $A.util.toggleClass(prgDiv,'slds-is-open');
	},  
    
	itemSelected : function(component, event, helper) {
		helper.itemSelected(component, event, helper);
	}, 
    
    serverCall :  function(component, event, helper) {
		helper.serverCall(component, event, helper);
	},
    
    clearSelection : function(component, event, helper){
        helper.clearSelection(component, event, helper);
    },
    
    toggleVisibility : function(component, event, helper){
        helper.toggleVisibility(component, event, helper);
	},
    
	blurtoggleVisibility : function(component, event, helper){
        helper.blurtoggleVisibility(component, event, helper);
    }

})