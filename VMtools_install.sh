#!/bin/bash
DMIEDECODE=$(which dmidecode)
GREP=$(which grep)
YUM=$(which yum)
AWK=$(which awk)
SYSTEMCTL=$(which systemctl)
PackageVMware='open-vm-tools'
ServiceVMware='vmtoolsd.service'
PackageRHEV='ovirt-guest-agent-common'
ServiceRHEV='ovirt-guest-agent.service'
PackageKVM='qemu-guest-agent'
ServiceKVM='qemu-guest-agent.service'

MACHINE_TYPE=$(${DMIEDECODE} | ${GREP} -A10 '^System Information' | ${GREP} 'Product Name' | ${AWK} '{print $3;}')
PACKAGE=''
SERVICENAME=''

# Right now we need to package vmware tools and add it to Softwere Channel
case $MACHINE_TYPE in
  VMware)
    PACKAGE=${PackageVMware}
    SERVICENAME=${ServiceVMware}
    echo "This machine is in Vsphere"
    ;;
  RHEV)
    PACKAGE=${PackageRHEV}
    SERVICENAME=${ServiceRHEV}
    echo "This Machine is in RHEV"
    ;;
  KVM)
    PACKAGE=${PackageKVM}
    SERVICENAME=${ServiceKVM}
    echo "This machine is in KVM"
esac

# Install if Package name is set. By logic above if package not found then the var is empty.
if [ ! -z "$PACKAGE" ]; then
  ${YUM} info ${PACKAGE}
  if [ $? = 0 ]; then
    ${YUM} install -y ${PACKAGE}
    ${SYSTEMCTL} enable ${SERVICENAME}
    ${SYSTEMCTL} start ${SERVICENAME}
  else
    echo "${PACKAGE} was not found"
    exit 1
  fi
fi
