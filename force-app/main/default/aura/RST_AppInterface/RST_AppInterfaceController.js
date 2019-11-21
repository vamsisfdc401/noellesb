({
    doInit : function(component, event, helper){
        var action = component.get("c.checkMagicUpdated");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var data = response.getReturnValue();
                component.set("v.magicStatus", data);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleActive: function (cmp, event, helper) {
        helper.lazyLoadTabs(cmp, event);
    },
    magicClick : function(component, event, helper){
        var action = component.get("c.refreshMagic");
        action.setCallback(this, function (response) {
            var state = response.getState()
            if (state === 'SUCCESS') {
                var data = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success:",
                    "message": "Magic Refresh Started"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})