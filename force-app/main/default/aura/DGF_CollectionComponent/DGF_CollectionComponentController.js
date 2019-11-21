({
	
		doInit : function(component, event, helper) {
      
		  var action1 = component.get("c.fetchCollections");
            
          action1.setParams({
            'recordID': component.get("v.recordId")  
        });
            
             var action2 = component.get("c.fetchPromotionType");
            
          action2.setParams({
            'recordID': component.get("v.recordId")  
        });
         var action3 = component.get("c.getProfileDetails");
            action3.setParams({
            'recordID': component.get("v.recordId")  
        });
         action1.setCallback(this, function(response) {
             
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                component.set("v.recordsToDisplay", storeResponse); 
                component.set("v.numberOfRecords", storeResponse.length); 
           
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
            component.set("v.promoType",storeResponse);
             
             });
             action3.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                //component.set("v.allRecords",storeResponse);
                component.set("v.restrictedProfile", storeResponse); 
                
               
            }    
            else if (state === "ERROR"){
                component.set("v.isCodeError", true);
                //component.set("v.CodeError", "An unexpected error has happened. Please contact system administrator.");
                component.set("v.CodeError", response.getError()[0].message);
                console.log("Error Message", response.getError()[0].message);
            }
        });
        $A.enqueueAction(action3);
         $A.enqueueAction(action1);
         $A.enqueueAction(action2);
	},
    
    showAll: function(component,event,helper){
          var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:DGF_CollectionComponent",
            componentAttributes: {
                recordId : component.get("v.recordId"),
                showViewAll : "false"
            }
        });        
        evt.fire(); 
    },
    editPromoProd: function(component,event,helper){
       var index = event.target.dataset.index;
        var wrapperList = component.get("v.recordsToDisplay");
       var action1 = component.get("c.editPromoPrd");
          action1.setParams({
            'wrpList': JSON.stringify(component.get("v.recordsToDisplay")),
              'ind':index
        });
         action1.setCallback(this, function(response) {
             
            var state = response.getState();
            if (state === "SUCCESS") {
            var storeResponse = response.getReturnValue();
                    var urlEvent = $A.get("e.force:navigateToURL");
                    
                    urlEvent.setParams({
                        "url": "/" + storeResponse + "/e",
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
       

      
    },
    
    deletePromoProd : function(component,event,helper){
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
        console.log(recToDelete);
          var action1 = component.get("c.deletePromoProduct");
          action1.setParams({
            'recId': recToDelete,
              'type': 'collection'
              
        });
         action1.setCallback(this, function(response) {
             
            var state = response.getState();
            if (state === "SUCCESS") {
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
        console.log('wait...');
        component.set("v.showSpinner",true);
    },    
    hideSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",false);
    }
	
})