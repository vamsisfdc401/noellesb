/*****************************************************************************************
Class Name: DGF_PerformDML
Purpose: To save TPR Prices
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             22/08/2017           Prarthana                Initial Development
******************************************************************************************/
public without sharing class DGF_PerformDML{
    /***********************************
    Method Name: saveTPRChanges
    Purpose: method to insert/update tpr prices
    ***********************************/   
    public static void saveRecords(list<sobject>objectList,String operation){
        if(!objectList.isEmpty()){
            if(operation=='insert'){
                database.insert(objectList);
            }
            else if(operation=='update'){
                database.update(objectList);
            }
            else if(operation=='delete'){
                 database.delete(objectList);
            }
        }
    }
}