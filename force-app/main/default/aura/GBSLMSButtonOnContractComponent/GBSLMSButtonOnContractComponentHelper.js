({
    //saveLMS method will save the LMS record with the provided inputs onclick of Save button
    saveLMS : function (component){
        var distributingCompany = component.find('distributingCompany').get('v.value');
        var primaryFactory = component.find('primaryFactory').get('v.value');        
        var tradeOffice = component.find('tradeOffice').get('v.value');
        var factory = component.find('factory').get('v.value');
        var notes = component.find('notes').get('v.value');
        var contract = component.get('v.recordId');
        var newLMS = [];
        newLMS.push({            
            Factory__c : factory,
            Notes__c : notes,
            Trade_Office__c : tradeOffice,
            Primary_Factory__c : primaryFactory,
            Distributing_Company__c : distributingCompany,
            Contract__c : contract
        });
        
        var action = component.get('c.saveLMS');       
        // set param to method  
        action.setParams({ newLMSJSON : JSON.stringify( newLMS ) });
        // set a callBack    
        action.setCallback(this, function(response) { 
            var status = response.getState();
            if(status === "SUCCESS"){ 
                component.set("v.LMS", response.getReturnValue());
                
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);       
        
    },
    
    //saveLMS method will save the LMS record with the provided inputs onclick of Save and Select Products/IPs button
    saveLMSAndNext : function (component){
        var distributingCompany = component.find('distributingCompany').get('v.value');
        var primaryFactory = component.find('primaryFactory').get('v.value');
        var tradeOffice = component.find('tradeOffice').get('v.value');
        var factory = component.find('factory').get('v.value');
        var notes = component.find('notes').get('v.value');
        var contract = component.get('v.recordId');
        var newLMS = [];
        newLMS.push({            
            Factory__c : factory,
            Notes__c : notes,
            Trade_Office__c : tradeOffice,
            Primary_Factory__c : primaryFactory,
            Distributing_Company__c : distributingCompany,
            Contract__c : contract
        });
        
        var action = component.get('c.saveLMS');       
        // set param to method  
        action.setParams({ newLMSJSON : JSON.stringify( newLMS ) });
        // set a callBack    
        action.setCallback(this, function(response) { 
            var status = response.getState();           
            if(status === "SUCCESS"){             
                component.set("v.LMS", response.getReturnValue());
                var lms = component.get("v.LMS").Id;
                var event = $A.get("e.force:navigateToComponent");           
                event.setParams({
                    componentDef: "c:GBSQuickButton",
                    componentAttributes: { 
                        recordId : component.get("v.LMS").Id,
                        loadWithoutBtnClick : "true"
                    }
                });
                event.fire();
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);       
}
 
})