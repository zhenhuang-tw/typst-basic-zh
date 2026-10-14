# typst-basic-zh

適用於 [Typst](https://typst.app/) 的繁體中文排版模板，提供三個入口檔：

| 入口檔               | 用途                                       | 引註方式                          |
| -------------------- | ------------------------------------------ | --------------------------------- |
| `basic-note.typ`     | 課堂筆記、讀書摘要、公文草稿、單篇文章     | 選用；Typst 原生，僅隨頁註        |
| `large-note.typ`     | 整學年筆記、長篇報告：在「壹、」之上分「章」 | 同上                              |
| `academic-paper.typ` | 投稿用學術論文：中英封面、摘要、參考文獻   | 必用；citrus + note 式 CSL        |

三者共用 `common.typ` 中的字體、行內樣式、註腳與標題編號，因此外觀一致。`common.typ` 不是入口檔，請勿直接匯入。

## 環境需求

1. [Typst](https://github.com/typst/typst#installation) 0.14 以上（`academic-paper.typ` 使用的 citrus 0.2.1 要求 0.14）。
2. 建議安裝下列字型。缺少時 Typst 會以其他字型替補，但外觀會不同：
   - Times New Roman、Arial
   - 微軟正黑體（`Microsoft JhengHei UI`）
   - 新細明體（`PMingLiU`）、標楷體（`DFKai-SB`）
   - [TaiwanPearl 台灣圓體](https://github.com/max32002/TaiwanPearl) 的 Light 版本（`#hypo` 使用）
   - [Zhuque Fangsong 朱雀仿宋](https://github.com/TrionesType/zhuque)（`#thought` 使用）

首次編譯時，Typst 會自動下載 `@preview/cuti`；使用 `academic-paper.typ` 時另會下載 `@preview/citrus`。

## 安裝

### 方式一：Git submodule（建議）

在你的專案根目錄執行：

```powershell
git submodule add https://codeberg.org/zhenhuang/typst-basic-zh.git typst-basic-zh
```

之後以 `#import "typst-basic-zh/basic-note.typ": *` 匯入。以下範例皆假設模板位於 `typst-basic-zh/` 資料夾。

### 方式二：直接複製

將 `common.typ` 與你要用的入口檔一起複製到專案中。入口檔都依賴 `common.typ`，`large-note.typ` 另依賴 `basic-note.typ`，缺一無法編譯。

## 快速開始

### 一般筆記（`basic-note.typ`）

```typ
#import "typst-basic-zh/basic-note.typ": *

#show: project.with(
  title: "民法債編總論筆記",
  authors: "授課老師：何孝元教授",
)

= 前言

這是一份用 Typst 撰寫的中文筆記。可以用 #keyword[重點強調] 標示重點，
或用 #hypo[教學設例] 寫下假設情境。
```

```powershell
typst compile note.typ     # 產生 note.pdf
typst watch note.typ       # 監看檔案，存檔即重新編譯
```

### 大型筆記（`large-note.typ`）

參數與 `basic-note.typ` 完全相同，只差在標題多一層「章」：

```typ
#import "typst-basic-zh/large-note.typ": *

#show: project.with(title: "全學年刑法總則筆記")

= 導論          // 第一章 導論（另起新頁）
== 問題意識     // 壹、問題意識
=== 小結        // 一、小結
```

### 學術論文（`academic-paper.typ`）

```typ
#import "typst-basic-zh/academic-paper.typ": *

#show: project.with(
  bib: read("ref.bib"),
  csl: read("tssci-q1-law.csl"),
  title: "論公法上之比例原則",
  subtitle: "以教育法為中心",
  authors: (name: "黃某", thanks: "國立臺灣大學法律學系碩士班"),
  abstract-zh: [本文探討……],
  keywords-zh: "公法、比例原則",
  title-en: "On Proportionality in Public Law",
  abstract-en: [This article examines ...],
  keywords-en: "Public Law, Proportionality",
)

= 緒論

本文探討公法問題@WangZeJian2025。#footnote[
  #ncite("LiRenMiao2023", "頁7", prefix: "可參照")。
]
```

`bib` 與 `csl` 必須由你的文件自己 `read()` 後傳入。若改由模板讀取，路徑會以模板所在的資料夾為準，模板放在 submodule 時就找不到你的檔案。

## 參數說明

各入口檔的主函式都叫 `project`，以 `#show: project.with(...)` 套用。

### `basic-note.typ`、`large-note.typ`

| 參數           | 型別                | 預設值 | 說明                                                   |
| -------------- | ------------------- | ------ | ------------------------------------------------------ |
| `title`        | 字串                | `""`   | **必填**。主標題。                                     |
| `title-thanks` | 內容／`none`        | `none` | 標題的註解，例如「本文為某計畫成果」，以腳註呈現。     |
| `subtitle`     | 內容／`none`        | `none` | 副標題。                                               |
| `authors`      | 字串／字典／陣列    | `()`   | 作者，寫法見下節。                                     |
| `bib`          | 字串／bytes／`none` | `none` | 參考文獻（`.yml` 或 `.bib`）。不傳則不載入，見下節。   |

### `academic-paper.typ`

| 參數                                | 型別             | 預設值 | 說明                                                         |
| ----------------------------------- | ---------------- | ------ | ------------------------------------------------------------ |
| `bib`                               | 字串             | —      | **必填**。`read("ref.bib")` 讀出的 BibTeX 內容。             |
| `csl`                               | 字串             | —      | **必填**。`read("xxx.csl")` 讀出的 CSL 內容，應為 note 式。  |
| `title`、`title-thanks`、`subtitle` |                  |        | 同上表。                                                     |
| `title-en`                          | 字串／`none`     | `none` | 英文標題。不填則不產生英文封面頁。                           |
| `title-en-thanks`、`subtitle-en`    | 內容／`none`     | `none` | 英文標題註解、英文副標題。                                   |
| `authors`                           | 字串／字典／陣列 | `()`   | 中文作者。                                                   |
| `authors-en`                        | 字串／字典／陣列 | `()`   | 英文作者。不填則沿用 `authors`。                             |
| `abstract-zh`、`abstract-en`        | 內容             | `[]`   | 中、英文摘要。留空則不輸出。                                 |
| `keywords-zh`、`keywords-en`        | 字串／`none`     | `none` | 中、英文關鍵字。                                             |

### 作者（`authors`）

```typ
// 1. 單純一個字串
authors: "何孝元"

// 2. 一位作者並附上職銜（以腳註呈現）
authors: (name: "何孝元", thanks: "國立臺北大學法律學系")

// 3. 多位作者，以「、」連接
authors: (
  (name: "何孝元", thanks: "國立臺北大學法律學系"),
  "蔡蔭恩",
)
```

### 筆記的參考文獻（`bib`）

筆記模板的引用一律以**腳註**呈現（`chicago-shortened-notes`），文末**不**輸出參考文獻清單。若不需要參考文獻，省略 `bib` 即可。

傳入方式依模板位置而定：

```typ
// 模板放在 submodule（建議）：由你的文件讀檔，傳入 bytes
bib: read("ref.yml", encoding: none),

// 模板與文件在同一資料夾：也可以直接傳路徑
bib: "ref.yml",
```

傳入字串時，Typst 會以**模板檔所在資料夾**解析路徑；在 submodule 架構下會指向 `typst-basic-zh/ref.yml`，因此請改傳 bytes。

### 論文的引註與參考文獻

`academic-paper.typ` 使用 [citrus](https://typst.app/universe/package/citrus) 搭配 note 式 CSL，`@key` 會自動產生腳註。

**腳註內的引用請用 `#ncite`**。在 `#footnote[...]` 裡寫 `@key`，會在腳註裡再產生一個腳註。`#ncite` 改以行內格式輸出：

```typ
#ncite("bibKey")
#ncite("bibKey", "頁5")
#ncite("bibKey", "頁5", prefix: "可參照", suffix: "之不同語境")
```

文末參考文獻依語言與類型分組。沒有文獻的分組不輸出；全文沒有任何引用時，整個參考文獻章節都不輸出：

```
參考文獻
一、英文文獻
二、中文文獻
  (一) 期刊論文
  (二) 其他
```

## 行內樣式函式

三個入口檔都會一併匯出下列函式：

| 函式           | 用途                     | 範例                           |
| -------------- | ------------------------ | ------------------------------ |
| `keyword`      | 重點強調（原字體加粗）   | `#keyword[重要]`               |
| `very-keyword` | 非常重要（黑體粗體）     | `#very-keyword[極重要]`        |
| `hypo`         | 教學設例（圓體）         | `#hypo[假設小明……]`            |
| `thought`      | 個人想法（仿宋）         | `#thought[我認為……]`           |
| `inquote`      | 行內引用（楷體）         | `#inquote[被引用之文字]`       |
| `rightNote`    | 靠右的灰色小字註解       | `#rightNote[（0218 W1 節一）]` |
| `ncite`        | 腳註內引用（僅論文模板） | 見上節                         |

## 編號規則

### 標題

| 寫法         | `basic-note`、`academic-paper` | `large-note`   |
| ------------ | ------------------------------ | -------------- |
| `= 標題`     | 壹、標題（置中）               | 第一章 標題（置中、另起新頁） |
| `== 標題`    | 一、標題                       | 壹、標題       |
| `=== 標題`   | (一) 標題                      | 一、標題       |
| `==== 標題`  | 1.標題                         | (一) 標題      |
| `===== 標題` | (1) 標題                       | 1.標題         |

### 編號清單

```typ
+ 第一項        // 1.
+ 第二項        // 2.
  + 子項        // (1)
```

依層級依序為 `1. → (1) → A. → (A) → a. → (a)`。

## 版面

**共通**：A4，左右邊距 3cm、上下 2.5cm，頁碼置中；內文新細明體 12pt；腳註文內標籤為黑體上標，頁底採懸掛縮排；圖說置於圖片上方。

| 項目     | 筆記                       | 論文                                                 |
| -------- | -------------------------- | ---------------------------------------------------- |
| 段落     | 不縮排，行距 1.1em         | 首行縮排 2 字，行距 1.2em                            |
| 首頁     | 標題、作者，其下接目錄     | 中文標題、作者、「<摘要>」、關鍵字                   |
| 其他前頁 | 無                         | 英文封面與 Abstract（填 `title-en` 時）、獨立目錄頁  |
| 文末     | 不輸出參考文獻清單         | 分組參考文獻                                         |

## 從舊版遷移

### 原本匯入 `basic-zh.typ`

`basic-zh.typ` 已移除，更新 submodule 後舊文件會無法編譯。請改為：

| 原本                                   | 改為                                        |
| -------------------------------------- | ------------------------------------------- |
| `#import "basic-zh.typ": *`            | `#import "basic-note.typ": *`               |
| 加上 `isLargeReport: true` 的文件      | `#import "large-note.typ": *`，並刪除該參數 |

### 原本使用獨立的 `template_basicPaper.typ`

1. 匯入路徑改為 `typst-basic-zh/academic-paper.typ`。
2. 在 `project.with(...)` 中加上 `bib: read("ref.bib")` 與 `csl: read("你的樣式.csl")`。
3. 原專案資料夾中的 `template_basicPaper.typ` 可以刪除。

差異：巢狀編號清單的第二層由 `1.` 改為 `(1)`；參考文獻不再重複列出英文文獻、分組編號從「一、」起算、空分組不輸出。

## 更新 submodule

在你的專案根目錄執行：

```powershell
git submodule update --remote --merge typst-basic-zh
git add typst-basic-zh
git commit -m "chore(tpl): update typst-basic-zh submodule"
```

主專案只記錄 submodule 指向的 commit，所以更新後必須把 submodule 資料夾 `git add` 並提交，其他電腦 clone 時才會取得新版。其他電腦拉取主專案後，執行 `git submodule update --init` 即可同步。
