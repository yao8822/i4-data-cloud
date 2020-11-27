# i4-data-cloud 分布式微服务权限控制数据平台
- **整合数据资源，重写代码架构，降低耦合度，服务功能做到热插拔，开箱即用；**
- **底层代码分模块封装成至简化，职责明确，注释严谨，保障高可读性；**
- **应用层相对独立，借助注册中心，通过openfeign相互调用，配置降级熔断机制；**
- **应用/功能拓展简单，通过FreeMarker开发了一套基于当前平台的自动代码生成应用，且提供了web界面操作，只需依次填写配置表单即可；**
- **数据存储方式的多元化决定可存储内容的丰富化，图片，图文内容，音视频等各类文件；**
- **数据存储的各类组件，统一为高可用模式，master-slave节点，可用节点大于等于2；**
- **流程引擎驱动事务办理，将线下的会签事项搬到线上，绘制相对应的流程图；**
- **自定义权限控制，权限细化到按钮，操作拦截到具体的接口，保持公共数据的可阅读性与安全性；**
## 数据存储/中间件
| 名称  | 存储类型  | 作用  |
| ------------ | ------------ | ------------ |
| MySQL  | 核心业务数据  | 事务操作，数据的最终落地保存  |
|  Redis | 缓存（持久化），分布式锁，限流计数器，消息推送……  | 分布式单点登录，下午茶点单，活动行签到，照片墙点赞，流转任务办理…………诸如此类场景  |
| mongoDB  | 富文本，图文内容数据  | 各种富文本编辑器的图文内容，长文本内容，生成二维码的base64码存储。  |
| fastDFS  |  分布式文件存储(图片，视频，音频，文档……) | 所有的文件上传全部对接FastDFS，提供在线访问的链接，文件访问的token验权……  |
| clickHouse  |  大数据量的存储（日志） | 超高效的查询效率，不支持事务，很吃资源，一切为了极致的查询与计算  |
| rabbitMQ  |  消息队列 | 异步处理与业务解耦，分离一些与主业务不相关，但不得不处理的数据 |
### 为什么整合与拆分？
程序员时刻要保持两个意识：数据量的急速扩张的请求量的瞬间上涨。
- 如果只是为了实现功能的去写相关业务代码，完成发布后，一旦遇到了上述两个问题中的其中一个，再想修改的话很麻烦，假如代码又很凌乱的话，改起来很有可能会重头再来，这对于线上的服务来说，时间已经来不及了，所以未雨绸缪的规范数据处理和适当的主动压力测试，其实是一个良好的习惯。通过缓存避免直接对MySQL操作，减少请求到达数据库的次数，热点数据（签到，点单，点赞……）尽量放在离用户近的地方，额外提供数据预热的管理界面，支持先将数据加载到缓存；
- MySQL尽量控制字段的长度，一旦字段的文本内容过长，数据总量累计量大，相关表整体的读写效率将会被这一个字段给拖累得不要不要的。如果将其拆分成一个单独的表存储，读写分类的话，其实还好，如果只是单节点的MySQL，那么将会给MySQL服务带来很大的负担，根据木桶效应，系统的短板就决定着系统的瓶颈，所以引入mongoDB。
- 所有Redis中的相关业务表（签到，点赞，点单……）最终都需要通过定时任务在MySQL中落地存储；
- 所有MySQL中的文本字段全部抽出来存储到mongoDB中，返回mongoID相关关联，mongoDB中的库名与集合名保持与MySQL表名相对应；
- 所有的文件上传（file_url）字段，统一对接fastDFS，上传成功后返回对应节点的在线访问链接存储到MySQL对应字段；
- fastDFS对比传统的容器文件上传（eg：Tomcat），保障文件的安全可靠性和可移植性；
- clickHouse主要针对海量数据的存储，由于不支持事务的特性，没有隔离级别，使其查询非常快，再加上列式存储，在count()这类操作有天然有优势。

## 架构拆分
模块 | 端口 | 说明
---|---|---
i4-data-cloud-base |  | base模块，封装基类约束规范代码，自定义注解/枚举，Echart实体，工具类，相关常量类，返回结果集……
i4-data-cloud-cache |  | 缓存模块，此处主要是Redis，包括但不限于5种数据类型的操作，lua执行脚本，分布式锁，消息推送……
i4-data-cloud-core |  | MySQL的核心业务代码，entity（dto，model，view），service（impl），mapper……SQL日志拦截器……
i4-data-cloud-mongo |  | 对MongoDB的一次半彻底封装，开发使用仅需少量的代码（提供集合的映射实体，相关service继承抽象类）
i4-data-cloud-mq |  | 对rabbitMQ的一次半彻底封装，提供可供调用的produceService，必须被继承的consumer抽象类，加载即预热队列
i4-data-cloud-start-activiti-design | 9016 | 集成activiti（5.22）流程设计器（maven依赖独立存在），提供流程处理的一系列接口
i4-data-cloud-start-auth | 9010 | 统一认证中心：单点登录，注册，找回密码，提供验证码，提供token
i4-data-cloud-start-autocode | 9015 | 采用freemarker封装的一套web界面自动代码生成服务（针对数据源做相关的处理）
i4-data-cloud-start-consumer | 9014 | 消息消费者服务（集中处理rabbitmq消息），多节点部署即负载均衡
i4-data-cloud-start-eureka | 9001 | eureka注册中心
i4-data-cloud-start-file | 9012 | 分布式FastDFS文件服务（上传/下载/删除）
i4-data-cloud-start-gateway | 9002 | API网管服务
i4-data-cloud-start-schedule | 9017 | 定时任务的集中处理
i4-data-cloud-start-system | 9011 | 数据平台的管理系统
