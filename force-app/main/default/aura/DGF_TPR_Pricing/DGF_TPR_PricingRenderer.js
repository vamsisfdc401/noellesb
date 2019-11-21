({
    
    rerender : function(component, helper){
        this.superRerender();       
        if(component.get("v.isjQueryLoaded")){
            window.setTimeout(function(){
                $("#tblTPRPricing" + component.get("v.showViewAll")).tableHeadFixer({"left" : 2,"z-index" : 4});
            },1000);
        }   
    }
})