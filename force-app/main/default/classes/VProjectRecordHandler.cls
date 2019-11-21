/*****************************************************************************************
Class Name: VProjectRecordHandler 
Purpose: Apex page for vProjectRecord
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             03/09/2016           Durgesh                  Initial Development
******************************************************************************************/
public class VProjectRecordHandler {
    
    public String releaseID;
    public v_Project_Request__c newVp{get;set;}
    public list<Release_Material__c> relMatRec;
    public list<v_Project_Request__c> vProjrec{get;set;}
    public VProjectRecordHandler(ApexPages.StandardController controller) {
        
        releaseID = apexpages.currentpage().getparameters().get('id');
        
        Release__c rRec= [select Name,Street_Date__c from Release__c where Id=:releaseID limit 1];
        
        vProjrec = new list<v_Project_Request__c>();
        newVp = new v_Project_Request__c();     
        relMatRec = new list<Release_Material__c>();
        vProjrec = [select id,Sales_Org__c,Project_Studio__c,Total_Allocation_Percentage__c,SAP_Project_Description__c,
                    POS_Order_End_Date__c,Project_Finish_Date__c,Return_End_Date__c,
                    Project_Category__c,Project_Class__c,Project_Sub_Class__c  from v_Project_Request__c where Release__c =:releaseID ];
        
        if(vProjrec.size()>0){
            newVp.SAP_Project_Description__c = vProjrec[0].SAP_Project_Description__c;
            newVp.Project_Category__c= vProjrec[0].Project_Category__c;
            newVp.Project_Class__c= vProjrec[0].Project_Class__c;
            newVp.Project_Sub_Class__c= vProjrec[0].Project_Sub_Class__c;
            newVp.Project_Studio__c = vProjrec[0].Project_Studio__c ;
            newVp.Sales_Org__c = vProjrec[0].Sales_Org__c ;
            newVp.POS_Order_End_Date__c= vProjrec[0].POS_Order_End_Date__c;
            newVp.Project_Finish_Date__c= vProjrec[0].Project_Finish_Date__c;
            newVp.Return_End_Date__c= vProjrec[0].Return_End_Date__c;
            
        }
        else{
            newVp.SAP_Project_Description__c = rRec.Name;
            if(rRec.Street_Date__c!=null){
                newVp.POS_Order_End_Date__c = rRec.Street_Date__c.Adddays(180);
                newVp.Project_Finish_Date__c = rRec.Street_Date__c.Adddays(240);
                newVp.Return_End_Date__c = rRec.Street_Date__c.Adddays(240);
            } 
            
        }
    }
    
    
    /*****************************************************************
    Method Name: getMatReleases
    Purpose: To get release materials for the release
    ***************************************************************/
    public list<Release_Material__c> getMatReleases(){
        
        relMatRec = [select id,Allocation_Percentage__c,Material__r.Material_Type__c,Material__r.Name,Material__r.Material_Number__c from Release_Material__c where Release__c=: releaseID AND Material__r.Material_Type__c='FERT'];
        
        return relMatRec ;
    }
    
    /*****************************************************************
    Method Name: saveVproject
    Purpose: To save v-Project
    ***************************************************************/ 
    public PageReference saveVproject(){
        if(vProjrec.size()>0){
            
            vProjrec[0].SAP_Project_Description__c = newVp.SAP_Project_Description__c;
            vProjrec[0].Project_Category__c= newVp.Project_Category__c;
            vProjrec[0].Project_Class__c= newVp.Project_Class__c;
            vProjrec[0].Project_Sub_Class__c= newVp.Project_Sub_Class__c;
            vProjrec[0].Release__c = releaseID ;
            vProjrec[0].Project_Studio__c = newVp.Project_Studio__c ;
            vProjrec[0].Sales_Org__c = newVp.Sales_Org__c ;
            vProjrec[0].POS_Order_End_Date__c= newVp.POS_Order_End_Date__c;
            vProjrec[0].Project_Finish_Date__c= newVp.Project_Finish_Date__c;
            vProjrec[0].Return_End_Date__c= newVp.Return_End_Date__c;
            update vProjrec;
            
        }
        else{
            v_Project_Request__c newV =  new v_Project_Request__c();   
            newV.SAP_Project_Description__c = newVp.SAP_Project_Description__c;
            newV.Project_Category__c= newVp.Project_Category__c;
            newV.Project_Class__c= newVp.Project_Class__c;
            newV.Project_Sub_Class__c= newVp.Project_Sub_Class__c;
            newV.Release__c = releaseID ;
            newV.Project_Studio__c = newVp.Project_Studio__c ;
            newV.Sales_Org__c = newVp.Sales_Org__c ;
            newV.POS_Order_End_Date__c= newVp.POS_Order_End_Date__c;
            newV.Project_Finish_Date__c= newVp.Project_Finish_Date__c;
            newV.Return_End_Date__c= newVp.Return_End_Date__c;
            Insert newV;  
        }    
        return null;    
    }
    
    
    /*****************************************************************
    Method Name: updaVprojectandRelMat
    Purpose: To update allocation percentage
    ***************************************************************/ 
    public PageReference updaVprojectandRelMat(){
        
        decimal tolal =0;
        
        for(Release_Material__c each :relMatRec){
            if(each.Allocation_Percentage__c>0)
                tolal = tolal + each.Allocation_Percentage__c;
        }
        
        if (tolal > 100) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please Check Total Allocated.')); 
        }
        else{
            Update relMatRec; 
            
            if(vProjrec.size()>0){
                vProjrec[0].Total_Allocation_Percentage__c = tolal ;
                update vProjrec;  
            }  
        }  
        return null;  
    }
    
    /*****************************************************************
    Method Name: cancel
    Purpose: To redirect the userback to release
    ***************************************************************/ 
    public PageReference cancel() {       
        PageReference orderPage = new PageReference('https://cs41.salesforce.com/' +releaseID );
        orderPage.setRedirect(true);
        return orderPage;
    }
}