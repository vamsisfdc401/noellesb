({
    doInit : function(component, event, helper) {  
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:DGF_NewProductComponent",
            componentAttributes: {
                releaseRecordId : component.get("v.recordId")
            }
        });        
        evt.fire(); 
    }
})