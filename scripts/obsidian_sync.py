#!/usr/bin/env python3
"""Obsidian の設定を、resources 用（正本）から works 用へ一方向に反映する。

usage: obsidian_sync.py [--dots DIR] [--check] [-n]
  （引数なし）  works 用の派生分を生成する。何度走らせても同じ結果になる
  --check       書き換えずに、正本との差分だけを出す。差分があれば終了コード 1
  -n            書き換えずに、何をするかだけを出す（--check と違い、差分があっても終了コード 0）

正本    : windows/obsidian/resources/.obsidian/
works 用: windows/obsidian/works/.obsidian/
  派生分 : app.json（正本に app.override.json を重ねる）、appearance.json、core-plugins.json、
           types.json、snippets/、themes/   ← git で追跡しない（.gitignore）
  固有分 : community-plugins.json、plugins/、app.override.json   ← 反映の対象外

works 側が前回の反映から変わっていたら、それを表示して上書きする。
標準ライブラリだけを使う（Python 3.8 以上）。
"""
import argparse
import hashlib
import json
import os
import shutil
import sys

FILES = ["appearance.json", "core-plugins.json", "types.json"]
DIRS = ["snippets", "themes"]
OVERRIDE = "app.override.json"
STATE = ".sync-state.json"


def sha(b):
    return hashlib.sha256(b).hexdigest()


def read(path):
    try:
        with open(path, "rb") as f:
            return f.read()
    except FileNotFoundError:
        return None


def desired(master, works):
    """works 用の派生分の、あるべき中身。{相対パス(/ 区切り): bytes}"""
    out = {}
    for name in FILES:
        b = read(os.path.join(master, name))
        if b is not None:
            out[name] = b
    app = read(os.path.join(master, "app.json"))
    if app is not None:
        ov = read(os.path.join(works, OVERRIDE))
        if ov is not None:
            data = json.loads(app.decode("utf-8"))
            data.update(json.loads(ov.decode("utf-8")))
            app = json.dumps(data, indent=2, ensure_ascii=False).encode("utf-8")
        out["app.json"] = app
    for d in DIRS:
        root = os.path.join(master, d)
        for dp, _, fns in os.walk(root):
            for fn in fns:
                full = os.path.join(dp, fn)
                rel = d + "/" + os.path.relpath(full, root).replace(os.sep, "/")
                out[rel] = read(full)
    return out


def existing(works):
    """works 側にいまある派生分の相対パス（固有分は含めない）。"""
    found = set()
    for name in FILES + ["app.json"]:
        if os.path.isfile(os.path.join(works, name)):
            found.add(name)
    for d in DIRS:
        root = os.path.join(works, d)
        for dp, _, fns in os.walk(root):
            for fn in fns:
                full = os.path.join(dp, fn)
                found.add(d + "/" + os.path.relpath(full, root).replace(os.sep, "/"))
    return found


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--dots", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
    ap.add_argument("--check", action="store_true")
    ap.add_argument("-n", "--dry-run", action="store_true")
    a = ap.parse_args(argv)

    base = os.path.join(a.dots, "windows", "obsidian")
    master = os.path.join(base, "resources", ".obsidian")
    works = os.path.join(base, "works", ".obsidian")
    if not os.path.isdir(master):
        print("[ERR] master not found: " + master, file=sys.stderr)
        return 1
    if not os.path.isdir(works):
        print("[ERR] works dir not found: " + works, file=sys.stderr)
        return 1

    want = desired(master, works)
    have = existing(works)
    state_path = os.path.join(works, STATE)
    try:
        state = json.loads((read(state_path) or b"{}").decode("utf-8"))
    except ValueError:
        state = {}

    diffs = []  # (種別, パス)
    for rel in sorted(want):
        cur = read(os.path.join(works, *rel.split("/")))
        if cur is None:
            diffs.append(("missing", rel))
        elif cur != want[rel]:
            # 前回の反映の結果と違えば、works の画面などで直された
            edited = state.get(rel) not in (None, sha(cur))
            diffs.append(("edited-in-works" if edited else "stale", rel))
    for rel in sorted(have - set(want)):
        diffs.append(("extra", rel))

    if a.check:
        for kind, rel in diffs:
            print("[DIFF] %s: %s" % (kind, rel))
        if diffs:
            print("[CHECK] %d difference(s). Run obsidian_sync.py to apply." % len(diffs))
            return 1
        print("[CHECK] works config matches the master.")
        return 0

    dry = a.dry_run
    for kind, rel in diffs:
        if kind == "edited-in-works":
            print("[WARN] works 側が前回の反映から変わっていた（上書きする）: " + rel)
    for kind, rel in diffs:
        path = os.path.join(works, *rel.split("/"))
        if kind == "extra":
            print(("[DRY] remove " if dry else "[OK] removed ") + rel)
            if not dry:
                os.remove(path)
        else:
            print(("[DRY] write " if dry else "[OK] wrote ") + rel)
            if not dry:
                os.makedirs(os.path.dirname(path), exist_ok=True)
                with open(path, "wb") as f:
                    f.write(want[rel])
    if not dry:
        for d in DIRS:  # 空になったディレクトリを片付ける
            root = os.path.join(works, d)
            for dp, dn, fn in sorted(os.walk(root, topdown=False)):
                if not os.listdir(dp) and dp != root:
                    os.rmdir(dp)
        os.makedirs(works, exist_ok=True)
        with open(state_path, "wb") as f:
            f.write(json.dumps({k: sha(v) for k, v in want.items()}, indent=2, sort_keys=True).encode("utf-8"))
    if not diffs:
        print("[OK] already in sync.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
