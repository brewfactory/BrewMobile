FRAMEWORK_DIR="./Carthage/Build/iOS"
FRAMEWORKS=`find "${FRAMEWORK_DIR}" -type d -name "*.framework"`

for FRAMEWORK in ${FRAMEWORKS};
    do
    if [ -d "${FRAMEWORK}" ]; then
		codesign --deep -f -s - "${FRAMEWORK}"
     fi
done
