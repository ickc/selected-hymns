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
from collections import OrderedDict

import yaml
import yamlloader


# %%
def parse_category(category):
    result = category.split("——")
    temp = result[1].split("（")
    if len(temp) == 2:
        result[1] = temp[0]
        # remove closing parenthesis
        result.append(temp[1][:-1])
    return result


# %%
def push_dict(dict_, keys, key, value):
    # default to an empty OrderedDict
    if keys[0] not in dict_:
        dict_[keys[0]] = OrderedDict()
    # recursively push keys into dict_
    if len(keys) > 1:
        push_dict(dict_[keys[0]], keys[1:], key, value)
    # until no more and push key-value pair to it
    else:
        dict_[keys[0]][key] = value


# %%
with open("data.yml", "r") as f:
    data = yaml.load(f, Loader=yamlloader.ordereddict.CSafeLoader)

# %%
result = OrderedDict()
for i, datum in enumerate(data):
    categories = parse_category(datum["category"]["zh"])
    datum.pop("category", None)
    push_dict(result, categories, i, datum)

# %%
with open("data2.yml", "w") as f:
    yaml.dump(
        result,
        f,
        Dumper=yamlloader.ordereddict.CSafeDumper,
        default_flow_style=False,
        allow_unicode=True,
    )
