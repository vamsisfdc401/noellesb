({
    doInit: function (component, event, helper) {
        var newTitle = {};
        component.set("v.newTitle", newTitle);

        var action = component.get("c.getNewTitleOptions");
        //action.setParams({"versionId" : version_selected});
        action.setCallback(this, function (response) {
            var state = response.getState()
            if (state === 'SUCCESS') {
                var data = response.getReturnValue();
                console.log(data);

                component.set("v.titles", data.titles.sort());
                component.set("v.genres", data.genres.sort());

                var titles_list = [];
                titles_list = data.titles.map(
                    (el) => {
                        var le = {};
                        le.label = el.Name;
                        le.value = el.Id;
                        return le;
                    }
                );
                console.log('titles_list');
                console.log(titles_list);
                component.set("v.titles_list", titles_list.sort()); // complete list, use for filtering
                component.set("v.filter_list", titles_list.sort()); // filtered list, use for displaying
                

            } else {

            }
        });
        $A.enqueueAction(action);

    },
    enterTitleNext: function (component, event, helper) {
        
        helper.advanceStep(component);
        
    },
    previousClicked: function (component, event, helper) {
        helper.decreaseStep(component);
    },
    titleCompareUpdated: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value").toString();
        var titles = selectedOptionValue.split(",");
		
        var selected_list = component.get("v.selected_list");
    },
    titleChanged: function (component, event, helper) {
        
        var title_id = event.getParam("value"); //src.get("v.Name");
        var newTitle = component.get("v.newTitle");
        newTitle.Id = title_id[0]; //'something';
                
        component.set("v.newTitle", newTitle);
    },
    retryClick  : function (component, event, helper) {
        helper.getMagicForecast(component);
    },
    magicClick : function (component, event, helper) {
        var action = component.get("c.refreshMagic");
        action.setCallback(this, function (response) {
            var state = response.getState()
            if (state === 'SUCCESS') {
                var data = response.getReturnValue();
                console.log(data);
            }
        });
        $A.enqueueAction(action);

    },
    updateFilterList : function (component, event, helper) {        
        var filterValue = event.getSource().get("v.value");
        //var selected_list = component.get("v.selected_list");
        
        helper.filterTitleList(component, filterValue);
    }
    

})