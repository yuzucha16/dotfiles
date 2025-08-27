#!/usr/bin/env awk -f
# 入力: tags (Universal Ctags)
# 出力: NAMESPACE_MAP.md（標準出力に書くので > でリダイレクト推奨）

BEGIN {
  FS = "\t";
}
function kv(hay, key,   m) {
  # タグの拡張フィールドから key:val を抜く
  # 例: "kind:f\tline:123\tsignature:(int)\tclass:Foo\tnamespace:bar::baz"
  if (match(hay, key ":([^ \t]+)", m)) return m[1];
  return "";
}
function basename(p,   n, a) { n=split(p, a, "/"); return a[n]; }

{
  name = $1; file = $2; ex = $0;
  kind = kv(ex, "kind"); line = kv(ex, "line");
  ns   = kv(ex, "namespace"); cls = kv(ex, "class");
  strc = kv(ex, "struct");    sign= kv(ex, "signature");

  # ctags により namespace自体は kind:"p"
  if (kind == "p") { namespaces[ns==""?name:ns] = 1; next; }

  # スコープ解決: namespace が無い場合でも class/struct があれば補助
  scope = (ns != "" ? ns : "");
  # 表示ラベルとカテゴリ決定
  cat = (kind=="c" ? "Class"
      : kind=="s" ? "Struct"
      : kind=="m" ? "Member"
      : kind=="f" ? "Function"
      : kind=="g" ? "Enum"
      : kind=="t" ? "Typedef"
      : kind=="u" ? "Union"
      : kind=="v" ? "Variable"
      : kind=="p" ? "Namespace" : kind);

  entry = sprintf("- `%s`%s  _( %s:%s )_",
                  name, (sign!=""? sign:""),
                  file, (line!=""? line:"?"));

  if (scope == "") {
    global[cat][++global_idx[cat]] = entry;
  } else {
    bucket[scope][cat][++idx[scope cat]] = entry;
    scopes[scope] = 1;
  }
}

END {
  print("# Namespace Map");
  print();
  # Namespaces（見出し一覧）
  if (length(scopes) > 0) {
    print("## Index (Namespaces)");
    for (s in scopes) printf("- [%s](#ns-%s)\n", s, gensub(/[:]/, "", "g", s));
    print("");
  }

  # 各 Namespace セクション
  for (s in scopes) {
    anchor = gensub(/[:]/, "", "g", s);
    printf("## %s {#ns-%s}\n\n", s, anchor);

    # カテゴリ順で出す
    cats[1]="Class"; cats[2]="Struct"; cats[3]="Enum"; cats[4]="Typedef";
    cats[5]="Union"; cats[6]="Function"; cats[7]="Variable"; cats[8]="Member";

    for (i=1; i<=8; i++) {
      c=cats[i];
      if (c in bucket[s]) {
        printf("### %s\n", c);
        for (j=1; j<=idx[s c]; j++) print bucket[s][c][j];
        print("");
      }
    }
  }

  # グローバル（ns 無し）
  any=0; for (c in global) any=1;
  if (any) {
    print("## (Global scope)\n");
    for (c in global) {
      printf("### %s\n", c);
      for (j=1; j<=global_idx[c]; j++) print global[c][j];
      print("");
    }
  }
}
