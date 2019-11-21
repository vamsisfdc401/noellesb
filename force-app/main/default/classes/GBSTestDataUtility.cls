/*********************************************************************************************
Class Name: GBSTestDataUtility
Purpose: class for setting up GBS test data
**********************************************************************************************
Version         	DateModified         	ModifiedBy       	Change
1.0             	27/04/2018           	Jay                    	Initial Development
**********************************************************************************************/
public class GBSTestDataUtility{
    
    private static Id agentContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.AGENTCONTACT).getRecordTypeId();
    private static Id licenseeContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.LICENSEECONTACT).getRecordTypeId();
    private static Id factoryContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.FACTORYCONTACT).getRecordTypeId();
    private static Id auditFirmContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.AUDITFIRMCONTACT).getRecordTypeId();
    private static Id tradeOfficeContactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(GBSConstants.TRADEOFFICECONTACT).getRecordTypeId();
    
    
/*****************************************
Method Name: createContact
Purpose: Method to create digital release
*****************************************/    
    public static List<Contact> createContact (Id parent, Integer count, string recordType){
        List<Contact> contactList = new List<Contact>();       
        
        for(integer i=1;i<=count;i++){
            Contact con = new Contact();
            con.FirstName = 'Test ' + i;
            con.LastName = 'Contact' + i;
            con.Phone = '555-555-1212';
            con.Email = 'Test.'+ i + '@test' + i +'.com';
            con.recordTypeID = recordType;
            if(recordType == factoryContactRecTypeId){
                con.Factory__c = parent;
            } else if(recordType == auditFirmContactRecTypeId){
                con.Audit_Firm__c = parent;              
            } else if(recordType == tradeOfficeContactRecTypeId){
                con.Trade_Office__c = parent; 
            } else {
                con.AccountId = parent;
            }
            contactList.add(con);            
        }
        
        return contactList;    
    }
    
/*****************************************
Method Name: createAccount
Purpose: Method to create Account
*****************************************/
    public static List<Account> createAccount(Integer count, string recordType){
        List<Account> accList = new List<Account>();
        for(integer i=1;i<=count;i++){
            Account acc = new Account();
            acc.Name = 'Test ' + i;
            acc.recordTypeID = recordType;
            accList.add(acc);
        }
        return accList;
    }
    
/*****************************************
Method Name: createFactory
Purpose: Method to create Factory
*****************************************/
    public static List<Factory__c> createFactory(Integer count){
        List<Factory__c> factoryList = new List<Factory__c>();
        for(integer i=1;i<=count;i++){
            Factory__c factory = new Factory__c();
            factory.Name = 'Test Factory' + i;
            factoryList.add(factory);
        }
        return factoryList;
    }
    
/*****************************************
Method Name: createTradeOffice
Purpose: Method to create TradeOffice
*****************************************/
    public static List<Trade_Office__c> createTradeOffice(Integer count){
        List<Trade_Office__c> tradeOfficeList = new List<Trade_Office__c>();
        for(integer i=1;i<=count;i++){
            Trade_Office__c tradeOffice = new Trade_Office__c();
            tradeOffice.Name = 'Test Trade Office' + i;
            tradeOfficeList.add(tradeOffice);
        }
        return tradeOfficeList;
    } 
    
/*****************************************
Method Name: createAuditFirm
Purpose: Method to create Audit Firm
*****************************************/
    public static List<Audit_Firm__c> createAuditFirm(Integer count){
        List<Audit_Firm__c> auditFirmList = new List<Audit_Firm__c>();
        for(integer i=1;i<=count;i++){
            Audit_Firm__c auditFirm = new Audit_Firm__c();
            auditFirm.Name = 'Test Audit Firm' + i;
            auditFirmList.add(auditFirm);
        }
        return auditFirmList;
    }
    
