# ASP.NET #

## メモ ##

1. JSON JavaScriptSerializer 文字列の長さエラー

JSON JavaScriptSerializer を使用したシリアル化または逆シリアル化中にエラーが発生しました。文字列の長さが maxJsonLength プロパティで設定されている値を超えています。

   ~~~cshtml
   cshtml
   @{
    var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
    serializer.MaxJsonLength = Int32.MaxValue; // default 4M
    var jsonModel = serializer.Serialize(Model);
   }
   <script>
    $(function () {
        var viewModel = @Html.Raw(jsonModel);
        // now you can access Model in JSON form from javascript
    });
   </script>
   ~~~

   参考資料：
   [Json Encode exception length exceeded](https://stackoverflow.com/questions/24155468/json-encode-throwing-exception-json-length-exceeded/39277843)
   [JavaScriptSerializer.MaxJsonLength プロパティ](https://docs.microsoft.com/ja-jp/dotnet/api/system.web.script.serialization.javascriptserializer.maxjsonlength?view=netframework-4.8)

1. ControllerでModelの値を変更しても、HiddenForで該当値を画面に表示する場合、前画面のPOST結果になる（変更字は無視される）

   ~~~csharp
   ModelState.Remove("PostValueID");
   ModelState.Clear();
   ~~~
