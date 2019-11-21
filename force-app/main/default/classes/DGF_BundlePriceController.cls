public class DGF_BundlePriceController {
	
	public class pricingWrapper{ 
		@AuraEnabled 
		public String name;
		@AuraEnabled 
		public Decimal price;
		@AuraEnabled 
		public boolean validationStatus;
		@AuraEnabled 
		public String validationNotes;	
		
		public pricingWrapper(string name, decimal price, boolean validationStatus, string validationNotes){
			this.name = name;
			this.price = price;
			this.validationStatus = validationStatus;
			this.validationNotes = validationNotes;
		}	
	}
	
	@AuraEnabled 
	public static String validateBundleRelease(Id bundleProductId){	
		
		String errorMessage = 'PASS';
		
		product__C prod  = [select Digital_Release__r.Release_State__c, Digital_Release__r.US_Bundle_Avail_Date__c, Digital_Release__r.CA_Bundle_Avail_Date__c,
			(select id, name, Resolution__c, Valid_From__c, Valid_To__c, Territory__c, Platform__c, WSP__c, SRP__c, Price_Type__c  from Pricing__r) from product__C where id = :bundleProductId ];
		
		if(prod!=null){
			if(prod.Digital_Release__r.US_Bundle_Avail_Date__c==null && prod.Digital_Release__r.CA_Bundle_Avail_Date__c==null){
				errorMessage = 'Please Enter a Valid Bundle Avail Date';
				return errorMessage;
			} 
			else if(prod.Digital_Release__r.Release_State__c!=null && !prod.Digital_Release__r.Release_State__c.equalsIgnoreCase('Active')){
				errorMessage = 'Bundle is Inactive or Cancelled';
				return errorMessage;
			}else if(prod.Digital_Release__r.Release_State__c==null || prod.Digital_Release__r.Release_State__c.equalsIgnoreCase('Active')){
				if(prod.Pricing__r!=null &&  prod.Pricing__r.size()>0){
					for(pricing__C priceRec : prod.Pricing__r){
						if(priceRec.Price_Type__c!=DGF_Constants.ORIGINAL){
							errorMessage = 'Bundle has pricing Records that are Reprice or TPR';
							break;
						}else if(String.isBlank(priceRec.Resolution__c) || String.isBlank(priceRec.Territory__c) || String.isBlank(priceRec.Platform__c) || priceRec.WSP__c==0 ||  priceRec.SRP__c==0 || priceRec.Valid_To__c <  system.today() || priceRec.Valid_From__c == null){
							errorMessage = 'Please check the pricing records for Resolution, Territory, Platform, WSP, SRP, Validity and Try Again!';
							break;
						}
					}
				}				
			}else{
				errorMessage = 'Please add Pricing and Try Again!'; 
			}
			
		}
		
		return errorMessage;
		
	}
	
	@AuraEnabled 
	public static List<pricingWrapper> validateTitlePricingBundle(Id bundleProductId){		
			
		Map<string, string> displayLabelMap = new Map<string, string> ();
		displayLabelMap.put('USESTSDWSP', 'US EST SD WSP');
		displayLabelMap.put('USESTSDSRP', 'US EST SD SRP');
		displayLabelMap.put('USESTHDWSP', 'US EST HD WSP');
		displayLabelMap.put('USESTHDSRP', 'US EST HD SRP');
		displayLabelMap.put('USESTUHDWSP', 'US EST UHD WSP');
		displayLabelMap.put('USESTUHDSRP', 'US EST UHD SRP');
		displayLabelMap.put('USEST3DWSP', 'US EST 3D WSP');
		displayLabelMap.put('USEST3DSRP', 'US EST 3D SRP');    
		
		displayLabelMap.put('CAESTSDWSP', 'CA EST SD WSP');
		displayLabelMap.put('CAESTSDSRP', 'CA EST SD SRP');
		displayLabelMap.put('CAESTHDWSP', 'CA EST HD WSP');
		displayLabelMap.put('CAESTHDSRP', 'CA EST HD SRP');
		displayLabelMap.put('CAESTUHDWSP', 'CA EST UHD WSP');
		displayLabelMap.put('CAESTUHDSRP', 'CA EST UHD SRP');
		displayLabelMap.put('CAEST3DWSP', 'CA EST 3D WSP');
		displayLabelMap.put('CAEST3DSRP', 'CA EST 3D SRP');
		
		
	
	
		//system.debug('bundleProductId***'+bundleProductId);
		date caAvailDate;
		date usAvailDate;
		list<pricing__c> bundlePricingList = new list<pricing__c>();
		list<Id> titleVersionsList = new list<Id>();
		boolean notOriginal = false;
		List<pricingWrapper> wrapperPriceList = new List<pricingWrapper>();
		
		product__C prod  = [select Digital_Release__r.US_Bundle_Avail_Date__c, Digital_Release__r.CA_Bundle_Avail_Date__c,
		(select id,name, Resolution__c, Valid_From__c, Valid_To__c, Territory__c, Platform__c, WSP__c, SRP__c, Price_Type__c  from Pricing__r), (select id, TM_Version__c from Product_Versions__r) from product__C where id = :bundleProductId ];
		
		if(prod!=null && prod.Product_Versions__r!=null){
			for(Product_Version__c pv: prod.Product_Versions__r){ 
				titleVersionsList.add(pv.TM_Version__c);
			}
		}
		
		//System.debug('titleVersionsList>>' + titleVersionsList);
		
		
		//if(prod!=null && prod.pricing__r!=null && !notOriginal){
		if(prod!=null && prod.pricing__r!=null){
			bundlePricingList = prod.pricing__r;
			
			List<pricing__c> pricingListUS;
			List<pricing__c> pricingListCA;
			Map<string, pricing__c> pricingMapUS = new Map<string, pricing__c>();
			Map<string, pricing__c> pricingMapCA = new Map<string, pricing__c>();
			 
			if(prod.Digital_Release__r.US_Bundle_Avail_Date__c!=null){ //Process US Pricing Rec Validation
				pricingListUS = [select id, product__r.name, product__c,  Price_Type__c, WSP__c, SRP__c, Resolution__c, Territory__c,Platform__c  , Valid_From__c, Valid_To__c, promotion__c from pricing__c 
					where product__c  in (select Product__c from  Product_Version__c  where  TM_Version__c = :titleVersionsList ) and ( (Valid_To__c >= :prod.Digital_Release__r.US_Bundle_Avail_Date__c  and Valid_To__c>= today) or Valid_To__c = null)  
					 and Product__r.RecordType.Name != :DGF_Constants.BUNDLE and Territory__c = :DGF_Constants.TERRITORY_US and Account__c =null and promotion__c = null and platform__C != :DGF_Constants.PLATFORM_VOD order by product__r.Name, Platform__c, Valid_From__c desc ] ;
			
			System.debug('pricingListUS>>' + pricingListUS);
				if(pricingListUS!=null && pricingListUS.size()>0){
					
					for(pricing__C priceRecord : pricingListUS){
						String key = '';
						key = priceRecord.Territory__c + '' + priceRecord.Platform__c + '' + priceRecord.Resolution__c + '-' + priceRecord.product__c;
						System.debug('KEY>>'+ key);
						
						if(!pricingMapUS.containsKey(key)){
							pricingMapUS.put(key, priceRecord);
						}else{
							 if(pricingMapUS.get(key).Price_Type__c == DGF_Constants.ORIGINAL){ //Existing is Original
									
								}else if(pricingMapUS.get(key).Price_Type__c == DGF_Constants.REPRICE){//Existing is Reprice
									if(priceRecord.Price_Type__c == DGF_Constants.REPRICE){//new Reprice has low wsp
										if(pricingMapUS.get(key).Valid_From__c > priceRecord.Valid_From__c){
											pricingMapUS.put(key, priceRecord);
										}
									}else if(priceRecord.Price_Type__c == DGF_Constants.ORIGINAL){ // new Rec is Original
										pricingMapUS.put(key, priceRecord);
									}
								}							
						}
					}
					
					//System.debug('pricingMapUS>>' + pricingMapUS);
					
					for(pricing__c bundlePrice : bundlePricingList){
						if(bundlePrice.Territory__c.equalsIgnoreCase(DGF_Constants.TERRITORY_US)){
							String priceName = bundlePrice.Territory__c + '' + bundlePrice.Platform__c + '' + bundlePrice.Resolution__c;
							System.debug('priceName>>' + priceName);
							Decimal titleSumPriceWSP = 0;
							Decimal titleSumPriceSRP = 0;
							
							for(string prodKey : pricingMapUS.KeySet()){
								string innerPriceName = prodKey.substringBefore('-').trim();
								System.debug('innerPriceName>>' + innerPriceName);
								if(priceName.equalsIgnoreCase (innerPriceName)){
									titleSumPriceWSP+= pricingMapUS.get(prodKey).WSP__c;
									titleSumPriceSRP+= pricingMapUS.get(prodKey).SRP__c;
									system.debug('innerPriceName??TRUE' );
								}
							}
							System.debug('titleSumPriceWSP>>' + titleSumPriceWSP + 'titleSumPriceSRP>>' + titleSumPriceSRP );
							if(titleSumPriceWSP>0){
								string displaynameStr = displayLabelMap.get(priceName+'WSP');
								
								if(bundlePrice.WSP__c > titleSumPriceWSP){
									wrapperPriceList.add(new pricingWrapper(displaynameStr, bundlePrice.WSP__c, False, 'Sum of title(s) WSP : '+ titleSumPriceWSP));
								}								
							}
							if(titleSumPriceSRP>0){
								string displaynameStr = displayLabelMap.get(priceName+'SRP');
								if(bundlePrice.SRP__c > titleSumPriceSRP){
									wrapperPriceList.add(new pricingWrapper(displaynameStr, bundlePrice.SRP__c, False, 'Sum of title(s) SRP : '+ titleSumPriceSRP));
								}
							}
						}
					}
				}
			
			}
			if(prod.Digital_Release__r.CA_Bundle_Avail_Date__c!=null){//Process CA Pricing Rec Validation
				pricingListCA = [select id, product__r.name, product__c, Price_Type__c, WSP__c, SRP__c, Resolution__c, Territory__c,Platform__c , Valid_From__c, Valid_To__c, promotion__c from pricing__c 
					where product__c  in (select Product__c from  Product_Version__c  where  TM_Version__c = :titleVersionsList ) and ( (Valid_To__c >= :prod.Digital_Release__r.CA_Bundle_Avail_Date__c  and Valid_To__c>= today) or Valid_To__c = null) 
					 and Product__r.RecordType.Name != :DGF_Constants.BUNDLE and Territory__c = :DGF_Constants.TERRITORY_CA and Account__c =null and promotion__c = null and platform__C != :DGF_Constants.PLATFORM_VOD order by product__r.Name, Platform__c, Valid_From__c desc ] ;
			
			
				if(pricingListCA!=null && pricingListCA.size()>0){
					
					for(pricing__C priceRecord : pricingListCA){
						String key = '';
						key = priceRecord.Territory__c + '' + priceRecord.Platform__c + '' + priceRecord.Resolution__c + '-' + priceRecord.product__c;
						
						if(!pricingMapCA.containsKey(key)){
							pricingMapCA.put(key, priceRecord);
						}else{
							if(pricingMapCA.get(key).Price_Type__c == DGF_Constants.ORIGINAL){ //Existing is Original
									
								}else if(pricingMapCA.get(key).Price_Type__c == DGF_Constants.REPRICE){//Existing is Reprice
									if(priceRecord.Price_Type__c == DGF_Constants.REPRICE){//new Reprice has low wsp
										if(pricingMapCA.get(key).Valid_From__c > priceRecord.Valid_From__c){
											pricingMapCA.put(key, priceRecord);
										}
									}else if(priceRecord.Price_Type__c == DGF_Constants.ORIGINAL){
										pricingMapCA.put(key, priceRecord);
									}
								}
						}
					}
					
					for(pricing__c bundlePrice : bundlePricingList){
						if(bundlePrice.Territory__c.equalsIgnoreCase(DGF_Constants.TERRITORY_CA)){
							String priceName = bundlePrice.Territory__c + '' + bundlePrice.Platform__c + '' + bundlePrice.Resolution__c;
							Decimal titleSumPriceWSP = 0;
							Decimal titleSumPriceSRP = 0;
							
							for(string prodKey : pricingMapCA.KeySet()){
								string innerPriceName = prodKey.substringBefore('-').trim();
								if(priceName.equalsIgnoreCase (innerPriceName)){
									titleSumPriceWSP+= pricingMapCA.get(prodKey).WSP__c;
									titleSumPriceSRP+= pricingMapCA.get(prodKey).SRP__c;
								}
							}
							if(titleSumPriceWSP>0){
								string displaynameStr = displayLabelMap.get(priceName+'WSP');
								if(bundlePrice.WSP__c > titleSumPriceWSP){
									wrapperPriceList.add(new pricingWrapper(displaynameStr, bundlePrice.WSP__c, False, 'Sum of title(s) WSP : '+ titleSumPriceWSP));
								}								
							}
							if(titleSumPriceSRP>0){
								string displaynameStr = displayLabelMap.get(priceName+'SRP');
								if(bundlePrice.SRP__c > titleSumPriceSRP){
									wrapperPriceList.add(new pricingWrapper(displaynameStr, bundlePrice.SRP__c, False, 'Sum of title(s) SRP : '+ titleSumPriceSRP));
								}
							}
						}
					} 
				}
			}
		}
		
		if(wrapperPriceList.isEmpty()) wrapperPriceList.add(new pricingWrapper('PASS', 0, True, 'Validation Pass!'));
		 return wrapperPriceList;
		
	}
    
}