({
	doInIt : function(cmp, event, helper) {
        var acctNames = [];
		var action = cmp.get("c.getPromotionAccounts");
        var today = $A.localizationService.formatDate(new Date(), "MM/DD/YYYY");
    	cmp.set("v.today", today);
        action.setParams({ promotionId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + JSON.stringify(response.getReturnValue()));
                var result = response.getReturnValue();
                if(result == null){
                  alert("No Promotion accounts associted for this promotion");  
                }
                else if(result.length===1){
                    //alert("Validate the account");
                    helper.validateAccount(cmp, event, result[0].Account__c);
                    cmp.set("v.accountName",result[0].Account__r.Name);
                }
                    else if(result.length>1){
                        /*for(var i=0;i<result.length ; i++){
                          acctNames.push(result[i].Account__r.Name);  
                        } */
                        cmp.set("v.accountPromotions",result);
                    }
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    validateSelected : function(component, event, helper) {
        //alert(cmp.find("accNameId").get("v.value"));
        helper.validateAccount(component, event, component.find("accNameId").get("v.value"));   
    },
	handleNext : function(component, event, helper) 
    {
        var pgNo = component.get("v.pageNumber");
        var page = parseInt(pgNo)+parseInt(1);
        component.set("v.pageNumber",page);console.log("page number "+page);
     var bundleList = component.get("v.bundleWrapper");
        var end = component.get("v.end");    console.log("next end "+end);           
        var start = component.get("v.start");   console.log("next start "+start);        
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++)
        {
         if(bundleList.length > i)
            {
          paginationList.push(bundleList[i]);
                
         }
         counter ++ ;
        }
        console.log("paginationList "+paginationList);
        start = start + counter;
        end = end + counter;
        
        component.set("v.start",start); console.log("next start1 "+start); 
        component.set("v.end",end);      console.log("next end1 "+end);
        
        component.set('v.paginationList', paginationList);
    },
    handlePrevious : function(component, event, helper) 
    {
        var pgNo = component.get("v.pageNumber");
        var page = parseInt(pgNo)-parseInt(1);
        component.set("v.pageNumber",page);console.log("page number "+page);
     var bundleList = component.get("v.bundleWrapper");
        var end = component.get("v.end");console.log("Previous end "+end);
        var start = component.get("v.start");console.log("Previous start "+start);
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
         
        var counter = 0; console.log("start-pageSize "+start-pageSize);
        for(var i= start-pageSize; i < start ; i++)
        { 
         if(i > -1)
            {
             paginationList.push(bundleList[i]);
                counter ++;
         }
            else
            {
                start++;
                end++;
            }
        }console.log("start "+start);console.log("counter "+counter);
        start = start - counter;
        end = end - counter;
        
        component.set("v.start",start);console.log("Previous start1 "+start);
        component.set("v.end",end);console.log("Previous end1 "+end);
        
        component.set('v.paginationList', paginationList);
    },
    navigateBack : function(component, event, helper){
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": "/"+component.get("v.recordId")
    });
    urlEvent.fire();
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }
	
})