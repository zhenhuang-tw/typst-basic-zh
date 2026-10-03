// template.typ

// 字體定義（方便未來抽換特定字型）
#let font-song = ("Times New Roman", "PMingLiU")
#let font-hei = ("Arial", "Microsoft JhengHei UI")
#let font-kai = ("Times New Roman", "DFKai-SB")

// 引用樣式：行內引用【範例：#inquote[被引用之文字]】
#let inquote(content) = text(font: font-kai, content)



// ============================================================
// § 主模板函式
// ============================================================
#let project(
  // ── 中文標題區 ──
  title: "", // 標題必填
  title-thanks: none, // 標題註解（如：本文為某計畫成果）
  subtitle: none, // 副標題，預設 none

  // ── 英文標題區 (均得免填) ──
  title-en: none,
  title-en-thanks: none, // 英文標題註解
  subtitle-en: none,

  // ── 作者區（中文） ──
  // 每位作者為一個 dict：(name: "姓名", thanks: "職銜或說明")
  // 若不需要 thanks，可僅傳字串，或傳 (name: "姓名", thanks: none)
  authors: (),

  // ── 作者區（英文） ──
  authors-en: (),

  // ── 摘要與關鍵字（中文） ──
  abstract-zh: [],
  keywords-zh: none, // 字串，例如 "公法、教育法、比例原則"

  // ── 摘要與關鍵字（英文） ──
  abstract-en: [],
  keywords-en: none, // 字串，例如 "Public Law, Education Law"

  body,
) = {
  // ── 正規化 authors / authors-en 為陣列（相容純字串、單一 dict、陣列三種傳入方式） ──
  let authors-arr = if type(authors) == array { authors } else { (authors,) }
  let authors-en-arr = if type(authors-en) == array { authors-en } else { (authors-en,) }

  // ── 取出作者姓名（用於 PDF 元資料） ──
  let author-names = authors-arr.map(a => {
    if type(a) == dictionary { a.at("name", default: "") } else { str(a) }
  })

  set document(title: title, author: author-names)

  /*
    PDF 後處理指令:
    編譯後若需修改 PDF 製作者資訊，請於終端機 (Windows PowerShell) 執行：
    exiftool -Producer="國立臺北大學法律學系"
  */

  // 1. 基本頁面設定
  set page(
    paper: "a4",
    margin: (x: 3cm, y: 2.5cm),
    numbering: "1",
    number-align: center,
  )

  // 2. 字體與段落設定
  set text(
    font: font-song,
    size: 12pt,
    lang: "zh",
    region: "tw",
  )

  show: show-cn-fakebold

  set par(
    first-line-indent: 2em,
    leading: 1.2em,
    justify: true,
    spacing: 1.6em,
  )

  // 區塊引用

  show quote.where(block: true): it => {
    text(font: font-kai, it)
    v(-1em) // 抵銷多餘間距
    par(text(size: 0pt, "")) // 插入不可見的假段落，迫使下段恢復首行縮排
  }

  // 圖說
  show figure.caption: set text(font: font-kai)
  show figure.where(
    kind: image,
  ): set figure.caption(position: top)

  // ──────────────────────────────────────────────
  // § 註腳格式設定 (文內標籤黑體 + 底部懸掛縮排)
  // ──────────────────────────────────────────────
  show footnote: set text(font: font-hei)

  show footnote.entry: it => {
    set text(font: font-song, weight: "regular")
    set par(leading: 0.9em, spacing: 0.9em)

    let loc = it.note.location()
    let num-array = counter(footnote).at(loc)
    let num = if num-array.len() > 0 { num-array.first() } else { "" }

    // 使用 grid 切分兩欄，實現懸掛縮排
    // 2. 調整「註腳與註腳之間」的距離
    // 使用 block 包覆並設定 below 屬性 (這裡設為 0.6em，可視需求微調)
    block(
      width: 100%,
      inset: (bottom: 0.6em),
      grid(
        columns: (1.25em, 1fr),
        // 1.5em 為左側懸掛區塊寬度，放編號；1fr 為右側內容區塊寬度
        text(font: font-hei)[#super[#counter(footnote).display(at: loc)]],
        // 左欄：黑體字、上標數字
        it.note.body,
        // 右欄：註腳內文
      ),
    )
  }

  // 3. 標題層級設定
  show heading: set text(font: font-hei, weight: "bold")

  let ch-big-numbers = ("壹", "貳", "參", "肆", "伍", "陸", "柒", "捌", "玖", "拾")

  set heading(
    numbering: (..nums) => {
      let n = nums.pos()
      let level = n.len()
      let val = n.last()
      if level == 1 {
        if val <= 10 { ch-big-numbers.at(val - 1) + "、" } else { str(val) }
      } else if level == 2 {
        numbering("一、", ..n.slice(1))
      } else if level == 3 {
        numbering("(一) ", ..n.slice(2))
      } else if level == 4 {
        numbering("1.", ..n.slice(3))
      } else if level == 5 {
        numbering("(1) ", ..n.slice(4))
      }
    },
  )

  // ──────────────────────────────────────────────
  // 標題顯示規則：
  //   - 第一層：置中，無縮排
  //   - 第二至第四層：靠左，無縮排
  //   - 無編號（特殊頁標題）：直接輸出原樣
  // ──────────────────────────────────────────────
  show heading: it => {
    if it.numbering != none {
      let displayed = {
        counter(heading).display(it.numbering)
        it.body
      }
      if it.level == 1 {
        set align(center)
        set par(first-line-indent: 0em)
        displayed
      } else {
        set align(left)
        set par(first-line-indent: 0em)
        displayed
      }
    } else if it.body == [摘要] {
      // 模仿《臺大法學論叢》排版：中文摘要標題改為「<摘要>」字樣、楷體置中
      align(center, text(font: font-kai, weight: "regular", "<摘要>"))
    } else {
      // 無編號標題（Abstract、目錄、參考文獻）
      // 直接輸出，讓字體、大小、對齊沿用有編號標題的 show heading 設定
      it
    }
  }

  // ──────────────────────────────────────────────
  // 4. 輔助函式：渲染作者列表
  //    支援純字串或 dict (name, thanks) 兩種格式
  // ──────────────────────────────────────────────
  let render-authors(auths) = {
    let parts = auths.map(a => {
      if type(a) == dictionary {
        let n = a.at("name", default: "")
        let t = a.at("thanks", default: none)
        if t != none {
          // 以上標腳註附上作者說明
          [#n#footnote(t)]
        } else {
          [#n]
        }
      } else {
        [#str(a)]
      }
    })
    parts.join("、")
  }

  // ──────────────────────────────────────────────
  // 5. 中文封面頁（標題 + 作者 + 中文摘要 + 關鍵字）
  // ──────────────────────────────────────────────
  align(center)[
    // 主標題（含標題 thanks）
    #block(
      text(font: font-hei, weight: 700, size: 1.75em)[
        #title#if title-thanks != none { footnote(title-thanks) }
      ],
    )

    // 副標題
    #if subtitle != none and subtitle != "" [
      #v(0.5em)
      #block(text(font: font-hei, weight: "bold", size: 1.25em, subtitle))
    ]

    #v(1em)

    // 作者
    #render-authors(authors-arr)
  ]

  // 中文摘要區塊
  if abstract-zh != [] {
    v(1.5em)
    // 使用無編號標題呈現「摘要」，樣式與內文標題一致
    heading(level: 1, numbering: none)[摘要]
    v(0.5em)
    // 中文摘要字體大小與內文相同（12pt）
    set par(first-line-indent: 2em)
    abstract-zh
    if keywords-zh != none {
      v(0.5em)
      text(font: font-kai)[#text(weight: "bold")[關鍵字：]#keywords-zh]
    }
  }

  pagebreak()

  // ──────────────────────────────────────────────
  // 6. 英文封面頁（英文標題 + 作者 + 英文摘要 + 關鍵字）
  // ──────────────────────────────────────────────
  if title-en != none and title-en != "" {
    align(center)[
      // 英文主標題（含 thanks）
      #block(
        text(font: font-hei, weight: 700, size: 1.75em)[
          #title-en#if title-en-thanks != none and title-en-thanks != "" { footnote(title-en-thanks) }
        ],
      )

      // 英文副標題
      #if subtitle-en != none and subtitle-en != "" [
        #v(0.5em)
        #block(text(font: font-hei, weight: "bold", size: 1.25em, subtitle-en))
      ]

      #v(1em)

      // 英文作者
      #if authors-en-arr.len() > 0 {
        render-authors(authors-en-arr)
      } else {
        render-authors(authors-arr)
      }
    ]

    // 英文摘要
    if abstract-en != [] {
      v(1.5em)
      heading(level: 1, numbering: none)[Abstract]
      v(0.5em)
      // 英文摘要維持較小字體，但行距縮小
      pad(x: 2em)[
        #set text(size: 10pt)
        #set par(leading: 0.8em, first-line-indent: 0em)
        #abstract-en
        #if keywords-en != none {
          v(0.3em)
          text(weight: "bold")[Keywords: ]
          keywords-en
        }
      ]
    }

    // pagebreak()
  }

  // ──────────────────────────────────────────────
  // 7. 目錄頁（獨立一頁）
  // ──────────────────────────────────────────────
  // heading(level: 1, numbering: none)[目錄]
  // v(0.5em)
  outline(indent: auto, depth: 3)

  pagebreak()

  // ──────────────────────────────────────────────
  // 8. 超連結樣式
  // ──────────────────────────────────────────────
  // citrus 的 show cite 規則會把引用（含 ncite 的 prose 形式）
  // 包成 link(label(...))，即使 auto-links: false 也無法取消該
  // 引用→參考文獻的內部超連結。此處直接展開為內文，避免註腳內
  // 引用仍出現藍色底線的超連結。
  show link: it => it.body

  // ──────────────────────────────────────────────
  // 9. 輸出內文
  // ──────────────────────────────────────────────
  body

  // ──────────────────────────────────────────────
  // 10. 參考文獻
  // ──────────────────────────────────────────────
  show bibliography: set heading(outlined: false)
  bibliography(
    "ref.yml",
    style: "chicago-shortened-notes",
    title: "參考文獻",
  )
}
