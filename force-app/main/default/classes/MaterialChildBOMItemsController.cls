/*****************************************************************************************
Class Name: MaterialChildBOMItemsController
Purpose: Apex class to display Child BOM items on Material layout.
         Display Records only when BOM Item text 1 or Text 2 has any values.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             14/02/2018           Ashok                    Initial Development (REL 160)
******************************************************************************************/  

public class MaterialChildBOMItemsController 
{
    public Material__c mat;

    public List <BOM_Item__c> BOMItems {get; set;}
    
    public MaterialChildBOMItemsController(ApexPages.StandardController controller) 
    {
        this.mat = (Material__c)controller.getRecord();
  
        BOMItems = new List <BOM_Item__c> ();
        BOMItems = [SELECT ID,
                             Component_Number__c,
                             Material_Component__r.Name,
                             BOM_Item_Text_1__c,
                             BOM_Item_Text_2__c,
                             Valid_To__c
                             FROM BOM_Item__c
                             WHERE Material__c = :mat.Id AND (BOM_Item_Text_1__c != '' or BOM_Item_Text_2__c !='') AND (Item_Category__c='L' or Item_Category__c ='N' )
                   ];
    
    }
}