# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.13.5
#   kernelspec:
#     display_name: all39-conda-forge
#     language: python
#     name: all39-conda-forge
# ---

# %%
import yaml
import yamlloader

# %% [markdown]
# To

# %%
with open("data.yml", "r") as f:
    data = yaml.load(f, Loader=yamlloader.ordereddict.CSafeLoader)

# %%
data_enum = {i: datum for i, datum in enumerate(data, 1)}

# %%
with open("data-enum.yml", "w") as f:
    yaml.dump(
        data_enum,
        f,
        Dumper=yamlloader.ordereddict.CSafeDumper,
        default_flow_style=False,
        allow_unicode=True,
    )

# %% [markdown]
# From

# %%
with open("data-enum.yml", "r") as f:
    data_enum = yaml.load(f, Loader=yamlloader.ordereddict.CSafeLoader)

# %%
data = list(data_enum.values())

# %%
with open("data.yml", "w") as f:
    yaml.dump(
        data,
        f,
        Dumper=yamlloader.ordereddict.CSafeDumper,
        default_flow_style=False,
        allow_unicode=True,
    )
