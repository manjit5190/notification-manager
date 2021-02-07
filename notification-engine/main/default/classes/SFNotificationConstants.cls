/**
 *
 * @description Constants
 *
 * @see SFNotification
 * @see SFNotificationBatch
 * @see SFNotificationGroupBatch
 *
 * @date 2021-02-07
 * @author Manjit Singh
 */
public with sharing class SFNotificationConstants {
    public static String SUCCESS = Label.SFNotificationSuccess;
    public static String ERROR = Label.SFNotificationError;
    public static String QUEUED = Label.SFNotificationQueued;

    public static String MESSAGE_BLANK_TITLE_OR_BODY = Label.SFNotificationErrorTitleBody;
    public static String MESSAGE_BLANK_TYPE = Label.SFNotificationErrorNotificationType ;
    public static String MESSAGE_BLANK_PRIORITY = Label.SFNotificationErrorPriority;
    public static String MESSAGE_BLANK_TARGET_ID = Label.SFNotificationErrorTarget;
    public static String MESSAGE_BLANK_RECIPIENTS = Label.SFNotificationErrorRecipient;

    // General
    public static String DEFAULT_NOTIFICATION_TYPE = 'SFDefaultNotification';
    public static String TEST_MESSAGE_ONE_NOTIF_QUEUED = 'A notification should have been created in queued status';
    public static String TEST_MESSAGE_ONE_GROUP_CREATED = 'A notification groups should have been created.';
    public static String TEST_MESSAGE_BATCH_SUCCESS = 'Batch should complete successfully as all fields are filled';
    public static String TEST_MESSAGE_BATCH_FAILURE = 'Batch should have failed. Mandatory fields are missing';

    public static String QUERY_GROUP_BATCH = 'SELECT OwnerId, Group__c FROM Notification__c WHERE ' +
            'Group__c != NULL AND Group__r.Status__c = \'' +
            QUEUED + '\' ORDER BY Priority__c ASC';

    public static String QUERY_BATCH = 'SELECT Body__c, Error__c, Group__c, Id, NotificationType__c, ' +
            'OwnerId, TargetReference__c, TargetId__c, Priority__c, Status__c, Title__c FROM ' +
            'Notification__c WHERE Group__c = NULL AND Status__c = \'' + QUEUED + '\' ' +
            'ORDER BY Priority__c ASC ';
}