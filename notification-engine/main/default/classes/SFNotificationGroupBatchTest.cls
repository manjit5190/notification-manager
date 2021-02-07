/**
 *
 * @description Test class for SFNotificationBatch
 *
 * @see SFNotificationBatch
 *
 * @date 2021-02-07
 * @author Manjit Singh
 */
@IsTest(SeeAllData=false)
private with sharing class SFNotificationGroupBatchTest {
    @TestSetup private static void createData() {
        insert new Account(Name = 'SFNotificationSchedulerTest');
    }

    @IsTest private static void batchSuccessTest() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        SFNotification notif = new SFNotification(SFNotificationConstants.DEFAULT_NOTIFICATION_TYPE,
                'Test Group', 'Title', 'Body');

        notif.setRecordId(account.Id).addRecipient(UserInfo.getUserId()).setPriority(1000).enqueue();

        NotificationGroup__c notificationGroup = [SELECT Status__c FROM NotificationGroup__c LIMIT 1];

        System.assertEquals(SFNotificationConstants.QUEUED, notificationGroup.Status__c,
                SFNotificationConstants.TEST_MESSAGE_ONE_GROUP_CREATED);
        Test.startTest();
        Database.executeBatch(new SFNotificationGroupBatch(SFNotificationConstants.QUERY_GROUP_BATCH), 200);
        Test.stopTest();
        notificationGroup = [SELECT Status__c FROM NotificationGroup__c LIMIT 1];

        System.assertEquals(SFNotificationConstants.SUCCESS, notificationGroup.Status__c,
                SFNotificationConstants.TEST_MESSAGE_BATCH_SUCCESS);

    }
}