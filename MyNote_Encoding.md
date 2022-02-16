# MyNote_Encoding #

## Oと0を区別しやすいフォント ##

~~~txt
Monaco / Consolas
~~~

## UTF8 ##

### UTF8の定義 ###

[RFC 3629(対訳)](http://www.t-net.ne.jp/~cyfis/rfc/char/rfc3629_ja.html)

   ~~~txt
   Char. number range  |        UTF-8 octet sequence
       文字の範囲       |
      (hexadecimal)    |              (binary)
        (16進数)       |               (2進数)
   --------------------+---------------------------------------------
   0000 0000-0000 007F | 0xxxxxxx
   0000 0080-0000 07FF | 110xxxxx 10xxxxxx
   0000 0800-0000 FFFF | 1110xxxx 10xxxxxx 10xxxxxx
   0001 0000-0010 FFFF | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx

   UTF8-octets = *( UTF8-char )
   UTF8-char   = UTF8-1 / UTF8-2 / UTF8-3 / UTF8-4
   UTF8-1      = %x00-7F
   UTF8-2      = %xC2-DF UTF8-tail

   UTF8-3      = %xE0 %xA0-BF UTF8-tail / %xE1-EC 2( UTF8-tail ) /
                 %xED %x80-9F UTF8-tail / %xEE-EF 2( UTF8-tail )
   UTF8-4      = %xF0 %x90-BF 2( UTF8-tail ) / %xF1-F3 3( UTF8-tail ) /
                 %xF4 %x80-8F 2( UTF8-tail )
   UTF8-tail   = %x80-BF
   ~~~

   ~~~sql
   --posgresqlでbyteaの末尾が不完全な場合spaceに置き換え
   create or repalce function fix_last_char(strb bytea) returns bytea as $$
   declare
     strb_len int;
     last_1st_byte int;
     last_2nd_byte int;
     last_3rd_byte int;
     last_4rd_byte int;
   begin
     strb_len := octet_length(strb);
     if strb_len = 0 then
       return strb;
     elsif strb_len = 1 then
       last_1st_byte := get_byte(strb,last_1st_byte-1);
     elsif strb_len = 2 then
       last_1st_byte := get_byte(strb,last_1st_byte-1);
       last_2nd_byte := get_byte(strb,last_1st_byte-2);
     elsif strb_len = 3 then
       last_1st_byte := get_byte(strb,last_1st_byte-1);
       last_2nd_byte := get_byte(strb,last_1st_byte-2);
       last_3rd_byte := get_byte(strb,last_1st_byte-3);
     else
       last_1st_byte := get_byte(strb,last_1st_byte-1);
       last_2nd_byte := get_byte(strb,last_1st_byte-2);
       last_3rd_byte := get_byte(strb,last_1st_byte-3);
       last_4rd_byte := get_byte(strb,last_1st_byte-4);
     end if;
     --UTF8-1 0x00-7F
     --UTF8-2 0xC2-DF 0x80-BF
     --UTF8-3 0xE0 0xA0-BF 0x80-BF | 0xE1-EC 0x80-BF 0x80-BF | 0xED 0x80-9F 0x80-BF | 0xEE-EF 0x80-BF 0x80-BF
     --UTF8-4 0xF0 0x90-BF 0x80-BF 0x80-BF | 0xF1-F3 0x80-BF 0x80-BF 0x80-BF | 0xF4 0x80-8F 0x80-BF 0x80-BF
     if last_1st_byte <= 0x7F then
       --末尾が1バイト文字の場合、UTF8として問題なし
       return strb;
     elsif (last_2st_byte >= C2 and last_2st_byte <= 0xDF)
         or (last_1st_byte >= 0x80 and last_1st_byte <= 0xBF) then
       --末尾が2バイト文字の場合、UTF8として問題なし
       return strb;
     
     else
     end if;
   end;
   $$ language plpgsql;
   ~~~
