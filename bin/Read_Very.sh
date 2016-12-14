#!/bin/bash
#set -x
#===============================================================================
#readコマンドテスト用スクリプト
#=======概要====================================================================
#readコマンドを使用して、apt-getしてくる感じのスクリプト
#インストールするプログラムはリストファイル化するのがいいかも
#インストールと削除と状態確認ができると嬉しい
#
#===============================================================================

#===============================================================================
# 変数・定数
#===============================================================================
#変数
user_input=""		#この変数にreadからの値を入力する。
ins_flg=""		#インストール実施フラグ
unins_flg=""		#アンインストール実施フラグ
app_list=()

#定数
list_PASS="/I_A_Works/list/apt_list.lst"
tmp_PASS="/I_A_Works/tmp/tmpfile.txt"
#===============================================================================
# メイン処理
#===============================================================================
echo "start_read_apt_get"
#まずは、インストールするのか、アンインストールするのか確認する。
while true
do
	echo 'まずは、実行する処理を記入してください。'
	echo 'インストールの場合は「install」、アンインストールの場合は「uninstall」と入力して下さい。'
	echo -n 'コマンド?（ドラクエ風）：'
	read user_input

	if test 'install' = ${user_input} ; then
		ins_flg='YES'
		unins_flg='NO'

		break
	elif test 'uninstall' = ${user_input} ; then
		unins_flg='YES'
		ins_flg='NO'

		break
	else
		echo '入力している値が違うみたいです。'
	fi
	
done

if test ${ins_flg} = 'YES' ; then
	for i in $(cat ${list_PASS} | grep -v '#' ) 
	do
		app_list+=(${i})
	done

	while true
	do
		cnt=0		#以下for文の番号表示用変数	
		echo "インストール出来るアプリは以下のものになります。"
		for i in ${app_list[@]}
		do
			echo "${cnt}:${i}"
			cnt=`expr ${cnt} + 1`
		done
		echo "インストールしたいプログラムの番号を入力してください。"
		echo "処理を終了したいときはquitと入力してね。"
		echo -n "コマンド？(しつこくドラクエ風)："
		read user_input
		expr ${user_input} + 1 >/dev/null 2>&1
		RET=$?
		if test ${RET} -lt 2 ; then
			if [ ${user_input} -lt ${#app_list[*]} ] ; then >>/dev/null 2>&1
				touch "${tmp_PASS}"
				apt-get -s install "${app_list[${user_input}]}" > ${tmp_PASS}
				tmp=$(cat ${tmp_PASS} | grep -c 'はすでに最新バージョン')
				if [ ${tmp} -lt 1 ] ; then 
					echo 'プログラムのインストールを開始するよ。'
					su -l root -c "apt-get -y install "${app_list[${user_input}]}"" >>/dev/null 2>&1
					if [ $? -eq 0 ] ; then echo 'インストールが成功したよ。'
					else echo '何か問題があったようだよ' ; fi
				else
					echo 'すでにインストールされているみたい。'
				fi
				rm -f ${tmp_PASS}
			else
				echo "その数値にはプログラムが存在しないよ" 
			fi
		elif [ ${user_input} = 'quit' ] ; then
			echo '処理を終了するよ'
			break
		else 
			echo '謎の値が入力されてるよ'

		fi		
	done		
fi	

if test ${unins_flg} = 'YES' ; then
	for i in $(cat ${list_PASS} | grep -v '#' )
		do 
			app_list+=(${i})
		done

	while true
	do
		cnt=0
		echo "アンインストール指定出来るものは以下のものになります。"
		for i in ${app_list[@]}
		do
			echo "${cnt}:${i}"
			cnt=`expr ${cnt} + 1`
		done
		echo "アンインストールしたいプログラムの番号を入力してください。"
		echo "処理を終了したいときはquitと入力してね。"
		echo -n "コマンド？(ドラクエ風か？)："
		read user_input
		expr ${user_input} + 1 >/dev/null 2>&1
		RET=$?
		if [ ${RET} -lt 2 ] ; then
			if [ ${user_input} -lt ${#app_list[*]} ] ; then
				touch "{tmp_PASS}"
				#apt-cache showpkg "${app_list[${user_input}]}" > ${tmp_PASS}
				#tmp=$(cat ${tmp_PASS})
				apt-get -s install "${app_list[${user_input}]}" > ${tmp_PASS}
				tmp=$(cat ${tmp_PASS} | grep -c 'はすでに最新バージョン')
				if [ "${tmp}" = "" ] ; then
					echo '選択した番号のプログラムは存在しないみたい'
				else 
					echo 'プログラムのアンインストールを開始するよ'
					su -l root -c "apt-get -y purge "${app_list[${user_input}]}"" >>/dev/null 2>&1
					if [ $? -eq 0 ] ;then echo 'アンインストールが成功したよ。'
					else echo '何か問題があったようだよ' ; fi
				fi
				rm -f ${tmp_PASS}
			else 
				echo 'その処理は存在しないよ'
			fi
		elif [ "${user_input}" = 'quit' ] ; then 
			echo '処理を終了するよ。'
			break
		else 
			echo '不明な値が入力されてるよ'
		fi
	done
fi

exit
