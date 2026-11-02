---
title: "第2章 中置式の優先順位を実装する"
---

この章では、`2 + 3 * 4` を「掛け算が先」というルールを守って `(+ 2 (* 3 4))` に組み替える方法を、`code/bc.rkt` のコードを部品ごとに読みながら説明します。

## 2.1 考え方：式を「木」にする

`(+ 2 (* 3 4))` は、次のような **木**（上から枝分かれする図）として見られます。

```text
      +
     / \
    2   *
       / \
      3   4
```

計算は **下（葉っぱ）から** 進みます。まず `3 * 4 = 12`、次に `2 + 12 = 14` です。つまり、**後で計算したい演算子ほど木の上（外側）に置く** と、掛け算を先にできます。足し算は掛け算より「弱い」（後で計算する）ので、外側に置きます。

## 2.2 ルール：右端の弱い演算子で二つに切る

実装のルールは次のとおりです。Scratch の「もし〜なら、でなければ」と同じ形で考えられます。

1. もし `+` か `-` があるなら、その中で **いちばん右** のもので式を左右に切る。
2. でなければ、もし `*` か `/` があるなら、その中で **いちばん右** のもので切る。
3. 切った左側・右側それぞれに、同じルールをもう一度使う。

3 のように、自分と同じ手順を小さい部分に使うことを **再帰**（さいき）と呼びます。Scratch でいえば、「定義ブロック」の中から同じ定義ブロックを呼ぶことにあたります。

**なぜ右端で切るのか**：`8 - 3 - 1` は、ふつう左から計算して `(8 - 3) - 1 = 4` です（**左結合**）。右端の `-` で切ると、左側が `8 - 3`、右側が `1` になり、`(- (- 8 3) 1)` という形ができて 4 になります。もし左端で切ると `8 - (3 - 1) = 6` になってしまいます。

**括弧の扱い**：`(2 + 3)` のような括弧の部分は、ひとかたまりの 1 個の要素として扱います。演算子を探すときに括弧の中は見ず、必要になったときに中へ入って同じルールを使います。

## 2.3 コードを部品ごとに読む

`code/bc.rkt` の中心部分です（これは抜粋なので、この部分だけでは実行できません）。

### 部品1：演算子かどうかを調べる `operator?`

```racket
(define (operator? token operators)
  (and (identifier? token) (memq (syntax-e token) operators)))
```

| 部分 | 意味 |
|---|---|
| `(define (operator? token operators) ...)` | `operator?` という関数を作る。材料は `token`（式の中の 1 個の要素、**トークン**）と `operators`（探したい演算子の一覧） |
| `(identifier? token)` | そのトークンが名前（`+` や `x` のような記号）かどうか。数の `2` なら「いいえ」 |
| `(syntax-e token)` | 構文オブジェクトの包みを一枚はがして、中身の記号（たとえば `+`）を取り出す |
| `(memq ... operators)` | その記号が一覧の中にあるかを調べる。Scratch の「[リスト] に (〜) が含まれる」ブロックに近い |
| `(and A B)` | A も B も成り立つときだけ「はい」。Scratch の「〈 〉かつ〈 〉」 |

### 部品2：いちばん右の演算子の位置を探す `rightmost`

```racket
(define (rightmost tokens operators)
  (for/fold ([found #f]) ([token (in-list tokens)] [i (in-naturals)])
    (if (operator? token operators) i found)))
```

| 部分 | 意味 |
|---|---|
| `(define (rightmost tokens operators) ...)` | `rightmost`（いちばん右）という関数を作る。`tokens` はトークンのリスト |
| `for/fold` | リストを先頭から一つずつ見ながら、一つの答えを更新していくくり返し。Scratch の「(リストの長さ) 回繰り返す」に変数の更新を組み合わせたもの |
| `([found #f])` | 答えを入れる変数 `found` を用意し、最初は `#f`（「見つかっていない」という意味の「偽」） |
| `[token (in-list tokens)]` | くり返しのたびに、リストの要素を順に `token` に入れる |
| `[i (in-naturals)]` | 同時に番号 `i` を 0, 1, 2, … と数える（Racket の番号は 0 から始まる） |
| `(if (operator? token operators) i found)` | もし演算子なら、`found` を今の番号 `i` に置き換える。でなければそのまま |

最後まで見ると、`found` には **最後に見つかった（＝いちばん右の）** 演算子の番号が残ります。一つもなければ `#f` のままです。例：`2 + 3 * 4` のトークンは番号 0〜4 で、`+` を探すと答えは 1 です。

### 部品3：組み替えの本体 `compile-infix`（前半：切る場所を決める）

```racket
(define (compile-infix tokens origin)
  (define split
    (or (rightmost tokens '(+ -)) (rightmost tokens '(* /))))
```

