/**
 * Created by Eric Liang on 2019/9/25.
 */

public with sharing class AsyncOperationSetting {
    private static AsyncOperationSetting__c asyncSetting;

    public static AsyncOperationSetting__c getConfig() {
        if (asyncSetting != null) {
            return asyncSetting;
        }
        asyncSetting = AsyncOperationSetting__c.getInstance();
        if (asyncSetting == null || Test.isRunningTest()) {
            asyncSetting = new AsyncOperationSetting__c(
                    Name = 'default',
                    Active__c = true,
                    EmailAlert__c = false,
                    Emails__c = 'eric.liang@vikingcruises.cn',
                    RetriedTimes__c = 3
            );
        }
        return asyncSetting;
    }
}