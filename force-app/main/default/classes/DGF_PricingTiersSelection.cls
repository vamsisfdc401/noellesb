/***********************************************************************************
Class Name: DGF_PricingTiersSelection
Purpose: Creating pricing records automatically when choosing Pricing Tier in grid.
******************************************************************************************
Version         DateModified         ModifiedBy               Change
1.0             11/10/2018          Naga                  Initial Development 
 
******************************************************************************************/
public class DGF_PricingTiersSelection {
	//wrapper class
    public class PTierRecords {
        
        @AuraEnabled public boolean isSelected;
        @AuraEnabled public boolean isCreated;
        @AuraEnabled public boolean isProductsExists;
        @AuraEnabled public string ptName;        
        @AuraEnabled public string ptType;
        @AuraEnabled public string ptId;
        @AuraEnabled public string ptCategopy;
        @AuraEnabled public string ptSubCategopy;
        @AuraEnabled public string ptPlatform;
        
        @AuraEnabled public string uSSDWSP;
		@AuraEnabled public string uSSDSRP;
		@AuraEnabled public string uSHDWSP;
		@AuraEnabled public string uSHDSRP;
		@AuraEnabled public string uSUHDWSP;
		@AuraEnabled public string uSUHDSRP;
        
        @AuraEnabled public string cASDWSP;
		@AuraEnabled public string cASDSRP;
		@AuraEnabled public string cAHDWSP;
		@AuraEnabled public string cAHDSRP;
		@AuraEnabled public string cAUHDWSP;
		@AuraEnabled public string cAUHDSRP;
        @AuraEnabled public string noOfTitles;
        //wrapper class constructor
        public PTierRecords(){
            isSelected = false;
            isCreated = false;
            isProductsExists = false;
            ptName = '';             
            ptType = '';
            ptCategopy = '';
            ptSubCategopy = '';
            ptPlatform = '';
            ptId = '';
            noOfTitles = '';
            
            uSSDWSP = '';
			uSSDSRP = '';
			uSHDWSP = '';
			uSHDSRP = '';
			uSUHDWSP = '';
			uSUHDSRP = '';
            cASDWSP = '';
			cASDSRP = '';
			cAHDWSP = '';
			cAHDSRP = '';
			cAUHDWSP = '';
			cAUHDSRP = '';
        }
    }
    @AuraEnabled
    public static List<PTierRecords> getPTRecords(String recId) {
        system.debug('recId====='+recId);
        list<PTierRecords> lstPTrec = new list<PTierRecords>();
        
        //List<PTRecords> lstPTRecords = new List<PTRecords>();
        map<string,String> ptNImap = new map<string,String>();
        map<string,Pricing_Tier__c> ptmap = new map<string,Pricing_Tier__c>();
        map<string,Decimal> ptSRPmap = new map<string,Decimal>();
        map<string,Decimal> ptWSPmap = new map<string,Decimal>();
        map<string,String> pRPmap = new map<string,String>();
        list<Digital_Release__c> lstDR = new list<Digital_Release__c>();
        Decimal strTIB = null;
        //String strProductId = '';
        set<String> prodSet = new set<String>();
        
        lstDR = [SELECT Id,of_Titles_in_Bundle__c 
                 FROM Digital_Release__c
        		WHERE Id =:recId];
        if(lstDR!=null && lstDR.size()>0)
        {
            strTIB = lstDR[0].of_Titles_in_Bundle__c;
        }
        
        list<Product__c> lstDRP = new list<Product__c>();
        lstDRP = [SELECT Id 
                 FROM Product__c
        		WHERE Digital_Release__c =:recId];
        if(lstDRP!=null && lstDRP.size()>0)
        {
            //strProductId = lstDRP[0].Id;
            for(Product__c sPord : lstDRP)
            {
                prodSet.add(sPord.Id);
            }
            
        }
        //system.debug('strProductId====='+strProductId);
        system.debug('prodSet====='+prodSet);
        //To get already existing pricing records based on Product Ids
        list<Pricing__c> lstPricing = new list<Pricing__c>();
        lstPricing = [SELECT Id,Name, Category__c, Platform__c, Price_Type__c, Resolution__c, Territory__c, 
                      Product__c, Sub_Category__c
                     FROM Pricing__c 
                     WHERE Product__c IN :prodSet 	//=:strProductId
                     //AND Price_Type__c = 'Original'
                     ];
        
        if(lstPricing!=null && lstPricing.size()>0)
        {
            for(Pricing__c pObj : lstPricing)
            {
                //String strP = pObj.Category__c+'~'+pObj.Platform__c+'~'+pObj.Territory__c+'~'+pObj.Resolution__c;
                String strP = pObj.Category__c+'~'+pObj.Sub_Category__c+'~'+pObj.Platform__c;
                pRPmap.put(strP,strP);
            }
        }
            
        List<Pricing_Tier__c> lstPTs =  [SELECT Id, Name, Territory__c, Resolution__c, SRP__c, WSP__c, Product_Type__c, 
                                         No_of_Titles__c,Category__c,Platform__c, Sub_Category__c
                                               FROM Pricing_Tier__c 
                                        WHERE Product_Type__c = 'Bundle'
                                         AND No_of_Titles__c =: strTIB
                                         //AND Category__c = 'New Release Premium' AND Sub_Category__c='Super Premium'
                                         AND Category__c !=null AND Category__c !=''
                                         ORDER BY WSP__c DESC NULLS LAST, Category__c
                                        ];
         
        if(lstPTs != null && lstPTs.size() > 0){
            
            for(Pricing_Tier__c pt : lstPTs){
                system.debug('==============='+pt.Name+'~'+pt.Product_Type__c+'~'+pt.No_of_Titles__c);
                if(!ptNImap.isEmpty() && ptNImap.containsKey(pt.Category__c+'~'+pt.Product_Type__c+'~'+pt.Sub_Category__c+'~'+pt.No_of_Titles__c))
                {
                	String str = ptNImap.get(pt.Category__c+'~'+pt.Product_Type__c+'~'+pt.Sub_Category__c+'~'+pt.No_of_Titles__c);
                    str += ','+pt.Id;
                    ptNImap.put(pt.Category__c+'~'+pt.Product_Type__c+'~'+pt.Sub_Category__c+'~'+pt.No_of_Titles__c,str);
				}else
                {
                    ptNImap.put(pt.Category__c+'~'+pt.Product_Type__c+'~'+pt.Sub_Category__c+'~'+pt.No_of_Titles__c,pt.Id);
                }
                
                ptmap.put(pt.Category__c+'~'+pt.Sub_Category__c, pt);
                
                String srpkey = pt.Category__c+'~'+pt.Sub_Category__c+'~'+pt.Territory__c+'~'+pt.Resolution__c+'~'+'SRP';
                if(ptSRPmap.isEmpty() || !ptSRPmap.containsKey(srpkey))
                {
                    ptSRPmap.put(srpkey,pt.SRP__c);
                }
                
                String wspkey = pt.Category__c+'~'+pt.Sub_Category__c+'~'+pt.Territory__c+'~'+pt.Resolution__c+'~'+'WSP';
                if(ptWSPmap.isEmpty() || !ptWSPmap.containsKey(wspkey))
                {
                    ptWSPmap.put(wspkey,pt.WSP__c);
                }
                
                /*if(!ptNImap.isEmpty() && ptNImap.containsKey(pt.Name+'~'+pt.Product_Type__c+'~'+pt.No_of_Titles__c))
                {
                	String str = ptNImap.get(pt.Name+'~'+pt.Product_Type__c+'~'+pt.No_of_Titles__c);
                    str += ','+pt.Id;
                    ptNImap.put(pt.Name+'~'+pt.Product_Type__c+'~'+pt.No_of_Titles__c,str);
				}else
                {
                    ptNImap.put(pt.Name+'~'+pt.Product_Type__c+'~'+pt.No_of_Titles__c,pt.Id);
                }
                                
                ptmap.put(pt.Name, pt);
                
                String srpkey = pt.Name+'~'+pt.Territory__c+'~'+pt.Resolution__c+'~'+'SRP';
                if(ptSRPmap.isEmpty() || !ptSRPmap.containsKey(srpkey))
                {
                    ptSRPmap.put(srpkey,pt.SRP__c);
                }
                
                String wspkey = pt.Name+'~'+pt.Territory__c+'~'+pt.Resolution__c+'~'+'WSP';
                if(ptWSPmap.isEmpty() || !ptWSPmap.containsKey(wspkey))
                {
                    ptWSPmap.put(wspkey,pt.WSP__c);
                }
                */
                
            }
            
        }
        
        system.debug('ptmap====='+ptmap);
        system.debug('pRPmap====='+pRPmap);
        if(!ptNImap.isEmpty() && ptNImap.size()>0)
        {
            for(String key : ptNImap.keySet())
            {
                PTierRecords ptrObj = new PTierRecords();
                ptrObj.ptId = ptNImap.get(key);
                string[] strArry = key.split('~');
                //ptrObj.ptName = strArry[0];  
                String strCategory =  strArry[2]; 
                system.debug('strCategory===='+strCategory);
                if(strCategory != null && strCategory != '' && strCategory != 'null')
                {
                    strCategory =  ' : ' +strCategory ;
                }else
                {
                    strCategory =  '' ;
                }
                system.debug('strCategory=11==='+strCategory);
                ptrObj.ptName = strArry[0]+strCategory; 
                system.debug('ptrObj.ptName====='+ptrObj.ptName);                
                system.debug('ptrObj.ptName Test'+ptrObj.ptName);
                ptrObj.ptType = strArry[1];
                ptrObj.isCreated = false;
                
                String srpkey = strArry[0]+'~'+strArry[2];
                system.debug('srpkey====='+srpkey);
                ptrObj.ptCategopy = ptmap.get(srpkey).Category__c;
                //ptrObj.ptCategopy = ptmap.get(ptrObj.ptName).Category__c;
                ptrObj.ptPlatform = ptmap.get(srpkey).Platform__c;
                //ptrObj.ptPlatform = ptmap.get(ptrObj.ptName).Platform__c;
                ptrObj.ptSubCategopy = ptmap.get(srpkey).Sub_Category__c;
                //ptrObj.ptSubCategopy = ptmap.get(ptrObj.ptName).Sub_Category__c;
                ptrObj.noOfTitles = String.valueOf(ptmap.get(srpkey).No_of_Titles__c);
                //ptrObj.noOfTitles = String.valueOf(ptmap.get(ptrObj.ptName).No_of_Titles__c);
                system.debug('ptrObj.ptCategopy===='+ptrObj.ptCategopy+'===='+ptrObj.ptSubCategopy+'==ptPlatform=='+ptrObj.ptPlatform);
                if(!pRPmap.isEmpty() && pRPmap.containsKey(ptrObj.ptCategopy+'~'+ptrObj.ptSubCategopy+'~'+ptrObj.ptPlatform))
                {
                    ptrObj.isCreated = true;
                }
                ptrObj.isProductsExists = false;
                if(prodSet!=null && prodSet.size()>0)
                {
                	ptrObj.isProductsExists = true;
                }
                
                //String srpkey1 = strArry[0]+'~'+'US'+'~'+'SD'+'~'+'SRP';
                //String wspkey1 = strArry[0]+'~'+'US'+'~'+'SD'+'~'+'WSP';
                String srpkey1 = strArry[0]+'~'+strArry[2]+'~'+'US'+'~'+'SD'+'~'+'SRP';
                String wspkey1 = strArry[0]+'~'+strArry[2]+'~'+'US'+'~'+'SD'+'~'+'WSP';
                ptrObj.uSSDWSP = String.valueOf(ptWSPmap.get(wspkey1));
                ptrObj.uSSDSRP = String.valueOf(ptSRPmap.get(srpkey1));
                
                //srpkey1 = strArry[0]+'~'+'US'+'~'+'HD'+'~'+'SRP';
                //wspkey1 = strArry[0]+'~'+'US'+'~'+'HD'+'~'+'WSP';
                srpkey1 = strArry[0]+'~'+strArry[2]+'~'+'US'+'~'+'HD'+'~'+'SRP';
                wspkey1 = strArry[0]+'~'+strArry[2]+'~'+'US'+'~'+'HD'+'~'+'WSP';
                ptrObj.uSHDWSP = String.valueOf(ptWSPmap.get(wspkey1));
                ptrObj.uSHDSRP = String.valueOf(ptSRPmap.get(srpkey1));
                
                //srpkey1 = strArry[0]+'~'+'US'+'~'+'UHD'+'~'+'SRP';
                //wspkey1 = strArry[0]+'~'+'US'+'~'+'UHD'+'~'+'WSP';
                srpkey1 = strArry[0]+'~'+strArry[2]+'~'+'US'+'~'+'UHD'+'~'+'SRP';
                wspkey1 = strArry[0]+'~'+strArry[2]+'~'+'US'+'~'+'UHD'+'~'+'WSP';
                ptrObj.uSUHDWSP = String.valueOf(ptWSPmap.get(wspkey1));
                ptrObj.uSUHDSRP = String.valueOf(ptSRPmap.get(srpkey1));
                
                //srpkey1 = strArry[0]+'~'+'CA'+'~'+'SD'+'~'+'SRP';
                //wspkey1 = strArry[0]+'~'+'CA'+'~'+'SD'+'~'+'WSP';
                srpkey1 = strArry[0]+'~'+strArry[2]+'~'+'CA'+'~'+'SD'+'~'+'SRP';
                wspkey1 = strArry[0]+'~'+strArry[2]+'~'+'CA'+'~'+'SD'+'~'+'WSP';
                ptrObj.cASDWSP = String.valueOf(ptWSPmap.get(wspkey1));
                ptrObj.cASDSRP = String.valueOf(ptSRPmap.get(srpkey1));
                
                //srpkey1 = strArry[0]+'~'+'CA'+'~'+'HD'+'~'+'SRP';
                //wspkey1 = strArry[0]+'~'+'CA'+'~'+'HD'+'~'+'WSP';
                srpkey1 = strArry[0]+'~'+strArry[2]+'~'+'CA'+'~'+'HD'+'~'+'SRP';
                wspkey1 = strArry[0]+'~'+strArry[2]+'~'+'CA'+'~'+'HD'+'~'+'WSP';
                ptrObj.cAHDWSP = String.valueOf(ptWSPmap.get(wspkey1));
                ptrObj.cAHDSRP = String.valueOf(ptSRPmap.get(srpkey1));
                
                //srpkey1 = strArry[0]+'~'+'CA'+'~'+'UHD'+'~'+'SRP';
                //wspkey1 = strArry[0]+'~'+'CA'+'~'+'UHD'+'~'+'WSP';
                srpkey1 = strArry[0]+'~'+strArry[2]+'~'+'CA'+'~'+'UHD'+'~'+'SRP';
                wspkey1 = strArry[0]+'~'+strArry[2]+'~'+'CA'+'~'+'UHD'+'~'+'WSP';
                ptrObj.cAUHDWSP = String.valueOf(ptWSPmap.get(wspkey1));
                ptrObj.cAUHDSRP = String.valueOf(ptSRPmap.get(srpkey1));
                                
                lstPTrec.add(ptrObj);
            }
        }
        
        PTierRecords ptrObj = new PTierRecords();
        ptrObj.ptId = 'Temp';
        
        ptrObj.ptName = 'Custom';
        ptrObj.ptType = '';
        ptrObj.ptCategopy = '';
        ptrObj.ptSubCategopy = '';
        ptrObj.ptPlatform = '';
        
        ptrObj.isProductsExists = false;
        if(prodSet!=null && prodSet.size()>0)
        {
            ptrObj.isProductsExists = true;
        }
        
        
        ptrObj.noOfTitles = String.valueOf(strTIB); //12-13-2018
        ptrObj.uSSDWSP = '';
        ptrObj.uSSDSRP = '';
        ptrObj.uSHDWSP = '';
        ptrObj.uSHDSRP = '';
        ptrObj.uSUHDWSP = '';
        ptrObj.uSUHDSRP = '';
        ptrObj.cASDWSP = '';
        ptrObj.cASDSRP = '';
        ptrObj.cAHDWSP = '';
        ptrObj.cAHDSRP = '';
        ptrObj.cAUHDWSP = '';
        ptrObj.cAUHDSRP = '';
        lstPTrec.add(ptrObj);
		
        system.debug('lstPTrec====='+lstPTrec);
        return lstPTrec;

    } 
   
