/**
 * @description Test class for Async Operation
 *
 * @author Eric Liang
 *
 * @date 2019/10/15 15:20
 * @Version 1.0
 **/
@IsTest
public with sharing class AsyncOperationTest {

    @TestSetup
    static void setupData() {
        List<Account> accountsForTest = new List<Account>();
        accountsForTest.add(new Account(Name = 'test1'));
        accountsForTest.add(new Account(Name = 'test2'));
        insert accountsForTest;
    }

    @IsTest
    static void test1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new calloutMock());
        AsyncOperationQueueable.enqueue();
        Test.stopTest();
    }

    @IsTest
    static void test2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new calloutMock());
        AsyncOperationQueueable.tryToQueue();
        Test.stopTest();
    }

    @IsTest
    static void test3() {
        List<Account> accounts = [SELECT Id FROM Account];
        Test.startTest();
        AsyncOperationHelper.createRecord(accounts[0], 'AsyncSampleImpl', true);
        AsyncOperationHelper.createRecord(accounts[1], 'AsyncSampleImpl', false);
        AsyncOperationHelper.createRecords(accounts, 'AsyncSampleImpl');
        Test.stopTest();
    }
    
    public class calloutMock implements HttpCalloutMock {
        // Implement this interface method
        public HttpResponse respond(HttpRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"example":"test"}');
            response.setStatusCode(0);
            return response;
        }
    }
}