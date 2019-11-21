/*****************************************************************************************
Class Name: VProjectRecordInlinePageHandler
Purpose: This class is the extension controller of VProject Inline page. 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             31/08/2016           Durgesh                  Initial Development
******************************************************************************************/
public class VProjectRecordInlinePageHandler {
    
    // Local variables.
    public String releaseID;
    public v_Project_Request__c newVp{get;set;}
    public list<Release_Material__c> relMatRec;
    public list<v_Project_Request__c> vProjrec{get;set;}
    public Boolean refreshPage { get; set; }
    
    // Extension constructor.
    public VProjectRecordInlinePageHandler(ApexPages.StandardController controller) {
        
        releaseID = apexpages.currentpage().getparameters().get('id');    
        refreshPage=false;
        
        vProjRec= [select id,Total_Allocation_Percentage__c,Release__c from v_Project_Request__c where ID =:releaseID limit 1];
        
    }
    
    // Retreiving Release Material.
    public list<Release_Material__c> getMatReleases(){
        
        relMatRec = [select id,Allocation_Percentage__c,Material__r.Material_Type__c,Material__r.Name,Material__r.Material_Number__c 
                     from Release_Material__c where Release__c=: vProjRec[0].Release__c AND Material__r.Material_Type__c='FERT'];
        
        return relMatRec ;
    }
    
    // Following method updates V-Project request.
    public PageReference updaVprojectandRelMat(){
        
        decimal tolal =0;
        
        for(Release_Material__c each :relMatRec){
            if(each.Allocation_Percentage__c>0)
                tolal = tolal + each.Allocation_Percentage__c;
        }
        
        if (tolal > 100) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,'Please Check Total Allocated.')); 
        }
        else{
            Update relMatRec; 
            
            if(vProjrec.size()>0){
                vProjrec[0].Total_Allocation_Percentage__c = tolal ;
                update vProjrec;  
            }  
        }
        refreshPage=true; 
        return null;   
    }
    
    // Below method handles cancel event.
    public PageReference cancel() {       
        refreshPage=true;
        return null;
    }
}