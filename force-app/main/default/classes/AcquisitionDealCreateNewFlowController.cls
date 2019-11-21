/*****************************************************************************************
Class Name: AcquisitionDealCreateNewFlowController
Purpose: Apex class for redirecting users to the cloned deal after users click Finish on the Clone Deal screen
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             26/09/2016           Ashwini Gnanamurthy      Initial Development
******************************************************************************************

******************************************************************************************
Version         DateModified         ModifiedBy               Change
11.0             22/2/2018            Elavarasan               Change in Development
******************************************************************************************/
public with sharing class AcquisitionDealCreateNewFlowController{
    
    /************************************
    Method Name: AcquisitionDealCreateNewFlowController
    Purpose: Constructor
    *************************************/ 
     public AcquisitionDealCreateNewFlowController(ApexPages.StandardController controller) {
    }
    
    public Flow.Interview.Acquisition_Deal_Create_New_Flow_Alike FlowDealAlikeEntry{get;set;}
    
    /************************************
    Method Name: getpRefFinishLocation
    Purpose: Redirect users to the Cloned Deal
    *************************************/ 
    public PageReference getpRefFinishLocation() {      

            String temp = 'home/home.jsp';
            if(FlowDealAlikeEntry!=null) temp = string.valueOf(FlowDealAlikeEntry.newAcquisitionDealId);
            if(temp==null)
            temp = string.valueOf(FlowDealAlikeEntry.inputid);
            PageReference pRef = new PageReference('/' + temp);
            return pRef;

     }
   

}