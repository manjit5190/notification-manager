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
private with sharing class SFNotificationBatchTest {
    @TestSetup private static void createData() {
        insert new Account(Name = 'SFNotificationSchedulerTest');
    }

    @IsTest private static void batchSuccessTest() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        SFNotification notif = new SFNotification(SFNotificationConstants.DEFAULT_NOTIFICATION_TYPE);

        notif.setRecordId(account.Id).setBody('Body').setTitle('Title')
                .addRecipient(UserInfo.getUserId()).setPriority(1000).enqueue();

        Notification__c notification = [SELECT Status__c FROM Notification__c LIMIT 1];

        System.assertEquals(SFNotificationConstants.QUEUED, notification.Status__c,
                SFNotificationConstants.TEST_MESSAGE_ONE_NOTIF_QUEUED);

        Test.startTest();
        Database.executeBatch(new SFNotificationBatch(SFNotificationConstants.QUERY_BATCH), 200);
        Test.stopTest();
        notification = [
                SELECT Status__c, TargetReference__c, TargetId__c
                FROM Notification__c
                LIMIT 1
        ];

        System.assertEquals(SFNotificationConstants.SUCCESS, notification.Status__c,
                SFNotificationConstants.TEST_MESSAGE_BATCH_SUCCESS);

    }

    @IsTest private static void batchFailureTest() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        SFNotification notif = new SFNotification(SFNotificationConstants.DEFAULT_NOTIFICATION_TYPE);

        notif.setRecordId(account.Id).setBody('Body').setTitle('Title')
                .addRecipient(UserInfo.getUserId()).setPriority(1000).enqueue();

        Notification__c notification = [
                SELECT Status__c, TargetReference__c, TargetId__c, NotificationType__c
                FROM Notification__c
                LIMIT 1
        ];


        System.assertEquals(SFNotificationConstants.QUEUED, notification.Status__c,
                SFNotificationConstants.TEST_MESSAGE_ONE_NOTIF_QUEUED);

        new SFNotificationBatch(SFNotificationConstants.QUERY_BATCH).execute(null, new List<Notification__c>{
                notification
        });

        notification = [
                SELECT Status__c, TargetReference__c, TargetId__c
                FROM Notification__c
                LIMIT 1
        ];

        System.assertEquals(SFNotificationConstants.ERROR, notification.Status__c,
                SFNotificationConstants.TEST_MESSAGE_BATCH_FAILURE);

    }
}