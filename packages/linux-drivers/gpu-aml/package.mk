################################################################################
#      This file is part of LibreELEC - https://libreelec.tv
#      Copyright (C) 2016-present Team LibreELEC
#
#  LibreELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  LibreELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with LibreELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="gpu-aml"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="http://openlinux.amlogic.com:8000/download/ARM/gpu/"
if [ "$MESON_FAMILY" = "gxm" ] ; then
  PKG_VERSION="fe7a4d8"
  PKG_SHA256="518f855a2b191e50d09c2d0b3e671b5ed4b5e4db06aa3a718e29ef30cc0d9a57"
  PKG_URL="https://github.com/khadas/android_hardware_arm_gpu/archive/$PKG_VERSION.tar.gz"
  PKG_SOURCE_DIR="android_hardware_arm_gpu-$PKG_VERSION*"
else
  PKG_VERSION="9b0fbbc"
  PKG_SHA256="7ca380052b285598f1c0100cec3411f69674dcfc0f78bc2dbe407aaf85b8ebd7"
  PKG_URL="https://github.com/openwetek/gpu-aml/archive/$PKG_VERSION.tar.gz"
  PKG_SOURCE_DIR="gpu-aml-$PKG_VERSION*"
fi
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_SECTION="driver"
PKG_SHORTDESC="gpu-aml: Linux drivers for Mali GPUs found in Amlogic Meson SoCs"
PKG_LONGDESC="gpu-aml: Linux drivers for Mali GPUs found in Amlogic Meson SoCs"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

pre_configure_target() {
  sed -e "s|USING_GPU_UTILIZATION=1|USING_GPU_UTILIZATION=0|g; s|shell date|shell date -R|g" -i $PKG_BUILD/mali/Kbuild
}

make_target() {
  if [ "$MESON_FAMILY" = "gxm" ] ; then
    LDFLAGS="" make -C $(kernel_path) M=$PKG_BUILD/t83x/kernel/drivers/gpu/arm/midgard \
    EXTRA_CFLAGS="-DCONFIG_MALI_PLATFORM_DEVICETREE -DCONFIG_MALI_BACKEND=gpu" \
      CONFIG_MALI_MIDGARD=m CONFIG_MALI_PLATFORM_DEVICETREE=y CONFIG_MALI_BACKEND=gpu modules
  else
    LDFLAGS="" make -C $(kernel_path) M=$PKG_BUILD/mali \
      CONFIG_MALI400=m CONFIG_MALI450=m
  fi
}

makeinstall_target() {
  if [ "$MESON_FAMILY" = "gxm" ] ; then
    LDFLAGS="" make -C $(kernel_path) M=$PKG_BUILD/t83x/kernel/drivers/gpu/arm/midgard \
      INSTALL_MOD_PATH=$INSTALL/$(get_kernel_overlay_dir) INSTALL_MOD_STRIP=1 DEPMOD=: \
    modules_install

    mkdir -p $INSTALL/usr/lib/modprobe.d
    echo mali > $INSTALL/usr/lib/modprobe.d/mali.conf
  else
    LDFLAGS="" make -C $(kernel_path) M=$PKG_BUILD/mali \
      INSTALL_MOD_PATH=$INSTALL/$(get_kernel_overlay_dir) INSTALL_MOD_STRIP=1 DEPMOD=: \
    modules_install
  fi
}
