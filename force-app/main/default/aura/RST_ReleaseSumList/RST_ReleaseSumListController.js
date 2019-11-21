({
    doInit: function (component, event, helper) {

        //var useToday = new Date().toISOString().split('T')[0];
        //component.set("v.useToday", useToday);
        //console.log(useToday);
        component.set("v.showFilter", false); // prime the default
        

        var action = component.get("c.getTitles");
        action.setCallback(this, function (response) {
            var state = response.getState()
            if (state === 'SUCCESS') {
                var data = response.getReturnValue();
                console.log(data);
                component.set("v.titles_all", data);
                component.set("v.titles", data);

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
        //console.log('clicked ' + titleId);
        var useTitle = (currentTitle && titleId == currentTitle.Id) ? null : titleId;
        var selectedTitle = titles.find(obj => obj.Id === useTitle);
        component.set("v.selectedTitle", selectedTitle);
        console.log(selectedTitle);
        if (selectedTitle) helper.getTitlesNestedPlayWeeks(component); // if not null, go get titles
        //console.log('set ' + useTitle);
    },
    titleLockClick : function(component, event, helper){
        component.set("v.showSpinner", true);
        var isLocked = event.getSource().get("v.checked");
        console.log(isLocked);
        helper.setTitleLocked(component, isLocked);
    },
    sortClick: function (component, event, helper) {
        component.set("v.showSpinner", true);

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
            helper.sortTitles(component);
        }
    },
    itemsChange: function (component, event, helper) {
        console.log("titles has changed");
        console.log("old value: " + event.getParam("oldValue"));
        console.log("current value: " + event.getParam("value"));
    },
    saveTitleClicked: function (component, event, helper) {
        helper.saveTitleInfo(component);
    },
    handleKeyUp: function (component, event) {
        var isEnterKey = event.keyCode === 13;
        //console.log(event.keyCode);
        if (isEnterKey) {
            var queryTerm = component.find('title-search').get('v.value');
            var titles = component.get("v.titles"); // viewable titles
            //var titles_all = component.get("v.titles_all"); // entire result set
            var result_titles = titles.filter(obj => obj.Name.toLowerCase().includes(queryTerm.toLowerCase()));
            console.log(result_titles);
            if (result_titles) {
                component.set("v.titles", result_titles);
            } else {
                alert('no matching titles found');
            }

        }
    },
    weeksChange: function (component, event, helper) {
        var week_selected = component.find('weeks-select').get('v.value');
        var titles = component.get("v.titles_all"); 
        //alert(component.find('weeks-select').get('v.value'));
        if (week_selected) {


            //var titles = component.get("v.titles_all"); // viewable titles
            var result_titles = titles.filter(obj => obj.Wide_Release_Date__c === week_selected);
            console.log(result_titles);
            if (result_titles) {
                component.set("v.titles", result_titles);
            }
        } else {
            component.set("v.titles", titles);
        }
    },
    distsChange: function (component, event, helper) {
        //alert(component.find('dists-select').get('v.value'));
        var dist_selected = component.find('dists-select').get('v.value');
        var titles = component.get("v.titles_all"); 

        if (dist_selected) {
            var result_titles = titles.filter(obj => obj.Distributor__c === dist_selected);
            if (result_titles) {
                component.set("v.titles", result_titles);
            }
        } else {
            component.set("v.titles", titles);
        }


    },
    fsoGenreChange: function (component, event, helper) {
        //alert(component.find('fso-genre-select').get('v.value'));
        var fso_selected = component.find('fso-genre-select').get('v.value');
        var titles = component.get("v.titles_all"); 

        if (fso_selected) {
            var result_titles = titles.filter(obj => obj.FS_O_Genre__c === fso_selected);
            if (result_titles) {
                component.set("v.titles", result_titles);
            }
        } else {
            component.set("v.titles", titles);
        }
    },
    renGenreChange: function (component, event, helper) {
        //alert(component.find('ren-genre-select').get('v.value'));
        var ren_selected = component.find('ren-genre-select').get('v.value');
        var titles = component.get("v.titles_all"); 

        if (ren_selected) {
            var result_titles = titles.filter(obj => obj.FS_O_Genre__c === ren_selected);
            if (result_titles) {
                component.set("v.titles", result_titles);
            }
        } else {
            component.set("v.titles", titles);
        }
    },
    
    enterKeyCheck : function (component, event, helper) {
        if (event.which == 13) {
            helper.filterTitles(component, event, helper);
        }
    },
    
    filterTitles : function (component, event, helper) {
        helper.filterTitles(component, event, helper);
    },
    
    downloadTitlesCSV : function (component, event, helper) {
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
        csvHeaders += 'Last Modified By,\r\n'; //Eighth Column: LastModifiedBy.Name
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
            csvString += (titles[itr].LastModifiedBy.Name + ',\r\n');
            
        }
        csvString = csvString.substring(0, csvString.length-4); //Remove final new line
        
        console.log('Titles.CSV Rows: ' + csvString);

        var csv = csvHeaders + csvString;
        
        var link = document.createElement("a");
        link.href = "data:text/csv;charset=utf-8,"+csv;
        link.download = "Titles.csv";
        link.click();
    },

    downloadTitlePlayWeeksCSV : function(component, event, helper) {
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
        csvHeaders += 'Growth %,'; //Twelfth Column: Total_BO_formula__c
        csvHeaders += 'Last Modified By,\r\n'; //Thirteenth Column: LastModifiedBy.Name
        console.log('PlayWeeks.CSV Headers: ' + csvHeaders);
        
        var csvRows = '';
        //Iterate through Title Play Weeks and populate CSV Rows
        var runningTotal = 0.0;
        var pwTitle = '';
        for(var itr = 0; itr < playWeeks.length; itr++) {
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
            csvRows += (playWeeks[itr].MidWeek_Drop__c != null) ? (String(playWeeks[itr].MidWeek_Drop__c) + '%,') : ',';
            csvRows += ('$' + String(playWeeks[itr].Total_BO_formula__c) + ',');
            csvRows += (playWeeks[itr].TST_Total_Week_BO_Drop__c != 0) ? (String(playWeeks[itr].TST_Total_Week_BO_Drop__c / 100) + '%,') : ',';
            csvRows += ('$' + String(runningTotal) + ',');
            csvRows += (String( ( (parseFloat(playWeeks[itr].Weekend_BO__c) + parseFloat(playWeeks[itr].Midweek_BO__c)) / parseFloat(runningTotal)) * 100) + '%,');
            csvRows += (playWeeks[itr].LastModifiedBy.Name + ',\r\n');
            
        }
        csvRows = csvRows.substring(0, csvRows.length-4); //Remove final new line
        
        console.log('PlayWeek.CSV Rows: ' + csvRows);
        
        var csv = csvHeaders + csvRows;

        var link = document.createElement("a");
        link.href = "data:text/csv;charset=utf-8,"+csv;
        link.download = pwTitle + "_PlayWeeks.csv";
        link.click();
    },


})