({
    rerender : function (component, helper) {
        this.superRerender();        
        if(component.get("v.isjQueryLoaded")){
            setTimeout(function(){
                $("#tblAvailableTPR").tableHeadFixer({"left" : 2,"z-index" : 3});        
                $("#tblSelectedTPR").tableHeadFixer({"left" : 2,"z-index" : 3});
            },50);  
        }
    }
})