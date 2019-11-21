/***********************************************************************************
Class Name: DGF_SystemModeUtility
Purpose: Utility class for executing logic in without sharing mode
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             27/06/2017           Mohit                    Initial Development
******************************************************************************************/
public without sharing class DGF_SystemModeUtility{
    
    @testVisible private static string testChatterGroup = 'TEST CLASS CHATTER GROUP';
    
    /***********************************
    Method Name: changeReleaseAccessLevelAndSendEmail
    Purpose: change access level when release is cancelled
    ***********************************/
    public static void changeReleaseAccessLevelAndSendEmail(){
        
        //instantiating variables
        Digital_Release__c dgOld = new Digital_Release__c();
        Set<ID> setReleaseID = new Set<ID>();  
        List<Digital_Release__Share> insertShareRecords = new List<Digital_Release__Share>();
        List<CollaborationGroup> chatterGroupId = new List<CollaborationGroup>();
        List<CollaborationGroupMember> chatterGroupMembers = new List<CollaborationGroupMember>();
        //Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Map<id,List<product__c>> dgProductMap = new Map<id,List<product__c>>();
        Map<id,List<EPO_Bonus__c>> dgBonusMap = new Map<id,List<EPO_Bonus__c>>();
        Map<id,List<Promotion_Product__c>> productPromotionsMap = new Map<id,List<Promotion_Product__c>>();
        
        //getting ID of chatter group 
        if(Test.isRunningTest()){
            chatterGroupId = [SELECT Id,Name From CollaborationGroup WHERE Name =:testChatterGroup];
        }else{
            chatterGroupId = [SELECT Id,Name From CollaborationGroup WHERE Name =:DGF_Constants.DD_PRODUCT_USER_CHATTER_GROUP OR NAME=:DGF_Constants.DD_OPS_USER_CHATTER_GROUP OR NAME=:DGF_Constants.DD_ACCOUNT_USER_CHATTER_GROUP];
        }        
        
        //getting details of chatter group members
        chatterGroupMembers = [Select MemberId,Member.name,Member.Email,CollaborationGroup.Name from CollaborationGroupMember where CollaborationGroupId in: chatterGroupId];
        
        //mailingids of group members
        List<String> mailingIdsProductGroup = new List<String>();
        
        for(CollaborationGroupMember grpMember : chatterGroupMembers){
        	//if((grpMember.CollaborationGroup.Name == DGF_Constants.DD_PRODUCT_USER_CHATTER_GROUP) || (Test.isRunningTest())){
        		mailingIdsProductGroup.add(grpMember.Member.Email);
        	//}
        } 
        
        list<id> cancelledReleases = new list<id>();
        
         for(Digital_Release__c dg : (List<Digital_Release__c>)trigger.new){            
            //if old status was not cancelled and new release status is cancelled
            dgOld = (Digital_Release__c) Trigger.OldMap.get(dg.Id);
            if(dg.Release_State__c == DGF_Constants.CANCELLED && dgOld.Release_State__c != DGF_Constants.CANCELLED){
            	cancelledReleases.add(dg.id);
            }            
         }
         
         //getData for Email DFOR-518
         if(cancelledReleases!=null && cancelledReleases.size()>0){
         	set<product__c> prodIdSet =  new set<product__c>();
         	list<digital_release__c> cancelledDigiReleaseList = [select id, (select id, name from Products__r), (Select Id, Name From EPO_Bonus__r) from digital_release__C where id in : cancelledReleases];
         	if(cancelledDigiReleaseList!=null && cancelledDigiReleaseList.size()>0){
         		for(digital_release__c dr : cancelledDigiReleaseList){
         			if(dr.Products__r!=null && dr.Products__r.size()>0){
         				dgProductMap.put(dr.id, dr.Products__r);
         				prodIdSet.addAll(dr.Products__r);
         			}
         			
         			if(dr.EPO_Bonus__r!=null && dr.EPO_Bonus__r.size()>0){
         				dgBonusMap.put(dr.id, dr.EPO_Bonus__r);
         			}
         		}
         	}
         	
         	//promoProd
         	list<Promotion_Product__c> promoProdList = [Select Promotion__r.Name, Promotion__c, Product__c, Id From Promotion_Product__c where Product__c in : prodIdSet and Promotion__r.Name!=null];
         	if(promoProdList!=null && promoProdList.size()>0){
         		for(Promotion_Product__c pr : promoProdList){
         			if(productPromotionsMap.containsKey(pr.Product__c)){
         				list<Promotion_Product__c> tempList = productPromotionsMap.get(pr.Product__c);
         				tempList.add(pr);
         				productPromotionsMap.put(pr.Product__c, tempList);
         			}else{
         				productPromotionsMap.put(pr.Product__c, new list<Promotion_Product__c>{pr});
         			}
         		}
         	}         	
         	
         }
        
        //looping over new instance of records
        for(Digital_Release__c dg : (List<Digital_Release__c>)trigger.new){
            
            //getting old instance of record
            dgOld = (Digital_Release__c) Trigger.OldMap.get(dg.Id);
            
            //if old status was not cancelled and new release status is cancelled
            if(dg.Release_State__c == DGF_Constants.CANCELLED && dgOld.Release_State__c != DGF_Constants.CANCELLED /*&& FilmRecTypeId == dg.RecordTypeId*/){
                //looping over group members
                for(CollaborationGroupMember grpMember : chatterGroupMembers){
                    //if product user then only create share record
                    if((grpMember.CollaborationGroup.Name == DGF_Constants.DD_PRODUCT_USER_CHATTER_GROUP && grpMember.MemberId != dg.OwnerId) || (Test.isRunningTest() && grpMember.MemberId != dg.OwnerId)){                        
                        //creating instance digital share object
                        Digital_Release__Share dgShare = new Digital_Release__Share();
                        
                        dgShare.AccessLevel = 'Edit';
                        dgShare.ParentID = dg.Id;                        
                        dgShare.UserOrGroupId = grpMember.MemberId;                            
                        
                        //adding instance to list
                        insertShareRecords.add(dgShare);  
                    } 
                }
                // Sending email with details by clubbing group members into a single mail.
                //creating email instance DFOR-518
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setSubject('Digital release ' + dg.Name + ' ' + DGF_Constants.CANCELLED);                  
				mail.setToAddresses( mailingIdsProductGroup);
				set<id> promotionIdSet = new set<id>();
				
				//setting email body
				string strEmailBody = '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + dg.Id + '">' + dg.Name + '</a>' + ' has been cancelled. Please update/remove records associated to the release.'; 
				if(dgProductMap.containsKey(dg.id)){
					strEmailBody = strEmailBody + '<br><br>';
					strEmailBody = strEmailBody + 'Product(s): <br>';
					for(product__C prod : dgProductMap.get(dg.id)){
						strEmailBody = strEmailBody + '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + prod.Id + '">' + prod.Name + '</a>' + '<br>';
					}
					
					integer i=0;
					for(product__C prod : dgProductMap.get(dg.id)){
						
						 if(productPromotionsMap.containsKey(prod.id)){
						 	if(i==0){
						 		strEmailBody = strEmailBody + '<br>';
								strEmailBody = strEmailBody + 'Promotion(s): <br>';
						 	}i++;
						 	
							for(Promotion_Product__c pr : productPromotionsMap.get(prod.id)){
								if(!promotionIdSet.contains(pr.Promotion__c)){
						 			promotionIdSet.add(pr.Promotion__c);
						 			strEmailBody = strEmailBody + '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + pr.Promotion__c + '">' + pr.Promotion__r.Name + '</a>' + '<br>';
						 		}						 	
							}							
						 }
					}
				} 
				if(dg.recordtype.name != DGF_Constants.BUNDLE){ 
					if(dgBonusMap.containsKey(dg.id)){
						strEmailBody = strEmailBody + '<br> Bonus: <br>';
						for(EPO_Bonus__c bonus : dgBonusMap.get(dg.id)){
							strEmailBody = strEmailBody + '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + bonus.Id + '">' + bonus.Name + '</a>' + '<br>';
						}
					}
				}
				
				mail.setHtmlBody(strEmailBody); 
				mails.add(mail); 
            }            
        } 
        
        //sending email notification
        if(!mails.isEmpty()){
            Messaging.sendEmail(mails);
        }
        
        //inserting record share
        if(!insertShareRecords.isEmpty()){
            insert insertShareRecords;
        }       
    }    
    
    /***********************************
    Method Name: addSharingForGroupMember
    Purpose: when a new member is added to product user group
    ***********************************/
    public static void addSharingForGroupMember(){
        
        //creating list to be inserted
        List<Digital_Release__Share> insertShareRecords = new List<Digital_Release__Share>();
        //Id FilmRecTypeId = Schema.SObjectType.Digital_Release__c.getRecordTypeInfosByName().get(DGF_Constants.FILM).getRecordTypeId();
        List<CollaborationGroupMember> lstGrpMember = new List<CollaborationGroupMember>();
        
        //getting group member details
        if(Test.isRunningTest()){
            lstGrpMember = [Select MemberId,Member.name,Member.Email,CollaborationGroup.Name from CollaborationGroupMember where CollaborationGroup.Name =:testChatterGroup AND ID in: Trigger.NewMap.keySet()];
        }else{
            lstGrpMember = [Select MemberId,Member.name,Member.Email,CollaborationGroup.Name from CollaborationGroupMember where CollaborationGroup.Name =: DGF_Constants.DD_PRODUCT_USER_CHATTER_GROUP AND ID in: Trigger.NewMap.keySet()];
        }        
        
        //looping over digital release
        for(Digital_Release__c dg : [Select id,name,Release_State__c,OwnerId,recordtypeid from Digital_Release__c where Release_State__c =: DGF_Constants.CANCELLED order by createdDate desc limit 5000]){
            for(CollaborationGroupMember grpMember : lstGrpMember){
                //if product user then only create share record
                if((grpMember.CollaborationGroup.Name == DGF_Constants.DD_PRODUCT_USER_CHATTER_GROUP /*&& FilmRecTypeId == dg.RecordTypeId*/ && grpMember.MemberId != dg.OwnerId) || (Test.isRunningTest() && grpMember.MemberId != dg.OwnerId)){
                    //creating instance digital share object
                    Digital_Release__Share dgShare = new Digital_Release__Share();
                    
                    dgShare.AccessLevel = 'Edit';
                    dgShare.ParentID = dg.Id;                        
                    dgShare.UserOrGroupId = grpMember.MemberId;                            
                    
                    //adding instance to list
                    insertShareRecords.add(dgShare); 
                }
            }
        }   
        
        //inserting record share
        if(!insertShareRecords.isEmpty()){
            insert insertShareRecords;
        }        
    }
    
    /***********************************
    Method Name: removeSharingForGroupMember
    Purpose: when a member is removed from product user group
    ***********************************/
    public static void removeSharingForGroupMember(){
        //set of storing member id
        Set<Id> setMemberId = new Set<Id>();
        
        //creating a set of member ids
        for(CollaborationGroupMember grpMember : (List<CollaborationGroupMember>)Trigger.old){
            if(!setMemberId.contains(grpMember.MemberId)){
                setMemberId.add(grpMember.MemberId);
            }            
        }
        
        //getting share records to delete
        List<Digital_Release__Share> lstDGShare =  [Select Id,AccessLevel,ParentID,RowCause,UserOrGroupId from Digital_Release__Share where UserOrGroupId in:setMemberId AND RowCause = 'Manual'];
        
        //deleting share records
        if(!lstDGShare.isEmpty()){
            delete lstDGShare;
        }        
    }
}