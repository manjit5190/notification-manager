/**
 *
 * @description This class is a wrapper over the Notification and Notification Group
 * custom objects and helps to create records which are then picked up
 * by batches and sent as notifications.
 *
 * <p>
 * The notifications can be create using the two constructors, one for group
 * and another for single notification.
 *
 * </p>
 * <br/>
 * <p>
 * <b>Example</b><br/>
 * <code>
 * new SFNotification('UserUpdate').setTitle('Title')
 * .setBody('Body').setRecordId('&lt;ACCOUNT ID&gt;')
 * .addRecipient('&lt;Recipient userId&gt;').enqueue();
 * </code>
 *
 * </p>
 *
 * @see SFNotificationGroupBatch
 * @see SFNotificationBatch
 * @date 2021-02-07
 * @author Manjit Singh
 */
public with sharing class SFNotification {
    private SFNotificationHelper helper = new SFNotificationHelper();

    private Set<Id> recipientsIds = new Set<Id>();
    private String notificationType;
    private Id recordId;
    private Integer priority = 500;
    private String pageRef;
    private String title;
    private String body;
    private String groupName;
    private Id groupId;
    private Boolean isGroup = false;


    public SFNotification(String notificationType) {
        this.notificationType = notificationType;
        this.isGroup = false;
    }

    public SFNotification(String notificationType, String groupName, String title, String body) {
        this.notificationType = notificationType;
        this.title = title;
        this.body = body;
        this.groupName = groupName;
        this.isGroup = true;
    }

    /**
     * @description Writes the record
     *
     * @return SFNotification Current instance of the class
     */
    public SFNotification enqueue() {
        this.validateInputs();
        if (this.isGroup) {
            this.groupId = helper.createGroupIfNotExisting(
                    this.groupName, this.notificationType,
                    this.title, this.body, this.recordId, this.pageRef
            ).Id;
        } else {
            this.groupId = null;
        }
        List<Notification__c> notifications = new List<Notification__c>();
        for (Id userOrGroupId : recipientsIds) {
            Notification__c notification = new Notification__c();
            notification.Title__c = this.title;
            notification.Body__c = this.body;
            notification.Priority__c = this.priority;
            notification.NotificationType__c = this.notificationType;
            notification.Group__c = this.groupId;
            notification.Status__c = SFNotificationConstants.QUEUED;
            notification.TargetId__c = this.recordId;
            notification.TargetReference__c = this.pageRef;
            notifications.add(notification);
        }
        insert notifications;
        return this;
    }


    public SFNotification addRecipient(Id userId) {
        this.recipientsIds.add(userId);
        return this;
    }

    public SFNotification removeRecipient(Id userId) {
        this.recipientsIds.remove(userId);
        return this;
    }

    public SFNotification setRecordId(Id recordId) {
        this.recordId = recordId;
        return this;
    }

    public SFNotification setPriority(Integer priority) {
        this.priority = priority;
        return this;
    }

    public SFNotification setPageRef(String pageRef) {
        this.pageRef = pageRef;
        return this;
    }

    public SFNotification setTitle(String title) {
        if (this.checkBlankAndLength(title, 250)) {
            this.title = title;
        }
        return this;
    }

    public SFNotification setBody(String body) {
        if (this.checkBlankAndLength(body, 750)) {
            this.body = body;
        }
        return this;
    }

    private Boolean checkBlankAndLength(String str, Integer length) {
        if (String.isBlank(str) || str.length() > length) {
            throw new IllegalArgumentException('Input must not be blank and should not exceed '
                    + length + ' characters.');
        }
        return true;
    }

    private void validateInputs() {
        if (String.isBlank(this.notificationType)) {
            throw new IllegalArgumentException(SFNotificationConstants.MESSAGE_BLANK_TYPE);
        }
        if (String.isBlank(this.title) && String.isBlank(this.body)) {
            throw new IllegalArgumentException(SFNotificationConstants.MESSAGE_BLANK_TITLE_OR_BODY);
        }
        if (this.priority == null) {
            throw new IllegalArgumentException(SFNotificationConstants.MESSAGE_BLANK_PRIORITY);
        }
        if (String.isBlank(this.recordId) && String.isBlank(this.pageRef)) {
            throw new IllegalArgumentException(SFNotificationConstants.MESSAGE_BLANK_TARGET_ID);
        }
        if (this.recipientsIds.isEmpty()) {
            throw new IllegalArgumentException(SFNotificationConstants.MESSAGE_BLANK_RECIPIENTS);
        }
    }
}