({
    update : function(component,event,helper) { 
        location.reload(true);
    },
    doInit : function(component, event, helper) {
        
        var action1 = component.get("c.fetchRelatedRecords");
        action1.setParams({
            'recordID': component.get("v.recordId"),
            'accountId': ''
        });
        var action2=component.get("c.fetchRecordType");
        action2.setParams({
            'recordID' :component.get("v.recordId")
        });
        var action3 = component.get("c.getProdCount");
        action3.setParams({
            'recordID': component.get("v.recordId")
        });
        
        var action4 = component.get("c.getProfileDetails");
        action4.setParams({
            'recordID': component.get("v.recordId")
        });

		var action5 = component.get("c.fetchPromoTerritories");
        action5.setParams({
            'recordID': component.get("v.recordId")
        });
        var action6 = component.get("c.getAccountPromotions");
        action6.setParams({
            'promotionId': component.get("v.recordId")
        });
		
        action1.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                //component.set("v.allRecords",storeResponse);
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
                        console.log('recordsToDisplay====='+JSON.stringify(recordsToDisplay));
                        component.set("v.recordsToDisplay", recordsToDisplay);
                        component.set("v.numberOfRecords", recordsToDisplay.length);
                }
                
                if(component.get("v.isjQueryLoaded")){
                    window.setTimeout(function(){
                        $("#tblTPRPricing" + component.get("v.showViewAll")).tableHeadFixer({"left" : 2,"z-index" : 4});
                    },3000);
                }  
                
                
                component.set("v.isCodeError", false);
            }    
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        });
        action2.setCallback(this, function(response) {
            var storeResponse = response.getReturnValue();
            component.set("v.recType",storeResponse);
        });
        action3.setCallback(this, function(response){
            var storeResponse = response.getReturnValue();
            component.set("v.prodCount",storeResponse);
        });
        action4.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                //component.set("v.allRecords",storeResponse);
                component.set("v.restrictedProfile", storeResponse); 
                component.set("v.isCodeError", false);
                
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
            var terList = [];
            if( !$A.util.isEmpty(storeResponse) ){
            	if(storeResponse.includes("US")){
            		component.set("v.us",true);
            		terList.push("US");
		        }else{
		            component.set("v.us",false);
		        }
		        
		        if(storeResponse.includes("CA")){
		            component.set("v.ca",true);
		            terList.push("CA");
		        }else{
		            component.set("v.ca",false);
		        }
		        
		        component.set("v.territoryList",terList);
		        component.set("v.territoryFilter",storeResponse); 
            }else{            	
            	if(terList.length==0){
		        	terList.push("N/A");
		        }
		        component.set("v.territoryList",terList);
		        component.set("v.us",false);
            	component.set("v.ca",false);            	
            }           
            		
        });
        // DFOR-1445
         action6.setCallback(this, function(response) {
            var storeResponse = response.getReturnValue();
                var state = response.getState();
                if (state === "SUCCESS") {
                if(storeResponse!=''){
                    if(storeResponse.length==1){
                     
                     component.set("v.actName",storeResponse[0].Account__r.Name);   
                    }
                    else{
                      component.set("v.accountValues",storeResponse);  
                    }
            //component.find("actId").set("v.value",JSON.stringify(storeResponse[0].Account__r.Name));
                }
                }
               else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
                //helper.setDefaultValue(component,event,JSON.stringify(storeResponse[0].Account__r.Name));
        });


        $A.enqueueAction(action4);
        $A.enqueueAction(action5);
        $A.enqueueAction(action1);
        $A.enqueueAction(action2);
        $A.enqueueAction(action3);
        $A.enqueueAction(action6);
    },
    
    
    onFilterChange : function(component,event,helper){
        
        var territory=component.get("v.territoryFilter");
        var platform=component.get("v.platformFilter");
        var res=component.get("v.resFilter");
        var wspVssrp=component.get("v.WSPorSRPFilter");
        var acc=component.get("v.accountFilter");
        var stdOrTPR = component.get("v.StandardorTPRFilter");
        
        if(stdOrTPR.includes("Standard")){
            component.set("v.Standard",true);
            console.log('Standard is true');
        }
        else{
            component.set("v.Standard",false);
        }
        if(stdOrTPR.includes("TPR")){
            component.set("v.TPR",true);
            console.log('TPR is true');
        }
        else{
            component.set("v.TPR",false);
        }
        if(territory.includes("US")){
            component.set("v.us",true);
        }
        else{
            component.set("v.us",false);
        }
        if(territory.includes("CA")){
            component.set("v.ca",true);
            console.log('CA is true');
        }
        else{
            component.set("v.ca",false);
        }
        if(platform.includes("EST")){
            component.set("v.est",true);
            console.log('est is true');
        }
        else{
            component.set("v.est",false);
        } 
        if(platform.includes("VOD")){
            component.set("v.vod",true);
        }
        else{
            component.set("v.vod",false);
        } 
        if(res.includes("SD")){
            component.set("v.sd",true);
        }
        else{
            component.set("v.sd",false);
        }
        if(res.includes("HD")){
            component.set("v.hd",true);
            console.log('hd is true');
        }
        else{
            component.set("v.hd",false);
        }
        if(res.includes("ultra")){
            component.set("v.uhd",true);
        }
        else{
            component.set("v.uhd",false);
        }
        if(res.includes("3D")){
            component.set("v.xd",true);
        }
        else{
            component.set("v.xd",false);
        }
        if(wspVssrp.includes("WSP")){
            component.set("v.wsp",true);
        }
        else{
            component.set("v.wsp",false);
        }
        if(wspVssrp.includes("SRP")){
            component.set("v.srp",true);
        }
        else{
            component.set("v.srp",false);
        }
        if(acc.includes("National")){
            component.set("v.national",true);
        }
        else{
            component.set("v.national",false);
        }
        if(acc.includes("iTunes")){
            component.set("v.iTunes",true);
            console.log('itunes is true');
        }
        else{
            component.set("v.iTunes",false);
        }        
    },
    
    saveDates:function(component,event,helper){
        var index=event.getSource().get("v.label");
        
        var wrapperList = component.get("v.recordsToDisplay");
        wrapperList[index].dateChanged=true;
        component.set("v.recordsToDisplay",wrapperList);
        console.log('in save dates');
    },
    
    saveTPRPricing : function(component,event,helper){
        
        var index = event.target.dataset.index;
        if(isNaN(event.target.value)){
            component.set("v.isCodeError", true);
            //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
            component.set("v.CodeError","Please enter a valid number");
        }
        else{
            if(component.get("v.isCodeError")){
                component.set("v.isCodeError", false);
            }
            var wrapperList = component.get("v.recordsToDisplay");
            //console.log(wrapperList);
            var recordUpdated=wrapperList[index];
            var valueChanged=event.target.value;
            var changedField=event.target.name;
            var formattedValue ; 
             component.set("v.tprGreater",false);
            //US EST SD
            if(changedField=='US-EST-SD-WSP-TPR' ){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usESTSDWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-EST-SD-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-EST-SD-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-EST-SD-WSP-TPR');
                }
                
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usESTSDWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            
            else if(changedField=='US-EST-SD-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usESTSDSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                wrapperList[index].usESTSDSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].usESTSDTPRiTunesID==null || wrapperList[index].usESTSDTPRiTunesID==''){
                    wrapperList[index].usESTSDTPRiTunesID='edited';
                }
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-EST-SD-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-EST-SD-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-EST-SD-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usESTSDSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
                else if(changedField=='US-SD-SRP-TPR_iTunes'){
                    document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                    wrapperList[index].usESTSDSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                    
                    if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                        wrapperList[index].edited='US-SD-SRP-TPR_iTunes';
                    }
                    else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-SD-SRP-TPR_iTunes')){
                        var str=wrapperList[index].edited;
                        wrapperList[index].edited=str.concat(';US-SD-SRP-TPR_iTunes');
                    }
                    component.set("v.recordsToDisplay",wrapperList);
                    formattedValue=wrapperList[index].usESTSDSRP_iTunes.replace('$','');
                    
                    if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                        component.set("v.tprGreater",true);
                        document.getElementById(event.target.id).style.borderColor = "red"
                    }
                }
            
            //US EST HD
            if(changedField=='US-EST-HD-WSP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usESTHDWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-EST-HD-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-EST-HD-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-EST-HD-WSP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usESTHDWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            else if(changedField=='US-EST-HD-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usESTHDSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                wrapperList[index].usESTHDSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].usESTHDTPRiTunesID==null || wrapperList[index].usESTHDTPRiTunesID==''){
                    wrapperList[index].usESTHDTPRiTunesID='edited';
                }
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-EST-HD-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-EST-HD-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-EST-HD-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usESTHDSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
                else if(changedField=='US-HD-SRP-TPR_iTunes'){
                    document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                    wrapperList[index].usESTHDSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                    
                    if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                        wrapperList[index].edited='US-HD-SRP-TPR_iTunes';
                    }
                    else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-HD-SRP-TPR_iTunes')){
                        var str=wrapperList[index].edited;
                        wrapperList[index].edited=str.concat(';US-HD-SRP-TPR_iTunes');
                    }
                    component.set("v.recordsToDisplay",wrapperList);
                    formattedValue=wrapperList[index].usESTHDSRP_iTunes.replace('$','');
                    
                    if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                        component.set("v.tprGreater",true);
                        document.getElementById(event.target.id).style.borderColor = "red"
                    }
                }
            //US EST UHD
            if(changedField=='US-EST-UHD-WSP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usESTUHDWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-EST-UHD-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-EST-UHD-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-EST-UHD-WSP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usESTUHDWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            else if(changedField=='US-EST-UHD-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usESTUHDSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                wrapperList[index].usESTUHDSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].usESTUHDTPRiTunesID==null || wrapperList[index].usESTUHDTPRiTunesID==''){
                    wrapperList[index].usESTUHDTPRiTunesID='edited';
                }
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-EST-UHD-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-EST-UHD-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-EST-UHD-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usESTUHDSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
                else if(changedField=='US-UHD-SRP-TPR_iTunes'){
                    document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                    wrapperList[index].usESTUHDSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                    
                    if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                        wrapperList[index].edited='US-UHD-SRP-TPR_iTunes';
                    }
                    else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-UHD-SRP-TPR_iTunes')){
                        var str=wrapperList[index].edited;
                        wrapperList[index].edited=str.concat(';US-UHD-SRP-TPR_iTunes');
                    }
                    component.set("v.recordsToDisplay",wrapperList);
                    formattedValue=wrapperList[index].usESTUHDSRP_iTunes.replace('$','');
                    
                    if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                        component.set("v.tprGreater",true);
                        document.getElementById(event.target.id).style.borderColor = "red"
                    }
                }
            
            //US EST 3D
            if(changedField=='US-EST-3D-WSP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usEST3DWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-EST-3D-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-EST-3D-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-EST-3D-WSP-TPR');
                }
                
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usEST3DWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            else if(changedField=='US-EST-3D-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usEST3DSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                wrapperList[index].usEST3DSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].usEST3DTPRiTunesID==null || wrapperList[index].usEST3DTPRiTunesID==''){
                    wrapperList[index].usEST3DTPRiTunesID='edited';
                }
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-EST-3D-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-EST-3D-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-EST-3D-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usEST3DSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
                else if(changedField=='US-3D-SRP-TPR_iTunes'){
                    document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                    wrapperList[index].usESTHDSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                    
                    if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                        wrapperList[index].edited='US-3D-SRP-TPR_iTunes';
                    }
                    else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-3D-SRP-TPR_iTunes')){
                        var str=wrapperList[index].edited;
                        wrapperList[index].edited=str.concat(';US-3D-SRP-TPR_iTunes');
                    }
                    component.set("v.recordsToDisplay",wrapperList);
                    formattedValue=wrapperList[index].usEST3DSRP_iTunes.replace('$','');
                    
                    if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                        component.set("v.tprGreater",true);
                        document.getElementById(event.target.id).style.borderColor = "red"
                    }
                }
            
            
            //CA EST SD
            if(changedField=='CA-EST-SD-WSP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caESTSDWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-EST-SD-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-EST-SD-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-EST-SD-WSP-TPR');
                }
                
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caESTSDWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            else if(changedField=='CA-EST-SD-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caESTSDSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                wrapperList[index].caESTSDSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].caESTSDTPRiTunesID==null || wrapperList[index].caESTSDTPRiTunesID==''){
                    wrapperList[index].caESTSDTPRiTunesID='edited';
                }
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-EST-SD-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-EST-SD-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-EST-SD-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caESTSDSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
                else if(changedField=='CA-SD-SRP-TPR_iTunes'){
                    document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                    wrapperList[index].caESTSDSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                    
                    if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                        wrapperList[index].edited='CA-SD-SRP-TPR_iTunes';
                    }
                    else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-SD-SRP-TPR_iTunes')){
                        var str=wrapperList[index].edited;
                        wrapperList[index].edited=str.concat(';CA-SD-SRP-TPR_iTunes');
                    }
                    component.set("v.recordsToDisplay",wrapperList);
                    formattedValue=wrapperList[index].caESTSDSRP_iTunes.replace('$','');
                    
                    if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                        component.set("v.tprGreater",true);
                        document.getElementById(event.target.id).style.borderColor = "red"
                    }
                }
            
            //CA EST HD
            if(changedField=='CA-EST-HD-WSP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caESTHDWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-EST-HD-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-EST-HD-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-EST-HD-WSP-TPR');
                }
                
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caESTHDWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            else if(changedField=='CA-EST-HD-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caESTHDSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                wrapperList[index].caESTHDSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].caESTHDTPRiTunesID==null || wrapperList[index].caESTHDTPRiTunesID==''){
                    wrapperList[index].caESTHDTPRiTunesID='edited';
                }
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-EST-HD-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-EST-HD-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-EST-HD-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caESTHDSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
                else if(changedField=='CA-HD-SRP-TPR_iTunes'){
                    document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                    wrapperList[index].caESTHDSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                    
                    if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                        wrapperList[index].edited='CA-HD-SRP-TPR_iTunes';
                    }
                    else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-HD-SRP-TPR_iTunes')){
                        var str=wrapperList[index].edited;
                        wrapperList[index].edited=str.concat(';CA-HD-SRP-TPR_iTunes');
                    }
                    component.set("v.recordsToDisplay",wrapperList);
                    formattedValue=wrapperList[index].caESTHDSRP_iTunes.replace('$','');
                    
                    if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                        component.set("v.tprGreater",true);
                        document.getElementById(event.target.id).style.borderColor = "red"
                    }
                }
            //CA EST UHD
            if(changedField=='CA-EST-UHD-WSP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caESTUHDWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-EST-UHD-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-EST-UHD-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-EST-UHD-WSP-TPR');
                }
                
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caESTUHDWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            else if(changedField=='CA-EST-UHD-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caESTUHDSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                wrapperList[index].caESTUHDSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].caESTUHDTPRiTunesID==null || wrapperList[index].caESTUHDTPRiTunesID==''){
                    wrapperList[index].caESTUHDTPRiTunesID='edited';
                }
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-EST-UHD-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-EST-UHD-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-EST-UHD-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caESTUHDSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
                else if(changedField=='CA-UHD-SRP-TPR_iTunes'){
                    document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                    wrapperList[index].caESTHDSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                    
                    if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                        wrapperList[index].edited='CA-UHD-SRP-TPR_iTunes';
                    }
                    else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-UHD-SRP-TPR_iTunes')){
                        var str=wrapperList[index].edited;
                        wrapperList[index].edited=str.concat(';CA-UHD-SRP-TPR_iTunes');
                    }
                    component.set("v.recordsToDisplay",wrapperList);
                    formattedValue=wrapperList[index].caESTUHDSRP_iTunes.replace('$','');
                    
                    if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                        component.set("v.tprGreater",true);
                        document.getElementById(event.target.id).style.borderColor = "red"
                    }
                }
            
            //CA EST 3D
            if(changedField=='CA-EST-3D-WSP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caEST3DWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-EST-3D-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-EST-3D-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-EST-3D-WSP-TPR');
                }
                
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caEST3DWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            else if(changedField=='CA-EST-3D-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caEST3DSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                wrapperList[index].caEST3DSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].caEST3DTPRiTunesID==null || wrapperList[index].caEST3DTPRiTunesID==''){
                    wrapperList[index].caEST3DTPRiTunesID='edited';
                }
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-EST-3D-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-EST-3D-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-EST-3D-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caEST3DSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
                else if(changedField=='CA-3D-SRP-TPR_iTunes'){
                    document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                    wrapperList[index].caESTHDSRPTPR_iTunes=valueChanged!=''? parseFloat(valueChanged) : null;
                    
                    if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                        wrapperList[index].edited='CA-3D-SRP-TPR_iTunes';
                    }
                    else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-3D-SRP-TPR_iTunes')){
                        var str=wrapperList[index].edited;
                        wrapperList[index].edited=str.concat(';CA-3D-SRP-TPR_iTunes');
                    }
                    component.set("v.recordsToDisplay",wrapperList);
                    formattedValue=wrapperList[index].caEST3DSRP_iTunes.replace('$','');
                    
                    if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                        component.set("v.tprGreater",true);
                        document.getElementById(event.target.id).style.borderColor = "red"
                    }
                }
            
            
            //US VOD SD
            if(changedField=='US-VOD-SD-WSP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usVODSDWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-VOD-SD-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-VOD-SD-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-VOD-SD-WSP-TPR');
                }
                
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usVODSDWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            else if(changedField=='US-VOD-SD-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usVODSDSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-VOD-SD-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-SD-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-VOD-SD-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usVODSDSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
            
            
            //US VOD HD
            if(changedField=='US-VOD-HD-WSP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usVODHDWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-VOD-HD-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-VOD-HD-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-VOD-HD-WSP-TPR');
                }
                
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usVODHDWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            else if(changedField=='US-VOD-HD-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usVODHDSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-VOD-HD-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-VOD-HD-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-VOD-HD-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usVODHDSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
            
            //US VOD UHD
            if(changedField=='US-VOD-UHD-WSP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usVODUHDWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-VOD-UHD-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-VOD-UHD-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-VOD-UHD-WSP-TPR');
                }
                
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usVODUHDWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            else if(changedField=='US-VOD-UHD-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usVODUHDSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-VOD-UHD-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-VOD-UHD-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-VOD-UHD-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usVODUHDSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
            
            //US VOD 3D
            if(changedField=='US-VOD-3D-WSP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usVOD3DWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-VOD-3D-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-VOD-3D-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-VOD-3D-WSP-TPR');
                }
                
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usVOD3DWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            else if(changedField=='US-VOD-3D-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].usVOD3DSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='US-VOD-3D-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('US-VOD-3D-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';US-VOD-3D-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].usVOD3DSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
            
            //CA VOD SD
            if(changedField=='CA-VOD-SD-WSP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caVODSDWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-VOD-SD-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-VOD-SD-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-VOD-SD-WSP-TPR');
                }
                
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caVODSDWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            else if(changedField=='CA-VOD-SD-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caVODSDSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-VOD-SD-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-VOD-SD-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-VOD-SD-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caVODSDSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
            
            
            //CA VOD HD
            if(changedField=='CA-VOD-HD-WSP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caVODHDWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-VOD-HD-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-VOD-HD-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-VOD-HD-WSP-TPR');
                }
                
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caVODHDWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            else if(changedField=='CA-VOD-HD-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caVODHDSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-VOD-HD-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-VOD-HD-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-VOD-HD-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caVODHDSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
            
            //CA VOD UHD
            if(changedField=='CA-VOD-UHD-WSP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caVODUHDWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-VOD-UHD-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-VOD-UHD-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-VOD-UHD-WSP-TPR');
                }
                
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caVODUHDWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            else if(changedField=='CA-VOD-UHD-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caVODUHDSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-VOD-UHD-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-VOD-UHD-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-VOD-UHD-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caVODUHDSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
            
            
            //CA VOD 3D
            if(changedField=='CA-VOD-3D-WSP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caVOD3DWSPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-VOD-3D-WSP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-VOD-3D-WSP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-VOD-3D-WSP-TPR');
                }
                
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caVOD3DWSP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
                
            }
            else if(changedField=='CA-VOD-3D-SRP-TPR'){
                document.getElementById(event.target.id).style.borderColor = "rgb(221, 219, 218)";
                wrapperList[index].caVOD3DSRPTPR=valueChanged!=''? parseFloat(valueChanged) : null;
                
                if(wrapperList[index].edited==null || wrapperList[index].edited==''){
                    wrapperList[index].edited='CA-VOD-3D-SRP-TPR';
                }
                else if((wrapperList[index].edited!=null || wrapperList[index].edited!='') && !wrapperList[index].edited.includes('CA-VOD-3D-SRP-TPR')){
                    var str=wrapperList[index].edited;
                    wrapperList[index].edited=str.concat(';CA-VOD-3D-SRP-TPR');
                }
                component.set("v.recordsToDisplay",wrapperList);
                formattedValue=wrapperList[index].caVOD3DSRP.replace('$','');
                
                if(valueChanged != null && formattedValue !=null && parseFloat(valueChanged) > parseFloat(formattedValue)){
                    component.set("v.tprGreater",true);
                    document.getElementById(event.target.id).style.borderColor = "red"
                }
            }
            
            if(component.get("v.tprGreater")){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"error",
                    "message": "The entered TPR Price is greater than the everyday price."
                });
                toastEvent.fire();
            }
            
            
            console.log(wrapperList);
        }
        
        
        
    },
    saveAll : function(component,event,helper){
        //if(!component.get("v.tprGreater")){
        var action1 = component.get("c.saveTPRPrices");
		var terr = []; //DFOR-1379
		terr=component.get("v.territoryList"); //DFOR-1379
		var terr1 = terr.length > 1 ? 'US;CA' : ''; //DFOR-1379
        action1.setParams({
            'wrapperList': JSON.stringify(component.get("v.recordsToDisplay")),
            'recType':component.get("v.recType"),
            'promoId' : component.get("v.recordId"),
			'promoTerr' : terr1
        });
        
        action1.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse.length >0) {
                    // set searchResult list with return value from server.
                    //component.set("v.allRecords",storeResponse);
                    component.set("v.recordsToDisplay", storeResponse); 
                    component.set("v.numberOfRecords", storeResponse.length); 
                    component.set("v.successful",true);
                    component.set("v.successMessage",'TPR Records Saved Succcessfully.')
                    
                    if(component.get("v.isjQueryLoaded")){
                        window.setTimeout(function(){
                            $("#tblTPRPricing" + component.get("v.showViewAll")).tableHeadFixer({"left" : 2,"z-index" : 4});
                        },500);
                    }  
                    
                    console.log( component.get("v.recordsToDisplay"));
                    component.set("v.isCodeError", false);
                }
                else {
                    component.set("v.isCodeError", true);
                    //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                    component.set("v.CodeError","TPR Prices are greater than the everyday price. Please correct the values before saving.");
                }
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
    showAll: function(component,event,helper){
        component.set("v.isCodeError", false);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:DGF_TPR_Pricing",
            componentAttributes: {
                recordId : component.get("v.recordId"),
                showViewAll : "false"
            }
        });        
        evt.fire(); 
        
        console.log(component.get("v.showViewAll"));
    },
    addProds: function (component,event,helper){
        component.set("v.isCodeError", false);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:DGF_NewPromotionProductComponent",
            componentAttributes: {
                PromotionId : component.get("v.recordId"),
                
            }
        });        
        evt.fire(); 
    },
    bulkTPR: function(component,event,helper){
        component.set("v.isCodeError", false);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:DGF_BulkTPRPricing",
            componentAttributes: {
                PromotionId : component.get("v.recordId"),
                
            }
        });        
        evt.fire(); 
    },
    deletePromoPrds :function(component,event,helper){
        if(component.get("v.restrictedProfile")){
            component.set("v.isCodeError", true);
            //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
            component.set("v.CodeError", 'Insufficient Privileges');
        }
        else{
            component.set("v.isCodeError", false);
            var index = event.target.dataset.index;
            var wrapperList = component.get("v.recordsToDisplay");
            var recToDelete=wrapperList[index].id;
            var action1 = component.get("c.deletePromoProduct");
            action1.setParams({
                'recId': recToDelete,
                'type': 'promo'
                
            });
            action1.setCallback(this, function(response) {
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.isCodeError", false);
                    var storeResponse = response.getReturnValue();
                    var urlEvent = $A.get("e.force:navigateToURL");
                    
                    urlEvent.setParams({
                        "url": "/" + storeResponse,
                        "isredirect": "TRUE"
                    });
                    urlEvent.fire();
                    
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
    },
    showSpinner : function (component, event, helper) {   
        component.set("v.showSpinner",true);
    },    
    hideSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",false);
    },
    scriptLoaded : function(component, event, helper) {        
        component.set("v.isjQueryLoaded", true);
        
        $("#tblTPRPricing" + component.get("v.showViewAll")).tableHeadFixer({"left" : 2,"z-index" : 4});
    },
    showMore : function (component, event, helper) {       
    //getting record list
        var masterList = component.get("v.searchResultMaster");
        var recordsToDisplay = component.get("v.recordsToDisplay");
        
        //declaring variables required for show more
        var masterListLength = masterList.length;
        var displayListLength = recordsToDisplay.length;
        var pageSize = component.get("v.pageSize");
        var maxloop = 0;
         //if length of master list is more than displayed list
        if(masterListLength > displayListLength){
            //getting size different
            var listLengthDif = masterListLength - displayListLength;
            
            //if size different is more than page size
            if(listLengthDif >= pageSize){
                maxloop = displayListLength + pageSize;
            }
            //if size difference is less than page size
            else if(listLengthDif < pageSize){
                maxloop = displayListLength + listLengthDif;
            }
            
            //creating list of records to be displayed
            for(var i=displayListLength; i < maxloop; i++){
                recordsToDisplay.push(masterList[i]);
            }
            
            //set array to list which will be loaded on UI
            component.set("v.recordsToDisplay", recordsToDisplay);
            component.set("v.numberOfRecords", recordsToDisplay.length);
        }
        
        /*helper.getNextPage(component);
        if(component.get("v.isjQueryLoaded")){
            
            window.setTimeout(function(){
                $("#tblTPRPricing" + component.get("v.showViewAll")).tableHeadFixer({"left" : 2,"z-index" : 4});
            },3000);
        }  */
    },
    cancel: function (component,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        var prId=component.get("v.recordId")  ;        
        urlEvent.setParams({
            "url": "/" + prId,
            "isredirect": "TRUE"
        });
        urlEvent.fire();
    },
    /*
     * @author: Vaibhav B
     * @Story #: DFOR-1035
     * @purpose: method which is invoked on click of header, identifies which column is clicked and what order to sort in.
    */
    sort : function(component,event,helper) {
        var searchResult = component.get("v.searchResultMaster");
        component.set("v.showSpinner",true);
        if(searchResult == null || searchResult.length == 0) {
            return;
        }
        helper.clearOrder(component,event,helper);
        var selectedColumn = component.get('v.selectedRow');
        var target = event.currentTarget.id;
        var sortOrder = true;
        if(selectedColumn == target) {
            sortOrder = !component.get('v.assending');
        } 
        component.set("v.assending",sortOrder);
        component.set("v.selectedRow",target);
        console.log('target is '+target);
        console.log('component.find(target) is '+component.find(target));
        $A.util.removeClass(component.find(target), 'slds-hide');
        helper.sortByField(component,helper,target,sortOrder,searchResult);
        component.set("v.showSpinner",false);
    },
    
    //to show editProductOrder modal
    handleEditOrder : function(component, event, helper){
       var options = component.get("v.recordsToDisplay");
        console.log("Options:" + options);
        component.set("v.availableProducts",options.productName);
        component.set("v.showEditProduct", true);
        
        
    },
    
    onSave : function(component, event, helper){
        console.log('onSave');
    },
    
    closeModal : function(component, event, helper){
        component.set("v.showEditProduct", false);
    },
    
    handleDualBox : function(component, event, helper){
        console.log('handleDualBox'); 
        var selctedProducts = event.getParam("value");
    },
     onAccountChange : function(component,event,helper) {
       //alert(component.find("actId").get("v.value"));
       var action = component.get("c.fetchRelatedRecords");
        action.setParams({
            'recordID': component.get("v.recordId"),
            'accountId': component.find("actId").get("v.value")
        });
        
		action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                //component.set("v.allRecords",storeResponse);
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
                        console.log('recordsToDisplay====='+JSON.stringify(recordsToDisplay));
                        component.set("v.recordsToDisplay", recordsToDisplay);
                        component.set("v.numberOfRecords", recordsToDisplay.length);
                }
                
                if(component.get("v.isjQueryLoaded")){
                    window.setTimeout(function(){
                        $("#tblTPRPricing" + component.get("v.showViewAll")).tableHeadFixer({"left" : 2,"z-index" : 4});
                    },3000);
                }  
                
                
                component.set("v.isCodeError", false);
            }    
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
}
    
})