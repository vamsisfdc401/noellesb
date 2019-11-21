/*****************************************************************************************
Class Name: DGF_ExceptionLogController
Purpose: Controller for logging Exceptions
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             31/05/2017           Prarthana                Initial Development
******************************************************************************************/
public  class DGF_ExceptionLogController{  
      /***********************************
      Method Name: createExceptionLog
      Purpose: method to create Exception Log
      ***********************************/
      public static void createExceptionLog(String evnt,String src,String error) {
          Exception_Log__c excep=new Exception_Log__c(Event__c=evnt,Source__c=src,Error_Message__c=error,User__c=UserInfo.getUserName());
          database.insert(excep);
      }
}