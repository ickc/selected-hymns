# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.13.6
#   kernelspec:
#     display_name: all3-defaults
#     language: python
#     name: all3-defaults
# ---

# %%
from functools import partial
from pathlib import Path

import numpy as np
import pandas as pd
import yaml
import yamlloader
from pantable.ast import PanTableMarkdown
from pantable.util import convert_text

# %%

# %%


# %% [markdown]
# keys per hymn:
#
# stanza: dict with keys as int, or int-chorus, values as dict with key as zh, en
#
# meter: str
#
# note: dict with key as zh, en
#
# ref: dict with key as zh, en
#
# author: dict with key as en
#
# title: dict with key as en

# %%
def get_title(lang, hymn):
    """get title from hymn if exist, else get first line from stanza
    else return 'No Title'
    """
    if "title" in hymn and lang in hymn["title"]:
        return hymn["title"][lang]
    else:
        try:
            return list(hymn["stanza"].values())[0][0][lang]
        except:
            return ""


# %%
def get(lang, hymn, key="author"):
    """get key"""
    if key in hymn and lang in hymn[key]:
        return hymn[key][lang]
    else:
        return ""


# %%
def get_duolingual(func, hymn):
    return " ".join((func(lang, hymn) for lang in ("en", "zh")))


# %%
subdir = Path("slide")

# %%
subdir.mkdir(exist_ok=True)

# %%
with open("data.yml") as f:
    data = yaml.load(f, Loader=yamlloader.ordereddict.CSafeLoader)

# %%
len(data)


# %%
def hymn_to_slide(hymn):
    pages = []

    meta = []
    title = get_duolingual(get_title, hymn)
    meta.append(f"title: {title}")
    author = get_duolingual(partial(get, key="author"), hymn).strip()
    if author:
        meta.append(f"author: {author}")

    temp = "\n".join(meta)
    pages.append(
        f"""---
{temp}
..."""
    )

    info_page = []
    for key in ("meter", "note", "ref"):
        temp = get_duolingual(partial(get, key=key), hymn).strip()
        if temp:
            info_page.append(f"{key}: {temp}")
    if info_page:
        temp = "\n\n".join(info_page)
        pages.append(
            f"""# About 關於

{temp}"""
        )

    for key, stanza in hymn["stanza"].items():
        temp = []
        if type(key) is int:
            temp.append(f"# {key}")
        else:
            temp.append("# Chorus 和")
        temp.append("\n")
        for line in stanza:
            for lang in ("en", "zh"):
                if lang in line:
                    temp.append(f"| {line[lang]}")
        pages.append("\n".join(temp))
    return "\n\n".join(pages)


# %%
for i, datum in enumerate(data, 1):
    with open(subdir / f"{i}.md", "w") as f:
        print(hymn_to_slide(datum), file=f)

# %%
# PanTableMarkdown?

# %%
l = len(data)
# try 8 or 16 columns
n = 16
m = l // n
assert l == m * n
shape = (m, n)

# %%
temp = np.arange(1, len(data) + 1).reshape(shape)

# %%
res = np.empty_like(temp, dtype="O")

# %%
for i in range(m):
    for j in range(n):
        num = temp[i, j]
        res[i, j] = f"[{num}](slide/{num}.html)"

# %%
df = pd.DataFrame(res)

# %%
df.to_csv("docs/slide.csv", header=False, index=False)

# %% [raw]
# pan_table = PanTableMarkdown(res, ms=np.array([0, 0, m, 0]))

# %% [raw]
# print(convert_text(pan_table.to_pantable().to_panflute_ast(), input_format='panflute', output_format='markdown'))
