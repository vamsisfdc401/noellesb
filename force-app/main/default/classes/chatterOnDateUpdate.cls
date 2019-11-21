/*****************************************************************************************
Class Name: chatterOnDateUpdate
Purpose: This class handles the business logic to add chatter post when 
date is updated on material.
******************************************************************************************/ 
public class chatterOnDateUpdate{
    public static void chatterOnMaterialDateUpdate(List<Release__c> relList){
        //Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        List<Release__c> matToUpdateList = new List<Release__c>();
        List<CollaborationGroup> g1 = new List<CollaborationGroup>();
            String pGroup = 'SELECT Id,Name From CollaborationGroup WHERE Name IN (\'UPHE Tech Ops\',\'Universal New Release Planning\',\'Universal Catalog Planning group\',\'UPHE Biz Comm\')';
        g1 = Database.Query(pGroup);
        for(Release__c rel : relList){
            if((rel.Label_Code__c == '24 - PURE FLIX' || rel.Label_Code__c == '34 - Film Arcade' || rel.Label_Code__c == '44 - GKIDS' || rel.Label_Code__c == '45 - PICTUREHOUSE' || rel.Label_Code__c == '46 - DREAMWORKS ANIMATION' 
                || rel.Label_Code__c == '55 - Open Road Films' || rel.Label_Code__c == '57 - BLEECKER STREET' || rel.Label_Code__c == '58 - HiT Entertainment' || rel.Label_Code__c == '61 - Universal Pictures' || rel.Label_Code__c == '62 - Focus' || rel.Label_Code__c == '63 - Family Home Entertainment'
                || rel.Label_Code__c == '64 - STX FINANCING LLC' || rel.Label_Code__c == '91 - AVIRON PICTURES' || rel.Label_Code__c == '36 - NEON RATED LLC')){
                if(rel.street_date__c != ((Release__c)trigger.oldMap.get(rel.id)).street_date__c){
                    system.debug('inside if');
                    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                    ConnectApi.MentionSegmentInput mentionSegmentInput2 = new ConnectApi.MentionSegmentInput();
                    ConnectApi.MentionSegmentInput mentionSegmentInput3 = new ConnectApi.MentionSegmentInput();
                    ConnectApi.MentionSegmentInput mentionSegmentInput4 = new ConnectApi.MentionSegmentInput();
                    ConnectApi.MentionSegmentInput mentionSegmentInput5 = new ConnectApi.MentionSegmentInput();
                    ConnectApi.MentionSegmentInput mentionSegmentInput6 = new ConnectApi.MentionSegmentInput();
                    List<ConnectApi.MentionSegmentInput> mentionSegmentInputList = new List<ConnectApi.MentionSegmentInput>();
                    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                    messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();  
                    if(textSegmentInput != null)
                    {
                        messageBodyInput.messageSegments.add(textSegmentInput);
                    }   
                     for(CollaborationGroup g : g1){
                        if(g.Name == 'UPHE Tech Ops'){
                            mentionSegmentInput.id = g.id;
                        }
                        if(g.Name == 'Universal New Release Planning'){
                            mentionSegmentInput4.id = g.id;
                        }
                        if(g.Name == 'Universal Catalog Planning group'){
                            mentionSegmentInput5.id = g.id;
                        }
                        if(g.Name == 'UPHE Biz Comm'){
                            mentionSegmentInput6.id = g.id;
                        }
                    }
                    if(rel.Marketing_Contact__c != null){
                        mentionSegmentInput2.Id = rel.Marketing_Contact__c;
                        messageBodyInput.messageSegments.add(mentionSegmentInput2);
                    }
                    if(rel.Creative_Contact__c != null){
                        mentionSegmentInput3.Id = rel.Creative_Contact__c;
                        messageBodyInput.messageSegments.add(mentionSegmentInput3); 
                    }
                    if(mentionSegmentInput.id != null)
                    {
                        messageBodyInput.messageSegments.add(mentionSegmentInput);
                    }   
                    if(mentionSegmentInput4.id != null)
                    {   
                        messageBodyInput.messageSegments.add(mentionSegmentInput4);
                    }   
                    if(mentionSegmentInput5.id != null)
                    {   
                        messageBodyInput.messageSegments.add(mentionSegmentInput5);
                    }   
                    if(mentionSegmentInput6.id != null)
                    {   
                        messageBodyInput.messageSegments.add(mentionSegmentInput6);
                    }   
                    textSegmentInput.text = 'A date change has been requested';
                    feedItemInput.body = messageBodyInput;
                    feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                    feedItemInput.subjectId = rel.Id;
                    System.debug('*****>Chatter> '+feedItemInput.subjectId+' :: '+messageBodyInput);
                    System.debug('*****>Chatter2> '+messageBodyInput.messageSegments);
                    ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput, null);
                }
            }
        }
        
    }
}