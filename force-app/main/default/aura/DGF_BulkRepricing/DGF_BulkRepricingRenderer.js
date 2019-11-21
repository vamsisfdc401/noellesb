({
    rerender : function (component, helper) {
        this.superRerender();        
        if(component.get("v.isjQueryLoaded")){
            setTimeout(function(){
                $("#tblAllSearched").tableHeadFixer({"left" : 2,"z-index" : 3});        
                $("#tblAllSelected").tableHeadFixer({"left" : 2,"z-index" : 3});
                $("#tblMassPriceUpdt").tableHeadFixer({"left" : 1,"z-index" : 3});
            },50);  
        }
    }
})