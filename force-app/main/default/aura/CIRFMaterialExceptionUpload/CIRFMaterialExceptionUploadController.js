({
    doInit : function(component, event, helper){
        
    },
    
    processCSV : function(component, event, helper) {
        document.getElementById("Waitspinner").style.display = "block";
        console.log(component.get("v.fileName"));
        if (component.find("fileId").get("v.files") != null && component.find("fileId").get("v.files").length > 0) {
            helper.UploadCSV(component,event,helper);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message!',
                message: 'Please select a file',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
    },
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    
    
    salarypageCall: function(component, event, helper) {
        //var myId = event.getSource().get('v.name');
        var vfUrl = 'https://uphe--CIRF.cs7.my.salesforce.com/sfc/p/M0000000FqCz/a/M000000001po/6TwDq1YEGZqaanpogE5ig1VVPmC6jUGW7q67yv6OHM0';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": vfUrl
        });
        urlEvent.fire();
        
    },
    
    cancel : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    downloadTemplate : function(component,event,helper){
        helper.callServer(component,"c.getCIRFMaterialExceptionTemplate",function(response){
            var hiddenElement = document.createElement('a');
            hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(response);
            hiddenElement.target = '_self'; // 
            hiddenElement.download = 'CIRF Material Exceptions Upload Template.csv';  // CSV file Name* you can change it.[only name not .csv] 
            document.body.appendChild(hiddenElement); // Required for FireFox browser
            hiddenElement.click(); 
        },{
            
        });
    }
    
    //
})