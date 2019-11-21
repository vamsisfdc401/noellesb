/**
* @name         :   CloneUtility
* @description  :   This is global utility class contain responsible for cloning an SObject
* @author       :   Bhanu Jain 
* @createddate  :   13 July 2016
**/
Global Class CloneUtility{
    Webservice static String clone(String Id,List<String> fieldsToIgnore){
        system.debug(' >>>> '+fieldsToIgnore);
        Set<String> setFieldsToIgnore;
        if(fieldsToIgnore!=null){
            setFieldsToIgnore = new Set<String>(fieldsToIgnore);
        }else{
            setFieldsToIgnore =null;
        }
        
        TriggerUtility.checkFromCloning = TRUE;
        String newId = Utility.clone(Id,setFieldsToIgnore);
        String redirectUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/'+newId;
       
        redirectUrl = redirectUrl + '/e?retURL=/' +newId;
        return redirectUrl;
    }

}