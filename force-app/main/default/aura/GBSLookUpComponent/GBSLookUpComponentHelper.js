({
    itemSelected : function(component, event, helper) {
        var target = event.target;   
        var SelIndex = helper.getIndexFrmParent(target,helper,"data-selectedIndex");        
        if(SelIndex){
            var serverResult = component.get("v.server_result");
            var selItem = serverResult[SelIndex];
            if(selItem.val){
                component.set("v.selItem",selItem);
                component.set("v.last_ServerResult",serverResult);
            } 
            component.set("v.server_result",null); 
        }
    }, 
       
    serverCall : function(component, event, helper) {  
        var target = event.target;  
        var searchText = target.value; 
        var last_SearchText = component.get("v.last_SearchText");
        //Escape button pressed 
        if (event.keyCode == 27) { 
            helper.clearSelection(component, event, helper);
        }else {            
            var objectName = component.get("v.objectName");
            var field_API_text = component.get("v.field_API_text");
            var field_API_text1 = component.get("v.field_API_text1");
            var field_API_text2 = component.get("v.field_API_text2");
            var field_API_val = component.get("v.field_API_val");
            var field_API_search = component.get("v.field_API_search");
            var limit = component.get("v.limit");
            var contractId = component.get("v.contractId");
            
            var action = component.get('c.searchDB');
            action.setStorable();
            
            action.setParams({
                objectName : objectName,
                fld_API_Text : field_API_text,
                fld_API_Text1 : field_API_text1,
                fld_API_Text2 : field_API_text2,
                fld_API_Val : field_API_val,
                lim : limit, 
                fld_API_Search : field_API_search,
                searchText : searchText,
                contractId : contractId
            });
            
            action.setCallback(this,function(a){
                this.handleResponse(a,component,helper);
            });
            
            component.set("v.last_SearchText",searchText.trim());
            console.log('Server call made');
            $A.enqueueAction(action); 
        }
        
    },
    
    handleResponse : function (res,component,helper){
        if (res.getState() === 'SUCCESS') {
            var retObj = JSON.parse(res.getReturnValue());
            if(retObj.length <= 0){
                var noResult = JSON.parse('[{"text":"No Results Found"}]');
                component.set("v.server_result",noResult); 
                component.set("v.last_ServerResult",noResult);
            }else{
                component.set("v.server_result",retObj); 
                component.set("v.last_ServerResult",retObj);
            }  
        }else if (res.getState() === 'ERROR'){
            var errors = res.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    // alert(errors[0].message);
                }
            } 
        }
    },
    
    getIndexFrmParent : function(target,helper,attributeToFind){
        //User can click on any child element, so traverse till intended parent found
        var SelIndex = target.getAttribute(attributeToFind);
        while(!SelIndex){
            target = target.parentNode ;
            SelIndex = helper.getIndexFrmParent(target,helper,attributeToFind);           
        }
        return SelIndex;
    },
    
    clearSelection: function(component, event, helper){
        component.set("v.selItem",null);
        component.set("v.server_result",null);
    },
    
    toggleVisibility : function(component, event, helper){
        var target = event.target;   
        var RelatedTo = target.getAttribute("data-selected-Index");
        if (RelatedTo==null || RelatedTo.length<0)
        {
            var prgDiv = component.find('prgId');
            $A.util.toggleClass(prgDiv,'slds-is-open');
            console.log("Toggle");
        }
        else
            console.log('We will not toggle as the value is selected');
    },
    
    blurtoggleVisibility : function(component, event, helper){
        var target = event.target;   
        var RelatedTo = target.getAttribute("data-selected-Index");
        if (RelatedTo==null || RelatedTo.length<0)
        {
            var prgDiv = component.find('prgId');
            window.setTimeout(
                $A.getCallback(function() {
                    $A.util.toggleClass(prgDiv,'slds-is-open');
                    console.log('Toggle on Blur event');
                }), 250);
        }
    } 
})