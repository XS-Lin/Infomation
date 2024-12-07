# eBPF #

## INSTALL ##

[bcc](https://github.com/iovisor/bcc)

~~~bash
# https://github.com/iovisor/bcc/blob/master/INSTALL.md#wslwindows-subsystem-for-linux---binary
sudo apt update
sudo apt-get install flex bison libssl-dev libelf-dev dwarves bc

# WSL2 Linux kernel
KERNEL_VERSION=$(uname -r | cut -d '-' -f 1) # 5.15.167.4
git clone --depth 1 https://github.com/microsoft/WSL2-Linux-Kernel.git -b linux-msft-wsl-$KERNEL_VERSION
cd WSL2-Linux-Kernel

# compile and install
cp Microsoft/config-wsl .config
make oldconfig && make prepare
make scripts
make modules
sudo make modules_install # ERROR: CONFIG_X86_X32 enabled but no binutils support
~~~

~~~bash
sudo apt update
sudo apt install software-properties-common
sudo apt install python3.11-full
sudo apt install bpfcc-tools
sudo apt install python3-bpfcc
# sudo apt install libbcc
sudo apt-get install bpfcc-tools libbpfcc libbpfcc-dev linux-headers-$(uname -r)

python3.11 -m venv venv
cd venv
. ./bin/activate
pip install bcc
pip install numba
python test.py

~~~

~~~bash
cat /etc/os-release # VERSION="22.04.3 LTS (Jammy Jellyfish)"


sudo apt-get install flex bison libssl-dev libelf-dev dwarves bc

git clone https://github.com/microsoft/WSL2-Linux-Kernel
cd WSL2-Linux-Kernel
git checkout -b linux-msft-wsl-5.15.153.1 refs/tags/linux-msft-wsl-5.15.153.1

export LOCALVERSION=
make -j8 KCONFIG_CONFIG=./Microsoft/config-wsl
# bison: not found
# flex: not found
sudo apt-get install flex bison
# openssl: not found
sudo apt install libssl-dev
# elf: not found
sudo apt install libelf-dev
# bc: not found
sudo apt-get install bc

make -j8 KCONFIG_CONFIG=./Microsoft/config-wsl
sudo make modules_install
ls /lib/modules # 5.15.153.1-microsoft-standard-WSL2

sudo apt-get install libllvm14 llvm-14-dev libclang-14-dev libelf-dev libfl-dev liblzma-dev libdebuginfod-dev arping netperf iperf zlib1g-dev zip
sudo apt-get install python3-setuptools
~~~
