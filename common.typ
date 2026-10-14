// common.typ
// 共用定義：字體、行內樣式函式、作者與標題區塊、基本排版規則。
// Shared definitions: fonts, inline style functions, title/author blocks, and base typesetting rules.
//
// 本檔不是入口檔，請改為匯入 basic-note.typ、large-note.typ 或 academic-paper.typ。
// This is not an entry point; import basic-note.typ, large-note.typ, or academic-paper.typ instead.

// 中文字型偽粗體 / Fake bold for Chinese fonts
#import "@preview/cuti:0.4.0": show-cn-fakebold

// ============================================================
// § 字體定義（方便未來抽換特定字型）
// § Font definitions (makes it easy to swap specific fonts later)
// ============================================================
#let font-song = ("Times New Roman", "PMingLiU")
#let font-hei = ("Arial", "Microsoft JhengHei UI")
#let font-kai = ("Times New Roman", "DFKai-SB")
#let font-yuan = ("TaiwanPearl", "Arial", "Microsoft JhengHei UI") // Source: https://github.com/max32002/TaiwanPearl
#let font-fsong = ("Zhuque Fangsong (technical preview)", "Times New Roman", "PMingLiU") // Source: https://github.com/TrionesType/zhuque

// ============================================================
// § 行內樣式函式
// § Inline style functions
// ============================================================

// 行內引用 / Inline quoting. Example: #inquote[quoted text]
#let inquote(content) = {
  set text(font: font-kai)
  content
}
// 重點強調 / Emphasis
#let keyword(content) = {
  set text(weight: "bold")
  content
}
// 非常重點強調 / Strong emphasis
#let very-keyword(content) = {
  set text(font: font-hei, weight: "bold")
  content
}
// 教學設例 / Hypothetical cases
#let hypo(content) = {
  set text(font: font-yuan, weight: "light") // "light": TaiwanPearl's font weight is on the heavy side
  content
}
// 個人想法 / Personal thoughts
#let thought(content) = {
  set text(font: font-fsong)
  content
}
// 右側註解 / Right-side note, e.g. #rightNote[(0218 W1 Session 1)]
#let rightNote(content) = align(right, text(size: 0.9em, fill: luma(90), content))

// ============================================================
// § 作者與標題區塊
// § Authors and title block
// ============================================================

// 正規化 authors 為陣列（相容純字串、單一 dict、陣列三種傳入方式）
// Normalize authors into an array (accepts a plain string, a single dict, or an array)
#let normalize-authors(authors) = if type(authors) == array { authors } else { (authors,) }

// 渲染作者列表；支援純字串或 dict (name, thanks)，thanks 以腳註呈現
// Render the author list; supports a plain string or a dict (name, thanks); thanks becomes a footnote
#let render-authors(auths) = {
  let parts = auths.map(a => {
    if type(a) == dictionary {
      let n = a.at("name", default: "")
      let t = a.at("thanks", default: none)
      if t != none { [#n#footnote(t)] } else { [#n] }
    } else {
      [#str(a)]
    }
  })
  parts.join("、")
}

// 置中的標題區塊：主標題（含 thanks）、副標題、作者
// Centered title block: main title (with thanks), subtitle, authors
#let title-block(title, title-thanks: none, subtitle: none, authors: ()) = align(center)[
  #block(
    text(font: font-hei, weight: 700, size: 1.75em)[
      #title#if title-thanks != none and title-thanks != "" { footnote(title-thanks) }
    ],
  )

  #if subtitle != none and subtitle != "" [
    #v(0.5em)
    #block(text(font: font-hei, weight: "bold", size: 1.25em, subtitle))
  ]

  #v(1em)

  #render-authors(authors)
]

