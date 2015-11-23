stackを使ってYesodの環境を作った.
stack、涙が出るほど素晴らしい.

## ビルド
stackを使っている.


### Amazon Linuxの場合

```shell
sudo yum -y update
```

```shell
curl -sSL https://s3.amazonaws.com/download.fpcomplete.com/centos/7/fpco.repo | sudo tee /etc/yum.repos.d/fpco.repo
```

```shell
sudo yum -y install stack
```

```shell
cd /tmp
wget https://github.com/jabaraster/yesod-wiki-by-stack/archive/20151123_1st.zip
unzip 20151123_1st.zip
sudo mv yesod-wiki-by-stack-20151123_1st/ /opt/yesod-full-sample
cd /opt/yesod-full-sample
```

GHCのインストールに必要なライブラリをインストールする.

```shell
sudo yum -y install zlib-devel
```

GHCをインストールする.

```shell
stack setup
```

```shell
stack build
```
ここはかなり時間がかかります.

```shell
stack install
```

リバースプロキシを立てる

```shell
sudo yum -y install nginx
sudo service nginx start
sudo chkconfig nginx on
```

```shell
sudo vi /etc/nginx/nginx.conf
```

55行目辺りの以下の記述を変更.  
変更前)  
```
55         location / {
56         }
```

変更後)  
```
55         location / {
56             proxy_pass http://127.0.0.1:3000;
57         }
```

```shell
sudo service nginx restart
```

## サーバ起動
環境変数APPROOTの設定が必要な点に注意.

```shell
export APPROOT=http://<ホスト名>
yesod-full-sample
```

## 開発用サーバ(develモード)の起動
stack exec -- yesod devel

## TODO
OS起動時に自動起動する設定.
