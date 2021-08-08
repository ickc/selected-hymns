#!/usr/bin/env python
'''Generate a table of URLs to different output formats in markdown in CSV.

Should be run from root where the output path is hard coded to docs/download.csv
'''
from __future__ import annotations

import os
from typing import List
from pathlib import Path

from github import Github
import pandas as pd
import defopt

VERSIONS = {
    'en': 'English',
    'zh-Hant': '繁體中文版',
    'zh-Hant-en': '繁體中英對照',
    'zh-Hans': '简体中文版',
    'zh-Hans-en': '简体中英对照',
}

FORMATS = {
    '.epub': 'ePub',
    '.pdf': 'PDF',
    '-logos.docx': 'Logos version',
    '.html': 'HTML (browser)',
}


def get_url(url_dict, format, version):
    name = f'{version}{format}'
    url = f'https://ickc.github.io/selected-hymns/{name}' if format == '.html' else url_dict[name]
    return f'[{name}]({url})'


def main(
    versions: List[str] = list(VERSIONS.keys()),
    formats: List[str] = list(FORMATS.keys()),
    output: Path = Path('docs/download-all.csv'),
):
    g = Github(os.environ['GITHUB_TOKEN'])
    repo = g.get_repo('ickc/selected-hymns')
    release = repo.get_latest_release()
    url_dict = {asset.name: asset.browser_download_url for asset in release.get_assets()}

    df = pd.DataFrame(
        [[get_url(url_dict, format, version) for format in formats] for version in versions],
        index=[VERSIONS[version] for version in versions],
        columns=[FORMATS[format] for format in formats],
    )

    df.to_csv(output)


def cli():
    defopt.run(main, strict_kwonly=False)


if __name__ == "__main__":
    cli()
