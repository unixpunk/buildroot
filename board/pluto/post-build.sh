#!/bin/sh
# args from BR2_ROOTFS_POST_SCRIPT_ARGS
# $2    board name
set -e

INSTALL=install

####################
# Create and insert the update.tgz.md5sum
#/home/steve/Desktop/SDR/Pluto/plutosdr-fw/buildroot/board/pluto/buildzip.sh
/home/steve/Desktop/SDR/Pluto/plutosdr-fw/buildroot/board/pluto/buildgz.sh
cp /home/steve/Desktop/SDR/Pluto/PlutoWeb/plutoweb/update.tgz.md5sum ${TARGET_DIR}/root/.update.tgz.md5sum

# Add a console on tty1
grep -qE '^ttyGS0::' ${TARGET_DIR}/etc/inittab || \
sed -i '/GENERIC_SERIAL/a\
ttyGS0::respawn:/sbin/getty -L ttyGS0 0 vt100 # USB console' ${TARGET_DIR}/etc/inittab

grep -qE '^::sysinit:/bin/mount -t debugfs' ${TARGET_DIR}/etc/inittab || \
sed -i '/hostname/a\
::sysinit:/bin/mount -t debugfs none /sys/kernel/debug/' ${TARGET_DIR}/etc/inittab

sed -i -e '/::sysinit:\/bin\/hostname -F \/etc\/hostname/d' ${TARGET_DIR}/etc/inittab

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"
GENIMAGE_CFG="${BOARD_DIR}/genimage-msd.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

rm -rf "${GENIMAGE_TMP}"

genimage                           \
	--rootpath "${TARGET_DIR}"     \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BOARD_DIR}/msd"  \
	--outputpath "${TARGET_DIR}/opt/" \
	--config "${GENIMAGE_CFG}"

rm -f ${TARGET_DIR}/opt/boot.vfat
rm -f ${TARGET_DIR}/etc/init.d/S99iiod

#mkdir -p ${TARGET_DIR}/www/img
mkdir -p ${TARGET_DIR}/etc/wpa_supplicant/

${INSTALL} -D -m 0755 ${BOARD_DIR}/update.sh ${TARGET_DIR}/sbin/
${INSTALL} -D -m 0755 ${BOARD_DIR}/udc_handle_suspend.sh ${TARGET_DIR}/sbin/
${INSTALL} -D -m 0755 ${BOARD_DIR}/S10mdev ${TARGET_DIR}/etc/init.d/
${INSTALL} -D -m 0755 ${BOARD_DIR}/S15watchdog ${TARGET_DIR}/etc/init.d/
${INSTALL} -D -m 0755 ${BOARD_DIR}/S20urandom ${TARGET_DIR}/etc/init.d/
${INSTALL} -D -m 0755 ${BOARD_DIR}/S21misc ${TARGET_DIR}/etc/init.d/
${INSTALL} -D -m 0755 ${BOARD_DIR}/S23udc ${TARGET_DIR}/etc/init.d/
${INSTALL} -D -m 0755 ${BOARD_DIR}/S40network ${TARGET_DIR}/etc/init.d/
${INSTALL} -D -m 0755 ${BOARD_DIR}/S41network ${TARGET_DIR}/etc/init.d/
${INSTALL} -D -m 0755 ${BOARD_DIR}/S45msd ${TARGET_DIR}/etc/init.d/
${INSTALL} -D -m 0644 ${BOARD_DIR}/fw_env.config ${TARGET_DIR}/etc/
${INSTALL} -D -m 0644 ${BOARD_DIR}/VERSIONS ${TARGET_DIR}/opt/
${INSTALL} -D -m 0755 ${BOARD_DIR}/device_reboot ${TARGET_DIR}/usr/sbin/
${INSTALL} -D -m 0644 ${BOARD_DIR}/motd ${TARGET_DIR}/etc/
${INSTALL} -D -m 0755 ${BOARD_DIR}/test_ensm_pinctrl.sh ${TARGET_DIR}/usr/sbin/
${INSTALL} -D -m 0644 ${BOARD_DIR}/device_config ${TARGET_DIR}/etc/
${INSTALL} -D -m 0644 ${BOARD_DIR}/mdev.conf ${TARGET_DIR}/etc/
${INSTALL} -D -m 0755 ${BOARD_DIR}/automounter.sh ${TARGET_DIR}/lib/mdev/automounter.sh
${INSTALL} -D -m 0755 ${BOARD_DIR}/ifupdown.sh ${TARGET_DIR}/lib/mdev/ifupdown.sh
${INSTALL} -D -m 0644 ${BOARD_DIR}/input-event-daemon.conf ${TARGET_DIR}/etc/

#${INSTALL} -D -m 0644 ${BOARD_DIR}/msd/img/* ${TARGET_DIR}/www/img/
#${INSTALL} -D -m 0644 ${BOARD_DIR}/msd/index.html ${TARGET_DIR}/www/

${INSTALL} -D -m 0755 ${BOARD_DIR}/wpa_supplicant/* ${TARGET_DIR}/etc/wpa_supplicant/

ln -sf ../../wpa_supplicant/ifupdown.sh ${TARGET_DIR}/etc/network/if-up.d/wpasupplicant
ln -sf ../../wpa_supplicant/ifupdown.sh ${TARGET_DIR}/etc/network/if-down.d/wpasupplicant
ln -sf ../../wpa_supplicant/ifupdown.sh ${TARGET_DIR}/etc/network/if-pre-up.d/wpasupplicant
ln -sf ../../wpa_supplicant/ifupdown.sh ${TARGET_DIR}/etc/network/if-post-down.d/wpasupplicant

ln -sf device_reboot ${TARGET_DIR}/usr/sbin/pluto_reboot
