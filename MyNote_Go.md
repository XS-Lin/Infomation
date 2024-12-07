# Go Tips #

## Tips ##

### 環境 ###

~~~powershell
go version # go version go1.22.0 windows/amd64
~~~

### cheat list ###

~~~powershell

go env # 環境変数確認
go build -o hello_word hello.go

# mod
mkdir hello-word
go mod init hello-word
go mod tidy # 必要なライブラリダウンロードと不要なライブラリ削除
go build

# install
#   ソースコードリポジトリからダウンロードとビルド
#   @でバージョン指定
#   $GOPATH/bin OR go/bin にインストール
go install github.com/cloudspannerecosystem/spanner-change-streams-tail@latest

# 整形
#   goはセミコロンが必要だが、自動的に挿入
go fmt
goimports

~~~

~~~go
// 基本型
'\u0061' // runeリテラル、1文字
"解釈済み文字列" 
`raw文字列`

// リテラルは型がない、代入の時に変数の型にキャスト。
//   整数リテラルのデフォルト型はint

// 浮動小数点数、IEEE754、10進数を正確に表現できない。イコール比較を避けるべき、どうしても必要な場合は誤差許容の範囲で実施。

// 文字を参照の場合はrune型を使う。int32と同じ意味だが、意図を明確に示す

// 変数宣言
//   var で変数リスト宣言可能
//   := は関数外で使えない

// 定数
//   型つき定数を使う場合、同じ型の変数のみ代入可能。untypedの場合は暗黙変換。

// 配列
//   == と != で比較可能
var x [3]int
var x [3]int{10,20,30} 
var x = [...]int{10,20,30}
var y = [3]int{10,20,30}
fmt.Print(x == y) // true

// スライス
//   配列は色んな制限があるため、頻繁に使われない。代わりにスライスがよく使われる。長さの制限がない。
//   長さがわからない場合、makeを使う。
//   スライスのスライスでは、メモリを共有する。つまり、サブスライスでappendの場合、メモリが共有しているすべてのスライスに影響する。フルスライス式で回避可能。
//   copyでメモリー共有しないスライス作成
var x = []int{10,20,30}
x = append(x,40) // Go は値をコピーして関数に渡すのみ。
fmt.Println(len(x),cap(x)) // 4 4
x = append(x,50)
fmt.Println(len(x),cap(x)) // 5 8 , capは1024までは倍増、以後は25%で増加
x := make([]int, 5) // 長さ5, キャパシティー5, すべての要素が0 になる。
x := make([]int, 5, 10) // 長さ5, キャパシティー10, すべての要素が0 になる。

var data []int
fmt.Println(data == nil) // true

data := []int{}
fmt.Println(data == nil) // false

// スライスとフルスライス
x := make([]int, 0, 5)
x = append(x, 1, 2, 3, 4)
y := x[:2:5]
y = append(y, 30, 40, 50)
x = append(x, 60)
fmt.Println(x) // [1 2 30 40 60]
fmt.Println(y) // [1 2 30 40 60]

x := make([]int, 0, 5)
x = append(x, 1, 2, 3, 4)
y := x[:2:2]
y = append(y, 30, 40, 50)
x = append(x, 60)
fmt.Println(x) // [1 2 3 4 60]
fmt.Println(y) // [1 2 30 40 50]

// 文字列の内部はbyte配列(utf8)

// マップ
//   map[<キーの型>]値の型
var nilMap map[string]int
totalWins := map[string]int{}
ages := make(map[string]int,10)

m := map[string]int {
    "hello":5,
    "world":0,
}
v, ok = m["hello"] // 5,true
v, ok = m["world"] // 0,true
v, ok = m["goodbye"] // 0,false
~~~

~~~go
// goはすべての型が値

// ブロック内 := で初期化された変数はそのブロックとサブブロックに有効
// 親ブロックの変数は := で隠ぺい可能
// ユニバースブロックの識別子(true, nil 等)を再定義しないように
//   https://go.dev/ref/spec#Predeclared_identifiers

// if
//   if と else 両方に有効する変数宣言可能

// for
//   他の言語のfor と同じ
//   他の言語のwhile と同じもできる
//   無限ループも
//   for-range は値コピー
//   for-range はよく使われる。コレクションの一部を処理する場合は他のループがいい。

// switch
//   各caseで利用する変数宣言可能
//   デフォルトフォールスルーしない(break不要)。fallthrough で指定可能
//   blank switch できる。同じ変数で判断の場合は使うがいい。使いすぎは禁物(きんもつ)

// 関数
//   名前付き引数、オプション引数がない。構造体で実現可能
//   可変長引数あり
//   引数は値コピー(ポインターでも同様)
//   複数戻り値(Pythonはタプルを戻す、Goと違う)
//   名前付き戻り値がある(シャドーイングに要注意)。この時ブランクreturnができる(わかりにくくなるため、基本的に使わない)。
//     defer の値とるために使うのがほとんどである
//   関数は値、型はfunc・引数・戻り値で決める。
//     関数型宣言
//     無名関数
//   クロージャ、関数内定義された関数

