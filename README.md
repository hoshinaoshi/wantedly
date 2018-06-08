実行の前に環境変数を設定してください
`$ vim ~/.bash_profile`
```
export WANTEDLY_EMAIL=wantedlyに登録したemail address
export WANTEDLY_PASS=wantedlyに登録したpassword
```
write and quit
`$ source ~/.bash_profile`

コマンドの例
```
ruby wantedly.rb eng // エンジニアの場合
ruby wantedly.rb des // デザイナーの場合
```

wantedlyのリロード時の処理の都合により、
1. 一度にふるいにかけられるユーザ数は最大27名です
2. コマンド実行の間隔が20分以内程度だと、グループへの追加がうまくいきません
