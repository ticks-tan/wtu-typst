

// World 字号对应 pt
#let FontSize = (
    初号: 42pt,
    小初: 36pt,
    一号: 26pt,
    小一: 24pt,
    二号: 22pt,
    小二: 18pt,
    三号: 16pt,
    小三: 15pt,
    四号: 14pt,
    中四: 13pt,
    小四: 12pt,
    五号: 10.5pt,
    小五: 9pt,
    六号: 7.5pt,
    小六: 6.5pt,
    七号: 5.5pt,
    小七: 5pt,
)

// 会用到的字体
#let Font = (
    宋体: ("Times New Roman", "SimSun"),
    仿宋: ("Times New Roman", "FangSong"),
    黑体: ("Times New Roman", "SimHei"),
    楷体: ("Times New Roman", "KaiTi"),
    Code: ("Times New Roman", "SimSun"),
)

// 封面部分
#let CoverPart = 1;
// 目录摘要部分
#let AbstractPart = 2;
// 正文部分
#let ContentPart = 3;

#let partCounter = counter("part")
#let chapterCounter = counter("chapter")
// 附录
#let appendixState = state("appendix", false)
// 代码计数
#let codeCounter = counter(figure.where(kind: "code"))
// 图片计数
#let imageCounter = counter(figure.where(kind: image))
// 表格计数
#let tableCounter = counter(figure.where(kind: table))
// 公式计数
#let equationCounter = counter(math.equation)

// 使用附录
#let StartAppendix() = {
    appendixState.update(true)
    // 章节和标题重新计数
    chapterCounter.update(0)
    counter(heading).update(0)
}

/* ----------------------------------------------------- */

// 数字转中文数字 整数
#let ChineseIntNumber(num) = if num <= 10 {
    ("零", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十").at(num)
}else if num < 100 {
    // num % 10
    if calc.rem(num, 10) == 0 {
      // 向下取整
      ChineseIntNumber(calc.floor(num / 10)) + "十"
    } else if num < 20 {
      "十" + ChineseIntNumber(calc.rem(num, 10))
    } else {
      ChineseIntNumber(calc.floor(num / 10)) + "十" + ChineseIntNumber(calc.rem(num, 10))
    }
}

// numbering 中文版本
#let ChineseNumbering(..nums, location: none, bracket: false) = locate(loc => {
    let realLoc = if location != none { location } else { loc }
    if not appendixState.at(realLoc) {
        // 一级数字
        if nums.pos().len() == 1 {
            "第" + ChineseIntNumber(nums.pos().first()) + "章"
        } else {
            // 数字版本
            numbering(if bracket {"(1.1)"} else {"1.1"}, ..nums)
        }
    } else {
        if nums.pos().len() == 1 {
            "附录 " + numbering("A.1", ..nums)
        } else {
            numbering(if bracket {"(A.1)"} else {"A.1"}, ..nums)
        }
    }
})

// 中文目录
#let ChineseOutline(title: "目录", depth: none, indent: false) = {
    // 目录标题
    heading(numbering: none, outlined: false)[#title]
    locate(loc => {
        // 查找标题
        let elements = query(heading.where(outlined: true), loc)

        for ele in elements {
            let eleLoc = ele.location()
            if partCounter.at(eleLoc).first() < AbstractPart and head.numbering == none { continue }

            if depth != none and ele.level > depth { continue }

            let number = if ele.numbering != none {
                if ele.numbering == ChineseNumbering {
                    ChineseNumbering(..counter(heading).at(eleLoc), location: eleLoc)
                } else {
                    numbering(head.numbering, ..counter(heading).at(eleLoc))
                }
                h(0.5em)
            }

            let line = {
                if indent {
                    // 横向缩进
                    h(1em * (ele.level - 1))
                }

                // 一级标题额外竖直缩进, weak: 连续出现会坍缩
                if ele.level == 1 {
                    v(0.5em, weak: true)
                }

                if number != none {
                    style(styles => {
                        let width = measure(number,styles).width
                        box(
                            width: width,
                            link(ele.location(), if ele.level == 1 {
                                strong(number)
                            } else {
                                number
                            })
                        )
                    })
                }

                link(eleLoc, if ele.level == 1 {
                    strong(ele.body)
                } else {
                    ele.body
                })

                if ele.level == 1 {
                    box(width: 1fr, h(1em) + box(width: 1fr) + h(1em))
                } else {
                    box(width: 1fr, h(1em) + box(width: 1fr, repeat[.]) + h(1em))
                }

                let footer = query(selector(<__footer__>).after(eleLoc), eleLoc);
                let page_number = if footer != () {
                    counter(page).at(footer.first().location()).first()
                }else {
                    0
                }

                link(eleLoc, if ele.level == 1 {
                    strong(str(page_number))
                } else {
                    str(page_number)
                })

                linebreak()
                v(-0.2em)
            }

            line
        }
    })
}

