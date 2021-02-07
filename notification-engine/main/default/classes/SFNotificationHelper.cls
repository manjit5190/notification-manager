/**
 *
 * @description This class is a helper and provides methods for
 * batch classes and SFNotification class
 *
 * @see SFNotification
 *
 * @date 2021-02-07
 * @author Manjit Singh
 */

public with sharing class SFNotificationHelper {

    public NotificationGroup__c createGroupIfNotExisting(String groupName, String notificationType, String title, String body, Id targetId, String pageRef) {
        List<NotificationGroup__c> groups = [
                SELECT Id, Name
                FROM NotificationGroup__c
                WHERE Name = :groupName
        ];

        if (groups.isEmpty()) {
            NotificationGroup__c notificationGroup = new NotificationGroup__c(
                    Name = groupName, Title__c = title, Body__c = body,
                    Status__c = SFNotificationConstants.QUEUED,
                    NotificationType__c = notificationType, TargetId__c = targetId,
                    TargetReference__c = pageRef
            );
            insert notificationGroup;
            return notificationGroup;
        }
        return groups.get(0);
    }

    public void createNotifications(Id notificationId, String title, String body, Id recordId, String pageRef, Set<String> recipientsIds) {
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(title);
        notification.setBody(body);
        notification.setNotificationTypeId(notificationId);
        notification.setTargetId(recordId);
        notification.setTargetPageRef(pageRef);
        notification.send(recipientsIds);
    }

    public Map<String, Id> getNotificationTypes() {
        Map<String, Id> notificationTypes = new Map<String, Id>();
        for (CustomNotificationType customNotificationType : [
                SELECT Id, DeveloperName,
                        CustomNotifTypeName
                FROM CustomNotificationType
        ]) {
            notificationTypes.put(customNotificationType.DeveloperName, customNotificationType.Id);
        }
        return notificationTypes;
    }
}