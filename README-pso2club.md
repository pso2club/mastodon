# 変更点メモ
## 何がやりたかったのか
* 連合TLが早いのと、似たインスタンスの合同TL的なものがほしくてやった。後悔している。

## 魔改造内容
* 連携タイムラインをつくる
* メニューに連携タイムラインを追加する
* メニューボタンに連携タイムラインを追加する
* メニューボタンの幅をボタン追加に合わせて修正する
* タイムラインの抽出条件を追加する
* タイムラインのトゥート受信時に更新を通知する
* 管理画面をつくる

## 差分ファイル
### 新規
| ファイル名                                               | 役割                 | 備考                   |
| -------------------------------------------------------- | -------------------- | ---------------------- |
| db/migrate/20170602155100_create_union_domains.rb        | DB設定               | id, domain, account_id |
| app/models/union_domain.rb                               | 連携ドメインモデル   |                        |
| app/controllers/admin/union_domains_controller.rb        | 管理画面コントローラ |                        |
| app/controllers/api/v1/timelines/union_controller.rb     | 連携TLコントローラ   |                        |
| app/views/admin/union_domains/_union_domain.html.haml    | 管理画面項目ビュー   |                        |
| app/views/admin/union_domains/index.html.haml            | 管理画面一覧ビュー   |                        |
| app/views/admin/union_domains/new.html.haml              | 管理画面追加ビュー   |                        |
| app/javascript/mastodon/features/union_timeline/index.js | Streaming用JS        |                        |

### 変更
| ファイル名                                                 | 役割                             | 備考                                     |
| ---------------------------------------------------------- | -------------------------------- | ---------------------------------------- |
| app/models/account.rb                                      | アカウントモデル                 | 連携ドメインのあそしえーしょん追加       |
| app/models/status.rb                                       | 投稿モデル                       | 連携ドメインの判定はここでうける         |
| app/views/about/_links.html.haml                           | 各種リンク                       | githubのURLを変更した                    |
| app/views/about/show.html.haml                             | このインスタンスについて         | githubのURLを変更した                    |
| app/views/about/terms.ja.html.haml                         | 利用規約・プライバシーポリシー   | ちょっとだけ表現かえた                   |
| app/javascript/mastodon/actions/compose.js                 | わかんにい・。・                 |                                          |
| app/javascript/mastodon/containers/mastodon.js             | ルーターかな・。・？             |                                          |
| app/javascript/mastodon/features/compose/index.js          | ヘッダーメニューのタブ・。・？   |                                          |
| app/javascript/mastodon/features/getting_started/index.js  | スタートのメニュー               |                                          |
| app/javascript/mastodon/features/ui/components/tabs_bar.js | ヘッダーのタブ（狭い時用）       |                                          |
| app/javascript/mastodon/locales/ja.json                    | ユーザー用言語ファイル（日本語） |                                          |
| app/javascript/mastodon/reducers/timelines.js              | わかんにい・。・                 |                                          |
| app/javascript/styles/components.scss                      | スタイルシート                   | ボタン追加した分幅を減らした             |
| app/services/fan_out_on_write_service.rb                   | 投稿あったときに更新通知するやつ | 投稿が連携内の場合に通知させるようにした |
| config/locales/en.yml                                      | 管理画面用言語ファイル（英語）   |                                          |
| config/locales/ja.yml                                      | 管理画面用言語ファイル（日本語） |                                          |
| config/navigation.rb                                       | 管理画面の左メニュー             | 連携用のメニュー追加                     |
| config/routes.rb                                           | ルーター                         | 連携TLのパス追加                         |
| db/schema.rb                                               | データーベース                   |                                          |
| lib/mastodon/version.rb                                    | バージョン                       | マイナーにunionを入れた                  |
| streaming/index.js                                         | ストリーミング                   | Streaming追加したやつのパス追加          |

## 本家から乗り換えるときは
* remote に入れて `git fetch` して `git checkout タグ名`
* 今月からアプデ遅れるかもしれない・。・；

## 本家のアップデートに対応するには
* たぶんpublicのタイムラインに変更あったらそれベースに変えればよいとおもう
* 1.4でタイムライン毎にコントローラーが別れたのでコンフリクト発生しにくいけどStatusに変更あったらわかりにくいので注意

## ぶっちゃけ
* **Docker環境**はうちDockerじゃないので動くかわかりません・。・
* ますとどんで初めてRuby(Rails)をさわった・。・
* UnionDomainは自信ない(たぶん無茶苦茶だとおもう・。・)
* それなりのインスタンスだと現状重くなるかもしれない・。・

## 連携を設定する
* 連携タイムラインは指定したドメインまたは指定したローカルユーザーのフォロイーで制御できる(はず)
* 1レコードで両方指定するのはNG(エラーにさせたかったのにならない・。・！)
* ドメイン/ユーザーいずれの指定でもローカルTLを含むのでリモートたちの設定だけでよい(自ドメインを含める必要はない)

## 表示(メニューとか)の変更
* app以下を`handshake-o`とか`連携`とかで検索かければよいかと・。・
