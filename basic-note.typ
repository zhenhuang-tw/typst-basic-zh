// basic-note.typ
// 一般筆記入口檔：課堂筆記、讀書摘要、公文草稿、單篇文章。
// Entry point for ordinary notes: class notes, reading summaries, draft documents, standalone articles.

#import "common.typ": *

// ============================================================
// § 筆記專用行內樣式函式（論文模板不提供）
// § Note-only inline style functions (not provided by the paper template)
// ============================================================

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
// § 筆記版面（basic-note 與 large-note 共用，請勿直接呼叫）
// § Note layout (shared by basic-note and large-note; do not call directly)
// ============================================================
#let _note-project(
  large: false,
  title: "",
  title-thanks: none,
  subtitle: none,
  authors: (),
  bib: none,
  body,
) = {
  show: common-style.with(title: title, authors: authors, large: large)

  title-block(title, title-thanks: title-thanks, subtitle: subtitle, authors: normalize-authors(authors))

  // 目錄（與標題同頁）/ Table of contents (on the same page as the title)
  v(1.5em)
  outline(indent: auto, depth: if large { 4 } else { 3 })

  pagebreak()

  show: plain-links

  body

  // 隨頁註引用：載入參考文獻以解析引用鍵，但隱藏文末清單。
  // 傳入字串時，路徑以「本檔所在目錄」為準；若模板位於 submodule，
  // 請改傳 read("ref.yml", encoding: none) 讀出的 bytes。
  // Footnote citations: load the bibliography to resolve keys, but hide the list at the end.
  // A string is a path relative to THIS file's directory; when the template lives in a
  // submodule, pass bytes from read("ref.yml", encoding: none) instead.
  if bib != none {
    show bibliography: it => {}
    bibliography(bib, style: "chicago-shortened-notes")
  }
}

// ============================================================
// § 主模板函式
// § Main template function
// ============================================================
#let project(
  title: "", // 標題必填 / Title (required)
  title-thanks: none, // 標題註解 / Title note
  subtitle: none, // 副標題 / Subtitle
  // 每位作者為字串或 dict：(name: "姓名", thanks: "職銜或說明")
  // Each author is a string or a dict: (name: "Name", thanks: "Affiliation or note")
  authors: (),
  bib: none, // 參考文獻（路徑或 bytes，選填）/ Bibliography (path or bytes, optional)
  body,
) = _note-project(
  large: false,
  title: title,
  title-thanks: title-thanks,
  subtitle: subtitle,
  authors: authors,
  bib: bib,
  body,
)
