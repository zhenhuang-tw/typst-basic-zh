// basic-zh.typ

// 字體定義（方便未來抽換特定字型）
// Font definitions (makes it easy to swap specific fonts later)
#let font-song = ("Times New Roman", "PMingLiU")
#let font-hei = ("Arial", "Microsoft JhengHei UI")
#let font-kai = ("Times New Roman", "DFKai-SB")
#let font-yuan = ("TaiwanPearl", "Arial", "Microsoft JhengHei UI") // Source: https://github.com/max32002/TaiwanPearl
#let font-fsong = ("Zhuque Fangsong (technical preview)", "Times New Roman", "PMingLiU") // Source: https://github.com/TrionesType/zhuque

// For inline quoting. Example: #inquote[quoted text]
#let inquote(content) = [
  #set text(font: font-kai)
  #content
]
// Emphasis 重點強調
#let keyword(content) = [
  #set text(weight: "bold")
  #content
]
// Strong emphasis 非常重點強調
#let very-keyword(content) = [
  #set text(font: font-hei, weight: "bold")
  #content
]
// Hypothetical Cases 教學設例
#let hypo(content) = [
  #set text(font: font-yuan, weight: "light") // "light": Because TaiwanPearl's font weight is on the heavy side
  #content
]
// Personal thoughts 個人想法
#let thought(content) = [
  #set text(font: font-fsong)
  #content
]

// 中文字型偽粗體 / Fake bold for Chinese fonts
#import "@preview/cuti:0.4.0": show-cn-fakebold

