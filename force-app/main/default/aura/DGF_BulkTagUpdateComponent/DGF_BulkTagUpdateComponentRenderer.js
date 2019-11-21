({
    rerender : function (component, helper) {
        this.superRerender();        
        if(component.get("v.isjQueryLoaded")){
            window.setTimeout(function(){
                var objName = component.get("v.selectedObject");
                if(objName == 'Title'){
                    $("#tblSearchTitle").tableHeadFixer({"left" : 2,"z-index" : 3});
                    $("#tblSelectedTitle").tableHeadFixer({"left" : 2,"z-index" : 3});
                }
                else if(objName == 'Product'){
                    $("#tblSearchProduct").tableHeadFixer({"left" : 2,"z-index" : 3});
                    $("#tblSelectedProduct").tableHeadFixer({"left" : 2,"z-index" : 3});
                }
                    else if(objName == 'Promotion'){
                        $("#tblSearchPromotion").tableHeadFixer({"left" : 2,"z-index" : 3});
                        $("#tblSelectedPromotion").tableHeadFixer({"left" : 2,"z-index" : 3});
                    }                    
            },50);
        }   
    }    
})