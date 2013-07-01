#NDK_ROOT="/opt/android/android-ndk"
APPNAME="SetCard"

# options

buildexternalsfromsource=
PARALLEL_BUILD_FLAG=

usage(){
cat << EOF
usage: $0 [options]

Build C/C++ code for $APPNAME using Android NDK

OPTIONS:
-s	Build externals from source
-p  Run make with -j8 option to take advantage of multiple processors
-h	this help
EOF
}

while getopts "sph" OPTION; do
case "$OPTION" in
s)
buildexternalsfromsource=1
;;
p)
PARALLEL_BUILD_FLAG=\-j8
;;
h)
usage
exit 0
;;
esac
done

# exit this script if any commmand fails
set -e

# read local.properties

_LOCALPROPERTIES_FILE=$(dirname "$0")"/local.properties"
if [ -f "$_LOCALPROPERTIES_FILE" ]
then
    [ -r "$_LOCALPROPERTIES_FILE" ] || die "Fatal Error: $_LOCALPROPERTIES_FILE exists but is unreadable"

    # strip out entries with a "." because Bash cannot process variables with a "."
    _PROPERTIES=`sed '/\./d' "$_LOCALPROPERTIES_FILE"`
    for line in "$_PROPERTIES"; do
        declare "$line";
    done
fi

# paths

if [ -z "${NDK_ROOT+aaa}" ];then
echo "NDK_ROOT not defined. Please define NDK_ROOT in your environment or in local.properties"
exit 1
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# ... use paths relative to current directory
if [ $COCOS2DX_ROOT == "" ];then
    COCOS2DX_ROOT="$DIR/../../../.."
fi
APP_ROOT="$DIR/.."
APP_ANDROID_ROOT="$DIR"
RESROUCE_ROOT="$APP_ROOT/Resources/"
BINDINGS_JS_ROOT="$COCOS2DX_ROOT/scripting/javascript/bindings/js"

echo
echo "Paths"
echo "    NDK_ROOT = $NDK_ROOT"
echo "    COCOS2DX_ROOT = $COCOS2DX_ROOT"
echo "    APP_ROOT = $APP_ROOT"
echo "    APP_ANDROID_ROOT = $APP_ANDROID_ROOT"
echo

# Debug
set -x

# make sure assets is exist
if [ -d "$APP_ANDROID_ROOT"/assets ]; then
    rm -rf "$APP_ANDROID_ROOT"/assets
fi

mkdir "$APP_ANDROID_ROOT"/assets

# copy "Resources" into "assets"
cp -rf "$RESROUCE_ROOT"/* "$APP_ANDROID_ROOT"/assets

# copy bindings/*.js into assets' root
cp -f "$BINDINGS_JS_ROOT"/*.js "$APP_ANDROID_ROOT"/assets


rm -rf "$APP_ANDROID_ROOT"/assets/img/icon
rm -rf "$APP_ANDROID_ROOT"/assets/img/btn
rm -rf "$APP_ANDROID_ROOT"/assets/img/txt
rm -rf "$APP_ANDROID_ROOT"/assets/img/num
rm -rf "$APP_ANDROID_ROOT"/assets/img/num1
rm -rf "$APP_ANDROID_ROOT"/assets/img/num2
rm -rf "$APP_ANDROID_ROOT"/assets/img/num3

echo "Using prebuilt externals"
echo

set -x

"$NDK_ROOT"/ndk-build $PARALLEL_BUILD_FLAG -C "$APP_ANDROID_ROOT" $* \
    "NDK_MODULE_PATH=${COCOS2DX_ROOT}:${COCOS2DX_ROOT}/cocos2dx/platform/third_party/android/prebuilt" \
    NDK_LOG=0 V=0
