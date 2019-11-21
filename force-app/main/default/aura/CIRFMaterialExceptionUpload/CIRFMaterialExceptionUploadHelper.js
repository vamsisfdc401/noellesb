({
    UploadCSV : function(component,event,helper) {
        var fileInput = component.find("fileId").get("v.files");
        var file = fileInput[0];
        
        var reader = new FileReader();
        var self = this;
        reader.onload = function () {
            
            self.callServer(component,"c.CIRFMaterialExceptionsUploadMethod",function(response){
                console.log(response);
                if(response == 'null' || response == null || response == ''){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'You did it! Successful upload!',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                else{
                    if(response == 'blank'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'You uploaded a blank template. Please review your file and re-upload with the appropriate details',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                    }
                    
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Errors found. Please see error file. All others uploaded successfully.',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        
                        toastEvent.fire();
                        var hiddenElement = document.createElement('a');
                        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(response);
                        hiddenElement.target = '_self'; // 
                        hiddenElement.download = 'ErrorFile.csv';  // CSV file Name* you can change it.[only name not .csv] 
                        document.body.appendChild(hiddenElement); // Required for FireFox browser
                        hiddenElement.click(); 
                        
                    }
                }
                
               
                
                $A.get("e.force:closeQuickAction").fire();
                
                $A.get('e.force:refreshView').fire();
                
            },{
                uploadedFile : encodeURIComponent(reader.result)
            });
        };
        
        reader.readAsText(file,"UTF-8");
    },
    
    
})