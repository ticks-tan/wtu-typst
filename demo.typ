#import "template/wtu-essays.typ": *

// 使用模板
#show: doc => conf(
    // 中文论文标题
    zhTitle: "关于XXX的研究",
    colleges: "化学与化工学院",
    major: "应用化学",
    class: "应化xxx班",
    studentId: "2000000000",
    zhAuthor: "杰克",
    enAuthor: "Jack",
    teacher: "张三",
    date: "二零二三年十二月七日",
    zhAbstract: [
        本文简单介绍了Typst语法，帮助人们快速入门。
    ],
    zhKeywords: ("Typst", "Wtu Essays"),
    enAbstract: [
        This article provides a brief introduction to the Typst syntax to help people get started quickly.
    ],
    enKeywords: ("Typst", "Wtu Essays"),
    doc
)

/* ----------------  正文  ----------------------*/
= Typst简单语法

== 标题

== 文字效果

== 图片

== 表格

== 代码块

== 公式

行内公式：$x + y^2 = a / c$ 。

#figure[
    $ x^2 = a * sum_(alpha=0)^(100)(sqrt(2alpha)/(a*b)) $
]

== 参考文献

= Typst高级功能

/*-----------------  附录  ----------------------*/
#StartAppendix();

= 关于Typst

= 关于本模板