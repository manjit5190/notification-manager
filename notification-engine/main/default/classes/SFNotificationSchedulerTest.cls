/**
 *
 * @description Test class for SFNotificationScheduler
 *
 * @see SFNotificationScheduler
 *
 * @date 2021-02-07
 * @author Manjit Singh
 */
@IsTest(SeeAllData=false)
private with sharing class SFNotificationSchedulerTest {
    @TestSetup private static void createData() {
        insert new Account(Name = 'SFNotificationSchedulerTest');
    }

    @IsTest private static void schedulerTest() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        SFNotification notif = new SFNotification(SFNotificationConstants.DEFAULT_NOTIFICATION_TYPE);

        notif.setRecordId(account.Id).setBody('Body').setTitle('Title')
                .addRecipient(UserInfo.getUserId()).setPriority(1000).enqueue();

        Notification__c notification = [SELECT Status__c FROM Notification__c LIMIT 1];

        System.assertEquals(SFNotificationConstants.QUEUED, notification.Status__c,
                SFNotificationConstants.TEST_MESSAGE_ONE_NOTIF_QUEUED);

        Test.startTest();
        System.schedule('Notifications Helper', '0 0 0/1 1/1 * ? *', new SFNotificationScheduler(400));
        Test.stopTest();

    }
}