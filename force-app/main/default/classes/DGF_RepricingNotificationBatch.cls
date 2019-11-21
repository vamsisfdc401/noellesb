/***********************************************************************************
Class Name: DGF_RepricingNotificationBatch
Purpose: DFOR-417 - Batch class for notifying the repricing
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             30/10/2017           Prarthana                Initial Development
******************************************************************************************/
global with sharing class DGF_RepricingNotificationBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    /***********************************
	Method Name: start
	Purpose: method to query Promotion Products created today
	***********************************/
    global list<Promotion_Product__c> start(Database.BatchableContext BC) {
        //query all Promotion Products created today
        list<Promotion_Product__c> promoPrdList = new list<Promotion_Product__c>();
        if(!Test.isRunningTest()){
        	 promoPrdList=[Select ID, Product__c, Promotion__c, Promotion__r.CreatedBy.Name, CreatedBy.Id, 
                                                 TPR_Start_Date__c, TPR_End_Date__c, TPR__c, CreatedDate From Promotion_Product__c where 
                                                 CreatedDate= TODAY AND TPR__c = true];
        }
        else{
             promoPrdList=[Select ID, Product__c, Promotion__c, Promotion__r.CreatedBy.Name, CreatedBy.Id, 
                                                 TPR_Start_Date__c, TPR_End_Date__c, TPR__c, CreatedDate From Promotion_Product__c where 
                                                 CreatedDate= TODAY AND TPR__c = true and CreatedBy.UserName = 'TestConnectedBatchPromotionProduct@product.com'];
            
        }
        system.debug('vv'+promoPrdList);
        return promoPrdList;
    }
    /***********************************
	Method Name: execute
	Purpose: method to notify of the reprice records
	***********************************/
    global void execute(Database.BatchableContext BC, List<Promotion_Product__c> promoPrdList){
        set<ID>prodIdSet = new set<Id>();
        list<Pricing__c>priceList = new list<Pricing__c>();
        map<Id,set<String>> repriceMap = new map<Id,set<String>>();
        map<Id,Id>promoMap = new map<Id,Id>();
        //iterate over the Promotion Products and prepare set of Product ids
        for(Promotion_Product__c promoPrd:promoPrdList) {
            prodIdSet.add(promoPrd.Product__c);
            promoMap.put(promoPrd.Promotion__c,promoPrd.Promotion__r.CreatedById);
        }
        //query for the Reprice records associated to the Products in the set
        priceList = [SELECT ID, Valid_From__c, Valid_to__c, Product__c, Product__r.Name FROM Pricing__c where Price_Type__c='Reprice' AND 
                     Account__c=:null AND Product__C IN:prodIdSet];
        
        
        for(Promotion_Product__c promoProd : promoPrdList) {    
            for(Pricing__c pr:priceList) {
                if(pr.Product__c == promoProd.Product__c) {
                    //check if the reprice records falls within TPR Start and End Date
                    if (pr.valid_from__c != null &&  promoProd.TPR_Start_Date__c !=null  &&  promoProd.TPR_End_Date__c !=null) {
                        if(pr.valid_from__c >= promoProd.TPR_Start_Date__c && pr.Valid_From__c <= promoProd.TPR_End_Date__c) {
                            if(!repriceMap.containsKey(promoProd.Promotion__c)) {
                                repriceMap.put(promoProd.Promotion__c,new set<String>{pr.Product__r.name+'-->'+' on '+pr.valid_from__c.month()+'/'+pr.Valid_From__c.day()+'/'+pr.Valid_From__c.year()});
                            }
                            else {
                                set<String>pricesList=repriceMap.get(promoProd.Promotion__c);
                                pricesList.add(pr.Product__r.name+'-->'+' on '+pr.valid_from__c.month()+'/'+pr.Valid_From__c.day()+'/'+pr.Valid_From__c.year());
                            }
                        }
                    }
                }
            }
        }
        //iterate over the Promotions to post the chatter message
        for(Id prId : promoMap.keySet()) {
            if(repriceMap.containsKey(prId)) {
                
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
                ConnectApi.MarkupEndSegmentInput markupEndSegment;
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                mentionSegmentInput.id = promoMap.get(prId);
                messageBodyInput.messageSegments.add(mentionSegmentInput);
                
                markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
                messageBodyInput.messageSegments.add(markupBeginSegment);
                
                textSegmentInput.text = 'The following products will be repriced during this Promotion: \n';
                
                messageBodyInput.messageSegments.add(textSegmentInput);
                textSegmentInput = new ConnectApi.TextSegmentInput();
                textSegmentInput.text = '';
                
                set<String>repriceSet = repriceMap.get(prId);
                
                for(String s:repriceSet) {
                    list<String> prd = s.split('-->');
					//to display in next line
                    markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                    markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
                    messageBodyInput.messageSegments.add(markupBeginSegment);
                    //to make the Product Name bold
                    markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
                    markupBeginSegment.markupType = ConnectApi.MarkupType.Bold;
                    messageBodyInput.messageSegments.add(markupBeginSegment);
                    //add the Product Name
                    textSegmentInput = new ConnectApi.TextSegmentInput();
                    textSegmentInput.text ='';
                    textSegmentInput.text += prd[0];
                    messageBodyInput.messageSegments.add(textSegmentInput); 
                    
                    textSegmentInput = new ConnectApi.TextSegmentInput();
                    textSegmentInput.text ='';
                    
                    markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                    markupEndSegment.markupType = ConnectApi.MarkupType.Bold;
                    messageBodyInput.messageSegments.add(markupEndSegment);
                    //add the Valid from Date
                    textSegmentInput.text += prd[1];
                    messageBodyInput.messageSegments.add(textSegmentInput); 
                    
                    markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                    markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
                    messageBodyInput.messageSegments.add(markupEndSegment);
                }
                markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
                markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
                messageBodyInput.messageSegments.add(markupEndSegment);
                
                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                feedItemInput.subjectId = prId;
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
            }
            
            
        }
    }
    global void finish(Database.BatchableContext BC){
    }
}