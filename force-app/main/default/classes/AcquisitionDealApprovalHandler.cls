/*****************************************************************************************
Class Name: AcquisitionDealApprovalHandler 
Purpose: Apex class to check the mandatory conditions before submitting the deal for approval
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             5/10/2016           Ashwini Gnanamurthy      Initial Development
******************************************************************************************

Version         DateModified         ModifiedBy               Change
1.0             22/2/2018           Elavarasan               Development Changes
******************************************************************************************/
public class AcquisitionDealApprovalHandler {
    
    Public Acquisition_Deal__c currentDeal {get; set;} 
    Public Boolean allMandatoryFieldsPresent {get; set;}
    Public Boolean dealDead{get; set;}
    Public Boolean dealOnHold{get; set;}
    
    /************************************
    Method Name: AcquisitionDealApprovalHandler
    Purpose: Constructor
    *************************************/ 
    public AcquisitionDealApprovalHandler(ApexPages.StandardController controller) {
        currentDeal = new Acquisition_Deal__c();
        this.currentDeal= (Acquisition_Deal__c )controller.getrecord();
    }

    /************************************
    Method Name: submitAndProcessApprovalRequest
    Purpose: Method that checks if Genre, MG and Deal Level are entered prior to submitting the deal for approval
    *************************************/    
    public void submitAndProcessApprovalRequest() {    
        
        currentDeal =[Select id, On_Hold__c, Dead__c,Genre__c, Acq_Deal_Level__c, MG_Currency__c from Acquisition_Deal__c where id=:currentDeal.id];
        if(currentDeal.Acq_Deal_Level__c!=NULL && currentDeal.Genre__c!=NULL && currentDeal.MG_Currency__c!=NULL){
            allMandatoryFieldsPresent= true;              
        }else{
            allMandatoryFieldsPresent = false;
        }
        dealDead = false;
        dealOnHold = false;
        if(currentDeal.Dead__c==true){
            dealDead= true;
        }
        if(currentDeal.On_Hold__c==true){
            dealOnHold= true;
        }
        try{
        if(allMandatoryFieldsPresent==true && dealDead==false && dealOnHold==false){
            // Create an approval request for the account
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting deal for approval.');
            req.setObjectId(currentDeal.id);
            
            // Submit on behalf of a specific submitter
            req.setSubmitterId(UserInfo.getUserId()); 
            
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req);
               
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'The deal has been submitted for approval successfully, please click the link below to return to the deal!'));         
        }
        
         else if(dealDead==true){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Deal is locked for edits as it has been cancelled, please uncheck "Deal Cancelled" to enable edit on deal!'));
        } else if(dealOnHold==true){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Deal is locked for edits as it has been put on hold, please uncheck "Put Deal On Hold" to enable edit on deal!'));            
        }
        
         else{
            //currentDeal.addError('');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The following fields are required to drive the approval workflow : MG, Acq Deal Level and Genre, please fill these fields and resubmit!'));  
        }}
        
        catch(exception e)
        {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This Acquisition Deal has been already submitted for approval and is currently not available for resubmission.'));}
        // Verify the result
        //System.assert(result.isSuccess());
                        
    }
    
    /************************************
    Method Name: returnToDeal
    Purpose: Method to return back to the deal
    *************************************/   
    public PageReference returnToDeal(){
            PageReference dealpage= New PageReference('/'+currentDeal.id);
            return dealpage;
    }
    
}