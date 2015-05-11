# !/bin/sh

# this is autobuild xcode project shell by willonboy 2014/12/3
# QQ: 962286684 MAIL: 962286684@qq.com Github: http://github.com/willonboy


# Copyright 2014 willonboy
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.




# 工程Target名称
projTargetName=Line0new
# 返回当前时间时间截
timestamp=`date +%s`
dateStr=`date "+%Y_%m_%d_%H_%M_%S"`
# 工程路径 路径赋值不能在路径两端添加双引号
projPath=~/Desktop/Line0new
cd $projPath
ipaFileName=${projTargetName}_${dateStr}.ipa
# 要同步到七牛的目录路径
syncDir=/Users/line0_dev/Documents/Line0Ent
AK="七牛云存储的AK"
SK="七牛云存储SK"
# 同步到七牛上的bucket名字
bucket="line0"
#七牛同步命令行工具的绝对路径
qiniuCmdToolDir=/Users/line0_dev/Documents/qiniu-devtools-v2.7
#ipa文件生成后的存放地址
ipaFilePath=$syncDir/${ipaFileName}
# 清理工程
/usr/bin/xcodebuild -target ${projTargetName} clean

bundleIdentifier="com.line0.line0enter"
bundleDisplayName="零号线企业包"
# 编译工证书名称
CODE_SIGN_IDENTITY="iPhone Distribution: Nanjing Line0 Agel Ecommerce Ltd"
# provision对应的uuid
PROVISIONING_PROFILE="9cd5090f-a0f4-4e67-8013-acae188ad6ce"

# 工程*Info.plist文件存放位置
infoPlistFilePath=./Line0new/Line0new-Info.plist




# 修改Info.plist配置文件
/usr/libexec/PlistBuddy -c "set CFBundleIdentifier ${bundleIdentifier}" ${infoPlistFilePath}
/usr/libexec/PlistBuddy -c "set CFBundleVersion ${timestamp}" ${infoPlistFilePath}
# /usr/libexec/PlistBuddy -c "set CFBundleShortVersionString 1.3" ${infoPlistFilePath}
/usr/libexec/PlistBuddy -c "delete CFBundleDisplayName" ${infoPlistFilePath}
/usr/libexec/PlistBuddy -c "add CFBundleDisplayName string ${bundleDisplayName}" ${infoPlistFilePath}
# /usr/libexec/PlistBuddy -c "set CFBundleDisplayName ${bundleDisplayName}" ${infoPlistFilePath}

# 管理员密码解锁登录证书链
#PASSWORD="管理员密码"
#/usr/bin/security list-keychains -s ~/Library/Keychains/login.keychain    
#/usr/bin/security default-keychain -d user -s ~/Library/Keychains/login.keychain    
#/usr/bin/security unlock-keychain -p ${PASSWORD} ~/Library/Keychains/login.keychain


