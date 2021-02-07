/**
 *
 * @description This class is a batch for group notifications.
 * It sends notifications to multiple users at same time
 * and takes care of limits i.e sends upto 10K notification events per hour.
 *
 * @see SFNotification
 *
 * @date 2021-02-07
 * @author Manjit Singh
 */
public with sharing class SFNotificationGroupBatch implements Database.Batchable<SObject> {

    String query;
    SFNotificationHelper helper = new SFNotificationHelper();
    Map<String, Id> notificationTypes = helper.getNotificationTypes();
    List<NotificationGroup__c> groups = new List<NotificationGroup__c>();

    public SFNotificationGroupBatch(String query) {
        this.query = query;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<Notification__c> scope) {
        Map<Id, Set<String>> groupWithRecipient = new Map<Id, Set<String>>();
        Map<Id, Set<Id>> groupWithNotification = new Map<Id, Set<Id>>();
        List<Notification__c> notifications = new List<Notification__c>();

        for (Notification__c notification : scope) {
            if (!groupWithRecipient.containsKey(notification.Group__c)) {
                groupWithRecipient.put(notification.Group__c, new Set<String>());
            }
            groupWithRecipient.get(notification.Group__c).add(notification.OwnerId);
            if (!groupWithNotification.containsKey(notification.Group__c)) {
                groupWithNotification.put(notification.Group__c, new Set<Id>());
            }
            groupWithNotification.get(notification.Group__c).add(notification.Id);
        }

        Map<Id, NotificationGroup__c> notificationGroupMap = new Map<Id, NotificationGroup__c>([
                SELECT Title__c,Body__c,TargetId__c, TargetReference__c, NotificationType__c
                FROM NotificationGroup__c
        ]);

        for (Id groupId : groupWithRecipient.keySet()) {
            NotificationGroup__c notificationGroup = notificationGroupMap.get(groupId);
            try {
                helper.createNotifications(notificationTypes.get(notificationGroup.NotificationType__c),
                        notificationGroup.Title__c, notificationGroup.Body__c, notificationGroup.TargetId__c,
                        notificationGroup.TargetReference__c, groupWithRecipient.get(groupId));
                groups.add(new NotificationGroup__c(
                        Id = groupId, Status__c = SFNotificationConstants.SUCCESS, Error__c = null
                ));
                // Update all children of the group as well.
                notifications.addAll(this.updateChildNotifications(
                        groupWithNotification.get(groupId), SFNotificationConstants.SUCCESS
                ));
            } catch (Exception e) {
                groups.add(new NotificationGroup__c(
                        Id = groupId, Status__c = SFNotificationConstants.ERROR,
                        Error__c = e.getMessage() + ' ' + e.getStackTraceString()
                ));
                // Update all children of the group as well.
                notifications.addAll(this.updateChildNotifications(
                        groupWithNotification.get(groupId), SFNotificationConstants.ERROR
                ));
            }
        }
        update groups;
        update notifications;
    }

    private List<Notification__c> updateChildNotifications(Set<Id> notificationIds, String message) {
        List<Notification__c> notifications = new List<Notification__c>();
        for (Id notificationId : notificationIds) {
            notifications.add(new Notification__c(
                    Id = notificationId, Status__c = message
            ));
        }
        return notifications;
    }

    public void finish(Database.BatchableContext bc) {

    }
}