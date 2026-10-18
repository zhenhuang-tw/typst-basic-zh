# typst-basic-zh

Traditional Chinese templates for [Typst](https://typst.app/), with three entry points:

| Entry point          | For                                                        | Citations                             |
| -------------------- | ---------------------------------------------------------- | ------------------------------------- |
| `basic-note.typ`     | Class notes, reading summaries, draft documents, articles  | Optional; native Typst, footnotes only |
| `large-note.typ`     | Year-long notes and long reports, with chapters above 壹、 | Same as above                         |
| `academic-paper.typ` | Journal papers: bilingual cover, abstracts, bibliography   | Required; citrus with a note-style CSL; BibTeX or CSL-JSON |

All three share fonts, inline styles, footnotes, and heading numbering from `common.typ`. `common.typ` is not an entry point; do not import it directly.

The Chinese README, [README-zh.md](README-zh.md), is the full manual. This file covers the essentials.

## Requirements

1. [Typst](https://github.com/typst/typst#installation) 0.14 or later (citrus 0.2.1, used by `academic-paper.typ`, requires 0.14).
2. Recommended fonts. Typst substitutes missing fonts, but the output will look different:
   - Times New Roman, Arial
   - Microsoft JhengHei UI, PMingLiU, DFKai-SB
   - [TaiwanPearl](https://github.com/max32002/TaiwanPearl) Light (used by `#hypo`)
   - [Zhuque Fangsong](https://github.com/TrionesType/zhuque) (used by `#thought`)

Typst downloads `@preview/cuti` on first compile, and `@preview/citrus` for `academic-paper.typ`.

## Installation

Recommended: add the repository as a Git submodule in your project root.

```powershell
git submodule add https://codeberg.org/zhenhuang/typst-basic-zh.git typst-basic-zh
```

Alternatively, copy `common.typ` together with the entry point you need. Every entry point depends on `common.typ`, and `large-note.typ` also depends on `basic-note.typ`.

## Quick start

### Notes

```typ
#import "typst-basic-zh/basic-note.typ": *   // or large-note.typ

#show: project.with(
  title: "民法債編總論筆記",
  authors: "授課老師：何孝元教授",
  bib: read("ref.yml", encoding: none),      // optional
)

= 前言

Use #keyword[emphasis] or #hypo[a hypothetical case] inline.
```

```powershell
typst compile note.typ
```

`basic-note.typ` and `large-note.typ` take the same parameters: `title`, `title-thanks`, `subtitle`, `authors`, `bib`. Citations appear as footnotes (`chicago-shortened-notes`), and no bibliography list is printed.

### Academic paper

```typ
#import "typst-basic-zh/academic-paper.typ": *

#show: project.with(
  bib: "/ref.bib",                  // or "/references.json"
  csl: read("my-style.csl"),
  title: "論公法上之比例原則",
  authors: (name: "黃某", thanks: "NTU College of Law"),
  abstract-zh: [...],
  keywords-zh: "公法、比例原則",
  title-en: "On Proportionality in Public Law",
  abstract-en: [...],
  keywords-en: "Public Law",
)
```

Inside a footnote, cite with `#ncite("key", "頁5", prefix: "...", suffix: "...")` instead of `@key`, which would nest a footnote inside the footnote.

`bib` is a path; its extension decides the format: `.json` is CSL-JSON, anything else is BibTeX. A leading UTF-8 BOM is stripped.

The bibliography is grouped into 英文文獻, then 中文文獻 with 期刊論文 and 其他. Empty groups are omitted.

## Paths in a submodule

Typst resolves a path against the file that reads it, which here is the template. When the template is a submodule, `bib: "ref.yml"` therefore points to `typst-basic-zh/ref.yml`. Either read the file in your own document and pass the contents, or pass a path starting with `/`, which resolves against the project root:

- notes: `read("ref.yml", encoding: none)`
- paper: `bib: "/ref.bib"` or `bib: "/references.json"`, and `csl: read("style.csl")`

## Migrating

- `basic-zh.typ` has been removed. Import `basic-note.typ` instead, or `large-note.typ` if you set `isLargeReport: true`, and drop that parameter.
- If you used the standalone `template_basicPaper.typ`, import `academic-paper.typ` instead and add the `bib` and `csl` parameters.
- `academic-paper.typ` now takes `bib` as a path: replace `bib: read("ref.bib")` with `bib: "/ref.bib"`.

## Updating the submodule

```powershell
git submodule update --remote --merge typst-basic-zh
git add typst-basic-zh
git commit -m "chore(tpl): update typst-basic-zh submodule"
```
