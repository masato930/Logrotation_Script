# はじめに
「/var/log/messages」を所定の時間にログローテーションするbashスクリプトを作成し、「crontab」に仕込む。

<br>

# 環境

**CentOS 7.6.1810**

```bash:/etc/redhat-release
[root@minikube log]# cat /etc/redhat-release 
CentOS Linux release 7.6.1810 (Core) 
[root@minikube log]# 
```

<br>

# 手順

**1.bashスクリプトの作成**
**2.crontab設定**
**3.ジョブ動作テスト**

※今回は個人の検証環境のため、「rootユーザー」にて実施しております。

<br>

## 1.bashスクリプトの作成

<br>

**①ログ保存用ディレクトリ作成**

ログ保存用のディレクトリを作成する。

```bash
mkdir -p /var/log/message_log_dir
```

ディレクトリが作成できたことを確認。

```bash
[root@minikube ~]# ls -la /var/log/message_log_dir/
合計 4
drwxr-xr-x.  2 root root    6  2月  5 06:26 .
drwxr-xr-x. 21 root root 4096  2月  5 06:26 ..
[root@minikube ~]# 
```

<br>

**②bashスクリプト格納用ディレクトリ作成**

bashスクリプト格納用のディレクトリを作成する。
※bashスクリプトのログ保存先も含めて作成。

```bash
mkdir -p /root/script/log
```

ディレクトリが作成できたことを確認。

```bash
[root@minikube ~]# ls -la /root/script/log
合計 0
drwxr-xr-x. 2 root root  6  2月  5 12:48 .
drwxr-xr-x. 3 root root 42  2月  5 12:43 ..
[root@minikube ~]# 
```

作成したディレクトリに移動する。

```bash
cd /root/script
```

<br>

**③bashスクリプト作成**

`/root/script`配下に`logrotate-test.sh`を作成

```bash
vi /root/script/logrotate-test.sh
```

※`vi`以外にも`vim`や`VSCode`でもスクリプト編集可能


```bash:logrotate-test.sh
#!/bin/sh
#「/var/log/messages」をログローテーションするスクリプト

# 日時取得
data=`date "+%Y%m%d_%H%M%S"`

# ログ取得設定
LOGFILE=/root/script/log/logrotate-test_${data}.log
exec >> ${LOGFILE} 2>&1

# ログローテート処理
if [ -e /var/log/messages ]; then

  # 「/var/log/messages」ファイルを「/var/log/message_log_dir」へ移動
  mv /var/log/messages /var/log/message_log_dir/messages_${data}

  # 新しい「/var/log/messages」ファイルを作成
  touch /var/log/messages

  # 移動したログファイルを圧縮
  zip -j /var/log/message_log_dir/messages_${data}.zip /var/log/message_log_dir/messages_${data}

  # 移動したログファイルを削除
  rm -f /var/log/message_log_dir/messages_${data}

else
  
  # スクリプトの終了
  exit

fi
```

<br>

**④スクリプトの権限変更**

作成した`logrotate-test.sh`に対して、所有者のみに実行権限を付与する。

- 事前確認

所有者「root」に実行権限がないことを確認。
→「rw-」

```bash
[root@minikube ~]# ls -la /root/script/logrotate-test.sh 
-rw-r--r--.  1 root root  812  2月  5 12:49 logrotate-test.sh
[root@minikube ~]# 
```

- 権限変更

所有者「root」に実行権限を追加。

```bash
chmod u+x /root/script/logrotate-test.sh
```

- 事後確認

所有者「root」に実行権限が付与されたことを確認。
→「rwx」

```bash
[root@minikube script]# ls -la /root/script/logrotate-test.sh 
-rwxr--r--. 1 root root 812  2月  5 12:49 /root/script/logrotate-test.sh
[root@minikube script]# 
```

<br>

## 2.crontab設定

**①crontab事前確認**

以下コマンドを実行し、事前にジョブが登録されていないか確認。

```bash:実行コマンド
crontab -l
```

実行例)

```bash:実行例
[root@minikube log]# crontab -l
no crontab for root
[root@minikube log]# 
```

**②crontab設定**

以下コマンドを実行し、crontabの設定を実施。

```bash:実行コマンド
crontab -e
```

毎日、20:00にシェルを実行するよう設定

```bash:設定内容
0 20 * * * /root/script/logrotate-test.sh
```

※詳しい確認方法は、以下サイトを参照
[cron の設定ガイド](https://www.express.nec.co.jp/linux/distributions/knowledge/system/crond.html)

**①crontab事後確認**

以下コマンドを実行し、設定したジョブが登録されていることを確認。

```bash:実行コマンド
crontab -l
```

実行例)

