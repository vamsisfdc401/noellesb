/*****************************************************************************************
Class Name: MaterialNamingConventionHandler
Purpose: This class handles the NBCU naming convention for its FERT Material and components.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             08/08/2016           Suman Kundu              Initial Development
******************************************************************************************/
public class MaterialNamingConventionHandler
{
    
    public static string parentformatDescription;
    
    // This method is called from Material Trigger to set name according to convention.
    public static void setMaterialDescription()
    {
        Set<Id> releaseIds = new Set<Id>();
        Set<Id> titleIds = new Set<Id>();
        if(!Trigger.isExecuting)
            return;
        
        // Removing logic for .isUpdate JE 9/8/16
        if(Trigger.isBefore && Trigger.isInsert )
            
        {
            for(SObject rec : Trigger.new)
            {
                if(rec.get('Release__c') != null)
                    releaseIds.add(String.valueOf(rec.get('Release__c')));
                
                if(rec.get('Title__c') != null)
                    titleIds.add(String.valueOf(rec.get('Title__c')));
            }
            
            Map<Id, Release__c> releaseMap;
            Map<Id, Title__c> titleMap;
            
            if(releaseIds.size() > 0)
            {
                // Fetching Release information.
                releaseMap = new Map<Id, Release__c>([SELECT Id, Name, Title__c, Title__r.Title_Abbreviation__c, 
                                                      Territory__c, Promotion_Name_Abbreviation__c, Title__r.Short_Name__c,
                                                      Title__r.Sort_Name__c 
                                                      FROM Release__c
                                                      WHERE Id IN :releaseIds]);
            }
            
            if(titleIds.size() > 0)
            {
                // Fetching Title details
                titleMap = new Map<Id, Title__c>([SELECT Id, Title_Abbreviation__c, Sort_Name__c, Short_Name__c
                                                  FROM Title__c
                                                  WHERE Id IN :titleIds]);
            }
            
            for(SObject rec : Trigger.new)
            {
                Material__c mat = (Material__c) rec;
                Id recTypeId = Schema.Sobjecttype.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
                if(mat.RecordTypeId == recTypeId){
                    continue;
                }
                Release__c rel;
                Title__c ttl;
                
                if(mat.Release__c != null)
                    rel = releaseMap.get(mat.Release__c);
                
                if(mat.Title__c != null)
                    ttl = titleMap.get(mat.Title__c);
                
                // Checking FERT to prepare naming according to the same.
                if(mat.Material_Type__c == 'FERT')
                {
                    System.debug('*****1> '+mat);
                    System.debug('*****2> '+rel);
                    System.debug('*****3> '+ttl);
                    mat.Name = getFERTMaterialName(mat, rel, ttl);
                }
                else if(mat.Material_Type__c == 'ROH' || mat.Material_Type__c == 'Z009')
                {
                    System.debug('*****1> ');
                    mat.Name = getComponentName(mat, rel, ttl);
                    System.debug('*****2> ');
                }
            }
        }
    }
    
