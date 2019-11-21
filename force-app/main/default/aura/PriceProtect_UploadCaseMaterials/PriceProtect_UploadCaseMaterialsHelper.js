({
    UploadCSV : function(component,event,helper) {
        console.log(component.get("v.fileName"));
        var fileInput = component.find("fileId").get("v.files");
        var file = fileInput[0];
        
        var reader = new FileReader();
        var self = this;
        reader.onload = function () {
            var action = component.get("c.UploadPPCaseMaterials");
            action.setParams({ uploadedFile : encodeURIComponent(reader.result),
                              HeaderId : component.get("v.recordId"),
                              LoadViaUI: true
                             } );
            action.setCallback(self, function(actionResult) {
                console.log((actionResult.getReturnValue()));
                if(actionResult.getReturnValue() == 'null' || actionResult.getReturnValue() == null || actionResult.getReturnValue() == ''){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                    	title : 'Success',
                        message: 'You did it! Successful upload!',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    //alert('Success!');
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'Errors during upload. Please see error file. All others materials uploaded successfully.',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    
                    toastEvent.fire();
                    var hiddenElement = document.createElement('a');
                    hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(actionResult.getReturnValue());
                    hiddenElement.target = '_self'; // 
                    hiddenElement.download = 'ErrorFile.csv';  // CSV file Name* you can change it.[only name not .csv] 
                    document.body.appendChild(hiddenElement); // Required for FireFox browser
                    hiddenElement.click(); 
                    

                }
                     $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            });
            $A.enqueueAction(action);
        };
        reader.readAsText(file,"UTF-8");
       
    },
    
    
})