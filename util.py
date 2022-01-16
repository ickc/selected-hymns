# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.13.6
#   kernelspec:
#     display_name: all3-intel
#     language: python
#     name: all3-intel
# ---

# %%
from functools import partial

import yaml
import yamlloader

from util.util import convert, hymn_range

# %%

# %%

# %%
KEYS = (
    "title",
    "category",
    "meter",
    "ref",
    "author",
    "note",
    "stanza",
)

# %%
list(map(convert, hymn_range()))
None

# %%
keys = set()
for num in hymn_range():
    keys |= set(
        yaml.load(
            open("data/{0:03}.yml".format(num)), Loader=yamlloader.ordereddict.CLoader
        ).keys()
    )


# %%
def get_lang(lang, data, key):
    result = data.get(key, None)
    return (
        result.get(lang, None)
        if result is not None and isinstance(result, dict)
        else result
    )


# %%
def writer(lang, num):
    with open("data/{0:03}.yml".format(num)) as f:
        data = yaml.load(f, Loader=yamlordereddictloader.Loader)

    _get_lang = partial(get_lang, lang, data)

    front_matter = list(filter(lambda x: x is not None, map(_get_lang, KEYS[:-1])))
    if front_matter:
        front_matter[0] = "# {0:03} {1}".format(num, front_matter[0])
    else:
        front_matter = ["# 0:03".format(num)]
    return "\n\n".join(front_matter)


# %%
writer("zh", 72)
