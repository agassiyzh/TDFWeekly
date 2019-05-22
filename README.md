## 分布式周报系统

周报几乎是每个团队都会有的东西。但是一个让我自己觉得舒心的写周报的地方一直没有找到。


总结起来，在用的写周报的地方有：

1. 公司内部wiki页面
2. Google Doc / wps网页版
3. excel/nubumer 文件
4. 石墨之类的在线编辑网站
5. 钉钉周报插件


我认为一个好用的周报协作系统需要有以下特性:

1. 部署在公司内网
> 既然是周报必然会涉及到公司项目进度等敏感信息。放在公网上的服务不合适。
2. 放在一个页面
> 团队周报是一个组员间了解各自工作进展的一个渠道。放在一个页面周会一起review一边方便效率高。
3. 支持同时编辑
> 周报的特点是大家会在每周有一个特定的时间点一起编辑同一个页面。目前支持在一个页面多人协同编辑的服务少之又少，Google Docs是一个但是要翻墙。WPS用过一次不好用。
4. 自由灵活的权限控制

---

于是基于git和runner写了些脚本，简单实现了一个分布式的周报系统。它有如下特点：

1. 支持任何复杂的团队结构
2. 基于git，权限清晰
3. 统一的周报模版
4. 每周团队成员在单独的文件中编辑
5. 根据不同维度，生成团队和个人的周报

---


## 使用方法

`membership.yaml`文件定义团队组织架构

```yaml
---
title: 互联网
membership:
  业界大佬:
    美国🇺🇸:
      - Timothy Donald Cook
      - Mark Elliot Zuckerberg
      - Elon Musk
    中国🇨🇳:
      - 马云
      - 马化腾
      - 雷军
      - 另一个小组织:
        - 路人甲
        - 路人乙
```

`template.yaml`定义周报的模板

```yaml
---
- title: 本周工作总结
  category: summary
  content: |
    1. 这里是周成员需要写的周报内容支持`markdown`
    2. 只要注意缩进可以写很长
    > `markdown` 引用
    3. 我们继续[markdown](https://devhints.io/markdown)
- title: 下周工作目标
  category: plan
  content: |
    1. xxxxx
    2. xxxxx
- title: 有遇到挑战或者困难么？希望团队怎么帮助你？
  category: challenge
  content: |
    1. xxxxx
    2. xxxxx
- title: 感想／吐槽，随便聊聊
  category: impression
  content: |
    1. xxxxx
    2. xxxxx
```

_ps: content中的内用支持markdown格式_

为每个成员生成周报模板：

```bash
bundle install
ruby copy_weekly_yaml_template.rb
```
生成后目录结构是这样的:

```
2019          <---------年
└── 21        <---------第几周
    └── 业界大佬        <-----------团队
        ├── 中国🇨🇳
        │   ├── 雷军.yaml
        │   ├── 马云.yaml
        │   ├── 马化腾.yaml
        │   └── 另一个小组织
        │       ├── 路人乙.yaml
        │       └── 路人甲.yaml
        └── 美国🇺🇸
            ├── Elon Musk.yaml
            ├── Mark Elliot Zuckerberg.yaml
            └── Timothy Donald Cook.yaml
```

组员在自己的周报模板中完成自己的周报提交。

比如

[雷军2019年29周的周报](2019/21/业界大佬/中国🇨🇳/雷军.yaml)

[马云2019年29周的周报](2019/21/业界大佬/中国🇨🇳/马云.yaml)

[路人甲2019年29周的周报](2019/21/业界大佬/中国🇨🇳/另一个小组织/路人甲.yaml)

[Cook2019年29周的周报](2019/21/业界大佬/美国🇺🇸/Timothy%20Donald%20Cook.yaml)

通过以下命令生成个人和团队周报。

```bash
ruby make_weekly_markdown.rb
```
 
## TODO

- [ ] 生成个人页面