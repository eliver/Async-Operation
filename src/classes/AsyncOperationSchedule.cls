/**
 * @description Created by Eric Liang on 2022/8/17.
 */

public without sharing class AsyncOperationSchedule implements Schedulable {

    public void execute(SchedulableContext context) {
        if (!([SELECT Id FROM AsyncOperation__c WHERE Status__c = 'Active' LIMIT 1].isEmpty())) {
            AsyncOperationQueueable.enqueue();
        }
    }
}