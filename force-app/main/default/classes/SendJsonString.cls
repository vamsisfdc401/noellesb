/***********************************************************************************
Class Name: SendJsonString
Purpose:  To send dynamic json to GTM
******************************************************************************************
Version         DateModified         ModifiedBy               Change 
1.0             2/27/2019             Naga                      
******************************************************************************************/
global class SendJsonString {
    // Scenarion :1 Sending Digital release along with products 
    @future(callOut=true)   
    global static void SendDigitalReleaseWithProducts(String jsonString, String digReleaseId){        
        System.debug('**Final**'+jsonString);
        HttpRequest req=new HttpRequest();  
// Used Named Credintials        
        req.setHeader('api_key', '{!$Credential.Password}');         
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint('callout:GTM_API');
        req.setBody(jsonString);
        req.setTimeout(120000);
        req.setMethod('POST');                
        Http ht=new Http();
        HttpResponse rep=new HttpResponse();
        String error1='';
        try{            
            rep=ht.send(req);
        }catch(Exception ex)
        {
            error1= ex.getMessage();
            System.debug('**exception**'+ex.getMessage());
            for(integer i=0; i<=5; i++)
            {
                if(error1=='Read timed out')
                { 
                    try{
                        rep=ht.send(req);
                    }
                    catch(Exception e)
                    {
                        error1= e.getMessage();
                        System.debug('**i**'+i);
                        
                    }
                }
                
            }
            
        }
        
        System.debug('**resp**'+rep.getBody());        
        String s = rep.getBody();
        //Parse response json from GTM
        Map<String,Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(s);
        String Error = JSON.serialize(jsonMap.get('Error'));
        String DGFId = JSON.serialize(jsonMap.get('DGF Release ID'));
        String ExtId = JSON.serialize(jsonMap.get('External Request ID'));
        String sysGen = JSON.serialize(jsonMap.get('SysGen'));
        String status = JSON.serialize(jsonMap.get('Status'));
        String message =JSON.serialize(jsonMap.get('Message'));
        
        List<product__c> lpList=[select id,JSON_Send__c from Product__c where Digital_Release__c=:digReleaseId and JSON_Send__c=false];
        for(product__c pd:lpList){
            pd.JSON_Send__c=true;
        }
        system.debug('***lpList '+lpList);
        update lpList;
        system.debug('***After insert lpList '+lpList);
        System.debug('Bundle SysGen'+sysGen);
        Digital_Release__c dr = new Digital_Release__c();
        dr.Id=digReleaseId;
        if(dr.Visibility__c != 'Visible'){
            dr.Visibility__c='Visible';
            update dr;
        }
        
        
        // Loggin GTM response into custom object        
        Digital_Release_Integration_Response__c DRI=new Digital_Release_Integration_Response__c();
        DRI.GTM_Message__c=Error.removeEnd('"').removestart('"'); 
        if(message != 'Null')
            DRI.GTM_Message__c =message.removeEnd('"').removestart('"');
        DRI.Requested_Id__c=JSON.serialize(jsonMap.get('External Request ID'));
        if(DGFId!='null')
        	DRI.Digital_Release__c=DGFId.removeEnd('"').removestart('"');
        DRI.Status__c=status.removeEnd('"').removestart('"');
        if(sysGen!='Null')
            DRI.Bundle_SYSGEN__c=sysGen.removeEnd('"').removestart('"');
        insert DRI;    
        
    }
    // Scenario :2 Send json to GTM when new product is added to the existing Digital Release which is already sent to GTM
    @future(callOut=true)   
    global static void ExistingDigitalReleaseWithNewProduct(String digReleaseId, List<String> prodId){
        System.debug('In callout method after add product');
        list<Digital_Release__c> digiList = [select id , name ,Bundle_SYSGEN__c,CA_Bundle_Avail_Date__c,Bundle_Genre__c,US_Bundle_Avail_Date__c,	Visibility__c,	Send_to_GTM__c,Primary_Bundle_Genre__c,CA_Bundle_Pre_Purchase_Date__c,
                                             US_Bundle_Pre_Purchase_Date__c,Deactivation_Date__c,
                                             (select id, name,Digital_Release__c,Product_ID__c, Version_Type__c,Short_Name__c,Bundle_Synopsis__c from Products__r where id IN:prodId) from Digital_Release__c where id=:digReleaseId];         
        User users=[Select Id,FederationIdentifier,Name,Email from User where Id=:userinfo.getuserId()];
        List<Product_Version__c> prodVerList=[select id, name,Product__c,TM_Version__c from Product_Version__c];
        map<id,list<Product_Version__c>> orderMap = new map<id,list<Product_Version__c>>();
        for(Product_Version__c info : [select id, name,Product__c,TM_Version__c from Product_Version__c])            
        {
            if(orderMap.containskey(info.Product__c))
            {
                orderMap.get(info.Product__c).add(info);
            }                        
            else
            {
                list<Product_Version__c> temp = new list<Product_Version__c>();
                temp.add(info) ;
                orderMap.put(info.Product__c,temp);
            }
        }  
        String input=''; 
        String input1='"entityList": [{';
        String input2='';
        string input3='';
        String inputDt='';
        String inputDt1='';
        String inputDt2='';
        String inputDt3='';
        String inputDt4='';
        String inputBundleGenre='';
        String inp='';     
        
        for(Digital_Release__c dr:digiList)
        {                  
            input='{"SourceID":"'+dr.id+'","SourceName":"DGFR","SourceTitleName":"'+dr.name+'","SystemSSO":"206611836","UserSSO":"'+users.FederationIdentifier+'",';             
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String unique1 = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            string gnrDesc='';
            system.debug('**** Parent unique1 '+unique1);
            system.debug('**** Products__r '+dr.Products__r);
            for (DigitalRelease__c mySetting : DigitalRelease__c.getAll().values()){                  
                if(dr.Primary_Bundle_Genre__c==mySetting.name){
                    gnrDesc=mySetting.DGF_GenreCode__c;
                    system.debug('*** DigitalRelease__c **'+gnrDesc);
                }
                
            }
            for(Product__c p:dr.Products__r)
            {
                system.debug('**** p'+p);
                string vType='';
                
                for (VersionType_In_Product__c setting : VersionType_In_Product__c.getAll().values()){
                    
                    if(p.Version_Type__c==setting.name){
                        vType=setting.Version_Type__c;
                    }                    
                }              
                
                Blob b1 = Crypto.GenerateAESKey(128);
                String h1 = EncodingUtil.ConvertTohex(b1);
                String unique2 = h1.SubString(0,8)+ '-' + h1.SubString(8,12) + '-' + h1.SubString(12,16) + '-' + h1.SubString(16,20) + '-' + h1.substring(20);
                system.debug('****Crosref Unique 1 '+unique2);
                
                Blob b2 = Crypto.GenerateAESKey(128);
                String h2 = EncodingUtil.ConvertTohex(b2);
                String unique3 = h2.SubString(0,8)+ '-' + h2.SubString(8,12) + '-' + h2.SubString(12,16) + '-' + h2.SubString(16,20) + '-' + h2.substring(20);
                system.debug('**** Crosref Unique 1 '+unique3);
                
                String parentUniqueId=unique2+','+unique3;
                system.debug('**** parentLinkId '+parentUniqueId);     
                if(input2==''){
                    input2='"type": "Version","currentRequestType": {"masterRequestType": "Version","requestType": "Version"}, "operation": "AD",'+
                        +'"data": {"versionType": "'+vType+'","versionNameDelimited":"'+p.Version_Type__c+'","language": "ENG"},"parentLinkId":"'+parentUniqueId+'"},'
                        +'{"type": "CrossRef","linkId": "'+unique2+'","currentRequestType": {"masterRequestType": "CrossRef", "requestType": "CrossRef"},"operation": "AD","data": { "sourceDesc": "DGF","crossRefNameDelimited": "'+p.Short_Name__c+'","crossRefShortName": "'+p.Short_Name__c+'", "crossRefNumber_s": "'+p.id+'" },"parentLinkId": "'+unique1+'"},'
                        +'{"type": "CrossRef","linkId": "'+unique3+'","currentRequestType": {"masterRequestType": "CrossRef","requestType": "CrossRef"},"operation": "AD",'
                        +'"data": {"sourceDesc": "BDLF","crossRefNameDelimited": "'+p.name+'","versionNameDelimited": "All Media"}, "parentLinkId": "'+unique1+'" },';
                    String synop='';
                    if(p.Bundle_Synopsis__c!=null) {
                        synop='{"type": "Synopsis","currentRequestType": {"masterRequestType": "Title", "requestType": "Synopsis"},"operation": "AD","data": { "languageDesc": "ENG","synopsisText": "'+p.Bundle_Synopsis__c+'"},"parentLinkId": "'+parentUniqueId+'"},';
                    }
                    input2=input2+synop;
                }
                else{
                    input2=input2+'{"type": "Version","currentRequestType": {"masterRequestType": "Version","requestType": "Version"}, "operation": "AD",'+
                        +'"data": {"versionType": "'+vType+'","versionNameDelimited":"'+p.Version_Type__c+'","language": "ENG"},"parentLinkId":"'+parentUniqueId+'"},'
                        +'{"type": "CrossRef","linkId": "'+unique2+'","currentRequestType": {"masterRequestType": "CrossRef", "requestType": "CrossRef"},"operation": "AD","data": { "sourceDesc": "DGF","crossRefNameDelimited": "'+p.Short_Name__c+'","crossRefShortName": "'+p.Short_Name__c+'" ,"crossRefNumber_s": "'+p.id+'" },"parentLinkId": "'+unique1+'"},'
                        +'{"type": "CrossRef","linkId": "'+unique3+'","currentRequestType": {"masterRequestType": "CrossRef","requestType": "CrossRef"},"operation": "AD",'
                        +'"data": {"sourceDesc": "BDLF","crossRefNameDelimited": "'+p.name+'","versionNameDelimited": "All Media"}, "parentLinkId": "'+unique1+'" },';
                    String synop='';
                    if(p.Bundle_Synopsis__c!=null){
                        synop='{"type": "Synopsis","currentRequestType": {"masterRequestType": "Title", "requestType": "Synopsis"},"operation": "AD","data": { "languageDesc": "ENG","synopsisText": "'+p.Bundle_Synopsis__c+'"},"parentLinkId": "'+parentUniqueId+'"},';
                    }
                    input2=input2+synop;
                }
                system.debug('**** input2'+input2);
                if(orderMap.containsKey(p.id) && orderMap.get(p.id).size() > 0){
                    for(Product_Version__c orderRec : orderMap.get(p.id)){
                        System.debug('OrderRec'+orderRec);
                        // Product_Version__c pvc = [select id ,TM_Version__c from Product_Version__c where Id =:orderRec.Id];
                        TM_Version__c tmv = [SELECT Id,Name,TVD_SAFE_Production_ID__c FROM TM_Version__c WHERE Id =:orderRec.TM_Version__c];
                        if(input3==''){	
                            input3=',{"type": "Compilation","currentRequestType": {"masterRequestType": "Title","requestType": "CMPL_Title"},"operation": "AD","data": {"crossRefNumber": "'+tmv.TVD_SAFE_Production_ID__c +'", "sourceCode": "TVD"},"parentLinkId": "'+parentUniqueId+'"}';
                        }
                        else{	
                            input3=input3+',{"type": "Compilation","currentRequestType": {"masterRequestType": "Title","requestType": "CMPL_Title"},"operation": "AD","data": {"crossRefNumber": "'+tmv.TVD_SAFE_Production_ID__c +'", "sourceCode": "TVD"},"parentLinkId": "'+parentUniqueId+'"}';
                        }
                    }
                }
                
            }
            
            inp='{"type": "Title",  "linkId": "'+unique1+'","currentRequestType": {"masterRequestType": "Title","requestType": "Title"},"operation": "ED",'
                +'"data": {"titleId_s":"'+dr.Bundle_SYSGEN__c+'"}}';          
            
            input3=input3+']}'; 
            
        }       
         
        input=input+input1+input2+inp+input3;
        System.debug('**Final**'+input);
        HttpRequest req=new HttpRequest();
        //Named Credintials
        req.setHeader('api_key', '{!$Credential.Password}');
        req.setEndpoint('callout:GTM_API'); 
        req.setHeader('Content-Type', 'application/json');
        req.setBody(input);
        req.setTimeout(120000);
        req.setMethod('POST');        
        Http ht=new Http();
        HttpResponse rep=new HttpResponse();
        String error1='';
        try{
            
            rep=ht.send(req);
        }catch(Exception ex)
        {
            error1= ex.getMessage();
            System.debug('**exception**'+ex.getMessage());
            for(integer i=0; i<=5; i++)
            {
                if(error1=='Read timed out')
                { 
                    try{
                        rep=ht.send(req);
                    }
                    catch(Exception e)
                    {
                        error1= e.getMessage();
                        System.debug('**i**'+i);
                        
                    }
                }
                
            }
            
        }
        System.debug('**resp**'+rep.getBody());
        String s = rep.getBody();
        // Parse GTM response
        Map<String,Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(s);
        String Error = JSON.serialize(jsonMap.get('Error'));
        String DGFId = JSON.serialize(jsonMap.get('DGF Release ID'));
        String ExtId = JSON.serialize(jsonMap.get('External Request ID'));
        String sysGen = JSON.serialize(jsonMap.get('SysGen'));
        String status = JSON.serialize(jsonMap.get('Status'));
        String message =JSON.serialize(jsonMap.get('Message'));
        List<product__c> lpList2=new List<product__c> ();
        List<product__c> lpList=[select id,JSON_Send__c from Product__c where Digital_Release__c=:digReleaseId];
        for(product__c pd:lpList){
            if(pd.JSON_Send__c==false){
                pd.JSON_Send__c=true;
                lpList2.add(pd);
            }         
        }
        update lpList2;
        System.debug('**lpList2**'+lpList2);
        Digital_Release_Integration_Response__c DRI=new Digital_Release_Integration_Response__c();
        DRI.GTM_Message__c=Error.removeEnd('"').removestart('"');
        if(message != 'Null')
            DRI.GTM_Message__c =message.removeEnd('"').removestart('"');
        DRI.Requested_Id__c=JSON.serialize(jsonMap.get('External Request ID'));
        if(DGFId!='null')
        DRI.Digital_Release__c=DGFId.removeEnd('"').removestart('"');
        DRI.Status__c=status.removeEnd('"').removestart('"');
        system.debug('***before DRI insert');        
        insert DRI;
        system.debug('***After DRI insert'+DRI);       
    }
    
    //Scenario :3 Send Json to GTM when Event Date fields changed in Digital release which is already sent to GTM
    @future(callOut=true)   
    global static void DigitalReleaseUpdateOnly(List<String> digReleaseId,Boolean primaryGnr,Boolean bundleGnr, Boolean CAPreDT_AD,Boolean CAPreDT_ED,Boolean CAavDT_AD,Boolean CAavDT_ED,Boolean CAPrePurDT_AD,Boolean CAPrePurDT_ED, Boolean DeactDT_AD,Boolean DeactDT_ED,Boolean USAvail_AD,Boolean USAvail_ED){
        list<Digital_Release__c> digiList = [select id , name ,CA_Bundle_Avail_Date__c,Bundle_Genre__c,Bundle_SYSGEN__c,US_Bundle_Avail_Date__c,Visibility__c,	Send_to_GTM__c,Primary_Bundle_Genre__c,CA_Bundle_Pre_Purchase_Date__c, US_Bundle_Pre_Purchase_Date__c,Deactivation_Date__c from Digital_Release__c where id IN:digReleaseId];         
        User users=[Select Id,FederationIdentifier,Name,Email from User where Id=:userinfo.getuserId()];
        
        String input=''; 
        String input1='"entityList": [';
        String input2='';
        string input3='';
        String inputDt='';
        String inputDt1='';
        String inputDt2='';
        String inputDt3='';
        String inputDt4='';
        String inputBundleGenre='';
        String inp=''; 
        system.debug('**** '+digReleaseId);
        List<ID> pdList=new List<ID>();
        List<String> bundleGenreList= new List<String>();
        for(Digital_Release__c dr:digiList)
        {      
            if(dr.Bundle_Genre__c != null) {
                System.debug('Bundle Genre is not null');
                bundleGenreList=dr.Bundle_Genre__c.split(';');
                system.debug('***Bundle genre '+bundleGenreList);
            }            
            input='{"SourceID":"'+dr.id+'","SourceName":"DGFR","SourceTitleName":"'+dr.name+'" ,"SystemSSO":"206611836","UserSSO":"'+users.FederationIdentifier+'",';
            integer yearr=0;
            
            if(dr.CA_Bundle_Avail_Date__c!=null && dr.US_Bundle_Avail_Date__c!=null){
                if(dr.CA_Bundle_Avail_Date__c>=dr.US_Bundle_Avail_Date__c){
                    yearr=dr.CA_Bundle_Avail_Date__c.year();
                }
                if(dr.CA_Bundle_Avail_Date__c<=dr.US_Bundle_Avail_Date__c){
                    yearr=dr.US_Bundle_Avail_Date__c.year();
                }
            }
            else if(dr.CA_Bundle_Avail_Date__c!=null){
                yearr=dr.CA_Bundle_Avail_Date__c.year();
            }
            else if(dr.US_Bundle_Avail_Date__c!=null){
                yearr=dr.US_Bundle_Avail_Date__c.year();
            }
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String unique1 = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            string gnrDesc='';
            system.debug('**** Parent unique1 '+unique1);
            if(primaryGnr){
                for (DigitalRelease__c mySetting : DigitalRelease__c.getAll().values()){                  
                    if(dr.Primary_Bundle_Genre__c==mySetting.name){
                        gnrDesc=mySetting.DGF_GenreCode__c;
                        system.debug('*** DigitalRelease__c **'+gnrDesc);
                    }
                    
                }
                input2=',{"type": "Genre","currentRequestType": {"masterRequestType": "Title","requestType": "Genre"},"operation": "AD","data": { "primaryGenre": "Y","genreDesc": "'+gnrDesc+'"},"parentLinkId": "'+unique1+'"}';
                
            }
            if(bundleGnr){
                if(bundleGenreList.size()>0){
                    for(integer i=0;i<bundleGenreList.size();i++){
                        for (DigitalRelease__c mySetting1 : DigitalRelease__c.getAll().values()){                  
                            if(bundleGenreList[i]== mySetting1.name && bundleGenreList[i] != dr.Primary_Bundle_Genre__c ){
                                String gnrDesc1 =mySetting1.DGF_GenreCode__c; // code for genre
                                system.debug('genDesc1'+gnrDesc1);
                                if(inputBundleGenre==''){
                                    inputBundleGenre=',{"type": "Genre","currentRequestType": {"masterRequestType": "Title","requestType": "Genre"},"operation": "AD","data": { "primaryGenre": "N","genreDesc": "'+gnrDesc1+'"},"parentLinkId": "'+unique1+'"}';
                                } 
                                else{
                                    inputBundleGenre=inputBundleGenre+',{"type": "Genre","currentRequestType": {"masterRequestType": "Title","requestType": "Genre"},"operation": "AD","data": { "primaryGenre": "N","genreDesc": "'+gnrDesc1+'"},"parentLinkId": "'+unique1+'"}';
                                }
                            }
                            
                        }
                        
                    }
                }
            }
            inp='{"type": "Title",  "linkId": "'+unique1+'","currentRequestType": {"masterRequestType": "Title","requestType": "Title"},"operation": "ED",'
                +'"data": {"titleId_s": "'+dr.Bundle_SYSGEN__c+'","productType": "CMPL","levelTagDesc": "TITLE","releaseStatusDesc": "REL","titleNameDelimited": "'+dr.name+'","originalMarket":"EDU","productionYear":"'+yearr+'"}}';            
            
            if(CAPreDT_AD){
                inputDt=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "AD",' 
                    +'"data": {"eventTypeDesc": "CAPREORDBD","eventDate":"'+dr.CA_Bundle_Pre_Purchase_Date__c+'"},"parentLinkId": "'+unique1+'"}';
            }
            if(CAavDT_AD){
                inputDt1=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "AD",' 
                    +'"data": {"eventTypeDesc": "CASTREETBD","eventDate":"'+dr.CA_Bundle_Avail_Date__c+'"},"parentLinkId": "'+unique1+'"}';
            }
            if(CAPrePurDT_AD){
                inputDt2=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "AD",' 
                    +'"data": {"eventTypeDesc": "USPREORDBD","eventDate":"'+dr.US_Bundle_Pre_Purchase_Date__c+'"},"parentLinkId": "'+unique1+'"}';
            }
            if(DeactDT_AD){
                inputDt3=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "AD",' 
                    +'"data": {"eventTypeDesc": "BDLDDUS","eventDate":"'+dr.Deactivation_Date__c+'"},"parentLinkId": "'+unique1+'"}';
            }
            if(USAvail_AD){
                inputDt4=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "AD",' 
                    +'"data": {"eventTypeDesc": "USSTREETBD","eventDate":"'+dr.US_Bundle_Avail_Date__c+'"},"parentLinkId": "'+unique1+'"}';
            }
            
            //================= for ED event dates ============================
            if(CAPreDT_ED){
                inputDt=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "ED",' 
                    +'"data": {"eventTypeDesc": "CAPREORDBD","eventDate":"'+dr.CA_Bundle_Pre_Purchase_Date__c+'"},"parentLinkId": "'+unique1+'"}';
            }
            if(CAavDT_ED){
                inputDt1=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "ED",' 
                    +'"data": {"eventTypeDesc": "CASTREETBD","eventDate":"'+dr.CA_Bundle_Avail_Date__c+'"},"parentLinkId": "'+unique1+'"}';
            }
            if(CAPrePurDT_ED){
                inputDt2=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "ED",' 
                    +'"data": {"eventTypeDesc": "USPREORDBD","eventDate":"'+dr.US_Bundle_Pre_Purchase_Date__c+'"},"parentLinkId": "'+unique1+'"}';
            }
            if(DeactDT_ED){
                inputDt3=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "ED",' 
                    +'"data": {"eventTypeDesc": "BDLDDUS","eventDate":"'+dr.Deactivation_Date__c+'"},"parentLinkId": "'+unique1+'"}';
            }
            if(USAvail_ED){
                inputDt4=',{"type" : "EventDates","currentRequestType": {"masterRequestType": "Title","requestType": "EventDates"},"operation": "ED",' 
                    +'"data": {"eventTypeDesc": "USSTREETBD","eventDate":"'+dr.US_Bundle_Avail_Date__c+'"},"parentLinkId": "'+unique1+'"}';
            }
            
            //input2=input2+inputDt+inputDt1+inputDt2+inputDt3+inputDt4;
            
            input3=input3+']}'; 
            
        }
        
        
        
        System.debug('**3**'+input3);
        input=input+input1+inp+input2+inputBundleGenre+inputDt+inputDt1+inputDt2+inputDt3+inputDt4+input3;
        System.debug('**Final**'+input);
        HttpRequest req=new HttpRequest();
        //req.setHeader('api_key', '7jj2x58pau9aj92krzm47x9s');
        req.setHeader('api_key', '{!$Credential.Password}');
        req.setEndpoint('callout:GTM_API'); 
        req.setHeader('Content-Type', 'application/json');
        req.setBody(input);
        req.setTimeout(120000);
        req.setMethod('POST');
        // req.setEndpoint('https://qa-api.nbcuniversal.com/gtm/qa/v1/beta/GTMUpdateRequest');         
        Http ht=new Http();
        HttpResponse rep=new HttpResponse();
        String error1='';
        try{
            
            rep=ht.send(req);
        }catch(Exception ex)
        {
            error1= ex.getMessage();
            System.debug('**exception**'+ex.getMessage());
            for(integer i=0; i<=5; i++)
            {
                if(error1=='Read timed out')
                { 
                    try{
                        rep=ht.send(req);
                    }
                    catch(Exception e)
                    {
                        error1= e.getMessage();
                        System.debug('**i**'+i);
                        
                    }
                }
                
            }
            
        }
        System.debug('**resp**'+rep.getBody());
        
        String s = rep.getBody();
        Map<String,Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(s);
        String Error = JSON.serialize(jsonMap.get('Error'));
        String DGFId = JSON.serialize(jsonMap.get('DGF Release ID'));
        String ExtId = JSON.serialize(jsonMap.get('External Request ID'));
        String sysGen = JSON.serialize(jsonMap.get('SysGen'));
        String status = JSON.serialize(jsonMap.get('Status'));
        String message =JSON.serialize(jsonMap.get('Message'));
        Digital_Release_Integration_Response__c DRI=new Digital_Release_Integration_Response__c();
        DRI.GTM_Message__c=Error.removeEnd('"').removestart('"');
        if(message != 'null')
            DRI.GTM_Message__c = message.removeEnd('"').removestart('"');  
        DRI.Status__c=status.removeEnd('"').removestart('"');
        DRI.Requested_Id__c=JSON.serialize(jsonMap.get('External Request ID'));
        if(DGFId!='null')
        DRI.Digital_Release__c=DGFId.removeEnd('"').removestart('"');
        system.debug('***before DRI insert');
        //DRI.Bundle_SYSGEN__c=sysGen.removeEnd('"').removestart('"');
        insert DRI;
        system.debug('***After DRI insert'+dri);
    }
    // Scenario:4
    @future(callOut=true)   
    global static void ProductUpdateonExistingDigitalRelease(List<String> prodIds,String digiR,Boolean prodName, Boolean prodShtName,Boolean ProdBndlSynops){
        list<Digital_Release__c> digiList = [select id , name ,Bundle_Sysgen__c,CA_Bundle_Avail_Date__c,Bundle_Genre__c,US_Bundle_Avail_Date__c,	Visibility__c,	Send_to_GTM__c,Primary_Bundle_Genre__c,CA_Bundle_Pre_Purchase_Date__c,
                                             US_Bundle_Pre_Purchase_Date__c,Deactivation_Date__c,
                                             (select id, name,Digital_Release__c,Product_ID__c, Version_Type__c,Short_Name__c,Bundle_ID__c,Bundle_Synopsis__c from Products__r where id=:prodIds) from Digital_Release__c where id=:digiR];         
        User users=[Select Id,FederationIdentifier,Name,Email from User where Id=:userinfo.getuserId()];
        String input=''; 
        String input1='"entityList": [';
        String input2='';
        string input3='';
        String inputDt='';
        String inputDt1='';
        String inputDt2='';
        String inputDt3='';
        String inputDt4='';
        String inputBundleGenre='';
        String inp=''; 
        
        for(Digital_Release__c dr:digiList)
        {
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String unique1 = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
            
            input='{"SourceID":"'+dr.id+'","SourceName":"DGFR","SourceTitleName":"'+dr.name+'","SystemSSO":"206611836","UserSSO":"'+users.FederationIdentifier+'",';
            
            integer yearr=0;
            if(dr.CA_Bundle_Avail_Date__c !=null && dr.US_Bundle_Avail_Date__c !=null){
                if(dr.CA_Bundle_Avail_Date__c>=dr.US_Bundle_Avail_Date__c){
                    yearr=dr.CA_Bundle_Avail_Date__c.year();
                }
                if(dr.CA_Bundle_Avail_Date__c<=dr.US_Bundle_Avail_Date__c){
                    yearr=dr.US_Bundle_Avail_Date__c.year();
                }
            }
            else if(dr.CA_Bundle_Avail_Date__c!=null){
                yearr=dr.CA_Bundle_Avail_Date__c.year();
            }
            else if(dr.US_Bundle_Avail_Date__c!=null){
                yearr=dr.US_Bundle_Avail_Date__c.year();
            }
            for(Product__c p:dr.Products__r)
            {
                Blob b1 = Crypto.GenerateAESKey(128);
                String h1 = EncodingUtil.ConvertTohex(b1);
                String unique2 = h1.SubString(0,8)+ '-' + h1.SubString(8,12) + '-' + h1.SubString(12,16) + '-' + h1.SubString(16,20) + '-' + h1.substring(20);
                system.debug('****Crosref Unique 1 '+unique2);
                
                Blob b2 = Crypto.GenerateAESKey(128);
                String h2 = EncodingUtil.ConvertTohex(b2);
                String unique3 = h2.SubString(0,8)+ '-' + h2.SubString(8,12) + '-' + h2.SubString(12,16) + '-' + h2.SubString(16,20) + '-' + h2.substring(20);
                system.debug('**** Crosref Unique 1 '+unique3);
                String inpp='';
                String parentUniqueId=unique2+','+unique3;
                if(prodName==true || prodShtName==true || ProdBndlSynops==true){
                    if(input2==''){
                        input2=',{"type": "CrossRef","linkId": "'+unique2+'","currentRequestType": {"masterRequestType": "CrossRef", "requestType": "CrossRef"},"operation": "ED","data": { "titleId_s": "'+dr.Bundle_SYSGEN__c+'", "sourceDesc": "DGF","crossRefNameDelimited": "'+p.Short_Name__c+'","crossRefShortName": "'+p.Short_Name__c+'","crossRefNumber_s": "'+p.id+'" },"parentLinkId": "'+unique1+'"}';
                        
                        inpp=',{"type": "CrossRef","linkId": "'+unique3+'","currentRequestType": {"masterRequestType": "CrossRef","requestType": "CrossRef"},"operation": "ED",'
                            +'"data": {"titleId_s": "'+dr.Bundle_SYSGEN__c+'","crossRefNumber_s": "'+p.Bundle_ID__c+'","sourceDesc": "BDLF","crossRefNameDelimited": "'+p.name+'","versionNameDelimited": "All Media"}, "parentLinkId": "'+unique1+'" }';
                        
                        String synop=',{"type": "Synopsis","currentRequestType": {"masterRequestType": "Title", "requestType": "Synopsis"},"operation": "ED","data": { "languageDesc": "ENG","synopsisText": "'+p.Bundle_Synopsis__c+'"},"parentLinkId": "'+parentUniqueId+'"}';
                        
                        input2=input2+inpp+synop;
                    }
                    else{
                        input2=input2+',{"type": "CrossRef","linkId": "'+unique2+'","currentRequestType": {"masterRequestType": "CrossRef", "requestType": "CrossRef"},"operation": "ED","data": { "titleId_s": "'+dr.Bundle_SYSGEN__c+'", "sourceDesc": "DGF","crossRefNameDelimited": "'+p.Short_Name__c+'","crossRefShortName": "'+p.Short_Name__c+'", "crossRefNumber_s": "'+p.id+'" },"parentLinkId": "'+unique1+'"}';
                        
                        inpp=',{"type": "CrossRef","linkId": "'+unique3+'","currentRequestType": {"masterRequestType": "CrossRef","requestType": "CrossRef"},"operation": "ED",'
                            +'"data": {"titleId_s": "'+dr.Bundle_SYSGEN__c+'","crossRefNumber_s": "'+p.Bundle_ID__c+'","sourceDesc": "BDLF","crossRefNameDelimited": "'+p.name+'","versionNameDelimited": "All Media"}, "parentLinkId": "'+unique1+'" }';
                        
                        String synop=',{"type": "Synopsis","currentRequestType": {"masterRequestType": "Title", "requestType": "Synopsis"},"operation": "ED","data": { "languageDesc": "ENG","synopsisText": "'+p.Bundle_Synopsis__c+'"},"parentLinkId": "'+parentUniqueId+'"}';
                        
                        input2=input2+inpp+synop;
                    }
                }
                inp='{"type": "Title",  "linkId": "'+unique1+'","currentRequestType": {"masterRequestType": "Title","requestType": "Title"},"operation": "ED",'
                    +'"data": {"titleId_s": "'+dr.Bundle_SYSGEN__c+'","productType": "CMPL","levelTagDesc": "TITLE","releaseStatusDesc": "REL","titleNameDelimited": "'+dr.name+'","originalMarket":"EDU","productionYear":"'+yearr+'"}}';
                
                input3=input3+']}'; 
                
            }
            input=input+input1+inp+input2+inputBundleGenre+inputDt+inputDt1+inputDt2+inputDt3+inputDt4+input3;
            System.debug('**Final**'+input);
            HttpRequest req=new HttpRequest();
            // req.setHeader('api_key', '7jj2x58pau9aj92krzm47x9s');
            req.setHeader('api_key', '{!$Credential.Password}');
            req.setEndpoint('callout:GTM_API'); 
            req.setHeader('Content-Type', 'application/json');
            req.setBody(input);
            req.setTimeout(120000);
            req.setMethod('POST');
            //  req.setEndpoint('https://qa-api.nbcuniversal.com/gtm/qa/v1/beta/GTMUpdateRequest');         
            Http ht=new Http();
            HttpResponse rep=new HttpResponse();
            String error1='';
            try{
                
                rep=ht.send(req);
            }catch(Exception ex)
            {
                error1= ex.getMessage();
                System.debug('**exception**'+ex.getMessage());
                for(integer i=0; i<=5; i++)
                {
                    if(error1=='Read timed out')
                    { 
                        try{
                            rep=ht.send(req);
                        }
                        catch(Exception e)
                        {
                            error1= e.getMessage();
                            System.debug('**i**'+i);
                            
                        }
                    }
                    
                }
                
            }
            System.debug('**resp**'+rep.getBody());
            
            String s = rep.getBody();
            Map<String,Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(s);
            String Error = JSON.serialize(jsonMap.get('Error'));
            String DGFId = JSON.serialize(jsonMap.get('DGF Release ID'));
            String ExtId = JSON.serialize(jsonMap.get('External Request ID'));
            String sysGen = JSON.serialize(jsonMap.get('SysGen'));
            String status = JSON.serialize(jsonMap.get('Status'));
            String message =JSON.serialize(jsonMap.get('Message'));
            Digital_Release_Integration_Response__c DRI=new Digital_Release_Integration_Response__c();
            DRI.GTM_Message__c=Error.removeEnd('"').removestart('"');
            if(message != 'Null')
                DRI.GTM_Message__c =message.removeEnd('"').removestart('"');
            DRI.Status__c=status.removeEnd('"').removestart('"');
            DRI.Requested_Id__c=JSON.serialize(jsonMap.get('External Request ID'));
            if(DGFId!='null')
            DRI.Digital_Release__c=DGFId.removeEnd('"').removestart('"');
            system.debug('***before DRI insert');
            //DRI.Bundle_SYSGEN__c=sysGen.removeEnd('"').removestart('"');
            insert DRI;
            system.debug('***After DRI insert'+dri);
        }
    }
    // Scenario 5
    
    @future(callOut=true)   
    global static void SendDigitalReleaseWithProductsAfterBundle_SYSGEN_Update(String JsonString,String digReleaseId){ 
        //===============================================
        //
        //
        //==================================================
        
        System.debug('**Final**'+JsonString);
        HttpRequest req=new HttpRequest();
        //req.setHeader('api_key', '7jj2x58pau9aj92krzm47x9s');
        req.setHeader('api_key', '{!$Credential.Password}');
        req.setEndpoint('callout:GTM_API'); 
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JsonString);
        req.setTimeout(120000);
        req.setMethod('POST');
        //  req.setEndpoint('https://qa-api.nbcuniversal.com/gtm/qa/v1/beta/GTMUpdateRequest');         
        Http ht=new Http();
        HttpResponse rep=new HttpResponse();
        String error1='';
        try{            
            rep=ht.send(req);
        }catch(Exception ex)
        {
            error1= ex.getMessage();
            System.debug('**exception**'+ex.getMessage());
            for(integer i=0; i<=5; i++)
            {
                if(error1=='Read timed out')
                { 
                    try{
                        rep=ht.send(req);
                    }
                    catch(Exception e)
                    {
                        error1= e.getMessage();
                        System.debug('**i**'+i);
                        
                    }
                }
                
            }
            
        }
        System.debug('**resp**'+rep.getBody());
        
        String s = rep.getBody();
        
        
        Map<String,Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(s);
        String Error = JSON.serialize(jsonMap.get('Error'));
        String DGFId = JSON.serialize(jsonMap.get('DGF Release ID'));
        String ExtId = JSON.serialize(jsonMap.get('External Request ID'));
        String sysGen = JSON.serialize(jsonMap.get('SysGen'));
        String status = JSON.serialize(jsonMap.get('Status'));
        String message =JSON.serialize(jsonMap.get('Message'));
        
        List<product__c> lpList2=new List<product__c> ();
        List<product__c> lpList=[select id,JSON_Send__c from Product__c where Digital_Release__c=:digReleaseId];
        for(product__c pd:lpList){
            if(pd.JSON_Send__c==false){
                pd.JSON_Send__c=true;
                lpList2.add(pd);
            }
            
        }
        update lpList2;
        system.debug('***After insert lpList '+lpList);        
        Digital_Release_Integration_Response__c DRI=new Digital_Release_Integration_Response__c();
        DRI.GTM_Message__c=Error.removeEnd('"').removestart('"'); 
        if(message != 'Null')
            DRI.GTM_Message__c =message.removeEnd('"').removestart('"');
        DRI.Requested_Id__c=JSON.serialize(jsonMap.get('External Request ID'));
        IF(DGFId!='null')
        DRI.Digital_Release__c=DGFId.removeEnd('"').removestart('"');
        DRI.Status__c=status.removeEnd('"').removestart('"');
        insert DRI;    
        
    }    
}