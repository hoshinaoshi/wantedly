# 何をするか
## wantedlyの「気になるリスト」に、気になるユーザを追加
指定された条件でユーザを検索し、検索条件に合致するユーザを  
エンジニアの場合は「エンジニア」、デザイナーの場合は「デザイナー」というグループに追加します。  

wantedlyの仕様上、検索条件に合わないユーザをリストに追加しない場合「スカウトを待っています。」のページに残り続けるため、  
そのようなユーザらを仮に「_エンジニア」、「_デザイナー」というグループに振り分けています。  

## 学歴フィルタをかける場合、フィルタから漏れた学校名をcsvに出力
少なくともエンジニアのスカウトでは、「大卒 かつ 大学の偏差値が58以上」という条件でも絞り込んでいます。  
そこから漏れた学校名の中には、表記揺れによって意図せず漏れてしまう大学名も存在するため、  
どの学校名が漏れたのかをcsvに出力しています。

# 注意
wantedlyのリロード時の処理の都合により、
1. 一度にふるいにかけられるユーザ数は最大27名です
2. コマンド実行の間隔が20分以内程度だと、グループへの追加がうまくいきません

# 準備
実行の前に環境変数を設定してください。  
`$ vim ~/.bash_profile`
```
export WANTEDLY_EMAIL=wantedlyに登録したemail address
export WANTEDLY_PASS=wantedlyに登録したpassword
```
write and quit して、  
`$ source ~/.bash_profile`

# コマンドの引数について
## 職種
エンジニアの第一引数: eng  
デザイナーの第一引数: des  
## 地域
関東に絞り込む場合の第二引数: kanto  
全国から探す場合の第二引数: all  

引数を入力せずにコマンドを実行した場合、引数の案内が出ます。

# コマンドの例
```
ruby wantedly.rb eng all // エンジニアで全国から絞り込みたい場合
ruby wantedly.rb des kanto // デザイナーで関東から絞り込みたい場合
```
