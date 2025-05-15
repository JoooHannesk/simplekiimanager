#
# Build, convert and upload DocC-Documentation to webserver using scp
# Build for static hosting
#
# by Johannes Kinzig | mail@johanneskinzig.com | https://johanneskinzig.com
#


# check if SCPDESTINATION is set
if [ -z ${SCPDESTINATION+x} ]
then
echo "Warning: Your scp destination is not set. Script will abort! Please set destination to deploy documentation to a webserver. Use the following format: export SCPDESTINATION=scp://user@host:port/path/to/www/folder/on/webserver"
exit 1
fi

# build .doccarchive
xcodebuild docbuild -scheme SimpleKiiManager -derivedDataPath ./.doccbuilds/build -destination platform=macOS 

# convert documentation for static hosting
xcrun docc process-archive transform-for-static-hosting ./.doccbuilds/build/Build/Products/Debug/SimpleKiiManager.doccarchive --output-path ./.doccbuilds/publish

# scp to destination
scp -rp ./.doccbuilds/publish/* $SCPDESTINATION

# cleanup local files
rm -r ./.doccbuilds

# refer to published documentation
echo "Documentation now available at:\nhttps://simplekiimanager.kinzig-developer-docs.com/documentation/simplekiimanager"
echo "(CMD+2*click on URL to open in your default browser)"
