#!/bin/bash

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$REPO_DIR/src"
export LD_LIBRARY_PATH="$REPO_DIR/libsass"
SASSC_BIN="$REPO_DIR/libsass/sassc"

ROOT_UID=0
DEST_DIR=

# For tweaks
opacity=
panel=
window=
blur=
outline=
titlebutton=
icon='-default'

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/themes"
else
  DEST_DIR="$HOME/.themes"
fi

SASSC_OPT="-M -t expanded"

THEME_NAME=Fluent
THEME_VARIANTS=('' '-purple' '-pink' '-red' '-orange' '-yellow' '-green' '-teal' '-grey')
COLOR_VARIANTS=('' '-Light' '-Dark')
SIZE_VARIANTS=('' '-compact')

if [[ "$(command -v gnome-shell)" ]]; then
  gnome-shell --version
  SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -1)"
  if [[ "${SHELL_VERSION:-}" -ge "44" ]]; then
    GS_VERSION="44-0"
  elif [[ "${SHELL_VERSION:-}" -ge "42" ]]; then
    GS_VERSION="42-0"
  elif [[ "${SHELL_VERSION:-}" -ge "40" ]]; then
    GS_VERSION="40-0"
  else
    GS_VERSION="3-28"
  fi

  if [[ "${SHELL_VERSION:-}" -ge "45" ]]; then
    activities="default"
  fi
else
  echo "'gnome-shell' not found, using styles for last gnome-shell version available."
  GS_VERSION="44-0"
fi

