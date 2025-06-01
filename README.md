# Salesforce Async Operation Framework | Salesforce 异步操作框架

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Salesforce](https://img.shields.io/badge/Salesforce-56.0-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

[English](#introduction) | [中文](#介绍)

</div>

## Introduction

The Salesforce Async Operation Framework is an asynchronous execution framework implemented based on Salesforce Queueable. All functionalities that require asynchronous processing can rely on this framework for implementation. It allows developers to decouple time-intensive processes from their synchronous execution context, improving overall system performance and user experience.

### Why Use This Framework?

The Async Operation Framework solves the problem of data tracking difficulty during asynchronous operations and improves the exception handling mechanism for asynchronous operations.

### Key Features

- **Trackable Execution**: Track the data and processing status of asynchronous executions
- **Configurable Retry Mechanism**: Built-in retry mechanism for failed operations (default: up to 3 retries)
- **Single/Batch Processing**: Support for processing single or batch data, stored as Attachments for large data volumes
- **Comprehensive Logging**: All asynchronous data records and their processing status can be viewed on the Async Operation object
- **Easy Implementation**: Simple interface-based design for creating custom async operations
- **Monitoring & Logging**: Comprehensive logging of operation execution status
- **Scalable Architecture**: Designed to handle high-volume transaction processing
- **Configurable Settings**: Customize retry attempts, email notifications, and more

### How It Works

1. Register your async operations by implementing the `IAsyncOperation` interface
2. Submit jobs via the `AsyncOperationHelper` class
3. The framework automatically processes jobs using Queueable Apex
4. Failed jobs are automatically retried based on configured settings
5. Monitor execution through custom objects

## Installation

### Using Salesforce CLI

```bash
# Clone the repository
git clone https://github.com/yourusername/salesforce-async-operation.git
cd salesforce-async-operation

# Deploy to your org
sfdx force:auth:web:login -a YourOrgAlias
sfdx force:source:deploy -p force-app -u YourOrgAlias
```

### Using a Scratch Org

```bash
# Clone the repository
git clone https://github.com/yourusername/salesforce-async-operation.git
cd salesforce-async-operation

# Create a scratch org
sfdx force:org:create -f config/project-scratch-def.json -a AsyncOpScratch

# Deploy the code
sfdx force:source:push -u AsyncOpScratch

# Open the org
sfdx force:org:open -u AsyncOpScratch
```

## Usage Guide

### 1. Implement the IAsyncOperation Interface

Create a new class that implements the `IAsyncOperation` interface:

```apex
public class AsyncXXImpl implements IAsyncOperation {
    public String execute(String JSONString) {
        // Process your data
        return 'Execution Log';
    }
}
```

### 2. Using AsyncOperation (Automatic Trigger)

#### Processing a Single Record

```apex
// Process a single record
AsyncOperationHelper.createRecord(Object message, String method);
// message - The data record
// method - The registered name of the implementation class
```

#### Processing Multiple Records

```apex
// Process multiple records
AsyncOperationHelper.createRecords(List<Object> messages, String method);
// messages - Collection of data records
// method - The registered name of the implementation class
```

#### Optional: Control Execution Mode

```apex
// Control execution mode
AsyncOperationHelper.createRecord(Object message, String method, Boolean isSync);
// message - The data record
// method - The registered name of the implementation class
// isSync - Execution mode, true for synchronous execution, false for asynchronous execution
```

### 3. Using AsyncOperation (Manual Trigger)

#### Adding a Single Record

```apex
// Add a single record
AsyncOperationHelper.addRecord(Object message, String method);
// message - The data record
// method - The registered name of the implementation class
```

#### Adding Multiple Records

```apex
// Add multiple records
AsyncOperationHelper.addRecords(List<Object> messages, String method);
// messages - Collection of data records
// method - The registered name of the implementation class
```

#### Execute Tasks Manually

After adding records, you need to manually execute tasks using one of the following methods:

```apex
// Execute all added tasks
AsyncOperationHelper.execute();

// Execute all added tasks with parallel control
AsyncOperationHelper.execute(Boolean runInParallel);
// runInParallel - Control whether to execute all tasks concurrently (true) or each task individually (false)

// Execute specified type of tasks
AsyncOperationHelper.execute(String method);
// method - The registered name of the implementation class
```

## Data Model

### Async Operation (Custom Object)

| Field Label | Field Name | Data Type | Description |
| --- | --- | --- | --- |
| Async Operation Name | Name | Name | Async-{YYYY}{MM}{DD}-{0000} |
| Call Method | Method__c | Text(255) | The registered name of the implementation class |
| Execution Log | Log__c | Long Text Area(32768) | Execution log |
| JSON String | JSON__c | Long Text Area(32768) | JSON format of the input data record |
| Status | Status__c | Picklist | Processing status of the data record:<br/>Active - Not yet processed<br/>Processing - Being processed<br/>Succeed - Successfully processed<br/>Failed - Processing failed |
| Tried Time(s) | TriedTimes__c | Number(18, 0) | Number of execution retries |

### Async Operation Setting (Custom Setting)

| Field Label | Field Name | Data Type | Description |
| --- | --- | --- | --- |
| Active | Active__c | Checkbox | Whether this feature is enabled |
| Email Alert? | EmailAlert__c | Checkbox | Whether to send email notifications when execution fails |
| Email(s) | Emails__c | Text(255) | Email addresses to send to when execution fails |
| Retried Time(s)? | RetriedTimes__c | Number(18, 0) | Number of error retries |

---

## 介绍

Salesforce 异步操作框架是一个基于 Salesforce Queueable 实现的异步执行框架，所有需要异步处理的功能都可以依赖该框架实现。它允许开发人员将耗时的流程与其同步执行上下文分离，从而提高整体系统性能和用户体验。

### 为什么使用这个框架？

Async Operation 解决了异步操作时的数据不易跟踪的问题，完善了异步操作的异常处理机制。

### 主要特点

- **可跟踪执行**：可跟踪异步执行的数据和处理状态
- **可配置的重试机制**：内置错误重试机制，当前设置为发生错误时最多重试三次
- **单个/批量处理**：支持处理单个/批量数据，当处理数据量大时会以 Attachment 方式保存
- **全面日志记录**：所有的异步数据记录及其处理状态均可在 Async Operation 对象上查看
- **易于实现**：基于简单接口设计，轻松创建自定义异步操作
- **监控与日志**：全面记录操作执行状态
- **可扩展架构**：专为处理高交易量而设计
- **可配置设置**：自定义重试次数、邮件通知等

### 工作原理

1. 通过实现 `IAsyncOperation` 接口注册您的异步操作
2. 通过 `AsyncOperationHelper` 类提交作业
3. 框架使用 Queueable Apex 自动处理作业
4. 根据配置设置自动重试失败的作业
5. 通过自定义对象监控执行情况

## 安装

### 使用 Salesforce CLI

```bash
# 克隆仓库
git clone https://github.com/yourusername/salesforce-async-operation.git
cd salesforce-async-operation

# 部署到您的组织
sfdx force:auth:web:login -a YourOrgAlias
sfdx force:source:deploy -p force-app -u YourOrgAlias
```

### 使用 Scratch Org

```bash
# 克隆仓库
git clone https://github.com/yourusername/salesforce-async-operation.git
cd salesforce-async-operation

# 创建 scratch org
sfdx force:org:create -f config/project-scratch-def.json -a AsyncOpScratch

# 部署代码
sfdx force:source:push -u AsyncOpScratch

# 打开组织
sfdx force:org:open -u AsyncOpScratch
```

## 使用指南

### 1. 实现 IAsyncOperation 接口

创建一个新的类，实现 `IAsyncOperation` 接口：

```apex
public class AsyncXXImpl implements IAsyncOperation {
    public String execute(String JSONString) {
        // 处理您的数据
        return 'Execution Log';
    }
}
```

### 2. 使用 AsyncOperation（自动触发）

#### 处理单条数据

```apex
// 处理单条数据
AsyncOperationHelper.createRecord(Object message, String method);
// message - 数据记录
// method - 实现类的注册名
```

#### 处理多条数据

```apex
// 处理多条数据
AsyncOperationHelper.createRecords(List<Object> messages, String method);
// messages - 数据记录集合
// method - 实现类的注册名
```

#### 可选：控制执行模式

```apex
// 控制执行模式
AsyncOperationHelper.createRecord(Object message, String method, Boolean isSync);
// message - 数据记录
// method - 实现类的注册名
// isSync - 执行方式，true为同步执行，false为异步执行
```

### 3. 使用 AsyncOperation（手动触发）

#### 添加单条数据

```apex
// 添加单条数据
AsyncOperationHelper.addRecord(Object message, String method);
// message - 数据记录
// method - 实现类的注册名
```

#### 添加多条数据

```apex
// 添加多条数据
AsyncOperationHelper.addRecords(List<Object> messages, String method);
// messages - 数据记录集合
// method - 实现类的注册名
```

#### 手动执行任务

添加完成后，需调用以下方法手动执行任务：

```apex
// 批量执行所有添加的任务
AsyncOperationHelper.execute();

// 批量执行所有添加的任务时，支持控制是否并发执行
AsyncOperationHelper.execute(Boolean runInParallel);
// runInParallel - 控制并发执行所有任务（true），还是单条执行每个任务（false）

// 执行指定类型的任务
AsyncOperationHelper.execute(String method);
// method - 实现类的注册名
```

## 数据模型

### Async Operation（自定义对象）

| 字段标签 | 字段名称 | 数据类型 | 描述 |
| --- | --- | --- | --- |
| Async Operation Name | Name | Name | Async-{YYYY}{MM}{DD}-{0000} |
| Call Method | Method__c | Text(255) | 调用的实现类的注册名 |
| Execution Log | Log__c | Long Text Area(32768) | 执行Log |
| JSON String | JSON__c | Long Text Area(32768) | 传入的数据记录的JSON格式 |
| Status | Status__c | Picklist | 数据记录的处理状态：<br/>Active - 尚未处理<br/>Processing - 正在处理<br/>Succeed - 处理成功<br/>Failed - 处理失败 |
| Tried Time(s) | TriedTimes__c | Number(18, 0) | 已经重试的执行次数 |

### Async Operation Setting（自定义设置）

| 字段标签 | 字段名称 | 数据类型 | 描述 |
| --- | --- | --- | --- |
| Active | Active__c | Checkbox | 是否启用该功能 |
| Email Alert? | EmailAlert__c | Checkbox | 执行失败时是否发送邮件通知 |
| Email(s) | Emails__c | Text(255) | 执行失败时发送到的邮件地址 |
| Retried Time(s)? | RetriedTimes__c | Number(18, 0) | 错误重试的次数 |

## 架构

![Architecture](https://via.placeholder.com/800x400?text=Salesforce+Async+Operation+Framework)

## 贡献指南

欢迎提交问题和拉取请求！请确保遵循项目的代码风格和测试指南。

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。 