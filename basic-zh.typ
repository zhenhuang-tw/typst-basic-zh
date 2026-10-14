// basic-zh.typ
// Document in Traditional Chinese:
// https://codeberg.org/zhenhuang/typst-basic-zh/src/branch/main/README-zh.md

#import "common.typ": *

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
  // 參考文獻檔（選填）/ Bibliography file (optional)
  bib: none,
  // 是否為大型報告：多一層「第一章」並每章另起新頁
  // Large report: adds a "Chapter N" level and starts each chapter on a new page
  isLargeReport: false,
  body,
) = {
  show: common-style.with(title: title, authors: authors, large: isLargeReport)

  title-block(title, title-thanks: title-thanks, subtitle: subtitle, authors: normalize-authors(authors))

  // 目錄（與標題同頁）/ Table of contents (on the same page as the title)
  v(1.5em)
  outline(indent: auto, depth: if isLargeReport { 4 } else { 3 })

  pagebreak()

  show: plain-links

  body

  // 隨頁註引用：載入參考文獻以解析引用鍵，但隱藏文末清單
  // Footnote citations: load the bibliography to resolve keys, but hide the list at the end
  if bib != none {
    show bibliography: it => {}
    bibliography(bib, style: "chicago-shortened-notes")
  }
}