```bash:実行例
[root@minikube script]# crontab -l
0 20 * * * /root/script/logrotate-test.sh
[root@minikube script]# 
```

<br>


## 3.ジョブ動作テスト

20:00以降に結果を確認する。

**①ログファイル確認**

- `/root/script/log`へ移動

```bash
cd /root/script/log
```

- ログが保存されていることを確認

```bash
[root@minikube log]# pwd
/root/script/log
[root@minikube log]# ls -la
合計 4
drwxr-xr-x. 2 root root 48  2月  5 20:00 .
drwxr-xr-x. 3 root root 42  2月  5 12:43 ..
-rw-r--r--. 1 root root 50  2月  5 20:00 logrotate-test_20210205_200001.log
[root@minikube log]# 
```

- ログファイルに処理結果が出力されていることを確認

```bash
[root@minikube log]# cat logrotate-test_20210205_200001.log 
  adding: messages_20210205_200001 (deflated 81%)
[root@minikube log]# 
```

**②新しい「/var/log/messages」が作成されていることを確認**

`/var/log/messages`が存在することを確認。

```bash
[root@minikube log]# ls -la /var/log/messages
-rw-r--r--. 1 root root 0  2月  5 20:00 /var/log/messages
[root@minikube log]# 
[root@minikube log]# cat /var/log/messages
[root@minikube log]# 
```

**③圧縮したログファイルの確認**

- `/var/log/message_log_dir`へ移動

```bash
cd /var/log/message_log_dir/
```

- `messages_yyyymmdd_hhmmss.zip`が存在することを確認

```bash
[root@minikube message_log_dir]# pwd
/var/log/message_log_dir
[root@minikube message_log_dir]# ls -la
合計 24
drwxr-xr-x.  2 root root    42  2月  5 20:00 .
drwxr-xr-x. 21 root root  4096  2月  5 20:00 ..
-rw-r--r--.  1 root root 20075  2月  5 20:00 messages_20210205_200001.zip
[root@minikube message_log_dir]# 
```

- `messages_yyyymmdd_hhmmss.zip`を解凍する。

```bash
unzip messages_20210205_200001.zip 
```

実行結果)

```bash:実行結果
[root@minikube message_log_dir]# unzip messages_20210205_200001.zip 
Archive:  messages_20210205_200001.zip
  inflating: messages_20210205_200001  
[root@minikube message_log_dir]#
```

- 解凍したログファイルが存在することを確認

```bash
[root@minikube message_log_dir]# ls -la
合計 128
drwxr-xr-x.  2 root root     74  2月  5 20:08 .
drwxr-xr-x. 21 root root   4096  2月  5 20:00 ..
-rw-r--r--.  1 root root 102951  2月  5 19:10 messages_20210205_200001
-rw-r--r--.  1 root root  20075  2月  5 20:00 messages_20210205_200001.zip
[root@minikube message_log_dir]# 
```

- ファイルの内容を確認

ログがローテーションできていることを確認。

```bash
[root@minikube message_log_dir]# cat messages_20210205_200001 | head
Feb  5 18:40:23 minikube kernel: Initializing cgroup subsys cpuset
Feb  5 18:40:23 minikube kernel: Initializing cgroup subsys cpu
Feb  5 18:40:23 minikube kernel: Initializing cgroup subsys cpuacct
Feb  5 18:40:23 minikube kernel: Linux version 3.10.0-957.el7.x86_64 (mockbuild@kbuilder.bsys.centos.org) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-36) (GCC) ) #1 SMP Thu Nov 8 23:39:32 UTC 2018
Feb  5 18:40:23 minikube kernel: Command line: BOOT_IMAGE=/vmlinuz-3.10.0-957.el7.x86_64 root=/dev/mapper/centos-root ro crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet LANG=ja_JP.UTF-8
Feb  5 18:40:23 minikube kernel: e820: BIOS-provided physical RAM map:
Feb  5 18:40:23 minikube kernel: BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
Feb  5 18:40:23 minikube kernel: BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
Feb  5 18:40:23 minikube kernel: BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
Feb  5 18:40:23 minikube kernel: BIOS-e820: [mem 0x0000000000100000-0x00000000f7feffff] usable
```

<br>

# さいごに

今回bashスクリプトに初挑戦してみました。
※業務ではPowerShellスクリプトの経験があります。

実際にbashスクリプトを書いてみて、PowerShellスクリプトと違うところがあると感じました。

しかし、慣れれば書けるという印象です。

これからもスクリプト系等、技術系の記事を投稿していきたいと思います！