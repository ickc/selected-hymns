# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.13.5
#   kernelspec:
#     display_name: all310-conda-forge
#     language: python
#     name: all310-conda-forge
# ---

# %%
from collections import defaultdict
from functools import partial
from itertools import chain

import yaml
import yamlloader

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
KEYS = ("author", "meter", "ref", "note")

# %%
LANG = ("zh", "en")

# %%
meta = {
    "en": """---
title:	Selected Hymns
keywords:	Hymn
lang:	en
otherlangs: zh-Hant
CJKmainfont:	Noto Sans CJK TC
CJKoptions:	BoldFont = * Bold, AutoFakeSlant
...

""",
    "zh": """---
title:	詩歌選集
keywords:	詩歌
lang:	zh-Hant
otherlangs: en
CJKmainfont:	Noto Sans CJK TC
CJKoptions:	BoldFont = * Bold, AutoFakeSlant
...

""",
}


# %%
def get_lang(lang, obj):
    """obtain language ``lang`` from ``obj``"""
    if isinstance(obj, str):
        return obj
    elif isinstance(obj, dict):
        if lang in obj:
            return obj[lang]
    else:
        return ""


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
            return "No Title"


# %%
def parse_stanza(lang, dict_):
    """parse ``dict_`` as a stanza while choosing only ``lang``

    stanza are dict with keys as either int or str. str is in format ``N-chorus``
    where ``N`` is any int. This int indicates the n-th stanza. And ``-chorus``
    means it is a chorus.

    In this function, Line blocks is used for each stanza, and chorus is an indented
    bullet item, stanza are enumerated items.

    return a str of stanza in markdown format
    """
    result = []
    for key, value in dict_.items():
        try:
            head_rest = "| "

            head0 = f"\n* | " if isinstance(key, str) else f"\n{key}. | "

            head_cur = head0
            for content in value:
                result.append(head_cur + content[lang])
                head_cur = head_rest
        # may occur at content[lang] when lang doesn't exist for that verse
        except KeyError:
            result.append(f"{head0}no translation.")
    return "\n".join(result)


# %%
def parser(lang, dict_, i, level, logos=False):
    # title
    result = ["#" * level + f" {i + 1} " + get_title(lang, dict_)]
    if logos:
        result.append(f"[[@Headword+en:{i + 1}]]")
    # between title and stanza
    result += [get_lang(lang, dict_[key]) for key in KEYS if key in dict_]
    # stanza
    result.append(parse_stanza(lang, dict_["stanza"]))
    return result


# %%
def walk(lang, doc, level=1, result=[], logos=False):
    """walk the doc as a dict, when hit a hymn, use ``parser``,
    else add a heading and recursively walk again
    """
    for key, value in doc.items():
        # when key is int, value is a hymn
        if isinstance(key, int):
            #             print(f'find an int {key}')
            result += parser(lang, value, key, level, logos=logos)
        # else key is a category and value is something like a doc
        else:
            #             print(f'find a category {key}')
            result.append("#" * level + " " + key)
            walk(lang, value, level=level + 1, result=result, logos=logos)


#     return result


# %%
def write_lang(meta, data, lang, logos=False):
    """IO wrapper of walk"""
    filename = "en" if lang == "en" else "zh-Hant"
    if logos:
        filename += "-logos"
    filename += ".md"
    with open(filename, "w") as f:
        f.write(meta[lang])
        result = []
        walk(lang, data, result=result, logos=logos)
        for line in result:
            print(line, file=f, end="\n\n")


# %%
with open("data2.yml", "r") as f:
    data2 = yaml.load(f, Loader=yamlloader.ordereddict.CLoader)

# %%
for lang in LANG:
    for logos in (True, False):
        write_lang(meta, data2, lang, logos=logos)
