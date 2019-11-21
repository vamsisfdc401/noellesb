/*****************************************************************************************
Class Name: TemplateUtility
Purpose: This is the utility class for controller of Template Creation Wizard.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             10/03/2017           Suman                    Initial Development
******************************************************************************************/
public without sharing class TemplateUtility
{
    // Method to validate template.
    public static Boolean isDuplicateTemplate(String tempName, Id recId)
    {
        if(recId != null)
        {
            List<Material_Template__c> templates = [SELECT Id FROM Material_Template__c WHERE Template_Name__c=:tempName AND Id!=:recId];
            return (templates != null && templates.size() > 0);
        }
        else
        {
            List<Material_Template__c> templates = [SELECT Id FROM Material_Template__c WHERE Template_Name__c=:tempName];
            return (templates != null && templates.size() > 0);
        }
    }
}