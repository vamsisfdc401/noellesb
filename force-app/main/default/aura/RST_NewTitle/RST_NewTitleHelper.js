({
	advanceStep : function(component, event, helper) {
        var nextStep = component.get("v.curStep") + 1;
        component.set("v.curStep", nextStep);
        if(nextStep == 2){
            this.getMagicForecast(component);
        }
    },
    decreaseStep : function(component, event, helper) {
        component.set("v.curStep", component.get("v.curStep") - 1);
    },
    getMagicForecast : function(component, event, helper) {
        var newTitle = component.get("v.newTitle");
        var selected_list = component.get("v.selected_list");
        newTitle.titles = selected_list;
        
        // default mid week bo to 0
        if(newTitle.Midweek_BO == null){
            console.log('setting mid-week bo to 0');
        	newTitle.Midweek_BO = 0;  
        } 
        
        console.log(JSON.stringify(newTitle));

        var action = component.get("c.getMagicForecast");
        action.setParams({
            "options" : JSON.stringify(newTitle)
        });
        action.setCallback(this, function(response){
            var state=response.getState();
            if(state==='SUCCESS'){
                var data = response.getReturnValue();
                console.log(data);
                component.set("v.result" , data);
                this.advanceStep(component);
                
            } else {
                
            }
        });
        $A.enqueueAction(action); 
    },
    filterTitleList : function(component, titleString) {
        var titles_list = component.get("v.titles_list");
        var selected_list = component.get("v.selected_list");
        var result_titles = titles_list.filter(obj => obj.label.toLowerCase().includes(titleString) || selected_list.includes(obj.value));
        component.set("v.filter_list", result_titles);
        
    }

})