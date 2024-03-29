#!/bin/bash
function main
{
	while true
	do
        dialog --menu "Qemu脚本生成器2.0 --- 控制台" 40 200 180 "1" "选择磁盘（可不选）" \
	      	"2" "选择光盘（可不选）" \
    		"3" "选择软盘（可不选）" \
        	"4" "选择BIOS固件（可不选）" \
		    "5" "选择内核文件（可不选）" \
        	"6" "选择Initrd文件（可不选）" \
	      	"7" "设置内存大小" \
		    "8" "选择显卡型号" \
        	"9" "选择CPU型号" \
		    "10" "graphic选项（可不选）" \
	     	"11" "显示方式（可不选）" \
	        "12" "-monitor选项" \
		    "13" "网卡型号选择（可不选）" \
		    "14" "启动选项（可不选）" \
        	"15" "声卡型号选择（可不选）" \
	    	"16" "保存并退出" 2> sel.log
        if (( $? == 1 )); then
        	dialog --yesno "现在退出?" 40 200
            if (( $? == 0 )); then
                exit
        	fi
	    fi
		case $(cat sel.log) in 
			1)
				./filepr.sh "disk";;
			2)
				./filepr.sh "cdrom";;
			3)
				./filepr.sh "floppy";;
			4)
				./filepr.sh "bios";;
			5)
				./filepr.sh "vmlinuz";;
			6)
				./filepr.sh "initrd";;
			7)
				mem;;
			8)
				GPU;;
			9)
				CPU;;
			"10")
				graphic;;
			"11")
				display;;
			"12")
				monitor;;
			"13")
				netdev;;
			"14")
				boot_option;;
			"15")
				soundhw;;
			"16")
				save_exit;;
		esac
	done
}

function mem
{
	export MEM=$(cat /proc/meminfo|head -n 1)
	export MEM=$(echo $MEM|tr -cd '[0-9]')
	export MEM=$[$MEM/1024]
	while true
	do
		dialog --inputbox "设置你的内存，你的内存现在有$MEM MiB" 40 200 2> mem.log
		if (( $? == 1 )); then
			return
		else
			export mem_input=$(cat mem.log|tr -cd '[0-9]')
			if test -z $mem_input; then
				dialog --msgbox "请输入一个正确的数字" 40 200
			else
				if (( $mem_input >= $MEM )); then
					dialog --msgbox "你当前设置的内存大于实际内存" 40 200
				else
					if (( $mem_input <= 16 )); then
						dialog --msgbox "设置的内存不能小于16MiB" 40 200
					else
						if (( $mem_input <= 128 )); then
							dialog --yesno "Waring：你现在的内存小于128MiB，继续？" 40 200
							if (( $? == 1 )); then
								:
							else
								export RealMEM="-m $mem_input"
								rm mem.log
								return
							fi
						else
							export RealMEM="-m $mem_input"
							rm mem.log
							return
						fi
					fi
				fi
			fi
		fi
	done
}

function GPU
{
	while true
	do
		dialog --menu "选择一个GPU型号" 40 200 180 \
			"1" "std" \
			"2" "cirrus" \
			"3" "vmware" \
			"4" "xenfb" \
			"5" "qxl" \
			"6" "virtio" 2> gpu.log
		if (( $? == 1 )); then
			return
		else
			case $(cat gpu.log) in
				1)
					export RealGPU="-vga std";;
				2)
					export RealGPU="-vga cirrus";;
				3)
					export RealGPU="-vga vmware";;
				4)
					export RealGPU="-vga xenfb";;
				5)
					export RealGPU="-vga qxl";;
				6)
					export RealGPU="-vga virtio";;
			esac
			rm gpu.log
			return
		fi
	done
}