    // Following method returns the FERT name according to Naming Convension rule.
    public static String getFERTMaterialName(Material__c mat, Release__c rel, Title__c ttl)
    {
        System.debug('----Naming1> '+mat);
        System.debug('----Naming2> '+rel);
        System.debug('----Naming3> '+ttl);
        
        // For display vehicle system will not format description.
        if(mat.Item_Type__c != null && mat.Item_Type__c == 'D (Display Vehicle)')
        {
            if(mat.Name != null)
                return mat.Name.toUpperCase();
            return mat.Name;
        }
        
        String matName = '';
        
        Integer titleLength = 21;
        
        //setting material name for Baby FERT
        if(mat.Item_Type__c != null && mat.Item_Code__c != null && mat.Item_Type__c == 'S (Single)' && mat.Item_Code__c == 'BF - BABY FERT'){
            if(ttl != null && ttl.Title_Abbreviation__c != null)
            {
                matName = ttl.Title_Abbreviation__c.trim() + ' ';
            }               
            matName = matName + '4MT';
            return matName.toUpperCase();
        }
        
        // Getting Title Abbreviation/Short Name/Release Name
        if(ttl != null && ttl.Title_Abbreviation__c != null)
        {
            if(ttl.Title_Abbreviation__c.length() > titleLength)
                matName += ' ' + ttl.Title_Abbreviation__c.subString(0, titleLength).trim();
            else
                matName += ' ' + ttl.Title_Abbreviation__c.trim();
        }
        else if(ttl != null && ttl.Sort_Name__c != null)
        {
            if(ttl.Sort_Name__c.length() > titleLength)
                matName += ' ' + ttl.Sort_Name__c.subString(0, titleLength).trim();
            else
                matName += ' ' + ttl.Sort_Name__c.trim();
        }
        else if(rel != null)
        {
            if(rel.Name.length() > titleLength)
                matName += ' ' + rel.Name.subString(0, titleLength).trim();
            else
                matName += ' ' + rel.Name.trim();
        }
        
       
        // Using format
        if(mat.Format_Description__c != null)
        {   //USST-2424
            Map<String,String> formatMap = new Map<String,String>{'COMBO PACK'=>'BDC','3D BD'=>'BD 3D','3D DVD'=>'DVD 3D','3D UHD'=>'UHD 3D','BD-R'=>'MOD BDR','BD-R COMBO PACK'=>'MOD BDRC','DVDR'=>'MOD DVDR','3D COMBO PACK'=>'BDC 3D'}; //USST-3120
                String format = mat.Format_Description__c;
         
            if(formatMap.containsKey(format))
                matName += ' ' + formatMap.get(format).trim();
            else if(format.length() > 4)
                matName += ' ' + format.subString(0, 4).trim();
            else
                matName += ' ' + format.trim();
        }
        
        // Merging Promo Name Abbreviation
        if(rel != null && rel.Promotion_Name_Abbreviation__c != null)
        {
            if(rel.Promotion_Name_Abbreviation__c.length() > 5)
                matName += ' ' + rel.Promotion_Name_Abbreviation__c.subString(0, 5).trim();
            else
                matName += ' ' + rel.Promotion_Name_Abbreviation__c.trim();
        }
        
        // Adding Retailer/Rental 
        if(mat.Retailer_Rental__c != null)
        {
            if(mat.Retailer_Rental__c.length() > 3)
                matName += ' ' + mat.Retailer_Rental__c.subString(0, 3).trim();
            else
                matName += ' ' + mat.Retailer_Rental__c.trim();
        }
        
        if(mat != null && mat.Territory__c != null && mat.Territory__c.trim() == 'CDN'){
            matName += ' CDN';
        }
        System.debug('----NamingFinal> '+matName);
        if(matName.trim() == '')
        {
            return mat.Name.toUpperCase();
        }
        
        return matName.toUpperCase();
    }
    