install() {
  local dest="$1"
  local name="$2"
  local theme="$3"
  local color="$4"
  local size="$5"
  local icon="$6"

  [[ "$color" == '-Dark' ]] && local ELSE_DARK="$color"
  [[ "$color" == '-Light' ]] && local ELSE_LIGHT="$color"
  [[ "$color" == '-Dark' ]] || [[ "$color" == '' ]] && local ACTIVITIES_ASSETS_SUFFIX="-Dark"

  if [[ "$window" == 'round' ]]; then
    round='-round'
  else
    round=$window
  fi

  local THEME_DIR="$dest/$name"

  theme_tweaks && install_theme_color

  echo "Installing '$THEME_DIR'..."

  mkdir -p                                                                      "$THEME_DIR"
  cp -r "$REPO_DIR/COPYING"                                                     "$THEME_DIR"

  echo "[Desktop Entry]" >>                                                     "$THEME_DIR/index.theme"
  echo "Type=X-GNOME-Metatheme" >>                                              "$THEME_DIR/index.theme"
  echo "Name=$name" >>                                   "$THEME_DIR/index.theme"
  echo "Comment=An Materia Gtk+ theme based on Elegant Design" >>               "$THEME_DIR/index.theme"
  echo "Encoding=UTF-8" >>                                                      "$THEME_DIR/index.theme"
  echo "" >>                                                                    "$THEME_DIR/index.theme"
  echo "[X-GNOME-Metatheme]" >>                                                 "$THEME_DIR/index.theme"
  echo "GtkTheme=$name" >>                               "$THEME_DIR/index.theme"
  echo "MetacityTheme=$name" >>                          "$THEME_DIR/index.theme"
  echo "IconTheme=$name${ELSE_DARK:-}" >>                                       "$THEME_DIR/index.theme"
  echo "CursorTheme=$name${ELSE_DARK:-}" >>                                     "$THEME_DIR/index.theme"
  echo "ButtonLayout=close,minimize,maximize:menu" >>                           "$THEME_DIR/index.theme"

  mkdir -p                                                                      "$THEME_DIR/gnome-shell"
  cp -r "$SRC_DIR/gnome-shell/pad-osd.css"                                      "$THEME_DIR/gnome-shell"

  $SASSC_BIN $SASSC_OPT "$SRC_DIR/gnome-shell/shell-$GS_VERSION/gnome-shell$color$size.scss" "$THEME_DIR/gnome-shell/gnome-shell.css"
  
  cp -r "${SRC_DIR}/gnome-shell/common-assets"                                  "$THEME_DIR/gnome-shell/assets"
  cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/"*.svg                     "$THEME_DIR/gnome-shell/assets"
  cp -r "${SRC_DIR}/gnome-shell/theme$theme/"*.svg                              "$THEME_DIR/gnome-shell/assets"
  cp -r "${SRC_DIR}/gnome-shell/assets${ACTIVITIES_ASSETS_SUFFIX:-}/activities/activities${icon}.svg" "$THEME_DIR/gnome-shell/assets/activities.svg"

  if [[ "$window" = "round" ]] ; then
    cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/buttons-round/"*.svg     "$THEME_DIR/gnome-shell/assets"
  else
    cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/buttons/"*.svg           "$THEME_DIR/gnome-shell/assets"
  fi

  if [[ "$color" = "-Light" ]] ; then
    cp -r "${SRC_DIR}/gnome-shell/assets-Dark/activities/activities${icon}.svg" "$THEME_DIR/gnome-shell/assets/activities-white.svg"
  fi

  if [[ "$opacity" = "solid" ]] ; then
    if [[ "$window" = "round" ]] ; then
      if [[ "$outline" = "" ]] ; then
        cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/solid-round/"*.svg    "$THEME_DIR/gnome-shell/assets"
      else
        cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/solid-round-borderless/"*.svg "$THEME_DIR/gnome-shell/assets"
      fi
    else
      if [[ "$outline" = "" ]] ; then
        cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/solid/"*.svg           "$THEME_DIR/gnome-shell/assets"
      else
        cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/solid-borderless/"*.svg "$THEME_DIR/gnome-shell/assets"
      fi
    fi
  else
    if [[ "$window" = "round" ]] ; then
      if [[ "$outline" = "" ]] ; then
        cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/default-round/"*.svg   "$THEME_DIR/gnome-shell/assets"
      else
        cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/default-round-borderless/"*.svg "$THEME_DIR/gnome-shell/assets"
      fi
    else
      if [[ "$outline" = "" ]] ; then
        cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/default/"*.svg         "$THEME_DIR/gnome-shell/assets"
      else
        cp -r "${SRC_DIR}/gnome-shell/assets${ELSE_DARK:-}/default-borderless/"*.svg "$THEME_DIR/gnome-shell/assets"
      fi
    fi
  fi

  cd "$THEME_DIR/gnome-shell"
  ln -sf assets/no-events.svg no-events.svg
  ln -sf assets/process-working.svg process-working.svg
  ln -sf assets/no-notifications.svg no-notifications.svg

  mkdir -p                                                                      "$THEME_DIR/gtk-2.0"
  cp -r "$SRC_DIR/gtk-2.0/common/"{apps.rc,hacks.rc,main.rc}                    "$THEME_DIR/gtk-2.0"
  cp -r "$SRC_DIR/gtk-2.0/assets-folder/assets$theme${ELSE_DARK:-}"             "$THEME_DIR/gtk-2.0/assets"
  cp -r "$SRC_DIR/gtk-2.0/gtkrc$theme${ELSE_DARK:-}"                            "$THEME_DIR/gtk-2.0/gtkrc"

  mkdir -p                                                                      "$THEME_DIR/gtk-3.0"
  cp -r "$SRC_DIR/gtk/assets$theme"                                             "$THEME_DIR/gtk-3.0/assets"
  cp -r "$SRC_DIR/gtk/scalable"                                                 "$THEME_DIR/gtk-3.0/assets"
  cp -r "$SRC_DIR/gtk/thumbnail$theme${ELSE_DARK:-}.png"                        "$THEME_DIR/gtk-3.0/thumbnail.png"

  $SASSC_BIN $SASSC_OPT "$SRC_DIR/gtk/3.0/gtk$color$size.scss"                   "$THEME_DIR/gtk-3.0/gtk.css"
  $SASSC_BIN $SASSC_OPT "$SRC_DIR/gtk/3.0/gtk-Dark$size.scss"                    "$THEME_DIR/gtk-3.0/gtk-dark.css"
  
  mkdir -p                                                                      "$THEME_DIR/gtk-4.0"
  cp -r "$SRC_DIR/gtk/assets$theme"                                             "$THEME_DIR/gtk-4.0/assets"
  cp -r "$SRC_DIR/gtk/scalable"                                                 "$THEME_DIR/gtk-4.0/assets"

  $SASSC_BIN $SASSC_OPT "$SRC_DIR/gtk/4.0/gtk$color$size.scss"                  "$THEME_DIR/gtk-4.0/gtk.css"
  $SASSC_BIN $SASSC_OPT "$SRC_DIR/gtk/4.0/gtk-Dark$size.scss"                   "$THEME_DIR/gtk-4.0/gtk-dark.css"
  
  mkdir -p                                                                      "$THEME_DIR/cinnamon"
  cp -r "$SRC_DIR/cinnamon/common-assets"                                       "$THEME_DIR/cinnamon/assets"
  cp -r "$SRC_DIR/cinnamon/assets${ELSE_DARK:-}/"*.svg                          "$THEME_DIR/cinnamon/assets"

  $SASSC_BIN $SASSC_OPT "$SRC_DIR/cinnamon/cinnamon$color$size.scss"            "$THEME_DIR/cinnamon/cinnamon.css"
  
  cp -r "$SRC_DIR/cinnamon/thumbnail$theme$color.png"                           "$THEME_DIR/cinnamon/thumbnail.png"

  if [[ "$size" == '' ]]; then
    mkdir -p                                                                    "$THEME_DIR/xfwm4"

    if [[ "$titlebutton" = "square" ]] ; then
      cp -r "$SRC_DIR/xfwm4/assets-square$color/"*.png                          "$THEME_DIR/xfwm4"
      cp -r "$SRC_DIR/xfwm4/themerc-square${ELSE_LIGHT:-}"                      "$THEME_DIR/xfwm4/themerc"
    else
      cp -r "$SRC_DIR/xfwm4/assets$color/"*.png                                 "$THEME_DIR/xfwm4"
      cp -r "$SRC_DIR/xfwm4/themerc${ELSE_LIGHT:-}"                             "$THEME_DIR/xfwm4/themerc"
    fi

    mkdir -p                                                                    "$THEME_DIR/metacity-1"
    cp -r "$SRC_DIR/metacity-1/metacity-theme-2$color.xml"                      "$THEME_DIR/metacity-1/metacity-theme-2.xml"

    if [[ "$window" = "round" ]] ; then
      cp -r "$SRC_DIR/metacity-1/metacity-theme-3-round.xml"                    "$THEME_DIR/metacity-1/metacity-theme-3.xml"
      cp -r "$SRC_DIR/metacity-1/assets-round"                                  "$THEME_DIR/metacity-1/assets"
    else
      cp -r "$SRC_DIR/metacity-1/metacity-theme-3.xml"                          "$THEME_DIR/metacity-1"
      cp -r "$SRC_DIR/metacity-1/assets"                                        "$THEME_DIR/metacity-1"
    fi

    cp -r "$SRC_DIR/metacity-1/thumbnail${ELSE_DARK:-}.png"                     "$THEME_DIR/metacity-1/thumbnail.png"
    cd "$THEME_DIR/metacity-1" && ln -sf metacity-theme-2.xml metacity-theme-1.xml
  fi

  mkdir -p                                                                      "$THEME_DIR/plank"
  cp -r "$SRC_DIR/plank/theme${ELSE_LIGHT:-}/dock.theme"                        "$THEME_DIR/plank"
}

