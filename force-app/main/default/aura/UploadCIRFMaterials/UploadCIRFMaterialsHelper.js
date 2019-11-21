({
    UploadCSV : function(component,event,helper) {
         var recid = component.get("v.recordId");
        console.log(component.get("v.fileName"));
        var fileInput = component.find("fileId").get("v.files");
        var file = fileInput[0];
        
        var reader = new FileReader();
        var self = this;
        reader.onload = function () {
            var action = component.get("c.UploadCIRFMaterials");
            action.setParams({ uploadedFile : encodeURIComponent(reader.result),
                              HeaderId : component.get("v.recordId")
                             } );
            action.setCallback(self, function(actionResult) {
                console.log((actionResult.getReturnValue()));
                if(actionResult.getReturnValue() == 'null' || actionResult.getReturnValue() == null || actionResult.getReturnValue() == ''){
                    //alert('success');
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
                    if(actionResult.getReturnValue() == 'blank'){
                        //alert('blank');
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
                        //alert('error');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Errors found. Please see error file. All others uploaded successfully.',
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
                    
                }
                $A.get("e.force:closeQuickAction").fire();
                
                


           $A.get('e.force:refreshView').fire();
                self.subTab(component,event,self);
                
            });
            $A.enqueueAction(action);
            
        };
        reader.readAsText(file,"UTF-8");
    },
     subTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
         
        var recordId = component.get("v.recordId");
        workspaceAPI.openTab({
            url: '/lightning/r/CIRF_Header__c/'+recordId+'/view',
            focus: true
        }).then(function(response) {
            workspaceAPI.openSubtab({tabId : response,
                     // url: '/lightning/r/CIRF_Material__c/a3OM0000000Q5gWMAS/view',
             focus: true
            
                                   });
       })
        .catch(function(error) {
            console.log(error);
        });
    }
    
    
    
})