# To generate the project

```sh
make prepare && make css && make all_but_pdf && make pdf
```

1. `make prepare` does these:
    - run `list_to_dict.ipynb` for `data2.yml`
        - `convert_slide.ipynb` to generate `slide/*.md`, `docs/slide.csv`
        - `convert.ipynb` to generate `en.md`, `en-logos.md`, `zh-Hant.md`, `zh-Hant-logos.md`.
        - `convert-bilingual.ipynb` to generate `zh-Hant-en.md`, `zh-Hant-en-logos.md`.
2. `make css` to download css for epub
3. `make all` or `make all_but_pdf && make pdf`
    - `make pdf` is separated as it often has errors to debug

# Release

```sh
make bump PART=minor
make release
# regenerate release table
make docs -B
```

# Develop

- `enumerate_data.ipynb` can be used to convert `data.yml` from list to dict with keys as the hymn number.
