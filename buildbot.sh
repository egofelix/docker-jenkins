#!/bin/bash
# Set Version
REVISION_NUMBER=`git rev-list --count HEAD`
FULL_VERSION="0.1.${REVISION_NUMBER}.${BUILD_NUMBER}"

#targetArchs=("amd64" "armhf")
#for arch in "${targetArchs[@]}"
#do
arch="amd64"

targetArch=""
if [[ "${TARGET^^}" == "ARMHF" ]];
then
  targetArch=linux-arm
fi;

if [[ "${TARGET^^}" == "AMD64" ]];
then
  targetArch=linux-x64
fi;

if [[ "${targetArch}" == "" ]];
then
	echo "Could not build for arch ${arch}"
	continue
fi;

# Fix Dos Lines
dos2unix ${PROJECT}/BuildInfo/postinst.txt
dos2unix ${PROJECT}/BuildInfo/postinst.txt
dos2unix ${PROJECT}/BuildInfo/preinst.txt
dos2unix ${PROJECT}/BuildInfo/preinst.txt
dos2unix ${PROJECT}/BuildInfo/prerm.txt
dos2unix ${PROJECT}/BuildInfo/prerm.txt
dos2unix ${PROJECT}/BuildInfo/control.txt
dos2unix ${PROJECT}/BuildInfo/control.txt

# Create Directories
#mkdir -p package_${arch}_${FULL_VERSION}/lib/systemd/system
mkdir -p package_${arch}_${FULL_VERSION}/DEBIAN

# Create Package Info
packageName=$(cat ${PROJECT}/BuildInfo/control.txt | grep 'Package:' | cut -d':' -f 2 | sed -e 's/[[:space:]]*$//' | sed -e 's/^[[:space:]]*//')
sed -e "s/\\\${packageName}/${packageName}/g" -e "s/\${arch}/${arch}/g" ${PROJECT}/BuildInfo/postinst.txt > package_${arch}_${FULL_VERSION}/DEBIAN/postinst
sed -e "s/\\\${packageName}/${packageName}/g" -e "s/\${arch}/${arch}/g" ${PROJECT}/BuildInfo/preinst.txt > package_${arch}_${FULL_VERSION}/DEBIAN/preinst
sed -e "s/\\\${packageName}/${packageName}/g" -e "s/\${arch}/${arch}/g" ${PROJECT}/BuildInfo/prerm.txt > package_${arch}_${FULL_VERSION}/DEBIAN/prerm
sed -e "s/\\\${packageName}/${packageName}/g" -e "s/\${arch}/${arch}/g" ${PROJECT}/BuildInfo/control.txt > package_${arch}_${FULL_VERSION}/DEBIAN/control
echo "" >> package_${arch}_${FULL_VERSION}/DEBIAN/control
echo "Version: ${FULL_VERSION}" >> package_${arch}_${FULL_VERSION}/DEBIAN/control
chmod 0755 package_${arch}_${FULL_VERSION}/DEBIAN/{postinst,preinst,prerm,control}

# Copy Service Template
dos2unix ${PROJECT}/BuildInfo/${packageName}.service && mkdir -p package_${arch}_${FULL_VERSION}/lib/systemd/system/
dos2unix ${PROJECT}/BuildInfo/${packageName}.service && mkdir -p package_${arch}_${FULL_VERSION}/lib/systemd/system/
sed -e "s/\\\${packageName}/${packageName}/g" -e "s/\${arch}/${arch}/g" ${PROJECT}/BuildInfo/${packageName}.service > package_${arch}_${FULL_VERSION}/lib/systemd/system/${packageName}.service

# Build it
echo Building ${packageName} for ${TARGET,,}
HOME=/var/jenkins_home/ DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true dotnet publish -r ${targetArch} -c Release "/p:Version=${FULL_VERSION}"

# Copy content to /opt/${PROJECT}
mkdir -p package_${arch}_${FULL_VERSION}/opt/${packageName}
cp -r ${PROJECT}/bin/Release/netcoreapp*.0/${targetArch}/publish/* package_${arch}_${FULL_VERSION}/opt/${packageName}/

# Copy MaiNConf
#dos2unix -n ${PROJECT}.BuildInfo/configuration/actions.iptables.conf banthosebastards_${FULL_VERSION}/etc/${PROJECT}/actions.conf
#dos2unix -n ${PROJECT}.BuildInfo/configuration/main.conf banthosebastards_${FULL_VERSION}/etc/${PROJECT}/main.conf

# Append .new to all config files
#find package_${arch}_${FULL_VERSION}/etc/${packageName}/ -type f -exec mv '{}' '{}'.new \;


# Build Package
echo Creating package ${packageName} for ${TARGET,,}
dpkg-deb --build package_${arch}_${FULL_VERSION}

# Copy Package to Repo
echo Releasing package ${packageName} for ${TARGET,,}
mkdir -p /var/packages/debian/dists/stable/main/binary-${TARGET,,}/
mv package_${arch}_${FULL_VERSION}.deb /var/packages/debian/dists/stable/main/binary-${TARGET,,}/${packageName}_${FULL_VERSION}.deb
