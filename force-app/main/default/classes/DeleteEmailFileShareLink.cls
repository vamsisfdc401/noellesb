/*****************************************************************************************
Class Name: DeleteEmailFileShareLink
Purpose: This class Deletes the link between Email messages to the email attachment(document)
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             09/06/2018           Ashok Raghavan          Initial Development(GBS 763)
******************************************************************************************/
global class DeleteEmailFileShareLink implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
    		
        List<DeleteFileShareLinkbyLibrary__c> ListLibrary = DeleteFileShareLinkbyLibrary__c.getall().Values();
		List<String> LibraryNameList = new List<String>();
		for(DeleteFileShareLinkbyLibrary__c LibraryName:ListLibrary )
			{
    			LibraryNameList.add(LibraryName.Name);
			}

		Set<ID> workspaceIds = new set<ID>();
		List<ContentWorkspace> workspaceIdList = [SELECT Id FROM ContentWorkspace WHERE Name = :LibraryNameList];
		for(ContentWorkspace workspace:workspaceIdList )
			{
   			 	workspaceIds.add(workspace.Id);
			}

        String query = 'SELECT ContentDocumentId,Title FROM ContentVersion WHERE ContentDocument.ParentId = :workspaceIds  and FileType =\'PDF\'';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<ContentVersion> DocList) {
        
        If (!DocList.isempty() || Test.isRunningTest())
        {
       				List<ID> ContentIds = new List<ID>();
					for(ContentVersion Doc:DocList ) 
						{
   								ContentIds.add(Doc.ContentDocumentId) ;
							}
			List <ContentDocumentLink> allDocumentLink =  [Select Id, LinkedEntityId from ContentDocumentLink where ContentDocumentId IN :ContentIds];
			
            If (!allDocumentLink.isempty() || Test.isRunningTest())
            {
            List<ID> LinkIdstoDelete = new List<ID>();
			for (ContentDocumentLink Link:allDocumentLink)
				{
   					If (String.valueOf(Link.LinkedEntityId.getSObjectType()) == 'EmailMessage')
   						{
       						LinkIdstoDelete.add(Link.id);
   						}
				}
            If (!LinkIdstoDelete.isempty() )
            {
            		List <ContentDocumentLink> DocumentLinktoDelete = [Select Id from ContentDocumentLink where Id IN :LinkIdstoDelete];
    			If (!DocumentLinktoDelete.isempty())
                {
                		delete DocumentLinktoDelete;
                }
            }
            }
  		   }   
    	}
    
    global void finish(Database.BatchableContext BC) {
    }
}