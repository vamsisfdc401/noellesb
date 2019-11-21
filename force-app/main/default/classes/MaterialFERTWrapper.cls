// Material Wrapper class.
public class MaterialFERTWrapper
{
    private static final string FERT_MATERIAL_TYPE = 'FERT';
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
    public boolean isCollapsed {get;set;}
    public Integer discQuantity {get; set;}
    public Integer discQuantityDVD {get; set;}
    public Integer quantity {get; set;}
    public Boolean hasDChainFR {get; set;}
    public String sysgenNo {get; set;}
    public Boolean isExisting {get; set;}
    public List<MaterialFERTWrapper> childFERTs {get; set;}
    public List<MaterialComponentWrapper> childComponents {get; set;}
    public Integer qtyBOM {get; set;}
    public Id parentMaterialId {get; set;}
    public Id bomItemId {get; set;}
    public string itemCategory {get; set;}
    public Decimal componentQty {get; set;}
    public Decimal componentQtyActual {get; set;}
    public List<SelectOption> lstTerritoryOptions {get; set;}
    public String wizardType;
    public PaginationHandler childIns {get; set;}
    public BOM_Item__c bmItm {get;set;}
    public boolean isNew {get; set;}
    public date validFrom {get; set;}
    public Integer levelOfDepth {
        get; 
        set {
            levelOfDepth = value;
            if(childIns != null)
            {
                // Assign level depending on wizard type and level of depth.
                if(wizardType == 'material' && levelOfDepth == 1)
                    childIns.pageSize = 6; //USST-2946
                else if(wizardType == 'release' && levelOfDepth == 1)
                    childIns.pageSize = 5; //USST-2946
                else if(wizardType == 'material' && levelOfDepth == 2)
                    childIns.pageSize = 6; //USST-2946
                else if(wizardType == 'release' && levelOfDepth == 2)
                    childIns.pageSize = 4; //USST-2946
                else if(wizardType == 'material' && levelOfDepth == 3)
                    childIns.pageSize = 4; //USST-2946
                else if(wizardType == 'release' && levelOfDepth == 3)
                    childIns.pageSize = 2;
                else
                    childIns.pageSize = 5;
            }
        }
    }
    public List<MaterialFERTWrapper> newFERTs {
        get {
            newFERTs = new List<MaterialFERTWrapper>();
            if(childFERTs != null && childFERTs.size() > 0)
            {
                for(MaterialFERTWrapper fert : childFERTs)
                {
                    if(!fert.isExistingRecord)
                        newFERTs.add(fert);
                }
            }
            return newFERTs;
        }
        set;
    }
    public List<MaterialFERTWrapper> existingFERTs {
        get {
            existingFERTs = new List<MaterialFERTWrapper>();
            if(childFERTs != null && childFERTs.size() > 0)
            {
                for(MaterialFERTWrapper fert : childFERTs)
                {
                    if(fert.isExistingRecord)
                        existingFERTs.add(fert);
                }
            }
            return existingFERTs;
        }
        set;
    }
    public List<MaterialComponentWrapper> newComponents {
        get {
            newComponents = new List<MaterialComponentWrapper>();
            if(childComponents!= null && childComponents.size() > 0)
            {
                for(MaterialComponentWrapper comp : childComponents)
                {
                    if(!comp.isExistingRecord)
                        newComponents.add(comp);
                }
            }
            return newComponents;
        }
        set;
    }
    public List<MaterialComponentWrapper> existingComponents {
        get {
            existingComponents = new List<MaterialComponentWrapper>();
            if(childComponents!= null && childComponents.size() > 0)
            {
                for(MaterialComponentWrapper comp : childComponents)
                {
                    if(comp.isExistingRecord)
                        existingComponents.add(comp);
                }
            }
            return existingComponents;
        }
        set;
    }
    
    // Added for RE-16
    public String parentItemType;
    
    public MaterialFERTWrapper(Id titleId, String sysgenNo,string profileName)
    {
        instance = new Material__c();
        instance.Title__c = titleId;
        instance.Material_Type__c = FERT_MATERIAL_TYPE;
        instance.BOM_Status__c = 'Draft';
        isSelected = true;
        isDisabled = false;
        isCollapsed = FALSE;
        discQuantity = 1;
        discQuantityDVD = 1;
        quantity = 1;
        this.sysgenNo = sysgenNo;
        isExisting = false;
        hasDChainFR = false;
        qtyBOM = 1;
        isExistingRecord = false;
        
        childFERTs = new List<MaterialFERTWrapper>();
        childComponents = new List<MaterialComponentWrapper>();
        parentMaterialId = null;
        bomItemId = null;
        
        componentQty = 1.000;
        componentQtyActual = 1.000;
        bmItm = new BOM_Item__c();
        isNew = FALSE;
        
        lstTerritoryOptions = new List<SelectOption>();
        
        lstTerritoryOptions.add(new SelectOption(US_TERRITORY,US_TERRITORY));
        lstTerritoryOptions.add(new SelectOption(CDN_TERRITORY,CDN_TERRITORY));
        lstTerritoryOptions.add(new SelectOption(US_CDN_TERRITORY,US_CDN_TERRITORY));
 
        childIns = new PaginationHandler();
        childIns.assignRecordList(childFERTs);
    }
}