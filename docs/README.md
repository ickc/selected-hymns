---
title: Selected Hymns
header-includes: |
  <script type="text/JavaScript">
    function openInNewTab() {
        var ref = document.getElementById("hymn-ref").value;
        const url='slide/' + ref + '.html';
        window.open(url, '_blank').focus();
    }
  </script>
include-after: |
  <!-- https://www.w3schools.com/howto/howto_js_trigger_button_enter.asp -->
  <script type="text/JavaScript">
    var input = document.getElementById("hymn-ref");
    input.addEventListener("keyup", function(event) {
        if (event.keyCode === 13) {
        event.preventDefault();
        document.getElementById("hymn-click").click();
        }
      }
    );
  </script>
...

Selected Hymns (詩歌選集) is a hymnal released by Tree of Life Publishers in 1995, which is later dicontinued due to copyright issue. This project is to provide a text-only version of the original hymnal. The long-term goal will be to identify the texts that has copyright issue and replaces it with one that is not.

# Recommended usage

## Install

### 繁體中文

手機用戶請從ePub一欄下載。蘋果手機用戶可用Apple Books 應用程式打開檔案，安卓手機用戶可用Google Play 圖書 應用程式打開檔案。其他用戶可以從PDF一欄下載。

請按你的語言從列中選擇所需檔案。例如你只需要中文版，請選擇中文版， 或按喜好選擇中英對照版。

```table
---
markdown: true
include: docs/download-zh-Hant.csv
...
```

### 简体中文

手机用户请从ePub一栏下载。苹果手机用户可用Apple Books 应用程式打开档案，安卓手机用户可用Google Play 图书 应用程式打开档案。其他用户可以从PDF一栏下载。

请按你的语言从列中选择所需档案。例如你只需要中文版，请选择中文版， 或按喜好选择中英对照版。

```table
---
markdown: true
include: docs/download-zh-Hans.csv
...
```

### English

If you are bilingual, see other sections above.

Mobile phone users please download from the ePub column. Apple users can open it using Apple Books, and Android users using Google Play Books. Other users can choose from the PDF column instead.

```table
---
markdown: true
include: docs/download-en.csv
...
```

## Slide

In the following box, input the hymn no., say, 16, and either hit enter on your keyboard or click the button on its right, a new tab will pops up.[^itworks]

<input type="text" placeholder="Enter hymn no.&hellip;" name="search" id="hymn-ref">
<button type="button" onclick="openInNewTab()" id="hymn-click"><i class="fa fa-search"></i></button>

In the slide, press space or arrows to advance to next slide. Type `?` in the slide for help.

# Advanced usage

## Install any formats

Download any supported formats below.

```table
---
markdown: true
include: docs/download-all.csv
...
```

## Slide listing[^itworks]

```table
---
markdown: true
header: false
include: docs/slide.csv
...
```

[^itworks]: This only works in <https://ickc.github.io/selected-hymns/>.
