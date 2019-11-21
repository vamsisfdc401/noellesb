({
    doInit: function (component, event, helper) {

        component.set("v.showFilter", false); // prime the default
        var appSettings = component.get("v.appSettings");
        var getAppSettingsAction = component.get("c.getApplicationSettings");
        getAppSettingsAction.setCallback(this, function(response){
            var state=response.getState();
            if(state==='SUCCESS'){
                var data = response.getReturnValue();
                console.log(data);
                component.set("v.appSettings", data);
                //Create Dates
                var now = new Date();
                if (data.Weeks_Before_Title_Start_Date__c != null) {
                	now.setDate(now.getDate() - (data.Weeks_Before_Title_Start_Date__c * 7));
                }
                var startDate = now.toLocaleDateString("en-US");
                
                component.set("v.startDate", startDate);
                if (data.Title_Week_Range__c != null) {
                    now.setDate(now.getDate() + (7 * data.Title_Week_Range__c));
                	var endDate = now.toLocaleDateString("en-US");
                	component.set("v.endDate", endDate);
                }
                else {
                    component.set("v.endDate", '');
                }
                
                
            } else {
                
            }
        });
        $A.enqueueAction(getAppSettingsAction);
		
        //get all titles and get titles within date range
        var action = component.get("c.getTitlesAll");
        action.setCallback(this, function (response) {
            var state = response.getState()
            if (state === 'SUCCESS') {
                var data = response.getReturnValue();
                helper.resetTitles(component, data);

                helper.prepPageOptions(component, data);

            } else {

            }
        });
        $A.enqueueAction(action);
    },
    
    toggleFilter : function(component, event, helper) {
        component.set("v.showFilter", !(component.get("v.showFilter")));
    },
    
    titleClick: function (component, event, helper) {
        var titleId = event.getSource().get("v.value");
        var currentTitle = component.get("v.selectedTitle");
        var titles = component.get("v.titles");
        var useTitle = (currentTitle && titleId == currentTitle.Id) ? null : titleId;
        var selectedTitle = titles.find(obj => obj.Id === useTitle);
        if (selectedTitle) {
            component.set('v.selectedTitleLoaded', false);
            helper.getTitlesNestedPlayWeeks(component, selectedTitle.Id); // if not null, go get titles
        }
        component.set("v.selectedTitle", selectedTitle);
    },
    
    titleLockClick : function(component, event, helper){
        component.set("v.showSpinner", true);
        var isLocked = event.getSource().get("v.checked");
        helper.setTitleLocked(component, isLocked);
    },
    
    sortClick: function (component, event, helper) {
        component.set("v.showSpinner", true);

        var sortFieldClicked = event.getSource().get("v.value");
        var sortField = component.get("v.sortField");
        var sortAsc = component.get("v.sortAsc");
        /*
        console.log('sortFieldClicked: ' + sortFieldClicked);
        console.log('sortField: ' + sortField);
        console.log('sortAsc: ' + sortAsc);
		*/
        if (sortFieldClicked == sortField) {
            helper.toggleSortOrder(component);
        } else {
            component.set("v.sortField", sortFieldClicked);
            helper.sortTitles(component);
        }
    },
    /*
    itemsChange: function (component, event, helper) {
        console.log("titles has changed");
        console.log("old value: " + event.getParam("oldValue"));
        console.log("current value: " + event.getParam("value"));
    },
    */
    saveTitleClicked: function (component, event, helper) {
        helper.saveTitleInfo(component);
    },

    enterKeyCheck : function (component, event, helper) {
        if (event.which == 13) { //enter key pressed
            helper.filterTitles(component, event, helper);
        }
    },
    
    filterTitles : function (component, event, helper) {
        helper.filterTitles(component, event, helper);
    },
    
    clearFilters : function(component, event, helper) {
        var showFilter = component.get("v.showFilter");
        //component.set("v.titles", component.get("v.titles_all"));
        if (showFilter) {
            component.find('title-search').set('v.value', '');
            component.find('weeks-select').set('v.value', '');
            component.find('dists-select').set('v.value', '');
            component.find('fso-genre-select').set('v.value', '');
            component.find('ren-genre-select').set('v.value', '');
        }
        
        helper.resetTitles(component, component.get("v.titles_all"));
        helper.prepPageOptions(component, component.get("v.titles_all"));
        //component.set("v.startDate", '');
        //component.set("v.endDate", '');
    },

    downloadTitlesCSV : function (component, event, helper) {
        function formatDate(date) {
          var hours = date.getHours();
          var minutes = date.getMinutes();
          var ampm = hours >= 12 ? 'pm' : 'am';
          hours = hours % 12;
          hours = hours ? hours : 12; // the hour '0' should be '12'
          minutes = minutes < 10 ? '0'+minutes : minutes;
          var strTime = hours + ':' + minutes + ' ' + ampm;
          return date.getMonth()+1 + "/" + date.getDate() + "/" + date.getFullYear() + "  " + strTime;
        }
        
        var titles = component.get("v.titles");
        console.log('Titles: ' +JSON.stringify(titles));
        console.log('Titles size: ' + titles.length);
        var csvHeaders = '';

        //Populate csv string with hard-coded headers
        csvHeaders += 'Wide Release Date,'; //First Column: Wide_Release_Date__c
        csvHeaders += 'Title Name,'; //Second Column: Name
        csvHeaders += 'Distributor,'; //Third Column: Distributor__c
        csvHeaders += 'RenTrak Genre,'; //Fourth Column: RenTrak_Genre__c
        csvHeaders += 'FS&O Genre,'; //Fifth Column: FS_O_Genre__c
        csvHeaders += 'Wide Opening Weekend,'; //Sixth Column: Wide_Opening_Weekend__c
        csvHeaders += 'Total Cumulative BO,'; //Seventh Column: Total_Cumulative_BO__c
        csvHeaders += 'Multiple,'; //Sixth Column: Multiple__c
        csvHeaders += 'Title Locked/Unlocked,'; //Seventh Column: Lock_Title__c
        csvHeaders += 'Last Edited By,\r\n'; //Eighth Column: LastModifiedBy.Name
        console.log('Titles.CSV Headers: ' + csvHeaders);
        
        var csvString = '';
        //Iterate through Titles and populate CSV Rows
        for(var itr = 0; itr < titles.length; itr++) {
			var tName = titles[itr].Name;
            if(tName.includes(",") && !tName.includes("\"")) {
                //add quotations to Title if it contains a comma
                tName = '"' + tName + '"';
            }
            csvString += (titles[itr].Wide_Release_Date__c != null) ? (String(titles[itr].Wide_Release_Date__c) + ',') : ',';
            csvString += (tName + ',');
            csvString += (titles[itr].Distributor__c != null) ? (titles[itr].Distributor__c + ',') : ',';
            csvString += (titles[itr].RenTrak_Genre__c != null) ? (titles[itr].RenTrak_Genre__c + ',') : ',';
            csvString += (titles[itr].FS_O_Genre__c != null) ? (titles[itr].FS_O_Genre__c + ',') : ',';
            csvString += (titles[itr].Wide_Opening_Weekend__c != null) ? ('$' + String(titles[itr].Wide_Opening_Weekend__c) + ',') : ',';
            csvString += (titles[itr].Total_Cumulative_BO__c != null) ? ('$' + String(titles[itr].Total_Cumulative_BO__c) + ',') : ',';
            csvString += (titles[itr].Multiple__c != null) ? (String(titles[itr].Multiple__c) + ',') : ',';
            csvString += (titles[itr].Lock_Title__c) ? 'Locked,': 'Unlocked,';
            var lmd = new Date(titles[itr].LastModifiedDate);
            csvString += (titles[itr].LastModifiedBy.Name + /*' - ' + String(formatDate(lmd)) +*/ ',\r\n');
            
        }
        csvString = csvString.substring(0, csvString.length-2); //Remove final new line
        
        console.log('Titles.CSV Rows: ' + csvString);

        var csv = csvHeaders + csvString;
        
        var link = document.createElement("a");
        link.href = "data:text/csv;charset=utf-8,"+csv;
        link.download = "Titles.csv";
        link.click();
    },

    downloadTitlePlayWeeksCSV : function(component, event, helper) {
        function formatDate(date) {
          var hours = date.getHours();
          var minutes = date.getMinutes();
          var ampm = hours >= 12 ? 'pm' : 'am';
          hours = hours % 12;
          hours = hours ? hours : 12; // the hour '0' should be '12'
          minutes = minutes < 10 ? '0'+minutes : minutes;
          var strTime = hours + ':' + minutes + ' ' + ampm;
          return date.getMonth()+1 + "/" + date.getDate() + "/" + date.getFullYear() + "  " + strTime;
        }
        
        var rootPlayWeek = component.get("v.selectedTitlePW");
        var playWeeks = [];
        while (rootPlayWeek.child != null){
            playWeeks.push(rootPlayWeek.pw);
            rootPlayWeek = rootPlayWeek.child;
        } 
        //add final play week
        if (rootPlayWeek.pw != null) playWeeks.push(rootPlayWeek.pw);
        console.log('PlayWeeks size: ' + playWeeks.length);

        var csvHeaders = '';
        var csvRows = '';
        
        //Populate csv string with hard-coded headers
        csvHeaders += 'Title,'; //First Column: Title__r.Name
        csvHeaders += '#,'; //Second Column: Play_Week__c
        csvHeaders += 'Date,'; //Third Column: Week_Date__c
        csvHeaders += 'Source,'; //Fourth Column: Source__c
        csvHeaders += 'Weekend BO,'; //Fifth Column: Weekend_BO__c
        csvHeaders += 'Weekend Drop %,'; //Sixth Column: Weekend_Drop__c
        csvHeaders += 'Mid-Week BO,'; //Seventh Column: Midweek_BO__c
        csvHeaders += 'Mid-Week Drop %,'; //Eighth Column: MidWeek_Drop__c
        csvHeaders += 'Total BO,'; //Ninth Column: Total_BO_formula__c
        csvHeaders += 'Total BO Drop %,'; //Tenth Column: TST_Total_Week_BO_Drop__c / 100
        csvHeaders += 'Cumulative BO,'; //Eleventh Column: Cumulative__c
        //csvHeaders += 'Growth %,'; //Twelfth Column: Total_BO_formula__c
        csvHeaders += 'Last Edited By,\r\n'; //Thirteenth Column: LastModifiedBy.Name
        console.log('PlayWeeks.CSV Headers: ' + csvHeaders);
        
        var csvRows = '';
        //Iterate through Title Play Weeks and populate CSV Rows
        var runningTotal = 0.0;
        var pwTitle = '';
        for(var itr = 0; itr < playWeeks.length; itr++) {
            console.log('Playweek:');
            console.log(playWeeks[itr]);
            runningTotal += parseFloat(playWeeks[itr].Weekend_BO__c) + parseFloat(playWeeks[itr].Midweek_BO__c);
            pwTitle = playWeeks[itr].Title__r.Name;
            if( pwTitle.includes(",") && !pwTitle.includes("\"")) {  
                //add quotations to Title if it contains a comma
                pwTitle = '"' + pwTitle + '"';
            }
            csvRows += (pwTitle + ',');
            csvRows += (playWeeks[itr].Play_Week__c != null) ? (String(playWeeks[itr].Play_Week__c) + ',') : ',';
            csvRows += (playWeeks[itr].Week_Date__c != null) ? (String(playWeeks[itr].Week_Date__c) + ',') : ',';
            csvRows += (playWeeks[itr].Source__c != null) ? (playWeeks[itr].Source__c + ',') : ',';
            csvRows += (playWeeks[itr].Weekend_BO__c != null) ? ('$' + String(playWeeks[itr].Weekend_BO__c) + ',') : '$0.00,';
            csvRows += (playWeeks[itr].Weekend_Drop__c != null) ? (String(playWeeks[itr].Weekend_Drop__c) + '%,') : ',';
            csvRows += (playWeeks[itr].Midweek_BO__c != null) ? ('$' + String(playWeeks[itr].Midweek_BO__c) + ',') : '$0.00,';
            csvRows += (playWeeks[itr].Midweek_Drop__c != null) ? (String(playWeeks[itr].Midweek_Drop__c) + '%,') : ',';
            csvRows += ('$' + String(playWeeks[itr].Total_BO_formula__c) + ',');
            csvRows += (playWeeks[itr].TST_Total_Week_BO_Drop__c != 0) ? (String(playWeeks[itr].TST_Total_Week_BO_Drop__c / 100) + '%,') : ',';
            csvRows += ('$' + String(runningTotal) + ',');
            //csvRows += (String( ( (parseFloat(playWeeks[itr].Weekend_BO__c) + parseFloat(playWeeks[itr].Midweek_BO__c)) / parseFloat(runningTotal)) * 100) + '%,');
            var lmd = new Date(playWeeks[itr].LastModifiedDate);
            csvRows += (playWeeks[itr].LastModifiedBy.Name + /*' - ' + String(formatDate(lmd)) +*/ ',\r\n');
            
        }
        csvRows = csvRows.substring(0, csvRows.length-2); //Remove final new line
        
        console.log('PlayWeek.CSV Rows: ' + csvRows);
        
        var csv = csvHeaders + csvRows;

        var link = document.createElement("a");
        link.href = "data:text/csv;charset=utf-8,"+csv;
        link.download = pwTitle + "_PlayWeeks.csv";
        link.click();
    },


})