function CPU
{
	while true
	do
		dialog --menu "选择一个CPU型号" 40 200 180 \
			"1" "AMD EPYC" \
			"2" "Haswell" \
			"3" "IvyBridge" \
			"4" "KnightsMill" \
			"5" "Nehalem" \
			"6" "qemu64" \
			"7" "Opteron_G5" \
			"8" "athlon" \
			"9" "Penryn" \
			"10" "Westmere" \
			"11" "core2duo" \
			"12" "kvm64" \
			"13" "n270" \
			"14" "Pentium" \
			"15" "Pentium2" \
			"16" "Pentium3" \
			"17" "phenom" 2> cpu.log
		if (( $? == 1 )); then
			return
		else
			case $(cat cpu.log) in
				1)
					export RealCPU="-cpu EPYC";;
				2)
					export RealCPU="-cpu Haswell";;
				3)
					export RealCPU="-cpu IvyBridge";;
				4)
					export RealCPU="-cpu KnightsMill";;
				5)
					export RealCPU="-cpu Nehalem";;
				6)
					export RealCPU="-cpu qemu64";;
				7)
					export RealCPU="-cpu Opteron_G5";;
				8)
					export RealCPU="-cpu athlon";;
				9)
					export RealCPU="-cpu Penryn";;
				"10")
					export RealCPU="-cpu Westmere";;
				"11")
					export RealCPU="-cpu core2duo";;
				"12")
					export RealCPU="-cpu kvm64";;
				"13")
					export RealCPU="-cpu n270";;
				"14")
					export RealCPU="-cpu pentium";;
				"15")
					export RealCPU="-cpu pentium2";;
				"16")
					export RealCPU="-cpu pentium3";;
				"17")
					export RealCPU="-cpu phenom";;
			esac
			while true
			do
				dialog --inputbox "输入一个数字，它将作为CPU的核心数[ 1-16 | 默认 = 2]" 40 200 2> cores.log
				if (( $? == 1 )); then
					break
				else
					export cores=$(cat cores.log|tr -cd '[0-9]')
					if test -z $cores; then
						dialog --msgbox "使用默认核心数 : 2" 40 200
						export RealCores="-smp 2"
						rm cores.log cpu.log
						return
					else
						if (( $cores <= 0 )); then
							dialog --msgbox "CPU核心数不能小于1" 40 200
						else
							if (( $cores >= 17 )); then
								dialog --msgbox "CPU核心数不能大于16" 40 200
							else
								export RealCores="-smp $cores"
								rm cores.log cpu.log
								return
							fi
						fi
					fi
				fi
			done
		fi
	done
}

function graphic
{
	while true
	do
		dialog --yesno "你需要启用 -nographic 参数吗？?" 40 200
		if (( $? == 1 )); then
            export RealGrap=''
            return
        else
            export RealGrap="-nographic"
            return
        fi
    done
}

function display
{
    while true
    do
        dialog --menu "设置显示方式" 40 200 180 \
        "1" "VNC" \
        "2" "SDL" \
        "3" "无" 2> display.log
        if (( $? == 1 )); then
            return
        else
            case $(cat display.log) in
                1)
                    vnc_port
                    rm display.log
                    return;;
                2)
                    export RealDIS="-sdl"
                    rm display.log
                    return;;
                3)
                    rm display.log
                    return;;
            esac
        fi
    done
}
function vnc_port
{
    while true
    do
        dialog --inputbox "输入一个数字，它将作为VNC的端口[1-255 | 默认 16]" 40 200 2> vnc.log
        if (( $? == 1 )); then
            return
        else
            export vport=$(cat vnc.log|tr -cd '[0-9]')
            if test -z $vport; then
                dialog --msgbox "使用默认端口数 : 16" 40 200
                export $RealDIS="-vnc :16"
                rm vnc.log
                return
            else
                if (( $vport <= 0 )); then
                    dialog --msgbox "端口不能小于1" 40 200
                else
                    if (( $vport >= 256 )); then
                        dialog --msgbox "端口不能高于255" 40 200
                    else
                        export RealDIS="-vnc :$vport"
                        rm vnc.log
                        return
                    fi
                fi
            fi
        fi
    done
}

function monitor
{
    while true
    do
        dialog --menu "设置 -monitor参数" 40 200 180 \
        "1" "无" \
        "2" "本地 Studio" \
        "3" "远程 Telnet" 2> mnr.log
        if (( $? == 1 )); then
            return
        else
            case $(cat mnr.log) in
                1)
                    rm mnr.log
                    return;;
                2)
                    export RealMNR="-monitor stdio"
                    rm mnr.log
                    return;;
                3)
                    telnet_port
                    rm mnr.log
                    return;;
            esac
        fi
    done
}
function telnet_port
{
    while true
    do
        dialog --inputbox "输入一个数字，它将作为telnet的端口[1-4096 | 默认 511]" 40 200 2> telport.log
        if (( $? == 0 )); then
            return
        else
            export telport=$(cat telport.log|tr -cd '[0-9]')
            if test -z $telport; then
                dialog --msgbox "使用默认端口：511"
                export RealMNR="-monitor telnet::511,server,nowait"
                rm telport.log
                return
            else
                if (( $telport <= 0 )); then
                    dialog --msgbox "端口数不能小于1" 40 200
                else
                    if (( $telport >= 4097 )); then
                        dialog --msgbox "端口数过高" 40 200
                    else
                        export RealMNR="-monitor telnet::$telport,server,nowait"
                        rm telport.log
                        return
                    fi
                fi
            fi
        fi
    done
}

