/*
    Oracle の SUBSTRB の Postgresql 版実装 
    
    仕様
        SUBSTRB ( string , position [, length] )
        引数
            string        対象の文字列
            position      
               正の場合     取り出したい文字列の開始位置（1〜）
               0 の場合     1を指定したことと同じ
               負の場合     文字の末尾から逆向きに数えた位置
            length        取り出す文字列長(	default 最後まで )
       戻り値
            抽出した部分文字列 (Substring)
    　　補足
            入出力文字コードをUTF8とする。漢字などのマルチバイト文字の途中から取り出すと、
            バイト単位に切り分けた文字化けするバイトコードが戻るというわけではなくスペース(' ') が代替抽出される。
       
    参考資料
      [UTF-8, a transformation format of ISO 10646](http://www.t-net.ne.jp/~cyfis/rfc/char/rfc3629_ja.html)
      [SUBSTRB](https://www.shift-the-oracle.com/sql/functions/substr.html)

    詳細
        UTF8定義
        ------------------------------------------------------------------
        Char. number range  |        UTF-8 octet sequence
           (hexadecimal)    |              (binary)
        --------------------+---------------------------------------------
        0000 0000-0000 007F | 0xxxxxxx
        0000 0080-0000 07FF | 110xxxxx 10xxxxxx
        0000 0800-0000 FFFF | 1110xxxx 10xxxxxx 10xxxxxx
        0001 0000-0010 FFFF | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
        ------------------------------------------------------------------

        アルゴリズム
        ------------------------------------------------------------------
                                       BYTE_INDEX
        PARTTERN  BYTES  -3     -2     -1     0      +1     +2     +3
               1      1  **     **     **     00-7F  **     **     **  
               2      2  **     **     **     C0-DF  80-BF  **     **
               3      2  **     **     C0-DF  80-BF  **     **     **
               4      3  **     **     **     E0-EF  80-BF  80-BF  **
               5      3  **     **     E0-EF  80-BF  80-BF  **     **
               6      3  **     E0-EF  80-BF  80-BF  **     **     **
               7      4  **     **     **     F0-F4  80-BF  80-BF  80-BF
               8      4  **     **     F0-F4  80-BF  80-BF  80-BF  **
               9      4  **     F0-F4  80-BF  80-BF  80-BF  **     **
              10      4  F0-F4  80-BF  80-BF  80-BF  **     **     **
        ------------------------------------------------------------------

*/
CREATE OR REPLACE FUNCTION substrb (str text, pos int, len int) RETURNS text AS $$
DECLARE
    start_index int; --start by 1
    end_index int;
    str_length int;
    strbytes bytea;
    resultbytes bytea;
    --BYTE_INDEX
    byte_minus_3 int; 
    byte_minus_2 int;
    byte_minus_1 int;
    byte_minus_0 int;
    byte_plus_0 int;
    byte_plus_1 int;
    byte_plus_2 int;
    byte_plus_3 int;
BEGIN
    IF str IS NULL OR str = '' THEN
        RETURN str;
    END IF;

    str_length = octet_length(str);

    IF abs(pos) > str_length THEN
        RETURN NULL;
    END IF;

    IF len <= 0 THEN
        RETURN NULL;
    END IF;

    IF pos > 0 THEN
        start_index = pos;
    ELSIF pos < 0 THEN
        start_index = str_length + pos + 1;
    ELSE
        start_index = 1;
    END IF;
    
    end_index = start_index + len - 1;
    IF end_index > str_length THEN
        end_index = str_length;
    END IF;

    strbytes = convert_to(str, 'UTF8');
    resultbytes = convert_to(str, 'UTF8');
    --STATR_INDEX (SKIP PARTTERN 1,2,4,7)
    byte_plus_0 = get_byte(strbytes,start_index - 1);
    --PARTTERN 3,5,6,8,9,10
    IF byte_plus_0 >= 128 AND byte_plus_0 <= 191 THEN
        IF start_index + 1 < end_index THEN
            byte_plus_1 = get_byte(strbytes,start_index);
            --PARTTERN 5,8,9
            IF byte_plus_1 >= 128 AND byte_plus_1 <= 191 THEN
                IF start_index + 2 < end_index THEN
                    byte_plus_2 = get_byte(strbytes,start_index + 1);
                    --PARTTERN 8
                    IF byte_plus_2 >= 128 AND byte_plus_2 <= 191 THEN
                        resultbytes = set_byte(resultbytes,start_index + 1,32);
                    END IF;
                END IF;
                resultbytes = set_byte(resultbytes,start_index,32);
            END IF;
        END IF;
        resultbytes = set_byte(resultbytes,start_index-1,32);
    END IF;

    --END_INDEX(SKIP PARTTERN 1,3,6,10)
    byte_minus_0 = get_byte(strbytes,end_index - 1);
    --PARTTERN 2,4,7
    IF byte_minus_0 >= 192 THEN
        resultbytes = set_byte(resultbytes,end_index - 1,32);
    ELSE
        IF end_index - 1 > start_index THEN
            byte_minus_1 = get_byte(strbytes,end_index - 2);
            --PARTTERN 5,8
            IF byte_minus_1 >= 224 THEN
                resultbytes = set_byte(resultbytes,end_index - 1,32);
                resultbytes = set_byte(resultbytes,end_index - 2,32);
            ELSE
                IF end_index - 2 > start_index THEN
                    byte_minus_2 = get_byte(strbytes,end_index - 3);
                    --PARTTERN 9
                    IF byte_minus_2 >= 240 THEN
                        resultbytes = set_byte(resultbytes,end_index - 1,32);
                        resultbytes = set_byte(resultbytes,end_index - 2,32);
                        resultbytes = set_byte(resultbytes,end_index - 3,32);
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;
    RAISE NOTICE 'start_index=%',start_index;
    RAISE NOTICE 'end_index=%',end_index;
    RAISE NOTICE 'str_length=%',str_length;
    RAISE NOTICE 'strbytes=%',encode(strbytes,'hex');
    RAISE NOTICE 'resultbytes=%',encode(resultbytes,'hex');
    RAISE NOTICE 'byte_minus_3=%',byte_minus_3; 
    RAISE NOTICE 'byte_minus_2=%',byte_minus_2;
    RAISE NOTICE 'byte_minus_1=%',byte_minus_1;
    RAISE NOTICE 'byte_minus_0=%',byte_minus_0;
    RAISE NOTICE 'byte_plus_0=%',byte_plus_0;
    RAISE NOTICE 'byte_plus_1=%',byte_plus_1;
    RAISE NOTICE 'byte_plus_2=%',byte_plus_2;
    RAISE NOTICE 'byte_plus_3=%',byte_plus_3;
    RETURN convert_from(substring(resultbytes from start_index for end_index - start_index + 1),'UTF8');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

