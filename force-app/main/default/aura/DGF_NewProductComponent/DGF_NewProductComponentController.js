({
    doInit : function(component, event, helper) { 
        var action = component.get("c.getProductUser");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                component.set("v.isNotProductUser", storeResponse);
                
                if(component.get("v.isjQueryLoaded")){
                    window.setTimeout(function(){
                        $("#fixTable1").tableHeadFixer({"left" : 2,"z-index" : 3});
                        $("#fixTable2").tableHeadFixer({"left" : 2,"z-index" : 3});
                    },100);
                } 
                
                var action1 = component.get("c.getTitleName");
                action1.setParams({
                    'releaseID': component.get("v.releaseRecordId") 
                });
                action1.setCallback(this, function(response) {
                    var stateval = response.getState();
                    if (stateval === "SUCCESS") {
                        var storeRes = response.getReturnValue();                        
                        if(storeRes != null){
                            component.set("v.searchKeyword",storeRes) ;
                            helper.searchTitle(component, event); 
                            
                            if(component.get("v.isjQueryLoaded")){
                                window.setTimeout(function(){
                                    $("#fixTable1").tableHeadFixer({"left" : 2,"z-index" : 3});
                                    $("#fixTable2").tableHeadFixer({"left" : 2,"z-index" : 3});
                                },100);
                            } 
                        }                        
                    }
                });
                $A.enqueueAction(action1);
            }
        }); 
        $A.enqueueAction(action);
    },
    Search : function(component, event, helper) {
        var searchKeyFld = component.find("searchId");
        var srcValue = searchKeyFld.get("v.value");
        if (srcValue == '' || srcValue == null) {
            // display error message if input value is blank or null
            searchKeyFld.set("v.errors", [{
                message: "Enter Search Keyword."
            }]);
        } else {
            searchKeyFld.set("v.errors", null);
            // call helper method
            helper.searchTitle(component, event); 
            
            if(component.get("v.isjQueryLoaded")){
                window.setTimeout(function(){
                    $("#fixTable1").tableHeadFixer({"left" : 2,"z-index" : 3});
                    $("#fixTable2").tableHeadFixer({"left" : 2,"z-index" : 3});
                },100);
            }   
            //$("#fixTable").tableHeadFixer({"head" : true, "left" : 1}); 
            
        }
    },
    addSelectedTitleVersion : function(component, event, helper) {
        //getting the index of record to be added
        var index = event.target.dataset.index;
        
        //calling helper
        helper.addTitleVersion(component, index);
    },
    removeSelectedTitleVersion : function(component, event, helper) {
        //getting the index of record to be added
        var index = event.target.dataset.index;
        
        //calling helper
        helper.removeTitleVersion(component, index);
        component.set("v.Message",false);
    },
    showSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",true);
    },    
    hideSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",false);
    },
    onEnterClickSearch : function(component, event, helper) {        
        var searchKeyFld = component.find("searchId");
        var srcValue = searchKeyFld.get("v.value");
        
        if(event.getParams().keyCode == 13){
            if (srcValue == '' || srcValue == null) {
                // display error message if input value is blank or null
                searchKeyFld.set("v.errors", [{
                    message: "Enter Search Keyword."
                }]);
            } else {
                searchKeyFld.set("v.errors", null);
                // call helper method
                helper.searchTitle(component, event);
                if(component.get("v.isjQueryLoaded")){
                    window.setTimeout(function(){
                        $("#fixTable1").tableHeadFixer({"left" : 2,"z-index" : 3});
                        $("#fixTable2").tableHeadFixer({"left" : 2,"z-index" : 3});
                    },100);
                }   
            }        
        }
    },
    gotoURL : function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var releaseID = component.get("v.releaseRecordId");
        
        urlEvent.setParams({
            "url": "/" + releaseID,
            "isredirect": "TRUE"
        });
        urlEvent.fire();
    },
    saveRecordDetails : function(component, event, helper) {
        //getting selected title versions
        var selectedTitleVersions = component.get("v.selectedResultList");
        
        //for film release version is mandatory if original flag is not set on version 
        if(component.get("v.renderVersion") == true && component.get("v.selectVersionVal") == 'None'){
            component.set("v.isCodeError", true);
            
        }
        else{
            //helper method to create records
            if(selectedTitleVersions.length > 0){
                helper.createRecords(component, event);
            }
        }        
    },
    onESTSelectChange : function(component, event, helper) {
        //getting selected value
        var selectedVal = component.find("selectESTTier").get("v.value");
        
        //setting selected EST Tier Value
        component.set("v.selectESTTierVal",selectedVal);
    },
    onVersionSelectChange : function(component, event, helper) {
        //getting selected value
        var selectedVal = component.find("selectVersion").get("v.value");
        //setting selected EST Tier Value
        component.set("v.selectVersionVal",selectedVal);
    },
    selectAll : function(component, event, helper) {               
        //calling helper
        helper.selectAllTitlVersions(component, event);
        //$("#fixTable2").tableHeadFixer({"left" : 1});
    },
    removeAll : function(component, event, helper) {               
        //calling helper
        helper.removeAllTitlVersions(component, event);
        component.set("v.Message",false);
    },
    onLeadTitleClick : function(component, event, helper) {
        //getting the index of record to be added
        //var index = event.target.dataset.index;       
        
        //calling helper
        helper.setLeadTitle(component, event);
    },
    scriptLoaded : function(component, event, helper) {
        component.set("v.isjQueryLoaded", true);
        console.log('event outside fired');           
    },
    showMore : function(component, event, helper) {      
        helper.showMoreRecords(component, event); 
    },
    noVersionSelected : function(component,event,helper){
        component.set("v.noVersionClicked",true);
        
    },
    closeModal : function (component,event,helper){
        component.set("v.noVersionClicked",false);
    },
    createProd : function (component,event,helper){
        helper.createNoVersionProduct(component,event);
    }
})