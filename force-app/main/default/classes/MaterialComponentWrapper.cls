// Component wrapper class
public class MaterialComponentWrapper
{
    private static final string US_TERRITORY = 'US';
    private static final string CDN_TERRITORY = 'CDN';
    private static final string US_CDN_TERRITORY = 'US & CDN';
    private static final string BRAND_USER_PROFILE = 'Brand User';
    
    public Boolean isExistingRecord {get; set;}
    public Material__c instance {
        get; 
        set
        {
            instance = value;
            if(instance.Id != null)
                isExistingRecord = true;
            if(instance.Count_Sales_for_D_Chain_Status__c != null && instance.Count_Sales_for_D_Chain_Status__c > 0)
                hasDChainFR = true;
        }
    }
    public Boolean isSelected {get; set;}
    public Boolean isDisabled {get; set;}
    public Boolean isExisting {get; set;}
    public Integer quantity {get; set;}
    public Boolean hasDChainFR {get; set;}
    public Id parentMaterialId {get; set;}
    public Id bomItemId {get; set;}
    public Decimal componentQty {get; set;}
    public Decimal componentQtyActual {get; set;}
    public Integer localComponentId {get; set;}     
    public List<SelectOption> lstTerritoryOptions {get; set;}
    public string itemCategory {get; set;}
    public BOM_Item__c bmItm {get; set;}
    public date validFrom {get; set;}
    public boolean isNew {get; set;}
    
    public MaterialComponentWrapper(Integer localComponentId,string profileName)
    {
        instance = new Material__c();
        instance.Material_Type__c = 'ROH';
        
        quantity = 1;
        isExisting = false;
        isExistingRecord = false;
        hasDChainFR = false;
        isSelected = true;
        isDisabled = false;
        parentMaterialId = null;
        bomItemId = null;
        
        componentQty = 1.000;
        componentQtyActual = 1.000;
        this.localComponentId = localComponentId;
        bmItm = new BOM_Item__c();
        isNew = FALSE;
        
        lstTerritoryOptions = new List<SelectOption>();
        
        if(profileName != null)
        {
            if(profileName == BRAND_USER_PROFILE){
                lstTerritoryOptions.add(new SelectOption(US_TERRITORY,US_TERRITORY));
                lstTerritoryOptions.add(new SelectOption(CDN_TERRITORY,CDN_TERRITORY));
                lstTerritoryOptions.add(new SelectOption(US_CDN_TERRITORY,US_CDN_TERRITORY));
            }else{
                lstTerritoryOptions.add(new SelectOption(US_TERRITORY,US_TERRITORY));
                lstTerritoryOptions.add(new SelectOption(CDN_TERRITORY,CDN_TERRITORY));             
                lstTerritoryOptions.add(new SelectOption(US_CDN_TERRITORY,US_CDN_TERRITORY));
            }
        }
    }
}