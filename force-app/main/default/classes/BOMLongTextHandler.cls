/*****************************************************************************************
Class Name: BOMLongTextHandler 
Purpose: Class for creating and deleting BOM Long Text 
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             01/02/2017           Jay                    Initial Development
******************************************************************************************/
public class BOMLongTextHandler {
    
    /*****************************************************************
    Method Name: manageBOMLongText
    Purpose: Handles logic that should be executed when BOM Long Text field is changed     
    ***************************************************************/   
    public static void manageBOMLongText(){
        
        System.debug('##Asha - Inside manageBOMLongText');
        List<Id> matIds = new List<Id>();
        
        //Get materials where BOM Long Text is changed
        for(Material__c mat : (List<Material__c>)Trigger.New){
            
            if(Trigger.isInsert){
                if(mat.BOM_Long_Text__c != null){
                    matIds.add(mat.Id);
                }
            }
            if (Trigger.isUpdate){
                Material__c oldMat = (Material__c)Trigger.oldMap.get(mat.Id);
                if(mat.BOM_Long_Text__c != oldMat.BOM_Long_Text__c){
                    matIds.add(mat.Id);                    
                }                             
            }
        }
        System.debug('##Asha - Inside matIds'+matIds);
        
        if(matIds.size() > 0){
            deleteOldBOMLongText(matIds);
            List<Material__c> parseMat = [Select id, BOM_Long_Text__c from Material__c where Id IN: MatIds]; 
            parseLongText(parseMat);
        }
    }    //END Method:  manageBOMLongText
    
    
    /*****************************************************************
    Method Name: deleteOldBOMLongText
    Purpose: Queries for old BOM Long Text child records of a Material and deletes them
    ***************************************************************/   
    public static void deleteOldBOMLongText(List<Id> deleteIds){
        System.debug('##Asha - Inside deleteOldBOMLongText'+deleteIds);
        
        List<BOM_Long_Text__c> deletes = [Select id, Material__c from BOM_Long_Text__c where Material__c IN: deleteIds]; 
        if(deletes.size()>0)
            delete(deletes);
    }    //END Method:  deleteOldBOMLongText
    
    
    /*****************************************************************
    Method Name: parseLongText
    Purpose: parse a string containing line breaks and / carriage returns into a list of string lines that may be 
        	consumed by TIBCO for SAP integration
        	system problems.  Returns List of BOM Long Text     
    ***************************************************************/      
    public static void parseLongText(List<Material__c> mat){
        
        String target = '\r\n';
        String replacement = '\n';
        String newString;
        List<BOM_Long_Text__c> parseList = new List<BOM_Long_Text__c>();
        
        System.debug('##Asha - Inside parseLongText'+mat);
        
        for(Material__c m : mat){
            if(String.isBlank(m.BOM_Long_Text__c)){
                continue;
            }
            newString = m.BOM_Long_Text__c.replace(target, replacement);
            List<String> stringLines = newString.split('\n');
            //Initialize variables
            
            //System.debug('###stringLines---->'+stringLines );
            Integer counter = 1;
            //setting char length as 39 for the first line later setting it to 132 as per DF-1660
            Integer maxCharacter = 39;
            String CodeValue;
            
            for(String lines : stringLines){
                
                String tempLine = lines;
                if(counter>1){
                    CodeValue = '*';                
                }
                else{
                    CodeValue = '';
                }    
                
                //Handle Text from line
                //Chop up line into additional pieces based on maxCharacter length
                //If length(tempLine) > maxCharacter, then take left(maxCharacter) and assign to parseLine
                //Remove what was assigned from tempLine and loop, until
                //Set order field on record
                
                do { 
                    System.debug('counter -> '+counter);             
                    if(templine.length() > maxCharacter){
                        //add maxCharacters to Line
                        BOM_Long_Text__c parseLine = new BOM_Long_Text__c();
                        parseLine.Material__c = m.Id;
                        parseLine.Text__c = tempLine.left(maxCharacter);
                        String remainLine = tempLine.removeStart(parseLine.Text__c);
                        tempLine = remainLine;
                        parseLine.Code__c = CodeValue;
                        parseLine.Order__c = counter;                    
                        parseList.add(parseLine);                       
                        CodeValue = '';
                        counter = counter +1;                  
                    }
                    else{//Handle when templine.length is less than maxCharacters
                        BOM_Long_Text__c parseLine = new BOM_Long_Text__c();
                        parseLine.Material__c = m.Id;
                        parseLine.Text__c = tempLine;                   
                        parseLine.Order__c = counter; 
                        parseLine.Code__c = CodeValue;     
                        tempLine='';
                        System.debug('tempLine -> '+tempLine);                    
                        parseList.add(parseLine);
                        counter = counter +1;                        
                    }
                    
                    if(counter > 1){
                        maxCharacter = 132;
                    }
                    
                }while (tempLine.length() <> 0); 
            }           
        }
        
        if(parseList.size()>0)
            insert parseList;
        
    }    //END Method:  parseLongText
}