function netdev
{
    while true
    do
        dialog --menu "选择一个网卡型号" 40 200 180 \
        "1" "i82550" \
        "2" "i82551" \
        "3" "i82557a" \
        "4" "i82558a" \
        "5" "i82559a" \
        "6" "i82562" \
        "7" "i82801" \
        "8" "e1000" \
        "9" "ne2k_pci" \
        "10" "pcnet" \
        "11" "rtl8139" \
        "12" "tulip" \
        "13" "vmxnet3" 2> net.log
        if (( $? == 1 )); then
            return
        else
            case $(cat net.log) in
                1)
                    export RealNET="-netdev user,id=eth0 -net nic,model=i82550,netdev=eth0";;
                "2")
                    export RealNET="-netdev user,id=eth0 -net nic,netdev=eth0,model=i82551";;
                "3")
                    export RealNET="-netdev user,id=eth0 -net nic,netdev=eth0,model=i82557a";;
                "4")
                    export RealNET="-netdev user,id=eth0 -net nic,netdev=eth0,model=i82558a";;
                "5")
                    export RealNET="-netdev user,id=eth0 -net nic,netdev=eth0,model=i82559a";;
                "6")
                    export RealNET="-netdev user,id=eth0 -net nic,netdev=eth0,model=i82562";;
                "7")
                    export RealNET="-netdev user,id=eth0 -net nic,netdev=eth0,model=i82801";;
                "8")
                    export RealNET="-netdev user,id=eth0 -net nic,netdev=eth0,model=e1000";;
                "9")
                    export RealNET="-netdev user,id=eth0 -net nic,netdev=eth0,model=ne2k_pci";;
                "10")
                    export RealNET="-netdev user,id=eth0 -net nic,netdev=eth0,model=pcnet";;
                "11")
                    export RealNET="-netdev user,id=eth0 -net nic,netdev=eth0,model=rtl8139";;
                "12")
                    export RealNET="-netdev user,id=eth0 -net nic,netdev=eth0,model=tulip";;
                "13")
                    export RealNET="-netdev user,id=eth0 -net nic,netdev=eth0,model=vmxnet3";;
            esac
            rm net.log
            return
        fi
    done
}

function boot_option
{
    while true
    do
        dialog --menu "配置启动顺序" 40 200 180 \
        "1" "从软盘启动" \
        "2" "从光盘启动" \
        "3" "从硬盘启动" 2> boot.log
        if (( $? == 1 )); then
            return
        else
            case $(cat boot.log) in
                1)
                    export RealBOOT="-boot a";;
                2)
                    export RealBOOT="-boot d";;
                3)
                    export RealBOOT="-boot c";;
            esac
            rm boot.log
            return
        fi
    done
}

function soundhw
{
    while true
    do
        dialog --menu "选择一个声音设备" 40 200 180 \
        "1" "adlib" \
        "2" "cs4231a" \
        "3" "sb16" \
        "4" "hda" \
        "5" "es1370" \
        "6" "ac97" \
        "7" "gus" 2> sound.log
        if (( $? == 1 )); then
            return
        else
            case $(cat sound.log) in
                1)
                    export RealSound="-soundhw adlib";;
                2)
                    export RealSound="-soundhw cs4231a";;
                3)
                    export RealSound="-soundhw sb16";;
                4)
                    export RealSound="-soundhw hda";;
                5)
                    export RealSound="-soundhw es1370";;
                6)
                    export RealSound="-soundhw ac97";;
                7)
                    export RealSound="-soundhw gus";;
            esac
            rm sound.log
            return
        fi
    done
}