    // Following method returns the Component name according to Naming Convension rule.
    public static String getComponentName(Material__c mat, Release__c rel, Title__c ttl)
    {
        System.debug('*****12> ');
        String matName = '';
        System.debug('*****TriggerUtility.checkFromCloning> '+TriggerUtility.checkFromCloning);
        if(TriggerUtility.checkFromCloning)
        {
            return mat.Name.toUpperCase();
        }
        
        System.Debug('Printmaterial instance @@ '+mat);
        // Populating Item Code from Component Type mapping for ROH and Z009.
        if(mat.Material_Type__c != null && (mat.Material_Type__c == 'ROH' || mat.Material_Type__c == 'Z009') && 
           mat.Component_Type__c != null && Component_ItemCode_Mapping__c.getInstance(mat.Component_Type__c) != null)
        {
            mat.Item_Code__c = Component_ItemCode_Mapping__c.getInstance(mat.Component_Type__c).Item_Code__c;
        }
        
        // Get abbreviation from custom settings
        if(mat.Component_Type__c != null)
            mat.Name = mat.Component_Type__c;
        
        ComponentNamingConventions__c comAbb = ComponentNamingConventions__c.GetValues(mat.Name);
        
        if(string.Valueof(comAbb) != null) {      
            mat.Component_Type_Abbreviation__c =  comAbb.Abbreviation__c;
        }  
        
        System.Debug('check abb !! '+ mat.Component_Type_Abbreviation__c);
        System.Debug('check abb1 !! '+ comAbb );
        // Component Name abbreviation
        if(mat.Component_Type_Abbreviation__c != null && mat.Component_Type_Abbreviation__c.length() > 5)
            matName+= mat.Component_Type_Abbreviation__c.subString(0, 5)+'/';
        else if(mat.Component_Type_Abbreviation__c != null)
            matName = mat.Component_Type_Abbreviation__c + '/';
        
        Integer titleLength = 21;
        
        // Concatenating Title Abbreviation/Release name
        if(ttl != null && ttl.Title_Abbreviation__c != null)
        {
            if(ttl.Title_Abbreviation__c.length() > titleLength)
                matName +=  ttl.Title_Abbreviation__c.subString(0, titleLength).trim() + ' ';
            else
                matName +=  ttl.Title_Abbreviation__c.trim() + ' ';
        }
        else if(rel != null)
        {
            System.debug('----rel> '+rel);
            System.debug('----rel1> '+rel.Name);
            if(rel.Name.length() > titleLength)
                matName +=  rel.Name.subString(0, titleLength).trim() + ' ';
            else
                matName +=  rel.Name.trim() + ' ';
            System.debug('----rel2> '+matName);
        }
        System.debug('*****mat.Format_Description__c> '+mat.Component_Type__c+' -- '+mat.Format_Description__c);
        // Merging Format
        if(mat.Format_Description__c != null)
        {
            // for 3D FORMATS FOR DISC (EXCEPT DISC CD)
            Map<String,String> formatMap = new Map<String,String>{'3D BD'=>'BD 3D','3D DVD'=>'DVD 3D','3D UHD'=>'UHD 3D','DVD'=>'DVD 3D','BD'=>'BD 3D','UHD'=>'UHD 3D'};
                
                system.debug('parent material description-->'+parentformatDescription);
            String format = mat.Format_Description__c;
            if(format == 'COMBO PACK'){
                format = 'BDC';
                matName += ' ' + format.trim(); //USST-2424 Starts
            }
            //USST-3120 -- start
            else if(format =='3D COMBO PACK')
            {
               matName += ' ' + 'BDC 3D';
            }
            //USST-3120 -- end
            else if(format =='BD-R')
            {
               matName += ' ' + 'MOD BDR';
            }else if(format =='BD-R COMBO PACK')
            {
               matName += ' ' + 'MOD BDRC';
            }else if(format =='DVDR')
            {
                 matName += ' ' + 'MOD DVDR';
            }
             else if(format =='BD-R DVD' || format =='BD-R UHD' || format =='BD-R BD' )
            {
                 matName += ' ' + format.replace('BD-R','MOD BDR');
            }else if(format =='BD-R COMBO PACK DVD' || format =='BD-R COMBO PACK UHD' || format =='BD-R COMBO PACK BD' )
            {
                 matName += ' ' + format.replace('BD-R COMBO PACK','MOD BDRC');
            }else if(format =='DVDR DVD' || format =='DVDR UHD' || format =='DVDR BD')
            {
                 matName += ' ' + format.replace('DVDR','MOD DVDR');
            } //USST-2424 Ends
            else if(parentformatDescription!=null && formatMap.containsKey(format) && (parentformatDescription.equals('3D DVD') || parentformatDescription.equals('3D BD') || parentformatDescription.equals('3D UHD')))
                matName += ' ' + formatMap.get(format).trim();
            else if(format.length() >= 4){
                matName +=  format.subString(0, 4).trim();
                system.debug('else if-->'+matName);
            }
            else{
                matName +=  format.trim();
                system.debug('material name11 else-->'+matName);
            }
        }
        system.debug('material name-->'+matName);
        // Adding Retailer/Rental 
        if(mat.Retailer_Rental__c != null)
        {
            if(mat.Retailer_Rental__c.length() > 3)
                matName += ' ' + mat.Retailer_Rental__c.subString(0, 3).trim();
            else
                matName += ' ' + mat.Retailer_Rental__c.trim();
        }
        
        if(mat != null && mat.Territory__c != null && mat.Territory__c.trim() == 'CDN'){
            matName += ' CDN';
        }
        // Special scenario for ComboPack
        if(mat.Name != null && mat.Component_Type__c != null && !mat.Component_Type__c.containsIgnoreCase('DISC') && mat.Format_Description__c != null && mat.Format_Description__c.equalsIgnoreCase('COMBO PACK'))
        {
            if(mat.Name.endsWith('BD'))
                matName += ' BD';
            else if(mat.Name.endsWith('DVD'))
                matName += ' DVD';
        }
        
        if(comAbb != null && comAbb.Ending__c != null && comAbb.Ending__c.trim() != '')
            matName += ' ' + comAbb.Ending__c.trim();
        System.debug('----NamingFinal> '+matName);
        if(matName.trim() == '')
        {
            return mat.Name.toUpperCase();
        }
        
        return matName.toUpperCase();
    }
}