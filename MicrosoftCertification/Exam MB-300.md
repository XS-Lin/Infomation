# MB-300 Microsoft Dynamics 365: Core Finance and Operations #

[MB-300](https://docs.microsoft.com/ja-jp/learn/certifications/exams/mb-300)

## 計画 ##

1. 80時間 2020/09/07-2020/10/02 (平日2H×18 休日6H×8)

1. 平日=>20:00-21:00運動 21:00-23:00

## ラーニング パス: Finance and Operations アプリの利用開始 ##

### モジュール: Dynamics 365 Finance に関する入門情報 ###

#### 一般会計 ####

~~~plantuml
@startwbs
* 一般会計 [General Ledger]
** 決算トランザクション処理 [Process closing transactions]
*** トランザクションの割り当て [Allocate transactions]
*** 勘定科目の管理 [Maintain ledger accounts]
*** トランザクションを閉じる [Close transactions]
** 通貨金額の再評価 [Revalue currency amounts]
*** 会計通貨の変換 [Convert accounting currency]
** 事前決算レポートの準備 [Prepare pre-closing reports]
*** 電子ドキュメントの作成 [Create electronic documents]
** 原価と所得の配賦 [Allocate cost and income]
*** トランザクションの連結 [Consolidate transactions]
*** キャシューフォローおよび必要通貨の予測 [Forecast cash flow & currency requirements]
*** トランザクションの削除 [Eliminate transactions]
** 帳簿の締め処理 [Close books]
*** 会計期間および会計年度の締め [Close period and fiscal year]
@endwbs
~~~

#### 現金および銀行管理 ####

* 預金伝票 [deposit slip]
* 小切手 [check]
* 受取手形,為替手形 [bill of exchange]
* 支払手形,約束手形 [promissory note]
* 保証人 [guarantor]
* 受益者,受取人 [beneficiary]
* 銀行取引明細書 [bank statements]
* 基準 [criteria]
* 調整アカウント [reconciliation account]
* 預り金 [deposit]
* 振替 [transfer]
* 銀行残高 [bank balances]
* 見積もり [estimate]

#### 税 ####

* 当局 [authorities]
* 徴収 [collect]
* 支払う [pay]
* 売上税 [sales tax]
* 付加価値税 (VAT) [value-added tax]
* 物品、サービス税 (GST) [goods and services tax]
* 単位ベースの手数料 [unit-based fees]
* 源泉徴収税 [withholding tax]

#### 買掛金勘定 ####

* 買掛金勘定 [Accounts payable]
* 仕入先 [vendor]
* 配達,配送,出荷 [delivery]
* 決済 [settlement]
* 請求書 [invoice]
* 請求書承認仕訳 [invoice approval journal]
* 仕入先請求書 [Vendor invoice]
* 不一致, 相違, 食い違い, 違い, 齟齬, 懸隔 [discrepancy]
* 仕入先請求仕訳 [vendor invoice journal]
* 前払い [positive pay]
* 支払提案 [payment proposal]
* 貸方 [credit]
* 借り方 [debit]
* 前払い請求書 [prepayment invoice]
* ディスカウント,割引,値引き [discount]

#### 売掛金勘定 ####

* 売掛金勘定 [Accounts receivable]
* 顧客請求書 [customer invoice]
* 入金 [payment]
* 納品書 [packing slip]
* 受注 [sales order]

#### 与信および取立 ####

* 与信および取立 [Credit and collections]
* 基準 [criteria]
* 残高 [balance]
* 免除,放棄 [waive]
* 再開,復活[reinstat]
* 取り消し,逆行 [reverse]
* 利息 [interest]
* 手数料 [fee]
* 滞納 [delinquent]
* 損金,帳消し,償却 [write-off]
* 預金不足(NSF) [Not Sufficient Funds]

#### 予算作成 ####

* 予算作成 [Budgeting]
* 予報,予測 [forecasting]
* 予算 [budget]
* 成熟 [maturity]

#### 固定資産 ####

* 固定資産 [Fixed assets]
* 乗物 [vehicles]
* 減価償却 [depreciation]
* 取得 [acquisition]
* 償却 [amortize]
* 廃棄,処分 [dispose]
* 引退 [retire]
* 取得と処分のトランザクション [acquisition and disposal transactions]
* 有効期間 [lifetimes]
* 固定資産の帳簿価格引上と償却 [write ups and write downs]

#### 原価会計 ####

* 原価会計 [Cost accounting]
* 原価管理 [Cost control]

### モジュール: Dynamics 365 Supply Chain Management に関する入門情報 ###

#### Supply Chain Management の利点 ####

* 個別生産 [discrete manufacturing]
* リーン生産 [lean manufacturing]
* 見込み生産 [make to stock]
* 受注生産 [make to order]
* 受注プル生産 [pull to order]
* 受注構成 [configure to order]
* 個別受注生産 [engineer to order]
* 製造原料 [manufacturing material]
* 完成品 [finished goods]
* 倉庫管理 [warehouse management]
* 物流管理 [logistics management]
* 合理化 [streamline]

#### Supply Chain Management の概要 ####

* 固定資産モジュール [Fixed assets module]
* 在庫管理モジュール [Inventory management module]
* 人事管理モジュール [Human resources module]
* 組織管理モジュール [Organization administration module]
* マスター プラン モジュール [Master planning]

~~~plantuml
@startmindmap
* 発注書 [Purchase order]
** 取得 [Acquisitions]
*** 固定資産 [Fixed assets]
** 財務トランザクション [Financial transactions]
*** 総勘定元帳 [General ledger]
** 発注書の送信 [Submission of purchase orders]
*** 仕入先コラボレーション [Vendor collaboration]
** 品目トランザクション [Item transactions]
*** 在庫/倉庫管理 [Inventory/Warehouse management]

left side

** 直納/発注書の作成 [Direct delivery/Puchare order creation]
*** 営業とマーケティング [Sales and marketing]
** 予算チェック [Budget checks]
*** 予算作成 [Budgeting]
** 計画発注書 [Planned purchase orders]
*** マスタープラン [Master planning]
** プロジェクト購買 [Project purchase]
*** プロジェクトと会計の管理 [Project and accounting management]
** 見積依頼購買契約 [Request for quotations purchase requisitions aggreements]
*** 調達とソーシング [Procurement and souring]
** 発注書明細行 [Purchase order line]
*** 製品情報管理 [Product infomation management]
** 外注 [Subcontracting]
*** 生産管理 [Production control]
@endmindmap
~~~

~~~plantuml
@startmindmap
* 在庫管理 [Inventory management]
** 財務トランザクション [Financial transactions]
*** 総勘定元帳 [Generel ledger]
** 出庫 [Issues]
*** 製造オーダーピッキングリスト [Production order picking list]
** 入庫/出庫 [Receipts/Issues]
*** 在庫/倉庫管理 [Iventory/Warehouse management]
** 出庫 [Issues]
*** プロジェクト販売注文 [Project sales orders]
** 出庫 [Issues]
*** 販売注文 [Sales orders]
** 出庫 [Issues]
*** 仕入先の返品 [Vendor returns]

left side

** 入庫 [Receipts]
*** 発注書 [Purchase orders]
** 入庫 [Receipts]
*** プロジェクトの発注書 [Project purchase orders]
** 入庫 [Receipts]
*** 製造オーダー完了レポート [Production order Report as finished]
** 入庫 [Receipts]
*** 顧客の返品 [Customer returns]
@endmindmap
~~~

* 棚卸 [counting]
* 転送 [transfer]
* 検査 [quarantine]
* 品質管理 [quality controls]

#### 原価管理 ####

* 原価会計 [Cost accounting]
* 原価会計 > ワークスペース > 原価管理 [Cost accounting > Workspaces > Cost control]
* 原価管理 [Cost management]
* 原材料 [raw materials]
* 半完成品 [semi-finished goods]
* 完成品 [finished goods]
* 仕掛品 [work-in-progress assets]

#### 在庫管理および倉庫管理 ####

* 在庫管理および倉庫管理 [Inventory management and Warehouse management]

~~~plantuml
@startmindmap
* 在庫/倉庫管理 [Inventory/Warehouse management]
** 入庫作業 [Inpound operations]
*** 製品の入庫 [Receive products]
**** 品目のプットアウェイ [Put away items]
** 品質保証 [Quality assurance]
*** 製品のテスト [Test products]
**** 製品を保留中に設定 [Set products on hold]
** 倉庫作業 [Warehouse operations]
*** 倉庫活動の追跡 [Track warehouse activities]
**** 倉庫活動の最適化と管理 [Optimize and maintain warehouse activities]
** 出庫作業 [Outbound operations]
*** 出庫準備と梱包作業 [Prepare shiment and packing operations]
**** 品目のピッキング [Pick items]
***** コンテナ-詰めされた製品 [Containerized products]
****** 製品の出荷 [Ship products]
** 在庫管理 [Inventory control]
*** コスト構造の定義 [Define cost structure]
**** 価格と価格構造の定義 [Define prices and price structure]
***** 在庫終了 [Close inventory]
****** 在庫の調整 [Adjust inventory]
******* 在庫の再計算 [Recalculate inventory]
@endmindmap
~~~

#### マスター プラン ####

~~~plantuml
@startmindmap
* マスター プラン [Master Planning]
** 組織管理 [Organization Administration]
** 買掛金勘定 [Accounts payable]
** 売掛金勘定 [Accounts receivable]
** 総勘定元帳 [General ledger]
** 製品情報管理 [Product information management]
** 生産管理 [Production control]
** 在庫/倉庫管理 [Inventory/Warehouse management]
** 営業とマーケティング [Sales and marketing]
@endmindmap
~~~

* 正味必要量計画 [Net requirements plan]
* 予測プラン [Forecast planning]

#### 調達 ####

~~~plantuml
@startmindmap
* 調達 [Procurement and sourcing]
** 調達先と仕入先を特定する [Identify sources and vendors]
*** 適格な仕入先を検索する [Search for a qualified vendor]
**** 仕入先要求を送信する [Submit vendor request]
***** 仕入先要求を管理する [Manage vendor request]
** 仕入先を選定して管理する [Select and maintain vendors]
*** 仕入先コラボレーションポータル [Vendor collaboration portal]
**** 仕入先のカテゴリとカタログを管理する [Maintain vendor categorise and datalogs]
***** 仕入先応答を管理する [Manage vendor responses]
** 契約、リベートを管理する [Maintain agreements,rebates]
*** 売買契約を管理する [Maintain trade agreements]
**** 購買契約を管理する [Maintain purchase agreements]
** 製品を注文する [Order products]
*** 調達カタログを管理する [Maintain procurement catalogs]
**** 購買契約を作成する [Create purchase requisitions]
***** 購買契約を発注書に変換する [Convert purchase requistions to purchase orders]
*** 発注書を作成する [Create purchase order]
**** 発注書の変更を管理 [Purchase order change management]
***** 発注書を確認する [Purchase order confimation]
** 製品を登録する [Register products]
*** 製品の受け入れを拒否する [Reject the receipt of products]
**** 納品日を管理する [Manage delivery dates]
***** 製品受領書を確認する [Confirm products receipts]
****** タスクを買掛金勘定、請求および支払に渡す [Pass the task to Accounts payable,invoicing and payment]
** 買掛金勘定に仕入先請求書を記録する [Accounts payable records vendor invoices]
*** 買掛金勘定、請求書照合と検証を実行する [Accounts Payable,Perform invoice matching and validation]
**** 買掛金勘定、支払を生成して送信する [Accounts Payable,generate and submit payments]
***** 買掛金勘定、仕入先決済を管理する [Accounts Payable,manage vendor settlements]
** 支出を分析する [Analyze spending]
*** ポリシーを管理する [Maintain plicies]
@endmindmap
~~~

#### 仕入先コラボレーション ####

* 仕入先の承認(自動確認)->発注書の状態:確認済み
* Vendor accepts(automatic confirmation)->PO status:Confirmed
* 仕入先の承認(自動確認なし)->仕入先の応答:承認済->発注書の状態:外部レビュー中
* Vendor accepts(no automatic confirmation)->Vendor response:Accepted->PO status:In external review
* 仕入先の拒否->仕入先の応答:拒否->仕入先メモと共に拒否がが返された
* Vender rejects->Vendor response:Rejected->Rejection sent with vendor note
* 仕入先が変更内容を承認->仕入先の応答:変更内容承認済->発注書の状態:外部レビュー中
* Vendor accepts with changes->Vendor response:Accepted with changes->PO status:In external review

#### 製品情報管理 ####

* 製品タイプ 品目、またはサービス [Product type Item or service]
* 製品サブタイプ個別の製品または製品マスター [Product subtype Distinct products or product masters]
* 製品バリアント モデルの定義: [Definition of the product variant model]
  * 製品分析コードと分析コードグループ [Product demensions and dimension groups]
  * 製品の分類 [Product nomenclature]
  * 製品コンフィギュレーション モデル [Product configuration models]
* 1 つ以上のカテゴリに対する製品の関連付け [Association of the product with one or more categories]
* 製品およびカテゴリ属性の定義 [Definition of the product and category attributes]
* 製品画像 [Product images]
* アタッチメント [Attachments]
* 単位と関連する変換 [Units of measure an related conversions]
* すべての名前と説明の翻訳 [Translations for all names and descriptions]

### モジュール: Dynamics 365 Supply Chain Management における生産管理の開始 ###

#### 生産管理における主要な概念 ####

* カレンダー [Calendars]
* リソース [Resources]
  * 仕入先 [Vendor]
  * 人事管理 [Human resources]
  * 機械 [Machine]
  * ツール [Tool]
  * 場所 [Location]
  * 設備 [Facility]
* リソースの種類 [Resource types]
* リソースの能力 [Resource capabilities]
  * 生産グループ [Production groups]
  * 生産管理グループ [Production pools]
  * プロパティ [Properties]
  * リソースの能力 [Resource capabilities]
* 部品表 (BOM) [Bill of materials]
* 工順と工程 [Routes and operations]
* 式 [Formula]
* バリュー ストリーム [Value streams]
* 生産フロー モデル [Production flow models]
* 生産単位 [Production units]
* 生産グループ [Production groups]
* 生産管理グループ [Production pools]
* 配賦キー [Allocation keys]
* かんばん機能 [Kanban functionality]

#### 統合製造の理解 ####

* 製造オーダー [Production order]
* バッチ オーダー [Batch order]
* かんばん [Kanban]
* プロジェクト [Project]
* 材料配賦の相互供給ポリシー – BOM でのリソース消費 [Materials allocation cross-supply policy – Resource consumption on BOMs]

#### 生産方式 ####

* 見込み生産 [Make to stock]
* 受注生産 [Make to order]
* 受注仕様生産 [Configure to order]
* 個別受注生産 [Engineer to order]

#### 生産プロセスと生産ライフ サイクルの概要 ####

* 生産ライフ サイクルの概要 [Overview of the production life cycle]
  * 作成済 [Created]
  * 見積 [Estimated]
  * スケジュール済み [Scheduled]
    * 工程のスケジューリング [Operations scheduling]
    * ジョブのスケジューリング [Job scheduling]
    * かんばんスケジュール [Kanban schedule]
  * リリース済 [Released]
  * 準備済/ピッキング済 [Prepared/Picked]
  * 開始済 [Started]
  * レポート進行/ジョブの完了 [Report progress/Complete jobs]
  * 完了として報告済 (製品受領書) [Reported as finished (the product receipt)]
  * 品質評価 [Quality assessment]
  * プット アウェイと受注生産 [Put away and Ship to order]
  * 終了済 [Ended]
  * 期間の決算 [Period closure]

* 消費 [consumption]

#### 個別製造 ####

* 注文ベースの生産 (個別の製造オーダーでの生産) [Order-based production (production in individual production orders)]
* 製品の変更が頻繁にある場合 [Product changes frequently]
* ワーク センターのさまざまな順序 (複雑なルーティング) [Varying sequence of work centers (complex routings)]
* 半完成製品は多くの場合、一時的な保管場所に配置されます [Semi-finished products often put into interim storage]
* 注文を参照してステージングされるコンポーネント [Components staged with reference to order]
* ステータスを処理しています [Status processing]
* 個々操作または注文の完了確認 (一括引き落とし) [Completion confirmation (backflush) for individual operations or orders]
* 注文ベースの原価会計 [Order-based cost accounting]
* 複雑度の高い少量の製品、または複雑度の低い大量の製品を構築、組み立て、生産する [Builds, assembles, produces in low volume with high complexity or high volume of low complexity]
* 製品を生産する [Makes products]
* 原材料は、多くの場合、部品単位で測定されます [Raw materials are most often measured in pieces]
* 通常、製品は 1 つの出力用にスケールされます [Products are usually scaled for an output of one (1)]
* 製品の出力は 1 つだけです [Only has one product output]
* 仕損は、原材料明細行でのみ計上できます [Waste can only be accounted for on raw material lines]

#### プロセス製造 ####

* 特徴
  * フォーミュラ、つまりレシピを使用します。 [Uses a formula, or recipe]
  * 複数の製品をバッチでブレンドします。 [Blends products together in a batch]
  * 分解できないものを作成します。 [Builds something that cannot be taken apart]
  * 類似する製品があります。1 つの製品を別の製品と区別することはできません。 [Has analogous products, where you can’t tell one product from another]
  * 取消できない製品が含まれています [Includes products that cannot be reversed]
  * 変動成分が含まれています [Involves variable ingredients]
  * 連産品と副産物を生産します [Produces co-products and by-products]
  * 割り込みの最小化が含まれています [Contains minimal interruptions]
  * 塗料、医薬品、飲料、食品など、大量の製品を製造します [Makes products in bulk quantities, such as paints, pharmaceuticals, beverages, and food products]
  * フォーミュラの原材料は、部分ではなく、重量または体積で測定されます [Measures raw material ingredients in formulas by weight or volume instead of pieces]
  * 1 より大きい数量を計る標準サイズ (バッチ サイズ) が 1 つ以上あります [Has one or more standard sizes (batch sizes) that are scaled for a quantity greater than one]
  * 可能性として 1 つ以上の製品出力があります [Has potentially one or more product outputs]
  * 利回りとしての無駄/損失の勘定 (出力と入力の間の比率) [Accounts for waste/loss as yield, which is the ratio between output and input]
  * 注文への変更 (MTO)、在庫への変更 (MTS)、混合モード、ハイブリッド環境など、さまざまなプロセスをサポートします [Supports a wide range of processes, including make to order (MTO), make to stock (MTS), in mixed mode, and hybrid environments]

* 主要な要件
  * フォーミュラ管理 [Formula management]
  * 連産品および副産物の計画と管理 (予定外の連産品および副産物の原価配賦を含む) [Co-product and by-product planning and management, including allocating cost for unplanned co-products and by-products]
  * コンテナ詰め梱包 [Containerized packaging]
  * バッチ オーダーの管理 (梱包済み製品のバッチ オーダーを、類似した梱包済み製品、および親バルク品目に連結することを含む) [Batch order management, including consolidating batch orders for packed products with similar packed products and a parent bulk item]
  * 完全な可視性と部分的な可視性の CW 機能 [Full visibility and partial visibility catch weight functionality]
  * バッチ属性の割り当て、検索、および引当機能 [Batch attribute assignment, search, and reserve capability]
  * 在庫バッチ管理 [Inventory batch management]
  * 仕入先固有のバッチ情報を設定する、1 つ目の有効期限、1 番目のアウト (FEFO) および消費期限在庫管理 [First expiry, first out (FEFO) and shelf life inventory management to set vendor-specific batch information]
  * 商品価格決定機能 [Commodity pricing functionality]
  * リベートおよび取引促進機能 [Rebate and trade promotion capability]

* プロセス製造機能
  * 処理済の商品の販売業者は、供給と需要を予測し、計画することができます。 [Distributors of processed goods can forecast and plan the supply and demand.]
  * 調達と販売は、2 つの測定単位で管理できます。 [Procurement and sales can be managed in a dual unit of measurement.]
  * 低温殺菌ミルク、塗料生産、ミキシングなど、自然および消費財パッケージ製品の在庫バッチに対して、短期および長期の消費期限と厳格な品質基準を維持することができます。 [Short and long shelf life and stringent quality standards can be maintained for inventory batches of natural and consumer packaged products, such as pasteurized milk, paint production and mixing, and so on.]
  * プロセス製造は、バッチまたは半連続製造プロセスを自動化する必要がある会社にも使用できます。 処理済の商品のメーカーは、複雑なフォーミュラをすばやく定義し、生産原価を正確に制御できます。また、製造するか、購入するかを機敏に決定し、それらの切り換えが簡単にできます。 [Process manufacturing can also be used by companies that want to automate their batch or semi-continuous manufacturing processes. Manufacturers of processed goods can quickly define complex formulas to accurately control production costs and they can more easily switch between make or buy decisions with agility.]
  * 複雑なフォーミュラの保持 [Retention of complex formulas]
  * 消費期限製品の管理 [Manage shelf life products]
  * 商品価格設定の管理 [Manage commodity pricing]
  * 製品コンプライアンスの管理 [Manage product compliance]
  * 複雑なリベートの設定および適用 [Set up and apply complex rebates]
  * 詳細ロット追跡と制御 [Advanced lot tracking and control]
  * 複数のアウトプットの原価管理の強化 [Enhanced cost management of multiple outputs]
  * 2 つの測定単位での製品の調達、保管、販売 [Procure, store, and sell products in dual units of measure]
  * 1 つまたは 2 つの測定単位について組立または分解の生産を管理する [Manage production for assembly or disassembly for single or dual units of measure]

#### リーン生産 ####

* 特徴
  * 生産性を犠牲にすることなく、無駄を最小限に抑える [Waste minimization without sacrificing productivity]
  * 過負荷によって生じる無駄と、作業負荷の不均一によって生じる無駄を考慮する [Considers waste created through overburden and waste created through unevenness in work loads]
  * 価値を高めるものに重点を置き、価値をもたらさないものをすべて削減する [Emphasizes what adds value and reduces everything that does not add value]
  * Toyota の生産方式から派生したものである [Derived from the Toyota production system]
  * 元々は Toyota の 7 つの無駄に着目したことで知られている [Known for its focus on the original Toyota seven wastes]
* 原則
  * 顧客の価値 [Customer value]
    * 顧客がリーン サプライチェーンの製品の価値を定義します。 [The customer defines the value of product in a Lean supply chain.]
    * 付加価値活動を通じて、製品を顧客の望むものに近づけます。 [Value-adding activities transform the product closer to what the customer wants.]
    * 価値を追加しない活動は、無駄であると見なされます。 []
  * バリュー ストリームの識別 [Identify the value stream]
  * フロー [Flow]
  * プル [Pull]
  * 完成度 [Perfection]
* 用語
  * バリュー ストリーム [Value Stream]
  * カイゼン [Kaizen]
  * (作業) セル [(Work) Cell]
  * サイクル時間 [Cycle time]
  * タクト タイム [Takt time]
  * スーパーマーケット [Supermarket]
  * 生産フロー [Production flow]
  * 一括原価計算 [Backflush costing]
  * かんばん [Kanban]
  * 平準化 [Heijunka leveling]

#### 統合製造向け生産管理の構成 ####

* 開始前
  * パラメーター [Parameters]
  * 仕訳帳名 [Journal names]
    * 製造オーダー仕訳帳 [Production order journals]
    * 生産仕訳帳 [production journals]
      * ピッキング リスト [Picking list]
      * 工順カード [Route card]
      * ジョブ カード [Job card]
      * 完了レポート [Report as finished]
    * 仕訳
      * 仕訳ヘッダー
        * 仕訳(ヘッダー) [Journal (header)]
          * タイプ [Type]
          * 名前 [Name]
        * 番号 [Number]
      * 仕訳明細行 [Journal lines]
        * 材料と数量 [Materials and quantities]
        * 操作と費やした時間 [Operations and time spent]
        * 適正数量と不良数量 [Good and bad quantities]
* 配賦キー [Allocation keys]
  * サイト [Sites]
  * 生産単位 [Production units]
  * リソース [Resources]
  * リソースの種類 [Resource types]
  * バンドル タイプ [Bundle type]
    * 見積 [Estimation]
    * ジョブ [Jobs]
    * 正味時間 [Net time]
    * リアルタイム [Real time]
* 生産管理グループ [Production pools]
  * 生産する準備ができたオーダー [Orders that are ready to be produced]
  * 出荷されていない外注オーダー [Subcontracted orders that are missing deliveries]
  * 通常の生産 [Regular productions]
  * 材料が無いオーダー [Orders that are missing materials]
  * コンピュータ障害のために遅延するオーダー [Orders that are delayed because of machine failure]
  * リリース、開始、またはスケジューリングの準備が完了しているオーダー [Orders that are ready for release, start, or scheduling]

#### 能力計画 ####

* リソースと作業時間カレンダーの設定プロセス
  * 1.作業時間テンプレートの作成。 [Create working time templates.]
  * 2.作業時間カレンダーの作成。 [Create working time calendars.]
  * 3.能力の作成。 [Create capabilities.]
  * 4.リソースの作成。 [Create resources.]
  * 5.リソース グループの作成。 [Create resource groups.]

* 組織管理 > 設定 > カレンダー > 作業時間テンプレート [Organization administration > Setup > Calendars > Working time templates]
* 組織管理 > 設定 > カレンダー > カレンダー [Organization administration > Setup > Calendars > Calendars]
* 生産管理 > 設定 > リソース > リソース グループ [Production control > Setup > Resources > Resource groups]
* 組織管理 > リソース > リソース [Organization administration > Resources > Resources]

* リソースの能力 [Capabilities]
  * 能力 [Capabilities]
  * スキル [Skills]
  * コース [Courses]
  * 証明書 [Certificate]
  * 職位 [Title]

* リソース [Resources]
  * 機械 [machines]
  * 工具 [tools]
  * 人事管理 [human resources]
  * 仕入先 [vendors]
  * 設備 [facility]
  * 場所 [locations]

#### 一般会計と生産管理モジュールとの統合 ####

* 生産の監視と制御 [Monitoring and controlling the production]
* 原価の見積と計算 [Estimating and calculating costs]
* オーダーのスケジュール設定 [Scheduling orders]
* 実際の生産の開始と終了 [Starting and ending actual production]

* 作成と見積 [Create and estimate]
* スケジュール [Schedule]
* リリースと開始 [Release and start]
* 完了レポート [Report as finished]
* 終了 [End]
* 既定の元帳設定 [Default ledger settings]
* 在庫転記プロフィール [Inventory posting profiles]
* 生産グループ [Production groups]
* 生産仕訳帳 [Production journals]
* 生産仕訳帳のタイプ [Production journal types]
* 生産中の消費に関するフィードバック [Feedback on consumption during production]
* 生産原価の転記 [Production cost posting]

## ラーニング パス: Finance and Operations アプリでの組織の構成 ##

### モジュール: Finance and Operations アプリの法人を計画して実装する ###

#### 組織階層と作業単位について理解する ####

* 作業単位 [Operating units]
  * コスト センター [Cost center]
  * 事業単位 [Business unit
  * バリュー ストリーム [Value stream]]
  * 部門 [Department]
  * 小売チャネル [Retail channel]
  * 支店 [Branch]
  * レンタル場所 [Rental Location]
  * リージョン [Region]
  * チーム [Teams]

#### 内部組織を法人と作業単位のどちらでモデル化するかを決定する ####

* Finance and Operations アプリの法人は、必ずしもビジネスの実体と対応している必要はありません
  * たとえば、取引に関与する会社に子会社法人を持たせることもできます。 この例では、取引を行う法人が必要であり、子会社法人の連結決算を行うには、仮想的な法人が必要です。

* マスター データ [Master data]
* モジュールのパラメーター [Module parameters]
* データ セキュリティ [Data security]
* 元帳 [Ledgers]
* 会計カレンダー [Fiscal calendars]
* 連結 [Consolidation]
* 集中支払 [Centralized payments]

#### 目的とポリシーの適用 ####

階層は、次の目的で使用できます。

* 調達内部統制 [Procurement internal control]
* 経費内部統制 [Expenditure internal control]
* 組織図 [Organization charts]
* 署名権限の内部統制 [Signature authority internal control]
* 仕入先支払の内部統制 [Vendor payment internal control]
* 監査内部統制 [Audit internal control]
* 集中支払 [Centralized payments]
* セキュリティ [Security]
* 小売品揃え [Retail assortment]
* 小売補充 [Retail replenishment]
* 小売レポート [Retail reporting]
* 給付金の適格性制御 [Benefit eligibility control]
* 予算計画 [Budget planning]
* Retail POS の転記 [Retail POS posting]
* プロジェクト管理 [Project management]
* 割増所得の生成 [Premium earning generation]
* 分散型注文管理 (DOM) [Distributed order management]

## Bookmark ##

https://docs.microsoft.com/ja-jp/learn/modules/plan-implement-security-finance-operations/
https://docs.microsoft.com/en-us/learn/modules/plan-implement-security-finance-operations/6-exercise-1