| 部分 | 意味 |
|---|---|
| `compile-infix` | 中置式（infix）を Racket の式に変換（compile）する関数 |
| `tokens` | 変換したいトークンのリスト |
| `origin` | 元の `(bc ...)` 全体。エラーのとき「どこが悪いか」を示すために持ち歩く |
| `(rightmost tokens '(+ -))` | まず `+` か `-` のいちばん右を探す |
| `(rightmost tokens '(* /))` | 見つからなければ `*` か `/` のいちばん右を探す |
| `(or A B)` | A が見つかれば A、だめなら B を使う |
| `(define split ...)` | 結果（切る位置の番号か `#f`）を `split` という名前で覚える |

### 部品4：演算子で切ったときの処理

```racket
    [split
     (when (or (zero? split) (= split (sub1 (length tokens))))
       (raise-syntax-error 'bc "binary operator needs two operands" origin))
     (define left (compile-infix (take tokens split) origin))
     (define right (compile-infix (drop tokens (add1 split)) origin))
     (case (syntax-e (list-ref tokens split))
       [(+) #`(+ #,left #,right)]
       [(-) #`(- #,left #,right)]
       [(*) #`(* #,left #,right)]
       [(/) #`(/ #,left #,right)])]
```

| 行・部分 | 意味 |
|---|---|
| `[split ...]` | `cond`（「もし〜なら」の並び）の一つ目。切る位置が見つかったときの処理 |
| `(zero? split)` | 演算子が先頭（番号 0）にある。左側の数がない |
| `(= split (sub1 (length tokens)))` | 演算子が最後にある（`sub1` は 1 を引く）。右側の数がない |
| `(when ... (raise-syntax-error ...))` | どちらかなら「二項演算子には材料が二つ必要」というエラーを出して止める |
| `(take tokens split)` | 切る位置より **左** の部分を取り出す |
| `(drop tokens (add1 split))` | 切る位置の **次から右** の部分を取り出す（`add1` は 1 を足す） |
| `(compile-infix ... origin)` | 左右それぞれに同じ関数をもう一度使う（再帰） |
| `(list-ref tokens split)` | 切る位置にある演算子そのものを取り出す |
| `(case ... [(+) ...] ...)` | 演算子の種類で分かれる。`+` なら足し算の形、`-` なら引き算の形…と作る |
| `` #`(+ #,left #,right) `` | 「`(+ 左の式 右の式)`」という形の構文を組み立てる。くわしくは第3章 3.6 |

### 部品5：トークンが 1 個だけのとき

```racket
    [(= (length tokens) 1)
     (define token (car tokens))
     (define nested (syntax->list token))
     (cond
       [(real? (syntax-e token)) token]
       [nested (compile-infix nested origin)]
       [else (raise-syntax-error 'bc "expected a real number or parenthesized expression" origin token)])]
```

| 行・部分 | 意味 |
|---|---|
| `(= (length tokens) 1)` | 演算子がなく、要素が 1 個だけのとき |
| `(car tokens)` | リストの先頭（ここでは唯一の要素）を取り出す |
| `(syntax->list token)` | その要素が括弧のかたまりなら、中身のリストを取り出す。括弧でなければ `#f` |
| `(real? (syntax-e token))` → `token` | 中身が数（実数）なら、それ以上組み替えずにそのまま返す |
| `[nested (compile-infix nested origin)]` | 括弧のかたまりなら、その中へ入って同じルールで変換する |
| `[else (raise-syntax-error ...)]` | 数でも括弧でもない（たとえば `x`）なら、エラーで止める |

### 部品6：それ以外

```racket
    [else (raise-syntax-error 'bc "expected an infix arithmetic expression" origin)]
```

演算子がなく、要素が 0 個または 2 個以上のとき（`(bc)` や `(bc 2 3)`）は、中置の計算式ではないのでエラーにします。

## 2.4 追跡表：`2 + 3 * 4` の場合

| 手順 | 見ている式 | すること | できる形 |
|---|---|---|---|
| 1 | `2 + 3 * 4` | 右端の `+`（番号 1）で切る | `(+ 左 右)` |
| 2 | 左：`2` | 1 個で数なのでそのまま | `2` |
| 3 | 右：`3 * 4` | `+` `-` はない。`*` で切る | `(* 3 4)` |
| 4 | まとめる | | `(+ 2 (* 3 4))` → 実行すると 14 |

## 2.5 エラーと対象外

- 変換できない式（`(bc 2 +)`、`(bc x + 2)`、`(bc 2 ^ 3)` など）は、`raise-syntax-error` で **計算する前に** 止めます。
- `(bc 1 / 0)` のようなゼロでの割り算は、式の形としては正しいので、変換は成功します。止まるのは実行したとき（**実行時エラー**）です。
- `(bc 3 / 2)` は小数ではなく、正確な分数 `3/2` になります。
- 単項のマイナスを別のトークンで書く `(bc - 2)` は対象外です。ただし、`-2` という負の数をそのまま書く `(bc -2)` は使えます。

確認する観点は、優先順位、左結合、括弧、正確な分数、構文エラーです。今後は追跡表とエラー例を増やします。テストは用意していますが、Racket 上の実行確認は未実施です。
