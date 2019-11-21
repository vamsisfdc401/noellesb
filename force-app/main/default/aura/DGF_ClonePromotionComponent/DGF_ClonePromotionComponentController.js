({
    doInit : function(component, event, helper) {
        var action = component.get("c.clonePromotionRecord");
        var action2 = component.get("c.getPromotionType");
        
        action.setParams({
            'recordId': component.get("v.recordId"),
            'isCloneProcess': component.get("v.isCloneProcess")
        });
        action2.setParams({
            'recordId': component.get("v.recordId"),
            'isCloneProcess': component.get("v.isCloneProcess")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                component.set("v.clonedPromotion", storeResponse); 
                //component.set("v.clonedPromotionForTPR", storeResponse);
                component.set("v.promotionTerritory", storeResponse.Territory__c); 
                component.set("v.promotionFilmOrTv", storeResponse.Film_TV__c); 
                component.set("v.promotionType", storeResponse.Promotion_Type__c); 
                component.set("v.promotionUSPlatformOffering", storeResponse.US_Platform_Offering__c); 
                component.set("v.promotionCAPlatformOffering", storeResponse.CA_Platform_Offering__c);
            }            
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // set searchResult list with return value from server.
                if(storeResponse == "Account Promotion"){
                    component.set("v.isAccountPromotion", true);
                }                
            }            
        });
        $A.enqueueAction(action);
        $A.enqueueAction(action2);
    },
    onTerritoryChange : function(component, event, helper) {
        var clonedPromotionInstance = component.get("v.clonedPromotion");
        clonedPromotionInstance.Territory__c = component.get("v.promotionTerritory");
        component.set("v.clonedPromotion", clonedPromotionInstance); 
    },
    onFilmTvChange : function(component, event, helper) {
        var clonedPromotionInstance = component.get("v.clonedPromotion");
        clonedPromotionInstance.Film_TV__c = component.get("v.promotionFilmOrTv");
        component.set("v.clonedPromotion", clonedPromotionInstance); 
    },
    onPromotionTypeChange : function(component, event, helper) {
        var clonedPromotionInstance = component.get("v.clonedPromotion");
        clonedPromotionInstance.Promotion_Type__c = component.get("v.promotionType");
        component.set("v.clonedPromotion", clonedPromotionInstance); 
    },
    onUSPlatformOfferingChange : function(component, event, helper) {
        var clonedPromotionInstance = component.get("v.clonedPromotion");
        clonedPromotionInstance.US_Platform_Offering__c = component.get("v.promotionUSPlatformOffering");
        component.set("v.clonedPromotion", clonedPromotionInstance); 
    },
    onCAPlatformOfferingChange : function(component, event, helper) {
        var clonedPromotionInstance = component.get("v.clonedPromotion");
        clonedPromotionInstance.CA_Platform_Offering__c = component.get("v.promotionCAPlatformOffering");
        component.set("v.clonedPromotion", clonedPromotionInstance); 
    },
    gotoURL : function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var promotionId = component.get("v.recordId");
        
        urlEvent.setParams({
            "url": "/" + promotionId,
            "isredirect": "TRUE"
        });
        urlEvent.fire();
    },
    saveRecordDetails : function(component, event, helper) {        
        var tprField = component.find("inputTPR");
        var tprValue = tprField.get("v.value");
        //alert(tprValue);
        
        //if record name is null then throw error
        if(component.get("v.clonedPromotion").Name == null || component.get("v.clonedPromotion").Name == ''){
            component.set("v.isCodeError", true);
            component.set("v.CodeError", 'Please enter promotion name.');
        }
        //else process
        else{
            var tempClonedPromotion = component.get("v.clonedPromotion");
            
            //if start date is set as blank then populate null to avoid deserializing error 
            if (tempClonedPromotion.Start_Date__c == '') {
                tempClonedPromotion.Start_Date__c = null;
            }
            
            //if end date is set as blank then populate null to avoid deserializing error 
            if (tempClonedPromotion.End_Date__c == '') {
                tempClonedPromotion.End_Date__c = null;
            }
            
            var action = component.get("c.saveClonedPromotionRecord");        
            action.setParams({
                'promotionInstance': JSON.stringify(component.get("v.clonedPromotion")),
                'recordId': component.get("v.recordId"),
                'strNationalTPROffering': tprValue,
                'isCloneProcess': component.get("v.isCloneProcess")
            });
            action.setCallback(this, function(response) {
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
            $A.enqueueAction(action); 
        }        
    },
    showSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",true);
    },    
    hideSpinner : function (component, event, helper) {       
        component.set("v.showSpinner",false);
    }
})