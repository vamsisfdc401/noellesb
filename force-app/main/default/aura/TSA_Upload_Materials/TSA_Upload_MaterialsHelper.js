({
    UploadCSV : function(component,event,helper) {
        console.log(component.get("v.fileName"));
        var fileInput = component.find("fileId").get("v.files");
        var file = fileInput[0];
        
        var reader = new FileReader();
        var self = this;
        reader.onload = function () {
            var action = component.get("c.UploadMaterials");
            action.setParams({ uploadedFile : encodeURIComponent(reader.result),
                              HeaderId : component.get("v.recordId")
                             } );
           
            action.setCallback(self, function(actionResult) {
            console.log((actionResult.getReturnValue()));                               
            if(actionResult.getReturnValue() == 'null' || actionResult.getReturnValue() == null || actionResult.getReturnValue() == ''){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'File Loaded Succesfully',
                        type: 'success'
                    });
                    toastEvent.fire();
                }//end if
             else {
                    //alert(actionResult.getReturnValue());
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'Error(s) found in the uploaded file.  Please refer to the downloaded Error file for error details.',
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
                }//end else 
                
                $A.get("e.force:closeQuickAction").fire();
                
            });//end setCallBack function
            
            $A.enqueueAction(action);
            
        };//end reader function
        
        reader.readAsText(file,"UTF-8");
    
    },//end upload CSV function
     
    
})//end JS