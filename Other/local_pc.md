# ローカル環境設定 #

## FTP設定 ##

### SSL ###

1. FTPサービスとIISコンソル有効化

    * インターネット インフォメーション サービス
      * FTP サーバ
      * FTP Service
    * Web 管理ツール
      * IIS 管理コンソール

1. FTPユーザ追加

    * コンピューターの管理(ローカル)
      * ローカル ユーザとグループ
        * ユーザ
          * 新しいユーザ
          * ユーザ名: test_ftp
          * パスワード: test_ftp1
          * ユーザーは次回ログオン時にパスワードの変更が必要: off

1. 自己署名証明書作成

    1. IIS サーバ証明書
    1. 自己証明入り証明書の作成

        * 証明書のフレンドリ名を指定してください: test_ssl
        * 新しい証明書の証明書ストアを選択してください: 個人

1. インターネット インフォメーション サービス(IIS) マネージャー

    1. FTP サイト追加

        * FTPサイト名: local_ftp
        * 物理パス: D:\shared

    1. バインドとSSLの設定

        * IP アドレス: すべて未割当て
        * ポート: 21
        * FTP サイトを自動的に開始する: on
        * SSL: 許可
        * SSL_証明書: test_ssl

    1. 認証および承認の情報

       * 認証: 基本
       * 承認: 指定されたユーザーtest_ftp
       * アクセス許可: 読み取りon 書き込みon

    1. アクセス許可の編集

       * test_ftp ユーザに「フォルダの内容の一覧表示、読み取り、書き込み」を許可する

1. ファイアウォールサポート(必須ではない)

    **設定してもすぐに効かないが、PC再起動で有効になる。(サービスだけ再起動は？)**
    ftpsvc(Microsoft FTP Service)再起動も効果なし

    * データチャネルのポート範囲 5000-6000

1. [II7 ファイアウォール設定](https://docs.microsoft.com/en-us/iis/publish/using-the-ftp-service/configuring-ftp-firewall-settings-in-iis-7)

    ~~~cmd
    # 管理者でCMD実行
    # ポート21開放
    netsh advfirewall firewall add rule name="FTP for IIS" action=allow protocol=TCP dir=in localport=21
    # パッシブポート範囲設定(必須ではない)
    netsh advfirewall firewall add rule name="FTP for IIS (Passive port range)" action=allow service=ftpsvc protocol=TCP dir=in localport=5000-6000
    # ファイアウォールグローバル設定表示 netsh advfirewall show global、StatefulFtp無効化
    netsh advfirewall set global StatefulFtp disable # 大量ファイル転送時、サーバより接続切るの対応

    # 削除 netsh advfirewall firewall delete rule name="FTP for IIS"
    ~~~

## アクセステスト ##

~~~cmd
# local cmd
curl -u test_ftp:test_ftp1 ftp://localhost
curl -u test_ftp:test_ftp1 -ssl ftp://localhost
~~~

~~~bash
docker pull alpine
docker run --rm --name test_ftp_linux -it alpine
apk add curl
apk add lftp
apk add vim
apk add tcpdump
cd tmp

# download
curl -u test_ftp:test_ftp1 -o test.txt ftp://192.168.3.2/game/test.txt
curl -u test_ftp:test_ftp1 -o test.txt -ssl -k ftp://192.168.3.2/game/test.txt

lftp -u test_ftp,test_ftp1 192.168.3.2
set ssl:verify-certificate false
cd game
get test.txt
bye

lftp -u test_ftp,test_ftp1 192.168.3.2
set ftp:ssl-allow false
cd game
put test.txt
bye

# upload
curl -u test_ftp:test_ftp1 -T test.txt ftp://192.168.3.2/game/
curl -u test_ftp:test_ftp1 -T test.txt -ssl -k ftp://192.168.3.2/game/

lftp -u test_ftp,test_ftp1 192.168.3.2
set ftp:ssl-allow false
cd game
put test.txt
bye

lftp -u test_ftp,test_ftp1 192.168.3.2
set ssl:verify-certificate false
cd game
put test.txt
bye

~~~