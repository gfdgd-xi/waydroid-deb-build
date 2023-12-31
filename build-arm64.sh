#!/bin/bash
# 配置环境
echo 配置环境
dpkg --add-architecture arm64
sudo apt update | true
sudo apt install tree aria2 curl git python3 python3-requests -y
git clone https://github.com/gfdgd-xi/waydroid-deb-build
cd waydroid-deb-build
python3 get-newest-version.py arm64 GAPPS
cp ../waydroid-deb-build /tmp -rv
VERSION=`cat /tmp/version.txt`-`date +"%Y%m%d%H%M%S"`
curl https://repo.waydro.id | sudo bash | true
sudo bash -c "echo deb [signed-by=/usr/share/keyrings/waydroid.gpg] https://repo.waydro.id/ jammy main > /etc/apt/sources.list.d/waydroid.list"
sudo apt update | true
echo 下载所需安装包
cd /tmp
#curl https://repo.waydro.id | sudo bash
#sudo apt install waydroid -y
#sudo waydroid init -s GAPPS -f

urlSystem=`cat /tmp/url.txt`
urlVendor=`cat /tmp/vendorurl.txt`
aria2c -x 16 -s 16 $urlSystem
aria2c -x 16 -s 16 $urlVendor
uSystem=`dirname $urlSystem`
uVendor=`dirname $urlVendor`
unzip `basename $uSystem`
unzip `basename $uVendor`

#sudo cp /tmp/houdini-install/overlay/system/etc /tmp/mount/system -rv | true
#sudo cp /tmp/houdini-install/overlay/system/* /tmp/mount/ -rv | true
#sudo cp /tmp/houdini-install/overlay/system/lib64 /tmp/mount/ -rv | true
#sudo cp vendor_google_proprietary_widevine-prebuilt-*/prebuilts/* /tmp/mount/system -rv | true
#sudo cp vendor_google_proprietary_widevine-prebuilt-*/prebuilts/* /tmp/mount/ -rv | true

#sudo umount /tmp/mount | true
#sudo qemu-nbd -d /dev/nbd0 | true
mkdir -p deb/DEBIAN
mkdir -p deb/usr/share/waydroid-extra/images
mkdir -p deb/var/lib/waydroid/
# 扩容 img
#cp vendor_google_proprietary_widevine-prebuilt-*/prebuilts/* deb/var/lib/waydroid/overlay/system -rv | true
cp system.img deb/usr/share/waydroid-extra/images
cp vendor.img deb/usr/share/waydroid-extra/images

cat > deb/DEBIAN/control <<EOF
Package: waydroid-android-image-gapps
Version: $VERSION
Maintainer: gfdgd xi <3025613752@qq.com>
Homepage: https://github.com/gfdgd-xi/waydroid-runner
Architecture: arm64
Severity: serious
Certainty: possible
Check: binaries
Type: binary, udeb
Priority: optional
Depends: 
Section: utils
Installed-Size: 0
Description: Waydroid Android 镜像
EOF
cat > deb/DEBIAN/postinst <<EOF
#!/bin/bash
systemctl restart waydroid-container.service | true
EOF
cat > deb/DEBIAN/postrm <<EOF
#!/bin/bash
systemctl restart waydroid-container.service | true
EOF
chmod 0775 -Rv deb/DEBIAN
cat > /tmp/deb/var/lib/waydroid/waydroid.cfg <<EOF
[waydroid]
arch = arm64
vendor_type = MAINLINE
system_datetime = 0
vendor_datetime = 0
suspend_action = freeze
mount_overlays = True
images_path = /usr/share/waydroid-extra/images
system_ota = https://ota.waydro.id/system/lineage/waydroid_arm64/VANILLA.json
vendor_ota = https://ota.waydro.id/vendor/waydroid_arm64/MAINLINE.json
binder = anbox-binder
vndbinder = anbox-vndbinder
hwbinder = anbox-hwbinder
binder_protocol = aidl3
service_manager_protocol = aidl3

[properties]
persist.sys.timezone=Asia/Shanghai
persist.sys.language=zh
persist.sys.country=CN
EOF
dpkg-deb -Z xz -z 4 -b deb waydroid-android-image-gapps.deb
#curl -F 'file=@waydroid-android-image-gapps.deb' $URL
#mv waydroid-android-image-gapps.deb /tmp
apt download waydroid python3-gbinder:arm64 libgbinder:arm64 libglibutil:arm64
#curl -F 'file=@libgbinder.deb' $URL
#curl -F 'file=@libglibutil.deb' $URL
#curl -F 'file=@python3-gbinder.deb' $URL
dpkg -x waydroid_*.deb waydroid
dpkg -e waydroid_*.deb waydroid/DEBIAN
mkdir -p /tmp/waydroid/var/lib/waydroid/
tree waydroid

#bash -c "echo -e '\npersist.sys.timezone=Asia/Shanghai\npersist.sys.language=zh\npersist.sys.country=CN' >> /tmp/waydroid/var/lib/waydroid/waydroid.cfg"
#bash -c "echo -e '\nro.product.cpu.abilist=x86_64,x86,arm64-v8a,armeabi-v7a,armeabi\nro.product.cpu.abilist32=x86,armeabi-v7a,armeabi\nro.product.cpu.abilist64=x86_64,arm64-v8a\nro.dalvik.vm.native.bridge=libhoudini.so\nro.enable.native.bridge.exec=1\nro.dalvik.vm.isa.arm=x86\nro.dalvik.vm.isa.arm64=x86_64\nro.vendor.product.cpu.abilist=x86_64,x86,arm64-v8a,armeabi-v7a,armeabi\nro.vendor.product.cpu.abilist32=x86,armeabi-v7a,armeabi\nro.vendor.product.cpu.abilist64=x86_64,arm64-v8a'  >> /tmp/waydroid/var/lib/waydroid/waydroid.cfg"
rm waydroid/DEBIAN/md5sums -rfv
python3 waydroid-deb-build/change-deb-debian.py waydroid/DEBIAN/control
dpkg-deb -Z xz -z 4 -b waydroid waydroid.deb
#cp waydroid.deb /tmp -v
#curl -F 'file=@waydroid.deb' $URL
mv python3-gbinder*.deb python3-gbinder.deb
mv libgbinder*.deb libgbinder.deb
mv libglibutil*.deb libglibutil.deb
#git clone https://gitlink.org.cn/rain-gfd/waydroid-image.git
mkdir waydroid-image
cd waydroid-image
git init .
cp ../system.img . -v
cp ../vendor.img . -v
git add .

git config --global user.name 'rain-gfd'
git config --global user.email q3025613752@qq.com
git commit -m $VERSION
git remote add origin "https://rain-gfd:$PASSWORD@gitlink.org.cn/rain-gfd/waydroid-image.git" | true
git push origin +master | true