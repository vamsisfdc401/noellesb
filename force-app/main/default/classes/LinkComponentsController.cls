/*****************************************************************************************
Class Name: LinkComponentsController
Purpose: Apex class for linking components
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             31/08/2016           Mohit                    Initial Development
******************************************************************************************/
public with sharing class LinkComponentsController {

    
    /****private static variables****/
    private static final string FERT_MATERIAL_TYPE = 'FERT';
    private static final string ROH_MATERIAL_TYPE = 'ROH';
    
    /****private variables****/
    private ID releaseID;
    private string retURL;
    private ID materialID;
    
    /****public variables****/
    public Release__c releaseDetails{get;set;}
    public List<wrapperParent> lstParentWrapper{get;set;}
    public Boolean showReleaseSection{get;set;}   
    public integer rowNum{get;set;}
    Set<String> setChildMaterialTypes = new Set<String>{'ROH', 'Z009', 'ZVSM', 'ZDLT'};
    
    
    /************************************
    Method Name: LinkComponentsController
    Purpose: Constructor
    *************************************/   
    public LinkComponentsController(){ 
        try{
            //getting release ID from URL   
            releaseDetails = new Release__c();
            
            if(apexpages.currentpage().getparameters().containskey('rid') && apexpages.currentpage().getparameters().get('rid') != ''){
              showReleaseSection = TRUE;
              releaseID = apexpages.currentpage().getparameters().get('rid');
            }  
            else{
              showReleaseSection = FALSE;
            }
            
            if(apexpages.currentpage().getparameters().containskey('mid') && apexpages.currentpage().getparameters().get('mid') != ''){              
              materialID = apexpages.currentpage().getparameters().get('mid');
            }  
            
            retURL = apexpages.currentpage().getparameters().get('retURL');
            
            System.Debug('retURL Value '+retURL);
            
            //getting release details
            if(string.valueof(releaseID) != null && string.valueof(releaseID) != ''){
                releaseDetails = [Select id,name,Title__c,Street_Date__c,Brand_Group__c,Territory__c,Project_Type__c,Promotion_Name_Abbreviation__c from Release__c where ID=:releaseID];                
            }
            
            setMaterialDetails();
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact System Administrator.'+ex.getMessage()));               
        }      
    }
    
    /*****************************************************************
    Method Name: setMaterialDetails
    Purpose: setting material details 
    ***************************************************************/  
    public void setMaterialDetails(){        
        List<Material__c> lstParentMaterials = new List<Material__c>();
        List<Material__c> lstChildMaterials = new List<Material__c>();
        lstParentWrapper = new List<wrapperParent>();
        
        Set<ID> fertID = new Set<ID>();
        Set<ID> rohID = new Set<ID>();
        Boolean isBOMAlreadyCreated = FALSE;
        
        if (Cache.Session.contains('fertID')) {
             fertID = (Set<ID>)cache.session.get('fertID');
             //cache.session.remove('fertID');
        }
        
        if (Cache.Session.contains('rohID')) {
             rohID = (Set<ID>)cache.session.get('rohID');
             //cache.session.remove('rohID');
        }
        
        System.Debug('FERT ID @@ '+fertID);
        System.Debug('ROH ID @@ '+rohID);
        
        //SOQL for components
        lstParentMaterials = [Select id,name,Format_Description__c,territory__c,Component_Type__c from Material__c where Material_Type__c in: setChildMaterialTypes AND ID in:rohID];
        
        //SOQL for FERT
        lstChildMaterials = [Select id,name,Format_Description__c,Component_Type__c,territory__c,
                             (Select id, Material__c, Material_Component__c from BOM_Items__r where Material__c in:fertID AND Material_Component__r.Item_Code__c != 'BF - BABY FERT') 
                             from Material__c where Material_Type__c =: FERT_MATERIAL_TYPE AND ID in:fertID AND Item_Code__c != 'BF - BABY FERT'];
        
        //populating ROH records
        if(!lstParentMaterials.isEmpty()){
            for(integer i=0;i<lstParentMaterials.size();i++){
                lstParentWrapper.add(new wrapperParent(lstParentMaterials[i])); 
            }        
        }
        
        //populating FERT records
        if(!lstChildMaterials.isEmpty() && !lstParentWrapper.isEmpty()){        
            for(integer j=0;j<lstParentWrapper.size();j++){          
                for(integer k=0;k<lstChildMaterials.size();k++){
                    //setting default to false
                    isBOMAlreadyCreated = FALSE;
                    
                    //check if BOM Item present for FERT
                    if(lstChildMaterials[k].BOM_Items__r.size() > 0){
                        for(BOM_Item__c bm : lstChildMaterials[k].BOM_Items__r){
                            //checking if component already linked to FERT
                            if(lstParentWrapper[j].matDetails.ID == bm.Material_Component__c){
                                isBOMAlreadyCreated = TRUE;
                            }
                        }
                    }
                    
                    //if not linked then putting it in list
                    if(!isBOMAlreadyCreated){
                        lstParentWrapper[j].lstChildWrapper.add(new wrapperChild(lstChildMaterials[k]));
                    }
                }          
            }        
        }
        
    }
    
    /*****************************************************************
    Method Name: submit
    Purpose: save record mappping
    ***************************************************************/ 
    public pageReference submit(){
        try{
            //initializing BOM Item list            
            List<BOM_Item__c> lstBOMItem = new List<BOM_Item__c>();
            Map<ID,String> mapROHBOMQty = new Map<ID,String>();
            
            if (Cache.Session.contains('bomQty')) {
                mapROHBOMQty = (Map<ID,String>)cache.session.get('bomQty');            
            }
            
            //checking if wrapper list not null
            if(!lstParentWrapper.isEmpty()){
                for(wrapperParent child : lstParentWrapper){                    
                    for(wrapperChild parent : child.lstChildWrapper){       
                        //if ROH selected for a FERT
                        if(parent.selected== TRUE){
                            BOM_Item__c objBOM= new BOM_Item__c();
                            objBOM.Material__c = parent.matDetails.id;
                            objBOM.Material_Component__c = child.matDetails.id;
                            objBOM.Territory__c = parent.matDetails.territory__c ;
                            
                            if(mapROHBOMQty.containsKey(child.matDetails.id)){
                                objBOM.Component_Quantity__c = mapROHBOMQty.get(child.matDetails.id);
                                objBOM.BOM_Quantity__c = Integer.ValueOf(mapROHBOMQty.get(child.matDetails.id));
                            }
                            
                            lstBOMItem.add(objBOM);                            
                        }
                    } 
                }
                
                //inserting BOM Item
                if(!lstBOMItem.isEmpty()){
                    insert lstBOMItem;
                }
                
                //removing checkbox selection
                removeCheckBoxSelection();                
            }
            
            //redirecting user to release details
            string returnPath;
            if(string.valueof(releaseID) != null && string.valueOf(releaseID) != ''){
                returnPath = '/' + releaseID;
            }
            else if (string.valueof(materialID) != null && string.valueOf(materialID) != ''){
                returnPath = '/' + materialID;
            }
            else{
                returnPath = retURL;
            }           
            
            pagereference pg = new pagereference(returnPath);
            pg.setRedirect(true);
            return pg;            
        }
        catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact System Administrator.'+ex.getMessage()));  
            return null;
        }
    }
    
    /*****************************************************************
    Method Name: setMaterialDetails
    Purpose: setting material details 
    ***************************************************************/
    public pageReference cancel(){
        //set association required checkbox to false
        removeCheckBoxSelection();
       
        //redirecting user to release details
        string returnPath;
        if(string.valueof(releaseID) != null && string.valueOf(releaseID) != ''){
            returnPath = '/' + releaseID;
        }
        else if (string.valueof(materialID) != null && string.valueOf(materialID) != ''){
            returnPath = '/' + materialID;
        }
        else{
            returnPath = retURL;
        }           
        
        pagereference pg = new pagereference(returnPath);
        pg.setRedirect(true);
        return pg;    
    }
    
    /*****************************************************************
    Method Name: removeCheckBoxSelection
    Purpose: removing checkbox selection
    ***************************************************************/
    public void removeCheckBoxSelection(){
        try{        
            if (Cache.Session.contains('fertID')) {
             cache.session.remove('fertID');
            }
            
            if (Cache.Session.contains('rohID')) {
                 cache.session.remove('rohID');
            }  
        }catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please contact System Administrator.'+ex.getMessage()));
        }
    }
    
    /*****************************************************************
    Method Name: setSelection
    Purpose: selecting all records in table
    ***************************************************************/
    public void setSelection(){
        if(!lstParentWrapper.isEmpty()){
            for(wrapperChild wc : lstParentWrapper[rowNum].lstChildWrapper){
                wc.selected = lstParentWrapper[rowNum].selectALL;
            }        
        }    
    }
    
    /*****************************************************************
    Method Name: setSelectALL
    Purpose: setting select all to true or false
    ***************************************************************/
    public void setSelectALL(){
        Boolean flag = FALSE;
        
        if(!lstParentWrapper.isEmpty()){
            for(wrapperChild wc : lstParentWrapper[rowNum].lstChildWrapper){
                if(!wc.selected){
                    lstParentWrapper[rowNum].selectALL = FALSE;
                    flag = TRUE;
                }
                
                if(!flag){
                    lstParentWrapper[rowNum].selectALL = TRUE;
                }
            }        
        }
    }
    
    /*****************************************************************
    Method Name: openRequestWizard
    Purpose: Redirects user depending on values of releaseid and materialid 
    ***************************************************************/
    
    
    public pageReference openRequestWizard(){
        pageReference pg;
        
        if(string.valueof(releaseID) != null && string.valueof(releaseID) != ''){
            pg = new pageReference('/apex/MaterialCreationWizard?id='+releaseID+'&source=releasedetail&retURL=/'+releaseID);
        }
        else if(string.valueof(materialID) != null && string.valueof(materialID) != ''){
            pg = new pageReference('/apex/MaterialCreationWizard?id='+materialID+'&source=materialdetail&retURL=/'+materialID);
        }
        
        pg.setRedirect(TRUE);
        return pg;
    }
    
   
    //wrapper class for ROH
    public class wrapperParent{        
        public material__c matDetails{get;set;}
        public List<wrapperChild> lstChildWrapper{get;set;} 
        public boolean selectALL{get;set;}       
        public wrapperParent(Material__c mt){
            matDetails = new Material__c();            
            matDetails = mt;            
            lstChildWrapper = new List<wrapperChild>();
            
            selectALL = FALSE;
        }        
    }
    
    //Wrapper class for FERT records
    public class wrapperChild{        
        public material__c matDetails{get;set;}
        public boolean selected{get;set;}
        
        public wrapperChild(Material__c mt){
            matDetails = new Material__c();
            matDetails = mt;
            selected = FALSE;
        }        
    }
}