#!/bin/bash

UYellow='\033[4;33m'
Purple='\033[1;35m'
Green='\033[1;32m'
URed='\033[4;31m'
Red='\033[1;31m'
NC='\033[0m' # No Color

# Change this to the location of the repo
pluginLocation='/opt/wallpaper-engine-kde-plugin/'

function restart_plasma {
  systemctl --user restart plasma-plasmashell.service &>/dev/null
  returnValue=$?
  sleep 3

  return $returnValue
}

function del_plugin {
  if [ -f /usr/lib/qt6/qml/com/github/catsout/wallpaperEngineKde/qmldir ] &&
    [ -f /usr/lib/qt6/qml/com/github/catsout/wallpaperEngineKde/libWallpaperEngineKde.so ]; then
    sudo rm /usr/lib/qt6/qml/com/github/catsout/wallpaperEngineKde/{qmldir,libWallpaperEngineKde.so}
    kpackagetool6 -t Plasma/Wallpaper -r com.github.catsout.wallpaperEngineKde
    echo -e "${Green}[+] Deleted files: ${Purple}qmldir, libWallpaperEngineKde${NC}"
    return 0
  fi

  echo -e """
${Red}Files not found: 
/usr/lib/qt6/qml/com/github/catsout/wallpaperEngineKde/qmldir
/usr/lib/qt6/qml/com/github/catsout/wallpaperEngineKde/libWallpaperEngineKde.so
${NC}"""

  echo -e "${Green}[+] Creating files"

}

function restart_plugin {

  echo -e "${Green}[+] Restarting Plasma${NC}"
  restart_plasma
  if [ $? -eq 1 ]; then
    echo -e "${Red}[-] Plasmashell failed, retrying${NC}"
    restart_plasma

    if [ $? -eq 1 ]; then
      echo -e "\n${Red}[-] Failed again, wait a couple minutes and retry${NC}"
      exit 1
    fi
  fi

  echo -e "\n${UYellow}[!] Choose a wallpaper other than the wallpaperEngineKde plugin:${NC} ${URed}SET FOR ALL MONITORS${NC}"
  sleep 3
  kcmshell6 kcm_wallpaper &>/dev/null

}

function build {

  echo -e "${Green}[+] Rebuilding the plugin${NC}"

  sudo cmake --build $pluginLocation/build --target install_pkg >/dev/null
  sudo cmake --install $pluginLocation/build >/dev/null
  cmake --build $pluginLocation/build --target install_pkg
  restart_plasma

}

del_plugin
restart_plugin
build

restart_plasma
echo -e "\n${Green}Plugin Fixed :) ${NC}"