// ============================================================
// § 基本排版規則
// § Base typesetting rules
//
//   以 `show: common-style.with(...)` 套用。入口檔可在其後再寫
//   set 規則覆寫（例如段落縮排），較內層的 set 規則優先。
//   Apply with `show: common-style.with(...)`. Entry points may
//   override afterwards with their own set rules (e.g. paragraph
//   indent); inner set rules take precedence.
//
//   - large: 是否在最上層多加一層「第一章」（由 large-note.typ 使用）
//            Whether to add a "Chapter N" level on top (used by large-note.typ)
// ============================================================
#let common-style(title: "", authors: (), large: false, body) = {
  let author-names = normalize-authors(authors).map(a => {
    if type(a) == dictionary { a.at("name", default: "") } else { str(a) }
  })
  set document(title: title, author: author-names)

  /*
    PDF 後處理指令:
    PDF post-processing command:
    編譯後若需修改 PDF 製作者資訊，請於終端機 (Windows PowerShell) 執行：
    After compiling, to modify the PDF producer info, run this in a terminal (Windows PowerShell):
    exiftool -Producer="國立臺北大學法律學系"
  */

  // 1. 基本頁面設定 / Basic page setup
  set page(
    paper: "a4",
    margin: (x: 3cm, y: 2.5cm),
    numbering: "1",
    number-align: center,
  )

  // 2. 字體與段落設定 / Font and paragraph setup
  set text(font: font-song, size: 12pt, lang: "zh", region: "tw")

  show: show-cn-fakebold

  set par(
    first-line-indent: 0em, // 筆記預設不縮排；論文由 academic-paper.typ 覆寫 / Notes default to no indent; overridden by academic-paper.typ
    leading: 1.1em,
    justify: true,
    spacing: 1.6em,
  )

  // 區塊引用 / Block quote
  show quote.where(block: true): set text(font: font-kai)

  // 編號清單：依層級採臺灣公文常用格式 1. → (1) → A. → (A) → a. → (a)
  // Numbered list: formats common in Taiwanese official documents by level
  set enum(
    full: true,
    numbering: (..nums) => {
      let n = nums.pos()
      let pats = ("1.", "(1)", "A.", "(A)", "a.", "(a)")
      numbering(pats.at(calc.min(n.len(), pats.len()) - 1), n.last())
    },
  )
  set list(marker: ([•], [▪], [◆]))

  // 圖說 / Figure caption
  show figure.caption: set text(font: font-kai)
  show figure.where(kind: image): set figure.caption(position: top)

  // ──────────────────────────────────────────────
  // § 註腳格式設定 (文內標籤黑體 + 底部懸掛縮排)
  // § Footnote formatting (sans-serif in-text label + hanging indent at the bottom)
  // ──────────────────────────────────────────────
  show footnote: set text(font: font-hei)

  show footnote.entry: it => {
    set text(font: font-song, weight: "regular")
    set par(leading: 0.9em, spacing: 0.9em)

    let loc = it.note.location()

    // 以 grid 切兩欄實現懸掛縮排；以 block 的 bottom inset 控制註腳間距
    // A two-column grid gives the hanging indent; the block's bottom inset sets spacing between footnotes
    block(
      width: 100%,
      inset: (bottom: 0.6em),
      grid(
        columns: (1.25em, 1fr), // 左欄放編號、右欄放內文 / Left: number, right: body
        text(font: font-hei)[#super[#counter(footnote).display(at: loc)]],
        it.note.body,
      ),
    )
  }

  // 3. 標題層級設定 / Heading level setup
  show heading: set text(font: font-hei, weight: "bold")

  let ch-big-numbers = ("壹", "貳", "參", "肆", "伍", "陸", "柒", "捌", "玖", "拾")

  // large 為 true 時，於現有層級上方多加一層「章」
  // When large is true, an extra "chapter" level is added on top
  let level-offset = if large { 1 } else { 0 }

  set heading(
    numbering: (..nums) => {
      let n = nums.pos()
      let level = n.len() - level-offset
      let val = n.last()
      if large and n.len() == 1 {
        numbering("第一章 ", val)
      } else if level == 1 {
        if val <= 10 { ch-big-numbers.at(val - 1) + "、" } else { str(val) }
      } else if level == 2 {
        numbering("一、", ..n.slice(1 + level-offset))
      } else if level == 3 {
        numbering("(一) ", ..n.slice(2 + level-offset))
      } else if level == 4 {
        numbering("1.", ..n.slice(3 + level-offset))
      } else if level == 5 {
        numbering("(1) ", ..n.slice(4 + level-offset))
      }
    },
  )

  // 標題顯示規則 / Heading display rules:
  //   - 第一層：置中；large 時第一層為「章」，字級大一號、另起新頁
  //     Level 1: centered; when large, level 1 is the chapter, one size larger, on a new page
  //   - 其餘層級：靠左 / Other levels: left-aligned
  //   - 無編號（目錄、參考文獻等）：原樣輸出 / Unnumbered (TOC, references, ...): output as-is
  show heading: it => {
    if it.numbering != none {
      let displayed = {
        counter(heading).display(it.numbering)
        it.body
      }
      set par(first-line-indent: 0em)
      if it.level == 1 {
        if large {
          set text(size: 1.25em)
          pagebreak(weak: true)
        }
        set align(center)
        displayed
      } else {
        set align(left)
        displayed
      }
    } else {
      if large and it.level == 1 { pagebreak(weak: true) }
      it
    }
  }

  body
}

// ============================================================
// § 移除超連結樣式
// § Strip hyperlink styling
//
//   引用（Typst 原生 cite 或 citrus 的 cite）會被包成指向參考文獻
//   的 link，在註腳中顯示為超連結。以 `show: plain-links` 套用後，
//   其後內容的連結一律只輸出文字。請在 outline 之後才套用，
//   以免目錄失去頁內跳轉。
//   Citations (native or citrus) are wrapped in links to the
//   bibliography and show up as hyperlinks in footnotes. After
//   `show: plain-links`, links in the following content render as
//   plain text. Apply it after the outline so the TOC keeps its jumps.
// ============================================================
#let plain-links(body) = {
  show link: it => it.body
  body
}
