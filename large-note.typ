// large-note.typ
// 大型筆記入口檔：在「壹、」之上多一層「第一章」，且每章另起新頁。
// Entry point for large notes: adds a "Chapter N" level above "壹、" and starts each chapter on a new page.

#import "common.typ": *
#import "basic-note.typ": _note-project

#let project(
  title: "", // 標題必填 / Title (required)
  title-thanks: none, // 標題註解 / Title note
  subtitle: none, // 副標題 / Subtitle
  authors: (), // 作者 / Authors
  bib: none, // 參考文獻（路徑或 bytes，選填）/ Bibliography (path or bytes, optional)
  body,
) = _note-project(
  large: true,
  title: title,
  title-thanks: title-thanks,
  subtitle: subtitle,
  authors: authors,
  bib: bib,
  body,
)
