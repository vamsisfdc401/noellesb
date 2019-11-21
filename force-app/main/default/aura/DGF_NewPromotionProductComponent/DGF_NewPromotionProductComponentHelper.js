({
    searchProduct : function(component, event,btnID) {
        var action = component.get("c.fetchProducts");
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword"),
            'buttonID': btnID
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var storeResponse = response.getReturnValue();
                console.log("response.getReturnValue()====>",response.getReturnValue());
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
                
                // set numberOfRecord attribute value with length of return value from server
                component.set("v.numberOfRecord", storeResponse.length);
                // set searchResult list with return value from server.
                component.set("v.searchResult", storeResponse); 
                
            } 
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    addProducts : function(component, index) {
        //getting the complete result list
        var resultProduct = component.get("v.searchResult");
        
        //getting selected Promotion Product
        var selectedProduct = component.get("v.selectedResultList");
        var selectedProductsIds=[];
        
        //checking for a valid index
        if (index > -1){
            var isErrorOccured=false;
            for(var i = 0; i < selectedProduct.length; i++){ 
                if(selectedProduct[i].productID == resultProduct[index].productID){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":"error",
                        "message": "Error! Record already added."
                    });
                    toastEvent.fire(); 
                    isErrorOccured=true;
                }  
            }
            if(!isErrorOccured){
                component.set("v.isCodeError", false);
                //adding record to selected list
                if(selectedProduct.length == 0){
                    resultProduct[index].sortIndex = 0;
                    console.log('### Sort Index set to 0');
                }
                else{
                    resultProduct[index].sortIndex = selectedProduct.length;
                    console.log('### sort index set to: '+resultProduct[index].sortIndex);
                }
                selectedProduct.push(resultProduct[index]);
                //removing record from search list
                resultProduct.splice(index, 1); 
            }
        } 
        
        //setting the component list
        component.set("v.selectedResultList",selectedProduct);  
        component.set("v.searchResult",resultProduct); 
        
        component.set("v.numberOfRecord",resultProduct.length);  
        component.set("v.selectedRecordCount",selectedProduct.length); 
        
    },
    removeProducts : function(component, index) {
        //getting the complete result list
        var resultProduct = component.get("v.searchResult");
        
        //getting selected Promotion Product
        var selectedProduct = component.get("v.selectedResultList");
        
        //checking for a valid index
        if (index > -1) {
            //add record back to search list
            resultProduct.push(selectedProduct[index]);
            //removing record from selected list
            selectedProduct.splice(index, 1);
        }
        var idx;
        for(idx in selectedProduct){
            selectedProduct[idx].sortIndex = idx;
            console.log('### '+selectedProduct[idx].productName+' index set to: '+selectedProduct[idx].sortIndex);
        }
        //setting the component list
        component.set("v.selectedResultList",selectedProduct);  
        component.set("v.searchResult",resultProduct); 
        
        component.set("v.numberOfRecord",resultProduct.length);  
        component.set("v.selectedRecordCount",selectedProduct.length); 
    },
    selectAllProducts : function(component,event){
        //getting the complete result list
        var resultProducts = component.get("v.searchResult");
        
        //getting selected Promotion Product
        var selectedProducts = component.get("v.selectedResultList");
        var selectedProductsIds=[];
        var isDuplicateScenario = false;
        
        for(var j = 0; j < selectedProducts.length; j++){ 
            selectedProductsIds.push(selectedProducts[j].productID);
        }
        
        var addedProd=[] ;
        
        //adding all Products to select list        
        for(var i = 0; i < resultProducts.length; i++){ 
            if(!(selectedProductsIds.indexOf(resultProducts[i].productID)>-1) ){
                addedProd.push(resultProducts[i]);
            }else{
                isDuplicateScenario = true;
            }
        }        
    
        //adding record to selected list
        if(addedProd!=null){
            var idSet = [];
            for(var i = 0; i < addedProd.length; i++){
                if(!(idSet.indexOf(addedProd[i].productID)>-1) ){
                    addedProd[i].sortIndex = i;
                    selectedProducts.push(addedProd[i]);
                    idSet.push(addedProd[i].productID);
                }                
            }       
        }        
     
        var searchResultArr = [];
     
        //setting the component list
        component.set("v.selectedResultList",selectedProducts);  
        component.set("v.searchResult",searchResultArr); 

        component.set("v.numberOfRecord",searchResultArr.length);  
        component.set("v.selectedRecordCount",selectedProducts.length);
        
        if(isDuplicateScenario){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"info",
                "message": "Info! Records already added have been skipped."
            });
            toastEvent.fire();
        }
    },
    selectAllTPRforPromotion : function(component, event) {
        //getting selected Promotion Product
        var selectedProducts = component.get("v.selectedResultList");
        var chkBoxAll = component.find("chkSelectAll");
        var chkAllValue = chkBoxAll.get("v.value");
        
        //adding all titles to select list
        for(var i = 0; i < selectedProducts.length; i++){  
            //adding record to selected list            
            selectedProducts[i].isTPR = chkAllValue;
        }
        
        component.set("v.selectedResultList",selectedProducts);
    },
        removeAllProducts : function(component, event) {
            //getting the complete result list
            var resultProducts = component.get("v.searchResult");
            
            //getting selected Promotion Product
            var selectedProducts = component.get("v.selectedResultList");
            
            //adding all titles to select list
            for(var i = 0; i < selectedProducts.length; i++){  
                //adding record to selected list
                resultProducts.push(selectedProducts[i]);  
            }
            
            var selectResultArr = [];
            
            //setting the component list
            component.set("v.selectedResultList",selectResultArr);  
            component.set("v.searchResult",resultProducts); 
            
            component.set("v.numberOfRecord",resultProducts.length);  
            component.set("v.selectedRecordCount",selectResultArr.length); 
        },
        createRecords : function(component, event) {
            var idx = 0;
            var recs = component.get("v.selectedResultList");
            for(idx in recs){
                console.log('### rec at: '+idx+' is '+recs[idx].sortIndex+':'+recs[idx].productName);
            }
            var action = component.get("c.submitDetails");        
            action.setParams({
                'promotionID': component.get("v.PromotionId"),
                'strPromotionProduct': JSON.stringify(component.get("v.selectedResultList")),
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {  
                    var storeResponse = response.getReturnValue();
                    if (!storeResponse.includes("Only one Product can be selected when syncing Free First Episode dates.")) {
                        var urlEvent = $A.get("e.force:navigateToURL");
                        
                        urlEvent.setParams({
                            "url": "/" + storeResponse,
                            "isredirect": "TRUE"
                        });
                        urlEvent.fire();
                    }
                    else{
                        component.set("v.isCodeError", true);
                        component.set("v.CodeError", storeResponse);
                        console.log("Error Message", storeResponse);
                    }
                }  
                else if ( state === "ERROR"){
                    component.set("v.isCodeError", true);
                    component.set("v.CodeError", response.getError()[0].message);
                    console.log("Error Message", response.getError()[0].message);
                }
            });        
            $A.enqueueAction(action);
        },
})