/*****************************************
Method Name: createProductRightsGroup
Purpose: Method to create Product Rights Group records
*****************************************/
    public static List<Product_Rights_Group__c> createProductRightsGroup(Id parent,Integer count){
        List<Product_Rights_Group__c> productRightsGroupList = new List<Product_Rights_Group__c>();
        for(integer i=1;i<=count;i++){
            Product_Rights_Group__c productRightsGroup = new Product_Rights_Group__c();
            productRightsGroup.Name = 'Test Product Rights Group' + i;
            productRightsGroup.Contract__c = parent;
            productRightsGroup.Rights_Group_End_Date__c = System.today();
            productRightsGroupList.add(productRightsGroup);
        }
        return productRightsGroupList;
    }

    /*****************************************
Method Name: createContract
Purpose: Method to create GBS Contract records
*****************************************/
    public static List<Contract__c> createContract(Id parent, Integer count){
        List<Contract__c> contractList = new List<Contract__c>();
        for(integer i=1;i<=count;i++){
            Contract__c contracts = new Contract__c();
            contracts.Name = 'Test Contract' + i;
            contracts.Licensee__c = parent;
            contracts.Contract_End_Date__c = System.today() ;
            contractList.add(contracts);
        }
        return contractList;
    }
    
/*****************************************
Method Name: createIP
Purpose: Method to create Intellectual Property records
*****************************************/
    public static List<Intellectual_Property__c> createIP(Integer count){
        List<Intellectual_Property__c> IPList = new List<Intellectual_Property__c>();
        for(integer i=1;i<=count;i++){
            Intellectual_Property__c IP = new Intellectual_Property__c();
            IP.Name = 'Test Product Rights Group' + i;
            IPList.add(IP);
        }
        return IPList;
    }
    
/*****************************************
Method Name: createProductType
Purpose: Method to create Product Type records
*****************************************/
    public static List<Product_Type__c> createProductType(Integer count){
        List<Product_Type__c> productTypeList = new List<Product_Type__c>();
        for(integer i=1;i<=count;i++){
            Product_Type__c productType = new Product_Type__c();
            productType.Name = 'Test Product Type' + i;
            productType.Product_Hierarchy__c = 'Test '+ i;
            productTypeList.add(productType);
        }
        
        return productTypeList;
    }
   
/*****************************************
Method Name: createIPRight
Purpose: Method to create create IP Right records
*****************************************/
    public static List<Intellectual_Property_Right__c> createIPRight(List<Product_Rights_Group__c> productRightsGroupList, List<Intellectual_Property__c> intellectualPropertyList){
        List<Intellectual_Property_Right__c> intellectualPropertyRightList = new List<Intellectual_Property_Right__c>();
        for(Product_Rights_Group__c prg : productRightsGroupList){
            for(Intellectual_Property__c ip : intellectualPropertyList){
            	Intellectual_Property_Right__c intellectualPropertyRight = new Intellectual_Property_Right__c();
            	intellectualPropertyRight.Product_Rights_Group__c = prg.Id;
            	intellectualPropertyRight.Intellectual_Property__c = ip.Id;                
            	intellectualPropertyRightList.add(intellectualPropertyRight);
            }
        }
        
        return intellectualPropertyRightList;
    }    
    /*****************************************
Method Name: createIPRight
Purpose: Method to create create IP Right records
*****************************************/
    public static List<Product_Right__c> createProductRight(List<Product_Rights_Group__c> productRightsGroupList, List<Product_Type__c> productList){
        List<Product_Right__c> productRightList = new List<Product_Right__c>();
        for(Product_Rights_Group__c prg : productRightsGroupList){
            for(Product_Type__c prod : productList){
            	Product_Right__c productRight = new Product_Right__c();
            	productRight.Product_Rights_Group__c = prg.Id;
            	productRight.Product_Type__c = prod.Id;                
            	productRightList.add(productRight);
            }
        }
        
        return productRightList;
    }
    
/*****************************************
Method Name: createLMS
Purpose: Method to create LMS
*****************************************/
    public static List<LMS__c> createLMS(Integer count){
        List<LMS__c> lmsList = new List<LMS__c>();
        for(integer i=1;i<=count;i++){
            LMS__c lms = new LMS__c();
            lms.Notes__c = 'Test LMS'+ i;
            lmsList.add(lms);
        }
        return lmsList;
    }
    
/*****************************************
Method Name: ContractAgentContact
Purpose: Method to create ContractAgentContact
*****************************************/
    public static List<Contract_Agent_Contact__c> createContractAgentContact(Integer count, Id contract, Id contact){
        List<Contract_Agent_Contact__c> contractAgentContactList = new List<Contract_Agent_Contact__c>();
        for(integer i=1;i<=count;i++){
            Contract_Agent_Contact__c contractAgentContact = new Contract_Agent_Contact__c();
            contractAgentContact.Contact__c = contact;
            contractAgentContact.Contract__c = contract;
            contractAgentContactList.add(contractAgentContact);
        }
        return contractAgentContactList;
    }    
}