    @AuraEnabled
    public static Boolean getProductSel(String recId) {
        Boolean checkSelected = false;
        list<Product__c> lstDRP = new list<Product__c>();
        lstDRP = [SELECT Id, HD__c, SD__c, UHD__c 
                 FROM Product__c
        		WHERE Digital_Release__c =:recId];
        if(lstDRP!=null && lstDRP.size()>0)
        {
            //strProductId = lstDRP[0].Id;
            for(Product__c sPord : lstDRP)
            {
                if(sPord.HD__c == true || sPord.SD__c == true || sPord.UHD__c == true)
                {
                    checkSelected = true;
                }
            }
            
        }
        //system.debug('strProductId====='+strProductId);
        system.debug('checkSelected====='+checkSelected);
        return checkSelected;
    }
    
    @AuraEnabled
    public static String getUserProfile() {
        //Id userId = UserInfo.getUserId();
        //return [SELECT IsActive FROM User WHERE Id = :userId].IsActive;
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        system.debug('Profile Name'+profileName);
        
        return profileName;
    }
    
    @AuraEnabled
    public static String savePricingTiers(String lstPts, String dRRecId, String selPType, String seltoday){
        String msg = '';
        //Boolean recordsSaved = false;
        String recordsSaved = 'false';
        
            system.debug('lstPts====='+lstPts);
            system.debug('dRRecId======'+dRRecId);
            system.debug('selPType======'+selPType);
            system.debug('seltoday======'+Date.valueOf(seltoday));
            Date sDate = Date.valueOf(seltoday);
            //12-11-2018
            list<Product__c> lstDRPCheck = new list<Product__c>();
            set<Id> prodSet = new set<Id>();
            lstDRPCheck = [SELECT Id 
                     FROM Product__c
                    WHERE Digital_Release__c =:dRRecId];
            if(lstDRPCheck!=null && lstDRPCheck.size()>0)
            {
                //strProductId = lstDRP[0].Id;
                for(Product__c sPord : lstDRPCheck)
                {
                    prodSet.add(sPord.Id);
                }
                
            }
            //system.debug('strProductId====='+strProductId);
            system.debug('prodSet====='+prodSet);
            //To get already existing pricing records based on Product Ids
            list<Pricing__c> lstPricing = new list<Pricing__c>();
            lstPricing = [SELECT Id,Name, Category__c, Platform__c, Price_Type__c, Resolution__c, Territory__c, 
                          Product__c, Sub_Category__c
                         FROM Pricing__c 
                         WHERE Product__c IN :prodSet 	//=:strProductId
                          AND Valid_From__c >=: sDate
                          AND Account__c != 'iTunes'
                         //AND Price_Type__c = 'Original'
                         ];
             System.debug('----------------------'+lstPricing);
            if(lstPricing!=null && lstPricing.size()>0)
            {
                recordsSaved = 'Pricing records exists';
                return recordsSaved;
            }
            //12-11-2018
            
            List<PTierRecords>
                listToSave = (List<PTierRecords>)JSON.deserialize(lstPts, List<PTierRecords>.class);
            system.debug('listToSave===='+listToSave);
            
            list<Pricing__c> lstPrice = new list<Pricing__c>();
            list<Product__c> lstDRP = new list<Product__c>();
            String strProdId = '';
            map<String,Product__c> productMap = new map<String,Product__c>();
            lstDRP = [SELECT Id, HD__c, SD__c, UHD__c ,US_Platform_Offering__c, CA_Platform_Offering__c
                     FROM Product__c
                    WHERE Digital_Release__c =:dRRecId];
            if(lstDRP!=null && lstDRP.size()>0)
            {
                //strProdId = lstDRP[0].Id;
                for(Product__c prod : lstDRP)
                {
                    productMap.put(prod.Id, prod);
                }
            }
            system.debug('strProdId====='+strProdId);
            String bundlePricingTier ='';
            
            if(listToSave != null && listToSave.size() > 0){
                   system.debug('listToSave===='+listToSave); 
                for(PTierRecords pt : listToSave){
                    if(pt.isSelected == true)
                    {
                        
                        if(pt.ptId == 'Temp')
                        {
                            System.debug('Custom Records to save?---->'+pt);
                            pt.ptCategopy = 'Custom';
                            pt.ptPlatform = 'EST'; // Modified.
                          //  pt.noOfTitles = pt.ptId.noOfTitles;
                              System.debug('No of titles in the System---'+pt.noOfTitles);                         
                        }
     // added on 11/29/2018 to update initial pricin tier and Current pricing Tier with category and sub-category.
                        if(pt.ptSubCategopy != null && pt.ptSubCategopy != ''){
                            bundlePricingTier = pt.ptCategopy+' : '+pt.ptSubCategopy;
                        } else
                        {
                            bundlePricingTier = pt.ptCategopy;
                        }
                         
                        
                        
                        /*==================US==================*/
                        
                        //Pricing__c pObj = new Pricing__c();
                        if(!productMap.isEmpty() && productMap.size()>0)
                        {
                            for(String key : productMap.keySet())
                            {
                                Product__c prObj = productMap.get(key);
                                String usPlatform = prObj.US_Platform_Offering__c;
                                String caPlatform = prObj.CA_Platform_Offering__c;
                                
                                if(prObj.SD__c)
                                {
                                    
                                    
                                    if(usPlatform!=null && usPlatform!='' && usPlatform.contains('EST'))
                                    {
                                        if((pt.uSSDWSP!=null && pt.uSSDWSP!='') || (pt.uSSDSRP!=null && pt.uSSDSRP!=''))
                                        {
                                            Pricing__c pObj = new Pricing__c();
                                            pObj.Name = pt.ptName;                                      
                                            pObj.Product__c = key;
                                            System.debug('Before Conversiton'+pt.uSSDWSP);
                                            // modified
                                            if(String.isBlank(pt.uSSDWSP))
                                            {
                                                pt.uSSDWSP = '0';
                                            } 
                                            if(String.isBlank(pt.uSSDSRP))
                                            {
                                                pt.uSSDSRP = '0';
                                            } 
                                            pObj.SRP__c = Decimal.valueOf(pt.uSSDSRP);
                                            pObj.WSP__c = Decimal.valueOf(pt.uSSDWSP);
                                            System.debug('After Conversiton'+pt.uSSDWSP);
                                            pObj.Resolution__c = 'SD';
                                            pObj.Territory__c = 'US';
                                            pObj.Price_Type__c = selPType;
                                            pObj.Valid_From__c = Date.valueOf(seltoday);
                                            pObj.Platform__c = pt.ptPlatform;
                                            pObj.Category__c = pt.ptCategopy;
                                            pObj.Sub_Category__c = pt.ptSubCategopy;
                                            system.debug('pObj.Sub_Category__c------>'+pObj.Sub_Category__c);
                                            if(pt.noOfTitles!=null && pt.noOfTitles!='')
                                                pObj.No_of_Titles__c = Decimal.valueOf(pt.noOfTitles);
                                            lstPrice.add(pObj);
                                        }
                                    }
                                    
                                    
                                    if(caPlatform!=null && caPlatform!='' && caPlatform.contains('EST'))
                                    {
                                        if((pt.cASDWSP!=null && pt.cASDWSP!='') || (pt.cASDSRP!=null && pt.cASDSRP!=''))
                                        {
                                            Pricing__c pObj = new Pricing__c();
                                            pObj.Name = pt.ptName;
                                            
                                            pObj.Product__c = key;
                                            if(String.isBlank(pt.cASDWSP))
                                            {
                                                pt.cASDWSP = '0';
                                            } 
                                            if(String.isBlank(pt.cASDSRP))
                                            {
                                                pt.cASDSRP = '0';
                                            } 
                                            pObj.SRP__c = Decimal.valueOf(pt.cASDSRP);
                                             System.debug('Enter Value'+pt.cASDWSP);
                                            pObj.WSP__c = Decimal.valueOf(pt.cASDWSP);
                                            System.debug('Enter Value'+pObj.WSP__c);
                                            pObj.Resolution__c = 'SD';
                                            pObj.Territory__c = 'CA';
                                            pObj.Price_Type__c = selPType;
                                            pObj.Valid_From__c = Date.valueOf(seltoday);
                                            pObj.Platform__c = pt.ptPlatform;
                                            pObj.Category__c = pt.ptCategopy;
                                            pObj.Sub_Category__c = pt.ptSubCategopy;
                                            if(pt.noOfTitles!=null && pt.noOfTitles!='')
                                                pObj.No_of_Titles__c = Decimal.valueOf(pt.noOfTitles);
                                            lstPrice.add(pObj);
                                        }
                                    }
                                }
                                
                                if(prObj.HD__c)
                                {
                                    if(usPlatform!=null && usPlatform!='' && usPlatform.contains('EST'))
                                    {
                                        if((pt.uSHDWSP!=null && pt.uSHDWSP!='') || (pt.uSHDSRP!=null && pt.uSHDSRP!=''))
                                        {
                                            Pricing__c pObj = new Pricing__c();
                                            pObj.Name = pt.ptName;
                                            
                                            pObj.Product__c = key;
                                            // Modified
                                            if(String.isBlank(pt.uSHDWSP))
                                            {
                                                pt.uSHDWSP = '0';
                                            } 
                                            if(String.isBlank(pt.uSHDSRP))
                                            {
                                                pt.uSHDSRP = '0';
                                            } 
                                            pObj.SRP__c = Decimal.valueOf(pt.uSHDSRP);
                                            pObj.WSP__c = Decimal.valueOf(pt.uSHDWSP);
                                            pObj.Resolution__c = 'HD';
                                            pObj.Territory__c = 'US';
                                            pObj.Price_Type__c = selPType;
                                            pObj.Valid_From__c = Date.valueOf(seltoday);
                                            pObj.Platform__c = pt.ptPlatform;
                                            pObj.Category__c = pt.ptCategopy;
                                            pObj.Sub_Category__c = pt.ptSubCategopy;
                                            if(pt.noOfTitles!=null && pt.noOfTitles!='')
                                                pObj.No_of_Titles__c = Decimal.valueOf(pt.noOfTitles);
                                            lstPrice.add(pObj);
                                        }
                                    }
                                    
                                    if(caPlatform!=null && caPlatform!='' && caPlatform.contains('EST'))
                                    {
                                        if((pt.cAHDWSP!=null && pt.cAHDWSP!='') || (pt.cAHDSRP!=null && pt.cAHDSRP!=''))
                                        {
                                            Pricing__c pObj = new Pricing__c();
                                            pObj.Name = pt.ptName;
                                            
                                            pObj.Product__c = key;
                                            // Modified
                                            if(String.isBlank(pt.cAHDWSP))
                                            {
                                                pt.cAHDWSP = '0';
                                            } 
                                            if(String.isBlank(pt.cAHDSRP))
                                            {
                                                pt.cAHDSRP = '0';
                                            } 
                                            pObj.SRP__c = Decimal.valueOf(pt.cAHDSRP);
                                            pObj.WSP__c = Decimal.valueOf(pt.cAHDWSP);
                                            pObj.Resolution__c = 'HD';
                                            pObj.Territory__c = 'CA';
                                            pObj.Price_Type__c = selPType;
                                            pObj.Valid_From__c = Date.valueOf(seltoday);
                                            pObj.Platform__c = pt.ptPlatform;
                                            pObj.Category__c = pt.ptCategopy;
                                            pObj.Sub_Category__c = pt.ptSubCategopy;
                                            if(pt.noOfTitles!=null && pt.noOfTitles!='')
                                                pObj.No_of_Titles__c = Decimal.valueOf(pt.noOfTitles);
                                            lstPrice.add(pObj);
                                        }
                                    }
                                }
                                
                                if(prObj.UHD__c)
                                {
                                    if(usPlatform!=null && usPlatform!='' && usPlatform.contains('EST'))
                                    {
                                        if((pt.uSUHDWSP!=null && pt.uSUHDWSP!='') || (pt.uSUHDSRP!=null && pt.uSUHDSRP!=''))
                                        {
                                            Pricing__c pObj = new Pricing__c();
                                            pObj.Name = pt.ptName;
                                            
                                            pObj.Product__c = key;
                                            // Modified
                                            if(String.isBlank(pt.uSUHDWSP))
                                            {
                                                pt.uSUHDWSP = '0';
                                            } 
                                            if(String.isBlank(pt.uSUHDSRP))
                                            {
                                                pt.uSUHDSRP = '0';
                                            } 
                                            pObj.SRP__c = Decimal.valueOf(pt.uSUHDSRP);
                                            pObj.WSP__c = Decimal.valueOf(pt.uSUHDWSP);
                                            pObj.Resolution__c = 'UHD';
                                            pObj.Territory__c = 'US';
                                            pObj.Price_Type__c = selPType;
                                            pObj.Valid_From__c = Date.valueOf(seltoday);
                                            pObj.Platform__c = pt.ptPlatform;
                                            pObj.Category__c = pt.ptCategopy;
                                            pObj.Sub_Category__c = pt.ptSubCategopy;
                                            if(pt.noOfTitles!=null && pt.noOfTitles!='')
                                                pObj.No_of_Titles__c = Decimal.valueOf(pt.noOfTitles);
                                            lstPrice.add(pObj);
                                        }
                                    }
                                    if(caPlatform!=null && caPlatform!='' && caPlatform.contains('EST'))
                                    {
                                        if((pt.cAUHDWSP!=null && pt.cAUHDWSP!='') || (pt.cAUHDSRP!=null && pt.cAUHDSRP!=''))
                                        {
                                            Pricing__c pObj = new Pricing__c();
                                            pObj.Name = pt.ptName;
                                             
                                            pObj.Product__c = key;
                                            // modified
                                             if(String.isBlank(pt.cAUHDWSP))
                                            {
                                                pt.cAUHDWSP = '0';
                                            } 
                                            if(String.isBlank(pt.cAUHDSRP))
                                            {
                                                pt.cAUHDSRP = '0';
                                            } 
                                            pObj.SRP__c = Decimal.valueOf(pt.cAUHDSRP);
                                            pObj.WSP__c = Decimal.valueOf(pt.cAUHDWSP);
                                            pObj.Resolution__c = 'UHD';
                                            pObj.Territory__c = 'CA';
                                            pObj.Price_Type__c = selPType;
                                            pObj.Valid_From__c = Date.valueOf(seltoday);
                                            pObj.Platform__c = pt.ptPlatform;
                                            pObj.Category__c = pt.ptCategopy;
                                            pObj.Sub_Category__c = pt.ptSubCategopy;
                                            if(pt.noOfTitles!=null && pt.noOfTitles!='')
                                                pObj.No_of_Titles__c = Decimal.valueOf(pt.noOfTitles);                                            
                                            lstPrice.add(pObj);
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                    }
                }
            }
            
            if(lstPrice!=null && lstPrice.size()>0)
            {
                system.debug('lstPrice===='+lstPrice);
                insert lstPrice;
                recordsSaved = 'true';
                list<Digital_Release__c> lstDR = new list<Digital_Release__c>();
                
                lstDR = [SELECT Id, Initial_Pricing_Tier__c, Current_Pricing_Tier__c
                         FROM Digital_Release__c
                        WHERE Id =:dRRecId];
                if(lstDR!=null && lstDR.size()>0)
                {
                    if((lstDR[0].Initial_Pricing_Tier__c == null || lstDR[0].Initial_Pricing_Tier__c == '')
                       && selPType == 'Original')
                        lstDR[0].Initial_Pricing_Tier__c = bundlePricingTier;
                    else
                        lstDR[0].Current_Pricing_Tier__c = bundlePricingTier;
                    //strTIB = lstDR[0].of_Titles_in_Bundle__c;
                    
                    update lstDR;
                }
            }
        
        return recordsSaved;
        
    }
    
}