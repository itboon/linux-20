grep
sed
awk


== 去掉空行和注释行 ==
<code>
awk '!/^[ \t]*(#|$)/{print $0}'
grep -Pv '^\s*($|#)'
</code>

  * 空行: ''^[ \t]*$''
  * 注释行: ''^[ \t]*#''
  * [ \t]* 表示0-n个空格或换行

== 统计文件夹代码行数(包括子文件夹) ==
''egrep -v "(^[ \t]*\/\/)|(^[ \t]*$)" -r --include "*.go" ./ | wc -l''

== 去重复行 ==
''awk '!a[$0]++' googleip.txt >> ip-google.txt''

''awk '!($0 in a){a[$0];print $0}''' 或者 ''awk '!a[$0]++''' ，这种写法省略了{print $0}

== 日志过滤 ==

<code bash>
# 日志信息示例
# Oct 10 08:05:16 sdeb systemd[1]: anacron.timer: Adding 2min 39.112982s random time.

# 输出10月10日8点的日志信息
awk -F ":" '$1 ~ /Oct 10 08/{print $0}' syslog
awk 'BEGIN{FIELDWIDTHS="15"} $1 ~ /^Oct 10 08:/{print $0}' syslog
# egrep 等于 grep -E 支持扩展正则表达式ERE
egrep "^Oct 10 08:" syslog

# 输出10月10日8点以前的日志信息
awk -F ":" '$1 ~ /Oct 10 0[0-7]/{print $0}' syslog

# 输出10月9日8点以前的日志信息
#  "Oct  9"中间2个空格
awk -F ":" '$1 ~ /Oct  9 0[0-7]/{print $0}' syslog

# 输出10月9日 7:40-7:49 时间段内的日志
awk -F ":" '$1 ~ /Oct  9 07/' syslog.1 | awk -F ":" '$2 ~ /4[0-9]/'

# apache access.log 13:00-17:59 时间段内的日志
egrep "^.+( - - )\[10/Oct/2018:1[3-7]" /var/log/apache2/dokuwiki_access.log
</code>

== 简单验证邮件地址是否合法 ==
  awk '/^.+@.+$/{print $0}'

  * https://en.wikipedia.org/wiki/Email_address#Local-part
  * [[https://stackoverflow.com/questions/201323/how-to-validate-an-email-address-using-a-regular-expression|stackoverflow]]

有效的邮箱地址：
  * x@example.com
  * disposable.style.email.with+symbol@example.com
  * "very.(),:;<>[]\".VERY.\"very@\\ \"very\".unusual"@strange.example.com
  * admin@mailserver1
  * #!$%&'*+-/=?^_`{}|~@example.org
  * "()<>[]:,;@\\\"!#$%&'-/=?^_`{}| ~.a"@example.org
  * example@s.example
  * user@[2001:DB8::1]
  * " "@example.org (space between the quotes)

==== sed文本替换 ====
<code>
sed 's/search/replace/' file
sed 's/search/replace/g' file
# 不加g仅对一行第一个目标进行替换,加g表示替换所有
</code>

== 批量替换文本 ==
将代码中所有import语句''"project/sub/''替换为''"project/''
<code>
sed -i 's/\"project\/sub/\"project\//g' `grep "\"project/sub/" -r -l`
</code>

文本行倒序
  sed -n '{1!G;h;$p}'
  * 第一行，放入保持空间
  * 第二行，保持空间附加到模式空间后，放入保持空间
  * 第三行，重复第二行
  * 最后一行，重复，然后打印

# 查看ipmi sdr 异常信息
  ipmitool -H 10.64.10.11 -UADMIN sdr | awk -F "|" '!/ok|ns/ {print $0}'

# ipmitool获取温度超过40度的数据
<code>
CPU1 Temp        | 38 degrees C      | ok
CPU2 Temp        | 40 degrees C      | ok
P1-DIMMA1 Temp   | 35 degrees C      | ok
P1-DIMMB1 Temp   | 35 degrees C      | ok
P1-DIMMC1 Temp   | no reading        | ns
P1-DIMMD1 Temp   | no reading        | ns
# 温度数据在20-21列，需要分割出这个数据
ipmitool -H 10.64.10.11 -UADMIN sdr | \
awk 'BEGIN{FIELDWIDTHS="18 4 9 10"} $3=="degrees C" && $2>40 {print $1,$2,$3,$4}'
</code>

对ping搜集的数据进行分析，将主机和丢包信息合并到一行，并按丢包率排序。
  grep -e statistics -e loss /tmp/ping.log | sed ":a;N;s/---\n//g;$!ba" \
  | sort -n -k 8 -o ping.log.sort
筛选出有丢包的日志，按主机名排序
  grep -e statistics -e loss /tmp/ping.log | sed ":a;N;s/---\n//g;$!ba" \
  | grep -v 0% | sort -n -k 1 -o ping.log.bad

==== 获取中国所有的ip地址 ====
  curl 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep ipv4 | grep CN | \
  awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > chnroute.txt
''32-log($5)/log(2)'' 计算掩码,2的n次方=$5,32-n的值就是掩码。

==== 获取网页所有域名 ====
  curl $1 |  grep -oP "(http|https)://[a-zA-Z0-9.]{1,26}+[\.a-zA-Z0-9]{0,26}"  | sort | uniq

==== 根据子网掩码计算广播地址，把网络地址和广播地址取出来 ====
172.16.0.0/12 > 172.16.0.0-172.31.255.255

<code bash ipformat.sh>
#!/bin/bash
while read line
do
  netmask=$(awk -F "/" '{print $2}' <<< $line)
  ipStart=$(awk -F "/" '{print $1}' <<< $line)
  if [[ "$netmask" -lt "8" ]]; then
    ipEnd=$(awk 'BEGIN{FS=OFS="."}{print $1+2^(8-'$netmask')-1,255,255,255}' <<< $line)
  elif [[ "$netmask" -lt "16" ]];then
    ipEnd=$(awk 'BEGIN{FS=OFS="."}{print $1,$2+2^(16-'$netmask')-1,255,255}' <<< $line)
  elif [[ "$netmask" -lt "24" ]];then
    ipEnd=$(awk 'BEGIN{FS=OFS="."}{print $1,$2,$3+2^(24-'$netmask')-1,255}' <<< $line)
  else
    ipEnd=$(awk 'BEGIN{FS="[./]";OFS="."}{print $1,$2,$3,$4+2^(32-'$netmask')-1}' <<< $line)
  fi
  echo $ipStart-$ipEnd >> b.txt
done < a.txt
</code>

==== 配置文件转换 unbound ====

从github获取dnsmasq中国域名配置文件，转换为unbound配置文件。
<code bash>
exec 1>>fz.china.conf

curl -s https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf \
    | awk -F "/" '{print $2}' | while read line
do
    echo "forward-zone:"
    echo "    name: \"${line}.\""
    echo "    forward-addr: 223.5.5.5"
    echo "    forward-addr: 223.6.6.6"
    echo
done
</code>