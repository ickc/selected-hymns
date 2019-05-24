#!/usr/bin/env python
'''Generate a table of URLs to different output formats in markdown in CSV.

Should be run from root where the output path is hard coded to docs/download.csv
'''
import os
from collections import OrderedDict

from github import Github
import pandas as pd

versions = {
    'en': 'English',
    'zh-Hant': '繁體中文版',
    'zh-Hant-en': '繁體中英對照',
    'zh-Hans': '简体中文版',
    'zh-Hans-en': '简体中英对照',
}

formats = {
    '.epub': 'ePub^[for mobile such as Apple Books or Google Play Books]',
    '.pdf': 'PDF',
    '-logos.docx': 'Logos version',
    '.html': 'HTML (browser)',
}


def get_url(url_dict, format, version):
    name = f'{version}{format}'
    url = f'https://ickc.github.io/selected-hymns/{name}' if format == '.html' else url_dict[name]
    return f'[{name}]({url})'


if __name__ == "__main__":
    g = Github(os.environ['GITHUB_TOKEN'])
    repo = g.get_repo('ickc/selected-hymns')
    release = repo.get_latest_release()
    url_dict = {asset.name: asset.browser_download_url for asset in release.get_assets()}

    df = pd.DataFrame(
        [[get_url(url_dict, format, version) for format in formats] for version in versions],
        index=versions.values(),
        columns=formats.values()
    )

    df.to_csv('docs/download.csv')
