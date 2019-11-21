({
    /*
     * @author: Nandeesh 
     * @Story #: DFOR-105
     * @purpose: To retrive the related pricing records for Digital release.
     * 
    */
    doInit : function(component, event, helper) { 
        component.set("v.numberOfRecords", "0"); 
        var action1 = component.get("c.fetchRelatedRecords");
        
        action1.setParams({
            'recordID': component.get("v.recordId")  
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                component.set("v.recordsToDisplay", storeResponse); 
                component.set("v.numberOfRecords", storeResponse.length);   
                if(component.get("v.isjQueryLoaded")){
                    window.setTimeout(function(){
                        $("#fixTable3").tableHeadFixer({"left" : 1,"z-index" : 3});
                    },100);
                }                
            }    
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                component.set("v.CodeError", response.getError()[0].message);
            }
        }); 
        $A.enqueueAction(action1);
    },
    
    /*
     * @author: Nandeesh 
     * @Story #: DFOR-105
     * @purpose: To display the related pricing records for Digital release when clicked on Show All.
     * 
    */
    showAll : function(component, event) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:DGF_TitleHierarchyComponent",
            componentAttributes: {
                recordId : component.get("v.recordId"),
                showViewAll : "false"
            }
        });        
        evt.fire(); 
    },
    
    /*
     * @author: Nandeesh 
     * @Story #: DFOR-105
     * @purpose: To display the spinner when data loading.
     * 
    */
    showSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",true);
    },
    
	/*
     * @author: Nandeesh 
     * @Story #: DFOR-105
     * @purpose: To display the spinner after data loaded.
     * 
    */    
    hideSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",false);
    },
    
    /*
     * @author: Nandeesh 
     * @Story #: DFOR-105
     * @purpose: To freeze the columns in the Table.
     * 
    */
    scriptLoaded : function(component, event, helper) {
        component.set("v.isjQueryLoaded", true);        
        $("#fixTable3").tableHeadFixer({"left" : 1,"z-index" : 3});
    }
})