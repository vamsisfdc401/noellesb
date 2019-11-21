({
    resetTitles : function(component, data){
        component.set("v.titles_all", data);
        
        var startDate = component.get("v.startDate");
        var result_titles = data.filter(obj => (Date.parse(obj.Wide_Release_Date__c) >= Date.parse(startDate) /*&& Date.parse(obj.Wide_Release_Date__c) < Date.parse(endDate)*/));
        
        component.set("v.titles", result_titles);
        
    },
    sortTitles : function(component){
        //Modified by Saurav :Enable Sorting on the "Last Edited By" Column- COES-25
        //var titles = component.get("v.titles");
        var field = component.get("v.sortField");
        var sortAsc = component.get("v.sortAsc");
        var action = component.get('c.sortingByFieldOfTittle');
        action.setParams({
         'sortField': field,
         'isAsc': sortAsc
      });
      action.setCallback(this, function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
             var data=response.getReturnValue();
             this.resetTitles(component, data);
             this.prepPageOptions(component, data);
         }
      });
        /*titles.sort(function(a,b){
            var t1 = a[field] == b[field],
            t2 = a[field] > b[field];
            return t1? 0: ((sortAsc?-1:1)*(t2?-1:1));
        });
        
        component.set("v.titles", titles);*/
        component.set("v.showSpinner", false);
      $A.enqueueAction(action);
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
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success:",
                    "message": useSuccessMessage
                });
                toastEvent.fire();
                
                var titles = component.get("v.titles");
                for(var title in titles){
                    if(title.Id == selectedTitle.Id) title.Lock_Title__c = isLocked;
                }
				component.set("v.titles", titles);
                
            } else {
                
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action); 
    },
    getTitlesNestedPlayWeeks : function(component, selectedTitleId){
        //getNestedPlayWeeks
        //var selectedTitle = component.get("v.selectedTitle");
		component.set("v.selectedTitlePW" , null);
        
        var action = component.get("c.getNestedPlayWeeks");
        action.setParams({"titleId" : selectedTitleId});
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
                component.set('v.selectedTitleLoaded', true);
                
            } else {
                
            }
        });
        $A.enqueueAction(action); 
    },

    saveTitleInfo : function(component) {
        var selectedTitle = component.get("v.selectedTitle");
        var selectedTitlePW = component.get("v.selectedTitlePW");
                
        var action = component.get("c.setNestedPlayWeeks");
        action.setParams({
            "titleId" : selectedTitle.Id,
            "titlePlayWeek" : JSON.stringify(selectedTitlePW)
        });
        action.setCallback(this, function(response){
            var state=response.getState();
            if(state==='SUCCESS'){
                var data = response.getReturnValue();
                //console.log(data);
                //console.log(data.pw.LastModifiedBy.Name);
                component.set("v.selectedTitlePW" , data);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success:",
                    "message": "Save successful!"
                });
                toastEvent.fire();
                
                var titles = component.get("v.titles");
                for(var title in titles){
                    //console.log(title);
                    //console.log('title.Id: ' + titles[title].Id + ' && selectedTitle.Id: ' + selectedTitle.Id);
                    if(titles[title].Id == selectedTitle.Id) {
                        //console.log('change last updated user');
                        titles[title].LastModifiedBy.Name = data.pw.LastModifiedBy.Name;
                    }
                }
				component.set("v.titles", titles);
                
            } else {
                
            }
        });
        $A.enqueueAction(action); 
    },
    prepPageOptions : function(component, data){
        
        var pageOptions = {};
        
        // get weeks between start end
        var startDate = (component.get("v.startDate") != '') ? new Date(component.get("v.startDate")) : null;
        var endDate = (component.get("v.endDate") != '') ? new Date(component.get("v.endDate")) : null;  
        
        var filteredItems = data.filter(function (item) { 
            let releaseDate = new Date(item.Wide_Release_Date__c);
  			return releaseDate >= startDate && (releaseDate <= endDate || endDate == null); 
		});

        var raw_weeks =  [...new Set(filteredItems.map(item => item.Wide_Release_Date__c))];
        pageOptions["weeks"] = raw_weeks.sort(function(a,b){
           return  Date.parse(a) - Date.parse(b);
        });

        var raw_dists =  [...new Set(filteredItems.map(item => item.Distributor__c))];
        pageOptions["dists"] = raw_dists.sort(function(a,b){
            return a.localeCompare(b);
        });
        
        var raw_fso_genre =  [...new Set(filteredItems.map(item => item.FS_O_Genre__c))];
        pageOptions["fso_genres"] = raw_fso_genre.sort(function(a,b){
            return a.localeCompare(b);
        });

        var raw_ren_genre =  [...new Set(filteredItems.map(item => item.RenTrak_Genre__c))];
        pageOptions["ren_genres"] = raw_ren_genre.sort(function(a,b){
            return a.localeCompare(b);
        });

        component.set("v.pageOptions", pageOptions);
        component.set("v.showSpinner", false);
        
        console.log(pageOptions);
    },
    
    filterTitles : function (component, event, helper) {
        var showFilter = component.get("v.showFilter");
		var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");
        var titles= component.get("v.titles_all");
        var filters = {};
        //Gather filter inputs
        if (showFilter) {
            filters = {
                startDate : startDate,
                endDate : endDate,
                title : component.find('title-search').get('v.value').toLowerCase(),
                playweek : component.find('weeks-select').get('v.value'),
                distributor : component.find('dists-select').get('v.value'),
                fsoGenre : component.find('fso-genre-select').get('v.value'),
                renGenre : component.find('ren-genre-select').get('v.value')
            }
        }
        else {
            filters = {
                startDate : startDate,
                endDate : endDate
            }
        }
        //console.log('Filters: ' + JSON.stringify(filters));
        
        var result_titles = titles;
        
        // 1st Filter by date range
        
            if (filters.startDate != null && filters.startDate != undefined && filters.startDate != "" &&
                filters.endDate != null && filters.endDate != undefined && filters.endDate != "") {
                result_titles = result_titles.filter(obj => (Date.parse(obj.Wide_Release_Date__c) >= Date.parse(filters.startDate) && Date.parse(obj.Wide_Release_Date__c) <= Date.parse(filters.endDate)));
            }
            else if (filters.startDate != null && filters.startDate != undefined && filters.startDate != "") {
                result_titles = result_titles.filter(obj => Date.parse(obj.Wide_Release_Date__c) >= Date.parse(filters.startDate));
            }
            else if (filters.endDate != null && filters.endDate != undefined && filters.endDate != "") {
                 result_titles = result_titles.filter(obj => Date.parse(obj.Wide_Release_Date__c) <= Date.parse(filters.endDate));
            }
        
        if (showFilter) {
            //2nd - filter by title
            if (filters.title != null && filters.title != undefined && filters.title != "") {
                result_titles = result_titles.filter(obj => obj.Name.toLowerCase().includes(filters.title));
            }
            //3rd - Filter by Play Week
            if (filters.playweek != null && filters.playweek != undefined && filters.playweek != "") {
                result_titles = result_titles.filter(obj => obj.Wide_Release_Date__c === filters.playweek);
            }
            
            //4th - Filter by Distributor
            if (filters.distributor != null && filters.distributor != undefined && filters.distributor != "") {
                result_titles = result_titles.filter(obj => obj.Distributor__c === filters.distributor);
            }
            
            //5th - Filter by FS&O Genre
            if (filters.fsoGenre != null && filters.fsoGenre != undefined && filters.fsoGenre != "") { 
                result_titles =  result_titles.filter(obj => obj.FS_O_Genre__c === filters.fsoGenre);
            }
            
            //6th - Filter by RenTrak Genre
            if (filters.renGenre != null && filters.renGenre != undefined && filters.renGenre != "") {
                result_titles = result_titles.filter(obj => obj.RenTrak_Genre__c === filters.renGenre);
            }
        }
        //console.log('Result Titles: ' + JSON.stringify(result_titles));
        component.set("v.titles", result_titles);
		this.prepPageOptions(component, result_titles);
    },
    
    getAppSettings : function(component, event, helper) {
        var action = component.get("c.getApplicationSettings");
        action.setCallback(this, function(response){
            var state=response.getState()
            if(state==='SUCCESS'){
                component.set("v.appSettings", response.getReturnValue());
                
            } else {
                
            }
        });
        $A.enqueueAction(action);
        
    },

})