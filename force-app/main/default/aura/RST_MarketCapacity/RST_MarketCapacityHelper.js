({
    prepWeekDates : function(component, data) {
        
        // get weeks between start end
        var startDate = new Date(component.get("v.startDate"));
        var endDate = (component.get("v.endDate") != '') ? new Date(component.get("v.endDate")) : null;        
        var filteredWeeks = data.filter(function (item) { 
            let weekDate = new Date(item.Week_Date__c);
  			return weekDate >= startDate && (weekDate <= endDate || endDate == null); 
		});
        
        /*
        var mcWeeks =  [...new Set(data.map(item => item.Week_Date__c))];
        mcWeeks = mcWeeks.sort(function(a,b){
           return  Date.parse(a) - Date.parse(b);
        }); 
        */
        component.set("v.weekDates", [...new Set(filteredWeeks.map(item => item.Week_Date__c))]);
    },  
    
    getPlayWeeks: function (component) {
        var currentWeek = component.get("v.selectedWeek");
        if (currentWeek) {
            var action = component.get("c.getPlayWeeksForWeek");
            action.setParams({ "weekSelected": currentWeek });
            action.setCallback(this, function (response) {
                var state = response.getState()
                if (state === 'SUCCESS') {
                    var data = response.getReturnValue();
                    console.log(data);
                    /*
                    console.log('data');
                    console.log(data);
                    var tempJSON = JSON.parse(JSON.stringify(data).split('Play_Weeks__r').join('_children'));
                    */
                    component.set("v.selectedWeekDetail", data);

                } else {

                }
            });
            $A.enqueueAction(action);
        }

    },

    sortWeeks : function(component){
        var mcWeeks = component.get("v.weeks");
        var field = component.get("v.sortField");
        var sortAsc = component.get("v.sortAsc");

        mcWeeks.sort(function(a,b){
            var t1 = a[field] == b[field],
            t2 = a[field] > b[field];
            return t1? 0: ((sortAsc?-1:1)*(t2?-1:1));
        });
        component.set("v.weeks", mcWeeks);

    },
    toggleSortOrder: function(component){
        component.set("v.sortAsc", !component.get("v.sortAsc"));
        this.sortWeeks(component);

    },
    
    filterPlayWeeks : function (component, event, helper) {
        var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");
        var allWeeks= component.get("v.weeks_all");

        //Gather filter inputs
        var filters = {
            startDate : startDate,
            endDate : endDate,
            week : component.find('weeks-select').get('v.value')
        }
        //console.log('Filters: ' + JSON.stringify(filters));
        
        var result_pws = allWeeks;
        
        // 1st Filter by date range
        if (filters.startDate != null && filters.startDate != undefined && filters.startDate != "" &&
            filters.endDate != null && filters.endDate != undefined && filters.endDate != "") {
            result_pws = result_pws.filter(obj => (Date.parse(obj.Week_Date__c) >= Date.parse(filters.startDate) && Date.parse(obj.Week_Date__c) <= Date.parse(filters.endDate)));
        }
        else if (filters.startDate != null && filters.startDate != undefined && filters.startDate != "") {
            result_pws = result_pws.filter(obj => Date.parse(obj.Week_Date__c) >= Date.parse(filters.startDate));
        }
        else if (filters.endDate != null && filters.endDate != undefined && filters.endDate != "") {
        	 result_pws = result_pws.filter(obj => Date.parse(obj.Week_Date__c) <= Date.parse(filters.endDate));
        }
        
        //2nd - filter by selected week
        if (filters.week != null && filters.week != undefined && filters.week != "") {
            result_pws = result_pws.filter(obj => obj.Week_Date__c === filters.week);
        }
        //console.log('Result pws: ' + JSON.stringify(result_pws));
        component.set("v.weeks", result_pws);
        this.prepWeekDates(component, result_pws);
    },
})