// ============================================================
// § 主模板函式
// § Main template function
// ============================================================
#let project(
  // ── 中文標題區 ──
  // ── Chinese title section ──
  title: "", // 標題必填 / Title (required)
  title-thanks: none, // 標題註解（如：本文為某計畫成果）/ Title note (e.g., "This article is the result of a project")
  subtitle: none, // 副標題，預設 none / Subtitle, defaults to none

  // ── 作者區（中文） ──
  // ── Author section (Chinese) ──
  // 每位作者為一個 dict：(name: "姓名", thanks: "職銜或說明")
  // Each author is a dict: (name: "Name", thanks: "Affiliation or note")
  // 若不需要 thanks，可僅傳字串，或傳 (name: "姓名", thanks: none)
  // If thanks is not needed, pass just a string, or (name: "Name", thanks: none)
  authors: (),

  body,
) = {
  // ── 正規化 authors 為陣列（相容純字串、單一 dict、陣列三種傳入方式） ──
  // ── Normalize authors into an array (accepts a plain string, a single dict, or an array) ──
  let authors-arr = if type(authors) == array { authors } else { (authors,) }

  // ── 取出作者姓名（用於 PDF 元資料） ──
  // ── Extract author names (used for PDF metadata) ──
  let author-names = authors-arr.map(a => {
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

  // 1. 基本頁面設定
  // 1. Basic page setup
  set page(
    paper: "a4",
    margin: (x: 3cm, y: 2.5cm),
    numbering: "1",
    number-align: center,
  )

  // 2. 字體與段落設定
  // 2. Font and paragraph setup
  set text(
    font: font-song,
    size: 12pt,
    lang: "zh",
    region: "tw",
  )

  show: show-cn-fakebold

  set par(
    first-line-indent: 0em, // 取消首行縮排（本文件多為編號清單）/ Remove first-line indent (this document is mostly numbered lists)
    leading: 1.2em,
    justify: true,
    spacing: 1.6em,
  )

  // 區塊引用
  // Block quote
  show quote.where(block: true): it => text(font: font-kai, it)

  // ──────────────────────────────────────────────
  // 編號清單：依層級採臺灣公文常用格式
  // Numbered list: uses formats common in Taiwanese official documents by level
  //   1. → (1) → A. → (A) → a. → (a)
  // ──────────────────────────────────────────────
  set enum(
    full: true,
    numbering: (..nums) => {
      let n = nums.pos()
      let pats = ("1.", "(1)", "A.", "(A)", "a.", "(a)")
      numbering(pats.at(calc.min(n.len(), pats.len()) - 1), n.last())
    },
  )
  set list(marker: ([•], [▪], [◆]))

  // 圖說
  // Figure caption
  show figure.caption: set text(font: font-kai)
  show figure.where(
    kind: image,
  ): set figure.caption(position: top)

  // ──────────────────────────────────────────────
  // § 註腳格式設定 (文內標籤黑體 + 底部懸掛縮排)
  // § Footnote formatting (bold sans-serif in-text label + hanging indent at the bottom)
  // ──────────────────────────────────────────────
  show footnote: set text(font: font-hei)

  show footnote.entry: it => {
    set text(font: font-song, weight: "regular")
    set par(leading: 0.9em, spacing: 0.9em)

    let loc = it.note.location()
    let num-array = counter(footnote).at(loc)
    let num = if num-array.len() > 0 { num-array.first() } else { "" }

    // 使用 grid 切分兩欄，實現懸掛縮排
    // Use a grid to split into two columns to achieve a hanging indent
    // 2. 調整「註腳與註腳之間」的距離
    // 2. Adjust the spacing between footnotes
    // 使用 block 包覆並設定 below 屬性 (這裡設為 0.6em，可視需求微調)
    // Wrap in a block and set the below property (set to 0.6em here; adjust as needed)
    block(
      width: 100%,
      inset: (bottom: 0.6em),
      grid(
        columns: (1.25em, 1fr),
        // 1.5em 為左側懸掛區塊寬度，放編號；1fr 為右側內容區塊寬度
        // 1.5em is the width of the left hanging block holding the number; 1fr is the width of the right content block
        text(font: font-hei)[#super[#counter(footnote).display(at: loc)]],
        // 左欄：黑體字、上標數字
        // Left column: sans-serif, superscript number
        it.note.body,
        // 右欄：註腳內文
        // Right column: footnote body text
      ),
    )
  }

  // 3. 標題層級設定
  // 3. Heading level setup
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
  // Heading display rules:
  //   - 第一層：置中，無縮排
  //   - Level 1: centered, no indent
  //   - 第二至第四層：靠左，無縮排
  //   - Levels 2 to 4: left-aligned, no indent
  //   - 無編號（特殊頁標題）：直接輸出原樣
  //   - Unnumbered (special page titles): output as-is
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
    } else {
      // 無編號標題（目錄、參考文獻）
      // Unnumbered headings (table of contents, references)
      // 直接輸出，讓字體、大小、對齊沿用有編號標題的 show heading 設定
      // Output directly, letting font, size, and alignment inherit from the show heading rule for numbered headings
      it
    }
  }

  // ──────────────────────────────────────────────
  // 4. 輔助函式：渲染作者列表
  // 4. Helper function: render the author list
  //    支援純字串或 dict (name, thanks) 兩種格式
  //    Supports both a plain string and a dict (name, thanks)
  // ──────────────────────────────────────────────
  let render-authors(auths) = {
    let parts = auths.map(a => {
      if type(a) == dictionary {
        let n = a.at("name", default: "")
        let t = a.at("thanks", default: none)
        if t != none {
          // 以上標腳註附上作者說明
          // Attach the author note as a superscript footnote
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
  // 5. 中文封面頁（標題 + 作者）
  // 5. Chinese cover page (title + authors)
  // ──────────────────────────────────────────────
  align(center)[
    // 主標題（含標題 thanks）
    // Main title (including the title thanks note)
    #block(
      text(font: font-hei, weight: 700, size: 1.75em)[
        #title#if title-thanks != none { footnote(title-thanks) }
      ],
    )

    // 副標題
    // Subtitle
    #if subtitle != none and subtitle != "" [
      #v(0.5em)
      #block(text(font: font-hei, weight: "bold", size: 1.25em, subtitle))
    ]

    #v(1em)

    // 作者
    // Authors
    #render-authors(authors-arr)
  ]

  // ──────────────────────────────────────────────
  // 6. 目錄（與中文標題同頁）
  // 6. Table of contents (on the same page as the Chinese title)
  // ──────────────────────────────────────────────
  v(1.5em)
  // heading(level: 1, numbering: none)[目錄]
  // v(0.5em)
  outline(indent: auto, depth: 3)

  pagebreak()

  // ──────────────────────────────────────────────
  // 7. 超連結樣式
  // 7. Hyperlink styling
  // ──────────────────────────────────────────────
  // citrus 的 show cite 規則會把引用（含 ncite 的 prose 形式）
  // citrus's show cite rule wraps citations (including the prose form of ncite)
  // 包成 link(label(...))，即使 auto-links: false 也無法取消該
  // into link(label(...)); even with auto-links: false, that internal
  // 引用→參考文獻的內部超連結。此處直接展開為內文，避免註腳內
  // citation-to-bibliography hyperlink cannot be removed. Here we unwrap it into the body text
  // 引用仍出現藍色底線的超連結。
  // to avoid blue underlined hyperlinks still appearing on citations inside footnotes.
  show link: it => it.body

  // ──────────────────────────────────────────────
  // 8. 輸出內文
  // 8. Output the body
  // ──────────────────────────────────────────────
  body

  // ──────────────────────────────────────────────
  // 9. 隨頁註引用（保留引用註腳，不輸出文末參考文獻清單）
  // 9. Footnote citations (keep citation footnotes; do not output the bibliography at the end)
  // ──────────────────────────────────────────────
  // 引用仍以註腳呈現，但不輸出文末參考文獻清單。bibliography
  // Citations are still shown as footnotes, but the bibliography at the end is not output. bibliography
  // 需保留以解析內文引用鍵，此處以 show 規則隱藏其輸出。
  // must be kept to resolve in-text citation keys; here a show rule hides its output.
  show bibliography: it => {}
  bibliography(
    "ref.yml",
    style: "chicago-shortened-notes",
  )
}
