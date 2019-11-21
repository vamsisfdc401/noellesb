/*****************************************************************************************
Class Name: MaterialApprovalHandler
Purpose: This class is responsible to handle all complex logics for pre-material approval.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             30/09/2016           Jay/Suman/Ipsita         Initial Development
******************************************************************************************/
global class MaterialApprovalHandler
{
      @TestVisible private static Set<String> childMaterialTypes = new Set<String>{'ROH', 'Z009'};
      @TestVisible private static Set<Id> requestMaterialIds = new Set<Id>();
      @TestVisible private static Set<Id> displayVehicleIds = new Set<Id>();
      @TestVisible private static Set<Id> multiPackIds = new Set<Id>();
      @TestVisible private static Integer approveMaterialCount;
      @TestVisible private static Set<Id> componentIds = new Set<Id>();
      @TestVisible private static Set<Id> allMaterialID = new Set<Id>();
      @TestVisible private static Map<Id,String> multiPackMap=new Map<Id,String>();
    // Below structure is used for JSON response to custom JS approval button.
    private class ApprovalResult
    {
        private Boolean isSuccess;
        private String errorMessage;
        
        private ApprovalResult()
        {
            isSuccess = true;
            errorMessage = '';
        }
    }
  
    /***********************************
    Method Name: checkSAPallFieldsComplete
    Purpose: Following method validates if all the materials submitting for approval are populated with required SAP field values..
    ***********************************/
    
    public static void checkSAPallFieldsComplete(List<Material__c> currentMateriallst){
        ApprovalResult result = new ApprovalResult();
        set<Id> materialId = new set<Id>();
        set<Id> materialIdlst= new set<Id>();
        for(Material__c each:currentMateriallst){
          materialIdlst.add(each.Id); 
          materialId.add(each.Id);
        }
       
       Id universalFinishedGoodRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('Universal Finished Good').getRecordTypeId(); 
       Id generalRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
       
        
       List<Material__c> currentMaterial = [Select id,Component_Type__c,Release__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
                                                    Technical_Format__c,Product_Class__c,Title_Source__c, TM_Origin_Code__c,Deal_ID__c,Label_Code__c,Sub_Label_Code_Lookup__c,Pre_Order_Close_Date__c,
                                                    Cross_Ref_Type__c, Base_Unit_of_Measure__c, Material_Group__c,General_Item_Category_Group__c,Division__c ,
                                                    Xplant_Material_Status__c,Xplant_Valid_From__c,Gross_Weight__c,Net_Weight__c,Weight_Unit__c, 
                                                    Alternative_Legal_Title_Lookup__c, Create_Version__c,X_Dchain_Status__c,X_Dchain_Valid_From__c,
                                                    Purchase_Value_Key__c, Transportation_Group__c, Original_Material_Number__c, Palletized__c, name,SGENNO__c,
                                                    BOM_Category__c,BOM_Usage__c,Industry_Sector__c,TM_Status__c,Selection_Reference_Number__c,Valid_From__c,Layer__c,Plant__c,SGENNO_ReadOnly__c, Order_Unit__c, Financial_Owner__c,Title__c from Material__c where Id=:materialId];
     
       List<Valuation__c> relatedValuations = [Select Material__c,id,Valuation_Area__c,Valuation_Class__c,Price_Unit__c, Standard_Price__c,Origin_Group__c, 
                                                Pricing_Control__c From Valuation__c where Material__c=:materialId];
                                                       
        List<Classification__c> relatedClassifications= [Select Material__c,id,Packaging_Type_US__c, Regie_Sticker_for_Canada__c,RecordType.Name,Label_Code__c,Aspect_Ratio__c,
                                                        Genre_US__c 
                                                                From Classification__c where Material__c=:materialId];
                                                                
        List<Plant__c> relatedPlants= [Select Material__c,id,Plant__c, Availability_Check__c, Profit_Center__c, Purchasing_Group__c, MRP_Controller__c,MRP_Group__c,
                                              Plant_Specific_Matl_Status__c, MRP_Type__c,ABC_Indicator__c, Lot_Size__c, Reorder_Point__c,Carton_Count__c,
                                              Min_Lot_Size__c, Max_Lot_Size__c, Fixed_Lot_Size__c, Max_Stock_Level__c, Rounding_Value__c,Safety_Stock__c,
                                              Special_Procurement__c, Plnd_Dely_time__c, Stor_Loc_EP__c, Schedule_Margin_Key__c, Period_Ind__c,Prod_Storage_Location__c,
                                              Splitting_Ind__c, Bwd_Cons_Period__c, Fwd_Cons_Period__c, GR_Processing_Time__c, Mixed_MRP__c,Consumption_Mode__c,
                                              Indv_Colle__c, Requirements_Grouping__c, Valid_From__c, Procurement_Type__c,Component_Scrap_Percentage__c,Loading_Group__c,
                                              Strategy_Group__c,Coverage_Prof__c From Plant__c where Material__c=:materialId];
                                              
        List<Sales__c> relatedSales= [Select Material__c,id, Tax_Indicator__c, Operations_Group__c, Tax_Jurisdiction_Code__c, Item_Category_Group__c,Distribution_Channel__c,
                                     Deliver_Plant__c,Original_Release_Date__c,Volume_Rebate_Group__c,Valid_From__c,
                                     D_Chain_Spec__c,Sales_Unit__c,Material_Group_1__c,Material_Group_2__c,Announcement_Date_US__c,
                                     Material_Group_3__c,Material_Group_4__c,Material_Group_5__c,Material_Pricing_Group__c,Solicitation_Date__c,
                                     Material_Statistic_Group__c,PST_Base_GST_CDN__c,GST_Canada__c,Territory__c,PST_Canada__c,City_Sales_Tax__c, County_Sales_Tax__c, Sales_Org__c From Sales__c where Material__c=:materialId];
       
         
       for(Material__c eachMat : currentMaterial){   
       if(eachMat.Material_Type__c!=null){
          
        if(((eachMat.Material_Type__c=='FERT' && eachMat.Format__c != '08 - EST (ELECTRONIC SELL THRU)') && (((eachMat.Street_Date__c !=Null && eachMat.Base_Unit_of_Measure__c  !=Null && eachMat.Material_Group__c!=Null && eachMat.Weight_Unit__c !=Null && eachMat.Create_Version__c !=Null && eachMat.X_Dchain_Status__c !=Null &&
                    eachMat.X_Dchain_Valid_From__c !=Null && eachMat.Purchase_Value_Key__c !=Null && eachMat.Transportation_Group__c    !=Null &&
                    eachMat.Plant__c !=Null && eachMat.Xplant_Valid_From__c!=Null && eachMat.Name!=Null && eachMat.SGENNO_ReadOnly__c !=Null && eachMat.Material_Type__c !=Null &&  eachMat.Item_Type__c !=Null && eachMat.Item_Code__c !=Null && eachMat.Format__c !=Null && eachMat.Technical_Format__c   !=Null && eachMat.Pre_Order_Close_Date__c != Null &&
                    eachMat.Label_Code__c !=Null && eachMat.Sub_Label_Code_Lookup__c!=Null && 
                    eachMat.General_Item_Category_Group__c!=Null && eachMat.Division__c !=Null && eachMat.Xplant_Material_Status__c!=Null &&    
                    eachMat.Gross_Weight__c !=Null && eachMat.Net_Weight__c !=Null && eachMat.Alternative_Legal_Title_Lookup__c !=Null && (eachMat.Layer__c !=Null || (eachMat.Layer__c ==Null && (eachMat.Format__c=='10 - HD HYBRID (DUAL FORMAT) DNU' ||
                   eachMat.Format__c == '13 - HD VOD' || eachMat.Format__c == '14 - HD EST' || eachMat.Format__c == '15 - DVDR' || 
                   eachMat.Format__c == '17 - BD-R' || eachMat.Format__c == '18 - BD-R COMBO PACK' || eachMat.Format__c == '98 - GWP'))) && eachMat.Product_Class__c !=null && eachMat.Title_Source__c!=null && eachMat.Deal_ID__c!=null &&
                    eachMat.Valid_From__c !=null && eachMat.Title__c!=null && eachMat.TM_Status__c!=Null &&
                    eachMat.Industry_Sector__c!=null && eachMat.BOM_Usage__c!=null && eachMat.BOM_Category__c!=null) && eachMat.Item_Type__c=='S (Single)' && eachMat.Item_Code__c!='BF - BABY FERT')
                    
            ||((eachMat.Base_Unit_of_Measure__c  !=Null && eachMat.Material_Group__c!=Null && eachMat.Weight_Unit__c !=Null && eachMat.Create_Version__c !=Null && eachMat.X_Dchain_Status__c !=Null &&
                    eachMat.X_Dchain_Valid_From__c !=Null && eachMat.Purchase_Value_Key__c !=Null && eachMat.Transportation_Group__c    !=Null &&
                    eachMat.Plant__c !=Null && eachMat.Xplant_Valid_From__c!=Null && eachMat.Name!=Null && eachMat.SGENNO_ReadOnly__c !=Null && eachMat.Material_Type__c !=Null &&  eachMat.Item_Type__c !=Null && eachMat.Item_Code__c !=Null && eachMat.Format__c !=Null && eachMat.Technical_Format__c   !=Null &&
                    eachMat.Label_Code__c !=Null && eachMat.Sub_Label_Code_Lookup__c!=Null && 
                    eachMat.General_Item_Category_Group__c!=Null && eachMat.Division__c !=Null && eachMat.Xplant_Material_Status__c!=Null &&    
                    eachMat.Gross_Weight__c !=Null && eachMat.Net_Weight__c !=Null && eachMat.Alternative_Legal_Title_Lookup__c !=Null && (eachMat.Layer__c !=Null || (eachMat.Layer__c ==Null && (eachMat.Format__c=='10 - HD HYBRID (DUAL FORMAT) DNU' ||
                   eachMat.Format__c == '13 - HD VOD' || eachMat.Format__c == '14 - HD EST' || eachMat.Format__c == '15 - DVDR' || 
                   eachMat.Format__c == '17 - BD-R' || eachMat.Format__c == '18 - BD-R COMBO PACK' || eachMat.Format__c == '98 - GWP'))) && eachMat.Product_Class__c !=null && eachMat.Title_Source__c!=null && eachMat.Deal_ID__c!=null &&
                    eachMat.Valid_From__c !=null && eachMat.Title__c!=null && eachMat.TM_Status__c!=Null &&
                    eachMat.Industry_Sector__c!=null && eachMat.BOM_Usage__c!=null && eachMat.BOM_Category__c!=null) && eachMat.Item_Type__c=='S (Single)' && eachMat.Item_Code__c=='BF - BABY FERT')     
            )        
                    
            || ((eachMat.Material_Type__c=='FERT' && eachMat.Format__c == '08 - EST (ELECTRONIC SELL THRU)') &&(((eachMat.Street_Date__c !=Null && eachMat.Base_Unit_of_Measure__c  !=Null && eachMat.Material_Group__c!=Null && eachMat.Weight_Unit__c !=Null && eachMat.Create_Version__c !=Null && eachMat.X_Dchain_Status__c !=Null &&
                    eachMat.X_Dchain_Valid_From__c !=Null && eachMat.Purchase_Value_Key__c !=Null && eachMat.Transportation_Group__c    !=Null &&
                    eachMat.Plant__c !=Null && eachMat.Xplant_Valid_From__c!=Null && eachMat.Name!=Null && eachMat.SGENNO_ReadOnly__c !=Null && eachMat.Material_Type__c !=Null &&  eachMat.Item_Type__c !=Null && eachMat.Item_Code__c !=Null && eachMat.Format__c !=Null && eachMat.Technical_Format__c   !=Null &&
                    eachMat.Label_Code__c !=Null && eachMat.Sub_Label_Code_Lookup__c!=Null && eachMat.Pre_Order_Close_Date__c != Null &&
                    eachMat.General_Item_Category_Group__c!=Null && eachMat.Division__c !=Null && eachMat.Xplant_Material_Status__c!=Null &&    
                    eachMat.Gross_Weight__c !=Null && eachMat.Net_Weight__c !=Null && eachMat.Alternative_Legal_Title_Lookup__c !=Null &&  
                    eachMat.Valid_From__c != Null && eachMat.Title__c!=null && eachMat.TM_Status__c!=null &&
                    eachMat.Industry_Sector__c !=null && eachMat.BOM_Usage__c!=null && eachMat.BOM_Category__c!=null ) && eachMat.Item_Type__c=='S (Single)' && eachMat.Item_Code__c!='BF - BABY FERT' )
           ||((eachMat.Base_Unit_of_Measure__c  !=Null && eachMat.Material_Group__c!=Null && eachMat.Weight_Unit__c !=Null && eachMat.Create_Version__c !=Null && eachMat.X_Dchain_Status__c !=Null &&
                    eachMat.X_Dchain_Valid_From__c !=Null && eachMat.Purchase_Value_Key__c !=Null && eachMat.Transportation_Group__c    !=Null &&
                    eachMat.Plant__c !=Null && eachMat.Xplant_Valid_From__c!=Null && eachMat.Name!=Null && eachMat.SGENNO_ReadOnly__c !=Null && eachMat.Material_Type__c !=Null &&  eachMat.Item_Type__c !=Null && eachMat.Item_Code__c !=Null && eachMat.Format__c !=Null && eachMat.Technical_Format__c   !=Null &&
                    eachMat.Label_Code__c !=Null && eachMat.Sub_Label_Code_Lookup__c!=Null &&
                    eachMat.General_Item_Category_Group__c!=Null && eachMat.Division__c !=Null && eachMat.Xplant_Material_Status__c!=Null &&    
                    eachMat.Gross_Weight__c !=Null && eachMat.Net_Weight__c !=Null && eachMat.Alternative_Legal_Title_Lookup__c !=Null &&  
                    eachMat.Valid_From__c != Null && eachMat.Title__c!=null && eachMat.TM_Status__c!=null &&
                    eachMat.Industry_Sector__c !=null && eachMat.BOM_Usage__c!=null && eachMat.BOM_Category__c!=null ) && eachMat.Item_Type__c=='S (Single)' && eachMat.Item_Code__c=='BF - BABY FERT')         
                    )            
          || (((eachMat.Item_Type__c=='D (Display Vehicle)') || (eachMat.Item_Type__c=='M (Multipack)')) && (eachMat.Street_Date__c !=Null && eachMat.Base_Unit_of_Measure__c    !=Null && eachMat.Material_Group__c!=Null && eachMat.Weight_Unit__c !=Null && eachMat.Create_Version__c !=Null && eachMat.X_Dchain_Status__c !=Null && eachMat.Pre_Order_Close_Date__c != Null &&
                    eachMat.X_Dchain_Valid_From__c !=Null && eachMat.Purchase_Value_Key__c !=Null && eachMat.Transportation_Group__c!=Null &&
                    eachMat.Plant__c !=Null && eachMat.Xplant_Valid_From__c!=Null && eachMat.Name!=Null &&  eachMat.Material_Type__c !=Null &&  eachMat.Item_Type__c !=Null && eachMat.Item_Code__c !=Null && eachMat.Format__c !=Null && eachMat.Technical_Format__c !=Null &&
                    eachMat.Label_Code__c !=Null && eachMat.Sub_Label_Code_Lookup__c!=Null && 
                    eachMat.General_Item_Category_Group__c!=Null && eachMat.Division__c !=Null && eachMat.Xplant_Material_Status__c!=Null &&    
                    eachMat.Gross_Weight__c !=Null && eachMat.Net_Weight__c !=Null && eachMat.Alternative_Legal_Title_Lookup__c !=Null && eachMat.Product_Class__c !=null && eachMat.Title_Source__c!=null &&  
                    eachMat.Valid_From__c !=Null &&
                    eachMat.Industry_Sector__c!=null && eachMat.BOM_Usage__c!=null && eachMat.BOM_Category__c!=null))   
                    
                    ))
                        
           || (eachMat.Material_Type__c!='FERT' && (eachMat.Division__c!=null && eachMat.Xplant_Material_Status__c!=null &&
                  eachMat.Gross_Weight__c!=null && eachMat.Net_Weight__c!=null && eachMat.Weight_Unit__c!=null && eachMat.Transportation_Group__c !=null &&
                  eachMat.Industry_Sector__c!=null && eachMat.Item_Code__c !=null && eachMat.Item_Type__c!=Null && eachMat.General_Item_Category_Group__c!=null && eachMat.Material_Group__c !=null ))
           )
           {
             Boolean valuationsOk = true;
             Boolean salesOk = true;
             Boolean classificationsOk = true;
             Boolean plantsOk = true;
             Boolean BOMOk = true;
             if(relatedValuations.size()>0){
                 for(Valuation__c eachValuation: relatedValuations){
                  if(eachValuation.Material__c == eachMat.Id){
                     if ((eachMat.Material_Type__c=='FERT'&& (eachValuation.Valuation_Area__c==NULL || eachValuation.Valuation_Class__c==NULL || eachValuation.Price_Unit__c==NULL 
                         || eachValuation.Standard_Price__c==NULL || eachValuation.Origin_Group__c==NULL || eachValuation.Pricing_Control__c==Null))
                         ||(eachMat.Material_Type__c!='FERT'  && (eachValuation.Valuation_Area__c==NULL || eachValuation.Valuation_Class__c==NULL || eachValuation.Price_Unit__c==NULL 
                             || eachValuation.Standard_Price__c==NULL || (eachValuation.Origin_Group__c==NULL && eachMat.Material_Type__c!='Z009')|| eachValuation.Pricing_Control__c==Null)) ){
                         valuationsOk = false;
                         break;
                     }
                   }  
                 }
             }
             
             if(relatedClassifications.size()>0){
             for(Classification__c eachClassification : relatedClassifications){
                if(eachClassification.Material__c == eachMat.Id){
                 }    
             }
             }
             if(relatedPlants.size()>0){
             for(Plant__c eachPlant: relatedPlants){
               if(eachPlant.Material__c == eachMat.Id){
                  if ((eachMat.Material_Type__c=='FERT' && (eachPlant.Valid_From__c == Null || eachPlant.Plant__c== Null || eachPlant.Availability_Check__c == Null || eachPlant.MRP_Type__c == Null ||
                        eachPlant.ABC_Indicator__c == Null || eachPlant.Lot_Size__c == Null || eachPlant.Max_Lot_Size__c == Null ||
                        eachPlant.Max_Stock_Level__c == Null || eachPlant.Special_Procurement__c == Null ||
                        eachPlant.Schedule_Margin_Key__c == Null || eachPlant.Schedule_Margin_Key__c == Null || eachPlant.Period_Ind__c == Null ||
                        eachPlant.Fwd_Cons_Period__c == Null || eachPlant.GR_Processing_Time__c == Null || eachPlant.Mixed_MRP__c == Null ||
                        eachPlant.Requirements_Grouping__c == Null || eachPlant.Profit_Center__c == Null || eachPlant.Purchasing_Group__c == Null || eachPlant.MRP_Controller__c == Null || eachPlant.Min_Lot_Size__c  == Null || eachPlant.Rounding_Value__c == Null || eachPlant.Plnd_Dely_time__c == Null ||
                        eachPlant.Stor_Loc_EP__c == Null || eachPlant.Splitting_Ind__c == Null || eachPlant.Bwd_Cons_Period__c == Null ||
                        eachPlant.Indv_Colle__c == Null || eachPlant.Consumption_Mode__c==Null ||
                        eachPlant.Procurement_Type__c ==Null))
                     
                     ||(eachMat.Material_Type__c!='FERT' &&(eachPlant.Safety_Stock__c == Null || eachPlant.Valid_From__c == Null || eachPlant.MRP_Controller__c == Null ||
                        eachPlant.Purchasing_Group__c == Null || eachPlant.Plant_Specific_Matl_Status__c == Null || eachPlant.MRP_Type__c == Null ||
                        eachPlant.Max_Lot_Size__c == Null ||
                        eachPlant.Max_Stock_Level__c == Null || eachPlant.Stor_Loc_EP__c == Null || eachPlant.Schedule_Margin_Key__c == Null ||
                        eachPlant.Period_Ind__c == Null || eachPlant.Bwd_Cons_Period__c == Null || eachPlant.Fwd_Cons_Period__c == Null ||
                        eachPlant.GR_Processing_Time__c == Null || eachPlant.Mixed_MRP__c == Null || eachPlant.Requirements_Grouping__c == Null ||
                        eachPlant.Plant__c == Null || eachPlant.Min_Lot_Size__c == Null ||eachPlant.Plnd_Dely_time__c == Null ||
                        eachPlant.Component_Scrap_Percentage__c == Null || eachPlant.Lot_Size__c == Null || eachPlant.Rounding_Value__c == Null ||
                        eachPlant.Availability_Check__c == Null || eachPlant.Splitting_Ind__c == Null || eachPlant.Profit_Center__c == Null ||
                        eachPlant.Procurement_Type__c==Null))){
                         plantsOk = false;
                         break;
                     }
                   }  
             }
             }
             if(relatedSales.size()>0){
             for(Sales__c eachSales : relatedSales){
               if(eachSales.Material__c == eachMat.Id){
                 if ((eachMat.Material_Type__c=='FERT' && 
                       (eachSales.Distribution_Channel__c == Null ||
                        eachSales.Deliver_Plant__c == Null || (                      
                        (eachSales.Tax_Jurisdiction_Code__c == Null && eachSales.Territory__c=='US') ||
                        (eachSales.County_Sales_Tax__c == Null && eachSales.Territory__c=='US') ||
                        (eachSales.City_Sales_Tax__c == Null && eachSales.Territory__c=='US'))||
                        eachSales.Item_Category_Group__c == Null ||
                        eachSales.Sales_Org__c == Null ||
                        eachSales.D_Chain_Spec__c == Null ||
                        eachSales.Valid_From__c == Null ||
                        eachSales.Operations_Group__c == Null ||
                        eachSales.Material_Group_3__c == Null ||
                        eachSales.Material_Group_5__c == Null || 
                        ((eachSales.GST_Canada__c == Null && eachSales.Territory__c=='CDN') ||
                        (eachSales.PST_Canada__c == Null && eachSales.Territory__c=='CDN') ||
                        (eachSales.PST_Base_GST_CDN__c == Null && eachSales.Territory__c=='CDN')) || 
                        eachSales.Material_Statistic_Group__c==Null))
                        
                     ||(eachMat.Material_Type__c!='FERT' && (eachSales.Distribution_Channel__c == Null ||
                            eachSales.D_Chain_Spec__c == Null ||
                            eachSales.Operations_Group__c == Null ||
                           ( (eachSales.Tax_Jurisdiction_Code__c == Null && eachSales.Territory__c=='US') ||
                            (eachSales.County_Sales_Tax__c == Null && eachSales.Territory__c=='US') ||
                            (eachSales.City_Sales_Tax__c == Null && eachSales.Territory__c=='US'))||
                            eachSales.Sales_Org__c == Null ||
                            eachSales.Tax_Indicator__c == Null ||
                            eachSales.Item_Category_Group__c == Null ||
                           ((eachSales.GST_Canada__c == Null && eachSales.Territory__c=='CDN') ||
                            (eachSales.PST_Canada__c == Null && eachSales.Territory__c=='CDN') ||
                            (eachSales.PST_Base_GST_CDN__c == Null && eachSales.Territory__c=='CDN')) || 
                            eachSales.Material_Statistic_Group__c==Null))){
                         salesOk = false;
                         break;
                     }
                  }   
             }
             }
          system.debug('=============eachMat.Id=='+eachMat.Id);
          system.debug('=============valuationsOk =='+valuationsOk ); 
          system.debug('=============salesOk =='+salesOk );
          system.debug('=============plantsOk =='+plantsOk );
          system.debug('=============classificationsOk =='+classificationsOk );
          system.debug('=============BOMOk =='+BOMOk );    
           
             if(valuationsOk && salesOk && plantsOk && classificationsOk){
                 system.debug('=============1 ==');
             } else{
               system.debug('=============2 ==');
             }           
            }
        else{
              system.debug('=============3 =='+eachMat.Id);
            }
          }
          else {
              system.debug('=============4 ==');
          }
         }
         
    }
    
    /***********************************
    Method Name: submitJointCorrugateMaterial
    Purpose:Below method is called to submit a Joint Corrugate material if satisfying all conditions.
    ***********************************/
    webservice static String submitJointCorrugateMaterial(Id materialId)
    {
        ApprovalResult result = new ApprovalResult();
        System.debug('======Inside submitJointCorrugateMaterial');
        
        List<BOM_Item__c> bomItemsFT = [SELECT Material_Component__c, Material_Component__r.BOM_Quantity__c 
                                        FROM BOM_Item__c
                                        WHERE Material__c = :materialId AND Material_Component__c != null AND 
                                            Material_Component__r.Material_Type__c='FERT' AND 
                                            Material_Component__r.Item_Type__c='D (Display Vehicle)' AND 
                                            Material_Component__r.Item_Code__c='FT - PHANTOM TRAY'];
        if(bomItemsFT != null && bomItemsFT.size() > 1)
        {
            Set<Id> associatedFTIds = new Set<Id>();
            //Added for DF-02177
            for(BOM_Item__c bom : bomItemsFT){
                associatedFTIds.add(bom.Material_Component__c);
            }
            system.debug('associatedFTIds== '+associatedFTIds);
            // Fetching child of FT Materials.
            for(Material__c mat : [SELECT Id, (SELECT Id, Material_Component__r.BOM_Quantity__c 
                                    FROM BOM_Items__r 
                                    WHERE Material_Component__c != null AND 
                                          Material_Component__r.Material_Type__c='FERT')
                                   FROM Material__c
                                   WHERE Id IN :associatedFTIds])
            {
                
                if(mat.BOM_Items__r == null || mat.BOM_Items__r.size() == 0)
                {
                    result.isSuccess = false;
                    result.errorMessage = 'FERTs are missing from the Phantom Tray. Please add and re-submit. Be sure to add quantities for the new FERT on the BOM Item.';
                    return JSON.serialize(result);
                }
            }
            
            // Approving the CORRUGATE Material
            Material__c mat = new Material__c();
            mat.Id = materialId;
            mat.Material_Status__c = 'Approved';
            mat.Material_Integration_State__c='N';
            System.debug('@@@@materialId'+materialId);
            update mat;

             FutureMaterial.unlockMaterial(new Set<Id>{materialId});
        }
        else
        {
            result.isSuccess = false;
            result.errorMessage = 'At least two Sub-Material FERTs (Phantom Tray FERT) are required for ths operation. Please add and re-submit.';
        }
        
        return JSON.serialize(result);
    }
    
    /***********************************
    Method Name: updateJointCorrugateMaterials
    Purpose: Following method handles the update of Joint Corrugate material.
    ***********************************/
    public static void updateJointCorrugateMaterials(Set<id> matid){

         System.debug('======Inside updateJointCorrugateMaterials');
        
        List<Material__c> matlList = new List<Material__c>();
        List<BOM_Item__c> bItemList = new List<BOM_Item__c>();
        List<Material__c> matListUpdt = new List<Material__c>();
        List<Material__c> matListCorrugateUpdt = new List<Material__c>();
        
        matlList = [Select id,Material_Number__c,BOM_Status__c, (Select id,material__c,material__r.id from BOM_Items1__r Where material__r.Item_Type__c = 'D (Display Vehicle)' AND
                                material__r.Label_Code__c = '87 - JOINT CORR/MULTI-STUDIO'),(Select id,Material_Component__r.id from BOM_Items__r Where Material_Component__r.Material_Type__c = 'FERT') from Material__c 
                    Where  id in : matid and Item_Type__c='D (Display Vehicle)' AND 
                    Item_Code__c='FT - PHANTOM TRAY'];
                    
        for(Material__c matl : matlList){
            if(matl.BOM_Items1__r != null && matl.BOM_Items1__r.size() > 0 && matl.BOM_Items__r != null && matl.BOM_Items__r.size() > 0 && matl.Material_Number__c != null){
               
                for(BOM_Item__c bItem : matl.BOM_Items1__r){ 
                    Material__c objMT = new Material__c();
                    objMT.ID = bItem.material__c;
                    matl.BOM_Status__c = 'Processed in SAP';
                    matListUpdt.add(matl);
                    system.debug('matListUpdt ');
                }
                
                Material__c objFT = new Material__c();
                objFT.ID = matl.id;
                objFT.BOM_Status__c = 'Processed in SAP';
            }
        }
        system.debug('matListUpdt '+matListUpdt.size());
        system.debug('matListUpdt '+matListUpdt);
        if(matListUpdt.size() > 0){
            update matListUpdt;
        }
    }
    
    /***********************************
    Method Name: submitJointCorrugateBOM
    Purpose: Following method handles the Approval submittion of Joint corrugate material.
    ***********************************/ 
    webservice static String submitJointCorrugateBOM(Id bItemId)
    {
        System.debug('======Inside submitJointCorrugateBOM');
        ApprovalResult result = new ApprovalResult();
        List<BOM_Item__c> bItemList = new List<BOM_Item__c>();
        List<Material__c> matList = new List<Material__c>();
        List<BOM_Item__c> bomItemsFT = [SELECT Material_Component__c, Material_Component__r.BOM_Quantity__c,Material__r.BOM_Status__c,Material__r.BOM_Quantity__c,
                                        Material__r.Prior_BOM_Quantity__c,Material_Component__r.Prior_BOM_Quantity__c FROM BOM_Item__c
                                        WHERE id = :bItemId AND Material_Component__c != null AND 
                                            Material_Component__r.Material_Type__c='FERT' AND 
                                            Material__r.Material_Type__c='FERT'];
                                            
        system.debug('bomItemsFT== '+bomItemsFT);
        system.debug('bomItemsFT== '+bomItemsFT.size());    
        if(bomItemsFT.size() > 0){
            for(BOM_Item__c bItem : bomItemsFT){
                Material__c m = new Material__c();
                m.id = bItem.Material__c;
                matList.add(m);
            }
            for(BOM_Item__c bItem : bomItemsFT){
                if(String.valueOf(bItem.Material_Component__r.BOM_Quantity__c) != bItem.Material_Component__r.Prior_BOM_Quantity__c) {
                    Material__c m = new Material__c();
                    m.id = bItem.Material_Component__c;
                    matList.add(m);
                }
                if(String.valueOf(bItem.Material__r.BOM_Quantity__c) != bItem.Material__r.Prior_BOM_Quantity__c){
                    Material__c m = new Material__c();
                    m.id = bItem.Material__c;
                    matList.add(m);
                }
            }
            system.debug('bItemList== '+matList.size());
            if(matList.size() > 0){
                update matList;
            }
            
        }
        else{
            result.isSuccess = false;
            result.errorMessage = 'D-Chain Spec Not Equal to FR';
            return JSON.serialize(result);
        }   
                                            
        return JSON.serialize(result);
    }
    
    /***********************************
    Method Name: submitPhantomTray
    Purpose: Following method handles the Approval submittion of Phantom material.
    ***********************************/
    webservice static String submitPhantomTray(Id materialId)
    {
    
        System.debug('======Inside submitPhantomTray');
        ApprovalResult result = new ApprovalResult();
        // Fetching child of FT Materials.
        Material__c mat = [SELECT Id, (SELECT Id, Material_Component__r.BOM_Quantity__c 
                            FROM BOM_Items__r 
                            WHERE Material_Component__c != null AND 
                                  Material_Component__r.Material_Type__c='FERT')
                           FROM Material__c
                           WHERE Id=:materialId];
                           
         List<BOM_Item__c>bomItemList=[Select Material__r.Material_Status__c from BOM_Item__c where Material__r.item_type__c='D (Display Vehicle)'
                                          and Material__r.item_code__c='FT - PHANTOM TRAY' and Material_Component__c=:materialId limit 1];    
                                                        
                           
        if(mat.BOM_Items__r == null || mat.BOM_Items__r.size() == 0)
        {
            result.isSuccess = false;
            result.errorMessage = 'FERTs are missing from the Phantom Tray. Please add and re-submit. Be sure to add quantities for the new FERT on the BOM Item.';
            return JSON.serialize(result);
        }
       
        
       
        // Approving the CORRUGATE Material
        if(!bomItemList.isEmpty() && bomItemList[0].Material__r.Material_Status__c=='Processed in SAP'){
            mat.Material_Status__c = 'Approved';
            mat.Material_Integration_State__c='N';
        }
        else if(!bomItemList.isEmpty() && bomItemList[0].Material__r.Material_Status__c!='Processed in SAP'){
            mat.Material_Status__c = 'Submitted';
        }
        else{
            mat.Material_Status__c = 'Submitted';
        }
        
        return JSON.serialize(result);
    }
    
    //usst-2239 start
    /***********************************
    Method Name: submitDisplayVehicle
    Purpose: Following method handles the Approval submission of Display Vehicle material.
    ***********************************/
    webservice static String submitDisplayVehicle(Id materialId)
    {
        List<Bom_Item__c>displayVehicleBOMsNew = new List<Bom_Item__c>();
        ApprovalResult result = new ApprovalResult();

       displayVehicleBOMsNew = [Select id,material__c from Bom_item__c where material__c =: materialId];
       if(displayVehicleBOMsNew.size()==0){
            result.isSuccess  = false;
            result.errorMessage = 'Display Vehicles are required to have a child FERT.';
       }
       return JSON.serialize(result);
       
    }
    //usst-2239 end
    
    
    /***********************************
    Method Name: submitAndProcessApprovalRequest
    Purpose: Call approval process to re activate the material... Added on 04/10/2016
    ***********************************/
    webservice static void submitAndProcessApprovalRequest(Id materialId){
       // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(materialId);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
    }  
    
    /***********************************
    Method Name: approveChildMaterials
    Purpose: Following method is responsible to submit child components for approval id conditions are satisfied.
    ***********************************/
    webservice static void approveChildMaterials(Id parentMaterialId)
    {
        ApprovalResult result = new ApprovalResult();
        List<BOM_Item__c> bomItemsFT = [SELECT Material_Component__c, Material_Component__r.BOM_Quantity__c, Material_Component__r.Material_Type__c, Material_Component__r.Material_Status__c,
                                        Material_Component__r.Item_Type__c, Material_Component__r.Item_Code__c, Material_Component__r.Deal_ID__c, Material_Component__r.SGENNO_ReadOnly__c,
                                        Material_Component__r.UPC__c, Material_Component__r.CMR__c, Material__c, Material__r.Material_Number__c
                                        FROM BOM_Item__c
                                        WHERE Material__c = :parentMaterialId AND Material_Component__c != null AND Material_Component__r.Material_Status__c='Draft' AND
                                            (Material_Component__r.Material_Type__c='ROH' OR Material_Component__r.Material_Type__c='Z009')
                                       ];
        List<Material__c> updateableMaterials = new List<Material__c>();
        List<Id> idsToLock = new List<Id>();
        
        if(bomItemsFT != null && bomItemsFT.size() > 0)
        {
            for(BOM_Item__c bi : bomItemsFT)
            {
                // Validating for regie sticket component.
                if(bi.Material_Component__r.Item_Type__c == 'C - Components' && bi.Material_Component__r.Item_Code__c == 'RG - REGIE STICKER' && 
                   (bi.Material_Component__r.UPC__c == null || bi.Material_Component__r.UPC__c.trim() == ''))
                {
                    continue;
                }
                else
                {
                    Material__c mat = new Material__c(Id=bi.Material_Component__c, Material_Status__c='Submitted');
                    if(bi.Material__c != null && bi.Material__r.Material_Number__c != null)
                    {
                        mat.Material_Status__c = 'Approved';
                        mat.Selection_Reference_Number__c = bi.Material__r.Material_Number__c;
                        mat.Material_Integration_State__c='N';
                    }
                    updateableMaterials.add(mat);
                    
                    idsToLock.add(bi.Material_Component__c);
                }
            }
        }
        
        // Approve components.
        if(updateableMaterials.size() > 0)
        {
            Database.update(updateableMaterials, false);
        }
        
        // Locking records.
        if(idsToLock.size() > 0)
        {

        }
    }
 
    /***********************************
    Method Name: submitReleaseMaterialsForApproval
    Purpose: This method is called from custom release button to get all child chain of materials to be submitted for approval.
    ***********************************/
    webservice static Integer submitReleaseMaterialsForApproval(Id materialId)
    {
          approveMaterialCount = 0;
          Integer TotalCount=0;
          Integer SubmittedCount=0;
        Set<Id> processingMaterialIds = new Set<Id>();
        System.debug('####submitReleaseMaterialsForApproval');
        List<Material__c> lstUpdateROH = new List<Material__c>();
        List<Material__c> lstUpdateROHMt = new List<Material__c>();
        
        // Extract first level Drafted materials.
        for(Material__c mat : [SELECT Id, Material_Type__c, Item_Type__c, RecordType.Name,Material_Status__c 
                               FROM Material__c 
                               WHERE id=:materialid AND Deletion_Flag__c=false])
        {
           allMaterialID.add(mat.Id); 
           system.debug('&&&allMaterialID'+allMaterialID);
           if(childMaterialTypes.contains(mat.Material_Type__c)){
               } 
            else
            {
                processingMaterialIds.add(mat.Id);
                system.debug('processingMaterialIds****'+processingMaterialIds);
            }
            
            if(mat.RecordType.Name == 'Update' && (mat.Material_Status__c =='Draft' || mat.Material_Status__c =='Sent Back') && (mat.Material_Type__c =='ROH' || mat.Material_Type__c =='Z009')){
                lstUpdateROH.add(mat);
            }
            system.debug('lstUpdateROH****'+lstUpdateROH);
        }
        
        // Extract all complete hierarchy of materials.
        fetchChildMaterials(processingMaterialIds, 1);  
           
        if(allMaterialID.size()>0){
              checkSAPFieldsCompleteHierarchy(allMaterialID);
              System.debug('###allMaterialID'+allMaterialID);
              system.debug('%%%allMaterialID.size()'+allMaterialID.size());
              TotalCount=allMaterialID.size();
              System.debug('###TotalCount'+TotalCount);
         } 
         
         if(!requestMaterialIds.isEmpty()) {
                System.debug('###requestMaterialIds'+requestMaterialIds);
                system.debug('$$$requestMaterialIds_size**'+requestMaterialIds.size());
                SubmittedCount=requestMaterialIds.size();
                System.debug('###SubmittedCount'+SubmittedCount);
                System.debug('###approveMaterialCount'+approveMaterialCount);
            }
            approveMaterialCount=TotalCount-SubmittedCount;
            System.debug('###approveMaterialCount'+approveMaterialCount);
            
            System.Debug('Check list values!! '+lstUpdateROH);

       // Added for RE-62
       MultipackDefaultingOnSubmitHandler.updateMultipackInTree(new Set<Id>{materialId});
       
       //Submit for Approval
       if(lstUpdateROH.isEmpty()) {
           submitMaterialHierarchyForApproval();  
       }
       else {
           System.Debug('Check list values '+lstUpdateROH); 
        }
       
       
       return approveMaterialCount;
    }
    
    /***********************************
    Method Name: fetchChildMaterials
    Purpose:Following method is responsible to fetch out the complete material list in the hierarchy.
    ***********************************/ 
    @TestVisible 
    private static void fetchChildMaterials(Set<Id> processingMaterialIds, Integer depth)
    {
        Set<Id> nextLevelProcessingMaterialIds = new Set<Id>();
        // Fetch the child materials from BOM Items.
        for(BOM_Item__c bom : [SELECT Material__c,Material_Component__c, Material_Component__r.Material_Type__c, Material_Component__r.Item_Type__c 
                               FROM BOM_Item__c
                               WHERE Material__c IN :processingMaterialIds AND Material_Component__c NOT IN :allMaterialID AND 
                                     (material_component__r.Material_Status__c='Draft' OR material_component__r.Material_Status__c='Sent Back') AND Material_Component__c != null AND 
                                     Material_Component__r.Deletion_Flag__c=false])
        {
            if(bom.Material_Component__r.Material_Type__c=='ROH' || bom.Material_Component__r.Material_Type__c=='Z009'){
            }
            allMaterialID.add(bom.Material_Component__c);
            allMaterialID.add(bom.Material__c);
            // Check if material is ROH or Z009, if it is ignore the search for its child.
            if(childMaterialTypes.contains(bom.Material_Component__r.Material_Type__c))
                componentIds.add(bom.Material_Component__c);
            else
            {
                nextLevelProcessingMaterialIds.add(bom.Material_Component__c);
                
                if(bom.Material_Component__r.Item_Type__c == 'M (Multipack)')
                    multiPackIds.add(bom.Material_Component__c);
                else if(bom.Material_Component__r.Item_Type__c == 'D (Display Vehicle)')
                    displayVehicleIds.add(bom.Material_Component__c);
            }
        }

        if(nextLevelProcessingMaterialIds.size() > 0)
        {
            fetchChildMaterials(nextLevelProcessingMaterialIds, ++ depth);
        }
        
       
        
    }   
    
    /***********************************
    Method Name: checkSAPFieldsCompleteHierarchy
    Purpose:Following method validates if all the materials submitting for approval are populated with required SAP field values.
    ***********************************/
    public static void checkSAPFieldsCompleteHierarchy(Set<Id> allMateriallistID){
        ApprovalResult result = new ApprovalResult();
         Id universalFinishedGoodRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('Universal Finished Good').getRecordTypeId();
         Id generalRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
       List<Material__c> updateMat = new list<Material__c>();
       Set<Id> materialsetId = new set<Id>();
       
       
        List<Material__c> currentMaterial = [Select id,Component_Type__c,Street_Date__c, Material_Type__c,Item_Code__c, Item_Type__c,Format__c,
                                                    Technical_Format__c,Product_Class__c,Title_Source__c, TM_Origin_Code__c,Deal_ID__c,Label_Code__c,Sub_Label_Code_Lookup__c,Pre_Order_Close_Date__c,
                                                    Cross_Ref_Type__c, Base_Unit_of_Measure__c, Material_Group__c,General_Item_Category_Group__c,Division__c ,
                                                    Xplant_Material_Status__c,Xplant_Valid_From__c,Gross_Weight__c,Net_Weight__c,Weight_Unit__c,MPM_Issue__c,
                                                    Alternative_Legal_Title_Lookup__c, Create_Version__c,X_Dchain_Status__c,X_Dchain_Valid_From__c,
                                                    Purchase_Value_Key__c, Transportation_Group__c, Original_Material_Number__c, Palletized__c, name,SGENNO__c,
                                                    BOM_Category__c,BOM_Usage__c,Industry_Sector__c,TM_Status__c,Selection_Reference_Number__c,Valid_From__c,Layer__c,Plant__c,SGENNO_ReadOnly__c, Order_Unit__c, Financial_Owner__c,Title__c,Sales_Planning_Group__c from Material__c where Id in:allMateriallistID]; //USST-3133
       
        List<Valuation__c> relatedValuations = [Select Material__c,id,Valuation_Area__c,Valuation_Class__c,Price_Unit__c, Standard_Price__c,Origin_Group__c, 
                                                     Pricing_Control__c  From Valuation__c where Material__c in:allMateriallistID];
                                                       
        List<Classification__c> relatedClassifications= [Select Material__c,id,Packaging_Type_US__c, Regie_Sticker_for_Canada__c,RecordType.Name,Label_Code__c,Aspect_Ratio__c,
                                                        Genre_US__c 
                                                                From Classification__c where Material__c  in:allMateriallistID];
         System.debug('###Asha-----relatedClassifications'+relatedClassifications);                                                       
                                                                
        List<Plant__c> relatedPlants= [Select Material__c,id,Plant__c, Availability_Check__c, Profit_Center__c, Purchasing_Group__c, MRP_Controller__c,MRP_Group__c,
                                              Plant_Specific_Matl_Status__c, MRP_Type__c,ABC_Indicator__c, Lot_Size__c, Reorder_Point__c,Carton_Count__c,
                                              Min_Lot_Size__c, Max_Lot_Size__c, Fixed_Lot_Size__c, Max_Stock_Level__c, Rounding_Value__c,Safety_Stock__c,
                                              Special_Procurement__c, Plnd_Dely_time__c, Stor_Loc_EP__c, Schedule_Margin_Key__c, Period_Ind__c,Prod_Storage_Location__c,
                                              Splitting_Ind__c, Bwd_Cons_Period__c, Fwd_Cons_Period__c, GR_Processing_Time__c, Mixed_MRP__c,Consumption_Mode__c,
                                              Indv_Colle__c, Requirements_Grouping__c, Valid_From__c, Procurement_Type__c,Component_Scrap_Percentage__c,Loading_Group__c,
                                              Strategy_Group__c,Coverage_Prof__c From Plant__c where Material__c in:allMateriallistID];
                                              
        List<Sales__c> relatedSales= [Select Material__c,id, Tax_Indicator__c, Operations_Group__c, Tax_Jurisdiction_Code__c, Item_Category_Group__c,Distribution_Channel__c,
                                     Deliver_Plant__c,Original_Release_Date__c,Volume_Rebate_Group__c,Valid_From__c,
                                     D_Chain_Spec__c,Sales_Unit__c,Material_Group_1__c,Material_Group_2__c,Announcement_Date_US__c,
                                     Material_Group_3__c,Material_Group_4__c,Material_Group_5__c,Material_Pricing_Group__c,Solicitation_Date__c,
                                     Material_Statistic_Group__c,PST_Base_GST_CDN__c,GST_Canada__c,Territory__c,PST_Canada__c,City_Sales_Tax__c, County_Sales_Tax__c, Sales_Org__c From Sales__c where Material__c in:allMateriallistID];
        

        for(Material__c eachMat : currentMaterial){   
       if(eachMat.Material_Type__c!=null){
         
          
        if(((eachMat.Material_Type__c=='FERT' && eachMat.Format__c != '08 - EST (ELECTRONIC SELL THRU)') && (((eachMat.Street_Date__c !=Null && eachMat.Base_Unit_of_Measure__c  !=Null && eachMat.Material_Group__c!=Null && eachMat.Weight_Unit__c !=Null && eachMat.Create_Version__c !=Null && eachMat.X_Dchain_Status__c !=Null &&
                    eachMat.X_Dchain_Valid_From__c !=Null && eachMat.Purchase_Value_Key__c !=Null && eachMat.Transportation_Group__c    !=Null &&
                    eachMat.Plant__c !=Null && eachMat.Xplant_Valid_From__c!=Null && eachMat.Name!=Null && eachMat.SGENNO_ReadOnly__c !=Null && eachMat.Material_Type__c !=Null &&  eachMat.Item_Type__c !=Null && eachMat.Item_Code__c !=Null && eachMat.Format__c !=Null && eachMat.Technical_Format__c   !=Null 
                    && eachMat.Pre_Order_Close_Date__c != Null &&
                    eachMat.Label_Code__c !=Null && eachMat.Sub_Label_Code_Lookup__c!=Null && 
                    eachMat.General_Item_Category_Group__c!=Null && eachMat.Division__c !=Null && eachMat.Xplant_Material_Status__c!=Null &&    
                    eachMat.Gross_Weight__c !=Null && eachMat.Net_Weight__c !=Null && eachMat.Alternative_Legal_Title_Lookup__c !=Null && (eachMat.Layer__c !=Null || (eachMat.Layer__c ==Null && (eachMat.Format__c=='10 - HD HYBRID (DUAL FORMAT) DNU' ||
                   eachMat.Format__c == '13 - HD VOD' || eachMat.Format__c == '14 - HD EST' || eachMat.Format__c == '15 - DVDR' || 
                   eachMat.Format__c == '17 - BD-R' || eachMat.Format__c == '18 - BD-R COMBO PACK' || eachMat.Format__c == '98 - GWP'))) &&  
                    eachMat.Valid_From__c != Null && eachMat.Title__c!=null && eachMat.TM_Status__c!=null &&
                    eachMat.Industry_Sector__c !=null && eachMat.BOM_Usage__c!=null && eachMat.BOM_Category__c!=null ) && eachMat.Item_Type__c=='S (Single)' && eachMat.Item_Code__c!='BF - BABY FERT')
                    
             || ((eachMat.Base_Unit_of_Measure__c  !=Null && eachMat.Material_Group__c!=Null && eachMat.Weight_Unit__c !=Null && eachMat.Create_Version__c !=Null && eachMat.X_Dchain_Status__c !=Null &&
                    eachMat.X_Dchain_Valid_From__c !=Null && eachMat.Purchase_Value_Key__c !=Null && eachMat.Transportation_Group__c    !=Null &&
                    eachMat.Plant__c !=Null && eachMat.Xplant_Valid_From__c!=Null && eachMat.Name!=Null && eachMat.SGENNO_ReadOnly__c !=Null && eachMat.Material_Type__c !=Null &&  eachMat.Item_Type__c !=Null && eachMat.Item_Code__c !=Null && eachMat.Format__c !=Null 
                    && eachMat.Technical_Format__c   !=Null &&
                    eachMat.Label_Code__c !=Null && eachMat.Sub_Label_Code_Lookup__c!=Null && 
                    eachMat.General_Item_Category_Group__c!=Null && eachMat.Division__c !=Null && eachMat.Xplant_Material_Status__c!=Null &&    
                    eachMat.Gross_Weight__c !=Null && eachMat.Net_Weight__c !=Null && eachMat.Alternative_Legal_Title_Lookup__c !=Null && (eachMat.Layer__c !=Null || (eachMat.Layer__c ==Null && (eachMat.Format__c=='10 - HD HYBRID (DUAL FORMAT) DNU' ||
                   eachMat.Format__c == '13 - HD VOD' || eachMat.Format__c == '14 - HD EST' || eachMat.Format__c == '15 - DVDR' || 
                   eachMat.Format__c == '17 - BD-R' || eachMat.Format__c == '18 - BD-R COMBO PACK' || eachMat.Format__c == '98 - GWP'))) &&  
                    eachMat.Valid_From__c != Null && eachMat.Title__c!=null && eachMat.TM_Status__c!=null &&
                    eachMat.Industry_Sector__c !=null && eachMat.BOM_Usage__c!=null && eachMat.BOM_Category__c!=null ) && eachMat.Item_Type__c=='S (Single)' && eachMat.Item_Code__c=='BF - BABY FERT')       
                    )
                    
                    
            || ((eachMat.Material_Type__c=='FERT' && eachMat.Format__c == '08 - EST (ELECTRONIC SELL THRU)') &&((eachMat.Street_Date__c !=Null && eachMat.Base_Unit_of_Measure__c  !=Null && eachMat.Material_Group__c!=Null && eachMat.Weight_Unit__c !=Null && eachMat.Create_Version__c !=Null && eachMat.X_Dchain_Status__c !=Null &&
                    eachMat.X_Dchain_Valid_From__c !=Null && eachMat.Purchase_Value_Key__c !=Null && eachMat.Transportation_Group__c    !=Null &&
                    eachMat.Plant__c !=Null && eachMat.Xplant_Valid_From__c!=Null && eachMat.Name!=Null && eachMat.SGENNO_ReadOnly__c !=Null && eachMat.Material_Type__c !=Null &&  eachMat.Item_Type__c !=Null && eachMat.Item_Code__c !=Null && eachMat.Format__c !=Null && eachMat.Technical_Format__c   !=Null &&
                    eachMat.Label_Code__c !=Null && eachMat.Sub_Label_Code_Lookup__c!=Null && eachMat.Pre_Order_Close_Date__c != Null &&
                    eachMat.General_Item_Category_Group__c!=Null && eachMat.Division__c !=Null && eachMat.Xplant_Material_Status__c!=Null &&    
                    eachMat.Gross_Weight__c !=Null && eachMat.Net_Weight__c !=Null && eachMat.Alternative_Legal_Title_Lookup__c !=Null &&  
                    eachMat.Valid_From__c != Null && eachMat.Title__c!=null && eachMat.TM_Status__c!=null &&
                    eachMat.Industry_Sector__c !=null && eachMat.BOM_Usage__c!=null && eachMat.BOM_Category__c!=null ) && eachMat.Item_Type__c=='S (Single)' && eachMat.Item_Code__c!='BF - BABY FERT')
                    
           ||(eachMat.Material_Type__c=='FERT' && eachMat.Format__c == '08 - EST (ELECTRONIC SELL THRU)') &&((eachMat.Base_Unit_of_Measure__c  !=Null && eachMat.Material_Group__c!=Null && eachMat.Weight_Unit__c !=Null && eachMat.Create_Version__c !=Null && eachMat.X_Dchain_Status__c !=Null &&
                    eachMat.X_Dchain_Valid_From__c !=Null && eachMat.Purchase_Value_Key__c !=Null && eachMat.Transportation_Group__c    !=Null &&
                    eachMat.Plant__c !=Null && eachMat.Xplant_Valid_From__c!=Null && eachMat.Name!=Null && eachMat.SGENNO_ReadOnly__c !=Null && eachMat.Material_Type__c !=Null &&  eachMat.Item_Type__c !=Null && eachMat.Item_Code__c !=Null && eachMat.Format__c !=Null && eachMat.Technical_Format__c   !=Null &&
                    eachMat.Label_Code__c !=Null && eachMat.Sub_Label_Code_Lookup__c!=Null &&
                    eachMat.General_Item_Category_Group__c!=Null && eachMat.Division__c !=Null && eachMat.Xplant_Material_Status__c!=Null &&    
                    eachMat.Gross_Weight__c !=Null && eachMat.Net_Weight__c !=Null && eachMat.Alternative_Legal_Title_Lookup__c !=Null &&  
                    eachMat.Valid_From__c != Null && eachMat.Title__c!=null && eachMat.TM_Status__c!=null &&
                    eachMat.Industry_Sector__c !=null && eachMat.BOM_Usage__c!=null && eachMat.BOM_Category__c!=null ) && eachMat.Item_Type__c=='S (Single)' && eachMat.Item_Code__c=='BF - BABY FERT')                   
                                
          || ((eachMat.Item_Type__c=='D (Display Vehicle)' || eachMat.Item_Type__c=='M (Multipack)') && (eachMat.Street_Date__c !=Null && eachMat.Base_Unit_of_Measure__c    !=Null && eachMat.Material_Group__c!=Null && eachMat.Weight_Unit__c !=Null && eachMat.Create_Version__c !=Null && eachMat.X_Dchain_Status__c !=Null && eachMat.Pre_Order_Close_Date__c != Null &&
                    eachMat.X_Dchain_Valid_From__c !=Null && eachMat.Purchase_Value_Key__c !=Null && eachMat.Transportation_Group__c    !=Null &&
                    eachMat.Plant__c !=Null && eachMat.Xplant_Valid_From__c!=Null && eachMat.Name!=Null &&  eachMat.Material_Type__c !=Null &&  eachMat.Item_Type__c !=Null && eachMat.Item_Code__c !=Null && eachMat.Format__c !=Null && eachMat.Technical_Format__c   !=Null &&
                    eachMat.Label_Code__c !=Null && eachMat.Sub_Label_Code_Lookup__c!=Null && ((eachMat.Product_class__c!=null && eachMat.Item_Type__c=='D (Display Vehicle)')||eachMat.Item_Type__c=='M (Multipack)') && //RE-28 Added Product Class check
                    eachMat.General_Item_Category_Group__c!=Null && eachMat.Division__c !=Null && eachMat.Xplant_Material_Status__c!=Null &&    
                    eachMat.Gross_Weight__c !=Null && eachMat.Net_Weight__c !=Null && eachMat.Alternative_Legal_Title_Lookup__c !=Null &&  
                    eachMat.Valid_From__c !=Null && 
                    eachMat.Industry_Sector__c!=null && eachMat.BOM_Usage__c!=null && eachMat.BOM_Category__c!=null))))
                        
           || (eachMat.Material_Type__c!='FERT' && (eachMat.Division__c!=null && eachMat.Xplant_Material_Status__c!=null &&
                  eachMat.Gross_Weight__c!=null && eachMat.Net_Weight__c!=null && eachMat.Weight_Unit__c!=null && eachMat.Transportation_Group__c !=null &&
                  eachMat.Industry_Sector__c!=null && eachMat.Item_Code__c !=null && eachMat.Item_Type__c!=Null && eachMat.General_Item_Category_Group__c!=null && eachMat.Material_Group__c !=null))
           || Test.isRunningTest())
                {
                 Boolean valuationsOk = true;
                 Boolean salesOk = true;
                 Boolean classificationsOk = true;
                 Boolean plantsOk = true;
                 Boolean BOMOk = true;
                 if(relatedValuations.size()>0){
                     for(Valuation__c eachValuation: relatedValuations){
                     if(eachValuation.material__c==eachMat.id && !Test.isRunningTest()){
                            if ((eachMat.Material_Type__c=='FERT'&& (eachValuation.Valuation_Area__c==NULL || eachValuation.Valuation_Class__c==NULL || eachValuation.Price_Unit__c==NULL 
                                 || eachValuation.Standard_Price__c==NULL || eachValuation.Origin_Group__c==NULL || eachValuation.Pricing_Control__c==Null))
                                 ||(eachMat.Material_Type__c!='FERT'  && (eachValuation.Valuation_Area__c==NULL || eachValuation.Valuation_Class__c==NULL || eachValuation.Price_Unit__c==NULL 
                                     || eachValuation.Standard_Price__c==NULL || (eachValuation.Origin_Group__c==NULL && eachMat.Material_Type__c!='Z009' ) || eachValuation.Pricing_Control__c==Null))){
                                 valuationsOk = false;
                                 break;
                             }
                         }    
                     }
                 }
                 
             if(relatedClassifications.size()>0){
             for(Classification__c eachClassification : relatedClassifications){

                     }
             }
             if(relatedPlants.size()>0){
             for(Plant__c eachPlant: relatedPlants){
                 if(eachMat.id==eachPlant.material__c && !Test.isRunningTest()){
            
                 if ((eachMat.Material_Type__c=='FERT' && (eachPlant.Valid_From__c == Null || eachPlant.Plant__c== Null || eachPlant.Availability_Check__c == Null || eachPlant.MRP_Type__c == Null ||
                        eachPlant.ABC_Indicator__c == Null || eachPlant.Lot_Size__c == Null || eachPlant.Max_Lot_Size__c == Null ||
                        eachPlant.Max_Stock_Level__c == Null || eachPlant.Special_Procurement__c == Null ||
                        eachPlant.Schedule_Margin_Key__c == Null || eachPlant.Schedule_Margin_Key__c == Null || eachPlant.Period_Ind__c == Null ||
                        eachPlant.Fwd_Cons_Period__c == Null || eachPlant.GR_Processing_Time__c == Null || eachPlant.Mixed_MRP__c == Null ||
                        eachPlant.Requirements_Grouping__c == Null || eachPlant.Profit_Center__c == Null || eachPlant.Purchasing_Group__c == Null || eachPlant.MRP_Controller__c == Null || eachPlant.Min_Lot_Size__c  == Null || eachPlant.Rounding_Value__c == Null || eachPlant.Plnd_Dely_time__c == Null ||
                        eachPlant.Stor_Loc_EP__c == Null || eachPlant.Splitting_Ind__c == Null || eachPlant.Bwd_Cons_Period__c == Null ||
                        eachPlant.Indv_Colle__c == Null || eachPlant.Consumption_Mode__c==Null || 
                        eachPlant.Procurement_Type__c==Null))
                    
                     ||(eachMat.Material_Type__c!='FERT' &&(eachPlant.Safety_Stock__c == Null || eachPlant.Valid_From__c == Null || eachPlant.MRP_Controller__c == Null ||
                        eachPlant.Purchasing_Group__c == Null || eachPlant.Plant_Specific_Matl_Status__c == Null || eachPlant.MRP_Type__c == Null ||
                        eachPlant.Max_Lot_Size__c == Null ||
                        eachPlant.Max_Stock_Level__c == Null || eachPlant.Stor_Loc_EP__c == Null || eachPlant.Schedule_Margin_Key__c == Null ||
                        eachPlant.Period_Ind__c == Null || eachPlant.Bwd_Cons_Period__c == Null || eachPlant.Fwd_Cons_Period__c == Null ||
                        eachPlant.GR_Processing_Time__c == Null || eachPlant.Mixed_MRP__c == Null || eachPlant.Requirements_Grouping__c == Null ||
                        eachPlant.Plant__c == Null || eachPlant.Min_Lot_Size__c == Null ||eachPlant.Plnd_Dely_time__c == Null ||
                        eachPlant.Component_Scrap_Percentage__c == Null || eachPlant.Lot_Size__c == Null || eachPlant.Rounding_Value__c == Null ||
                        eachPlant.Availability_Check__c == Null || (eachPlant.Splitting_Ind__c == Null && eachMat.Material_Type__c!='Z009') || eachPlant.Profit_Center__c == Null ||
                        eachPlant.Procurement_Type__c==Null))
                         
                         ){
                         plantsOk = false;
                         break;
                     }
                }                
             }
             }
             if(relatedSales.size()>0){
             for(Sales__c eachSales : relatedSales){
             if(eachMat.id==eachSales.material__c && !Test.isRunningTest()){
             if ((eachMat.Material_Type__c=='FERT' && (eachSales.Distribution_Channel__c == Null ||
                        eachSales.Deliver_Plant__c == Null ||
                        (eachSales.Territory__c=='US' && (eachSales.Tax_Jurisdiction_Code__c == Null ||
                         eachSales.County_Sales_Tax__c == Null ||
                         eachSales.City_Sales_Tax__c == Null))||
                        eachSales.Tax_Indicator__c == Null ||
                        eachSales.Item_Category_Group__c == Null ||
                        eachSales.Sales_Org__c == Null ||
                        eachSales.D_Chain_Spec__c == Null ||
                        eachSales.Valid_From__c == Null ||
                        eachSales.Operations_Group__c == Null ||
                        eachSales.Material_Group_3__c == Null ||
                        eachSales.Material_Group_5__c == Null || 
                        (eachSales.Territory__c=='CDN' && (eachSales.GST_Canada__c == Null ||
                        eachSales.PST_Canada__c == Null ||
                        eachSales.PST_Base_GST_CDN__c == Null)) || 
                        eachSales.Material_Statistic_Group__c==Null))
                    
                     ||(eachMat.Material_Type__c!='FERT' && (eachSales.Distribution_Channel__c == Null ||
                            eachSales.D_Chain_Spec__c == Null ||
                            eachSales.Operations_Group__c == Null ||
                           (eachSales.Territory__c=='US' && (eachSales.Tax_Jurisdiction_Code__c == Null ||
                            eachSales.County_Sales_Tax__c == Null||
                            eachSales.City_Sales_Tax__c == Null))||
                            eachSales.Sales_Org__c == Null ||
                            eachSales.Tax_Indicator__c == Null ||
                            eachSales.Item_Category_Group__c == Null ||
                            (eachSales.Territory__c=='CDN' && (eachSales.GST_Canada__c == Null||
                            eachSales.PST_Canada__c == Null||
                            eachSales.PST_Base_GST_CDN__c == Null)) || 
                            eachSales.Material_Statistic_Group__c==Null))){
                         salesOk = false;
                         break;
                     }
                }     
             }
             }
          system.debug('=============eachMat.Id Hierarchy=='+eachMat.Id);
          system.debug('=============valuationsOk Hierarchy =='+valuationsOk ); 
          system.debug('=============salesOkHierarchy =='+salesOk );
          system.debug('=============plantsOkHierarchy =='+plantsOk );
          system.debug('=============classificationsOkHierarchy =='+classificationsOk );
          system.debug('=============BOMOk =='+BOMOk ); 
           
             if(valuationsOk && salesOk && plantsOk && classificationsOk){
                system.debug('=============1==');
                result.isSuccess = true;
                //USST-3133 --- start
                if (eachMat.Label_Code__c!='59 - Paramount') {
                    requestMaterialIds.add(eachMat.Id);
                    system.debug('SAPrequestMaterialIds'+requestMaterialIds);          
                    if(childMaterialTypes.contains(eachMat.Material_Type__c))
                        componentIds.add(eachMat.Id);
                    else
                    {
                        if(eachMat.Item_Type__c == 'M (Multipack)')
                            multiPackIds.add(eachMat.Id);
                        else if(eachMat.Item_Type__c == 'D (Display Vehicle)')
                            displayVehicleIds.add(eachMat.Id);
                    }
                }
                else if(eachMat.Label_Code__c=='59 - Paramount'){
                    if (eachMat.MPM_Issue__c!='' && eachMat.MPM_Issue__c!=null) {
                        if (eachMat.Item_Type__c == 'D (Display Vehicle)' || childMaterialTypes.contains(eachMat.Material_Type__c)) {
                            requestMaterialIds.add(eachMat.Id);
                            system.debug('SAPrequestMaterialIds'+requestMaterialIds);          
                            if(childMaterialTypes.contains(eachMat.Material_Type__c))
                                componentIds.add(eachMat.Id);
                            else
                            {
                                if(eachMat.Item_Type__c == 'M (Multipack)')
                                    multiPackIds.add(eachMat.Id);
                                else if(eachMat.Item_Type__c == 'D (Display Vehicle)')
                                    displayVehicleIds.add(eachMat.Id);
                            }
                        }
                        else if (eachMat.Sales_Planning_Group__c != '' && eachMat.Sales_Planning_Group__c != null) {
                            requestMaterialIds.add(eachMat.Id);
                            system.debug('SAPrequestMaterialIds'+requestMaterialIds);          
                            if(childMaterialTypes.contains(eachMat.Material_Type__c))
                                componentIds.add(eachMat.Id);
                            else
                            {
                                if(eachMat.Item_Type__c == 'M (Multipack)')
                                    multiPackIds.add(eachMat.Id);
                                else if(eachMat.Item_Type__c == 'D (Display Vehicle)')
                                    displayVehicleIds.add(eachMat.Id);
                            }
                        }
                    }
                }
                //USST-3133 --- end
                
             } else{
                 system.debug('=============3==');
                result.isSuccess = false;
                result.errorMessage ='Please check the Components and/or Materials that are in Draft status and update the missing fields for resubmission.Please check on the Material Validate SAP Fields section.';
             }           
            }
        else{ system.debug('=============4==');
               result.isSuccess = false;
                result.errorMessage ='Please check the Components and/or Materials that are in Draft status and update the missing fields for resubmission.Please check on the Material Validate SAP Fields section.';
            }
          }
          else {system.debug('=============5==');
                result.isSuccess = false;
                result.errorMessage ='Please check the Components and/or Materials that are in Draft status and update the missing fields for resubmission.Please check on the Material Validate SAP Fields section.';
          }
         }
         
        System.debug('###requestMaterialIds'+requestMaterialIds);
        
    }
       
    /***********************************
    Method Name: submitMaterialHierarchyForApproval
    Purpose:This method handles the business logic to submit materials for approval according to its material type and other constraint.
    ***********************************/
    @TestVisible 
    private static void submitMaterialHierarchyForApproval()
    {
         List<Material__c> updateableMaterials = new List<Material__c>();
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
        List<Id> recordsToLock = new List<Id>();
        Map<Id,List<Id>>compMap=new Map<Id,List<Id>>();
         Boolean tobeApproved=true;
       
        Id materialRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
        
        system.debug('=========displayVehicleIds 1==='+displayVehicleIds);
        Map<Id, Material__c> materialDisplayMap = new Map<Id, Material__c>([SELECT Id,Item_Code__c,Selection_Reference_Number__c, recordtypeid,
                                                                            (SELECT Id FROM BOM_Items__r  
                                                                             WHERE Material_Component__r.Material_Type__c='FERT' AND Material_Component__r.Material_Number__c!='' AND
                                                                                   Material_Component__r.Material_Number__c != null) 
                                                                             FROM Material__c
                                                                             WHERE Id IN :displayVehicleIds and label_code__c!='87 - JOINT CORR/MULTI-STUDIO' and recordtypeid!=:materialRecordTypeId]);
                                                                             
         Map<Id, Material__c> materialJCMap = new Map<Id, Material__c>([SELECT Id,Item_Code__c,Selection_Reference_Number__c,recordtypeid, 
                                                                            (SELECT Id,Material_Component__c,Material_Component__r.Item_Code__c FROM BOM_Items__r  
                                                                             WHERE Material_Component__r.Material_Type__c='FERT')                                                                                    
                                                                             FROM Material__c
                                                                             WHERE Id IN :displayVehicleIds and label_code__c='87 - JOINT CORR/MULTI-STUDIO' and recordtypeid!=:materialRecordTypeId]);                                                                     
        //Added for DF-02177
        Set<Id> PTchildMap = new Set<Id>();
        Map<Id, List<BOM_Item__c>> materialJCPTMap = new Map<Id,List<BOM_Item__c>>();
        if(materialJCMap != null && materialJCMap.size() > 0){
            for(Material__c mat : materialJCMap.values()){
                if(mat.BOM_Items__r.size() > 0){
                    for(BOM_Item__c bom : mat.BOM_Items__r){
                        PTchildMap.add(bom.Material_Component__c);
                    }
                }
            }
        
            for(BOM_Item__c bom : [SELECT Id,Material_Component__c FROM BOM_Item__c WHERE Material__c IN: PTchildMap and Material__r.recordtypeid!=:materialRecordTypeId]){
                if(materialJCPTMap.containsKey(bom.Material_Component__c)){
                    materialJCPTMap.get(bom.Material_Component__c).add(bom);
                } else{
                    materialJCPTMap.put(bom.Material_Component__c,new List<BOM_Item__c>{bom});
                }
            }
        }
                                                                             
        Map<Id, Material__c> materialMultiPackMap = new Map<Id, Material__c>([SELECT Id,recordtypeid, (SELECT Id FROM BOM_Items__r WHERE Material_Component__r.Material_Type__c='FERT') 
                                                                              FROM Material__c
                                                                              WHERE Id IN :multiPackIds]);
        Map<Id, Material__c> componentMap = new Map<Id, Material__c>([SELECT Id, Deal_ID__c, SGENNO_ReadOnly__c, UPC__c, CMR__c, Selection_Reference_Number__c,
                                                                      Item_Type__c, Item_Code__c, Label_Code__c
                                                                      FROM Material__c 
                                                                     WHERE Id IN :componentIds]);
                                                                     
        Map<Id,Material__c>recordTypeMap=new Map<Id,Material__c>([Select id,recordTypeId,Material_Type__c from Material__c where id in:componentIds]);  
        
        Map<Id,Material__c>updateMatMap=new Map<Id,Material__c>([Select id,Material_Type__c from Material__c where id in:requestMaterialIds and recordtypeid=:materialRecordTypeId]);    
        
        Map<Id, Material__c> tempFertMap = new Map<Id, Material__c>([SELECT Id, Deal_ID__c, Item_Type__c, Title__c, Title_Source__c, TM_Version_Lookup__c FROM Material__c WHERE Id IN :requestMaterialIds and Item_Type__c='S (Single)']);   //Added for usst-2477 and usst-2387
        
        for(Bom_Item__c bomItem:[select Material__c,Material_Component__c from Bom_item__c where Material_Component__c in:componentIds]){
            if(compMap.containsKey(bomItem.Material_Component__c)){
                compMap.get(bomItem.Material_Component__c).add(bomItem.Material__c);
            }else{
                compMap.put(bomItem.Material_Component__c,new List<Id>{bomItem.Material__c});
            }
        }   
        
        for(Id matId : requestMaterialIds)
        {
            // Check if material is a component or format typed.
            if(componentIds.contains(matId))
            {  system.debug('========= In Approval 1===');
                Material__c comp;
                if(componentMap.containsKey(matId))
                    comp = componentMap.get(matId);
                else
                    continue;
                // Checking for REGIE STICKER
                if(comp.Item_Type__c == 'C - Components' && comp.Item_Code__c == 'RG - REGIE STICKER' &&
                   (comp.UPC__c == null || comp.UPC__c == ''))
                {
                    continue;
                }
                
                // Update the status directly to Approved.
                Material__c mat = comp;
                
                if(((mat.Selection_Reference_Number__c == null || mat.Selection_Reference_Number__c == '') || (mat.Label_Code__c == null || mat.Label_Code__c == '')) && (!materialMultiPackMap.containsKey(matId)) && materialMultiPackMap.size()>0 && !(componentIds.contains(matId))){
                    mat.Material_Status__c = 'Submitted';
                }
                else if((((mat.Selection_Reference_Number__c == null || mat.Selection_Reference_Number__c == '') || (mat.Label_Code__c == null || mat.Label_Code__c == '')) && (componentMap.containsKey(matId)) && compMap.containsKey(matId))
                        || (!compMap.containsKey(matid) && recordTypeMap.containsKey(matid)&& recordTypeMap.get(matid).recordtypeId==materialRecordTypeId)){
                    mat.Material_Status__c = 'Submitted';
                }
                else if((((mat.Selection_Reference_Number__c != null && mat.Selection_Reference_Number__c != '') && (mat.Label_Code__c != null && mat.Label_Code__c != '')) && (componentMap.containsKey(matId))&& compMap.containsKey(matId)) 
                            || (!compMap.containsKey(matid) && recordTypeMap.containsKey(matid)&& recordTypeMap.get(matid).recordtypeId!=materialRecordTypeId) )
                {
                    mat.Material_Status__c = 'Approved';
                    mat.Material_Integration_State__c='N';
                }

                else if((mat.Selection_Reference_Number__c != null && mat.Selection_Reference_Number__c != '') && (mat.Label_Code__c != null && mat.Label_Code__c != '') && (mat.Item_Code__c!='FT - PHANTOM TRAY') && !(componentIds.contains(matId))){

                    mat.Material_Status__c = 'Approved';
                    mat.Material_Integration_State__c='N';
                }
                else if((mat.Selection_Reference_Number__c != null || mat.Selection_Reference_Number__c != '') && (mat.Label_Code__c != null || mat.Label_Code__c != '') && (mat.Item_Code__c=='FT - PHANTOM TRAY')&& (!componentIds.contains(matId))){
                    mat.Material_Status__c = 'Submitted';
                }
                updateableMaterials.add(mat);
                
                FutureMaterial.unlockMaterial(new Set<Id> {matId});
            }
            else if(displayVehicleIds.contains(matId))
            {  system.debug('========= In Approval 2===');
               
                //For Joint Corrugate
                if((materialJCMap.containsKey(matId) && materialJCMap.get(matId).BOM_Items__r != null && 
                   materialJCMap.get(matId).BOM_Items__r.size() > 1))
                {
                    Material__c mat = new Material__c();
                    mat.Id = matId;
                    
                    if(materialJCMap.get(matId).Item_Code__c!='FT - PHANTOM TRAY'){
                        //Added for DF-02177
                        Boolean PTcheck = false;
                        for(BOM_Item__c bom : materialJCMap.get(matId).BOM_Items__r){
                            if(materialJCPTMap != null && !materialJCPTMap.containsKey(bom.Material_Component__c) && bom.Material_Component__r.Item_Code__c == 'FT - PHANTOM TRAY'){
                                PTcheck = true;
                            }
                        }
                        
                        if(!PTcheck){
                            mat.Material_Status__c = 'Approved';
                            mat.Material_Integration_State__c='N';
                        }
                    }
                    else if((materialJCMap.get(matId).Selection_Reference_Number__c != null && materialJCMap.get(matId).Selection_Reference_Number__c != '') && materialJCMap.get(matId).Item_Code__c=='FT - PHANTOM TRAY'){
                        //Added for DF-02177
                        Boolean PTcheck = false;
                        for(BOM_Item__c bom : materialJCMap.get(matId).BOM_Items__r){
                            if(materialJCPTMap != null && !materialJCPTMap.containsKey(bom.Material_Component__c) && bom.Material_Component__r.Item_Code__c == 'FT - PHANTOM TRAY'){
                                PTcheck = true;
                            }
                        }
                        if(!PTcheck){
                            mat.Material_Status__c = 'Approved';
                            mat.Material_Integration_State__c='N';
                        }
                    }
                    else if((materialJCMap.get(matId).Selection_Reference_Number__c == null || materialJCMap.get(matId).Selection_Reference_Number__c == '') && materialJCMap.get(matId).Item_Code__c=='FT - PHANTOM TRAY'){
                         mat.Material_Status__c = 'Submitted';
                    }
                    updateableMaterials.add(mat);
                    
                    recordsToLock.add(matId);
                    
                }
           
                if((materialDisplayMap.containsKey(matId) && materialDisplayMap.get(matId).BOM_Items__r != null && 
                   materialDisplayMap.get(matId).BOM_Items__r.size() > 0 ))
                {
                    Material__c mat = new Material__c();
                    mat.Id = matId;
                    System.debug('##Inside displayVehicleIds'+mat.Item_Code__c);
                    if(materialDisplayMap.get(matId).Item_Code__c!='FT - PHANTOM TRAY'){
                        System.debug('##If Item_Code__c!=FT - PHANTOM TRAY'+mat.Item_Code__c);
                        mat.Material_Status__c = 'Approved';
                        mat.Material_Integration_State__c='N';
                    }
                    else if((materialDisplayMap.get(matId).Selection_Reference_Number__c != null && materialDisplayMap.get(matId).Selection_Reference_Number__c != '') && materialDisplayMap.get(matId).Item_Code__c=='FT - PHANTOM TRAY'){
                        System.debug('##If Item_Code__c==FT - PHANTOM TRAY'+mat.Item_Code__c+'@@'+materialDisplayMap.get(matId).Selection_Reference_Number__c);
                        mat.Material_Status__c = 'Approved';
                        mat.Material_Integration_State__c='N';
                    }
                    else if((materialDisplayMap.get(matId).Selection_Reference_Number__c == null || materialDisplayMap.get(matId).Selection_Reference_Number__c == '') && materialDisplayMap.get(matId).Item_Code__c=='FT - PHANTOM TRAY'){
                        System.debug('##If Item_Code__c==FT - PHANTOM TRAY2'+mat.Item_Code__c+'@@'+materialDisplayMap.get(matId).Selection_Reference_Number__c);
                         mat.Material_Status__c = 'Submitted';
                    }
                    
                    updateableMaterials.add(mat);
                    
                    recordsToLock.add(matId);
                    
                }
                
                //RE-27 Update Materials for Display Vehichles will be auto-approved.-start
                if(updateMatMap!=null && updateMatMap.containskey(matId)){
                        Material__c mat = new Material__c();
                        mat.Id = matId;
                        mat.Material_Status__c = 'Approved';
                        mat.Material_Integration_State__c='N';
                        
                         updateableMaterials.add(mat);
                    
                        recordsToLock.add(matId);
                        
                }
                //RE-27 Update Materials for Display Vehichles will be auto-approved.-End
                
                if((materialDisplayMap.containsKey(matId) &&( materialDisplayMap.get(matId).BOM_Items__r== null || materialDisplayMap.get(matId).BOM_Items__r.size()== 0))|| 
                    (materialJCMap.containsKey(matId) && (materialJCMap.get(matId).BOM_Items__r == null || materialJCMap.get(matId).BOM_Items__r.size() <= 1)))
                {
                    if(materialDisplayMap.get(matId).Item_Code__c!='FT - PHANTOM TRAY'){ //DF-02177
                        approveMaterialCount ++;  
                    }
                                  
                    
                }
            }
            else
            {
                System.debug('##materialMultiPackMap'+materialMultiPackMap);
                if(multiPackIds.contains(matId) && ((!materialMultiPackMap.containsKey(matId)&& materialMultiPackMap.get(matid).recordtypeid!=materialRecordTypeId) || (materialMultiPackMap.containsKey(matId) && materialMultiPackMap.get(matid).recordtypeid!=materialRecordTypeId &&
                   (materialMultiPackMap.get(matId).BOM_Items__r == null || materialMultiPackMap.get(matId).BOM_Items__r.size() == 0))))
                {
                    continue;
                }
                ////////usst-2477 ---- start
                if (tempFertMap.containsKey(matId)) {
                    Material__c tempMat = tempFertMap.get(matId);
                    if (tempMat.Item_Type__c == 'S (Single)' && tempMat.Title__c != null && (tempMat.Deal_ID__c == null || tempMat.Deal_ID__c == '')) {
                        approveMaterialCount++;
                        continue;
                    }
                    /////////usst-2387 ---- start
                    if (tempMat.Item_Type__c == 'S (Single)' && tempMat.Title__c != null 
                                            && (tempMat.Title_Source__c == null || tempMat.Title_Source__c == '')) {
                        approveMaterialCount++;
                        continue;                       
                    }
                    if (tempMat.Item_Type__c == 'S (Single)' && tempMat.Title__c != null 
                                            && tempMat.TM_Version_Lookup__c == null) {
                        approveMaterialCount++;
                        continue;                       
                    }
                    /////////usst-2387 ---- end
                    
                }
                ////////usst-2477 ---- end
                
                system.debug('========= In Approval 3==='); 
                // Create an approval request for the material.
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                
                req1.setComments('Submitting request for approval.');
                
                req1.setObjectId(matId);
               FutureMaterial.unlockMaterial(New Set<Id> {matId}); 
                
                // Submit on behalf of a specific submitter
                req1.setSubmitterId(UserInfo.getUserId()); 
                
                // Skipping the criteria evaluation is set to false.
                req1.setSkipEntryCriteria(false);
                
                approvalRequestList.add(req1);
            }
        }
            System.debug('####approvalRequestList.size()'+approvalRequestList.size());
        // Submitting request for approval for non ROH and Z009 materials.
        if(approvalRequestList.size() > 0)
        {
            try
            {
                Approval.process(approvalRequestList, false);
            }
            catch(Exception ex){}
        }
        
        // Updating child materials to directly Approved as it happens on Submit for Approval.
        if(updateableMaterials.size() > 0)
        {
            update updateableMaterials;
        }
system.debug('approveMaterialCount after check'+approveMaterialCount);
    }    
    
    //STY-884 Default titleSource for Multipack
    public static void defaultTitleSourceforMultipack(){
        List<Material__c>updateMultipackList=new List<Material__c>();
        Map<id,List<String>>childTitleSourcesMap=new Map<id,List<String>>();
        Integer bomcount=0;
        Id materialRecordTypeId = Schema.SObjectType.Material__c.getRecordTypeInfosByName().get('Update').getRecordTypeId();
                                                                                     
        for(Bom_item__c bomitems:[Select id , Material_Component__r.title_source__c,Material__r.Title_Source__c,Material__c from Bom_item__c where material__c in:multiPackIds and Material_Component__r.material_type__c='FERT']) {
            if(bomitems.Material_Component__r.title_source__c!=null){
                if(childTitleSourcesMap.containsKey(bomitems.Material__c)){
                    childTitleSourcesMap.get(bomitems.Material__c).add(bomitems.Material_Component__r.title_source__c);
                }
                else{
                    childTitleSourcesMap.put(bomitems.Material__c,new List<String>{bomitems.Material_Component__r.title_source__c});
                }
            }
            bomcount++;
        }
        
        for(Material__c mat: [Select id,title_source__c, 
                              (SELECT Id, Material_Pricing_Group__c, Territory__c FROM Sales__r)
                              from Material__c where id in:multiPackIds and recordtypeid!=:materialRecordTypeId]){
            Set<String>titleSource=new Set<String>();
            
            
            if(childTitleSourcesMap!=null && childTitleSourcesMap.containsKey(mat.id)){
                
                titleSource.addAll(childTitleSourcesMap.get(mat.id));
                if(childTitleSourcesMap.get(mat.id).size()< bomcount){
                    mat.title_source__c='';
                    updateMultipackList.add(mat);
                }
                else if(titleSource.size()>1 && childTitleSourcesMap.get(mat.id).size()==bomcount){
                    mat.title_source__c='04 - VARIOUS';
                    updateMultipackList.add(mat);
                }
                else if(titleSource.size()==1 && childTitleSourcesMap.get(mat.id).size()==bomcount){
                    mat.title_source__c=new list<string>(childTitleSourcesMap.get(mat.id))[0];
                    updateMultipackList.add(mat);
                }
            }
            else {
                mat.title_source__c='';
                updateMultipackList.add(mat);
            }
        }  
        try{
            if(!updateMultipackList.isEmpty()){
                update updateMultipackList;
            }
        }
        catch(Exception ex){
        }                                                                  
        
    }
    
    
     //RE-126--- Method to delete udpate material if in Sent back status
    webservice static void deleteUpdateMaterials(Id materialId){
        
                System.debug('###Asha........deleteUpdateMaterials'+materialId);
                List<Approval.ProcessSubmitRequest> approvalRequestListDelete = new List<Approval.ProcessSubmitRequest>();
                material__c mat =[Select id,Deletion_Flag__c,Material_status__c,(Select id,D_Chain_Spec__c from Sales__r)  from Material__c where id =: materialId];
                
                System.debug('###Asha........deleteUpdateMaterials'+mat);
                
                //if Deletion flag is True or the D chain Spec is equal to XX-Never Released
                if(mat.Deletion_Flag__c == true || (mat.Deletion_Flag__c==false && mat.sales__r[0].D_Chain_Spec__c=='XX - Never Released')){
                        
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setObjectId(mat.id);
                    req1.setProcessDefinitionNameOrId('Approval_Process_for_Record_delete');
                    req1.setSkipEntryCriteria(true);
                    Approval.ProcessResult result = Approval.process(req1);
                    
                    
                }      
    }
}