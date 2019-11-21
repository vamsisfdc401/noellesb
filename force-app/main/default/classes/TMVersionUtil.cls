/*****************************************************************************************
Apex Class: TMVersionUtil 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             19/07/2016                                    Initial Development
******************************************************************************************/

public class TMVersionUtil {
    
    public static final String BLANK = 'Blank';
    public static final String NONE = '--None--';
    
    //Method to TM version and add to picklist
    public static List<SelectOption> getTmVersionTitle(String titleId){
        if(titleId != null) {
            String segNo = getSysgen(titleId);
            return getTmVersionSysGen(segNo);
        }
        return null;
    }   
    //Mathod to get TM version and add to display on Title
    public static String getSysgen(String titleId){
        List<Title__c> titles = [select SGENNO__c,Series_SGENNO__c from Title__c where id =:titleId ];
        if(titles.size() > 0 ) {
            return titles[0].SGENNO__c;
            
        }
        return null;
    }
    //Mathod to get TM version based on series sys.     
    public static List<SelectOption> getTmVersionSysGen (String sysgen) {
        if(sysgen != null) {
            return consturctSelectOptionList([select name,id from TM_Version__c where Series_Sys__c = :sysgen]);
        }
        return null;
    }
    
    //Mathod to get TM version and display TM version selected list 
    public static List<SelectOption> consturctSelectOptionList(List<TM_Version__c> tmversionList){
        
        List<SelectOption> tmVersionOpt = new List<SelectOption>();
        if(tmversionList.size()>1) 
            tmVersionOpt.add(new SelectOption(BLANK,NONE));
        
        for(TM_Version__c version:tmVersionList){
            tmVersionOpt.add(new SelectOption(version.id,version.name));
        }
        
        return tmVersionOpt;
    }
}