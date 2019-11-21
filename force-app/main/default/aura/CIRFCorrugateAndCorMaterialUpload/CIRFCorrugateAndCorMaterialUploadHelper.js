({
    UploadCSV : function(component,event,helper) {
         var recid = component.get("v.recordId");
        var fileInput = component.find("fileId").get("v.files");
        var file = fileInput[0];
        
        var reader = new FileReader();
        var self = this;
        reader.onload = function () {
            
            self.callServer(component,"c.CIRFCorrugateUpload",function(response){
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
                uploadedFile : encodeURIComponent(reader.result),
                HeaderId : component.get("v.recordId")
            })
            
            
                var relListEvent = $A.get("e.force:navigateToURL");
               //relatedListId- The API name of the related list to display, 
                  relListEvent.setParams({
                     
                   "url": 'https://uphe--cirf.lightning.force.com/lightning/r/'+recid+'/related/CIRF_Corrugates__r/view' ,
                   "isredirect":true 

                   });
                //$A.get("e.force:closeQuickAction").fire();
              // relListEvent.fire();
             
        };
        
        reader.readAsText(file,"UTF-8");
    },
    
    
})