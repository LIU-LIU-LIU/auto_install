#!/bin/bash
#离线自动安装脚本
#https://ahaly.cc:86/archives/redis-nginx
#https://github.com/LIU-LIU-LIU/auto_install

#主要版本:
#gcc-11.3.1	9*

#nginx-1.23.3
#redis-7.0.8
#jdk-1.0.8_271
#-----------------------
make=4
package=(redis nginx jdk)
command=(md5sum tar rpm make)

jdk(){
name="jdk1.8.0_271.tar.gz"
prefix="/usr/local/java"
md5="bd8dc95a810b095996acf5f5b0dd2a69"
}
nginx(){
name="nginx-1.23.3.tar.gz"
prefix="/opt/nginx"
md5="dcf1a476727a82b5bee702c2ca2c0833"
}
redis(){
name="redis-7.0.8.tar.gz"
md5="42a3b0cf3adb871daaed32a59e51f573"
}

fhz(){
if [ $1 == 0 -o $1 == 30 ];then
	echo -e "\033[36m ${2}完成 \033[0m"
else
	echo -e "\033[31m ${2}失败，原因见上，程序退出。 \033[0m"
	exit 1
fi
}

check(){
echo -e "\033[36m +------------------- \033[0m"
echo -e "\033[36m 1/3基础检测 \033[0m"
release=`cat /etc/redhat-release`
echo -e "\033[36m 系统版本: \033[0m"
echo -e "\033[36m ${release} \033[0m"
#head=`echo ${release}|awk '{print $4}'|awk -F"." '{print $1}'`
if [ ${release} != 'CentOS Stream release 9' ]
then
	echo -e "\033[31m 当前系统不是CentosStream9系列可能会出现问题! \033[0m"
	echo -e "\033[31m 是否继续:(y/n) \033[0m"
		read select
		case $select in
		y|yes|Y)        echo -e "\033[36m 好 \033[0m"
		;;
		*)         echo -e "\033[31m 退出程序 \033[0m"
			exit 1
		esac
fi

echo -e "\033[36m 2/3命令检测:\033[0m"
for v in ${command[@]}
do
	which ${v}
	if [ ${?} -eq 0 ]
	then
		echo -e "\033[36m ${v}命令存在，继续。 \033[0m"
	else
		if [ $v == "make" ]
		then
			echo -e "\033[31m make命令不存在，正在安装 \033[0m"
			cd ${dir}/package
			rpm -ivh make*.rpm
			fhz $? 安装make工具
			continue
		fi
		echo -e "\033[31m ${v}命令不存在，是否继续:(y/n) \033[0m"
		if [ ${silent} == "yes" ]
		then
			echo -e "\033[31m 是 \033[0m"
		else
			while true
			do
				read select
				case $select in
				y|yes|Y)        echo -e "\033[36m 好 \033[0m"
					select='ok'
					break
				;;
				n|no|N)         echo -e "\033[31m 退出程序 \033[0m"
					exit 1
				;;
				*)              echo -e "\033[31m 请输入正确的选择(y/n) \033[0m"
				esac
			done
		fi
	fi
done

echo -e "\033[36m 3/3文件检测: \033[0m"
for value in ${package[*]}
do
$value
cd $dir/package
if [ -e "$name" ]
then
	if [ "$md5sum" == "Not found" ]
	then
		echo -e "\033[31m md5sum命令不存在，跳过文件校验步骤 \033[0m"
	else
		temp_md5=`md5sum $name | awk '{print $1}'`
		if [ ${temp_md5} == ${md5} ]
		then
			echo -e "\033[36m ${name}包校验完成 \033[0m"
		else
			echo -e "\033[31m ${name}的md5校验失败，可能是包被篡改，或者下载时丢失部分文件 \033[0m"
			echo -e "\033[31m 是否继续:(y/n) \033[0m"
			if [ ${silent} == "yes" ]
			then
				echo -e "\033[31m 是 \033[0m"
			else
			while true
			do
				read select
				case $select in
				y|yes|Y)        echo -e "\033[36m 好 \033[0m"
					select='ok'
					break
				;;
				n|no|N)         echo -e "\033[31m 退出程序 \033[0m"
					exit 1
				;;
				*)              echo -e "\033[31m 请输入正确的选择(y/n) \033[0m"
				esac
			done
			fi
		fi
	fi
