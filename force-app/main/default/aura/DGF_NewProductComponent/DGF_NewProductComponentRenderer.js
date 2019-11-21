({
    rerender : function (component, helper) {
        this.superRerender();        
        if(component.get("v.isjQueryLoaded")){
            setTimeout(function(){
                $("#fixTable1").tableHeadFixer({"left" : 2,"z-index" : 3});
                $("#fixTable2").tableHeadFixer({"left" : 2,"z-index" : 3});               
            },50);  
        }
    }
})