// 代码块
#let CodeBlock(code, caption: "") = {
    figure(
        rect(
            width: 100%, 
            inset: 1em,
            radius: 0.5em,
            stroke: 1pt + color.rgb("#23273a")
        )[
            #set align(left)
            #code
        ],
        caption: caption, kind: "code", supplement: ""
    )
}


/* ----------------------------------------------------- */

#let conf(
    header: "本科毕业设计（论文）",
    zhTitle: "中文标题",
    enTitle: "English Title",
    colleges: "某学院",
    major: "某专业",
    class: "年级班级",
    studentId: "学号",
    zhAuthor: "张三",
    enAuthor: "San Zhang",
    teacher: "指导老师",
    date: "某年某月某日",
    zhAbstract: [],
    zhKeywords: (),
    enAbstract: [],
    enKeywords: (),
    lineSpacing: 1em,
    outlineDepth: 3,
    doc,
) = {
    // 设置页面
    set page(
        paper: "a4",
        // 页眉
        header: locate(loc => {
            set text(FontSize.小五)
            align(center, ("武汉纺织大学" + header))
            v(-1em)
            line(length: 100%)
        }),
        // 页脚
        footer: locate(loc => {
            [
                #set text(FontSize.小五)
                #set align(center)
                #if partCounter.at(loc).first() < AbstractPart or query(selector(heading).after(loc), loc).len() == 0 {
                    // Skip
                } else {
                    let headers = query(selector(heading).before(loc), loc)
                    let part = partCounter.at(headers.last().location()).first()
                    [
                        #if part < ContentPart {
                            numbering("I", counter(page).at(loc).first())
                        } else {
                            str(counter(page).at(loc).first())
                        }
                    ]
                }
                #label("__footer__")
            ]
        }),
    )

    // 设置样式
    set heading(numbering: ChineseNumbering)
    
    set figure(
        numbering: (..nums) => locate(loc => {
            set text(font: Font.黑体, size: FontSize.小五)
            if not appendixState.at(loc) {
                numbering("1.1", chapterCounter.at(loc).first(), ..nums)
            } else {
                numbering("A.1", chapterCounter.at(loc).first(), ..nums)
            }
        })
    )
    set math.equation(
        numbering: (..nums) => locate(loc => {
            set text(font: Font.黑体, size: FontSize.小五)
            if not appendixState.at(loc) {
                numbering("(1.1)", chapterCounter.at(loc).first(), ..nums)
            } else {
                numbering("(A.1)", chapterCounter.at(loc).first(), ..nums)
            }
        })
    )

    // 有序跟无序列表缩进 2 字符
    set list(indent: 2em)
    set enum(indent: 2em)

    show strong: it => text(font: Font.黑体, weight: "semibold", it.body)
    show emph: it => text(font: Font.楷体, style: "italic", it.body)
    show par: set block(spacing: lineSpacing)
    show raw: set text(font: Font.Code)

    // 标题重新渲染
    show heading: it => [
        #set par(first-line-indent: 0em)

        #let sizedheading(it, size) = [
            #set text(size)
            // 段前两行
            #v(2em)
            #if it.numbering != none {
                strong(counter(heading).display())
                h(0.5em)
            }
            #strong(it.body)
            // 段后一行
            #v(1em)
        ]

        #if it.level == 1 {

            locate(loc => {
                if it.body.text == "摘要" {
                    // 进入摘要部分
                    partCounter.update(AbstractPart)
                    counter(page).update(1)
                } else if it.numbering != none and partCounter.at(loc).first() < ContentPart {
                    // 进入正文部分
                    partCounter.update(ContentPart)
                    counter(page).update(1)
                }
            })
            // 章节重新计数
            if it.numbering != none {
                chapterCounter.step()
            }
            codeCounter.update(())
            imageCounter.update(())
            tableCounter.update(())
            equationCounter.update(())

            set align(center)
            sizedheading(it, FontSize.三号)
        } else {
            if it.level == 2 {
                sizedheading(it, FontSize.四号)
            } else if it.level == 3 {
                sizedheading(it, FontSize.中四)
            } else {
                sizedheading(it, FontSize.小四)
            }
        }
    ]

    show figure: it => [
        #set align(center)
        #if not it.has("kind") {
            it
        } else if it.kind == image {
            it.body
            [
                #set text(size: FontSize.五号)
                #it.caption
            ]
        } else if it.kind == table {
            [
                #set text(size: FontSize.五号)
                #it.caption
            ]
            it.body
        } else if it.kind == "code" {
            [
                #set text(size: FontSize.五号)
                代码#it.caption
            ]
            it.body
        }
    ]

    show ref: it => {
        if it.element == none {
            it
        } else {
            h(0em, weak: true)

            let item = it.element
            let itLoc = item.location();
            if item.func() == math.equation {
                link(itLoc, [
                    式
                    #ChineseNumbering(
                        chapterCounter.at(itLoc).first(),
                        equationCounter.at(itLoc).first(),
                        location: itLoc,
                        bracket: true,
                    )
                ])
            } else if item.func() == figure {
                if item.kind == image {
                    link(itLoc, [
                        图
                        #ChineseNumbering(
                            chapterCounter.at(itLoc).first(),
                            imageCounter.at(itLoc).first(),
                            location: itLoc,
                            bracket: true,
                        )
                    ])
                } else if item.kind == table {
                    link(itLoc, [
                        表
                        #ChineseNumbering(
                            chapterCounter.at(itLoc).first(),
                            tableCounter.at(itLoc).first(),
                            location: itLoc,
                            bracket: true,
                        )
                    ])
                } else if item.kind == "code" {
                    link(itLoc, [
                        代码
                        #ChineseNumbering(
                            chapterCounter.at(itLoc).first(),
                            codeCounter.at(itLoc).first(),
                            location: itLoc,
                            bracket: true,
                        )
                    ])
                }
            } else if item.func() == heading {
                if item.level == 1 {
                    link(itLoc, ChineseNumbering(..counter(heading).at(itLoc), location: itLoc))
                } else {
                    link(itLoc, [
                        节
                        #ChineseNumbering(..counter(heading).at(itLoc), location: itLoc)
                    ])
                }
            }
            h(0em, weak: true)
        }
    }

    let FieldName(name) = [
        #set align(right + top)
        #strong(name)
    ]

    let FieldValue(value) = [
        #set align(center + horizon)
        #set text(font: Font.仿宋)
        #grid(
            rows: (auto, auto),
            row-gutter: 0.2em,
            value,
            line(length: 100%)
        )
    ]

    // 封面部分
    set text(size: FontSize.一号, font: Font.宋体, lang: "zh")
    set align(center + top)
    v(2em)
    box(width: 100%)[
        #grid(
            columns: (1fr),
            rows: (auto, auto),
            gutter: 1em,
            align(center)[#image("wtu_logo.png", height: 2.4em, fit: "contain")],
            align(center)[#image("wtu_txt.png", height: 2.6em, fit: "contain")]
        )
    ]
    linebreak()
    v(0.5em)
    text(font: Font.仿宋)[#strong(header)]

    set align(center + horizon)
    set text(size: FontSize.三号)

    v(60pt)
    grid(
        columns: (80pt, 280pt),
        row-gutter: 1em,
        FieldName(text("题") + h(2em) + text("目：")), FieldValue(zhTitle),
        FieldName(text("学") + h(2em) + text("院：")), FieldValue(colleges),
        FieldName(text("专") + h(2em) + text("业：")), FieldValue(major),
        FieldName(text("年级班级：")), FieldValue(class),
        FieldName(text("学") + h(2em) + text("号：")), FieldValue(studentId),
        FieldName(text("姓") + h(2em) + text("名：")), FieldValue(zhAuthor),
        FieldName(text("指导老师：")), FieldValue(teacher)
    )
    v(60pt)
    text(size: FontSize.小二)[#date]

    pagebreak(weak: true)

    // 摘要部分
    set align(left + top)
    set text(FontSize.小四)

    // 中文摘要
    par(justify: true, first-line-indent: 2em, leading: lineSpacing)[
        #heading(numbering: none, outlined: false, "摘要")
        #zhAbstract
        #v(1em)
        #set par(first-line-indent: 0em)
        *关键词：*
        #zhKeywords.join(", ")
        #v(2em)
    ]
    pagebreak(weak: true)

    // 英文摘要
    par(justify: true, first-line-indent: 2em, leading: lineSpacing)[
        #heading(numbering: none, outlined: false, "Abstract")
        #enAbstract
        #v(1em)
        #set par(first-line-indent: 0em)
        *Key Words:*
        #h(0.5em, weak: true)
        #enKeywords.join(", ")
        #v(2em)
    ]
    pagebreak(weak: true)

    // 目录部分
    ChineseOutline(depth: outlineDepth, indent: true)
    pagebreak(weak: true)

    set align(left + top)
    par(justify: true, first-line-indent: 2em, leading: lineSpacing)[
      #doc
    ]

    partCounter.update(ContentPart)
    // 致谢待完成 ...
}