({
    doInit: function (component, event, helper) {

        component.set("v.showFilter", false); // prime the default

        var appSettings = component.get("v.appSettings");
        var getAppSettingsAction = component.get("c.getApplicationSettings");
        getAppSettingsAction.setCallback(this, function(response){
            var state=response.getState()
            if(state==='SUCCESS'){
                var data = response.getReturnValue();
                component.set("v.appSettings", data);
                //Create Dates
                var now = new Date();
                var startDate = now.toLocaleDateString("en-US");
                console.log('Start Date: ' + startDate);
                component.set("v.startDate", startDate);
                if (data.Market_Capacity_Week_Range__c != null) {
                    now.setDate(now.getDate() + (7 * data.Market_Capacity_Week_Range__c));
                	var endDate = now.toLocaleDateString("en-US");
                	console.log('End Date: ' + endDate);
                	component.set("v.endDate", endDate); 
                }
                else {
                    component.set("v.endDate", '');
                }
                
                
            } else {
                
            }
        });
        $A.enqueueAction(getAppSettingsAction);
        
        var getAllWeeksAction = component.get("c.getWeeksAll");
        getAllWeeksAction.setCallback(this, function (getAllWeeksResponse) {
            var state = getAllWeeksResponse.getState()
            if (state === 'SUCCESS') {
                var data = getAllWeeksResponse.getReturnValue();
                console.log(data);
                component.set("v.weeks_all", data);
                var startDate = component.get("v.startDate");
                //var endDate = component.get("v.endDate");
                var result_pws = data;
                result_pws = result_pws.filter(obj => (Date.parse(obj.Week_Date__c) > Date.parse(startDate) /*&& Date.parse(obj.Week_Date__c) < Date.parse(endDate)*/));
                component.set("v.weeks", result_pws);

				helper.prepWeekDates(component, data);
            } else {
				
            }
        });
        $A.enqueueAction(getAllWeeksAction);

    },
    
    weekClick: function(component, event, helper) {
        var weekId = event.getSource().get("v.value");
        var currentWeek = component.get("v.selectedWeek");
        component.set("v.selectedWeek", (currentWeek != weekId) ? weekId : null);
        helper.getPlayWeeks(component);
    },

    sortClick: function (component, event, helper) {

        var sortFieldClicked = event.getSource().get("v.value");
        var sortField = component.get("v.sortField");
        var sortAsc = component.get("v.sortAsc");

        console.log('sortFieldClicked: ' + sortFieldClicked);
        console.log('sortField: ' + sortField);
        console.log('sortAsc: ' + sortAsc);

        if (sortFieldClicked == sortField) {
            helper.toggleSortOrder(component);
        } else {
            component.set("v.sortField", sortFieldClicked);
            helper.sortWeeks(component);
        }
    },
    
    filterPlayWeeks : function(component, event, helper) {
        helper.filterPlayWeeks(component, event, helper);
    },
    
    clearFilters : function(component, event, helper) {
        var allWeeks = component.get('v.weeks_all');
        component.set("v.startDate", '');
        component.set("v.endDate", '');
        component.find('weeks-select').set("v.value", '');
        component.set("v.weeks", allWeeks);
    },
    
    downloadMarketCapacityCSV : function (component, event, helper) {
        var weeks = component.get("v.weeks");
        
        var csvString = '';
        //Create Headers for Market Capacity CSV
        csvString += 'Date,'; //First Column: Week_Date__c
        csvString += 'Occupied $s,'; //Second Column: Occupied_dollars__c
        csvString += 'Max Market Capacity,'; //Third Column: Max_Market_Capacity__c
        csvString += 'Max Available $s,'; //Fourth Column: Max_Available_dollars__c
        csvString += 'Avg Market Capacity,'; //Fifth Column: Average_Market_Capacity__c
        csvString += 'Avg Available $s,'; //Sixth Column: Average_Available_dollars__c
        csvString += 'Min Market Capacity,'; //Seventh Column: Min_Market_Capacity__c
        csvString += 'Min Available $s,\r\n'; //Eighth Column: Min_Available_dollars__c
        
        //Iterate through Market Capacity Weeks and populate CSV Rows
        for(var itr = 0; itr < weeks.length; itr++) {

            csvString += (weeks[itr].Week_Date__c != null) ? (String(weeks[itr].Week_Date__c) + ',') : ',';
            csvString += (weeks[itr].Occupied_dollar__c != null) ? (String(weeks[itr].Occupied_dollar__c) + ',') : ',';
            csvString += (weeks[itr].Max_Market_Capacity__c != null) ? (String(weeks[itr].Max_Market_Capacity__c) + ',') : ',';
            csvString += (weeks[itr].Max_Available_dollars__c != null) ? (String(weeks[itr].Max_Available_dollars__c) + ',') : ',';
            csvString += (weeks[itr].Average_Market_Capacity__c != null) ? (String(weeks[itr].Average_Market_Capacity__c) + ',') : ',';
            csvString += (weeks[itr].Average_Available_dollars__c != null) ? (String(weeks[itr].Average_Available_dollars__c) + ',') : ',';
            csvString += (weeks[itr].Min_Market_Capacity__c != null) ? (String(weeks[itr].Min_Market_Capacity__c) + ',') : ',';
            csvString += (weeks[itr].Min_Available_dollars__c != null) ? (String(weeks[itr].Min_Available_dollars__c) + ',\r\n') : ',\r\n';
            
        }
        csvString = csvString.substring(0, csvString.length - 2); //Remove final new line
        
        console.log(csvString);

        var link = document.createElement("a");
        link.href = "data:text/csv;charset=utf-8,"+csvString;
        link.download = "MarketCapacityWeeks.csv";
        link.click();
    },

    downloadMCPlayWeekCSV : function(component, event, helper) {
        var selectedWeek = component.get("v.selectedWeek");
        var weeks = component.get("v.selectedWeekDetail.titlePlayWeeks");
        
        //Get MC for selected week
        var mcWeeks = component.get("v.weeks");
        var mcWeek;
        for(var itr = 0; itr < mcWeeks.length; itr++) {
            if(mcWeeks[itr].Week_Date__c == selectedWeek) {
                mcWeek = mcWeeks[itr];
            }
        }
        
        var csvString = '';
        //Populate csv string with hard-coded headers
        csvString += 'Rank,'; //1st Column: Iterated value starting at 1
        csvString += 'Title,'; //2nd Column: Title__r.Name
        csvString += 'Play Week,'; //3rd Column: Play_Week__c
        csvString += 'Source,'; //4th Column: Source__c
        csvString += 'Distributor,'; //5th Column: Title__r.Distributor__c
        csvString += 'Rating,'; //6th Column: Title__r.Rating__c
        csvString += 'Weekend BO (FSS),'; //7th Column: Weekend_BO__c
        csvString += 'Weekend BO Drop %,'; //8th Column: Weekend_Drop__c
        csvString += 'Mid-Week BO (MTWR),'; //9th Column: Midweek_BO__c
        csvString += 'Mid-Week BO As % of Weekend BO,'; //10th Column: (Midweek_BO__c / Weekend_BO__c)
        csvString += 'Total Week BO,'; //11th Column: Total_BO_formula__c
        csvString += 'Total Week BO Drop %,'; //12th Column: TST_Total_Week_BO_Drop__c / 100
        csvString += 'Total Cumulative BO,'; //13th Column: Cumulative__c
        csvString += 'Locked/Unlocked,'; //14th Column: Title__r.Lock_Title__c
        csvString += 'Last Edited By,'; //15th Column: LastModifiedBy.Name
        
        //add headers for Market Capacity Data
        csvString += 'Date,'; //Fifteenth Column: Week_Date__c
        csvString += 'Occupied $s,'; //16th Column: Occupied_dollars__c
        csvString += 'Max Market Capacity,'; //17th Column: Max_Market_Capacity__c
        csvString += 'Max Available $s,'; //18th Column: Max_Available_dollars__c
        csvString += 'Avg Market Capacity,'; //19th Column: Average_Market_Capacity__c
        csvString += 'Avg Available $s,'; //20th Column: Average_Available_dollars__c
        csvString += 'Min Market Capacity,'; //21st Column: Min_Market_Capacity__c
        csvString += 'Min Available $s,\r\n'; //22nd Column: Min_Available_dollars__c
        
        //Iterate through Market Capacity Play Weeks and populate CSV Rows
        for(var itr = 0; itr < weeks.length; itr++) {
            var pwTitle = weeks[itr].Title__r.Name;
            if( pwTitle.includes(",") && !pwTitle.includes("\"")) {
                //add quotations to Title if it contains a comma
                pwTitle = '"' + pwTitle + '"';
            }
            csvString += (String(itr + 1) + ',');
            csvString += (pwTitle + ',');
            csvString += (weeks[itr].Play_Week__c != null) ? (String(weeks[itr].Play_Week__c) + ',') : ',';
            csvString += (weeks[itr].Source__c != null) ? (weeks[itr].Source__c + ',') : ',';
            csvString += (weeks[itr].Title__r.Distributor__c != null) ? (weeks[itr].Title__r.Distributor__c + ',') : ',';
            csvString += (weeks[itr].Title__r.Rating__c != null) ? (weeks[itr].Title__r.Rating__c + ',') : ',';
            csvString += (weeks[itr].Weekend_BO__c != null) ? ('$' + String(weeks[itr].Weekend_BO__c) + ',') : '$0.00,';
            csvString += (weeks[itr].Weekend_Drop__c != null) ? (String(weeks[itr].Weekend_Drop__c) + '%,') : ',';
            csvString += (weeks[itr].Midweek_BO__c != null) ? ('$' + String(weeks[itr].Midweek_BO__c) + ',') : '$0.00,';
            csvString += (weeks[itr].Midweek_BO__c != null && weeks[itr].Weekend_BO__c != null) ? (String((weeks[itr].Midweek_BO__c / weeks[itr].Weekend_BO__c)) + '%,') : ',';
            csvString += ('$' + String(weeks[itr].Total_BO_formula__c) + ',');
            csvString += (weeks[itr].TST_Total_Week_BO_Drop__c != 0) ? (String(weeks[itr].TST_Total_Week_BO_Drop__c / 100) + '%,') : ',';
            csvString += (weeks[itr].Cumulative__c != null) ? ('$' + String(weeks[itr].Cumulative__c) + ',') : ',';
            csvString += (weeks[itr].Title__r.Lock_Title__c) ? ('Locked,') : 'Unlocked,';
            csvString += (weeks[itr].LastModifiedBy.Name + ',\r\n');
            if(itr == 0) {
                csvString = csvString.substring(0, csvString.length-2);//remove newline
                //Add data for related Market Capacity data
                csvString += (mcWeek.Week_Date__c != null) ? (String(mcWeek.Week_Date__c) + ',') : ',';
                csvString += (mcWeek.Occupied_dollar__c != null) ? (String(mcWeek.Occupied_dollar__c) + ',') : ',';
                csvString += (mcWeek.Max_Market_Capacity__c != null) ? (String(mcWeek.Max_Market_Capacity__c) + ',') : ',';
                csvString += (mcWeek.Max_Available_dollars__c != null) ? (String(mcWeek.Max_Available_dollars__c) + ',') : ',';
                csvString += (mcWeek.Average_Market_Capacity__c != null) ? (String(mcWeek.Average_Market_Capacity__c) + ',') : ',';
                csvString += (mcWeek.Average_Available_dollars__c != null) ? (String(mcWeek.Average_Available_dollars__c) + ',') : ',';
                csvString += (mcWeek.Min_Market_Capacity__c != null) ? (String(mcWeek.Min_Market_Capacity__c) + ',') : ',';
                csvString += (mcWeek.Min_Available_dollars__c != null) ? (String(mcWeek.Min_Available_dollars__c) + ',\r\n') : ',\r\n';
                 
            }
        }
        csvString = csvString.substring(0, csvString.length-2); //Remove final new line
        
        console.log(csvString);

        var link = document.createElement("a");
        link.href = "data:text/csv;charset=utf-8,"+csvString;
        link.download = selectedWeek +"_PlayWeeks.csv";
        link.click();
    },

})