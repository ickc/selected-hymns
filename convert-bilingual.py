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
from collections import defaultdict
from functools import partial
from itertools import chain

import yaml
import yamlloader

# %%

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
KEYS = ("author", "meter", "ref", "note")

# %%
LANG = ("zh", "en")

# %%
meta = """---
title:	詩歌選集　Selected Hymns
keywords:	詩歌, Hymn
lang:	zh-Hant
otherlangs: en
CJKmainfont:	Kaiti TC
CJKoptions:	BoldFont = * Bold, AutoFakeSlant
...

"""


# %%
def get_lang(obj):
    if isinstance(obj, str):
        return obj
    elif isinstance(obj, dict):
        return "　".join(obj[lang] for lang in LANG if lang in obj)
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
            return None


# %%
def get_titles(hymn):
    results = (get_title(lang, hymn) for lang in LANG)
    results = (result for result in results if result is not None)
    return "　".join(results)


# %%
def parse_stanza(dict_):
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
        head_rest = "| "

        head0 = f"\n* | " if isinstance(key, str) else f"\n{key}. | "

        head_cur = head0
        for content in value:
            temp = [content[lang] for lang in LANG if lang in content]
            temp[0] = head_cur + temp[0]
            if len(temp) > 1:
                temp[1] = head_rest + temp[1]
            result += temp
            head_cur = head_rest
    return "\n".join(result)


# %%
def parser(dict_, i, level, logos=False):
    # title
    result = ["#" * level + f" {i + 1} " + get_titles(dict_)]
    if logos:
        result.append(f"[[@Headword+en:{i + 1}]]")
    # between title and stanza
    result += [get_lang(dict_[key]) for key in KEYS if key in dict_]
    # stanza
    result.append(parse_stanza(dict_["stanza"]))
    return result


# %%
def walk(doc, level=1, result=[], logos=False):
    """walk the doc as a dict, when hit a hymn, use ``parser``,
    else add a heading and recursively walk again
    """
    for key, value in doc.items():
        # when key is int, value is a hymn
        if isinstance(key, int):
            #             print(f'find an int {key}')
            result += parser(value, key, level, logos=logos)
        # else key is a category and value is something like a doc
        else:
            #             print(f'find a category {key}')
            result.append("#" * level + " " + key)
            walk(value, level=level + 1, result=result, logos=logos)


#     return result


# %%
def write_lang(meta, data, logos=False):
    """IO wrapper of walk"""
    filename = "zh-Hant-en"
    if logos:
        filename += "-logos"
    filename += ".md"
    with open(filename, "w") as f:
        f.write(meta)
        result = []
        walk(data, result=result, logos=logos)
        for line in result:
            print(line, file=f, end="\n\n")


# %%
with open("data2.yml", "r") as f:
    data2 = yaml.load(f, Loader=yamlloader.ordereddict.CLoader)

# %%
for logos in (True, False):
    write_lang(meta, data2, logos=logos)
