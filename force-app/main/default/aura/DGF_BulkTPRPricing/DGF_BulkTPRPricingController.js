({
    doInit : function(component, event, helper) {
        var action = component.get("c.fetchProducts");
        action.setParams({
            'promoId': component.get("v.PromotionId")
            
        });
        
        var action1 = component.get("c.createTPRWrapperOnInit");       
        action1.setParams({
            'recordID' : component.get("v.PromotionId")
        });
       
               
        var action2=component.get("c.fetchRecordType");
        action2.setParams({
            'recordID' : component.get("v.PromotionId")
        });
        var action3 = component.get("c.getProdCount");
        action3.setParams({
            'recordID': component.get("v.PromotionId")
        });
        var action4 = component.get("c.getProfileDetails");
        action4.setParams({
            'recordID': component.get("v.PromotionId")
        });
        var action5 = component.get("c.fetchPromoTerritories");
        action5.setParams({
            'recordID': component.get("v.PromotionId")
        });
        
        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var storeResponse = response.getReturnValue();
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    /*
                    storeResponse.sort(function(a,b) {
                        if(a.hasTPRPrices < b.hasTPRPrices){
                            return -1;
                        }
                        if(a.hasTPRPrices > b.hasTPRPrices){
                            return 1;
                        }
                          if(a.productName < b.productName){
                            return -1;
                        }
                        if(a.productName > b.productName){
                            return 1;
                        }
                        return 0;} );*/
                    component.set("v.Message", false);
                    component.set("v.searchResultMaster", storeResponse);
                    component.set("v.totalNumberOfRecord", storeResponse.length);
                    
                    //declaring variables required for show more
                    var searchListLength = storeResponse.length;
                    var pageSize = component.get("v.pageSize");
                    var maxloop = 0;
                    var recordsToDisplay = [];
                    
                    //if master data set and page size is equals or less
                    if(searchListLength > 0 && searchListLength <= pageSize){
                        maxloop = searchListLength;
                    }
                    
                    //if master data set contains more records then only load records equal to page size
                    else if(searchListLength > 0 && searchListLength > pageSize){
                        maxloop = pageSize;
                    }
                    //if loop variable is not 0
                    if(maxloop > 0){
                        //add record to display to an array
                        for(var i=0; i< maxloop; i++){
                            recordsToDisplay.push(storeResponse[i]);
                        }
                        
                        //set array to list which will be loaded on UI
                        component.set("v.prodResultList", recordsToDisplay);
                        component.set("v.numberOfRecord", recordsToDisplay.length);
                    }
                }
                
            } 
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        });        
        
        
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var storeResponse = response.getReturnValue();
                // if storeResponse size is 0 ,display no record found message on screen.
                
                //var tprList=component.get("v.tprWrapperList");
                //tprList.push(storeResponse);
                // set searchResult list with return value from server.
                component.set("v.tprWrapperList", storeResponse); 
                component.set("v.tprCount",storeResponse.length);
            } 
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        });
        
        action3.setCallback(this, function(response){
            var storeResponse = response.getReturnValue();
            component.set("v.prodCount",storeResponse);
        });
        
        
        action2.setCallback(this, function(response) {
            var storeResponse = response.getReturnValue();
            component.set("v.recType",storeResponse);
        });
        action4.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                //component.set("v.allRecords",storeResponse);
                component.set("v.restrictedProfile", storeResponse); 
                if(storeResponse){
                    component.set("v.accessIssue", true);
                    component.set("v.accessError", 'Insufficient Privileges');
                }
                else{
                    component.set("v.accessIssue", false);
                }
                
            }    
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        });
        
        action5.setCallback(this, function(response){
            var storeResponse = response.getReturnValue(); 
			var terList = []; //DFOR-1504
            if( !$A.util.isEmpty(storeResponse) ){
            	component.set("v.territoryFilter",storeResponse); 
          	
            	if(storeResponse.includes("US")){
            		component.set("v.us",true);
					terList.push("US"); //DFOR-1504
		        }else{
		            component.set("v.us",false);
		        }
		        
		        if(storeResponse.includes("CA")){
		            component.set("v.ca",true);
					terList.push("CA"); //DFOR-1504
		        }else{
		            component.set("v.ca",false);
		        }
				component.set("v.territoryList",terList); //DFOR-1504
            }else{
				//DFOR-1504 --- start
				if(terList.length==0){
		        	terList.push("N/A");
		        }
				//DFOR-1504 --- end
				component.set("v.territoryList",terList); //DFOR-1504
            	component.set("v.us",false);
            	component.set("v.ca",false);
            	
            }		
        });
        $A.enqueueAction(action4);        
      
        $A.enqueueAction(action);
        $A.enqueueAction(action1);
        $A.enqueueAction(action2);
        $A.enqueueAction(action3);
        $A.enqueueAction(action5);
        
        
        
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
    },
    selectAll: function(component,event,helper){
        helper.selectAllProducts(component,event,helper);
    },
    removeAll: function(component,event,helper){
        helper.removeAllProducts(component,event,helper);
    },
    addPrice : function(component,event,helper){
        var action1 = component.get("c.createTPRWrapper");
        action1.setParams({
            'tprWrp' : JSON.stringify(component.get("v.tprWrapperList")),
            'recordID' : component.get("v.PromotionId") 
        })
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var storeResponse = response.getReturnValue();
                // if storeResponse size is 0 ,display no record found message on screen.
                
                var tprList=component.get("v.tprWrapperList");
                tprList.push(storeResponse);
                // set searchResult list with return value from server.
                component.set("v.tprWrapperList", tprList); 
                component.set("v.tprCount",tprList.length);
            } 
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        });
        $A.enqueueAction(action1);
    },
    saveTPR : function (component,event,helper){
        console.log(component.get("v.tprWrapperList"));
        // added by piyush
        component.set("v.isdisabled",true);
        // added by piyush
        var action = component.get("c.saveTPRPricing");
		var terr = []; //DFOR-1504
		terr=component.get("v.territoryList"); //DFOR-1504
		var terr1 = terr.length > 1 ? 'US;CA' : ''; //DFOR-1504
        action.setParams({
            'prodJson':  JSON.stringify(component.get("v.selectedRecList")),
            'tprJson':  JSON.stringify(component.get("v.tprWrapperList")),
            'recordTypeName' : component.get("v.recType"),
            'defaultingFlag' : component.get("v.dontDefaultTPR"),
			'promoTerr' : terr1
            
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var storeResponse = response.getReturnValue();
                if(!storeResponse.includes('The TPR Price entered is greater than the everyday Price')){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    
                    urlEvent.setParams({
                        "url": "/" + storeResponse,
                        "isredirect": "TRUE"
                    });
                    urlEvent.fire();
                }
                else{
                    component.set("v.isCodeError", true);
                    component.set("v.CodeError",storeResponse);
                }
            } 
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    cancel: function (component,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        var prId=component.get("v.PromotionId")  ;        
        urlEvent.setParams({
            "url": "/" + prId,
            "isredirect": "TRUE"
        });
        urlEvent.fire();
    },
    removePrice:function (component,event,helper){
        var tprWrp=component.get("v.tprWrapperList");
        tprWrp.pop();
        component.set("v.tprWrapperList",tprWrp);
        component.set("v.tprCount",tprWrp.length);
    },
    
    saveAndContinue : function (component,event,helper){
        console.log(component.get("v.tprWrapperList"));
        var action = component.get("c.saveAndContinueTPR");
		var terr = []; //DFOR-1504
		terr=component.get("v.territoryList"); //DFOR-1504
		var terr1 = terr.length > 1 ? 'US;CA' : ''; //DFOR-1504
        action.setParams({
            'prodJson':  JSON.stringify(component.get("v.selectedRecList")),
            'tprJson':  JSON.stringify(component.get("v.tprWrapperList")),
            'recordTypeName' : component.get("v.recType"),
            'defaultingFlag' : component.get("v.dontDefaultTPR"),
			'promoTerr' : terr1
            
        });
        
        /*action1.setParams({
            'tprWrp' : JSON.stringify(component.get("v.tprWrapperList"))
        })*/
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var storeResponse = response.getReturnValue();
            if (state === "SUCCESS") {  
                if(storeResponse.length == 1 && storeResponse[0].msg!=null &&  storeResponse[0].msg.includes ('The TPR Price entered is greater than the everyday Price') && storeResponse[0].promoId ==null){
                    component.set("v.isCodeError", true);
                    component.set("v.CodeError",storeResponse[0].msg);
                }
                else{/*
                     storeResponse.sort(function(a,b) {
                        if(a.hasTPRPrices < b.hasTPRPrices){
                            return -1;
                        }
                        if(a.hasTPRPrices > b.hasTPRPrices){
                            return 1;
                        }
                          if(a.productName < b.productName){
                            return -1;
                        }
                        if(a.productName > b.productName){
                            return 1;
                        }
                         
                        return 0;} );*/
                     component.set("v.isCodeError", false);
                    component.set("v.searchResultMaster", storeResponse);
                    component.set("v.totalNumberOfRecord", storeResponse.length);
                    var prodResultList=[];
                    for(var i = 0; i < component.get("v.pageSize") && i < storeResponse.length ; i++) {
                        prodResultList.push(storeResponse[i]);
                    }
                    component.set("v.prodResultList",prodResultList);
                    component.set("v.numberOfRecord",prodResultList.length);
                    var selectedList=component.get("v.selectedRecList");
                    var selectedList=[];
                    component.set("v.selectedRecList",selectedList);
                    component.set("v.selectedRecordCount",selectedList.length);
                    component.set("v.success",true);
                    component.set("v.successMsg",'TPR Prices saved successfully');
                    var tprList=component.get("v.tprWrapperList");
                    tprList=[];
                    component.set("v.tprWrapperList",tprList);
                    var action1 = component.get("c.createTPRWrapperOnInit");
                     action1.setParams({
                    	 	'recordID' : component.get("v.PromotionId")
                     });
                    action1.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {  
                            var storeResponse = response.getReturnValue();
                            // if storeResponse size is 0 ,display no record found message on screen.
                            
                            //var tprList=component.get("v.tprWrapperList");
                            //tprList.push(storeResponse);
                            // set searchResult list with return value from server.
                            component.set("v.tprWrapperList", storeResponse); 
                            component.set("v.tprCount",storeResponse.length);
                        } 
                        else if (state === "ERROR"){
                            component.set("v.isCodeError", true);
                            //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                            component.set("v.CodeError", response.getError()[0].message);
                            console.log("Error Message", response.getError()[0].message);
                        }
                    });
                    $A.enqueueAction(action1);
                }
                
            } 
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        });
        
        
        $A.enqueueAction(action);
        
    },
    scriptLoaded : function(component, event, helper) {
        component.set("v.isjQueryLoaded", true);
        // console.log('event outside fired'); 
        
        if(component.get("v.isjQueryLoaded")){
            window.setTimeout(function(){
                //alert('entry search');
                //   console.log('entry search');
                $("#tblAvailableTPR").tableHeadFixer({"left" : 2,"z-index" : 3});        
                $("#tblSelectedTPR").tableHeadFixer({"left" : 2,"z-index" : 3});
            },1000);  
        }   
    } ,
    showMore : function (component, event, helper) {   
        console.log('1');
        helper.showMoreRecords(component,event);
        //helper.sortBy(component, "usESTHDWSP");
        //alert(component.get("v.prodResultList").length);
    },
    
    onCheck  : function (component, event, helper){
        var src=event.getSource();
        var checkCmp = component.find(src.getLocalId());
        component.set("v.dontDefaultTPR",checkCmp.get("v.value"));
        
        console.log( component.get("v.dontDefaultTPR"));
    },
    /*
     * @author: Vaibhav B
     * @Story #: DFOR-1035
     * @purpose: sort of search result by header column.
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
        helper.sort(component,event,helper,component.get("v.selectedRecList"),true,'selected');
    }  
})