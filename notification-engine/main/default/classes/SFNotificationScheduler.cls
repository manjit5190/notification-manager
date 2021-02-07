/**
 *
 * @description This is the class that schedules the two batches.
 * <br/>
 * <br/>
 * <b>How to schedule</b><br/>
 * <ol>
 *     <li>Open Developer console</li>
 *     <li>Open execute anonymous window</li>
 *     <li>Paste the following code  <br/>
  *     <code>System.schedule('Notifications Helper', '0 0 0/1 1/1 * ? *', new SFNotificationScheduler(400));
 *     </code>
 *     <br/>and execute.</li>
 * </ol>
 *
 *
 *
 * @see SFNotificationBatch
 * @see SFNotificationGroupBatch
 *
 * @date 2021-02-07
 * @author Manjit Singh
 */
public with sharing class SFNotificationScheduler implements Schedulable {

    Integer batchSize = 400;
    public SFNotificationScheduler(Integer batchSize) {
        this.batchSize = batchSize;
    }

    public void execute(SchedulableContext context) {
        //The documentation on SF is little unclear
        // It says max 500 recipients can be added whereas
        // a limit of 10K is written at most places.
        this.batchSize = Math.min(400, this.batchSize);

        Database.executeBatch(new SFNotificationBatch(SFNotificationConstants.QUERY_BATCH), this.batchSize);

        Database.executeBatch(new SFNotificationGroupBatch(SFNotificationConstants.QUERY_GROUP_BATCH), this.batchSize);

    }
}