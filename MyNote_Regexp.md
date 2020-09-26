# 正規表現 #

## 各ソフトの違い ##

### ORACLE 12.1 ###

[8 データベース・アプリケーションでの正規表現の使用](https://docs.oracle.com/cd/E57425_01/121/ADFNS/adfns_regexp.htm)

1. 標準に準拠
    * IEEEのPortable Operating System Interface(POSIX)標準ドラフト1003.2/D11.2
    * Unicode ConsortiumのUnicode正規表現ガイドライン

1. POSIX標準を超えて次のように拡張
    * 多言語データの照合機能が拡張
    * POSIX標準には含まれていないが競合もしない(文字クラスのショートカットや最短一致修飾子(?)など)、よく使用されるPERL正規表現演算子をサポート

### Postgresql 12.3 ###

[9.7.3.1. 正規表現の詳細](https://www.postgresql.jp/document/12/html/functions-matching.html#POSIX-METASYNTAX)

1. 標準に準拠
    * POSIX 1003.2

1. 拡張
    * POSIX標準にはないけれどもPerlやTclなどのプログラミング言語で利用できることから広く使用されるようになった、いくつかの拡張もサポート

### 注意点 ###

[PostgreSQL 12.3文書 ](https://www.postgresql.jp/document/12/html/functions-matching.html#POSIX-METASYNTAX)

9.7.3.2. ブラケット式
ブラケット式で、「[（次段落を参照）のなんらかの組み合わせ、およびエスケープ（AREのみ）を例外として、他の全ての特殊文字はブラケット式内では特殊な意味を持ちません」
9.7.3.6. 制限と互換性
AREでは、\は[]内でも特別な文字です。したがって、ブラケット式では\を\\と記述しなければなりません。