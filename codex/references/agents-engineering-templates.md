# 工程模板（按需读取）

仅在对应交付需要模板时读取其小节。示例数值为演示，不覆盖用户或项目的验收要求。

## 7. 模板与清单
### 7.1 证据表（CSV 头）
```
id,type,source,title,version,publish_date,access_date,link,applies_to
```
### 7.2 技术选型对比矩阵（CSV 头）
```
option,version,maturity,community_health,performance,security,maintainability,learning_cost,ecosystem,compatibility,cost,risk,score,notes,evidences
```
### 7.3 性能基准配置（YAML 示例）
```
target: service-x
workload:
  rps: [100, 500, 1000]
  duration: 5m
metrics:
  - p50_latency_ms
  - p95_latency_ms
  - p99_latency_ms
  - throughput_rps
  - cpu_pct
  - mem_mb
pass_thresholds:
  p99_latency_ms: 200
  throughput_rps: 800
```
### 7.4 风险登记表（CSV 头）
```
id,description,category,likelihood,impact,mitigation,owner,status
```
### 7.5 ADR 模板（Markdown）
```
# ADR-NN: <决策标题>
日期：YYYY-MM-DD  | 状态：提议/通过/废弃

## 背景
<业务背景与问题描述>

## 备选方案
- 方案A：优缺点
- 方案B：优缺点

## 决策
<选定方案与理由（含权衡矩阵得分）>

## 后果
<正/负面影响、迁移/回滚影响>

## 引用
- [证据#] ...
```
### 7.6 SDS 目录
- 概述与目标（含 SLO/SLI 与成功标准）
- 架构与部署（Mermaid/PlantUML）
- 数据流/时序与错误路径
- 接口契约、错误码、限流策略
- 数据模型与一致性/事务策略
- 观测性与容量规划
- 安全与合规
- 风险与缓解措施
- 验收与发布计划
