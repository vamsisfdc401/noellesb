({
    doInit: function (component, event, helper) {
        
        //console.log('on init fired');
        var useToday = new Date().toISOString().split('T')[0];
        component.set("v.useToday", useToday);
        
        
        var pw = component.get("v.PlayWeek");
        if(pw){
            console.log('init: has a playweek ' + pw.pw.Name);
            helper.processPlayWeek(component);
	        //component.set("v.initComplete", true);  
        } else {
            // loading delayed in '18
            console.log('init: does NOT has a playweek');
        }

    },
    cellFocus : function(component, event, helper){
        component.set("v.current_value", event.getSource().get("v.value"));
        
    },
    userUpdatedDecay : function (component, event, helper) {
        var current_value = component.get("v.current_value");
        if(current_value != event.getSource().get("v.value")){
            component.set("v.USE_BO_CALC", false);
            helper.processPlayWeek(component, true);
        }
        
    },
    userUpdatedBO : function (component, event, helper) {
        var current_value = component.get("v.current_value");
        if(current_value != event.getSource().get("v.value")){
            component.set("v.USE_BO_CALC", true);
            console.log("v.USE_BO_CALC : " + component.get("v.USE_BO_CALC"));
            helper.processPlayWeek(component, true);
        }
        
    },
    childUpdated : function (component, event, helper) {
		//var processing = component.get("v.processing");
        var params = event.getParam('arguments');
        console.log('Param 1: '+ params.wknd_bo);
        console.log('Param 2: '+ params.week_bo);

        component.set("v.start_WKND_BO", params.wknd_bo);
        component.set("v.start_WEEK_BO", params.week_bo);
        //component.set("v.USE_BO_CALC", params.use_bo_calc);
        
        component.set("v.USE_BO_CALC", false);

        var initComplete = component.get("v.initComplete");
        if(initComplete) helper.processPlayWeek(component, initComplete  ); // if init is done then its probably a user edit from a parent

    },
        
    playWeekUpdated: function (component, event, helper) {

        /*
        var processing = component.get("v.processing");
        var pw = component.get("v.PlayWeek");
        var useName = (pw) ? pw.pw.Name : 'unknown';
        console.log('playweek changed: ' + useName + ' and processing = ' + processing);
		
        if(!processing) {
            component.set("v.initComplete", true);
            //helper.processPlayWeek(component);
            
        } 
        */
    }
})