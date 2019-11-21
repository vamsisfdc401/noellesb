({
   
    //Save method will save the LMS record onclick of Save button
    save: function(component, event, helper) {       
        var distributingCompany = component.find('distributingCompany').get('v.value');
        var factory = component.find('factory').get('v.value');
        
        //if factory/distributingCompany is not selected in the LMS Form
        if(factory == null && distributingCompany == null){            
            $A.util.addClass(component.find('distributingCompany'),'slds-has-error');
            $A.util.addClass(component.find('factory'),'slds-has-error');
            $A.util.removeClass(component.find('errorMessageDistributingCompany'),'slds-hide');            
        }
        
        //if any of the factory/distributingCompany are selected in the LMS Form
        else{            
            $A.util.removeClass(component.find('distributingCompany'),'slds-has-error');
            $A.util.removeClass(component.find('factory'),'slds-has-error');
            $A.util.addClass(component.find('errorMessageDistributingCompany'),'slds-hide');
            helper.saveLMS(component);
            $A.get("e.force:closeQuickAction").fire();
        }
        
    },
    
    //cancel button will navigate back to the contract page closing the LMS popup screen
    cancel: function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    //navigatetoComp method will save the LMS record onclick of Save and Select Products/IPs button
    navigatetoComp: function(component, event, helper) {       
        var distributingCompany = component.find('distributingCompany').get('v.value');
        var factory = component.find('factory').get('v.value');       
        
        //if factory/distributingCompany is not selected in the LMS Form
        if(factory == null && distributingCompany == null){
            $A.util.addClass(component.find('distributingCompany'),'slds-has-error');
            $A.util.addClass(component.find('factory'),'slds-has-error');
            $A.util.removeClass(component.find('errorMessageDistributingCompany'),'slds-hide');
         }
        
        //if any of the factory/distributingCompany are selected in the LMS Form
        else{            
            $A.util.removeClass(component.find('distributingCompany'),'slds-has-error');
            $A.util.removeClass(component.find('factory'),'slds-has-error');
            $A.util.addClass(component.find('errorMessageDistributingCompany'),'slds-hide');
            helper.saveLMSAndNext(component, event, helper);            
        }        
    }
    
})