themes=()
colors=()
sizes=()
lcolors=()

while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    --dest)
      dest="$2"
      mkdir -p "$dest"
      shift 2
      ;;
    --name)
      _name="$2"
      shift 2
      ;;
    --solid)
      opacity="solid"
      shift
      ;;
    --float)
      panel="float"
      echo -e "Install floating panel version ..."
      shift
      ;;
    --round)
      window="round"
      echo -e "Install rounded windows version ..."
      shift
      ;;
    --blur)
      blur="true"
      panel="compact"
      echo -e "Install blur version ..."
      shift
      ;;
    --noborder)
      outline="false"
      echo -e "Install windows without outline version ..."
      shift
      ;;
    --square)
      titlebutton="square"
      echo -e "Install square windows button version ..."
      shift
      ;;
    --theme)
      accent='true'
      shift
      for variant in "$@"; do
        case "$variant" in
          default)
            themes+=("${THEME_VARIANTS[0]}")
            shift
            ;;
          purple)
            themes+=("${THEME_VARIANTS[1]}")
            shift
            ;;
          pink)
            themes+=("${THEME_VARIANTS[2]}")
            shift
            ;;
          red)
            themes+=("${THEME_VARIANTS[3]}")
            shift
            ;;
          orange)
            themes+=("${THEME_VARIANTS[4]}")
            shift
            ;;
          yellow)
            themes+=("${THEME_VARIANTS[5]}")
            shift
            ;;
          green)
            themes+=("${THEME_VARIANTS[6]}")
            shift
            ;;
          teal)
            themes+=("${THEME_VARIANTS[7]}")
            shift
            ;;
          grey)
            themes+=("${THEME_VARIANTS[8]}")
            shift
            ;;
          all)
            themes+=("${THEME_VARIANTS[@]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized theme variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    --icon)
      shift
      for icons in "$@"; do
        case "$icons" in
          default)
            icon='-default'
            shift
            ;;
          apple)
            icon='-apple'
            shift
            ;;
          simple)
            icon='-simple'
            shift
            ;;
          gnome)
            icon='-gnome'
            shift
            ;;
          ubuntu)
            icon='-ubuntu'
            shift
            ;;
          arch)
            icon='-arch'
            shift
            ;;
          manjaro)
            icon='-manjaro'
            shift
            ;;
          fedora)
            icon='-fedora'
            shift
            ;;
          debian)
            icon='-debian'
            shift
            ;;
          void)
            icon='-void'
            shift
            ;;
          opensuse)
            icon='-opensuse'
            shift
            ;;
          popos)
            icon='-popos'
            shift
            ;;
          mxlinux)
            icon='-mxlinux'
            shift
            ;;
          zorin)
            icon='-zorin'
            shift
            ;;
          endeavouros)
            icon='-endeavouros'
            shift
            ;;
          tux)
            icon='-tux'
            shift
            ;;
          nixos)
            icon='-nixos'
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized icon variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
        echo "Install $icons icon for gnome-shell panel..."
      done
      ;;
    --color)
      shift
      for variant in "$@"; do
        case "$variant" in
          standard)
            colors+=("${COLOR_VARIANTS[0]}")
            lcolors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          light)
            colors+=("${COLOR_VARIANTS[1]}")
            lcolors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[2]}")
            lcolors+=("${COLOR_VARIANTS[2]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    --size)
      shift
      for variant in "$@"; do
        case "$variant" in
          standard)
            sizes+=("${SIZE_VARIANTS[0]}")
            shift
            ;;
          compact)
            sizes+=("${SIZE_VARIANTS[1]}")
            shift
            ;;
          -*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized size variant '${1:-}'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    *)
      echo "ERROR: Unrecognized installation option '${1:-}'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [[ "${#themes[@]}" -eq 0 ]] ; then
  themes=("${THEME_VARIANTS[0]}")
fi

if [[ "${#colors[@]}" -eq 0 ]] ; then
  colors=("${COLOR_VARIANTS[@]}")
fi

if [[ "${#lcolors[@]}" -eq 0 ]] ; then
  lcolors=("${COLOR_VARIANTS[1]}")
fi

if [[ "${#sizes[@]}" -eq 0 ]] ; then
  sizes=("${SIZE_VARIANTS[@]}")
fi

tweaks_temp() {
  cp -rf ${SRC_DIR}/_sass/_tweaks.scss ${SRC_DIR}/_sass/_tweaks-temp.scss
  cp -rf ${SRC_DIR}/gnome-shell/sass/_tweaks.scss ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
}

install_float_panel() {
  sed -i "/\$panel_style:/s/compact/float/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$panel_style:/s/compact/float/" ${SRC_DIR}/_sass/_tweaks-temp.scss
}

install_solid() {
  sed -i "/\$opacity:/s/default/solid/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$opacity:/s/default/solid/" ${SRC_DIR}/_sass/_tweaks-temp.scss
  echo -e "Install solid version ..."
}

install_round() {
  sed -i "/\$window:/s/default/round/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$window:/s/default/round/" ${SRC_DIR}/_sass/_tweaks-temp.scss
}

install_blur() {
  sed -i "/\$blur:/s/false/true/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$blur:/s/false/true/" ${SRC_DIR}/_sass/_tweaks-temp.scss
}

install_noborder() {
  sed -i "/\$outline:/s/true/false/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
  sed -i "/\$outline:/s/true/false/" ${SRC_DIR}/_sass/_tweaks-temp.scss
}

install_square() {
  sed -i "/\$titlebutton:/s/circular/square/" ${SRC_DIR}/_sass/_tweaks-temp.scss
}

activities_style() {
  sed -i "/\$activities:/s/icon/default/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
}

install_theme_color() {
  if [[ "$theme" != '' ]]; then
    case "$theme" in
      -purple)
        theme_color='purple'
        ;;
      -pink)
        theme_color='pink'
        ;;
      -red)
        theme_color='red'
        ;;
      -orange)
        theme_color='orange'
        ;;
      -yellow)
        theme_color='yellow'
        ;;
      -green)
        theme_color='green'
        ;;
      -teal)
        theme_color='teal'
        ;;
      -grey)
        theme_color='grey'
        ;;
    esac
    sed -i "/\$theme:/s/default/${theme_color}/" ${SRC_DIR}/gnome-shell/sass/_tweaks-temp.scss
    sed -i "/\$theme:/s/default/${theme_color}/" ${SRC_DIR}/_sass/_tweaks-temp.scss
  fi
}

