// academic-paper.typ
// 學術論文入口檔：中英封面、摘要、目錄、note 式 CSL 引註、分類參考文獻。
// Entry point for academic papers: bilingual cover, abstracts, outline,
// note-style CSL citations, and a categorized bibliography.

#import "common.typ": *
#import "@preview/citrus:0.2.1": csl-bibliography, get-cited-entries, init-csl, init-csl-json, multicite

// ============================================================
// § 腳註內引用指令（非遞迴版）
// § Citations inside footnotes (non-recursive)
//
//   【背景】本模板採用 note 格式 CSL，引用時會自動產生腳註。若在
//   #footnote[...] 內再使用 @key，CSL 會再次插入腳註，造成「遞迴引註」。
//   [Background] With a note-style CSL, every citation produces a
//   footnote. Using @key inside #footnote[...] would nest footnotes.
//
//   【解法】以 cite(form: "prose") 輸出行內格式，不觸發 note-layout。
//   [Fix] cite(form: "prose") renders inline and does not create a footnote.
//
//   【用法 / Usage】
//   #ncite("bibKey")
//   #ncite("bibKey", "頁5")
//   #ncite("bibKey", "頁5", prefix: "可參照", suffix: "之不同語境")
//
//   【範例 / Example】
//   #footnote[
//     #ncite("WangZeJian2025", "頁12", prefix: "可參照")；
//     並請比對 #ncite("LiRenMiao2023", "頁7", suffix: "之不同語境")。
//   ]
// ============================================================
#let ncite(bibKey, ..args, prefix: none, suffix: none) = {
  let location = args.pos().at(0, default: none)

  if prefix != none { prefix }

  // 以獨立作用域 [ ... ] 讓 show rule 只作用於這筆引用；內部不可有空行，以免產生 parbreak
  // An isolated scope [ ... ] limits the show rules to this citation; no blank lines inside, to avoid parbreaks
  [#show regex("[。.]?\s*[(]"): "" // 消除作者後的句號與左括號 / Remove the period and "(" after the author
    #show regex("[。.]?[)]$"): "" // 消除句尾的句號與右括號 / Remove the trailing period and ")"
    #if location != none { cite(label(bibKey), supplement: location, form: "prose") } else {
      cite(label(bibKey), form: "prose")
    } ]

  if suffix != none { suffix }
}

// ============================================================
// § Footnote-citation shorthand
//
//   [Purpose] Equivalent to #footnote[#ncite(...)。]: a footnote that
//   contains exactly one citation.
//
//   【Usage】 Same arguments as ncite, plus period
//   #ncitef("bibKey")
//   #ncitef("bibKey", "頁5")
//   #ncitef("bibKey", "頁5", prefix: "可參照", suffix: "之不同語境")
//   #ncitef("bibKey", "at 5", period: ".")   // 英文文獻：半形句號 / English source: half-width period
//   #ncitef("bibKey", period: none)          // 不加句號 / No trailing period
//
//   【注意】period 預設為全形「。」，會接在 suffix 之後；
//   若 suffix 已以標點結尾，請傳入 period: none，以免重複。
//   [Note] period defaults to "。" and follows suffix; if suffix already
//   ends with punctuation, pass period: none to avoid doubling.
// ============================================================
#let ncitef(bibKey, ..args, prefix: none, suffix: none, period: "。") = footnote[
  #ncite(bibKey, ..args, prefix: prefix, suffix: suffix)#period
]

