({
	loadData : function(component, event, helper) {
	 var pageSize = component.get("v.pageSize");
	 var action1 = component.get('c.validateBundlesInTPR');
	 var today = $A.localizationService.formatDate(new Date(), "MM/DD/YYYY");
    component.set("v.today", today);
	action1.setParams({
            			promotionId : component.get("v.recordId")
            		});
            		action1.setCallback(this, function(response) {
			        //store state of response
			        var state = response.getState();
			        if (state === "SUCCESS") {
			          //set response value in wrapperList attribute on component.
			             //component.set('v.pricingWrapper', response.getReturnValue());
			             var bundleWrapperResponse = response.getReturnValue();
			             console.log('bundleWrapperResponse' + bundleWrapperResponse);
			           /*  if(priceWrapperResponse!='undefined' && priceWrapperResponse.length  == 1){
			            	 console.log('priceWrapperResponse' + priceWrapperResponse.length);
			            	 if(priceWrapperResponse[0].name == "PASS"){
			            		 component.set('v.successResponse', priceWrapperResponse[0].validationNotes);
			            		 component.set('v.displaySuccessMsg', "TRUE");
			            	 }else{
			            		 component.set('v.displayValidationMsg', "TRUE"); 
			            		 component.set('v.pricingWrapper', response.getReturnValue());
			            	 }
			             }else */
			             if(bundleWrapperResponse!='undefined'){
			            	// component.set('v.displayValidationMsg', "TRUE"); 
			            	 component.set("v.bundleWrapper", bundleWrapperResponse);
                             component.set("v.totalSize", component.get("v.bundleWrapper").length);
                             component.set("v.start",0);
                             component.set("v.end",pageSize-1);
                             var bundleWrapperSize = component.get("v.bundleWrapper").length;
                             if(bundleWrapperSize>5){
                            	 pageSize = 5;
                             }else{
                            	 pageSize = bundleWrapperSize;
                             }
                             var paginationList = [];
                             for(var i=0; i< pageSize; i++)
                             {
                              paginationList.push(response.getReturnValue()[i]);    
                              }
                             component.set('v.paginationList', paginationList);

			            	 //component.set('v.pricingWrapper', response.getReturnValue());
			             }
			        }
			      });
			      $A.enqueueAction(action1);
			      
			    
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