else
	echo -e "\033[31m ${name}不存在，退出程序 \033[0m"
	exit 1
fi
done

}

install-jdk(){
test jdk
if [ $? == 1 ]
then
	echo -e "\033[36m jdk已经安装跳过此步 \033[0m"
else
	cd ${dir}/package
	jdk
	r_name=`echo $name | awk -F".tar" '{print $1}'`
	mkdir ${prefix}
	if [ -d ${r_name} ]
	then
		echo -e "\033[36m ${r_name}目录已存在. \033[0m"
	else
		tar -zxvf ${name}
	fi
	mv ${r_name} ${prefix}
	echo "export JAVA_HOME=${prefix}/${r_name}" >> /etc/profile
	echo "export JRE_HOME=${prefix}/${r_name}/jre" >> /etc/profile
	echo "export PATH=${prefix}/${r_name}/bin:"'$PATH' >> /etc/profile
	source /etc/profile
	echo -e "\033[31m jdk已经安装，环境变量需要重启终端或者手动输入\"source /etc/profile\"生效! \033[0m"
fi
}

install-redis(){
	echo -e "\033[36m 安装redis \033[0m"
	test redis
	if [ $? == 1 ]
	then
		echo -e "\033[36m redis已经安装跳过此步 \033[0m"
	else
		redis
		cd ${dir}/package/gcc
		rpm -ivh *.rpm
		fhz $? 安装gcc及其依赖
		cd ${dir}/package
		r_name=`echo $name | awk -F".tar" '{print $1}'`
		if [ -d ${r_name} ]
		then
			echo -e "\033[36m ${r_name}目录已存在，进入目录并清除上次的编译文件 \033[0m"
		    cd ${r_name}
        	make distclean
		else
        	tar -zxvf ${name}
            fhz $? ${name}解压
			cd ${r_name}
		fi
		make MALLOC=libc -j ${make}
		fhz $? ${name}编译
	fi
}

install-nginx(){
#pcre-devel
#openssl-devel
#zlib-devel
    echo -e "\033[36m 安装nginx \033[0m"
    test nginx
    if [ $? == 1 ]
    then
            echo -e "\033[36m nginx已经安装跳过此步 \033[0m"
    else
		nginx
		cd ${dir}/package/gcc
		rpm -ivh *.rpm
		fhz $? 安装gcc及其依赖
		cd ${dir}/package/pcre
		rpm -ivh *.rpm
		fhz $? 安装pcre及其依赖
		cd ${dir}/package
		rpm -ivh openssl-devel*.rpm
		fhz $? 安装openssl-devel
		rpm -ivh zlib-devel*.rpm
		fhz $? 安装zlib-devel
		cd ${dir}/package
		install-tar nginx "./configure --prefix=${prefix} --with-http_ssl_module --with-http_gzip_static_module --with-pcre --with-stream"
	fi
}


install-tar(){
echo -e "\033[36m 安装tar包\033[0m"
cd ${dir}/package
${1}
r_name=`echo ${name} | awk -F".tar" '{print $1}'`
if [ -d ${r_name} ]
then
	echo -e "\033[36m ${r_name}目录已存在，进入目录 \033[0m"
	cd ${r_name}
	if [ -e Makefile ]
	then
		echo -e "\033[31m ${r_name}似乎已经编译过了，是否继续安装(y/n) \033[0m"
		if [ ${silent} == "yes" ]
		then
			echo -e "\033[36m 是 \033[0m"
			make clean
			make distclean
		else
		while true
        do
			read select
            case $select in
            y|yes|Y)        echo -e "\033[36m 好 \033[0m"
				make clean
				make distclean
				break
            ;;
            n|no|N)         echo -e "\033[36m 跳过此步。\033[0m"
				return 1
            ;;
            *)              echo -e "\033[31m 请输入正确的选择(y/n) \033[0m"
			esac
       done
	   fi
	fi
