({
    doInit : function(component, event, helper) {
        console.log('Inside the doInit #1');
        var action = component.get("c.getUser");
        var action1 = component.get("c.getPromotionProduct");
         action.setParams({
            'recordID': component.get("v.PromotionId")
        });
         action1.setParams({
            'recordID': component.get("v.PromotionId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                component.set("v.isNotProductorAccountUser", storeResponse); 
            }            
        }); 
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                component.set("v.selectedResultList", storeResponse);
                component.set("v.hasInitialProdProm", true);
                component.set("v.selectedRecordCount",storeResponse.length);
            }            
        });
        $A.enqueueAction(action);
        $A.enqueueAction(action1);
    },
    Search : function(component, event, helper) {
        var btnID = event.target.id;
        var searchKeyFld = component.find("searchId");
        var srcValue = searchKeyFld.get("v.value");
        if (btnID == 'btnSearch' && (srcValue == '' || srcValue == null)) {
            // display error message if input value is blank or null
            searchKeyFld.set("v.errors", [{
                message: "Enter Search Keyword."
            }]);
        } else {
            searchKeyFld.set("v.errors", null);
            // call helper method
            helper.searchProduct(component, event,btnID);
            
            /*if(component.get("v.isjQueryLoaded")){
                window.setTimeout(function(){
                    $("#tblAvailableRecords").tableHeadFixer({"left" : 1,"z-index" : 3});
                    $("#tblSelectedRecords").tableHeadFixer({"left" : 1,"z-index" : 3});
                },100);
            } */  
        }
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
                helper.searchProduct(component, event);
                
                /*if(component.get("v.isjQueryLoaded")){
                    window.setTimeout(function(){
                        $("#tblAvailableRecords").tableHeadFixer({"left" : 1,"z-index" : 3});
                        $("#tblSelectedRecords").tableHeadFixer({"left" : 1,"z-index" : 3});
                    },100);
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
    addSelectedProduct : function(component, event, helper) {
        //getting the index of record to be added
        var index = event.target.dataset.index;
        
        //calling helper
        helper.addProducts(component, index);
        
        /*if(component.get("v.isjQueryLoaded")){
            window.setTimeout(function(){
                $("#tblAvailableRecords").tableHeadFixer({"left" : 1,"z-index" : 3});
                $("#tblSelectedRecords").tableHeadFixer({"left" : 1,"z-index" : 3});
            },100);
        }   */
    },
    removeSelectedProduct : function(component, event, helper) {
        //getting the index of record to be added
        var index = event.target.dataset.index;
        
        //calling helper
        helper.removeProducts(component, index);
        component.set("v.Message",false);
        /*if(component.get("v.isjQueryLoaded")){
            window.setTimeout(function(){
                $("#tblAvailableRecords").tableHeadFixer({"left" : 1,"z-index" : 3});
                $("#tblSelectedRecords").tableHeadFixer({"left" : 1,"z-index" : 3});
            },100);
        }  */ 
    },
    selectAll : function(component, event, helper) {               
        //calling helper
        helper.selectAllProducts(component, event);
        
        /*if(component.get("v.isjQueryLoaded")){
            window.setTimeout(function(){
                $("#tblAvailableRecords").tableHeadFixer({"left" : 1,"z-index" : 3});
                $("#tblSelectedRecords").tableHeadFixer({"left" : 1,"z-index" : 3});
            },100);
        }  */ 
    },
    selectAllTPR : function(component, event, helper) {               
        //calling helper
        helper.selectAllTPRforPromotion(component, event);
    },
    removeAll : function(component, event, helper) {               
        //calling helper
        helper.removeAllProducts(component, event);
        component.set("v.Message",false);
        /*if(component.get("v.isjQueryLoaded")){
            window.setTimeout(function(){
                $("#tblAvailableRecords").tableHeadFixer({"left" : 1,"z-index" : 3});
                $("#tblSelectedRecords").tableHeadFixer({"left" : 1,"z-index" : 3});
            },100);
        }   */
    },
    gotoURL : function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var promID = component.get("v.PromotionId");
        
        urlEvent.setParams({
            "url": "/" + promID,
            "isredirect": "TRUE"
        });
        urlEvent.fire();
    },
    saveRecordDetails : function(component, event, helper) {
        //getting selected Promotion Product
        component.set("v.showSpinner",true);
        var selectedPromotions = component.get("v.selectedResultList");
        
        //helper method to create records
        helper.createRecords(component, event);
        component.set("v.showSpinner",false);
    },
    scriptLoaded : function(component, event, helper) {
        component.set("v.isjQueryLoaded", true);
        console.log('event outside fired'); 
        
        $("#tblAvailableRecords").tableHeadFixer({"z-index" : 3});
        $("#tblSelectedRecords").tableHeadFixer({"z-index" : 3});
    },
	
	onCheck : function(component, event, helper){
		console.log('checkbox');
	},
      handleChange: function (cmp, event) {
        
        var selectedOptionValue = event.getParam("value");
    },
    handleDrag : function(component,event,helper){
        component.set("v.draggedDivID",event.target.id);
    },
    allowDrop : function(component,event,helper){
        event.preventDefault();
    },
    handleDrop : function(component,event,helper){debugger;
        var srcId = component.get("v.draggedDivID");
        var srcIdx = parseInt(srcId);
        console.log('### srcIdx: '+srcIdx);
        console.log('### targetIdx: '+event.target.id);
        
        var table1Data = component.get("v.selectedResultList");
        var table2Data = new Array();
        var rowThatWasDragged = table1Data[srcIdx];
        //console.log('### rowThatWasDragged: '+rowThatWasDragged.productName);
        //console.log('table1Data>>'+ table1Data.length);
        var idx;
        var recX={}; 
                                                  
        if(parseInt(event.target.id)>table1Data.length){
          event.target.id =   table1Data.length - 1;
            //console.log('MODIFY??' + event.target.id);
        }                                         
      
                                                  
        //moving down
        if(srcIdx < event.target.id){
            console.log('### moving down');
            for(idx in table1Data){
                //console.log('### Tabe2' + table2Data);
                //alert('idx '+idx);alert('srcIdx '+srcIdx);
                //alert('idx > srcIdx '+idx > srcIdx);alert('idx <= event.target.id '+idx <= event.target.id);
                if((parseInt(idx) > parseInt(srcIdx)) && (parseInt(idx) <= parseInt(event.target.id))){
                    //console.log('if  block ??parseInt(idx)' + parseInt(idx) + 'parseInt(srcIdx)' + parseInt(srcIdx) + 'parseInt(event.target.id)' + parseInt(event.target.id));
                    recX = table1Data[idx];
                    recX.sortIndex = (parseInt(idx) - parseInt(1));//alert('parse '+recX.sortIndex);
                    table2Data[recX.sortIndex] = recX;
                }
                else if(parseInt(idx) == parseInt(srcIdx)){
                    //console.log('else block>>parseInt(idx)' + parseInt(idx) + 'parseInt(srcIdx)' + parseInt(srcIdx) );
                    recX = table1Data[idx];
                    recX.sortIndex =parseInt(event.target.id);
                    table2Data[recX.sortIndex] = recX;
                }
                else{
                    //console.log('Finalelse block>>parseInt(idx)' + parseInt(idx) + 'parseInt(srcIdx)' + parseInt(srcIdx) );
                	table2Data.push(table1Data[idx]);
                }
            }
        }
        //moving up
        else if(srcIdx > event.target.id){
            console.log('### moving up');
            for(idx in table1Data){
                if(parseInt(idx) == parseInt(srcIdx)){
                    recX = table1Data[idx];
                    recX.sortIndex = parseInt(event.target.id);
                    table2Data[recX.sortIndex] = recX;
                    //console.log('### #1 moved source to target: '+recX.productName);
                }
                else if(parseInt(idx) >= parseInt(event.target.id) && parseInt(idx) < parseInt(srcIdx)){
                    recX = table1Data[idx];
                    recX.sortIndex = parseInt(recX.sortIndex) + 1;
                    table2Data[recX.sortIndex] = recX;
                   // console.log('### #2 adding element at idx : '+recX.sortIndex+' - '+recX.productName);
                }
                else{
                	table2Data.push(table1Data[idx]); 
                    //console.log('### #3 adding element at idx : '+idx+' - '+table1Data[idx].productName);
                }
            }
    	}
        else{
            console.log('### source and target index are same'); 
            for(idx in table1Data){
                recX = table1Data[idx];
                recX.sortIndex = idx;
                table2Data[recX.sortIndex] = recX;
            }
        }
        for(idx in table2Data){
            //console.log('### at: '+table2Data[idx].sortIndex+' '+table2Data[idx].productName);
        }
        component.set("v.selectedResultList",table2Data);
    }
})