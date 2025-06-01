/**
 * Created by Eric Liang on 2019/9/25.
 * Trigger handler for Async Operation
 */

public with sharing class AsyncOperationTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        //Init default values
        for (AsyncOperation__c asyncOperation : (List<AsyncOperation__c>) Trigger.new) {
            asyncOperation.TriedTimes__c = asyncOperation.TriedTimes__c == null ? 0 : asyncOperation.TriedTimes__c;
        }
    }

    public override void beforeUpdate() {
        System.debug('***Async Operation Before Update');
        for (AsyncOperation__c asyncOperation : (List<AsyncOperation__c>) Trigger.new) {
            if (asyncOperation.TriedTimes__c != Trigger.oldMap.get(asyncOperation.Id).get('TriedTimes__c') &&
                    AsyncOperationSetting.getConfig().RetriedTimes__c <= asyncOperation.TriedTimes__c &&
                    asyncOperation.Status__c != 'Succeed') {
                asyncOperation.Status__c = 'Failed';
                if (AsyncOperationSetting.getConfig().EmailAlert__c) {
                    sendEmail(AsyncOperationSetting.getConfig().Emails__c);
                }
            }
        }
    }

    public override void afterInsert() {
        System.debug('***Async Operation After Insert');
        enqueueAsyncOperation((Map<Id, AsyncOperation__c>) Trigger.oldMap, Trigger.new);
    }

    public override void afterUpdate() {
        enqueueAsyncOperation((Map<Id, AsyncOperation__c>) Trigger.oldMap, Trigger.new);
    }

    private static void enqueueAsyncOperation(Map<Id, AsyncOperation__c> oldAsyncOperations, List<AsyncOperation__c> asyncOperations) {
        for (AsyncOperation__c item : asyncOperations) {
            if (item.Status__c == 'Active' &&
                    (oldAsyncOperations == null || oldAsyncOperations.isEmpty() || oldAsyncOperations.get(item.Id).Status__c != item.Status__c)) {
                AsyncOperationQueueable.enqueue(item);
            }
        }
    }

    private static void sendEmail(String emailAddress) {
        //TODO:Send email implements
    }
}