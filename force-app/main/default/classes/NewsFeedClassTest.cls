@isTest
private class NewsFeedClassTest {
    @IsTest
    static void doTest() {
        Title__c title=testClassUtility.createTitle('Test Title',true);
        title.SGENNO__c='000123';
        insert title;
        List<Release__c> lstRel = new List<Release__c>();
        Release__c release=testClassUtility.createRelease('Test Release','Family','New Release Mattel','Materials Not Requested',title.id);
        lstRel.add(release);
        insert lstRel;
        // Build a simple feed item
        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
        testItemList.add(new ConnectApi.FeedItem());
        testItemList.add(new ConnectApi.FeedItem());
        testPage.elements = testItemList;

        // Set the test data
        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(null,
            ConnectApi.FeedType.News, 'me', testPage);

        // The method returns the test page, which we know has two items in it.
        Test.startTest();
        //System.assertEquals(2, chatterOnDateUpdate.chatterOnMaterialDateUpdate(lstRel));
        Test.stopTest();
    }
}