// ポインター
//   bool型は1bitで保存できるが、メモリーのアクセスできる最小単位が1byteのため、1byteが必要
//   int32は4byte
//   ポインタのゼロ値はnil。Cと違って、nilは0ではない。
//   組み込み関数newでインスタンスのポインタ作成できるがほとんど使わない。構造体リテラルの前に&でインスタンスのポインタを作る。
//   基本型のリテラルのポインタは作れない(&をつけるとエラー)。基本型のポインターが必要な場合は基本型を宣言し、後で参照するポインターを宣言する。
//   定数のポインターも取得できない。必要な時は定数値を保存する変数を作成し、変数のポインターを作成(ヘルパー関数を使うがいい)
//   他の言語のクラスの裏はポインタ
//   ポインターを引数に使わないといけないのは関数がインターフェースを受け取る場合のみ。
//   関数から値を返す場合は値を返すべき。ポインター型を返す理由はデータ型の中に変更するべき状態があるときだけ。
//     バッファ
//     並行実行に使用されるデータ型は必ずポインターとして渡す
//   ポインター渡すのにかかる時間はおおよそ1ナノ秒、値の場合はおおよそ10MBで1ミリ秒。1MBより小さいデータを返す場合はポインターが遅い。

// ガベージコレクタの負荷軽減策
//   バッファ利用
//   実行中スタックサイズを増やすことが可能、この場合はスタックをコビーする時間がかかる。
//   ポインターは理由がない限り使わない。

// メソッド
//   メソッドがレシーバーを変更ならポインターレシーバーを使わなければならない。
//   メソッドがnilを扱う必要ならポインターレシーバーを使わなければならない。
//   メソッドがレシーバーを変更しないなら値レシーバーを使うことができる。
//   ポインターレシーバーに対してポインターでないローカル変数を渡すと自動的にポインター型に変更

// iota - 値が明確な意味を持つ場合は使うべきではない。

// Goは継承がない、合成がある。
//   埋め込みと継承の違い：
//     Employee型にManagerを代入できない※継承の場合は親クラスタイプの変数は子クラスのインスタンスを代入できる
//     具象型を動的ディスパッチがない※継承の場合は子のメソッドを優先、なければ親のメソッドを実行
type Employee struct {
    Name string
    ID string
}
func (e Employee) CountPrinter(c int) string {
    return fmt.Sprintf("Employee:%d", c)
}
func (e Employee) Double() string {
    result := e.Count * 2
    return e.CountPrinter(result)
}
type Manager struct {
    Employee
    Reports []Employee
}
func (m Manager) CountPrinter(c int) string {
    return fmt.Sprintf("Manager:%d", c)
}
m := Manage{
    Employee: Employee{
        Name: "上杉謙信",
        ID: "12345",
        Count: 5,
    },
    Reports: []Employee{},
}
var eOK Employee = m.Employee // OK
var eFail Employee = m // Error
fmt.Println(m.Double()) // Employee:10

// インターフェース
//   インターフェースは他の言語とほぼ同じ機能(デフォルトメソッドは定義できない)
//   interface{} は0個メソッド、つまり任意関数が満たす、任意インスタンス代入可能
//   埋め込み可
//   インターフェースを受け取り構造体を返す。
//     インターフェースを返すとバグが生じやすい。
//   interface{} のゼロ値はnilだが、「ベースとなる型へのポインター」と「ベースとなる値へのポインター」の組のため、両方がnilの場合のみnilとみなす.
//   go 1.18以後、any が使える(interface{}と同じ)。不明な値を保存、例えばJSONのような外部ファイル。避けるべきだが、リフレクションなどでも使う。
var s *string
fmt.Println(s == nil) // true
var i interface{}
fmt.Println(i == nil) // true
i = s
fmt.Println(i == nil) // false
//   型アサーションと型switch - 他の言語のCAST

// エラー
//   定義
type error interface{
    Error() string
}
//   単純はエラーは errors.New で作成
//   センチネルエラーは処理継続できないことを示す。Errで開始(io.EOFだけが例外)。
//   独自のエラーでもerrorを戻す。
func GenerateError(flag bool) error {
    var genErr StatusErr
    if flag {
        genErr = StatusErr {
            Status: NotFound
        }
    }
    return genErr
}
fun main() {
    err := GenerateError(true)
    fmt.Println(err == nil) // true
    err := GenerateError(false)
    fmt.Println(err == nil) // true
}
// 改修法1
func GenerateError(flag bool) error {
    if flag {
        return StatusErr {
            Status: NotFound
        }
    }
    return nil
}
// 改修法2
func GenerateError(flag bool) error {
    var genErr error
    if flag {
        genErr = StatusErr {
            Status: NotFound
        }
    }
    return genErr
}
// errors.Is,errors.As
//   特定インスタンス、値を探す時はerrors.Is
//   特定型を探す時はerrors.Is

~~~

~~~go
// モジュールとパッケージ
//   先頭文字が大文字は外で利用可能、小文字や「_」開始は内部のみ。構造体のフィールドも同様
//   パケージ名とフォルダ名一致しなくてもエラーにならないが、混乱しやすい。以下の3つは例外
//     main
//     Goの識別子として有効でないディレクトリ
//     ディレクトリを使ったバージョン管理
//   パケージ名オーバライドできる。「_」の場合は対象パケージ内の識別子アクセス不可になるが、代わりに使えなくもエラーにならない。パケージのinit実行する。

// 並行処理
//   

~~~