// ============================================================
// § 主模板函式
// § Main template function
// ============================================================
#let project(
  // ── 引註資料（必填）/ Citation data (required) ──
  // bib：書目檔路徑，依副檔名決定格式：.json 為 CSL-JSON，其餘為 BibTeX。
  //   檔案由本模板讀取，請以「/」開頭表示專案根目錄，例如 bib: "/references.json"；
  //   不以「/」開頭時，會以本模板所在目錄為準，submodule 下會找不到檔案。
  // bib: path to the bibliography file; the extension decides the format:
  //   .json is CSL-JSON, anything else is BibTeX. This template reads the file,
  //   so start the path with "/" for the project root, e.g. bib: "/references.json";
  //   otherwise it resolves against this template's directory.
  // csl：由呼叫端讀檔後傳入內容，例如 csl: read("tssci-q1-law.csl")。
  // csl: file contents read by the caller, e.g. csl: read("style.csl").
  bib: none,
  csl: none,

  // ── 中文標題區 / Chinese title ──
  title: "",
  title-thanks: none,
  subtitle: none,

  // ── 英文標題區（均得免填）/ English title (all optional) ──
  title-en: none,
  title-en-thanks: none,
  subtitle-en: none,

  // ── 作者 / Authors ──
  authors: (),
  authors-en: (),

  // ── 摘要與關鍵字 / Abstracts and keywords ──
  abstract-zh: [],
  keywords-zh: none, // 例如 "公法、教育法、比例原則"
  abstract-en: [],
  keywords-en: none, // e.g. "Public Law, Education Law"

  body,
) = {
  assert(bib != none, message: "academic-paper: 請傳入 bib: \"/ref.bib\" / pass bib: \"/ref.bib\"")
  assert(csl != none, message: "academic-paper: 請傳入 csl: read(\"style.csl\") / pass csl: read(\"style.csl\")")

  let init = if bib.ends-with(".json") { init-csl-json } else { init-csl }
  // 去除開頭的 UTF-8 BOM：Windows 上部分工具（如 Windows PowerShell 5.1 的
  // Out-File -Encoding utf8）會寫入 BOM，citrus 解析 JSON 時會因此失敗。
  // Strip a leading UTF-8 BOM: some Windows tools write one, and citrus
  // then fails to parse the JSON.
  let data = read(bib).trim("\u{feff}", at: start)

  // auto-links 會把整筆註腳加上連結到參考文獻區
  // auto-links would link each whole footnote to the bibliography
  show: init.with(data, csl, locales: (:), auto-links: false)

  show: common-style.with(title: title, authors: authors)

  // 論文段落：首行縮排、行距較寬 / Paper paragraphs: first-line indent, wider leading
  set par(first-line-indent: 2em, leading: 1.2em)

  // 區塊引用後，迫使下一段恢復首行縮排
  // After a block quote, force the next paragraph to keep its first-line indent
  show quote.where(block: true): it => {
    it
    v(-1em) // 抵銷多餘間距 / Cancel the extra spacing
    par(text(size: 0pt, "")) // 不可見的假段落 / Invisible dummy paragraph
  }

  // 仿《臺大法學論叢》：中文摘要標題顯示為楷體置中的「<摘要>」
  // Following National Taiwan University Law Journal: the Chinese abstract heading shows "<摘要>" in Kai, centered
  show heading.where(numbering: none, body: [摘要]): _ => align(
    center,
    text(font: font-kai, size: 13pt, weight: "regular", "<摘要>"),
  )

  let authors-arr = normalize-authors(authors)
  let authors-en-arr = normalize-authors(authors-en)

  // ── 中文封面頁 / Chinese cover page ──
  title-block(title, title-thanks: title-thanks, subtitle: subtitle, authors: authors-arr)

  if abstract-zh != [] {
    v(1.5em)
    heading(level: 1, numbering: none)[摘要]
    v(0.5em)
    abstract-zh
    if keywords-zh != none {
      v(0.5em)
      text(font: font-kai)[#text(weight: "bold")[關鍵字：]#keywords-zh]
    }
  }

  pagebreak()

  // ── 英文封面頁 / English cover page ──
  if title-en != none and title-en != "" {
    title-block(
      title-en,
      title-thanks: title-en-thanks,
      subtitle: subtitle-en,
      authors: if authors-en-arr.len() > 0 { authors-en-arr } else { authors-arr },
    )

    if abstract-en != [] {
      v(1.5em)
      heading(level: 1, numbering: none)[Abstract]
      v(0.5em)
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

    pagebreak()
  }

  // ── 目錄（獨立一頁）/ Table of contents (own page) ──
  // depth: 3 只收錄到「(一)」層 / depth: 3 stops at the "(一)" level
  outline(indent: auto, depth: 3)

  pagebreak()

  show: plain-links

  body

  // ── 參考文獻 / Bibliography ──
  // 沒有任何文獻的分類不輸出標題；完全沒有引用時，整個參考文獻章節都不輸出
  // Groups without entries are omitted; with no citations at all, the whole section is omitted
  context {
    let entries = get-cited-entries()
    if entries.len() == 0 { return }

    let group(level, title, items) = if items.len() > 0 {
      heading(level: level, outlined: false, title)
      for e in items [
        #e.rendered-body #e.ref-label
        #parbreak()
      ]
    }

    let en = entries.filter(e => e.lang == "en")
    let zh-journal = entries.filter(e => e.lang == "zh" and e.entry-type == "article")
    let others = entries.filter(e => {
      not (e.lang == "en" or (e.lang == "zh" and e.entry-type == "article"))
    })

    heading(level: 1, numbering: none, outlined: false)[參考文獻]
    // 無編號的第一層標題不會推進計數器；歸零後，下方分類才會從「一、」「(一)」重新起算
    // An unnumbered level-1 heading does not step the counter; reset it so the groups below restart at 一、 and (一)
    counter(heading).update(0)

    group(2, [英文文獻], en)
    if zh-journal.len() + others.len() > 0 {
      heading(level: 2, outlined: false)[中文文獻]
      group(3, [期刊論文], zh-journal)
      group(3, [其他], others)
    }
  }
}
