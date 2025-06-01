/**
 * Created by Eric Liang on 2019/9/25.
 */

public class AsyncOperationHelper {

    /**
     * @description Start a new async job for a record by specified method
     *
     * @param message single record
     * @param method execute method
     */
    public static void createRecord(Object message, String method) {
        if (message == null) {
            return;
        }
        try {
            AsyncOperation__c asyncOperation = new AsyncOperation__c();
            asyncOperation.Method__c = method;
            asyncOperation.TriedTimes__c = 0;
            asyncOperation.Status__c = 'Active';
            asyncOperation.JSON__c = JSON.serializePretty(message).left(32768);
            Database.insert(asyncOperation);
            //如果消息长度大于32768，则需要使用Attachment来保存消息
            if (JSON.serializePretty(message).length() > 32768) {
                Attachment a = new Attachment();
                a.ParentId = asyncOperation.Id;
                a.Name = 'Async JSON -- ' + Datetime.now();
                a.ContentType = 'text/plain';
                a.Body = Blob.valueOf(JSON.serializePretty(message));
                Database.insert(a);
            }
        } catch (Exception ex) {
            //Logger.logException(ex, message);
        }
    }

    /**
     * @description Start a new async job for multiple records by specified method
     *
     * @param messages multiple record
     * @param method execute method
     */
    public static void createRecords(List<Object> messages, String method) {
        if (messages == null || messages.isEmpty()) {
            return;
        }
        Map<Object, AsyncOperation__c> messageAsyncMap = new Map<Object, AsyncOperation__c>();
        try {
            for (Object message : messages) {
                AsyncOperation__c asyncOperation = new AsyncOperation__c();
                asyncOperation.Method__c = method;
                asyncOperation.TriedTimes__c = 0;
                asyncOperation.Status__c = 'Active';
                asyncOperation.JSON__c = JSON.serializePretty(message).left(32768);
                messageAsyncMap.put(message, asyncOperation);
            }
            Database.insert(messageAsyncMap.values());
            List<Attachment> attachments = new List<Attachment>();
            for (Object message : messageAsyncMap.keySet()) {
                AsyncOperation__c asyncOperation = messageAsyncMap.get(message);
                //如果消息长度大于32768，则需要使用Attachment来保存消息
                if (JSON.serializePretty(message).length() > 32768) {
                    Attachment a = new Attachment();
                    a.ParentId = asyncOperation.Id;
                    a.Name = 'Async JSON -- ' + Datetime.now();
                    a.ContentType = 'text/plain';
                    a.Body = Blob.valueOf(JSON.serializePretty(message));
                    attachments.add(a);
                }
            }
            if (!attachments.isEmpty()) {
                Database.insert(attachments);
            }
        } catch (Exception ex) {
            //Logger.logException(ex, messages);
        }
    }

    /**
     * @description Start a new async job for a record by specified method
     *
     * @param message single record
     * @param method execute method
     * @param isSync execute mode
     */
    public static void createRecord(Object message, String method, Boolean isSync) {
        if (isSync) {
            //execute in real-time
            asyncCallout(JSON.serializePretty(message), method);
        } else {
            //execute asynchronously
            createRecord(message, method);
        }
    }

    public static String getAsyncJSON(AsyncOperation__c asyncOperation) {
        List<Attachment> attachedJSON = [SELECT Id, Body FROM Attachment WHERE ParentId = :asyncOperation.Id];
        //如果消息使用的Attachment存储，则读取Attachment的内容
        if (!attachedJSON.isEmpty() && attachedJSON.get(0).Body != null) {
            return attachedJSON.get(0).Body.toString();
        }
        return asyncOperation.JSON__c;
    }

    public static AsyncResult asyncCallout(String asyncRequestMsg, String asyncMethod) {
        AsyncResult result = new AsyncResult();
        try {
            IAsyncOperation operation = AsyncOperationRegister.getMethod(asyncMethod);
            if (String.isEmpty(asyncRequestMsg)) {
                throw new AsyncException('JSON cannot be empty.');
            }
            result.message = '******' + operation.execute(asyncRequestMsg) + '\n';
            result.status = true;
        } catch (Exception e) {
            result.message = '******' + e.getMessage() + '\n';
            result.status = false;
        }
        return result;
    }

    public class AsyncResult {
        public Boolean status { get; set; }
        public String message { get; set; }
    }

    class AsyncException extends Exception {
    }

}