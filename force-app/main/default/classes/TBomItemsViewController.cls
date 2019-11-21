/*****************************************************************************************
Class Name: TBomItemsViewController
Purpose: This class is controller of T-Bom Item view component. It handles all the complexity for the functionality. 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             10/05/2017           Suman                    Initial Development
******************************************************************************************/
global with sharing class TBomItemsViewController
{
    public List<BOM_Item__c> tBomList {get; private set;} {tBomList = new List<BOM_Item__c>();}
    public Boolean showEditPanel {get; private set;} {showEditPanel = false;}
    public BOM_Item__c bomIns {get; set;}
    public Id editBomId {get; private set;}
    public List<String> columnsInTable {get; private set;} {columnsInTable = new List<String>();}
    // Once following property recieves a value, it builds dynamic columns' list to be shown in T-BOM table in component.
    public String columnsToShow
    {
        get; 
        set {
            columnsToShow = value;
            columnsInTable.clear();
            
            if(columnsToShow != null && columnsToShow.trim() != '')
            {
                Set<String> cols = new Set<String>();
                for(String col : columnsToShow.split(','))
                    cols.add(col.trim());
                
                if(cols.contains('Id'))
                    cols.remove('Id');
                if(cols.contains('BOM_Item_Text_1__c'))
                    cols.remove('BOM_Item_Text_1__c');
                if(cols.contains('RecordTypeId'))
                    cols.remove('RecordTypeId');
                
                columnsInTable.addAll(cols);
            }
        }
    }
    // This is an attribute property, once it receives material Id, it fetches its associated T-BOM Items.
    public Id parentRecordId {
        get; 
        set {
            parentRecordId = value;
            String sobjectType;
            if(parentRecordId != null)
                sobjectType = String.valueOf(parentRecordId.getSobjectType());
                
            if(sobjectType != null && sobjectType.equalsIgnoreCase('Material__c'))
            {
                tBomList.clear();
                
                String qry = 'SELECT Id, BOM_Item_Text_1__c';
                for(String col : columnsInTable)
                {
                    qry += ', ' + col;
                }
                qry += ' FROM BOM_Item__c';
                qry += ' WHERE Material__c =: parentRecordId AND Item_Category__c=\'T\'';
                qry += ' ORDER BY CreatedDate';
                
                for(BOM_Item__c bom : Database.query(qry))
                {
                    tBomList.add(bom);
                }
            }
        }
    }
    
    Boolean shouldCloseAfterSave = true;
    // Following method opens T-BOM Item edit panel.
    public void openEditPanel()
    {
        showEditPanel = true;
        shouldCloseAfterSave = true;
        instantiateBomIns();
        //System.debug('*****editBomItemId> '+ApexPages.currentPage().getParameters().get('editBomId'));
        if(ApexPages.currentPage().getParameters().get('editBomId') != null)
        {
            List<BOM_Item__c> editableBOMItems = [SELECT Id, BOM_Item_Text_1__c, Item_Category__c, Unit_of_Measure__c, Production_Flag__c, BOM_Quantity__c, Material__c
                                                  FROM BOM_Item__c 
                                                  WHERE Id=:ApexPages.currentPage().getParameters().get('editBomId')];
            if(editableBOMItems != null && editableBOMItems.size() > 0)
            {
                bomIns = editableBOMItems[0];
                editBomId = editableBOMItems[0].Id;
            }
            ApexPages.currentPage().getParameters().put('editBomId', null);
        }
    }
    
    // Following method handles the Create and Edit operation from the component request.
    @RemoteAction
    global static String saveBomItem(String editBomId, String bomText, String bomUnit, Boolean bomProdFlag, Decimal bomQty, String parentId) 
    {
        // Validating request.
        if(bomText == null || bomText.trim() == '')
            return 'Please populate the Bom Item Text.';
        else if(parentId == null || parentId.trim() == '')
            return 'This request does not contain parent Id.';
        
        Bom_Item__c bom = new Bom_Item__c();
        bom.BOM_Item_Text_1__c = bomText;
        
        // Editing T-Bom Item.
        if(editBomId != null && editBomId.trim() != '')
        {
            bom.Id = editBomId;
        }
        // New T-Bom Item.
        else
        {
            bom.Material__c = parentId;
            bom.Unit_of_Measure__c = bomUnit;
            bom.Production_Flag__c = bomProdFlag;
            bom.BOM_Quantity__c = bomQty;
            bom.Item_Category__c = 'T';
            bom.Component_Quantity__c = String.valueOf(bomQty);
        }
        
        try
        {
            upsert bom;
            return 'success';
        }
        catch(Exception ex)
        {
            return 'ERROR: '+ex.getMessage();
        }
        
        return '';
    }
    
    // This method handles the consequence of after Remote Action.
    public void handleAfterRemoteAction()
    {
        String result = ApexPages.currentPage().getParameters().get('result');
        String fromEvent = ApexPages.currentPage().getParameters().get('fromEvent');
        
        // Message printing.
        if(result == 'success')
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'T-BOM Item saved Successfully.'));
        else
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, result));
        
        // Redirection process.
        if(result == 'success')
        {
            if(fromEvent == 'save')
            {
                cancel();
            }
            else if(fromEvent == 'saveNew')
            {
                editBomId = null;
                instantiateBomIns();
            }
        }
    }
    
    @RemoteAction
    global static String removeBomItem(String editBomId)
    {
        // Validating request.
        if(editBomId == null || editBomId.trim() == '')
            return 'The request is invalid';
        
        try
        {
            delete new BOM_Item__c(Id=editBomId);
            return 'success';
        }
        catch(Exception ex)
        {
            return 'ERROR: '+ex.getMessage();
        }
        
        return '';
    }
    
    // Following method handles the cancel part on the edit popup.
    public void cancel()
    {
        showEditPanel = false;
        editBomId = null;
    }
    
    // Following method helps to setup default data for new instance. 
    public void instantiateBomIns()
    {
        bomIns = new BOM_Item__c();
        bomIns.Material__c = parentRecordId;
        bomIns.Item_Category__c = 'T';
        bomIns.Production_Flag__c = TRUE;
        bomIns.Unit_of_Measure__c = 'PC';
        bomIns.BOM_Quantity__c = 1;
    }
    
}