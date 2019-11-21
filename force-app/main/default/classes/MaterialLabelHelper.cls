public with sharing class MaterialLabelHelper {
    public Map<String, String> labelPlanningGroupMap = new Map<String, String>();
    public Map<String, Boolean>labelCustMktApprovalMap = new Map<String, Boolean>();
    public static Map<String,String> matLabelCodeMap;
    
    public static void MaterialLabelHelper() {
    }

    public static Map<String, Boolean> getLabelCustMktApprovalMap(List<CIRF_Material__c> SKUMatList) {

        Map<String, Boolean> resultMap = new Map<String, Boolean>();
        Set<String> matLabelSet = new Set<String>();

        for (CIRF_Material__c cm: SKUMatList) {
            matLabelSet.add(cm.material_label_code__c);
        }

        List<Material_Label_Code_Default__c> matLabelList = [select id, label_code_key__c, CIRF_Customer_Marketing_Approval__c from Material_Label_Code_Default__c where label_code_key__c in : matLabelSet ];

        for (Material_Label_Code_Default__c ml : matLabelList) {
            resultMap.put(ml.Label_Code_Key__c, ml.CIRF_Customer_Marketing_Approval__c);
        }

        return resultMap;
    }    


    public static Map<String, String> getLabelPlanningGroupMap(List<CIRF_Material__c> SKUMatList) {
        return null;
    }

    public static String getPlanningGroupByLabelCode(String label_Code_Key) {
        String defaultPlanningGroupName = 'Universal_New_Release_Planning';
        return (defaultPlanningGroupName);
    }
    
    public static String getPlanningGroupByLabelCode(String lblCode, String productClass) {
        System.debug(lblCode);
        System.debug(productClass);
        if(matLabelCodeMap == null){
            matLabelCodeMap = new Map<String,String>();
            List<Material_Label_Code_Default__c> def = [select id, Label_Code_Key__c, Studio__c from Material_Label_Code_Default__c];
            for(Material_Label_Code_Default__c m : def){
                matLabelCodeMap.put(m.Label_Code_Key__c,m.Studio__c);
            }
        }
        System.debug(matLabelCodeMap.get(lblCode));
        return getPublicGroup(matLabelCodeMap.get(lblCode), productClass);
    }
    
    public static String getPublicGroup(String studio, String productClass){
        String defaultPlanningGroupName = 'Universal_New_Release_Planning';
        if(studio == 'Universal' && productClass == '02 - HIT'){
            return 'NR-Planning_UNI';
        }
        else if(studio == 'Universal' && productClass == '01 - Catalog'){
            return 'Catalog_Planning_UNI';
        }
        else if(studio == 'Partners' && productClass == '02 - HIT'){
            return 'NR_Planning_Partners';
        }
        else if(studio == 'Partners' && productClass == '01 - Catalog'){
            return 'Catalog_Planning_Partners';
        }
        else if(studio == 'PHE' && productClass == '02 - HIT'){
            return 'NR_Planning_PHE';
        }
        else if(studio == 'PHE' && productClass == '01 - Catalog'){
            return 'Catalog_Planning_PHE';
        }
        return defaultPlanningGroupName;
    }
}