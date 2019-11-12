public with sharing class AccountController {
<<<<<<< HEAD
    /*444444*/

>>>>>>> 3059659e7bd84a207a2a8fe44d32e6d58da0da9d
    @AuraEnabled(cacheable=true)
    public static List<Account> findAccounts(String searchKey) {
        String key = '%' + searchKey + '%';
        return [SELECT Id, Name, AccountNumber FROM Account WHERE Name LIKE :key  LIMIT 10];
    }
}