function save_exit
{
    export mu=""
    if test -z $RealMEM; then
        export mu+=" 内存设置"
    fi
    if test -z $RealGPU; then
        export mu+=" 选择CPU型号"
    fi
    if test -z $RealCPU; then
        export mu+=" 选择GPU型号"
    fi
#
#
#
    if test -z $mu; then
        while true
        do
            dialog --inputbox "脚本名字？" 40 200 2> name.log
            if (( $? == 1 )); then
                return
            else
                if test -z $(cat name.log); then
                    dialog --msgbox "名字不能为空" 40 200
                else
                    export name=$(cat name.log)
                    rm name.log
                    break
                fi
            fi
        done
    else
        dialog --msgbox "你还没有完成 $mu" 40 200
        return
    fi
    clear
    echo "正在处理"
    sleep 2s
    filepr
    export ALL="qemu-system-x86_64 $RealBOOT $RealCPU $RealCores $RealMEM $RealMNR $RealGPU \
    $RealNET $RealGrap $RealSound $RealDIS $RealDISK $RealCDR $RealFPY $RealBIOS \
    $RealVMZ $RealITD"
    echo $ALL
    sleep 1s
    echo $ALL > $name.sh
    chmod 777 $name.sh
    rm path.log
    rm sel.log
    echo "完成."
    exit
}

function filepr
{
    for i in "disk" "cdrom" "floppy" "bios" "vmlinuz" "initrd"
    do
        if ls sel2_$i.log &> /dev/null; then
            case $i in
                "disk")
                    export RealDISK="-drive if=none,file=$(cat sel2_disk.log),id=hd0";;
                "cdrom")
                    export RealCDR="-cdrom $(cat sel2_cdrom.log)";;
                "floppy")
                    export RealFPY="-fda $(cat sel2_floppy.log)";;
                "bios")
                    export RealBIOS="-bios $(cat sel2_bios.log)";;
                "vmlinuz")
                    export RealVMZ="-kernel $(cat sel2_vmlinuz.log)";;
                "initrd")
                    export RealITD="-initrd $(cat sel2_initrd.log)";;
            esac
            rm sel2_$i.log
        fi
    done
}

function app_check
{
    echo "欢迎使用Qemu脚本生成器2.0 With Dialog"
    sleep 1s
    echo "作者:Hyper-V Manager|hyper-v管理器"
    sleep 1s
    echo "bili: https://space.bilibili.com/234069376"
    sleep 3s
    echo "正在检查所需的软件"
    export not_installed=""
    if ! command -v qemu-system-x86_64 &> /dev/null; then
        export not_installed+=" qemu-system-x86-64"
    fi
    if ! command -v dialog &> /dev/null; then
        export not_installed+=" dialog"
    fi
    if ! command -v zsh &> /dev/null; then
        export not_installed+=" zsh"
    fi
    if test -z $not_installed; then
        main
    else
        read -n 1 -p "$not_installed 还没有安装，现在安装？[Y|n]" yesno
        case $yesno in
            "Y"|"y")
                install_app;;
            "N"|"n")
                exit;;
            "")
                install_app;;
            *)
                echo "不输入，正在退出"
                exit;;
        esac
    fi
}

function install_app
{
    for pkmg in "apt" "yum" "zypper" "pacman"
    do
        if command -v $pkmg &> /dev/null; then
            break
        fi
        if [ $pkmg="yum" ]; then
            if ! command -v $pkmg &> /dev/null; then
                if command -v dnf &> /dev/null; then
                    export pkmg="dnf"
                    break
                fi
            fi
        fi
    done
    if (( $(id -u) == 0 )); then
        case $pkmg in
            "apt"|"yum"|"dnf"|"zypper")
                $pkmg install $not_installed -y;;
            "pacman")
                $pkmg -S $not_installed
                if (( $? == 1 )); then
                    exit
                fi;;
        esac
    else
        case $pkmg in
            "apt"|"yum"|"dnf"|"zypper")
                sudo $pkmg install $not_installed -y;;
            "pacman")
                sudo $pkmg -S $not_installed
                if (( $? == 1 )); then
                    exit
                fi;;
        esac
    fi
    app_check
    sleep 1s
    echo "检查完成"
    sleep 1s
    echo "图形界面将在3s后启动"
    sleep 2s
    main
}

if ls filepr.sh &> /dev/null; then
    echo "filepr.sh 存在"
    sleep 1s
    app_check
else
    echo "filepr.sh 不存在，正在退出"
    exit
fi
