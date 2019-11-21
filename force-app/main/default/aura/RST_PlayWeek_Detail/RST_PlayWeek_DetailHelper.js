({
    processPlayWeek : function(component, userChanged) {
        var pw = component.get("v.PlayWeek");
        if(!pw){
            console.log('playweek not loaded yet');
            return;
        }
        console.log('process playweek change: ' + pw.pw.Name);
        component.set("v.processing", true);

        var start_WKND_BO = component.get("v.start_WKND_BO");
        var start_WEEK_BO = component.get("v.start_WEEK_BO");
        var runningTotal = component.get("v.runningTotal");
        var USE_BO_CALC = component.get("v.USE_BO_CALC");

        if(userChanged){
            pw.pw.Source__c = 'User';
            pw.pw.LastModifiedBy.Name = 'Current User';

            if(USE_BO_CALC){ // use BO to calc decay, or decay to calc BO
                var wknd_bo = pw.pw.Weekend_BO__c;
                var week_bo = pw.pw.Midweek_BO__c;
    
                var use_WKND_DY = ((wknd_bo - start_WKND_BO) / start_WKND_BO) * 100;
                var use_WEEK_DY = ((week_bo - start_WEEK_BO) / start_WEEK_BO) * 100;
    
                if(pw.pw.Play_Week__c >= 2){
                    pw.pw.Weekend_Drop__c = use_WKND_DY;
                    pw.pw.Midweek_Drop__c = use_WEEK_DY;
                }
                
            } else {
                var wknd_drop = pw.pw.Weekend_Drop__c;
                var week_drop = pw.pw.Midweek_Drop__c;
                
                var use_WKND_BO = (wknd_drop) ? (start_WKND_BO * 1) + ((start_WKND_BO * 1) * (wknd_drop / 100)) : start_WKND_BO;
                var use_WEEK_BO = (week_drop) ? (start_WEEK_BO * 1) + ((start_WEEK_BO * 1) * (week_drop / 100)) : start_WEEK_BO;
                
                if(pw.pw.Play_Week__c >= 2){
                    pw.pw.Weekend_BO__c = use_WKND_BO;
                    pw.pw.Midweek_BO__c = use_WEEK_BO;
                }
            }
        }

        pw.pw.Weekend_BO__c = parseFloat(pw.pw.Weekend_BO__c).toFixed(2);
        pw.pw.Midweek_BO__c = parseFloat(pw.pw.Midweek_BO__c).toFixed(2);
        if(pw.pw.Play_Week__c >= 2){
            pw.pw.Weekend_Drop__c = parseFloat(pw.pw.Weekend_Drop__c).toFixed(2);
            pw.pw.Midweek_Drop__c = parseFloat(pw.pw.Midweek_Drop__c).toFixed(2);
        }
        
        runningTotal += (pw.pw.Weekend_BO__c * 1) + (pw.pw.Midweek_BO__c * 1);
        pw.pw.Cumulative__c = runningTotal;

        component.set("v.PlayWeek", pw);

        component.set("v.initComplete", true);
        
        var showChild = component.get("v.showChild");
        //and(v.PlayWeek.child, v.initComplete)
        if(pw.child && !showChild){
            console.log('show the child record now?');
        	component.set("v.showChild",true);  
        } 
        
    	
        var childComponent = component.find('child');
        
        if(childComponent && userChanged){
            console.log('send call ' + pw.pw.Name);
        	childComponent.updateChild(pw.pw.Weekend_BO__c, pw.pw.Midweek_BO__c, USE_BO_CALC);
            
        } 
        
    },
    previous_processPlayWeek : function(component) {
        
        console.log('playWeek_Loaded : ' + playWeek_Loaded);
        //if(!playWeek_Loaded) {
            
        

        //console.log("loading a pw");
        var pw = component.get("v.PlayWeek");
        if (!$A.util.isEmpty(pw)) {
            console.log('got a playweek');
            console.log(pw);
            var wknd_drop = pw.pw.Weekend_Drop__c;
            var week_drop = pw.pw.Midweek_Drop__c;
            //console.log(wknd_drop);
            var start_WKND_BO = component.get("v.start_WKND_BO");
            var start_WEEK_BO = component.get("v.start_WEEK_BO");

            var use_WKND_BO = component.get("v.use_WKND_BO");
            var use_WEEK_BO = component.get("v.use_WEEK_BO");

            if(use_WKND_BO > 50){
                console.log('calling child here');
                var childComponent = component.find('child');
                childComponent.updateChild('attribute1', 'updated');
            } else {
                console.log('not calling child here: ' + use_WKND_BO);
            }

            //if(!use_WKND_BO){
                use_WKND_BO = (wknd_drop) ? (start_WKND_BO * 1) + (start_WKND_BO * (wknd_drop / 100)) : start_WKND_BO;
                component.set("v.use_WKND_BO", use_WKND_BO);
            //}

            //if(!use_WEEK_BO) {
                use_WEEK_BO = (week_drop) ? start_WEEK_BO + (start_WEEK_BO * (week_drop / 100)) : start_WEEK_BO;
                component.set("v.use_WEEK_BO", use_WEEK_BO);
            //}
            
            
            component.set("v.playWeek_Loaded", true);
            
            
        }
    }
})