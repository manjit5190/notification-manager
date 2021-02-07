/**
 *
 * @description This class is a batch for individual notifications.
 * It sends notifications individually and takes care of limits i.e
 * sends upto 10K notification events per hour.
 *
 * @see SFNotification
 *
 * @date 2021-02-07
 * @author Manjit Singh
 */
public with sharing class SFNotificationBatch implements Database.Batchable<SObject> {

    String query;
    SFNotificationHelper helper = new SFNotificationHelper();
    Map<String, Id> notificationTypes = helper.getNotificationTypes();
    List<Notification__c> notifications = new List<Notification__c>();


    public SFNotificationBatch(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<Notification__c> scope) {

        for (Notification__c notification : scope) {
            try {
                helper.createNotifications(notificationTypes.get(notification.NotificationType__c),
                        notification.Title__c, notification.Body__c, notification.TargetId__c,
                        notification.TargetReference__c, new Set<String>{
                                notification.OwnerId
                        });
                notifications.add(new Notification__c(
                        Id = notification.Id, Status__c = SFNotificationConstants.SUCCESS, Error__c = null
                ));
            } catch (Exception e) {
                notifications.add(new Notification__c(
                        Id = notification.Id, Status__c = SFNotificationConstants.ERROR,
                        Error__c = e.getMessage() + ' ' + e.getStackTraceString()
                ));
            }
            update notifications;
        }
    }

    public void finish(Database.BatchableContext bc) {

    }
}