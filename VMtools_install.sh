#!/bin/bash
DMIEDECODE=$(which dmidecode)
GREP=$(which grep)
YUM=$(which yum)
AWK=$(which awk)

MACHINE_TYPE=$(${DMIEDECODE} | ${GREP} -A10 '^System Information' | ${GREP} 'Product Name' | ${AWK} '{print $3;}')
PACKAGE=''

# Right now we need to package vmware tools and add it to Softwere Channel
case $MACHINE_TYPE in
  VMware)
    PACKAGE='open-vm-tools'
    echo "This machine is in Vsphere"
    ;;
  RHEV)
    PACKAGE='ovirt-guest-agent-common.noarch'
    echo "This Machine is in RHEV"
    ;;
  KVM)
    PACKAGE="qemu-guest-agent"
    echo "This machine is in KVM"
esac

# Install if Package name is set. By logic above if package not found then the var is empty.
if [ ! -z "$PACKAGE" ]; then
  ${YUM} info ${PACKAGE}
  if [ $? = 0 ]; then
    ${YUM} install -y ${PACKAGE}
  else
    echo "${PACKAGE} was not found"
    exit 1
  fi
fi
