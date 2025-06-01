/**
 * Created by Eric Liang on 2019/9/25.
 */

trigger AsyncOperationTrigger on AsyncOperation__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new AsyncOperationTriggerHandler().run();
}