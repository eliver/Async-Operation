# Usage Examples | 使用示例

This document provides examples of how to use the Salesforce Async Operation Framework in different scenarios.

本文档提供了在不同场景下如何使用 Salesforce 异步操作框架的示例。

## Basic Example | 基本示例

### 1. Create an Implementation | 创建实现

First, create a class that implements the `IAsyncOperation` interface:

首先，创建一个实现 `IAsyncOperation` 接口的类：

```apex
public class EmailSenderOperation implements IAsyncOperation {
    
    public String execute(String JSONString) {
        try {
            // Parse the JSON input
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(JSONString);
            
            // Extract parameters
            String toAddress = (String) params.get('toAddress');
            String subject = (String) params.get('subject');
            String body = (String) params.get('body');
            
            // Create email message
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { toAddress });
            email.setSubject(subject);
            email.setPlainTextBody(body);
            
            // Send email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            
            return 'Success: Email sent to ' + toAddress;
        } catch (Exception e) {
            // Log the error and rethrow - framework will handle retries
            return 'Error: ' + e.getMessage();
        }
    }
}
```

### 2. Queue the Operation | 队列操作

Next, create an instance of your operation data and submit it to the framework:

接下来，创建操作数据的实例并将其提交到框架：

```apex
// Prepare the data for the operation
Map<String, Object> emailData = new Map<String, Object>{
    'toAddress' => 'recipient@example.com',
    'subject' => 'Async Email Test',
    'body' => 'This email was sent asynchronously using the framework.'
};

// Submit to the framework for async processing
AsyncOperationHelper.createRecord(emailData, 'EmailSenderOperation');
```

### 3. Synchronous Execution Option | 同步执行选项

If you need to execute the operation immediately:

如果您需要立即执行操作：

```apex
AsyncOperationHelper.createRecord(emailData, 'EmailSenderOperation', true);
```

## Advanced Examples | 高级示例

### Batch Processing | 批量处理

Process multiple records in a single asynchronous operation:

在单个异步操作中处理多条记录：

```apex
public class ContactUpdaterOperation implements IAsyncOperation {
    
    public String execute(String JSONString) {
        try {
            // Parse JSON into a list of contact IDs
            List<String> contactIds = (List<String>) JSON.deserialize(JSONString, List<String>.class);
            
            // Query contacts
            List<Contact> contactsToUpdate = [SELECT Id, LastActivityDate FROM Contact WHERE Id IN :contactIds];
            
            // Update the contacts
            for(Contact c : contactsToUpdate) {
                c.Last_Async_Process_Date__c = Date.today();
            }
            
            // Save updates
            update contactsToUpdate;
            
            return 'Success: Updated ' + contactsToUpdate.size() + ' contacts';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}

// Usage:
List<String> contactIds = new List<String>{ '001XXXXXXXXXXXXXXX', '001YYYYYYYYYYYYYYY' };
AsyncOperationHelper.createRecord(contactIds, 'ContactUpdaterOperation');
```

### Integration Example | 集成示例

Use the framework for external API callouts:

使用框架进行外部 API 调用：

```apex
public class ExternalAPICalloutOperation implements IAsyncOperation {
    
    public String execute(String JSONString) {
        try {
            // Parse the JSON input
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(JSONString);
            
            // Create HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint((String) params.get('endpoint'));
            req.setMethod((String) params.get('method'));
            req.setHeader('Content-Type', 'application/json');
            
            if(params.containsKey('body')) {
                req.setBody((String) params.get('body'));
            }
            
            // Set timeout to avoid long-running callouts
            req.setTimeout(120000); // 2 minutes
            
            // Send the request
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Process response
            if(res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                // Save the response somewhere if needed
                return 'Success: ' + res.getStatusCode() + ' ' + res.getStatus();
            } else {
                return 'Error: ' + res.getStatusCode() + ' ' + res.getStatus();
            }
        } catch(Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}

// Usage:
Map<String, Object> apiCallData = new Map<String, Object>{
    'endpoint' => 'https://api.example.com/data',
    'method' => 'GET'
};
AsyncOperationHelper.createRecord(apiCallData, 'ExternalAPICalloutOperation');
```

### Error Handling & Retry | 错误处理和重试

The framework automatically handles retries, but you can customize error response:

框架自动处理重试，但您可以自定义错误响应：

```apex
public class RetryDemonstrationOperation implements IAsyncOperation {
    
    public String execute(String JSONString) {
        try {
            // Parse data
            Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(JSONString);
            Integer attemptNumber = Integer.valueOf(params.get('attemptNumber'));
            
            // Simulate a failure on first two attempts
            if(attemptNumber < 3) {
                // Update the attempt number for next retry
                params.put('attemptNumber', attemptNumber + 1);
                
                // By returning an error message, the framework will retry
                return 'Error: Simulated failure on attempt ' + attemptNumber;
            }
            
            // Success on third attempt
            return 'Success on attempt ' + attemptNumber;
        } catch(Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}

// Usage:
Map<String, Object> retryData = new Map<String, Object>{
    'attemptNumber' => 1
};
AsyncOperationHelper.createRecord(retryData, 'RetryDemonstrationOperation');
```

## Best Practices | 最佳实践

1. Keep operation implementations stateless | 保持操作实现无状态
2. Store all necessary data in the JSON payload | 在JSON负载中存储所有必要的数据
3. Include error handling with detailed logs | 包含详细日志的错误处理
4. Return meaningful success/error messages | 返回有意义的成功/错误消息
5. Consider bulkification for high-volume operations | 考虑批量化高容量操作 