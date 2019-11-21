({
       
    Search : function(component, event, helper) {
        var searchProdFld = component.find("searchProdId");
        var srcProdValue = searchProdFld.get("v.value");
        
        if ((srcProdValue == '' || srcProdValue == null)  ) {
            // display error message if input value is blank or null
            searchProdFld.set("v.errors", [{
                message: "Enter Search Keyword."
            }]);
        } else {
            searchProdFld.set("v.errors", null);
            // call helper method
            helper.searchProducts(component, event);
            
            if(component.get("v.isjQueryLoaded")){
                window.setTimeout(function(){
                    $("#tblAllSearched").tableHeadFixer({"left" : 2,"z-index" : 3});        
                    $("#tblAllSelected").tableHeadFixer({"left" : 2,"z-index" : 3});
                },1000);  
            }       
        }        
    },    
    showMore : function(component,event,helper){
        helper.showMoreRecords(component, event); 
    },
    onEnterClickSearch : function(component, event, helper) {        
        var searchKeyFld = component.find("searchProdId");
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
                helper.searchProducts(component, event);
                
                /*if(component.get("v.isjQueryLoaded")){
                    window.setTimeout(function(){
                        $("#tblAllSearched").tableHeadFixer({"left" : 20,"z-index" : 3});        
                        $("#tblAllSelected").tableHeadFixer({"left" : 2,"z-index" : 3});
                    },1000);  
                }  */     
            }        
        }
    },
    showSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",true);
    },    
    hideSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",false);
    },
    addProd: function(component, event, helper) {
        var index = event.target.dataset.index;
        
        //calling helper
        helper.addSelectedProduct(component, index,helper);
    },
    removeProd: function(component,event,helper){
        var index = event.target.dataset.index;
        helper.removeSelectedProduct(component,index,helper);
        component.set("v.Message",false);
    },
    selectAll: function(component,event,helper){
        helper.selectAllProducts(component,event,helper);
    },
    removeAll: function(component,event,helper){
        helper.removeAllProducts(component,event,helper);
        component.set("v.Message",false);
    },
    displayNextSection: function(component,event,helper){
        component.set("v.hideProdList",true);
        
        if(component.get("v.isjQueryLoaded")){
            window.setTimeout(function(){
                $("#tblMassPriceUpdt").tableHeadFixer({"left" : 1,"z-index" : 3});        
                $("#tblAllSelected").tableHeadFixer({"left" : 2,"z-index" : 3});
            },1000);  
        }   
        
    },
    displayPreviousSection: function(component,event,helper){
        component.set("v.hideProdList",false);
    },
    confirmSelection: function(component,event,helper){
        var dateFld = component.find("EffectiveDate");
        var priceEffDate=component.get("v.priceEffectiveDate");
        if ((priceEffDate == '' || priceEffDate == null)  ) {
            // display error message if input value is blank or null
            dateFld.set("v.errors", [{
                message: "Enter Price Effective Date."
            }]);
        } else {
            dateFld.set("v.errors", null);
            // call helper method
            helper.updateSelectedProducts(component,event);
        }
        
    },
    cancel : function(component,event,helper){
        
        helper.cancelPage(component,event);
    },
    scriptLoaded : function(component, event, helper) {
        component.set("v.isjQueryLoaded", true);          
    },
    /*
     * @author: Vaibhav B
     * @Story #: DFOR-1035
     * @purpose: sort of serach result by header column.
    */
    sort : function(component,event,helper) {        
        helper.sort(component,event,helper,component.get("v.searchResultMaster"),false,'');           
    },
    /*
     * @author: Vaibhav B
     * @Story #: DFOR-1035
     * @purpose: sort of selected result by header column.
    */
    selectedSort : function(component,event,helper) {
        helper.sort(component,event,helper,component.get("v.selectedResultList"),true,'selected');
    }    
})