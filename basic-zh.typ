// template.typ

// 字體定義（方便未來抽換特定字型）
#let font-song = ("Times New Roman", "PMingLiU")
#let font-hei = ("Arial", "Microsoft JhengHei UI")
#let font-kai = ("Times New Roman", "DFKai-SB")
#let font-yuan = ("TaiwanPearl", "Arial", "Microsoft JhengHei UI") // 來自 https://github.com/max32002/TaiwanPearl
#let font-fsong = ("Zhuque Fangsong (technical preview)", "Times New Roman", "PMingLiU") // 來自 https://github.com/TrionesType/zhuque

// 引用樣式：行內引用【範例：#inquote[被引用之文字]】
#let inquote(content) = [
  #set text(font: font-kai)
  #content
]
// 重點強調
#let keyword(content) = [
  #set text(font: font-hei, weight: bold)
  #content
]
// 教學設例
#let hypo(content) = [
  #set text(font: font-yuan)
  #content
]
// 個人想法
#let thought(content) = [
  #set text(font: font-fsong)
  #content
]

// Chinese Fonts Fake Bold
#import "@preview/cuti:0.4.0": show-cn-fakebold

// ============================================================
// § 主模板函式
// ============================================================
#let project(
  // ── 中文標題區 ──
  title: "", // 標題必填
  title-thanks: none, // 標題註解（如：本文為某計畫成果）
  subtitle: none, // 副標題，預設 none

  // ── 作者區（中文） ──
  // 每位作者為一個 dict：(name: "姓名", thanks: "職銜或說明")
  // 若不需要 thanks，可僅傳字串，或傳 (name: "姓名", thanks: none)
  authors: (),

  body,
) = {
  // ── 正規化 authors 為陣列（相容純字串、單一 dict、陣列三種傳入方式） ──
  let authors-arr = if type(authors) == array { authors } else { (authors,) }

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
    first-line-indent: 0em, // 取消首行縮排（本文件多為編號清單）
    leading: 1.2em,
    justify: true,
    spacing: 1.6em,
  )

  // 區塊引用
  show quote.where(block: true): it => text(font: font-kai, it)

  // ──────────────────────────────────────────────
  // 編號清單：依層級採臺灣公文常用格式
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
    } else {
      // 無編號標題（目錄、參考文獻）
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
  // 5. 中文封面頁（標題 + 作者）
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

  // ──────────────────────────────────────────────
  // 6. 目錄（與中文標題同頁）
  // ──────────────────────────────────────────────
  v(1.5em)
  // heading(level: 1, numbering: none)[目錄]
  // v(0.5em)
  outline(indent: auto, depth: 3)

  pagebreak()

  // ──────────────────────────────────────────────
  // 7. 超連結樣式
  // ──────────────────────────────────────────────
  // citrus 的 show cite 規則會把引用（含 ncite 的 prose 形式）
  // 包成 link(label(...))，即使 auto-links: false 也無法取消該
  // 引用→參考文獻的內部超連結。此處直接展開為內文，避免註腳內
  // 引用仍出現藍色底線的超連結。
  show link: it => it.body

  // ──────────────────────────────────────────────
  // 8. 輸出內文
  // ──────────────────────────────────────────────
  body

  // ──────────────────────────────────────────────
  // 9. 隨頁註引用（保留引用註腳，不輸出文末參考文獻清單）
  // ──────────────────────────────────────────────
  // 引用仍以註腳呈現，但不輸出文末參考文獻清單。bibliography
  // 需保留以解析內文引用鍵，此處以 show 規則隱藏其輸出。
  show bibliography: it => {}
  bibliography(
    "ref.yml",
    style: "chicago-shortened-notes",
  )
}
