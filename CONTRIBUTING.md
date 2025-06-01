# Contributing Guide | 贡献指南

Thank you for your interest in contributing to the Salesforce Async Operation Framework! This document provides guidelines and instructions for contributing.

感谢您有兴趣为 Salesforce 异步操作框架做出贡献！本文档提供了贡献的指南和说明。

## How to Contribute | 如何贡献

### Reporting Issues | 报告问题

If you find a bug or have a feature request:

如果您发现错误或有功能请求：

1. Check if the issue already exists in the Issues section | 检查问题部分中是否已存在该问题
2. If not, create a new issue with a clear title and detailed description | 如果没有，请创建一个新问题，标题清晰，描述详细
3. Include code samples, error messages, and steps to reproduce if applicable | 如果适用，请包含代码示例、错误消息和重现步骤

### Code Contributions | 代码贡献

1. Fork the repository | 复刻存储库
2. Create a new branch with a descriptive name | 创建一个具有描述性名称的新分支
3. Make your changes following our coding standards | 按照我们的编码标准进行更改
4. Write or update tests as necessary | 根据需要编写或更新测试
5. Submit a pull request with a clear description of the changes | 提交一个包含更改清晰描述的拉取请求

## Development Setup | 开发设置

1. Set up a Salesforce DX project | 设置 Salesforce DX 项目
2. Clone this repository | 克隆此存储库
3. Deploy to a scratch org for development | 部署到 scratch org 进行开发

```bash
sfdx force:org:create -f config/project-scratch-def.json -a AsyncOpScratch
sfdx force:source:push -u AsyncOpScratch
```

## Coding Standards | 编码标准

- Follow Salesforce Apex coding best practices | 遵循 Salesforce Apex 编码最佳实践
- Write clear, descriptive comments | 编写清晰、描述性的注释
- Keep methods focused on a single responsibility | 使方法专注于单一职责
- Include appropriate test coverage (minimum 75%) | 包含适当的测试覆盖率（最低 75%）

## Testing | 测试

All new features or bug fixes should include tests:

所有新功能或错误修复都应包含测试：

1. Create test classes in the appropriate test directory | 在适当的测试目录中创建测试类
2. Ensure all tests pass before submitting a pull request | 在提交拉取请求之前确保所有测试都通过
3. Run tests locally using: | 使用以下命令在本地运行测试：

```bash
sfdx force:apex:test:run -u AsyncOpScratch -c -r human
```

## Pull Request Process | 拉取请求流程

1. Update documentation if needed | 如有需要，请更新文档
2. Ensure all tests pass | 确保所有测试都通过
3. Rebase your branch on the latest main branch | 在最新的主分支上重新设置您的分支基础
4. Submit the pull request with a clear description | 提交带有清晰描述的拉取请求

## Code Review | 代码审查

All submissions require review before being merged:

所有提交在合并之前都需要审查：

1. Be open to feedback and suggestions | 对反馈和建议持开放态度
2. Address all review comments | 处理所有审查评论
3. Make requested changes promptly | 及时进行所需的更改

## License | 许可证

By contributing to this project, you agree that your contributions will be licensed under the project's MIT License.

通过为此项目做出贡献，您同意您的贡献将根据项目的 MIT 许可证进行许可。 