else
	tar -zxvf ${name}
	fhz $? ${name}解压
	cd ${r_name}
fi
${2}
fhz $? ${name}预编译
make -j ${make}
fhz $? ${name}编译
make install
fhz $? ${name}安装
}

test(){
case $1 in
nginx)
	echo -e "\033[36m 检测nginx\033[0m"
	nginx
	cd ${prefix}/sbin
	./nginx -v
	if [ $? == 0 ]
	then
		echo -e "\033[32m nginx已经安装，目录在:${prefix} \033[0m"
		return 1
	else
		echo -e "\033[36m 找不到nginx \033[0m"
		return 0
	fi
;;
redis)
	echo -e "\033[36m 检测redis \033[0m"
	redis	
	r_name=`echo ${name} | awk -F".tar" '{print $1}'`
	cd ${dir}/package/${r_name}/src
	./redis-server -v
	if [ $? == 0 ]
	then
		echo -e "\033[32m redis已经安装，目录在:${dir}/package/${r_name} \033[0m"
		return 1
	else
		echo -e "\033[36m 找不到redis \033[0m"
        return 0
	fi
;;
jdk)
	echo -e "\033[36m 检测jdk \033[0m"
	jg=`grep "JAVA_HOME" /etc/profile`
	if [ -z "${jg}" ]
	then
		echo -e "\033[36m 找不到jdk \033[0m"
		return 0
	else
		echo -e "\033[32m jdk已经安装，目录在:${jg} \033[0m"
		return 1
	fi
esac
}


start_time=$(date +%s)
#开始计时
dir=$(cd "$(dirname "$0")"; pwd)
echo -e "\033[36m +------------------- \033[0m"
i=0
silent=no
for yes in ${*}
do
	if [ ${yes} = "-y" ]
	then
		silent=yes
	fi
	let "i++"
done
if [ -z ${1} ]
then
	echo -e "\033[36m 1/3 检测环境 \033[0m"
	check
	echo -e "\033[36m +------------------- \033[0m"
	echo -e "\033[36m 2/3 安装软件 \033[0m"
	install-redis
	install-nginx
	install-jdk
	echo -e "\033[36m +------------------- \033[0m"
	echo -e "\033[36m 3/3 测试结果 \033[0m"
	test redis
	test nginx
	test jdk
else
	for v in ${*}
	do
	case ${v} in
	redis|nginx|jdk|-y)
		echo -e "\033[36m 1/3 检测环境 \033[0m"
		check
		echo -e "\033[36m +------------------- \033[0m"
		echo -e "\033[36m 2/3 安装软件 \033[0m"
		if [ ${silent} == "yes" -a ${i} == 1 ]
		then
			install-redis
			install-nginx
			install-jdk
			echo -e "\033[36m +------------------- \033[0m"
			echo -e "\033[36m 3/3 测试结果 \033[0m"
			test redis
			test nginx
			test jdk
		fi
		case ${v} in
		redis)
			install-redis
			echo -e "\033[36m +------------------- \033[0m"
			echo -e "\033[36m 3/3 测试结果 \033[0m"
			test redis
		;;
		nginx)
			install-nginx
			echo -e "\033[36m +------------------- \033[0m"
			echo -e "\033[36m 3/3 测试结果 \033[0m"
			test nginx
		;;
		jdk)
			install-jdk
			echo -e "\033[36m +------------------- \033[0m"
			echo -e "\033[36m 3/3 测试结果 \033[0m"
			test jdk
		esac
	;;
	*)	echo -e "\033[31m 错误的参数，示例\n(./install redis)安装redis；\n(./install redis nginx)安装redis和nginx;\n(./install)不提供参数则全部安装.;\n(./install -y)静默安装\033[0m"
		exit 1
	esac
	done
fi
echo -e "\033[36m +------------------- \033[0m"
end_time=$(date +%s)
cost_time=$[ $end_time-$start_time ]
echo -e "\033[36m 本次安装总共耗时:$(($cost_time/60))分 $(($cost_time%60))秒 \033[0m"