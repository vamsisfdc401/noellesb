({
    doInit : function(component, event, helper){
        //var action = component.get("c.doConstructor");
        //$A.enqueueAction(action); 
        
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
})