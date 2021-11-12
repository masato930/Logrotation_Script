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