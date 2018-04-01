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


def get_filename(lang, num):
    '''return the relative path of the md file
    '''
    return os.path.join(lang, '{0:03}.md'.format(num))


def read_md(num):
    '''read the ``num``-th hymn with minimal cleanup
    '''
    lines = {}
    for lang in ('zh-Hant', 'en'):
        # use short-form lang
        lng = lang[:2]
        with open(get_filename(lang, num), 'r') as f:
            # split and remove empty white spaces
            lines[lng] = list(filter(lambda x: (x != ''), (ln.strip().strip(u'\xad') for ln in f)))
    return lines


def parse_to_list(num, lines):
    '''process the output of read_md
    to construct a universal index for both lang
    and split each hymn into title, stanza, and chorus
    return idxs, value
    where idxs, value['zh'], value['en'] are of the same length
    and idxs starts with 'title', and the remaining ones are of
    the format (INT, STR) where the INT is the n-th stanza,
    STR is either '' or 'chorus'
    '''
    idx = {}
    value = {}
    for lng in ('zh', 'en'):
        # parse into title, stanza
        idxs = []
        values = []
        for ln in lines[lng]:
            # title
            if ln.startswith('#'):
                idxs.append('title')
                ln2 = ln.lstrip('#').lstrip()
                assert int(ln2[:3]) == num
                values.append([ln2[3:].lstrip()])
                del ln2
            # stanza
            elif lng == 'en':
                # no translation case
                if 'No English translation' in ln:
                    idxs.append('unknown')
                    values.append(None)
                # stanza begins with start with numerical
                else:
                    ln2 = ln.split('.')
                    try:
                        idxs.append(int(ln2[0]))
                        values.append(['.'.join(ln2[1:]).strip()])
                    except ValueError:
                        values[-1].append(ln)
                    del ln2
            else: # if lng == 'zh':
                # no translation case
                if '無中文' in ln:
                    idxs.append('unknown')
                    values.append(None)
                # stanza begins with start with numerical
                elif ln.startswith('（') and ln[1:].startswith(ZH_NUM):
                    ln2 = ln[1:].split('）')
                    try:
                        idxs.append(ZH_TO_NUM[ln2[0]])
                        values.append(['）'.join(ln2[1:]).strip()])
                    except KeyError:
                        values[-1].append(ln)
                    del ln2
                # alternative syntax for zh num
                else:
                    ln2 = ln.split('、')
                    try:
                        idxs.append(ZH_TO_NUM[ln2[0]])
                        values.append(['、'.join(ln2[1:]).strip()])
                    except KeyError:
                        ln2 = ln.split('.')
                        try:
                            idxs.append(int(ln2[0]))
                            values.append(['.'.join(ln2[1:]).strip()])
                        except ValueError:
                            values[-1].append(ln)
                    del ln2
        idx[lng] = idxs
        value[lng] = values
        del ln, idxs, values
    del lng, lines

    assert len(idx['en']) == len(idx['zh']) == len(value['en']) == len(value['zh'])

    # 1 stanza only case
    if len(idx['en']) == 1:
        for lng in ('en', 'zh'):
            idx[lng].append(1)
            value[lng] = [[value[lng][0][0]], value[lng][0][1:]]
        del lng

    # unify idxs
    idxs = []
    for idx_en, idx_zh in zip(idx['en'], idx['zh']):
        if idx_en == idx_zh:
            idxs.append(idx_en)
        else:
            temp = [idx_en, idx_zh]
            temp.remove('unknown')
            idxs.append(temp[0])
            del temp
    del idx_en, idx_zh, idx
    # assert idxs in right order
    assert idxs[0] == 'title'
    assert idxs[1:] == list(range(1, len(idxs)))

    # assert title is 1 line or less
    for lng in ('zh', 'en'):
        assert len(value[lng][0]) <= 1
    del lng

    # extract chorus
    # iterate from the last stanza because chorus will only be inserted after current index
    for i in range(len(value['zh']) - 1, 0, -1):
        if value['zh'][i] is not None:
            for j in range(len(value['zh'][i])):
                if value['zh'][i][j].startswith(('（和）', '和、')):
                    if value['zh'][i][j].startswith('（和）'):
                        value['zh'][i][j] = value['zh'][i][j][3:]
                    else: # if value['zh'][i][j].startswith('和、'):
                        value['zh'][i][j] = value['zh'][i][j][2:]
                    # check en has enough length
                    assert value['en'][i] is None or len(value['en'][i]) >= j
                    for lng in ('zh', 'en'):
                        if value[lng][i] is not None:
                            # split values into stanza and chorus
                            chorus = value[lng][i][j:]
                            # for en that has no chorus
                            if not chorus:
                                chorus = None
                            # insert chorus
                            value[lng].insert(i + 1, chorus)
                            del chorus
                            # remove chorus from original stanza
                            del value[lng][i][j:]
                        else:
                            value[lng].insert(i + 1, None)
                    idxs.insert(i + 1, 'chorus')
                    # assume only 1 chorus per stanza
                    # break after found a chorus
                    break
                    del lng
            del j
    del i

    # reformat idxs to aways be tuple
    for i in range(1, len(idxs)):
        if idxs[i] == 'chorus':
            # at last index it already becomes a tuple
            assert isinstance(idxs[i - 1][0], int)
            idxs[i] = (idxs[i - 1][0], 'chorus')
        else:
            assert isinstance(idxs[i], int)
            idxs[i] = (idxs[i], '')
    del i
    # assert idxs is ordered
    assert idxs[1:] == sorted(idxs[1:])

    # assert each stanza has same no. of lines across lang
    for ln_en, ln_zh in zip(value['en'], value['zh']):
        if ln_en is not None and ln_zh is not None:
            assert len(ln_en) == len(ln_zh)
    del ln_en, ln_zh

    # assert stanza has same no. of lines within a lang
    # construct stanza and chrous index
    stanza_idx = [i for i, idx in enumerate(idxs) if idx[1] == '']
    for lng in ('en', 'zh'):
        length = None
        for i in stanza_idx:
            if value[lng][i] is not None:
                if length is None:
                    length = len(value[lng][i])
                else:
                    # special case
                    assert length == len(value[lng][i]) or (num in (476, 477))
        del i, length
    del lng, stanza_idx
    chorus_idx = [i for i, idx in enumerate(idxs) if idx[1] == 'chorus']
    if chorus_idx:
        for lng in ('en', 'zh'):
            length = None
            for i in chorus_idx:
                if value[lng][i] is not None:
                    if length is None:
                        length = len(value[lng][i])
                    else:
                        assert length == len(value[lng][i])
            del i, length
        del lng
    del chorus_idx
    return idxs, value