# 开始build 生成*.app
result=$(/usr/bin/xcodebuild -target ${projTargetName} CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" PROVISIONING_PROFILE="${PROVISIONING_PROFILE}")


# 判断是否执行过ipa-build脚本生成对应的app文件
ls ./build/Release-iphoneos/${projTargetName}.app &>/dev/null
rtnValue=$?
if [ $rtnValue != 0 ];then
    `echo "$result" | mail -s 自动build失败 xxx@line0.com`
    exit
fi

# 打包ipa
result=$(/usr/bin/xcrun -sdk iphoneos PackageApplication -v ./build/Release-iphoneos/${projTargetName}.app -o ${ipaFilePath})


# 判断是否生成ipa文件成功
ls ${ipaFilePath} &>/dev/null
rtnValue=$?
if [ $rtnValue != 0 ];then
    `echo "$result" | mail -s 自动编译生成ipa文件时失败 xxx@line0.com`
    exit
fi




enterprisePlistFileName="${projTargetName}_enterprise_${dateStr}.plist"

# 这个plist文件中需要修改配置你自己的值
# 生成plist文件
cat << EOF > ${syncDir}/${projTargetName}_enterprise_${dateStr}.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>items</key>
    <array>
        <dict>
            <key>assets</key>
            <array>
                <dict>
                    <key>kind</key>
                    <string>software-package</string>
                    <key>url</key>
                    <string>http://xxx.qiniudn.com/${ipaFileName}</string>
                </dict>
                <dict>
                    <key>kind</key>
                    <string>display-image</string>
                    <key>needs-shine</key>
                    <false/>
                    <key>url</key>
                    <string>http://xxx.qiniudn.com/icon.png</string>
                </dict>
            </array>
            <key>metadata</key>
            <dict>
                <key>subtitle</key>
                <string>${bundleDisplayName}</string>
                <key>title</key>
                <string>${bundleDisplayName}</string>
                <key>bundle-version</key>
                <string>1.0</string>
                <key>kind</key>
                <string>software</string>
                <key>bundle-identifier</key>
                <string>${bundleIdentifier}</string>
            </dict>
        </dict>
    </array>
</dict>
</plist>

EOF


# 注意https://dn-linezero.qbox.me是我们公司在七牛上的一个支持https的域名, 需要自行修改
# 生成install.htm
installFileName=${projTargetName}_install_${dateStr}.htm
cat << EOF > ${syncDir}/${installFileName}
<!DOCTYPE HTML>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>Line0 TEST VERSION</title>
        <script type="text/javascript">
        window.location.href="itms-services://?action=download-manifest&url=https://dn-linezero.qbox.me/${enterprisePlistFileName}";
        </script>
    </head>
    <body>
        <noscript>
        <ul>
            <li>
                <a href="itms-services://?action=download-manifest&url=https://dn-linezero.qbox.me/${enterprisePlistFileName}">install</a>
            </li>
        </ul>
        </noscript>
    </body>
</html>

EOF




################################################################

# 当前部分shell脚本是启动并同步七牛云存储

jsonFileName=sync_qiniu.json
# 同步文件的配置json文件路径
qiniuSyncJsonPath=${qiniuCmdToolDir}/${jsonFileName}

# 生成json文件
cat << EOF > $qiniuSyncJsonPath
{
    "src":"$syncDir",
    "dest":"qiniu:access_key=$AK&secret_key=$SK&bucket=$bucket",
    "deletable":0,
    "debug_level":1
}

EOF



# 同步次数记录变量, 最多连续尝试3次
syncTime=0
syncResult=false
# if A && B 的写法
while [[ $syncTime < 3 ]] && [[ $syncResult == false ]]; do
    # syncTime自增长用法
    syncTime=`expr $syncTime + 1`;
    # echo $syncTime
    # 将周步打印的log结果存放到result变量中 然后判断qiniu同步工具打印的log中是否包含 "Sync: all things updated!"或 "Sync done!", 如果包含刚上传成功
    syncLog=`${qiniuCmdToolDir}/qrsync $qiniuSyncJsonPath  2>&1`
    # echo $syncLog
    # shell 判断字符串是否存在包含关系
    echo "$syncLog" |grep -q "Sync: all things updated!"
    if [ $? -eq 0 ]; then
        syncResult=true
    else
        echo "$syncLog" |grep -q "Sync done!"
        if [ $? -eq 0 ]; then
            syncResult=true
        fi
    fi
done


# 最后同步的结果
if [[ $syncResult == true ]]; then
    qrcodeImgFilePath=${dateStr}.jpeg
    #line0.qiniudn.com 是我们公司用到的七牛分配的域名, 需要自行修改
    installHtmUrl=http://line0.qiniudn.com/${installFileName}
    echo "sync success! 时间截:${timestamp}  文件后缀:${dateStr} enterprisePlist FileName: ${enterprisePlistFileName}"
    # 生成二维码图片, 并存放到Desktop路径下
    syncLog=`${qiniuCmdToolDir}/qrcode ${installHtmUrl} ~/Desktop/${qrcodeImgFilePath}`

    `(echo ${ipaFileName} 编译成功 并且同步成功; uuencode ~/Desktop/${qrcodeImgFilePath} ${qrcodeImgFilePath}) | mail -s 自动编译成功 xxx@line0.com`
else
    echo "sync failed!"
    `echo "${ipaFileName} 编译成功 但是同步七牛失败" | mail -s 自动编译成功 xxx@line0.com`
fi


cd $projPath
`svn revert ${infoPlistFilePath}`


