({
    sortTitles : function(component){
        var titles = component.get("v.titles");
        var field = component.get("v.sortField");
        var sortAsc = component.get("v.sortAsc");
        //var sortAsc = field == sortField? !sortOrder: true;
        titles.sort(function(a,b){
            var t1 = a[field] == b[field],
            t2 = a[field] > b[field];
            return t1? 0: ((sortAsc?-1:1)*(t2?-1:1));
        });
        //component.set("v.titles_all", titles);
        component.set("v.titles", titles);
        component.set("v.showSpinner", false);
        //function filterByType (list, type) {
            //return list.filter(obj => obj.type === type)
          //}
    },
    toggleSortOrder: function(component){
        component.set("v.sortAsc", !component.get("v.sortAsc"));
        this.sortTitles(component);

    },
    setTitleLocked : function(component, isLocked){
        var selectedTitle = component.get("v.selectedTitle");
        var useSuccessMessage  = (isLocked) ? 'Title is Locked' : 'Title is Unlocked';

        
        var action = component.get("c.setTitleLocked");
        action.setParams({
            "titleId" : selectedTitle.Id,
            "isLocked" : isLocked
        });
        action.setCallback(this, function(response){
            var state=response.getState()
            if(state==='SUCCESS'){
                var data = response.getReturnValue();
                console.log(data);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success:",
                    "message": useSuccessMessage
                });
                toastEvent.fire();
                
            } else {
                
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action); 
    },
    getTitlesNestedPlayWeeks : function(component){
        //getNestedPlayWeeks
        var selectedTitle = component.get("v.selectedTitle");

        
        var action = component.get("c.getNestedPlayWeeks");
        action.setParams({"titleId" : selectedTitle.Id});
        action.setCallback(this, function(response){
            var state=response.getState()
            if(state==='SUCCESS'){
                var data = response.getReturnValue();
                console.log(data);
                /*
                console.log('data');
                console.log(data);
                var tempJSON = JSON.parse(JSON.stringify(data).split('Play_Weeks__r').join('_children'));
                */
                component.set("v.selectedTitlePW" , data);
                
            } else {
                
            }
        });
        $A.enqueueAction(action); 
    },

    saveTitleInfo : function(component) {
        var selectedTitle = component.get("v.selectedTitle");
        var selectedTitlePW = component.get("v.selectedTitlePW");
        
        console.log(selectedTitle);
        console.log(selectedTitlePW);

        
        var action = component.get("c.setNestedPlayWeeks");
        action.setParams({
            "titleId" : selectedTitle.Id,
            "titlePlayWeek" : JSON.stringify(selectedTitlePW)
        });
        action.setCallback(this, function(response){
            var state=response.getState();
            if(state==='SUCCESS'){
                var data = response.getReturnValue();
                console.log(data);
                /*
                console.log('data');
                console.log(data);
                var tempJSON = JSON.parse(JSON.stringify(data).split('Play_Weeks__r').join('_children'));
                */
                component.set("v.selectedTitlePW" , data);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success:",
                    "message": "Save successful!"
                });
                toastEvent.fire();
                
            } else {
                
            }
        });
        $A.enqueueAction(action); 
    },
    prepPageOptions : function(component, data){
        //var pageOptions = component.get("v.pageOptions");
        var pageOptions = {};
        //prepPageOptions : function(component, data){
        var raw_weeks =  [...new Set(data.map(item => item.Wide_Release_Date__c))];
        pageOptions["weeks"] = raw_weeks.sort(function(a,b){
           return  Date.parse(a) - Date.parse(b);
        });

        var raw_dists =  [...new Set(data.map(item => item.Distributor__c))];
        pageOptions["dists"] = raw_dists.sort(function(a,b){
            return  a > b;
        });

        var raw_fso_genre =  [...new Set(data.map(item => item.FS_O_Genre__c))];
        pageOptions["fso_genres"] = raw_fso_genre.sort(function(a,b){
            return  a > b;
        });

        var raw_ren_genre =  [...new Set(data.map(item => item.RenTrak_Genre__c))];
        pageOptions["ren_genres"] = raw_ren_genre.sort(function(a,b){
            return  a > b;
        });

        component.set("v.pageOptions", pageOptions);
        component.set("v.showSpinner", false);
        
        console.log(pageOptions);
    },
    
    filterTitles : function(component,event,helper) {
        var titles = component.get("v.titles_all");
        
        //Gather filter inputs
        var filters = {
            title : component.find('title-search').get('v.value').toLowerCase(),
            playweek : component.find('weeks-select').get('v.value'),
            distributor : component.find('dists-select').get('v.value'),
            fsoGenre : component.find('fso-genre-select').get('v.value'),
            renGenre : component.find('ren-genre-select').get('v.value')
        }
        //console.log('Filters: ' + JSON.stringify(filters));
        
        var result_titles = titles;
        
        //First - filter by title
        if (filters.title != null && filters.title != undefined && filters.title != "") {
            console.log('made it to title filter');
            result_titles = result_titles.filter(obj => obj.Name.toLowerCase().includes(filters.title));
        }
        //Second - Filter by Play Week
        if (filters.playweek != null && filters.playweek != undefined && filters.playweek != "") {
            console.log('made it to playweeks filter');
            result_titles = result_titles.filter(obj => obj.Wide_Release_Date__c === filters.playweek);
        }
        
        //Third - Filter by Distributor
        if (filters.distributor != null && filters.distributor != undefined && filters.distributor != "") {
            console.log('made it to distributor filter');
            result_titles = result_titles.filter(obj => obj.Distributor__c === filters.distributor);
        }
        
        //Fourth - Filter by FS&O Genre
        if (filters.fsoGenre != null && filters.fsoGenre != undefined && filters.fsoGenre != "") { 
            console.log('made it to fsoGenre filter');
            result_titles =  result_titles.filter(obj => obj.FS_O_Genre__c === filters.fsoGenre);
        }
        
        //Fifth - Filter by RenTrak Genre
        if (filters.renGenre != null && filters.renGenre != undefined && filters.renGenre != "") {
            console.log('made it to rentrakGenre filter');
            result_titles = result_titles.filter(obj => obj.RenTrak_Genre__c === filters.renGenre);
        }
        
        component.set("v.titles", result_titles);
    },

    /*
    calcBO : function(component, pwId){
        var titles = component.get("v.titles");
        //var selectedTitle = titles.find(obj => obj.Id === component.get("v.selectedTitle"));
        var selectedTitle = component.get("v.selectedTitle");
        console.log('got seelcted title');
        console.log(selectedTitle);

        var selectedPW = selectedTitle.Play_Weeks__r.find(obj => obj.Id === pwId);

        console.log('got seelcted pw: ' + pwId);
        console.log(selectedPW);

        var bo_wknd = component.find("BO_WKND"); //.get("v.value");
        var bo_week = component.find("BO_WEEK"); //.get("v.value");

        console.log('got all bos');
        console.log(bo_wknd);
        console.log(bo_week);
        
        var bo_wknd_selected = bo_wknd.find(obj => obj.get("v.label") === pwId);
        var bo_week_selected = bo_week.find(obj => obj.get("v.label") === pwId);

        console.log('got seelcted bos');
        console.log(bo_wknd_selected);
        console.log(bo_week_selected);

        var bo_wknd_selected_value = bo_wknd_selected.get("v.value");
        var bo_week_selected_value = bo_week_selected.get("v.value");

        console.log('got seelcted values');
        console.log(bo_wknd_selected_value);
        console.log(bo_week_selected_value);

        // see if anything changed or just tabbed through
        if(selectedPW.Weekend_BO__c != bo_wknd_selected_value || selectedPW.Midweek_BO__c != bo_week_selected_value){
            console.log('update my total bo');
        }
        
    }
    */

})