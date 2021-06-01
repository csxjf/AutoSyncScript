#!/usr/bin/env bash
cat /etc/hosts | grep "raw.githubusercontent.com" -q
if [ $? -ne 0 ]; then
  echo "199.232.28.133 raw.githubusercontent.com" >>/etc/hosts
  echo "199.232.68.133 raw.githubusercontent.com" >>/etc/hosts
  echo "185.199.108.133 raw.githubusercontent.com" >>/etc/hosts
  echo "185.199.109.133 raw.githubusercontent.com" >>/etc/hosts
  echo "185.199.110.133 raw.githubusercontent.com" >>/etc/hosts
  echo "185.199.111.133 raw.githubusercontent.com" >>/etc/hosts
fi

##############################  作  者  昵  称  （必填）  ##############################
# 使用空格隔开
author_list="monk_ichenzhe monk_normal LongZhuZhu jddj monk_car DiDi_fruit monk_member ppdz"

##############################  作  者  脚  本  地  址  URL  （必填）  ##############################
# 例如：https://raw.sevencdn.com/whyour/hundun/master/quanx/jx_nc.js
# 1.从作者库中随意挑选一个脚本地址，每个作者的地址添加一个即可，无须重复添加
# 2.将地址最后的 “脚本名称+后缀” 剪切到下一个变量里（my_scripts_list_xxx）

scripts_base_url_1=https://ghproxy.com/https://raw.githubusercontent.com/csxjf/AutoSyncScript/monk/i-chenzhe/
scripts_base_url_2=https://ghproxy.com/https://raw.githubusercontent.com/csxjf/AutoSyncScript/monk/normal/
scripts_base_url_3=https://ghproxy.com/https://raw.githubusercontent.com/csxjf/AutoSyncScript/longzhuzhu/qx/
scripts_base_url_4=https://ghproxy.com/https://raw.githubusercontent.com/csxjf/AutoSyncScript/passerby-b/
scripts_base_url_5=https://ghproxy.com/https://raw.githubusercontent.com/csxjf/AutoSyncScript/monk/car/
scripts_base_url_6=https://ghproxy.com/https://raw.githubusercontent.com/passerby-b/didi_fruit/main/
scripts_base_url_7=https://ghproxy.com/https://raw.githubusercontent.com/csxjf/AutoSyncScript/monk/member/
scripts_base_url_8=https://ghproxy.com/https://raw.githubusercontent.com/panghu999/panghu/master/

## 添加更多脚本地址URL示例：scripts_base_url_3=https://raw.sevencdn.com/whyour/hundun/master/quanx/

##############################  作  者  脚  本  名  称  （必填）  ##############################
# 将相应作者的脚本填写到以下变量中
my_scripts_list_1="z_fanslove.js z_health_community.js z_health_energy.js z_marketLottery.js z_shae.js z_carnivalcity.js z_shop_captain.js z_xmf.js z_mother_jump.js z_wish.js z_city_cash.js"
my_scripts_list_2="monk_inter_shop_sign.js monk_shop_follow_sku.js adolf_oppo.js adolf_newInteraction.js adolf_star.js adolf_pk.js adolf_martin.js adolf_urge.js adolf_jxhb.js adolf_superbox.js"
my_scripts_list_3="jd_super_redrain.js jd_half_redrain.js"
my_scripts_list_4="jddj_bean.js jddj_cookie.js jddj_fruit.js jddj_fruit_collectWater.js jddj_getPoints.js jddj_plantBeans.js"
my_scripts_list_5="monk_shop_add_to_car.js"
my_scripts_list_6="dd_fruit.js"
my_scripts_list_7="adolf_oneplus.js adolf_flp.js monk_pasture.js"
my_scripts_list_8="jd_ppdz.js"

##############################  随  机  函  数  ##############################
rand() {
  min=$1
  max=$(($2 - $min + 1))
  num=$(cat /proc/sys/kernel/random/uuid | cksum | awk -F ' ' '{print $1}')
  echo $(($num % $max + $min))
}
cd ${ShellDir}
index=1
for author in $author_list; do
  ##  echo -e "开始下载 $author 的活动脚本："
  echo -e "开始下载 $author 的活动脚本"
  echo -e ''
  # 下载my_scripts_list中的每个js文件，重命名增加前缀"作者昵称_"，增加后缀".new"
  eval scripts_list=\$my_scripts_list_${index}
  #echo $scripts_list
  eval url_list=\$scripts_base_url_${index}
  #echo $url_list
  for js in $scripts_list; do
    eval url=$url_list$js
    echo $url
    eval name=$js
    echo $name
    wget -q --no-check-certificate $url -O scripts/$name.new

    # 如果上一步下载没问题，才去掉后缀".new"，如果上一步下载有问题，就保留之前正常下载的版本
    # 随机添加个cron到crontab.list
    if [ $? -eq 0 ]; then
      mv -f scripts/$name.new scripts/$name
      echo -e "更新 $name 完成...\n"
      croname=$(echo "$name" | awk -F\. '{print $1}')
      script_date=$(cat scripts/$name | grep "http" | awk '{if($1~/^[0-59]/) print $1,$2,$3,$4,$5}' | sort | uniq | head -n 1)
      if [ -z "${script_date}" ]; then
        cron_min=$(rand 1 59)
        cron_hour=$(rand 7 9)
        [ $(grep -c "$croname" ${ListCron}) -eq 0 ] && sed -i "/hangup/a${cron_min} ${cron_hour} * * * bash jd $croname" ${ListCron}
      else
        [ $(grep -c "$croname" ${ListCron}) -eq 0 ] && sed -i "/hangup/a${script_date} bash jd $croname" ${ListCron}
      fi
    else
      [ -f scripts/$name.new ] && rm -f scripts/$name.new
      echo -e "更新 $name 失败，使用上一次正常的版本...\n"
    fi
  done
  index=$(($index + 1))
done

## 京东试用脚本添加取关定时任务
grep -q "（jd_try.js）" ${ListCron} && sed -i "/（jd_try.js）/d" ${ListCron} &&  sed -ie "/5 10 \* \* \* bash jd jd_unsubscribe/d" ${ListCron} ## 修复试用脚本重复通知定时任务的错误

[ -f ${ScriptsDir}/jd_try.js ] && grep -q "5 10 \* \* \* bash jd jd_unsubscribe" ${ListCron}
if [ $? -ne 0 ]; then
  echo -e '\n# 京东试用脚本添加的取关定时任务\n5 10 * * * bash jd jd_unsubscribe' >>${ListCron}
fi

##############################  删  除  失  效  的  活  动  脚  本  ##############################
## 删除旧版本失效的活动示例： rm -rf ${ScriptsDir}/jd_test.js
rm -rf ${ScriptsDir}/jd_live_lottery_social.js
rm -rf ${ScriptsDir}/jd_skyworth.js
