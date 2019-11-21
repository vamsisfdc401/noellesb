/*****************************************************************************************
Class Name: AcquisitionDealMarkSignedInvokeCont
Purpose: Apex class to update the field Inititate Sign to true to start the Process Builder- Acquisition_Deal_Sign_Deal
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             26/09/2016           Ashwini Gnanamurthy      Initial Development
******************************************************************************************/
public class AcquisitionDealMarkSignedInvokeCont{
    
    Acquisition_Deal__c currentDeal{get; set;}
    Public Boolean canDealBeSigned {get; set;}
    Public Boolean dealDead{get; set;}
    Public Boolean dealOnHold{get; set;}
        
    /************************************
    Method Name: AcquisitionDealMarkSignedInvokeCont
    Purpose: Constructor
    *************************************/ 
    public AcquisitionDealMarkSignedInvokeCont(ApexPages.StandardController controller) {
        currentDeal = (Acquisition_Deal__c)controller.getRecord();        
                     
    }
    
    /************************************
    Method Name: checkCanDealBeSigned
    Purpose: Check if the deal can be signed
    *************************************/
    public void checkCanDealBeSigned(){
        currentDeal = [Select id, On_Hold__c, Dead__c, Initiate_Sign__c,Acquisition_Deal_Status__c,Title_Approved__c,Comps_Approved__c,Financials_Approved__c,Primary_Term_Approved__c,Risk_Compliance_Approved__c from Acquisition_Deal__c where id=:currentDeal.id LIMIT 1];
        ID loggedInUserRole = UserInfo.getUserRoleId();
        ID loggedInUserProfile = UserInfo.getProfileId();
        Boolean canTheLoggedInRoleSignDeal = false;
        if(loggedInUserRole==Label.RoleId_Legal_Team_Member || loggedInUserRole==Label.RoleId_SVP_Legal_and_Business_Affairs || loggedInUserProfile == Label.ProfileId_System_Administrator){
            canTheLoggedInRoleSignDeal = true;
        }
               
        if(currentDeal.Title_Approved__c!=NULL && currentDeal.Primary_Term_Approved__c!=NULL && currentDeal.Financials_Approved__c!=NULL && currentDeal.Risk_Compliance_Approved__c!=NULL && currentDeal.Comps_Approved__c!=NULL){
            canDealBeSigned = true;          
        }      
        else{
            canDealBeSigned = false;  
        } 
        
        dealDead = false;
        dealOnHold = false;
        if(currentDeal.Dead__c==true){
            dealDead= true;
        }
        if(currentDeal.On_Hold__c==true){
            dealOnHold= true;
        }
        if(dealDead==true){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Deal is locked for edits as it has been cancelled, please uncheck "Deal Cancelled" to enable edit on deal!'));
        }else if(dealOnHold==true){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Deal is locked for edits as it has been put on hold, please uncheck "Put Deal On Hold" to enable edit on deal!'));
        }else if(canDealBeSigned==true && canTheLoggedInRoleSignDeal== true && dealOnHold==false && dealDead==false){
            updateInitiateSign();             
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'The deal has been signed, please click the button below to return to the deal!')); 
                  
        }else if(canDealBeSigned==false && canTheLoggedInRoleSignDeal==true){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot sign a deal which does not have an approved board pack!')); 
        } else{
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Deal could not be signed as it can only be signed by SVP Legal and Business Affairs and Legal Team Members!'));         
        }      
    }
    
    /************************************
    Method Name: updateInitiateSign
    Purpose: Update the field Inititate Sign to true to start the Process Builder- Acquisition_Deal_Sign_Deal
    *************************************/ 
    public void updateInitiateSign(){    
        currentDeal.Initiate_Sign__c = true;
        update currentDeal;   
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