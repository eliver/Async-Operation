/**
 * Created by Eric Liang on 2019/9/25.
 */

public without sharing class AsyncOperationQueueable implements Queueable, Database.AllowsCallouts {
    AsyncOperation__c asyncOperation = new AsyncOperation__c();
    //同一时间并发运行AsyncOperationQueue的数量
    //public static Integer concurrentCount = 40;

    public AsyncOperationQueueable() {
        //for update is used to lock the row so that this operation has exclusive access to the record during the processing
        List<AsyncOperation__c> asyncCallList = [SELECT Id, Name, JSON__c, Log__c, Method__c, Status__c, TriedTimes__c FROM AsyncOperation__c WHERE Status__c = 'Active' LIMIT 1 FOR UPDATE];
        
        if (!asyncCallList.isEmpty()) {
            this.asyncOperation = asyncCallList.get(0);
            this.asyncOperation.Status__c = 'Processing';
            update this.asyncOperation;
        }
    }

    public AsyncOperationQueueable(AsyncOperation__c asyncOperation) {
        //for update is used to lock the row so that this operation has exclusive access to the record during the processing
        List<AsyncOperation__c> asyncCallList = [SELECT Id, Name, JSON__c, Log__c, Method__c, Status__c, TriedTimes__c FROM AsyncOperation__c WHERE Id = :asyncOperation.Id AND Status__c <> 'Failed' FOR UPDATE];
        
        if (!asyncCallList.isEmpty()) {
            this.asyncOperation = asyncCallList.get(0);
            this.asyncOperation.Status__c = 'Processing';
            update this.asyncOperation;
        }
    }

    public void execute(QueueableContext context) {
        //Don't run if turned off in Setting
        //Don't run if no Async call record needs specified
        if (!AsyncOperationSetting.getConfig().Active__c || String.isEmpty(asyncOperation.Id)) {
            return;
        }
        //Resolve the execute log contains 'null' word
        String requestMsg = AsyncOperationHelper.getAsyncJSON(asyncOperation);
        AsyncOperationHelper.AsyncResult result = AsyncOperationHelper.asyncCallout(requestMsg, asyncOperation.Method__c);
        asyncOperation.Log__c = String.isEmpty(asyncOperation.Log__c) ? result.message.left(32768) : (asyncOperation.Log__c + result.message).left(32768);
        asyncOperation.TriedTimes__c++;
        asyncOperation.Status__c = result.status ? 'Succeed' : AsyncOperationSetting.getConfig().RetriedTimes__c <= asyncOperation.TriedTimes__c ? 'Failed' : 'Processing';
        update asyncOperation;
        try {
            //Retry current async operation if status = false
            if (!result.status && asyncOperation.Status__c == 'Processing') {
                enqueue(asyncOperation);
                return;
            }
            //Check if there are other async operations need to running
            if (![SELECT Id FROM AsyncOperation__c WHERE Status__c = 'Active' LIMIT 1].isEmpty()) {
                enqueue();
                return;
            }
        } catch (Exception ex) {
            //Use the undocumented feature to call a future from a queueable class to enqueue further
            tryToQueue();
        }
    }

    public static void enqueue() {
        List<AsyncApexJob> jobs = [
                SELECT Id
                FROM AsyncApexJob
                WHERE JobType = 'Queueable'
                AND (Status = 'Queued' OR Status = 'Holding')
                AND ApexClass.Name = 'AsyncOperationQueueable'
        ];
        // 超过设置的同一时间允许最多运行的数量，或系统当前没有可用资源
        //jobs.size() == concurrentCount ||
        if (jobs.size() == 0 && Limits.getLimitQueueableJobs() > Limits.getQueueableJobs()) {
            System.enqueueJob(new AsyncOperationQueueable());
        }
    }

    public static void enqueue(AsyncOperation__c asyncOperation) {
        asyncOperation = asyncOperation.clone(true);
        if (Test.isRunningTest() && System.isQueueable()) {
            asyncOperation.Status__c = 'Processing';
            update asyncOperation;
            new AsyncOperationQueueable(asyncOperation).execute(null);
        }
        if ((Limits.getLimitQueueableJobs() > Limits.getQueueableJobs())) {
            try {
                asyncOperation.Status__c = 'Processing';
                System.enqueueJob(new AsyncOperationQueueable(asyncOperation));
            } catch (Exception e) {
                asyncOperation.Status__c = 'Active';
            } finally {
                update asyncOperation;
            }
        }
    }

    @Future
    public static void tryToQueue() {
        if (Limits.getLimitQueueableJobs() > Limits.getQueueableJobs()) {
            try {
                enqueue();
            } catch (Exception ex) {
                //Reserved for future use.
            }
        }
    }

}