theme_tweaks() {
  if [[ "$panel" = "float" || "$opacity" == 'solid' || "$window" == 'round' || "$accent" == 'true' || "$blur" == 'true' || "$outline" == 'false' || "$titlebutton" == 'square' ]]; then
    tweaks='true'
    tweaks_temp
  fi

  if [[ "$panel" = "float" ]] ; then
    install_float_panel
  fi

  if [[ "$opacity" = "solid" ]] ; then
    install_solid
  fi

  if [[ "$window" = "round" ]] ; then
    install_round
  fi

  if [[ "$blur" = "true" ]] ; then
    install_blur
  fi

  if [[ "$outline" = "false" ]] ; then
    install_noborder
  fi

  if [[ "$titlebutton" = "square" ]] ; then
    install_square
  fi

  if [[ "$activities" = "default" ]] ; then
    activities_style
  fi
}

clean_theme() {
  local dest="${dest:-$DEST_DIR}"
  local name="${_name:-$THEME_NAME}"
  
  local THEME_DIR="$dest/$name"
  
  rm -rf "${THEME_DIR}"/{cinnamon,gnome-shell,gtk-2.0,gtk-3.0,gtk-4.0,metacity-1,plank,xfwm4,index.theme}
}

install_theme() {
  for theme in "${themes[@]}"; do
    for color in "${colors[@]}"; do
      for size in "${sizes[@]}"; do
        install "${dest:-$DEST_DIR}" "${_name:-$THEME_NAME}" "$theme" "$color" "$size" "$icon"
      done
    done
  done
}

clean_theme && install_theme

echo
echo "Done."
