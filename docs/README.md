---
title: Selected Hymns
header-includes: |
    <style>
        input {
            padding: 10px;
            font-size: 16px;
            border: 1px solid #ddd;
            border-radius: 4px;
            width: 100px;
            text-align: center;
        }
        button {
            padding: 10px 15px;
            background-color: #4285f4;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            margin-left: 10px;
        }
        button:hover {
            background-color: #3367d6;
        }
        .error {
            color: red;
        }
    </style>
include-after: |
    <script>
        // Add event listener for Enter key
        document.getElementById("hymnNumber").addEventListener("keyup", function(event) {
            if (event.key === "Enter") {
                goToHymn();
            }
        });

        function goToHymn() {
            const hymnInput = document.getElementById("hymnNumber");
            const errorMessage = document.getElementById("errorMessage");
            const hymnNumber = parseInt(hymnInput.value);
            
            // Clear previous error message
            errorMessage.textContent = "";
            
            // Validate input
            if (isNaN(hymnNumber)) {
                errorMessage.textContent = "Please enter a valid number.";
                return;
            }
            
            if (hymnNumber < 1 || hymnNumber > 848) {
                errorMessage.textContent = "Please enter a number between 1 and 848.";
                return;
            }
            
            // Open hymn in a new tab
            window.open(`slide/${hymnNumber}.html`, '_blank');
            
            // Optional: clear the input field after successful navigation
            // hymnInput.value = "";
        }
    </script>
...

Selected Hymns (詩歌選集) is a hymnal released by Tree of Life Publishers in 1995, which is later discontinued due to copyright issue. This project is to provide a text-only version of the original hymnal. The long-term goal will be to identify the texts that has copyright issue and replaces it with one that is not.

# Recommended usage

## Slide

<input type="number" id="hymnNumber" min="1" max="848" placeholder="1-848">
<button onclick="goToHymn()">Go to Hymn</button>

:::{.error #errorMessage}
:::

Tips:

- [Bookmark this page](SelectedHymns.html) for the button only.
- For best viewing of the presentation, press `F` to enter full Screen, `Esc` to cancel full screen.
- For long text, scroll down using the wheel of the mouse.
- Do not zoom into the content, it will messed with the UI of the presentation.
- In the slide, press space or arrows to advance to next slide. Type `?` in the slide for help.
    - E.g. `O` can be used to jump to a slide.

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
