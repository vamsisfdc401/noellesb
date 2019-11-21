({
    doInit : function(component, event, helper) {  
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:DGf_AddCarriageComponent",
            componentAttributes: {
                AccountId : component.get("v.recordId"),
                
            }
        });        
        evt.fire(); 
    }
})