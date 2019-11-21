({
    doInit : function(component, event, helper) { 
        component.set("v.changeInOrder", false);
        
        var action = component.get("c.getProductUser");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {            
            	var storeResponse = response.getReturnValue();            	
            	component.set("v.isNotProductUser", storeResponse);
            
            	var action1 = component.get("c.fetchTitles");
		        action1.setParams({
		            'releaseID': component.get("v.recordId") 
		        });
		        
		        action1.setCallback(this, function(response) {
		            var state = response.getState();
		            if (state === "SUCCESS") {
		                var storeRes = response.getReturnValue();                        
		                if(storeRes != null){                    
		                    component.set("v.allTitles",storeRes) ; 
		                    var titleOptions = [];
		                    for(var i=0;i<storeRes.length;i++){
		                        titleOptions.push({"class": "optionClass",
		                                       label: storeRes[i],
		                                       value: storeRes[i]});
		                    }
		                    //component.find("selectedTitleValuesId").set("v.options", titleOptions);
		                    component.set("v.listOptions", titleOptions);
		                    
		                    component.set("v.defaultOptions", storeRes);
		                }                        
		            }else if (state === "ERROR"){
		                component.set("v.isCodeError", true);
		                component.set("v.CodeError", response.getError()[0].message);
		                console.log("Error Message", response.getError()[0].message);
		            }
		        });
		        $A.enqueueAction(action1);
            }
        }); 
        $A.enqueueAction(action);
        
    },
    showSpinner : function (component, event, helper) {   
    	//console.log('spinner on');
        component.set("v.Spinner",true);
    },    
    hideSpinner : function (component, event, helper) {       
        component.set("v.Spinner",false);
        //console.log('spinner on');
    },
    cancel : function(component,event,helper){
        helper.cancelPage(component,event);
    },  

    handleChange: function (component, event) {

      // Get the list of the "value" attribute on all the selected options

      var selectedOptionsList = event.getParam("value");
      component.set("v.selectedTitles", selectedOptionsList);
      component.set("v.changeInOrder", true);
      //alert("Options selected: '" + selectedOptionsList + "'");

    },
 
 
    Search : function(component, event, helper) {
        var searchKeyFld = component.find("searchId");
        var srcValue = searchKeyFld.get("v.value");
        component.set("v.isCodeError", false);
        if (srcValue == '' || srcValue == null) {
            // display error message if input value is blank or null
            searchKeyFld.set("v.errors", [{
                message: "Enter Search Keyword."
            }]);
        } else {
            searchKeyFld.set("v.errors", null);
            // call helper method
            helper.searchTitle(component,event);
        }
    },
    
    SaveOrderTitle : function (component, event, helper) {
        //var finalValues = component.find("selectedTitleValuesId").get("v.options"); 
        var finalValues =   component.get("v.selectedTitles");
        var digiReleaseId = component.get("v.recordId");
        
        var action = component.get("c.updateTitles");
        action.setParams({ 
            "releaseID": digiReleaseId,
            "finalOrder" : finalValues  
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (component.isValid() && state == 'SUCCESS') {
              var urlEvent = $A.get("e.force:navigateToURL");
                    if(urlEvent) {
                        urlEvent.setParams({
                            "url": "/" + digiReleaseId
                        });
                        urlEvent.fire();
                        $A.get('e.force:refreshView').fire();
                        
                    } else {
                        sforce.one.navigateToURL("/" + digiReleaseId);
                        $A.get('e.force:refreshView').fire();
                    } 
                   
                }else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                alert("Error message: " + 
                                      errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }                       
             
        });        
        $A.enqueueAction(action); 
    }
    
})