({
	doInit : function(component, event, helper) {
		var columns = [
            {label: 'Contact Name', fieldName: 'Contact__c', type: 'Contact__c', sortable: true}
        ];
        component.set("v.mycolumns",columns);
        var action = component.get("c.getRelatedRecords");
        
        action.setParams(
            {
                "recordId":component.get("v.recordId"),
                "parentObjAPIName":component.get("v.parentObjAPIName"),
                "parentFieldAPIName":component.get("v.parentFieldAPIName"), 
                "childObjectAPIName":component.get("v.childObjectAPIName"),
                "lookupFieldAPINameOnChildObject":component.get("v.lookupFieldAPINameOnChildObject")
            }
        );
        
        action.setCallback(this, function(response) { 
        	console.log(response.getReturnValue());
            component.set("v.childData", response.getReturnValue());
        });
        $A.enqueueAction(action);
	}
})