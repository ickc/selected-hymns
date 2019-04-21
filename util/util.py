from collections import OrderedDict
import os

ZH_NUM = ('一', '二', '三', '四', '五', '六', '七', '八', '九', '十', '十一', '十二', '十三', '十四', '十五', '十六', '十七')
NUM_TO_ZH = tuple([''] + list(ZH_NUM))
ZH_TO_NUM = {zh: num for num, zh in enumerate(ZH_NUM, 1)}

METER = set(map(str, range(10))) | set(('.', 'D', ' ', '(', ')', 'I', 'A'))
METER_TYPE = {'with repeat': '重', 'with chorus': '和'}


def hymn_range():
    '''return a range object ranging through the hymn no.
    '''
    return range(1, 849)
