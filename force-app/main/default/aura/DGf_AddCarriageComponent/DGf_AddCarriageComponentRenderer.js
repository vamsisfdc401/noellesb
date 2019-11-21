({
    rerender : function (component, helper) {
        this.superRerender();        
        if(component.get("v.isjQueryLoaded")){
            setTimeout(function(){
                $("#tblAvailableRecords").tableHeadFixer({"left" : 2,"z-index" : 3});
            },50);  
        }
    }  
})