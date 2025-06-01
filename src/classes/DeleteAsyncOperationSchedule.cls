/**
 * Created by Eric Liang on 2022/4/28.
 */

public class DeleteAsyncOperationSchedule implements Schedulable, Database.Batchable<SObject> {
    public DeleteAsyncOperationSchedule() {
    }

    public void execute(SchedulableContext context) {
        Database.executeBatch(new DeleteAsyncOperationSchedule());
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id FROM AsyncOperation__c]);
    }

    //Batchable job implementation
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext BC) {
    }
}