def parse_to_dict(num, idxs, value):
    '''construct from the output of parse_to_list
    to a dict structure
    with optional keys note, ref, author, title, meter
    and mandatory keys stanza, category
    stanza is an OrderedDict with keys in format (INT, STR)
    as index of stanza/chorus.
    all the values might be a dict with keys 'en' and/or 'zh'
    for branching different values according to the language.
    '''
    result = {}

    # construct category
    category = value['zh'][0][0]
    # extract note
    if '（' in category:
        temp = [temp if i == 0 else temp[:-1] for i, temp in enumerate(category.split('（'))]
        if temp[-1].endswith(('行', '遍', '詩')):
            result['note'] = {'zh': temp[-1]}
            del temp[-1]
        elif temp[-1].endswith('章'):
            result['ref'] = {'zh': temp[-1]}
            del temp[-1]
        assert len(temp) <= 2
        category = temp[0] if len(temp) == 1 else '{}（{}）'.format(*temp)
        del temp
    result['category'] = {'zh': category}
    del category

    # construct meter
    meter = value['en'][0][0]
    if 'No English translation' in meter or 'Irregular' in meter:
        meter = None
    # special cases
    elif num == 749: # Bob McGee—Isaiah 7:14
        author, ref = meter.split('—')
        meter = None
        result['author'] = {'en': author}
        del author
        if 'ref' in result:
            result['ref']['en'] = ref
        else:
            result['ref'] = {'en': ref}
        del ref
    elif num == 570: # God will Take Care Of You <!-- editor: was missing -->
        result['title'] = {'en': meter}
        meter = None
    # extract note
    elif '(' in meter:
        assert meter.count('(') <= 1
        meter, note = meter.split('(')
        meter = meter.strip()
        assert note[-1] == ')'
        note = note[:-1]
        if len(note) == 1:
            meter = '{} ({})'.format(meter, note)
            note = None
        if note:
            if 'note' in result:
                result['note']['en'] = note
            else:
                result['note'] = {'en': note}
        del note
    # split meter and other stuffs
    if meter == '':
        meter = None
    if meter is not None:
        note = None
        if not set(meter).issubset(METER):
            for i, meter_i in enumerate(meter):
                if not meter_i in METER:
                    break
            del meter_i
            # special case
            if meter[i - 1] == 'D':
                i -= 1
            meter, note = meter[:i], meter[i:]
            del i
            if note.startswith('with chorus '):
                assert 'author' not in result
                result['author'] = {'en': note[12:]}
                note = 'with chorus'
            elif note.startswith('Psalm'):
                if 'ref' in result:
                    result['ref']['en'] = note
                else:
                    result['ref'] = {'en': note}
                note = None
            elif note == 'Dennis Cleveland':
                assert 'author' not in result
                result['author'] = {'en': note}
                note = None
        # normalize meter
        meter = meter.strip().replace('. ', '.').replace('.(', '. (')
        if not meter.endswith(('.', ')')):
            meter += '.'
        # treat note
        if note is None:
            result['meter'] = meter
        else:
            assert note in METER_TYPE
            result['meter'] = {
                'zh': ' '.join((meter, METER_TYPE[note])),
                'en': ' '.join((meter, note))
            }
        del note
    del meter

    # construct stanza dict
    stanza = OrderedDict()
    for i in range(1, len(idxs)):
        # get no. of lines in a stanza
        length = len(value['zh'][i]) if value['en'][i] is None else len(value['en'][i])
        stanza[idxs[i]] = [dict() for _ in range(length)]
        for lng in ('zh', 'en'):
            if value[lng][i] is not None:
                for j in range(length):
                    stanza[idxs[i]][j][lng] = value[lng][i][j]
                del j
        del lng, length
    result['stanza'] = stanza
    del i, idxs, value, stanza

    return result


def parser(num):
    '''read both en and zh-Hant hymns and convert it to a dict
    chaining read_md, parse_to_list, parse_to_dict
    '''
    return parse_to_dict(num, *parse_to_list(num, read_md(num)))


def convert(num):
    '''read markdown, parse it using ``parser``,
    and write to yaml
    '''
    import yaml
    import yamlordereddictloader

    with open('data/{0:03}.yml'.format(num), 'w') as f:
        yaml.dump(
            parser(num),
            f,
            Dumper=yamlordereddictloader.Dumper,
            allow_unicode=True,
            default_flow_style=False
        )
