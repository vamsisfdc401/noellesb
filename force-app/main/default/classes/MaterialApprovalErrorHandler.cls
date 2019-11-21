/*****************************************************************************************
Class Name: MaterialApprovalErrorHandler
Purpose: Handler class for Checking Material Mandatory fields
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0                                                      Initial Development
******************************************************************************************/

public class MaterialApprovalErrorHandler
{
    //public variables
    public list<string> matFieldName{get;set;}
    public list<string> valuationFieldName{get;set;}
    public list<string> classificationFieldName{get;set;}
    public list<string> plantFieldName{get;set;}
    public list<string> SaleFieldName{get;set;}
    public list<string> bomFieldName{get;set;}
    public Id materialId;
    public Boolean refreshPage { get; set; }
    public MaterialApprovalErrorHandler(ApexPages.StandardController controller) {
      refreshPage=false;
      materialId = apexpages.currentpage().getparameters().get('id');
      checkSAPApprovalFieldsComplete();
    }
    
    //On material page load, call the method to check the SAP Fields
    public PageReference loadPage() {
        checkSAPApprovalFieldsComplete();       
        //refreshPage=true;
        return null;
    }
    
    //On material page load, check the SAP required Fields are populated
     public void checkSAPApprovalFieldsComplete(){       
       matFieldName = new list<string>();
       valuationFieldName = new list<string>();
       classificationFieldName = new list<string>();
       plantFieldName = new list<string>();
       SaleFieldName = new list<string>();
       bomFieldName = new list<string>();
       
       Id universalFinishedGoodRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('Universal Finished Good').getRecordTypeId();
       Id generalRecordTypeId = Schema.SObjectType.Classification__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
       
       //List to store the current materials SAP required fields
       List<Material__c> currentMaterial = [Select id,Street_Date__c, Material_Type__c,Material_Status__c ,Item_Code__c, Item_Type__c,Format__c,
                                                    Technical_Format__c,Product_Class__c,Title_Source__c, TM_Origin_Code__c,Deal_ID__c,Label_Code__c,Sub_Label_Code_Lookup__c,Pre_Order_Close_Date__c,
                                                    Cross_Ref_Type__c, Base_Unit_of_Measure__c, Material_Group__c,General_Item_Category_Group__c,Division__c ,
                                                    Xplant_Material_Status__c,Xplant_Valid_From__c,Gross_Weight__c,Net_Weight__c,Weight_Unit__c, TM_Version_Lookup__c,
                                                    Alternative_Legal_Title_Lookup__c, Create_Version__c,X_Dchain_Status__c,X_Dchain_Valid_From__c,
                                                    Purchase_Value_Key__c, Transportation_Group__c, Original_Material_Number__c, Palletized__c, name,SGENNO__c,
                                                    Selection_Reference_Number__c, Order_Unit__c, Financial_Owner__c,Component_Type__c,Release__c,
                                                    BOM_Category__c,BOM_Usage__c,Industry_Sector__c,TM_Status__c,Layer__c,Valid_From__c,Plant__c,SGENNO_ReadOnly__c,Theatrical_Release_Date__c,Title__c from Material__c where Id=:materialId];
        
        //List to store the current valuation SAP required fields 
        List<Valuation__c> relatedValuations = [Select Material__c,id,Valuation_Area__c,Valuation_Class__c,Price_Unit__c, Standard_Price__c,Origin_Group__c, 
                                                 Pricing_Control__c From Valuation__c where Material__c=:materialId AND Deletion_Flag__c= FALSE];
        
        //List to store the current classification SAP required fields                                               
        List<Classification__c> relatedClassifications= [Select Material__c,id,Packaging_Type_US__c, Regie_Sticker_for_Canada__c,RecordType.Name,Label_Code__c,Aspect_Ratio__c,
                                                        Genre_US__c 
                                                                From Classification__c where Material__c=:materialId AND Deletion_Flag__c= FALSE];
        
        //List to store the current plant SAP required fields                                                        
        List<Plant__c> relatedPlants= [Select Material__c,id,Plant__c, Availability_Check__c, Profit_Center__c, Purchasing_Group__c, MRP_Controller__c,MRP_Group__c,
                                              Plant_Specific_Matl_Status__c, MRP_Type__c,ABC_Indicator__c, Lot_Size__c, Reorder_Point__c,Carton_Count__c,
                                              Min_Lot_Size__c, Max_Lot_Size__c, Fixed_Lot_Size__c, Max_Stock_Level__c, Rounding_Value__c,Safety_Stock__c,
                                              Special_Procurement__c, Plnd_Dely_time__c, Stor_Loc_EP__c, Schedule_Margin_Key__c, Period_Ind__c,Prod_Storage_Location__c,
                                              Splitting_Ind__c, Bwd_Cons_Period__c, Fwd_Cons_Period__c, GR_Processing_Time__c, Mixed_MRP__c,Consumption_Mode__c,
                                              Indv_Colle__c, Requirements_Grouping__c, Valid_From__c, Procurement_Type__c,Component_Scrap_Percentage__c,Loading_Group__c,
                                              Strategy_Group__c,Coverage_Prof__c From Plant__c where Material__c=:materialId AND Deletion_Flag__c= FALSE];
        
        //List to store the current sales SAP required fields                                      
        List<Sales__c> relatedSales= [Select Material__c,id, Tax_Indicator__c, Operations_Group__c, Tax_Jurisdiction_Code__c, Item_Category_Group__c,Distribution_Channel__c,
                                     Deliver_Plant__c,Original_Release_Date__c,Volume_Rebate_Group__c,Valid_From__c,
                                     D_Chain_Spec__c,Sales_Unit__c,Material_Group_1__c,Material_Group_2__c,Announcement_Date_US__c,
                                     Material_Group_3__c,Material_Group_4__c,Material_Group_5__c,Material_Pricing_Group__c,Solicitation_Date__c,
                                     Material_Statistic_Group__c,PST_Base_GST_CDN__c,GST_Canada__c,Territory__c,PST_Canada__c,City_Sales_Tax__c, County_Sales_Tax__c, Sales_Org__c From Sales__c where Material__c=:materialId AND Deletion_Flag__c= FALSE];
        
      //<BOM_Item__c> relatedBOM = [Select id,Material__c,Component_Quantity__c,Item_Category__c,Valid_From__c,Production_Flag__c from BOM_Item__c Where Material__c =:materialId];  
      
     for(Material__c eachMat : currentMaterial){   
       if(eachMat.Material_Type__c!=null){                             
         /*if((eachMat.Material_Type__c=='FERT' && (eachMat.name!=NULL && eachMat.SGENNO__c!=null && eachMat.Street_Date__c!=NULL && eachMat.Item_Type__c!=NULL && eachMat.Item_Code__c!=NULL && eachMat.General_Item_Category_Group__c!=NULL
                        && eachMat.Format__c!=NULL && eachMat.Technical_Format__c!=NULL && eachMat.Product_Class__c!=NULL && eachMat.Title_Source__c!=NULL && eachMat.Deal_ID__c!=NULL && eachMat.TM_Origin_Code__c!=NULL
                        && eachMat.Label_Code__c!=NULL && eachMat.Sub_Label_Code_Lookup__c!=NULL && eachMat.Cross_Ref_Type__c!=NULL && eachMat.Base_Unit_of_Measure__c!=NULL && eachMat.Material_Group__c!=NULL && eachMat.General_Item_Category_Group__c!=NULL
                        && eachMat.Division__c!=NULL && eachMat.Xplant_Material_Status__c!=NULL && eachMat.Xplant_Valid_From__c!=NULL && eachMat.Gross_Weight__c!=NULL && eachMat.Net_Weight__c!=NULL && eachMat.Weight_Unit__c!=NULL
                        && eachMat.Alternative_Legal_Title_Lookup__c!=NULL && eachMat.Create_Version__c!=NULL && eachMat.X_Dchain_Status__c!=NULL && eachMat.X_Dchain_Valid_From__c!=NULL && eachMat.Purchase_Value_Key__c!=NULL 
                        && eachMat.Transportation_Group__c!=NULL)) 
                    || (eachMat.Material_Type__c!='FERT' && (eachMat.Original_Material_Number__c!=NULL && eachMat.Alternative_Legal_Title_Lookup__c!=NULL && eachMat.Palletized__c!=NULL && eachMat.Sub_Label_Code_Lookup__c!=NULL && eachMat.Title_Source__c!=NULL
                        && eachMat.Selection_Reference_Number__c!=NULL && eachMat.Order_Unit__c!=NULL && eachMat.Financial_Owner__c!=NULL && eachMat.Material_Group__c!=NULL && eachMat.General_Item_Category_Group__c!=NULL&& eachMat.Purchase_Value_Key__c!=NULL
                        && eachMat.Item_Code__c!=NULL && eachMat.Item_Type__c!=NULL && eachMat.Division__c!=NULL && eachMat.Xplant_Material_Status__c!=NULL && eachMat.Gross_Weight__c!=NULL && eachMat.Net_Weight__c!=NULL && eachMat.Weight_Unit__c!=NULL
                        && eachMat.Transportation_Group__c!=NULL && eachMat.X_Dchain_Status__c!=NULL && eachMat.name!=NULL))
           ){*/
         
         //Check material status and all the fields SAP required fields
         if(eachMat.Material_Status__c =='Draft'){      
           
            if(eachMat.Material_Type__c=='FERT'){
                if(eachMat.Street_Date__c ==Null && eachMat.Item_Code__c !=Null && eachMat.Item_Code__c!='BF - BABY FERT'){
                        matFieldName.add('Street Date');
                    }         
                else if(eachMat.Street_Date__c ==Null && eachMat.Item_Code__c ==Null ){
                    matFieldName.add('Street Date');
                }                 
                if(eachMat.Base_Unit_of_Measure__c  ==Null) 
                 matFieldName.add('Base Unit of Measure');
                if(eachMat.Material_Group__c == Null) 
                 matFieldName.add('Material Group');
                if(eachMat.Weight_Unit__c==Null) 
                 matFieldName.add('Weight Unit');
                if(eachMat.Create_Version__c ==Null) 
                 matFieldName.add('Create Version');
                if(eachMat.X_Dchain_Status__c ==Null) 
                 matFieldName.add('X Dchain Status');
                if(eachMat.X_Dchain_Valid_From__c ==Null) 
                 matFieldName.add('X Dchain Valid From');
                if(eachMat.Purchase_Value_Key__c ==Null) 
                 matFieldName.add('Purchase Value Key');
                if(eachMat.Transportation_Group__c  ==Null)
                 matFieldName.add('Transportation Group'); 
                if(eachMat.Plant__c ==Null) 
                 matFieldName.add('Plant');
                if(eachMat.Xplant_Valid_From__c==Null)  
                 matFieldName.add('Xplant Valid From');
                if(eachMat.Name==Null) 
                 matFieldName.add('Material Description');
                if(eachMat.SGENNO_ReadOnly__c ==Null && eachMat.Item_Type__c=='S (Single)')     
                 matFieldName.add('SGENNO');
                if(eachMat.Material_Type__c ==Null)     
                 matFieldName.add('Material Type');
                if(eachMat.Item_Type__c ==Null) 
                 matFieldName.add('Item Type');
                if(eachMat.Item_Code__c ==Null) 
                 matFieldName.add('Item Code');
                if(eachMat.Format__c ==Null) 
                 matFieldName.add('Format');
                if(eachMat.Technical_Format__c  ==Null) 
                 matFieldName.add('Technical Format');
                if(eachMat.Label_Code__c ==Null) 
                 matFieldName.add('Label Code');
                if(eachMat.Sub_Label_Code_Lookup__c==Null)
                 matFieldName.add('Sub-Label Code');    
                //if(eachMat.Cross_Ref_Type__c ==Null) 
                 //matFieldName.add('Cross Ref Type');
                if(eachMat.General_Item_Category_Group__c==Null)    
                 matFieldName.add('General Item Category Group');
                if(eachMat.Division__c  ==Null) 
                 matFieldName.add('Division');
                if(eachMat.Xplant_Material_Status__c==Null)
                 matFieldName.add('Xplant Material Status');     
                if(eachMat.Gross_Weight__c  ==Null) 
                 matFieldName.add('Gross Weight');
                if(eachMat.Net_Weight__c ==Null) 
                 matFieldName.add('Net Weight');
                if(eachMat.Alternative_Legal_Title_Lookup__c ==Null)
                 matFieldName.add('Alternative Legal Title');   
                if(eachMat.Layer__c ==Null && eachMat.Item_Type__c=='S (Single)' && eachMat.Format__c!='08 - EST (ELECTRONIC SELL THRU)' && eachMat.Format__c!='10 - HD HYBRID (DUAL FORMAT) DNU' &&
                   eachMat.Format__c!='13 - HD VOD' && eachMat.Format__c!='14 - HD EST' && eachMat.Format__c!='15 - DVDR' && 
                   eachMat.Format__c!='17 - BD-R' && eachMat.Format__c!='18 - BD-R COMBO PACK' && eachMat.Format__c!='98 - GWP')     
                 matFieldName.add('Layer');
                if(eachMat.Valid_From__c ==Null)
                 matFieldName.add('Valid From');
                //if(eachMat.Release__c==Null) 
                 //matFieldName.add('Release Name');
                if(eachMat.Title__c==Null && eachMat.Item_Type__c=='S (Single)')  
                 matFieldName.add('Title Name'); 
                if(eachMat.TM_Status__c== Null && eachMat.Item_Type__c=='S (Single)') 
                 matFieldName.add('TM Status');  
                if(eachMat.Industry_Sector__c==Null) 
                 matFieldName.add('Industry Sector');  
                if(eachMat.BOM_Usage__c==Null)  
                  matFieldName.add('BOM Usage'); 
                if(eachMat.BOM_Category__c==null) 
                  matFieldName.add('BOM Category'); 
                if((eachMat.Pre_Order_Close_Date__c == Null && eachMat.Item_Code__c !=Null && eachMat.Item_Code__c!='BF - BABY FERT' ) || (eachMat.Pre_Order_Close_Date__c == Null && eachMat.Item_Code__c==Null)){
                  matFieldName.add('Pre Order Close Date');   
                }
                //Releaseforce 2.0 RE-28  Product class is mandatory for submitting Display Vehicle material.
                if(eachMat.Product_Class__c==null && eachMat.Item_Type__c=='D (Display Vehicle)')
                  matFieldName.add('Product Class');  
                /*if(eachMat.Title_Source__c==Null && eachMat.Item_Type__c=='M (Multipack)')
                 matFieldName.add('Title Source');*/ //Cancelled DF-1521
                 if(eachMat.Deal_ID__c ==null  && eachMat.Item_Type__c=='S (Single)' && eachMat.Title__c!= null) //Added for usst-2477
                    matFieldName.add('Deal ID'); //Added for usst-2477
                 if(eachMat.Title_Source__c ==null  && eachMat.Item_Type__c=='S (Single)' && eachMat.Title__c!= null) //Added for usst-2387
                    matFieldName.add('Title Source'); //Added for usst-2387
                 if(eachMat.TM_Version_Lookup__c ==null  && eachMat.Item_Type__c=='S (Single)' && eachMat.Title__c!= null) //Added for usst-2387
                    matFieldName.add('TM Version'); //Added for usst-2387
            }
           if(eachMat.Material_Type__c!='FERT'){
               if(eachMat.Division__c==Null) 
                 matFieldName.add('Division');
                if(eachMat.Xplant_Material_Status__c==Null)
                 matFieldName.add('Xplant Material Status'); 
                if(eachMat.Gross_Weight__c==Null) 
                 matFieldName.add('Gross Weight');
                if(eachMat.Net_Weight__c==Null) 
                 matFieldName.add('Net Weight');
                if(eachMat.Weight_Unit__c==Null) 
                 matFieldName.add('Weight Unit');
                if(eachMat.Transportation_Group__c ==Null)
                 matFieldName.add('Transportation Group');
               if(eachMat.Industry_Sector__c==Null) 
                 matFieldName.add('Industry Sector');  
               if(eachMat.Material_Group__c == Null) 
                 matFieldName.add('Material Group');
               if(eachMat.General_Item_Category_Group__c==Null)    
                 matFieldName.add('General Item Category Group');
               if(eachMat.Item_Type__c ==Null) 
                 matFieldName.add('Item Type');
               if(eachMat.Item_Code__c ==Null) 
                 matFieldName.add('Item Code');  
                  
                                                                                                  
           }     
         }   
         else if (eachMat.Material_Status__c == 'Submitted') {
           
             if(eachMat.Material_Type__c=='FERT'){
              if((eachMat.Street_Date__c ==Null && eachMat.Item_Code__c !=Null && eachMat.Item_Code__c!='BF - BABY FERT') || (eachMat.Street_Date__c ==Null && eachMat.Item_Code__c ==Null)){ 
                  matFieldName.add('Street Date');
               }  
                if(eachMat.Base_Unit_of_Measure__c  ==Null) 
                 matFieldName.add('Base Unit of Measure');
                if(eachMat.Material_Group__c ==Null) 
                 matFieldName.add('Material Group');
                if(eachMat.Weight_Unit__c==Null) 
                 matFieldName.add('Weight Unit');
                if(eachMat.Create_Version__c ==Null) 
                 matFieldName.add('Create Version');
                if(eachMat.X_Dchain_Status__c ==Null) 
                 matFieldName.add('X Dchain Status');
                if(eachMat.X_Dchain_Valid_From__c ==Null) 
                 matFieldName.add('X Dchain Valid From');
                if(eachMat.Purchase_Value_Key__c ==Null) 
                 matFieldName.add('Purchase Value Key');
                if(eachMat.Transportation_Group__c  ==Null)
                 matFieldName.add('Transportation Group'); 
                if(eachMat.Plant__c ==Null) 
                 matFieldName.add('Plant');
                if(eachMat.Xplant_Valid_From__c==Null)  
                 matFieldName.add('Xplant Valid From');
                if(eachMat.Name==Null) 
                 matFieldName.add('Material Description');
                if(eachMat.SGENNO_ReadOnly__c ==Null && eachMat.Item_Type__c=='S (Single)')     
                 matFieldName.add('SGENNO');
                if(eachMat.Material_Type__c ==Null)     
                 matFieldName.add('Material Type');
                if(eachMat.Item_Type__c ==Null) 
                 matFieldName.add('Item Type');
                if(eachMat.Item_Code__c ==Null) 
                 matFieldName.add('Item Code');
                if(eachMat.Format__c ==Null) 
                 matFieldName.add('Format');
                if(eachMat.Technical_Format__c  ==Null) 
                 matFieldName.add('Technical Format');
                if(eachMat.Label_Code__c ==Null) 
                 matFieldName.add('Label Code');
                if(eachMat.Sub_Label_Code_Lookup__c==Null)
                 matFieldName.add('Sub-Label Code');    
               // if(eachMat.Cross_Ref_Type__c ==Null) 
                 //matFieldName.add('Cross Ref Type');
                if(eachMat.General_Item_Category_Group__c==Null)    
                 matFieldName.add('General Item Category Group');
                if(eachMat.Division__c  ==Null) 
                 matFieldName.add('Division');
                if(eachMat.Xplant_Material_Status__c==Null)
                 matFieldName.add('Xplant Material Status');     
                if(eachMat.Gross_Weight__c  ==Null) 
                 matFieldName.add('Gross Weight');
                if(eachMat.Net_Weight__c ==Null) 
                 matFieldName.add('Net Weight');
                if(eachMat.Alternative_Legal_Title_Lookup__c ==Null)
                 matFieldName.add('Alternative Legal Title');   
                if(eachMat.Layer__c ==Null && eachMat.Item_Type__c=='S (Single)' && eachMat.Format__c!='08 - EST (ELECTRONIC SELL THRU)' && eachMat.Format__c!='10 - HD HYBRID (DUAL FORMAT) DNU' &&
                   eachMat.Format__c!='13 - HD VOD' && eachMat.Format__c!='14 - HD EST' && eachMat.Format__c!='15 - DVDR' && 
                   eachMat.Format__c!='17 - BD-R' && eachMat.Format__c!='18 - BD-R COMBO PACK' && eachMat.Format__c!='98 - GWP')     
                 matFieldName.add('Layer');
                if(eachMat.Valid_From__c ==Null)
                 matFieldName.add('Valid From');
                //if(eachMat.Release__c==Null) 
                 //matFieldName.add('Release Name');
                if(eachMat.Title__c==Null && eachMat.Item_Type__c=='S (Single)')  
                 matFieldName.add('Title Name');
                if(eachMat.Product_Class__c==Null)  
                 matFieldName.add('Product Class');
                if(eachMat.Title_Source__c ==Null && eachMat.Item_Type__c=='S (Single)' && eachMat.Title__c!= null)  //Added for usst-2387
                 matFieldName.add('Title Source'); //Added for usst-2387
                if(eachMat.Item_Type__c == 'S (Single)' && eachMat.Title__c!= null && eachMat.TM_Version_Lookup__c == Null)  //Added for usst-2387
                  matFieldName.add('TM Version'); //Added for usst-2387
                //if(eachMat.Deal_ID__c ==Null  && eachMat.Item_Type__c=='S (Single)')  //commented for usst-2477 
                 //matFieldName.add('Deal ID'); //commented for usst-2477
                if(eachMat.TM_Status__c== Null && eachMat.Item_Type__c=='S (Single)') 
                 matFieldName.add('TM Status'); 
                if(eachMat.Industry_Sector__c==Null) 
                 matFieldName.add('Industry Sector'); 
                if(eachMat.BOM_Usage__c==Null)  
                  matFieldName.add('BOM Usage');  
                if(eachMat.BOM_Category__c==null) 
                  matFieldName.add('BOM Category'); 
                if((eachMat.Pre_Order_Close_Date__c == Null && eachMat.Item_Code__c !=Null && eachMat.Item_Code__c!='BF - BABY FERT')||(eachMat.Pre_Order_Close_Date__c == Null && eachMat.Item_Code__c ==Null))
                  matFieldName.add('Pre Order Close Date');   
            }
           if(eachMat.Material_Type__c!='FERT'){
               if(eachMat.name==NULL)
                  matFieldName.add('Material Description');
               if(eachMat.Division__c==Null) 
                 matFieldName.add('Division');
                if(eachMat.Xplant_Material_Status__c==Null)
                 matFieldName.add('Xplant Material Status'); 
                if(eachMat.Gross_Weight__c==Null) 
                 matFieldName.add('Gross Weight');
                if(eachMat.Net_Weight__c==Null) 
                 matFieldName.add('Net Weight');
                if(eachMat.Weight_Unit__c==Null) 
                 matFieldName.add('Weight Unit');
                if(eachMat.Transportation_Group__c ==Null)
                 matFieldName.add('Transportation Group');
                if(eachMat.Industry_Sector__c==Null) 
                 matFieldName.add('Industry Sector'); 
               if(eachMat.Material_Group__c == Null) 
                 matFieldName.add('Material Group');
               if(eachMat.General_Item_Category_Group__c==Null)    
                 matFieldName.add('General Item Category Group');
               if(eachMat.Item_Type__c ==Null) 
                 matFieldName.add('Item Type');
               if(eachMat.Item_Code__c ==Null) 
                 matFieldName.add('Item Code');                                                                                
             }  
         
         }   
         
         /*if(relatedBOM.Size()>0){
             for(BOM_Item__c eachBOM: relatedBOM){
                          if(eachMat.Id == eachBOM.Material__c){
                           if((eachMat.Material_Status__c == 'Draft' || eachMat.Material_Status__c == 'Submitted') && eachMat.Material_Type__c=='FERT'){
                            
                             if(eachBOM.Component_Quantity__c == Null)
                                bomFieldName.add('Component Quantity');
                             if(eachBOM.Item_Category__c == Null)
                                bomFieldName.add('Item Category');
                             if(eachBOM.Valid_From__c == Null)
                                bomFieldName.add('Valid From');
                             if(eachBOM.Production_Flag__c == False)
                                bomFieldName.add('Production Relevancy ') ;
                              
                           }
                          }
                       }    
                }*/
         
          
              if(relatedValuations.size()>0){
                     for(Valuation__c eachValuation: relatedValuations ){
                          if(eachMat.Id == eachValuation.Material__c){
                           if(eachMat.Material_Status__c == 'Draft'){
                             if(eachValuation.Valuation_Area__c==NULL)
                               valuationFieldName.add('Valuation Area');
                             if(eachValuation.Valuation_Class__c==NULL)
                               valuationFieldName.add('Valuation Class');
                             if(eachValuation.Price_Unit__c==NULL )
                               valuationFieldName.add('Price Unit');
                             if(eachValuation.Standard_Price__c==NULL )
                               valuationFieldName.add('Standard Price'); 
                             if(eachValuation.Origin_Group__c==NULL && eachMat.Material_type__c!='Z009')
                               valuationFieldName.add('Origin Group');
                             if(eachValuation.Pricing_Control__c  ==NULL )
                               valuationFieldName.add('Pricing Control');  
                             
                            }
                          else if(eachMat.Material_Status__c == 'Submitted'){
                             if(eachValuation.Valuation_Area__c==NULL)
                               valuationFieldName.add('Valuation Area');
                             if(eachValuation.Valuation_Class__c==NULL)
                               valuationFieldName.add('Valuation Class');
                             if(eachValuation.Price_Unit__c==NULL )
                               valuationFieldName.add('Price Unit');
                             if(eachValuation.Standard_Price__c==NULL )
                               valuationFieldName.add('Standard Price'); 
                             if(eachValuation.Origin_Group__c==NULL && eachMat.Material_type__c!='Z009')
                               valuationFieldName.add('Origin Group');
                             if(eachValuation.Pricing_Control__c  ==NULL )
                               valuationFieldName.add('Pricing Control');  
                            }    
                         }                
                      
                     }
                 }
                 //Added for DF-02216
                 else
                 {
                     if(currentMaterial != null && currentMaterial.size() > 0 && currentMaterial[0].Material_Type__c != 'Z009')
                     {
                         valuationFieldName.add('No Valuation present');
                     }
                     
                 }
             if(relatedClassifications.size()>0){
             for(Classification__c eachClassification : relatedClassifications){
                  if(eachMat.Id == eachClassification.Material__c){
                    if((eachMat.Material_Status__c == 'Draft' || eachMat.Material_Status__c == 'Submitted') && eachMat.Material_Type__c=='FERT'){
                     // if(eachClassification.Label_Code__c==NULL && eachClassification.RecordTypeId == universalFinishedGoodRecordTypeId)
                          // classificationFieldName.add('Label Code-Record Type:'+eachClassification.RecordType.Name); 
                       System.debug('###Classification Data Outside'+eachClassification.Packaging_Type_US__c+' '+eachClassification.RecordTypeId+' '+eachMat.Material_Type__c);    
                      /*if(eachClassification.Packaging_Type_US__c==NULL && eachClassification.RecordTypeId == universalFinishedGoodRecordTypeId && eachMat.Material_Type__c=='FERT'){
                           System.debug('###Classification Data'+eachClassification.Packaging_Type_US__c+' '+eachClassification.RecordTypeId+' '+eachMat.Material_Type__c);   
                           classificationFieldName.add('Packaging Type US-Record Type:'+eachClassification.RecordType.Name);
                      }*/     
                      //if(eachClassification.Aspect_Ratio__c==null)  
                         //classificationFieldName.add('Aspect Ratio'); 
                         
                     // if(eachClassification.Genre_US__c ==NULL && eachClassification.RecordTypeId == generalRecordTypeId && eachMat.Material_Type__c=='FERT')
                        // classificationFieldName.add('Genre US-Record Type:'+eachClassification.RecordType.Name);
                      
                      }
                   /*  else if(eachMat.Material_Status__c == 'Submitted'){ 
                       if(eachClassification.Packaging_Type_US__c==NULL && eachClassification.RecordTypeId == universalFinishedGoodRecordTypeId)
                           classificationFieldName.add('Packaging Type US-Record Type:'+eachClassification.RecordType.Name);
                       //if(eachClassification.Regie_Sticker_for_Canada__c==NULL && eachClassification.RecordTypeId == universalFinishedGoodRecordTypeId)
                          // classificationFieldName.add('Regie Sticker for Canada-Record Type:'+eachClassification.RecordType.Name); 
                      if(eachClassification.Label_Code__c==NULL && eachClassification.RecordTypeId == universalFinishedGoodRecordTypeId)
                           classificationFieldName.add('Label Code-Record Type:'+eachClassification.RecordType.Name); 
                      }*/
                     }         
                    
                }
             }
             
            if(relatedPlants.size()>0){
             for(Plant__c eachPlant: relatedPlants){
              if(eachMat.Id == eachPlant.Material__c){
                 if(eachMat.Material_Status__c == 'Draft'){
                      if(eachMat.Material_Type__c=='FERT'){
                       if(eachPlant.Valid_From__c == Null)
                         plantFieldName.add('Valid From');
                        if(eachPlant.Plant__c== Null)
                         plantFieldName.add('Plant');
                        if(eachPlant.Availability_Check__c == Null)
                         plantFieldName.add('Availability Check');
                        if(eachPlant.MRP_Type__c == Null)
                         plantFieldName.add('MRP Type');
                        if(eachPlant.ABC_Indicator__c == Null)
                         plantFieldName.add('ABC Indicator');
                        if(eachPlant.Lot_Size__c == Null)
                         plantFieldName.add('Lot Size');
                       // if(eachPlant.Reorder_Point__c == Null)
                        // plantFieldName.add('Reorder Point');
                        if(eachPlant.Max_Lot_Size__c == Null)
                         plantFieldName.add('Max Lot Size');
                       // if(eachPlant.Fixed_Lot_Size__c == Null)
                        // plantFieldName.add('Fixed Lot Size');
                        if(eachPlant.Max_Stock_Level__c == Null)
                         plantFieldName.add('Max Stock Level');
                        if(eachPlant.Special_Procurement__c == Null)
                         plantFieldName.add('Special Procurement');
                        if(eachPlant.Schedule_Margin_Key__c == Null)
                         plantFieldName.add('Schedule Margin Key');
                        if(eachPlant.Period_Ind__c == Null)
                         plantFieldName.add('Period Ind');
                        if(eachPlant.Fwd_Cons_Period__c == Null)
                         plantFieldName.add('Fwd Cons Period');
                        if(eachPlant.GR_Processing_Time__c == Null)
                         plantFieldName.add('GR Processing Time');
                        if(eachPlant.Mixed_MRP__c == Null)
                         plantFieldName.add('Mixed MRP');
                        if(eachPlant.Requirements_Grouping__c == Null)
                         plantFieldName.add('Requirements Grouping');
                        if(eachPlant.Profit_Center__c == Null)
                         plantFieldName.add('Profit Center');
                        if(eachPlant.Purchasing_Group__c == Null)
                         plantFieldName.add('Purchasing Group');
                        if(eachPlant.MRP_Controller__c == Null)
                         plantFieldName.add('MRP Controller');
                        if(eachPlant.Min_Lot_Size__c  == Null)
                         plantFieldName.add('Min Lot Size');
                        if(eachPlant.Rounding_Value__c == Null)
                         plantFieldName.add('Rounding Value');
                        if(eachPlant.Plnd_Dely_time__c == Null)
                         plantFieldName.add('Planned Delivery Time (Days)');
                        if(eachPlant.Stor_Loc_EP__c == Null)
                         plantFieldName.add('Stor Loc EP');
                        if(eachPlant.Splitting_Ind__c == Null)
                         plantFieldName.add('Splitting Ind');
                        if(eachPlant.Bwd_Cons_Period__c == Null)
                         plantFieldName.add('Bwd Cons Period');
                        if(eachPlant.Indv_Colle__c == Null)
                         plantFieldName.add('Indv Colle');
                        if(eachPlant.Consumption_Mode__c== Null)
                         plantFieldName.add('Consumption Mode');
                        //if(eachPlant.Carton_Count__c== Null || eachPlant.Carton_Count__c ==0)
                         //plantFieldName.add('Carton Count'); 
                        if(eachPlant.Procurement_Type__c==Null)   
                          plantFieldName.add('Procurement Type');   
                         
                      }
                      if( eachMat.Material_Type__c!='FERT'){
                         if(eachPlant.Safety_Stock__c == Null)
                          plantFieldName.add('Safety Stock');
                        if(eachPlant.Valid_From__c == Null)
                         plantFieldName.add('Valid From');
                        if(eachPlant.MRP_Controller__c == Null)
                         plantFieldName.add('MRP Controller');
                        if(eachPlant.Purchasing_Group__c == Null)
                         plantFieldName.add('Purchasing Group');
                        if(eachPlant.Plant_Specific_Matl_Status__c == Null)
                         plantFieldName.add('Plant Specific Matl Status');
                        if(eachPlant.MRP_Type__c == Null)
                         plantFieldName.add('MRP Type');
                       // if(eachPlant.Reorder_Point__c == Null)
                         //plantFieldName.add('Reorder Point');
                        if(eachPlant.Max_Lot_Size__c == Null)
                         plantFieldName.add('Max Lot Size');
                        //if(eachPlant.Fixed_Lot_Size__c == Null)
                        // plantFieldName.add('Fixed Lot Size');
                        if(eachPlant.Max_Stock_Level__c == Null)
                         plantFieldName.add('Max Stock Level');
                        if(eachPlant.Stor_Loc_EP__c == Null)
                         plantFieldName.add('Stor Loc EP');
                        if(eachPlant.Schedule_Margin_Key__c == Null)
                         plantFieldName.add('Schedule Margin Key');
                        if(eachPlant.Period_Ind__c == Null)
                         plantFieldName.add('Period Ind');
                        if(eachPlant.Bwd_Cons_Period__c == Null)
                         plantFieldName.add('Bwd Cons Period');
                        if(eachPlant.Fwd_Cons_Period__c == Null)
                         plantFieldName.add('Fwd Cons Period');
                        if(eachPlant.GR_Processing_Time__c == Null)
                         plantFieldName.add('GR Processing Time');
                        if(eachPlant.Mixed_MRP__c == Null)
                         plantFieldName.add('Mixed MRP');
                        if(eachPlant.Requirements_Grouping__c == Null)
                         plantFieldName.add('Requirements Grouping');
                        if(eachPlant.Plant__c == Null)
                         plantFieldName.add('Plant');
                        if(eachPlant.Min_Lot_Size__c == Null)
                         plantFieldName.add('Min Lot Size');
                        if(eachPlant.Plnd_Dely_time__c == Null)
                         plantFieldName.add('Planned Delivery Time (Days)');
                        if(eachPlant.Component_Scrap_Percentage__c == Null)
                         plantFieldName.add('Component Scrap Percentage');
                        if(eachPlant.Lot_Size__c == Null)
                         plantFieldName.add('Lot Size');
                        if(eachPlant.Rounding_Value__c == Null)
                         plantFieldName.add('Rounding Value');
                        if(eachPlant.Availability_Check__c == Null)
                         plantFieldName.add('Availability Check');
                        if(eachPlant.Splitting_Ind__c == Null && eachMat.Material_type__c!='Z009')
                         plantFieldName.add('Splitting Ind');
                        if(eachPlant.Profit_Center__c == Null)
                         plantFieldName.add('Profit Center');
                        if(eachPlant.Procurement_Type__c==Null)   
                          plantFieldName.add('Procurement Type');  
                      }      
                    }
                  else if(eachMat.Material_Status__c == 'Submitted'){
                    if(eachMat.Material_Type__c=='FERT'){
                       if(eachPlant.Valid_From__c == Null)
                         plantFieldName.add('Valid From');
                        if(eachPlant.Plant__c== Null)
                         plantFieldName.add('Plant');
                        if(eachPlant.Availability_Check__c == Null)
                         plantFieldName.add('Availability Check');
                        if(eachPlant.MRP_Type__c == Null)
                         plantFieldName.add('MRP Type');
                        if(eachPlant.ABC_Indicator__c == Null)
                         plantFieldName.add('ABC Indicator');
                        if(eachPlant.Lot_Size__c == Null)
                         plantFieldName.add('Lot Size');
                        //if(eachPlant.Reorder_Point__c == Null)
                        // plantFieldName.add('Reorder Point');
                        if(eachPlant.Max_Lot_Size__c == Null)
                         plantFieldName.add('Max Lot Size');
                        //if(eachPlant.Fixed_Lot_Size__c == Null)
                        // plantFieldName.add('Fixed Lot Size');
                        if(eachPlant.Max_Stock_Level__c == Null)
                         plantFieldName.add('Max Stock Level');
                        if(eachPlant.Special_Procurement__c == Null)
                         plantFieldName.add('Special Procurement');
                        if(eachPlant.Schedule_Margin_Key__c == Null)
                         plantFieldName.add('Schedule Margin Key');
                        if(eachPlant.Period_Ind__c == Null)
                         plantFieldName.add('Period Ind');
                        if(eachPlant.Fwd_Cons_Period__c == Null)
                         plantFieldName.add('Fwd Cons Period');
                        if(eachPlant.GR_Processing_Time__c == Null)
                         plantFieldName.add('GR Processing Time');
                        if(eachPlant.Mixed_MRP__c == Null)
                         plantFieldName.add('Mixed MRP');
                        if(eachPlant.Requirements_Grouping__c == Null)
                         plantFieldName.add('Requirements Grouping');
                        if(eachPlant.Profit_Center__c == Null)
                         plantFieldName.add('Profit Center');
                        if(eachPlant.Purchasing_Group__c == Null)
                         plantFieldName.add('Purchasing Group');
                        if(eachPlant.MRP_Controller__c == Null)
                         plantFieldName.add('MRP Controller');
                        if(eachPlant.Min_Lot_Size__c  == Null)
                         plantFieldName.add('Min Lot Size');
                        if(eachPlant.Rounding_Value__c == Null)
                         plantFieldName.add('Rounding Value');
                        if(eachPlant.Plnd_Dely_time__c == Null)
                         plantFieldName.add('Planned Delivery Time (Days)');
                        if(eachPlant.Stor_Loc_EP__c == Null)
                         plantFieldName.add('Stor Loc EP');
                        if(eachPlant.Splitting_Ind__c == Null)
                         plantFieldName.add('Splitting Ind');
                        if(eachPlant.Bwd_Cons_Period__c == Null)
                         plantFieldName.add('Bwd Cons Period');
                        if(eachPlant.Indv_Colle__c == Null)
                         plantFieldName.add('Indv Colle');
                        if(eachPlant.Consumption_Mode__c== Null)
                         plantFieldName.add('Consumption Mode');
                       // if(eachPlant.Carton_Count__c== Null)
                        // plantFieldName.add('Carton Count');  
                       if(eachPlant.Procurement_Type__c==Null)   
                          plantFieldName.add('Procurement Type');   
                         
                      }
                      if( eachMat.Material_Type__c!='FERT'){
                         if(eachPlant.Safety_Stock__c == Null)
                          plantFieldName.add('Safety Stock');
                        if(eachPlant.Valid_From__c == Null)
                         plantFieldName.add('Valid From');
                        if(eachPlant.MRP_Controller__c == Null)
                         plantFieldName.add('MRP Controller');
                        if(eachPlant.Purchasing_Group__c == Null)
                         plantFieldName.add('Purchasing Group');
                        if(eachPlant.Plant_Specific_Matl_Status__c == Null)
                         plantFieldName.add('Plant Specific Matl Status');
                        if(eachPlant.MRP_Type__c == Null)
                         plantFieldName.add('MRP Type');
                        //if(eachPlant.Reorder_Point__c == Null)
                        // plantFieldName.add('Reorder Point');
                        if(eachPlant.Max_Lot_Size__c == Null)
                         plantFieldName.add('Max Lot Size');
                        //if(eachPlant.Fixed_Lot_Size__c == Null)
                        // plantFieldName.add('Fixed Lot Size');
                        if(eachPlant.Max_Stock_Level__c == Null)
                         plantFieldName.add('Max Stock Level');
                        if(eachPlant.Stor_Loc_EP__c == Null)
                         plantFieldName.add('Stor Loc EP');
                        if(eachPlant.Schedule_Margin_Key__c == Null)
                         plantFieldName.add('Schedule Margin Key');
                        if(eachPlant.Period_Ind__c == Null)
                         plantFieldName.add('Period Ind');
                        if(eachPlant.Bwd_Cons_Period__c == Null)
                         plantFieldName.add('Bwd Cons Period');
                        if(eachPlant.Fwd_Cons_Period__c == Null)
                         plantFieldName.add('Fwd Cons Period');
                        if(eachPlant.GR_Processing_Time__c == Null)
                         plantFieldName.add('GR Processing Time');
                        if(eachPlant.Mixed_MRP__c == Null)
                         plantFieldName.add('Mixed MRP');
                        if(eachPlant.Requirements_Grouping__c == Null)
                         plantFieldName.add('Requirements Grouping');
                        if(eachPlant.Plant__c == Null)
                         plantFieldName.add('Plant');
                        if(eachPlant.Min_Lot_Size__c == Null)
                         plantFieldName.add('Min Lot Size');
                        if(eachPlant.Plnd_Dely_time__c == Null)
                         plantFieldName.add('Planned Delivery Time (Days)');
                        if(eachPlant.Component_Scrap_Percentage__c == Null)
                         plantFieldName.add('Component Scrap Percentage');
                        if(eachPlant.Lot_Size__c == Null)
                         plantFieldName.add('Lot Size');
                        if(eachPlant.Rounding_Value__c == Null)
                         plantFieldName.add('Rounding Value');
                        if(eachPlant.Availability_Check__c == Null)
                         plantFieldName.add('Availability Check');
                        if(eachPlant.Splitting_Ind__c == Null && eachMat.Material_type__c!='Z009')
                         plantFieldName.add('Splitting Ind');
                        if(eachPlant.Profit_Center__c == Null)
                         plantFieldName.add('Profit Center');
                       if(eachPlant.Procurement_Type__c==Null)   
                          plantFieldName.add('Procurement Type');  
                      }                                                                
                  }   
                }
             }
            } 
             if(relatedSales.size()>0){
             for(Sales__c eachSales : relatedSales){
             // if(eachMat.Id == eachSales.Material__c){
                   if(eachMat.Material_Status__c == 'Draft'){
                     if(eachMat.Material_Type__c=='FERT'){
                       //if(eachSales.Pre_Order_Date__c == Null)
                         //SaleFieldName.add('Pre Order Date');
                       // if((eachSales.Material_Group_2__c ==Null && eachSales.Territory__c == 'CDN'))
                        // SaleFieldName.add('Material Group 2');
                        if(eachSales.Distribution_Channel__c == Null)
                         SaleFieldName.add('Distribution Channel');
                        if(eachSales.Deliver_Plant__c == Null)
                         SaleFieldName.add('Delivering Plant');
                        if(eachSales.Tax_Jurisdiction_Code__c == Null && eachSales.Territory__c=='US')
                         SaleFieldName.add('Tax Jurisdiction Code');
                        if(eachSales.County_Sales_Tax__c == Null && eachSales.Territory__c=='US')
                         SaleFieldName.add('County Sales Tax');
                        if(eachSales.City_Sales_Tax__c == Null && eachSales.Territory__c=='US')
                         SaleFieldName.add('City Sales Tax');
                        if(eachSales.Tax_Indicator__c == Null)
                         SaleFieldName.add('Tax Indicator');
                        if(eachSales.Item_Category_Group__c == Null)
                         SaleFieldName.add('Item Category Group');
                        if(eachSales.Sales_Org__c == Null)
                         SaleFieldName.add('Sales Org');
                        if(eachSales.D_Chain_Spec__c == Null)
                         SaleFieldName.add('D Chain Spec');
                        if(eachSales.Valid_From__c == Null)
                         SaleFieldName.add('Valid From');
                        //if(eachSales.Volume_Rebate_Group__c == Null)
                         //SaleFieldName.add('Volume Rebate Group');
                        /*if(eachSales.Material_Pricing_Group__c == Null)
                         SaleFieldName.add('Material Pricing Group');*/
                        if(eachSales.Operations_Group__c == null)
                          SaleFieldName.add('Operations Group');
                        if(eachSales.Material_Group_3__c == Null)
                        SaleFieldName.add('Material Group 3');
                        if(eachSales.Material_Group_5__c == Null) 
                         SaleFieldName.add('Material Group 5');
                        if(eachSales.GST_Canada__c == Null && eachSales.Territory__c=='CDN')
                         SaleFieldName.add('GST (Canada)');
                        if(eachSales.PST_Canada__c == Null && eachSales.Territory__c=='CDN')
                         SaleFieldName.add('PST (Canada)');
                        if(eachSales.PST_Base_GST_CDN__c == Null && eachSales.Territory__c=='CDN')
                         SaleFieldName.add('PST (Base+GST) CDN');   
                        if(eachSales.Material_Statistic_Group__c==Null)
                          SaleFieldName.add('Material Statistic Group');
                       }
                     if(eachMat.Material_Type__c!='FERT'){
                         if(eachSales.Distribution_Channel__c == Null)
                             SaleFieldName.add('Distribution Channel');
                            if(eachSales.D_Chain_Spec__c == Null)
                             SaleFieldName.add('D Chain Spec');
                            if(eachSales.Operations_Group__c == Null)
                             SaleFieldName.add('Operations Group');
                            if(eachSales.Tax_Jurisdiction_Code__c == Null && eachSales.Territory__c=='US')
                             SaleFieldName.add('Tax Jurisdiction Code');
                            if(eachSales.County_Sales_Tax__c == Null && eachSales.Territory__c=='US')
                             SaleFieldName.add('County Sales Tax');
                            if(eachSales.City_Sales_Tax__c == Null && eachSales.Territory__c=='US')
                             SaleFieldName.add('City Sales Tax');
                            if(eachSales.Sales_Org__c == Null)
                             SaleFieldName.add('Sales Org');
                            if(eachSales.Tax_Indicator__c == Null)
                             SaleFieldName.add('Tax Indicator');
                            if(eachSales.GST_Canada__c == Null && eachSales.Territory__c=='CDN')
                             SaleFieldName.add('GST (Canada)');
                            if(eachSales.PST_Canada__c == Null && eachSales.Territory__c=='CDN')
                             SaleFieldName.add('PST (Canada)');
                            if(eachSales.PST_Base_GST_CDN__c == Null && eachSales.Territory__c=='CDN')
                             SaleFieldName.add('PST (Base+GST) CDN');
                           if(eachSales.Material_Statistic_Group__c==Null)
                            SaleFieldName.add('Material Statistic Group'); 
                           if(eachSales.Item_Category_Group__c == Null)
                            SaleFieldName.add('Item Category Group');   
                     }  
                    }
                   else if(eachMat.Material_Status__c == 'Submitted'){
                     if(eachMat.Material_Type__c=='FERT'){
                     
                      //if(eachSales.Pre_Order_Date__c == Null)
                         //SaleFieldName.add('Pre Order Date');
                       // if((eachSales.Material_Group_2__c ==Null && eachSales.Territory__c == 'CDN'))
                        // SaleFieldName.add('Material Group 2');
                        if(eachSales.Distribution_Channel__c == Null)
                         SaleFieldName.add('Distribution Channel');
                        if(eachSales.Deliver_Plant__c == Null)
                         SaleFieldName.add('Delivering Plant');
                        if(eachSales.Tax_Jurisdiction_Code__c == Null && eachSales.Territory__c=='US')
                         SaleFieldName.add('Tax Jurisdiction Code');
                        if(eachSales.County_Sales_Tax__c == Null && eachSales.Territory__c=='US')
                         SaleFieldName.add('County Sales Tax');
                        if(eachSales.City_Sales_Tax__c == Null && eachSales.Territory__c=='US')
                         SaleFieldName.add('City Sales Tax');
                        if(eachSales.Tax_Indicator__c == Null)
                         SaleFieldName.add('Tax Indicator');
                        if(eachSales.Item_Category_Group__c == Null)
                         SaleFieldName.add('Item Category Group');
                        if(eachSales.Sales_Org__c == Null)
                         SaleFieldName.add('Sales Org');
                        if(eachSales.D_Chain_Spec__c == Null)
                         SaleFieldName.add('D Chain Spec');
                        if(eachSales.Valid_From__c == Null)
                         SaleFieldName.add('Valid From');
                        //if(eachSales.Volume_Rebate_Group__c == Null)
                         //SaleFieldName.add('Volume Rebate Group');
                        if(eachSales.Material_Pricing_Group__c == Null)
                         SaleFieldName.add('Material Pricing Group');
                        if(eachSales.Operations_Group__c == Null)
                          SaleFieldName.add('Operations Group');
                        if(eachSales.Material_Group_3__c == Null)
                        SaleFieldName.add('Material Group 3');
                        if(eachSales.Material_Group_5__c == Null) 
                         SaleFieldName.add('Material Group 5');
                        if(eachSales.GST_Canada__c == Null && eachSales.Territory__c=='CDN')
                         SaleFieldName.add('GST (Canada)');
                        if(eachSales.PST_Canada__c == Null && eachSales.Territory__c=='CDN')
                         SaleFieldName.add('PST (Canada)');
                        if(eachSales.PST_Base_GST_CDN__c == Null && eachSales.Territory__c=='CDN')
                         SaleFieldName.add('PST (Base+GST) CDN');
                        if(eachSales.Material_Statistic_Group__c==Null)
                          SaleFieldName.add('Material Statistic Group');
                     }
                     if(eachMat.Material_Type__c!='FERT'){
                       if(eachSales.Distribution_Channel__c == Null)
                         SaleFieldName.add('Distribution Channel');
                        if(eachSales.D_Chain_Spec__c == Null)
                         SaleFieldName.add('D Chain Spec');
                        if(eachSales.Operations_Group__c == Null)
                         SaleFieldName.add('Operations Group');
                        if(eachSales.Tax_Jurisdiction_Code__c == Null && eachSales.Territory__c=='US')
                         SaleFieldName.add('Tax Jurisdiction Code');
                        if(eachSales.County_Sales_Tax__c == Null && eachSales.Territory__c=='US')
                         SaleFieldName.add('County Sales Tax');
                        if(eachSales.City_Sales_Tax__c == Null && eachSales.Territory__c=='US')
                         SaleFieldName.add('City Sales Tax');
                        if(eachSales.Sales_Org__c == Null)
                         SaleFieldName.add('Sales Org');
                        if(eachSales.Tax_Indicator__c == Null)
                         SaleFieldName.add('Tax Indicator');
                        if(eachSales.GST_Canada__c == Null && eachSales.Territory__c=='CDN')
                         SaleFieldName.add('GST (Canada)');
                        if(eachSales.PST_Canada__c == Null && eachSales.Territory__c=='CDN')
                         SaleFieldName.add('PST (Canada)');
                        if(eachSales.PST_Base_GST_CDN__c == Null && eachSales.Territory__c=='CDN')
                         SaleFieldName.add('PST (Base+GST) CDN');
                       if(eachSales.Material_Statistic_Group__c==Null)
                          SaleFieldName.add('Material Statistic Group');  
                       if(eachSales.Item_Category_Group__c == Null)
                            SaleFieldName.add('Item Category Group');   
                     } 
                    }
                }
            }
        }
    }
 }
}