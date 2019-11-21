({
    saveDate : function(component,event,index){
          var index=event.getSource().get("v.label");
        var action1 = component.get("c.saveDates");
        action1.setParams({
            'wrapperList': JSON.stringify(component.get("v.recordsToDisplay")),
            'indexVal' : index,
            'dateval': event.getSource().get("v.value"),
            'fieldName' : event.getSource().getLocalId()
            
        });
        action1.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.recordsToDisplay",storeResponse);
                console.log(storeResponse);
                // set searchResult list with return value from server.
                // component.set("v.recordsToDisplay", storeResponse); 
                component.set("v.numberOfRecords", storeResponse.length); 
                 component.set("v.isCodeError", false);
                  if(component.get("v.isjQueryLoaded")){
                    window.setTimeout(function(){
                        $("#tblTPRPricing").tableHeadFixer({"left" : 2,"z-index" : 4});
                    },3000);
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
    /*
     * @author: Vaibhav B
     * @Story #: DFOR-1035
     * @purpose: hide all the up and down arrows on header
    */
    clearOrder : function(component,event,helper) {
        var columns=['productName', 'startDate', 'endDate', 'usESTSDWSP', 'usESTSDWSPTPR', 'usESTSDSRP', 'usESTSDSRPTPR', 'usESTHDWSP', 'usESTHDWSPTPR', 'usESTHDSRP', 'usESTHDSRPTPR', 'usESTUHDWSP', 'usESTUHDWSPTPR', 'usESTUHDSRP', 'usESTUHDSRPTPR', 'usEST3DWSP', 'usEST3DWSPTPR', 'usEST3DSRP', 'usEST3DSRPTPR', 'caESTSDWSP', 'caESTSDWSPTPR', 'caESTSDSRP', 'caESTSDSRPTPR', 'caESTHDWSP', 'caESTHDWSPTPR', 'caESTHDSRP', 'caESTHDSRPTPR', 'caESTUHDWSP', 'caESTUHDWSPTPR', 'caESTUHDSRP', 'caESTUHDSRPTPR', 'caEST3DWSP', 'caEST3DWSPTPR', 'caEST3DSRP', 'caEST3DSRPTPR', 'usVODSDWSP', 'usVODSDWSPTPR', 'usVODSDSRP', 'usVODSDSRPTPR', 'usVODHDWSP', 'usVODHDWSPTPR', 'usVODHDSRP', 'usVODHDSRPTPR', 'usVODUHDWSP', 'usVODUHDWSPTPR', 'usVODUHDSRP', 'usVODUHDSRPTPR', 'usVOD3DWSP', 'usVOD3DWSPTPR', 'usVOD3DSRP', 'usVOD3DSRPTPR', 'caVODSDWSP', 'caVODSDWSPTPR', 'caVODSDSRP', 'caVODSDSRPTPR', 'caVODHDWSP', 'caVODHDWSPTPR', 'caVODHDSRP', 'caVODHDSRPTPR', 'caVODUHDWSP', 'caVODUHDWSPTPR', 'caVODUHDSRP', 'caVODUHDSRPTPR', 'caVOD3DWSP', 'caVOD3DWSPTPR', 'caVOD3DSRP', 'caVOD3DSRPTPR', 'usESTSDWSP_iTunes', 'usESTSDWSPTPR_iTunes', 'usESTSDSRP_iTunes', 'usESTSDSRPTPR_iTunes', 'usESTHDWSP_iTunes', 'usESTHDWSPTPR_iTunes', 'usESTHDSRP_iTunes', 'usESTHDSRPTPR_iTunes', 'usESTUHDWSP_iTunes', 'usESTUHDWSPTPR_iTunes', 'usESTUHDSRP_iTunes', 'usESTUHDSRPTPR_iTunes', 'usEST3DWSP_iTunes', 'usEST3DWSPTPR_iTunes', 'usEST3DSRP_iTunes', 'usEST3DSRPTPR_iTunes', 'caESTSDWSP_iTunes', 'caESTSDWSPTPR_iTunes', 'caESTSDSRP_iTunes', 'caESTSDSRPTPR_iTunes', 'caESTHDWSP_iTunes', 'caESTHDWSPTPR_iTunes', 'caESTHDSRP_iTunes', 'caESTHDSRPTPR_iTunes', 'caESTUHDWSP_iTunes', 'caESTUHDWSPTPR_iTunes', 'caESTUHDSRP_iTunes', 'caESTUHDSRPTPR_iTunes', 'caEST3DWSP_iTunes', 'caEST3DWSPTPR_iTunes', 'caEST3DSRP_iTunes', 'caEST3DSRPTPR_iTunes', 'USSDiTunesTier', 'USSDiTunesTierTPR', 'USHDiTunesTier', 'USHDiTunesTierTPR', 'CASDiTunesTier', 'CASDiTunesTierTPR', 'CAHDiTunesTier', 'CAHDiTunesTierTPR'] ;
        for(var i = 0;i < columns.length;i++) { 
            $A.util.addClass(component.find(columns[i]), 'slds-hide');             
        }
    },
    /*
     * @author: Vaibhav B
     * @Story #: DFOR-1035
     * @purpose: sorts Master result list according to selected field and specified order.
     * sort order 'True' means assending order and 'False' as decending
    */
    sortByField : function(component,helper,fieldName,sortOrder,searchResult) {
        var stringColumns = $A.get("$Label.c.DGF_StringColumns");
        var dateColumns = $A.get("$Label.c.DGF_DateColumns");
        console.log('fieldName is '+fieldName);
        console.log('searchResult is '+searchResult);
        searchResult.sort(function(a, b){
            var element1;
            var element2;
            if(dateColumns.lastIndexOf(fieldName) >= 0) {
                var temp = a[fieldName];
                element1 = temp != null && temp != '' ? temp.substring(0,temp.indexOf('-'))+temp.substring(temp.indexOf('-')+1,temp.lastIndexOf('-'))+temp.substring(temp.lastIndexOf('-')+1,temp.length) : '00000000';
                temp = b[fieldName];
                element2 = temp != null && temp != '' ? temp.substring(0,temp.indexOf('-'))+temp.substring(temp.indexOf('-')+1,temp.lastIndexOf('-'))+temp.substring(temp.lastIndexOf('-')+1,temp.length) : '00000000';
            }
            else if(stringColumns.lastIndexOf(fieldName)>=0) {
                element1 = a[fieldName] == null ? '': a[fieldName].toLowerCase();
                element2 = b[fieldName] == null ? '': b[fieldName].toLowerCase();
            }
            else {
                	console.log('A field is '+a[fieldName] +'B val='+ b[fieldName]);
                var aIndex = 0;
                var bIndex = 0;
                if(a[fieldName] != 'N/A' && a[fieldName] != null && a[fieldName] != '' && a[fieldName].length > 0 && a[fieldName][0] == '$') {
                    aIndex = 1;
                }
                if(b[fieldName] != 'N/A' && b[fieldName] != null && b[fieldName] != '' && b[fieldName].length > 0 && b[fieldName][0] == '$') {
                    bIndex = 1;
                }
                element1 =a[fieldName] != 'N/A' && a[fieldName] != null && a[fieldName] != '' && a[fieldName].length > 0 ? a[fieldName].substr(aIndex, a[fieldName].length) : 0.0;
                element2 =b[fieldName] != 'N/A' && b[fieldName] != null && b[fieldName] != '' && b[fieldName].length > 0 ? b[fieldName].substr(bIndex, b[fieldName].length) : 0.0;
                element1 = parseFloat(element1);
                element2 = parseFloat(element2);
               
                console.log('A Element  is '+element1 +'B Elemt='+ element2);
            }
            return element1 == element2 ? 0 : element1 < element2 ? -1 : 1;            
        })
        if(!sortOrder) {
            searchResult.reverse();
        }        
        var searchResultClone=[];
        for(var i = 0;i < component.get("v.numberOfRecords") && i < searchResult.length;i++) {
            searchResultClone.push(searchResult[i]);
            console.log('searchResult[i] is '+searchResult[i]);
        }
        component.set("v.recordsToDisplay",[]);
        component.set("v.recordsToDisplay",searchResultClone);
        component.set("v.searchResultMaster",searchResult);      
    }
})