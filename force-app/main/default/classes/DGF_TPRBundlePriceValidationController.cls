public without sharing class DGF_TPRBundlePriceValidationController{ 
	
	public class pricingWrapper{ 
		@AuraEnabled 
		public String titleName;
		
		@AuraEnabled 
		public Decimal USESTSDWSP;
		@AuraEnabled 
		public Decimal USESTSDSRP;
		@AuraEnabled 
		public Decimal USESTHDWSP;
		@AuraEnabled 
		public Decimal USESTHDSRP;
		@AuraEnabled 
		public Decimal USESTUHDWSP;
		@AuraEnabled 
		public Decimal USESTUHDSRP;
		@AuraEnabled 
		public Decimal USEST3DWSP;
		@AuraEnabled 
		public Decimal USEST3DSRP;
		
		@AuraEnabled 
		public Decimal CAESTSDWSP;
		@AuraEnabled 
		public Decimal CAESTSDSRP;
		@AuraEnabled 
		public Decimal CAESTHDWSP;
		@AuraEnabled 
		public Decimal CAESTHDSRP;
		@AuraEnabled 
		public Decimal CAESTUHDWSP;
		@AuraEnabled 
		public Decimal CAESTUHDSRP;	
		@AuraEnabled 
		public Decimal CAEST3DWSP;	
		@AuraEnabled 
		public Decimal CAEST3DSRP;	 	
		
		@AuraEnabled 
		public String USESTSDWSPFlag;
		@AuraEnabled 
		public String USESTSDSRPFlag;
		@AuraEnabled 
		public String USESTHDWSPFlag;
		@AuraEnabled 
		public String USESTHDSRPFlag;
		@AuraEnabled 
		public String USESTUHDWSPFlag;
		@AuraEnabled 
		public String USESTUHDSRPFlag;
		@AuraEnabled 
		public String USEST3DWSPFlag;
		@AuraEnabled 
		public String USEST3DSRPFlag;
		@AuraEnabled 		
		public String CAESTSDWSPFlag;
		@AuraEnabled 		
		public String CAESTSDSRPFlag;
		@AuraEnabled 		 
		public String CAESTHDWSPFlag;
		@AuraEnabled 		 
		public String CAESTHDSRPFlag;
		@AuraEnabled 		 
		public String CAESTUHDWSPFlag;
		@AuraEnabled 		 
		public String CAESTUHDSRPFlag;
		@AuraEnabled 		 
		public String CAEST3DWSPFlag;
		@AuraEnabled 		 
		public String CAEST3DSRPFlag;		
		
		@AuraEnabled 
		public String affectedPromotions;
		
		
		public pricingWrapper(){
			this.titleName = '';
			this.affectedPromotions = '';
		}	
	}
	
	
	public class bundleWrapper{
		@AuraEnabled 
		public String bundleName;	
		@AuraEnabled 
		public String titleNames;	
		@AuraEnabled 
		public boolean validationStatus;
		@AuraEnabled 
		public String suggestedPricingSummaryUS;
		@AuraEnabled 
		public String suggestedPricingSummaryCA;	
		
		@AuraEnabled 
		public List<pricingWrapper> pricingWrapperList;
		
		public bundleWrapper(){
			this.bundleName = '';
			this.validationStatus = true;
			this.suggestedPricingSummaryUS = '';
			this.suggestedPricingSummaryCA = '';
		}
	}
	
	@AuraEnabled 
	public static List<bundleWrapper> validateBundlesInTPR(Id promotionId){	
		system.debug('promoId>>'+ promotionId);
		
		List<bundleWrapper> validBundleWrapper = new List<bundleWrapper>();
		List<bundleWrapper> invalidBundleWrapper = new List<bundleWrapper>();
		set<id> validateBundleSet =  new set<id>();
		set<id> promoProdSet = new set<id>();
		date promoStart;
		date promoEnd;	
		date pricingRecEvalDate;
        set<string> tprTerritorySet = new set<string>();
		
		//map<id, list<pricing__c>> bundlePricingMap =  new map<id, list<pricing__c>>();
		map<product__c, list<id>> bundleTMVersionMap = new map<product__c, list<id>>();
		map<id, list<product__c>> productBundleMap =  new map<id, list<product__c>>();
		map<id, list<pricing__c>> tmProductPricingMap =  new map<id, list<pricing__c>>();
		
		map<id, map<string, pricing__c>> bundlePricingKeyMap =  new map<id, map<string, pricing__c>>();
		map<id, map<string, pricing__c>> titlePricingKeyMap =  new map<id, map<string, pricing__c>>();
		
		set<id> tmVersionSet = new set<id>();
		
		map<id, id>	tmProdMap =  new map<id, id>();
		
		list<Promotion_Product__c> promProdList = [select id, product__c, TPR_Start_Date__c, TPR_End_Date__c, promotion__r.Territory__c, product__r.RecordType.name from Promotion_Product__c where Promotion__c = : promotionId];
		system.debug('promProdList' + promProdList);
		
		if(!promProdList.isEmpty() && promProdList.size()>0){
			promoStart = promProdList[0].TPR_Start_Date__c;
			promoEnd = promProdList[0].TPR_End_Date__c;
			if(promoStart <= system.today()){
				pricingRecEvalDate = system.today();
			}else{
				pricingRecEvalDate = promoStart;
			}
            tprTerritorySet.addAll(promProdList[0].promotion__r.Territory__c.split(';'));
            System.debug('tprTerritorySet' + tprTerritorySet + 'terr>>' + promProdList[0].promotion__r.Territory__c);
			
			for(Promotion_Product__c prod: promProdList){
				if(DGF_Constants.BUNDLE.equalsIgnoreCase(prod.product__r.RecordType.name)){ 
					validateBundleSet.add(prod.product__c);
				}else{
					promoProdSet.add(prod.product__c);
				}
			}
		}
		
		system.debug('promoStart' + promoStart + 'promoEnd' + promoEnd + 'promoProdSet' + promoProdSet);
		
		if(promoProdSet.size()>0){			
			list<product_version__c> tmVersionList = [select id, TM_Version__c from Product_Version__c where Product__c = :promoProdSet ] ;
			
			if(!tmVersionList.isEmpty() && tmVersionList.size()>0 ){
				for(product_version__c tm: tmVersionList){
					tmVersionSet.add(tm.TM_Version__c);
				}
				list<product_version__c> bundleProdList = [select id, TM_Version__c, product__c from Product_Version__c where Product__r.RecordType.name = :DGF_Constants.BUNDLE and TM_Version__c in :tmVersionSet 
						and Product__r.Digital_Release__r.Release_State__c = 'Active' and 
						(Product__r.Digital_Release__r.US_Bundle_Avail_Date__c <= :promoEnd OR Product__r.Digital_Release__r.CA_Bundle_Avail_Date__c <= :promoEnd )];
				
				if(!bundleProdList.isEmpty() && bundleProdList.size()>0){
					for(product_version__c bundleVersion : bundleProdList){
						validateBundleSet.add(bundleVersion.product__c);
					}
				}
			}
		}
		System.debug('BundleSet>>' + validateBundleSet);
		if(validateBundleSet.size()>0){
			
			//list<pricing__c> bundlePricingList = new list<pricing__c>();
			list<Id> titleVersionsList = new list<Id>();
			List<pricingWrapper> wrapperPriceList = new List<pricingWrapper>();
			
			list<product__c> prodList  = [select id, name, Digital_Release__r.US_Bundle_Avail_Date__c, Digital_Release__r.CA_Bundle_Avail_Date__c,
			(select id, name, Resolution__c, Valid_From__c, Valid_To__c, Territory__c, Platform__c, WSP__c, SRP__c, Price_Type__c  from Pricing__r where Account__c =null and ( (Valid_To__c >= :promoStart  and Valid_To__c>= today) or Valid_To__c = null )
			 and Valid_From__c <= :promoEnd and WSP__c !=null  and SRP__c!=null and resolution__c != :DGF_Constants.X3D and Territory__c = :tprTerritorySet and Price_Type__c != :DGF_Constants.TPR_Account order by Price_Type__c desc, territory__c, Resolution__c asc, Valid_From__c asc),
			 (select id, TM_Version__c, product__c from Product_Versions__r) from product__C where id = :validateBundleSet ];
			
			if(!prodList.isEmpty() && prodList.size()>0){
				
				for(product__c bundleProd: prodList){
					list<id> tmIdList = new list<id>();
					for(Product_Version__c pv: bundleProd.Product_Versions__r){ 
						tmIdList.add(pv.TM_Version__c);
						tmVersionSet.add(pv.TM_Version__c);
					}					
					bundleTMVersionMap.put(bundleProd, tmIdList);
				
				
				
				
					if(!bundleProd.Pricing__r.isEmpty()){
						map<string, pricing__c> bundleProdPricingMap =  new map<string, pricing__c>();
						for(pricing__C priceRecord : bundleProd.Pricing__r){
								String key = '';
								key = priceRecord.Territory__c + '' + priceRecord.Platform__c + '' + priceRecord.Resolution__c;
								System.debug('Bundle Price KEYs>>'+ key);
								
								if(!bundleProdPricingMap.containsKey(key)){
									bundleProdPricingMap.put(key, priceRecord);System.debug('bundleProdPricingMap'+ bundleProdPricingMap);
								}else{
									if(bundleProdPricingMap.get(key).Price_Type__c == DGF_Constants.TPR_National){
										if(priceRecord.Price_Type__c == DGF_Constants.TPR_National){
											if(bundleProdPricingMap.get(key).Valid_From__c <= pricingRecEvalDate && priceRecord.Valid_From__c <= pricingRecEvalDate){
												if(bundleProdPricingMap.get(key).srp__c > priceRecord.srp__c){
													bundleProdPricingMap.put(key, priceRecord);
												}
											}else if(priceRecord.Valid_From__c <= pricingRecEvalDate){
												bundleProdPricingMap.put(key, priceRecord);
											}else if(priceRecord.Valid_From__c < bundleProdPricingMap.get(key).Valid_From__c){
												bundleProdPricingMap.put(key, priceRecord);
											}/*else if(bundleProdPricingMap.get(key).srp__c > priceRecord.srp__c){
												bundleProdPricingMap.put(key, priceRecord);
											}*/
										}										
									}else if(bundleProdPricingMap.get(key).Price_Type__c == DGF_Constants.ORIGINAL){ //Existing is Original
											if(priceRecord.Price_Type__c == DGF_Constants.TPR_National){
												bundleProdPricingMap.put(key, priceRecord);
											}
									}else if(bundleProdPricingMap.get(key).Price_Type__c == DGF_Constants.REPRICE){//Existing is Reprice
											if(priceRecord.Price_Type__c == DGF_Constants.TPR_National){
												bundleProdPricingMap.put(key, priceRecord);
											}else if(priceRecord.Price_Type__c == DGF_Constants.REPRICE){//new Reprice has low wsp
												if(bundleProdPricingMap.get(key).Valid_From__c > priceRecord.Valid_From__c){
													bundleProdPricingMap.put(key, priceRecord);
												}
											}else if(priceRecord.Price_Type__c == DGF_Constants.ORIGINAL){ // new Rec is Original
												bundleProdPricingMap.put(key, priceRecord); 
											}
										}							
								}
						}
						bundlePricingKeyMap.put(bundleProd.id, bundleProdPricingMap);
					}
				}
				System.debug('bundlePricingKeyMap>>' + bundlePricingKeyMap);
				
				if(bundleTMVersionMap!=null && bundleTMVersionMap.size()>0){
					//query pricing records
					list<Product_Version__c> prodVersionList = [select id, Product__c, TM_Version__c from  Product_Version__c  where  TM_Version__c = : tmVersionSet  and Product__r.RecordType.Name != :DGF_Constants.BUNDLE and Product__r.RecordType.Name != :DGF_Constants.PRE_ORDER];
					for(Product_Version__c pv : prodVersionList){
						tmProdMap.put(pv.TM_Version__c, pv.Product__c);
					}
					System.debug('tmProdMap' + tmProdMap);
					
					list<product__c> productPricingList = [ select id, name, 
					(select id, product__c, product__r.name, Price_Type__c, WSP__c, SRP__c, Resolution__c, Territory__c,Platform__c , Valid_From__c, Valid_To__c, promotion__c, promotion__r.name
					 	from pricing__r where Account__c =null and platform__C != :DGF_Constants.PLATFORM_VOD 
					 	and ((Valid_To__c >= :promoStart  and Valid_To__c>= today) or Valid_To__c = null ) and Valid_From__c <= :promoEnd and WSP__c !=null  and SRP__c!=null and resolution__c != :DGF_Constants.X3D and Territory__c = :tprTerritorySet and Price_Type__c != :DGF_Constants.TPR_Account
					 	order by Price_Type__c desc, territory__c, Resolution__c asc, Valid_From__c asc) 
					 from product__c where id = :tmProdMap.values() and RecordType.Name != :DGF_Constants.BUNDLE] ; 
					
					if(!productPricingList.isEmpty()){
						for(product__c titleProd: productPricingList){
							
							if(titleProd.Pricing__r!=null){
								map<string, pricing__c> titleProdPricingMap =  new map<string, pricing__c>();
								for(pricing__C priceRecord : titleProd.Pricing__r){
										String key = '';
										key = priceRecord.Territory__c + '' + priceRecord.Platform__c + '' + priceRecord.Resolution__c;
										System.debug('Title KEY>>'+ key + 'priceRecord' + priceRecord.product__r.name);
										
										if(!titleProdPricingMap.containsKey(key)){
											titleProdPricingMap.put(key, priceRecord);
										}else{
											if(titleProdPricingMap.get(key).Price_Type__c == DGF_Constants.TPR_National){
												if(priceRecord.Price_Type__c == DGF_Constants.TPR_National){
													if(titleProdPricingMap.get(key).Valid_From__c <= pricingRecEvalDate && priceRecord.Valid_From__c <= pricingRecEvalDate){
														if(titleProdPricingMap.get(key).srp__c > priceRecord.srp__c){
															titleProdPricingMap.put(key, priceRecord);
														}
													}else if(priceRecord.Valid_From__c < pricingRecEvalDate){
														titleProdPricingMap.put(key, priceRecord);
													}else if(priceRecord.Valid_From__c < titleProdPricingMap.get(key).Valid_From__c){
														titleProdPricingMap.put(key, priceRecord);
													}/*else if(titleProdPricingMap.get(key).srp__c > priceRecord.srp__c){
														titleProdPricingMap.put(key, priceRecord);
													}*/
												}										
											}else if(titleProdPricingMap.get(key).Price_Type__c == DGF_Constants.ORIGINAL){ //Existing is Original
													if(priceRecord.Price_Type__c == DGF_Constants.TPR_National){
														titleProdPricingMap.put(key, priceRecord);
													}
											}else if(titleProdPricingMap.get(key).Price_Type__c == DGF_Constants.REPRICE){//Existing is Reprice
													if(priceRecord.Price_Type__c == DGF_Constants.TPR_National){
														titleProdPricingMap.put(key, priceRecord);
													}else if(priceRecord.Price_Type__c == DGF_Constants.REPRICE){//new Reprice has low wsp
														if(titleProdPricingMap.get(key).Valid_From__c > priceRecord.Valid_From__c){
															titleProdPricingMap.put(key, priceRecord);
														}
													}else if(priceRecord.Price_Type__c == DGF_Constants.ORIGINAL){ // new Rec is Original
														titleProdPricingMap.put(key, priceRecord); 
													}
												}							
										}
								}
								titlePricingKeyMap.put(titleProd.id, titleProdPricingMap);
							}							
						}
					}					
				}
				System.debug('titlePricingKeyMap>>'+titlePricingKeyMap);				
				for(product__c bundle :bundleTMVersionMap.keySet()){
					System.debug('BundleId>>' + bundle);
					if(bundlePricingKeyMap.containsKey(bundle.id)){
						//iterate block and check with pricing recs
						bundleWrapper bw =  new bundleWrapper();
						bw.pricingWrapperList =  new list<pricingWrapper>();
						bw.bundleName = bundle.name;
						boolean isValidBundle = true;
						set<string> titlesInBundleSet = new set<string>();
						
						
						pricingWrapper bundlePW =  new pricingWrapper();
						bundlePW.titleName = 'Bundle Price';
						
						pricingWrapper sumOfTitlePW =  new pricingWrapper();
						sumOfTitlePW.titleName = 'Sum of Titles';
						
						list<pricingWrapper> pricingWrapList = new list<pricingWrapper>();
						map<string, pricingWrapper> pricingWrapMap = new map<string, pricingWrapper>();
						pricingWrapMap.put('BundlePrice', bundlePW);
						pricingWrapMap.put('Sum of Titles', sumOfTitlePW);
						set<string> titleStrSet = new set<string>();
						
						for(string key: bundlePricingKeyMap.get(bundle.id).keyset()){
							decimal bundlePriceWSP = 0;
							decimal bundlePriceSRP = 0;
							decimal sumofTitlesWSP = 0;
							decimal sumofTitlesSRP = 0;	
							
							boolean srpExceeded = false;
							boolean wspExceeded = false;	
												
							String promos = '';							
														
							pricing__c bundlePricing = new pricing__c();
							bundlePricing = bundlePricingKeyMap.get(bundle.id).get(key);
							
							
							for(id tmId : bundleTMVersionMap.get(bundle)){ 
								System.debug('TM ID>>' + tmId + 'KEY in Progress' + key);
								id prodId = tmProdMap.get(tmId);
								System.debug('prodId>>' + prodId);
								system.debug('BundleWrapMap val' + pricingWrapMap);
								pricing__c titlePrice = new pricing__c();
								titlePrice = titlePricingKeyMap.get(prodId).get(key);
								string keyString = '';
								boolean isPromo = false;
								pricingWrapper pw;// = new pricingWrapper();
								
								
								if(titlePrice!=null){
									
									System.debug( 'key' + key + '>>>>>>>>pricingRec' + titlePrice + 'titlePrice.product__r.name' + titlePrice.product__r.name);
								
								
								
									if(!pricingWrapMap.containsKey(titlePrice.product__r.name)){
										pw = new pricingWrapper();
										pw.titleName = titlePrice.product__r.name;
										pricingWrapMap.put(titlePrice.product__r.name, pw);									
									}else{
										System.debug('Key>>>' + key + 'Existing PW' + pw );
										pw = pricingWrapMap.get(titlePrice.product__r.name);
									}
									
									titlesInBundleSet.add(titlePrice.product__r.name);
										
										if(titlePrice.promotion__c!=null){
											isPromo = true;
											if(String.isBlank(pw.affectedPromotions)){										
												pw.affectedPromotions = titlePrice.promotion__r.name;
											}else{
												set<string> promoStrSet = new set<string>();
												for(string str: pw.affectedPromotions.split(',')){
													promoStrSet.add(str.trim());
												}											
												if(!promoStrSet.contains(titlePrice.promotion__r.name))
													pw.affectedPromotions = pw.affectedPromotions + ', ' + titlePrice.promotion__r.name;
											}
										}
										
										if(key.equalsIgnoreCase('USESTSD')){
											pw.USESTSDSRP = titlePrice.srp__c;
											pw.USESTSDWSP = titlePrice.wsp__c;			
											
											bundlePW.USESTSDSRP = bundlePricing.srp__c;
											bundlePW.USESTSDWSP = bundlePricing.wsp__c;
											
											if(isPromo) {
												pw.USESTSDSRPFlag = 'DodgerBlue';
												pw.USESTSDWSPFlag = 'DodgerBlue';
											}															
										}else if(key.equalsIgnoreCase('USESTHD')){
											pw.USESTHDSRP = titlePrice.srp__c;
											pw.USESTHDWSP = titlePrice.wsp__c;		
											
											bundlePW.USESTHDSRP = bundlePricing.srp__c;
											bundlePW.USESTHDWSP = bundlePricing.wsp__c;	
											
											if(isPromo) {
												pw.USESTHDSRPFlag = 'DodgerBlue';
												pw.USESTHDWSPFlag = 'DodgerBlue';
											}							
										}else if(key.equalsIgnoreCase('USESTUHD')){
											pw.USESTUHDSRP = titlePrice.srp__c;
											pw.USESTUHDWSP = titlePrice.wsp__c;
											
											bundlePW.USESTUHDSRP = bundlePricing.srp__c;
											bundlePW.USESTUHDWSP = bundlePricing.wsp__c;	
											
											if(isPromo) {
												pw.USESTUHDSRPFlag = 'DodgerBlue';
												pw.USESTUHDWSPFlag = 'DodgerBlue';
											}								
										}else if(key.equalsIgnoreCase('USEST3D')){
											pw.USEST3DSRP = titlePrice.srp__c;
											pw.USEST3DWSP = titlePrice.wsp__c;	
											
											bundlePW.USEST3DSRP = bundlePricing.srp__c;
											bundlePW.USEST3DWSP = bundlePricing.wsp__c;
											
											if(isPromo) {
												pw.USEST3DSRPFlag = 'DodgerBlue';
												pw.USEST3DWSPFlag = 'DodgerBlue';
											}						
										}else if(key.equalsIgnoreCase('CAESTSD')){
											pw.CAESTSDSRP = titlePrice.srp__c;
											pw.CAESTSDWSP = titlePrice.wsp__c;
											
											bundlePW.CAESTSDSRP = bundlePricing.srp__c;
											bundlePW.CAESTSDWSP = bundlePricing.wsp__c;
											
											if(isPromo) {
												pw.CAESTSDSRPFlag = 'DodgerBlue';
												pw.CAESTSDWSPFlag = 'DodgerBlue';
											}										
										}else if(key.equalsIgnoreCase('CAESTHD')){
											pw.CAESTHDSRP = titlePrice.srp__c;
											pw.CAESTHDWSP = titlePrice.wsp__c;
											
											bundlePW.CAESTHDSRP = bundlePricing.srp__c;
											bundlePW.CAESTHDWSP = bundlePricing.wsp__c;
											
											if(isPromo) {
												pw.CAESTHDSRPFlag = 'DodgerBlue';
												pw.CAESTHDWSPFlag = 'DodgerBlue';
											}									
										}else if(key.equalsIgnoreCase('CAESTUHD')){
											pw.CAESTUHDSRP = titlePrice.srp__c;
											pw.CAESTUHDWSP = titlePrice.wsp__c;	
											
											bundlePW.CAESTUHDSRP = bundlePricing.srp__c;
											bundlePW.CAESTUHDWSP = bundlePricing.wsp__c;
											
											if(isPromo) {
												pw.CAESTUHDSRPFlag = 'DodgerBlue';
												pw.CAESTUHDWSPFlag = 'DodgerBlue';
											}									
										}else if(key.equalsIgnoreCase('CAEST3D')){
											pw.CAEST3DSRP = titlePrice.srp__c;
											pw.CAEST3DWSP = titlePrice.wsp__c;	
											
											bundlePW.CAEST3DSRP = bundlePricing.srp__c;
											bundlePW.CAEST3DWSP = bundlePricing.wsp__c;
											
											if(isPromo) {
												pw.CAEST3DSRPFlag = 'DodgerBlue';
												pw.CAEST3DWSPFlag = 'DodgerBlue';
											}									
										}									
										
										sumofTitlesSRP+=titlePrice.srp__c;
										sumofTitlesWSP+=titlePrice.wsp__c;
										
										System.debug('sumofTitles>>SRP' +sumofTitlesSRP  + 'sumofTitles>>WSP' +  sumofTitlesWSP);
										
										 
									system.debug('END of Iter' + 'KEY' + 'key>>>>' + pw  );
									system.debug('END of Iter' + 'KEY' + 'key>>>>' + bundlePW  );
									
								}
								
								//pricingWrapMap.put(titlePrice.product__r.name, pw);
								}
								
								
								if(bundlePricing.srp__c > sumofTitlesSRP)
									srpExceeded = true;
								if(bundlePricing.wsp__c > sumofTitlesWSP)
									wspExceeded = true;
									
									System.debug('bundlePricing.srp__c' + bundlePricing.srp__c + 'bundlePricing.wsp__c' + bundlePricing.wsp__c);
									System.debug('sumofTitlesWSP' + sumofTitlesWSP + 'sumofTitlesSRP' + sumofTitlesSRP);
								
								if(key.equalsIgnoreCase('USESTSD')){
									sumOfTitlePW.USESTSDSRP = sumofTitlesSRP;
									sumOfTitlePW.USESTSDWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.USESTSDSRPFlag = 'red';
									if(wspExceeded) bundlePW.USESTSDWSPFlag = 'red';			
								}else if(key.equalsIgnoreCase('USESTHD')){
									sumOfTitlePW.USESTHDSRP = sumofTitlesSRP;
									sumOfTitlePW.USESTHDWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.USESTHDSRPFlag = 'red';
									if(wspExceeded) bundlePW.USESTHDWSPFlag = 'red';																
								}else if(key.equalsIgnoreCase('USESTUHD')){
									sumOfTitlePW.USESTUHDSRP = sumofTitlesSRP;
									sumOfTitlePW.USESTUHDWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.USESTUHDSRPFlag = 'red';
									if(wspExceeded) bundlePW.USESTUHDWSPFlag = 'red';
								}else if(key.equalsIgnoreCase('USEST3D')){
									sumOfTitlePW.USEST3DSRP = sumofTitlesSRP;
									sumOfTitlePW.USEST3DWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.USEST3DSRPFlag = 'red';
									if(wspExceeded) bundlePW.USEST3DWSPFlag = 'red';
								}else if(key.equalsIgnoreCase('CAESTSD')){
									sumOfTitlePW.CAESTSDSRP = sumofTitlesSRP;
									sumOfTitlePW.CAESTSDWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.CAESTSDSRPFlag = 'red';
									if(wspExceeded) bundlePW.CAESTSDWSPFlag = 'red';
								}else if(key.equalsIgnoreCase('CAESTHD')){
									sumOfTitlePW.CAESTHDSRP = sumofTitlesSRP;
									sumOfTitlePW.CAESTHDWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.CAESTHDSRPFlag = 'red';
									if(wspExceeded) bundlePW.CAESTHDWSPFlag = 'red';
								}else if(key.equalsIgnoreCase('CAESTUHD')){
									sumOfTitlePW.CAESTUHDSRP = sumofTitlesSRP;
									sumOfTitlePW.CAESTUHDWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.CAESTUHDSRPFlag = 'red';
									if(wspExceeded) bundlePW.CAESTUHDWSPFlag = 'red';
								}else if(key.equalsIgnoreCase('CAEST3D')){
									sumOfTitlePW.CAEST3DSRP = sumofTitlesSRP;
									sumOfTitlePW.CAEST3DWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.CAEST3DSRPFlag = 'red';
									if(wspExceeded) bundlePW.CAEST3DWSPFlag = 'red';
								}	
									
								if(srpExceeded || wspExceeded){
									bw.validationStatus = false;
									if(bundlePricing.territory__C.equalsIgnoreCase(DGF_Constants.TERRITORY_US)){
										if(String.isBlank(bw.suggestedPricingSummaryUS)){
											bw.suggestedPricingSummaryUS = ' (' + bundlePricing.resolution__c + ') ' + '$' + string.valueOf(sumofTitlesSRP-.01);
										}else bw.suggestedPricingSummaryUS = bw.suggestedPricingSummaryUS + ', (' + bundlePricing.resolution__c + ') ' + '$' + string.valueOf(sumofTitlesSRP-.01);
									}else{
										if(String.isBlank(bw.suggestedPricingSummaryCA)){
											bw.suggestedPricingSummaryCA = ' (' + bundlePricing.resolution__c + ') ' + '$' + string.valueOf(sumofTitlesSRP-.01);
										}else bw.suggestedPricingSummaryCA = bw.suggestedPricingSummaryCA + ', (' + bundlePricing.resolution__c + ') ' + '$' + string.valueOf(sumofTitlesSRP-.01);
									} 
									isValidBundle = false;
								}	
						}
						bw.pricingWrapperList = pricingWrapMap.values();
						for(string title: titlesInBundleSet){
							if (string.isBlank(bw.titleNames)){ bw.titleNames  = title; } 
							else {bw.titleNames = bw.titleNames + ', ' + title; }							
						}
						if(!isValidBundle){
							invalidBundleWrapper.add(bw);
						}else{
							validBundleWrapper.add(bw);
						}
					}
				}
				if(!validBundleWrapper.isEmpty()){
					invalidBundleWrapper.addAll(validBundleWrapper);
				}
			}
			
		}
		System.debug('invalidBundleWrapper>>' +invalidBundleWrapper);
		return invalidBundleWrapper;
	}	
	
	public static boolean isiTunesAccount (string AccountId){
		Account selectedAccount = [select id, name from Account where id = : AccountId];
		if (selectedAccount.name.containsIgnoreCase('iTunes')) return true;
		else return false;
	}
	
	public static map<id, set<id>> getPromoAccountMap(list<product__c> prodList){
		set<id> promoIdSet = new set<Id>();
		map<id, set<id>> promoAccountMap = new map<id, set<id>>();
		for(product__c bundleProd: prodList){
			if(!bundleProd.Pricing__r.isEmpty()){
					for(pricing__c priceRec : bundleProd.Pricing__r){
						if (priceRec.promotion__c!=null) promoIdSet.add(priceRec.promotion__c);
					}
				}
				
				if(promoIdSet.size()>0){
					list<promotion__c> promoList = [select id, (select id, account__c from Promotion_Accounts__r) from promotion__c where RecordType.name = : DGF_Constants.ACCOUNT_PROMOTION and id in: promoIdSet];
					if(!promoList.isEmpty()){
						for(promotion__c promoRec : promoList){
							set<id> promSetIds =  new set<id>();
							if(!promoRec.Promotion_Accounts__r.isEmpty()){									
								for(promotion_account__c promoAccount : promoRec.Promotion_Accounts__r){
									promSetIds.add(promoAccount.account__c);
								}
							}
							if(promSetIds.size()>0){
								promoAccountMap.put(promoRec.id, promSetIds);
							}
						}
					}
				}
				
			}
			return 	promoAccountMap;								
	}
	
	
	public static list<pricing__c> filterPricingRecords(list<pricing__c> bundlePricingList){
		list<pricing__c> iTunesFilteredPricingList  = new List<pricing__c>();
		
		for(pricing__c priceRec : bundlePricingList){
			if(priceRec.account__c!=null || priceRec.promotion__c!=null)
			iTunesFilteredPricingList.add(priceRec);
		}
		return iTunesFilteredPricingList;
	}
	
	@AuraEnabled 
	public static List<bundleWrapper> validateBundlesInAccountTPR(Id promotionId, string AccountId){	
		system.debug('promoId>>'+ promotionId + 'AccountId>>' + AccountId);
		
		List<bundleWrapper> validBundleWrapper = new List<bundleWrapper>();
		List<bundleWrapper> invalidBundleWrapper = new List<bundleWrapper>();
		set<id> validateBundleSet =  new set<id>();
		set<id> promoProdSet = new set<id>();
		date promoStart;
		date promoEnd;	
		date pricingRecEvalDate;
        set<string> tprTerritorySet = new set<string>();
        boolean isiTunes = false;
        isiTunes = isiTunesAccount(AccountId);
		
		//map<id, list<pricing__c>> bundlePricingMap =  new map<id, list<pricing__c>>();
		map<id, set<id>> promoAccountMap =  new map<id, set<id>>();
		map<id, set<id>> promoAccountMapForIndTitles =  new map<id, set<id>>();
		map<product__c, list<id>> bundleTMVersionMap = new map<product__c, list<id>>();
		map<id, list<product__c>> productBundleMap =  new map<id, list<product__c>>();
		map<id, list<pricing__c>> tmProductPricingMap =  new map<id, list<pricing__c>>();
		
		map<id, map<string, pricing__c>> bundlePricingKeyMap =  new map<id, map<string, pricing__c>>();
		map<id, map<string, pricing__c>> titlePricingKeyMap =  new map<id, map<string, pricing__c>>();
		
		set<id> tmVersionSet = new set<id>();
		
		map<id, id>	tmProdMap =  new map<id, id>();
		
		list<Promotion_Product__c> promProdList = [select id, product__c, TPR_Start_Date__c, TPR_End_Date__c, promotion__r.Territory__c, product__r.RecordType.name from Promotion_Product__c where Promotion__c = : promotionId];
		system.debug('promProdList' + promProdList);
		
		if(!promProdList.isEmpty() && promProdList.size()>0){
			promoStart = promProdList[0].TPR_Start_Date__c;
			promoEnd = promProdList[0].TPR_End_Date__c;
			if(promoStart <= system.today()){
				pricingRecEvalDate = system.today();
			}else{
				pricingRecEvalDate = promoStart;
			}
            tprTerritorySet.addAll(promProdList[0].promotion__r.Territory__c.split(';'));
            System.debug('tprTerritorySet' + tprTerritorySet + 'terr>>' + promProdList[0].promotion__r.Territory__c);
			
			for(Promotion_Product__c prod: promProdList){
				if(DGF_Constants.BUNDLE.equalsIgnoreCase(prod.product__r.RecordType.name)){ 
					validateBundleSet.add(prod.product__c);
				}else{
					promoProdSet.add(prod.product__c);
				}
			}
		}
		
		system.debug('promoStart' + promoStart + 'promoEnd' + promoEnd + 'promoProdSet' + promoProdSet);
		
		if(promoProdSet.size()>0){			
			list<product_version__c> tmVersionList = [select id, TM_Version__c from Product_Version__c where Product__c = :promoProdSet ] ;
			
			if(!tmVersionList.isEmpty() && tmVersionList.size()>0 ){
				for(product_version__c tm: tmVersionList){
					tmVersionSet.add(tm.TM_Version__c);
				}
				list<product_version__c> bundleProdList = [select id, TM_Version__c, product__c from Product_Version__c where Product__r.RecordType.name = :DGF_Constants.BUNDLE and TM_Version__c in :tmVersionSet 
						and Product__r.Digital_Release__r.Release_State__c = 'Active' and 
						(Product__r.Digital_Release__r.US_Bundle_Avail_Date__c <= :promoEnd OR Product__r.Digital_Release__r.CA_Bundle_Avail_Date__c <= :promoEnd )];
				
				if(!bundleProdList.isEmpty() && bundleProdList.size()>0){
					for(product_version__c bundleVersion : bundleProdList){
						validateBundleSet.add(bundleVersion.product__c);
					}
				}
			}
		}
		System.debug('BundleSet>>' + validateBundleSet);
		if(validateBundleSet.size()>0){
			
			//list<pricing__c> bundlePricingList = new list<pricing__c>();
			list<Id> titleVersionsList = new list<Id>();
			List<pricingWrapper> wrapperPriceList = new List<pricingWrapper>();
			list<product__c> prodList;
			
			if(isiTunes){
				prodList  = [select id, name, Digital_Release__r.US_Bundle_Avail_Date__c, Digital_Release__r.CA_Bundle_Avail_Date__c,
				(select id, name, Account__c, Resolution__c, Valid_From__c, Valid_To__c, Territory__c, Platform__c, WSP__c, SRP__c, Price_Type__c, promotion__c  from Pricing__r where ( (Valid_To__c >= :promoStart  and Valid_To__c>= today) or Valid_To__c = null )
				 and Valid_From__c <= :promoEnd and WSP__c !=null  and SRP__c!=null and resolution__c != :DGF_Constants.X3D and Territory__c = :tprTerritorySet and  Price_Type__c != :DGF_Constants.TPR_National order by Price_Type__c desc, territory__c, Resolution__c asc, Valid_From__c asc),
				 (select id, TM_Version__c, product__c from Product_Versions__r) from product__C where id = :validateBundleSet ];
			}else{
				prodList  = [select id, name, Digital_Release__r.US_Bundle_Avail_Date__c, Digital_Release__r.CA_Bundle_Avail_Date__c,
				(select id, name, Resolution__c, Valid_From__c, Valid_To__c, Territory__c, Platform__c, WSP__c, SRP__c, Price_Type__c, promotion__c  from Pricing__r where Account__c =null and ( (Valid_To__c >= :promoStart  and Valid_To__c>= today) or Valid_To__c = null )
				 and Valid_From__c <= :promoEnd and WSP__c !=null  and SRP__c!=null and resolution__c != :DGF_Constants.X3D and Territory__c = :tprTerritorySet and Price_Type__c != :DGF_Constants.TPR_National order by Price_Type__c desc, territory__c, Resolution__c asc, Valid_From__c asc),
				 (select id, TM_Version__c, product__c from Product_Versions__r) from product__C where id = :validateBundleSet ];
			}
			
			
			
			if(!prodList.isEmpty() && prodList.size()>0){
				
				promoAccountMap = getPromoAccountMap(prodList);				
				System.debug('promoAccountMap>>' + promoAccountMap);
				
				for(product__c bundleProd: prodList){
					list<id> tmIdList = new list<id>();
					for(Product_Version__c pv: bundleProd.Product_Versions__r){ 
						tmIdList.add(pv.TM_Version__c);
						tmVersionSet.add(pv.TM_Version__c);
					}					
					bundleTMVersionMap.put(bundleProd, tmIdList);
				
				
					if(!bundleProd.Pricing__r.isEmpty()){
						map<string, pricing__c> bundleProdPricingMap =  new map<string, pricing__c>();
						boolean hasiTunesPricingRecords = false;
						list<pricing__c> bundlePricingRecordList = new List<pricing__c>();
						
						if(isiTunes){
							for(pricing__C priceRecord : bundleProd.Pricing__r){
								if(priceRecord.account__c!=null){
									hasiTunesPricingRecords = true;
									break;
								}
							}
							if(hasiTunesPricingRecords){
								bundlePricingRecordList  = filterPricingRecords(bundleProd.Pricing__r);
							}else{
								bundlePricingRecordList = bundleProd.Pricing__r;
							}
						}else{
							bundlePricingRecordList = bundleProd.Pricing__r;
						}						
						
						for(pricing__C priceRecord : bundlePricingRecordList){
								String key = '';
								key = priceRecord.Territory__c + '' + priceRecord.Platform__c + '' + priceRecord.Resolution__c;
								System.debug('Bundle Price KEYs>>'+ key);
								
								if(!bundleProdPricingMap.containsKey(key)){
									if(priceRecord.Price_Type__c == DGF_Constants.TPR_Account){
										if(promoAccountMap.get(priceRecord.promotion__c).contains(AccountId))
											bundleProdPricingMap.put(key, priceRecord);
									}else{
										bundleProdPricingMap.put(key, priceRecord);
									}									
								}else{
									if(bundleProdPricingMap.get(key).Price_Type__c == DGF_Constants.TPR_Account){
										if(priceRecord.Price_Type__c == DGF_Constants.TPR_Account && promoAccountMap.get(priceRecord.promotion__c).contains(AccountId)){
											if(bundleProdPricingMap.get(key).Valid_From__c <= pricingRecEvalDate && priceRecord.Valid_From__c <= pricingRecEvalDate){
												if(bundleProdPricingMap.get(key).srp__c > priceRecord.srp__c){
													bundleProdPricingMap.put(key, priceRecord);
												}
											}else if(priceRecord.Valid_From__c < pricingRecEvalDate){
												bundleProdPricingMap.put(key, priceRecord);
											}else if(priceRecord.Valid_From__c < bundleProdPricingMap.get(key).Valid_From__c){
												bundleProdPricingMap.put(key, priceRecord);
											}/*else if(bundleProdPricingMap.get(key).srp__c > priceRecord.srp__c){
												bundleProdPricingMap.put(key, priceRecord);
											}*/
										}										
									}else if(bundleProdPricingMap.get(key).Price_Type__c == DGF_Constants.ORIGINAL){ //Existing is Original
											if(priceRecord.Price_Type__c == DGF_Constants.TPR_Account && promoAccountMap.get(priceRecord.promotion__c).contains(AccountId)){
												bundleProdPricingMap.put(key, priceRecord);
											}
									}else if(bundleProdPricingMap.get(key).Price_Type__c == DGF_Constants.REPRICE){//Existing is Reprice
											if(priceRecord.Price_Type__c == DGF_Constants.TPR_Account && promoAccountMap.get(priceRecord.promotion__c).contains(AccountId)){
												bundleProdPricingMap.put(key, priceRecord);
											}else if(priceRecord.Price_Type__c == DGF_Constants.REPRICE){//new Reprice has low wsp
												if(bundleProdPricingMap.get(key).Valid_From__c > priceRecord.Valid_From__c){
													bundleProdPricingMap.put(key, priceRecord);
												}
											}else if(priceRecord.Price_Type__c == DGF_Constants.ORIGINAL){ // new Rec is Original
												bundleProdPricingMap.put(key, priceRecord); 
											}
										}							
								}
						}
						bundlePricingKeyMap.put(bundleProd.id, bundleProdPricingMap);
					}
				}
				System.debug('bundlePricingKeyMap>>' + bundlePricingKeyMap);
				
				if(bundleTMVersionMap!=null && bundleTMVersionMap.size()>0){
					//query pricing records
					list<Product_Version__c> prodVersionList = [select id, Product__c, TM_Version__c from  Product_Version__c  where  TM_Version__c = : tmVersionSet  and Product__r.RecordType.Name != :DGF_Constants.BUNDLE and Product__r.RecordType.Name != :DGF_Constants.PRE_ORDER];
					for(Product_Version__c pv : prodVersionList){
						tmProdMap.put(pv.TM_Version__c, pv.Product__c);
					}
					System.debug('tmProdMap' + tmProdMap);
					
					list<product__c> productPricingList;
					if(isiTunes){
						productPricingList= [ select id, name, 
							(select id, product__c, account__c, product__r.name, Price_Type__c, WSP__c, SRP__c, Resolution__c, Territory__c,Platform__c , Valid_From__c, Valid_To__c, promotion__c, promotion__r.name
							 	from pricing__r where Account__c !=null and platform__c != :DGF_Constants.PLATFORM_VOD 
							 	and ((Valid_To__c >= :promoStart  and Valid_To__c>= today) or Valid_To__c = null ) and Valid_From__c <= :promoEnd and WSP__c !=null  and SRP__c!=null and resolution__c != :DGF_Constants.X3D and Territory__c = :tprTerritorySet and Price_Type__c != :DGF_Constants.TPR_National
							 	order by Price_Type__c desc, territory__c, Resolution__c asc, Valid_From__c asc) 
							 from product__c where id = :tmProdMap.values() and RecordType.Name != :DGF_Constants.BUNDLE] ;	
					}else{
						productPricingList= [ select id, name, 
							(select id, product__c, product__r.name, Price_Type__c, WSP__c, SRP__c, Resolution__c, Territory__c,Platform__c , Valid_From__c, Valid_To__c, promotion__c, promotion__r.name
							 	from pricing__r where Account__c =null and Price_Type__c!=:DGF_Constants.TPR_National and platform__C != :DGF_Constants.PLATFORM_VOD 
							 	and ((Valid_To__c >= :promoStart  and Valid_To__c>= today) or Valid_To__c = null ) and Valid_From__c <= :promoEnd and WSP__c !=null  and SRP__c!=null and resolution__c != :DGF_Constants.X3D and Territory__c = :tprTerritorySet and Price_Type__c != :DGF_Constants.TPR_National
							 	order by Price_Type__c desc, territory__c, Resolution__c asc, Valid_From__c asc) 
							 from product__c where id = :tmProdMap.values() and RecordType.Name != :DGF_Constants.BUNDLE] ;
					} 
					 
					
					if(!productPricingList.isEmpty()){
						
							promoAccountMapForIndTitles = getPromoAccountMap(productPricingList);				
							System.debug('promoAccountMapForIndTitles>>' + promoAccountMapForIndTitles);
				
				
						for(product__c titleProd: productPricingList){
							
							if(titleProd.Pricing__r!=null){
								map<string, pricing__c> titleProdPricingMap =  new map<string, pricing__c>();
								for(pricing__C priceRecord : titleProd.Pricing__r){
										String key = '';
										key = priceRecord.Territory__c + '' + priceRecord.Platform__c + '' + priceRecord.Resolution__c;
										System.debug('Title KEY>>'+ key + 'priceRecord' + priceRecord.product__r.name);
										
										if(!titleProdPricingMap.containsKey(key)){
											//titleProdPricingMap.put(key, priceRecord);
											if(priceRecord.Price_Type__c == DGF_Constants.TPR_Account){
												if(promoAccountMapForIndTitles.get(priceRecord.promotion__c).contains(AccountId))
													titleProdPricingMap.put(key, priceRecord);
											}else{
												titleProdPricingMap.put(key, priceRecord);
											}
										}else{
											if(titleProdPricingMap.get(key).Price_Type__c == DGF_Constants.TPR_Account ){
												if(priceRecord.Price_Type__c == DGF_Constants.TPR_Account && promoAccountMapForIndTitles.get(priceRecord.promotion__c).contains(AccountId)){
													if(titleProdPricingMap.get(key).Valid_From__c <= pricingRecEvalDate && priceRecord.Valid_From__c <= pricingRecEvalDate){
														if(titleProdPricingMap.get(key).srp__c > priceRecord.srp__c){
															titleProdPricingMap.put(key, priceRecord);
														}
													}else if(priceRecord.Valid_From__c < pricingRecEvalDate){
														titleProdPricingMap.put(key, priceRecord);
													}else if(priceRecord.Valid_From__c < titleProdPricingMap.get(key).Valid_From__c){
														titleProdPricingMap.put(key, priceRecord);
													}/*else if(titleProdPricingMap.get(key).srp__c > priceRecord.srp__c){
														titleProdPricingMap.put(key, priceRecord);
													}*/
												}										
											}else if(titleProdPricingMap.get(key).Price_Type__c == DGF_Constants.ORIGINAL){ //Existing is Original
													if(priceRecord.Price_Type__c == DGF_Constants.TPR_Account && promoAccountMapForIndTitles.get(priceRecord.promotion__c).contains(AccountId)){
														titleProdPricingMap.put(key, priceRecord);
													}
											}else if(titleProdPricingMap.get(key).Price_Type__c == DGF_Constants.REPRICE){//Existing is Reprice
													if(priceRecord.Price_Type__c == DGF_Constants.TPR_Account && promoAccountMapForIndTitles.get(priceRecord.promotion__c).contains(AccountId)){
														titleProdPricingMap.put(key, priceRecord);
													}else if(priceRecord.Price_Type__c == DGF_Constants.REPRICE){//new Reprice has low wsp
														if(titleProdPricingMap.get(key).Valid_From__c > priceRecord.Valid_From__c){
															titleProdPricingMap.put(key, priceRecord);
														}
													}else if(priceRecord.Price_Type__c == DGF_Constants.ORIGINAL){ // new Rec is Original
														titleProdPricingMap.put(key, priceRecord); 
													}
												}							
										}
								}
								titlePricingKeyMap.put(titleProd.id, titleProdPricingMap);
							}							
						}
					}					
				}
				System.debug('titlePricingKeyMap>>'+titlePricingKeyMap);				
				for(product__c bundle :bundleTMVersionMap.keySet()){
					System.debug('BundleId>>' + bundle);
					if(bundlePricingKeyMap.containsKey(bundle.id)){
						//iterate block and check with pricing recs
						bundleWrapper bw =  new bundleWrapper();
						bw.pricingWrapperList =  new list<pricingWrapper>();
						bw.bundleName = bundle.name;
						boolean isValidBundle = true;
						set<string> titlesInBundleSet = new set<string>();
						
						
						pricingWrapper bundlePW =  new pricingWrapper();
						bundlePW.titleName = 'Bundle Price';
						
						pricingWrapper sumOfTitlePW =  new pricingWrapper();
						sumOfTitlePW.titleName = 'Sum of Titles';
						
						list<pricingWrapper> pricingWrapList = new list<pricingWrapper>();
						map<string, pricingWrapper> pricingWrapMap = new map<string, pricingWrapper>();
						pricingWrapMap.put('BundlePrice', bundlePW);
						pricingWrapMap.put('Sum of Titles', sumOfTitlePW);
						set<string> titleStrSet = new set<string>();
						
						for(string key: bundlePricingKeyMap.get(bundle.id).keyset()){
							decimal bundlePriceWSP = 0;
							decimal bundlePriceSRP = 0;
							decimal sumofTitlesWSP = 0;
							decimal sumofTitlesSRP = 0;	
							
							boolean srpExceeded = false;
							boolean wspExceeded = false;	
												
							String promos = '';							
														
							pricing__c bundlePricing = new pricing__c();
							bundlePricing = bundlePricingKeyMap.get(bundle.id).get(key);
							
							
							for(id tmId : bundleTMVersionMap.get(bundle)){ 
								System.debug('TM ID>>' + tmId + 'KEY in Progress' + key);
								id prodId = tmProdMap.get(tmId);
								System.debug('prodId>>' + prodId);
								system.debug('BundleWrapMap val' + pricingWrapMap);
								pricing__c titlePrice = new pricing__c();
								titlePrice = titlePricingKeyMap.get(prodId).get(key);
								string keyString = '';
								boolean isPromo = false;
								pricingWrapper pw;// = new pricingWrapper();
								
								if(titlePrice !=null){
									System.debug( 'key' + key + '>>>>>>>>pricingRec' + titlePrice + 'titlePrice.product__r.name' + titlePrice.product__r.name);
								
									
									
									if(!pricingWrapMap.containsKey(titlePrice.product__r.name)){
										pw = new pricingWrapper();
										pw.titleName = titlePrice.product__r.name;
										pricingWrapMap.put(titlePrice.product__r.name, pw);									
									}else{
										System.debug('Key>>>' + key + 'Existing PW' + pw );
										pw = pricingWrapMap.get(titlePrice.product__r.name);
									}
									
									titlesInBundleSet.add(titlePrice.product__r.name);
																		
										if(titlePrice.promotion__c!=null){
											isPromo = true;
											if(String.isBlank(pw.affectedPromotions)){										
												pw.affectedPromotions = titlePrice.promotion__r.name;
											}else{
												set<string> promoStrSet = new set<string>();
												for(string str: pw.affectedPromotions.split(',')){
													promoStrSet.add(str.trim());
												}											
												if(!promoStrSet.contains(titlePrice.promotion__r.name))
													pw.affectedPromotions = pw.affectedPromotions + ', ' + titlePrice.promotion__r.name;
											}
										}
										
										if(key.equalsIgnoreCase('USESTSD')){
											pw.USESTSDSRP = titlePrice.srp__c;
											pw.USESTSDWSP = titlePrice.wsp__c;			
											
											bundlePW.USESTSDSRP = bundlePricing.srp__c;
											bundlePW.USESTSDWSP = bundlePricing.wsp__c;
											
											if(isPromo) {
												pw.USESTSDSRPFlag = 'DodgerBlue';
												pw.USESTSDWSPFlag = 'DodgerBlue';
											}															
										}else if(key.equalsIgnoreCase('USESTHD')){
											pw.USESTHDSRP = titlePrice.srp__c;
											pw.USESTHDWSP = titlePrice.wsp__c;		
											
											bundlePW.USESTHDSRP = bundlePricing.srp__c;
											bundlePW.USESTHDWSP = bundlePricing.wsp__c;	
											
											if(isPromo) {
												pw.USESTHDSRPFlag = 'DodgerBlue';
												pw.USESTHDWSPFlag = 'DodgerBlue';
											}							
										}else if(key.equalsIgnoreCase('USESTUHD')){
											pw.USESTUHDSRP = titlePrice.srp__c;
											pw.USESTUHDWSP = titlePrice.wsp__c;
											
											bundlePW.USESTUHDSRP = bundlePricing.srp__c;
											bundlePW.USESTUHDWSP = bundlePricing.wsp__c;	
											
											if(isPromo) {
												pw.USESTUHDSRPFlag = 'DodgerBlue';
												pw.USESTUHDWSPFlag = 'DodgerBlue';
											}								
										}else if(key.equalsIgnoreCase('USEST3D')){
											pw.USEST3DSRP = titlePrice.srp__c;
											pw.USEST3DWSP = titlePrice.wsp__c;	
											
											bundlePW.USEST3DSRP = bundlePricing.srp__c;
											bundlePW.USEST3DWSP = bundlePricing.wsp__c;
											
											if(isPromo) {
												pw.USEST3DSRPFlag = 'DodgerBlue';
												pw.USEST3DWSPFlag = 'DodgerBlue';
											}						
										}else if(key.equalsIgnoreCase('CAESTSD')){
											pw.CAESTSDSRP = titlePrice.srp__c;
											pw.CAESTSDWSP = titlePrice.wsp__c;
											
											bundlePW.CAESTSDSRP = bundlePricing.srp__c;
											bundlePW.CAESTSDWSP = bundlePricing.wsp__c;
											
											if(isPromo) {
												pw.CAESTSDSRPFlag = 'DodgerBlue';
												pw.CAESTSDWSPFlag = 'DodgerBlue';
											}										
										}else if(key.equalsIgnoreCase('CAESTHD')){
											pw.CAESTHDSRP = titlePrice.srp__c;
											pw.CAESTHDWSP = titlePrice.wsp__c;
											
											bundlePW.CAESTHDSRP = bundlePricing.srp__c;
											bundlePW.CAESTHDWSP = bundlePricing.wsp__c;
											
											if(isPromo) {
												pw.CAESTHDSRPFlag = 'DodgerBlue';
												pw.CAESTHDWSPFlag = 'DodgerBlue';
											}									
										}else if(key.equalsIgnoreCase('CAESTUHD')){
											pw.CAESTUHDSRP = titlePrice.srp__c;
											pw.CAESTUHDWSP = titlePrice.wsp__c;	
											
											bundlePW.CAESTUHDSRP = bundlePricing.srp__c;
											bundlePW.CAESTUHDWSP = bundlePricing.wsp__c;
											
											if(isPromo) {
												pw.CAESTUHDSRPFlag = 'DodgerBlue';
												pw.CAESTUHDWSPFlag = 'DodgerBlue';
											}									
										}else if(key.equalsIgnoreCase('CAEST3D')){
											pw.CAEST3DSRP = titlePrice.srp__c;
											pw.CAEST3DWSP = titlePrice.wsp__c;	
											
											bundlePW.CAEST3DSRP = bundlePricing.srp__c;
											bundlePW.CAEST3DWSP = bundlePricing.wsp__c;
											
											if(isPromo) {
												pw.CAEST3DSRPFlag = 'DodgerBlue';
												pw.CAEST3DWSPFlag = 'DodgerBlue';
											}									
										}									
										
										sumofTitlesSRP+=titlePrice.srp__c;
										sumofTitlesWSP+=titlePrice.wsp__c;
										
										System.debug('sumofTitles>>SRP' +sumofTitlesSRP  + 'sumofTitles>>WSP' +  sumofTitlesWSP);
										
										 
									system.debug('END of Iter' + 'KEY' + 'key>>>>' + pw  );
									system.debug('END of Iter' + 'KEY' + 'key>>>>' + bundlePW  );
								}
								
								
								//pricingWrapMap.put(titlePrice.product__r.name, pw);
							}
								
								
								if(bundlePricing.srp__c > sumofTitlesSRP)
									srpExceeded = true;
								if(bundlePricing.wsp__c > sumofTitlesWSP)
									wspExceeded = true;
									
									System.debug('bundlePricing.srp__c' + bundlePricing.srp__c + 'bundlePricing.wsp__c' + bundlePricing.wsp__c);
									System.debug('sumofTitlesWSP' + sumofTitlesWSP + 'sumofTitlesSRP' + sumofTitlesSRP);
								
								if(key.equalsIgnoreCase('USESTSD')){
									sumOfTitlePW.USESTSDSRP = sumofTitlesSRP;
									sumOfTitlePW.USESTSDWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.USESTSDSRPFlag = 'red';
									if(wspExceeded) bundlePW.USESTSDWSPFlag = 'red';			
								}else if(key.equalsIgnoreCase('USESTHD')){
									sumOfTitlePW.USESTHDSRP = sumofTitlesSRP;
									sumOfTitlePW.USESTHDWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.USESTHDSRPFlag = 'red';
									if(wspExceeded) bundlePW.USESTHDWSPFlag = 'red';																
								}else if(key.equalsIgnoreCase('USESTUHD')){
									sumOfTitlePW.USESTUHDSRP = sumofTitlesSRP;
									sumOfTitlePW.USESTUHDWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.USESTUHDSRPFlag = 'red';
									if(wspExceeded) bundlePW.USESTUHDWSPFlag = 'red';
								}else if(key.equalsIgnoreCase('USEST3D')){
									sumOfTitlePW.USEST3DSRP = sumofTitlesSRP;
									sumOfTitlePW.USEST3DWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.USEST3DSRPFlag = 'red';
									if(wspExceeded) bundlePW.USEST3DWSPFlag = 'red';
								}else if(key.equalsIgnoreCase('CAESTSD')){
									sumOfTitlePW.CAESTSDSRP = sumofTitlesSRP;
									sumOfTitlePW.CAESTSDWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.CAESTSDSRPFlag = 'red';
									if(wspExceeded) bundlePW.CAESTSDWSPFlag = 'red';
								}else if(key.equalsIgnoreCase('CAESTHD')){
									sumOfTitlePW.CAESTHDSRP = sumofTitlesSRP;
									sumOfTitlePW.CAESTHDWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.CAESTHDSRPFlag = 'red';
									if(wspExceeded) bundlePW.CAESTHDWSPFlag = 'red';
								}else if(key.equalsIgnoreCase('CAESTUHD')){
									sumOfTitlePW.CAESTUHDSRP = sumofTitlesSRP;
									sumOfTitlePW.CAESTUHDWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.CAESTUHDSRPFlag = 'red';
									if(wspExceeded) bundlePW.CAESTUHDWSPFlag = 'red';
								}else if(key.equalsIgnoreCase('CAEST3D')){
									sumOfTitlePW.CAEST3DSRP = sumofTitlesSRP;
									sumOfTitlePW.CAEST3DWSP = sumofTitlesWSP;
									if(srpExceeded) bundlePW.CAEST3DSRPFlag = 'red';
									if(wspExceeded) bundlePW.CAEST3DWSPFlag = 'red';
								}		
									
								if(srpExceeded || wspExceeded){
									bw.validationStatus = false;
									if(bundlePricing.territory__C.equalsIgnoreCase(DGF_Constants.TERRITORY_US)){
										if(String.isBlank(bw.suggestedPricingSummaryUS)){
											bw.suggestedPricingSummaryUS = ' (' + bundlePricing.resolution__c + ') ' + '$' + string.valueOf(sumofTitlesSRP-.01);
										}else bw.suggestedPricingSummaryUS = bw.suggestedPricingSummaryUS + ', (' + bundlePricing.resolution__c + ') ' + '$' + string.valueOf(sumofTitlesSRP-.01);
									}else{
										if(String.isBlank(bw.suggestedPricingSummaryCA)){
											bw.suggestedPricingSummaryCA = ' (' + bundlePricing.resolution__c + ') ' + '$' + string.valueOf(sumofTitlesSRP-.01);
										}else bw.suggestedPricingSummaryCA = bw.suggestedPricingSummaryCA + ', (' + bundlePricing.resolution__c + ') ' + '$' + string.valueOf(sumofTitlesSRP-.01);
									} 
									isValidBundle = false;
								}	
						}
						bw.pricingWrapperList = pricingWrapMap.values();
						for(string title: titlesInBundleSet){
							if (string.isBlank(bw.titleNames)){ bw.titleNames  = title; } 
							else {bw.titleNames = bw.titleNames + ', ' + title; }							
						}
						if(!isValidBundle){
							invalidBundleWrapper.add(bw);
						}else{
							validBundleWrapper.add(bw);
						}
					}
				}
				if(!validBundleWrapper.isEmpty()){
					invalidBundleWrapper.addAll(validBundleWrapper);
				}
			}
			
		}
		System.debug('invalidBundleWrapper>>' +invalidBundleWrapper);
		return invalidBundleWrapper;
	}
	
    @AuraEnabled
    public static list<Promotion_Account__c> getPromotionAccounts(string promotionId){
        list<Promotion_Account__c> lstPromAccounts = new list<Promotion_Account__c>();
        for(Promotion__c prom : [select id,(select id,Promotion__c,Account__c,Account__r.Name from Promotion_Accounts__r) from Promotion__c where id=:promotionId]){
            if(prom.Promotion_Accounts__r.size()>0){
               return  prom.Promotion_Accounts__r;
            } 
        }
        return null;
    }
    @AuraEnabled
    public static promotion__c getRecTypeName(string recId){
       promotion__c promo =  [select id,Name,Start_Date__c,End_Date__c,recordtype.name from promotion__c where id=:recId];system.debug('promo '+promo);
       return promo;
    }
	
}