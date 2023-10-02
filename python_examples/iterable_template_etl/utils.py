import pandas as pd
import os
import re
import csv
import json


def to_snake_case(str):
    res = [str[0].lower()]
    for c in str[1:]:
        if c in ("ABCDEFGHIJKLMNOPQRSTUVWXYZ"):
            res.append("_")
            res.append(c.lower())
        else:
            res.append(c)

    return "".join(res)


def s3_file_exists(path):
    try:
        dbutils.fs.ls(path)
        return True
    except Exception:
        return False


def to_snake_case(str):
    res = [str[0].lower()]
    for c in str[1:]:
        if c in ("ABCDEFGHIJKLMNOPQRSTUVWXYZ"):
            res.append("_")
            res.append(c.lower())
        else:
            res.append(c)

    return "".join(res)


def get_folder_path(folder: str, up_one_level: bool = True):
    if up_one_level:
        return f"{os.path.abspath(os.path.join(os.getcwd(), '..', folder))}"
    else:
        return f"{os.path.abspath(os.path.join(os.getcwd(), folder))}"


def write_json(path: str, js: str):
    with open(path, "w") as f:
        json.dump(js, f, ensure_ascii=False, indent=1)
        f.close()


def write_file(path: str, text: str):
    with open(path, "w") as f:
        f.write(text)
        f.close()


def json_str_df(js):
    return pd.json_normalize(js)


def json_from_file(path, as_df=False):
    with open(path) as f:
        data = json.load(f)
        f.close()
    if as_df:
        return pd.json_normalize(data)
    else:
        return data


def dict_from_csv(path):
    with open(path, mode="r", encoding="utf-8-sig") as f:
        a = [
            {k: v for k, v in row.items()}
            for row in csv.DictReader(f, skipinitialspace=True)
        ]
    f.close()
    return a


def email_to_folder_name(email: str):
    return re.sub("[@!#$%&'*+=?^_`{|}~.-]", "_", email)


def flatten_list(l: list, dedup: bool = False):
    # Flattens a 2-D list of lists, with option to deduplicate records.
    if type(l[0]) != list:
        raise ValueError("flatten_list requires a list of lists.")
    new = []
    for l_item in l:
        for item in l_item:
            if not dedup or (dedup and item not in new):
                new.append(item)
    return new


def distinct(d):
    # Deduplicate keys in a dict or items in a list.
    if type(d) == list:
        new_list = []
        for i in d:
            if i not in new_list:
                new_list.append(i)
        return new_list
    elif type(d) == dict:
        new_dict = {}
        for k, v in d.items():
            if k not in new_dict:
                new_dict[k] = v
        return new_dict
    else:
        raise ValueError(f"distinct does not support type {type(d)}")


def unwrap_dict_list(source_list: list, target_dict: dict, key: str):
    # Takes a list of dictionaries and puts them in a target dict with a key from those dictionaries.
    for i in source_list:
        if i[key] not in target_dict:
            target_dict[i[key]] = i
    return target_dict
