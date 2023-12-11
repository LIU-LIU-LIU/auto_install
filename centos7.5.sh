#!/bin/bash
#离线自动安装脚本
#https://ahaly.cc:86/archives/redis-nginx
#https://github.com/LIU-LIU-LIU/auto_install

#主要版本:
#gcc-4.8.5	7.5*

#nginx-1.21.3
#redis-5.0.5
#jdk-1.0.8_271
#-----------------------
make=4
package=(mpfr libmpc cpp kernel-headers glibc-common glibc glibc-headers glibc-devel libgcc gcc redis libstdc++ libstdc++-devel gcc-c++ pcre perl openssl zlib nginx jdk)
command=(md5sum tar rpm make)

jdk(){
name="jdk1.8.0_271.tar.gz"
prefix="/usr/local/java"
md5="bd8dc95a810b095996acf5f5b0dd2a69"
}
nginx(){
#name="nginx-1.18.0.tar.gz"
#prefix="/opt/nginx"
#md5="b2d33d24d89b8b1f87ff5d251aa27eb8"
#name="nginx-1.21.3.tar.gz"
#prefix="/opt/nginx"
#md5="21cf8dbb90efc89012fe8b49e3e025d3"
name="nginx-1.23.3.tar.gz"
prefix="/opt/nginx"
md5="dcf1a476727a82b5bee702c2ca2c0833"
}
redis(){
name="redis-5.0.5.tar.gz"
md5="2d2c8142baf72e6543174fc7beccaaa1"
}
gcc(){
name="gcc-4.8.5-39.el7.x86_64.rpm"
md5="62d5fcff49a6efdc10c2fae57c4209b1"
}
gcc-c++(){
name="gcc-c++-4.8.5-39.el7.x86_64.rpm"
md5="dd9497e16f4f6d78609db56558789a4a"
}
libstdc++(){
name="libstdc++-4.8.5-39.el7.x86_64.rpm"
md5="0d43fe8f611a07c35d6d2130b49147bc"
}
libstdc++-devel(){
name="libstdc++-devel-4.8.5-39.el7.x86_64.rpm"
md5="271c1ce296152ad73a57e94b7512d6f4"
}
openssl(){
name="openssl-1.1.1h.tar.gz"
md5="53840c70434793127a3574433494e8d3"
}
perl(){
name="perl-5.30.1.tar.gz"
md5="6438eb7b8db9bbde28e01086de376a46"
}
pcre(){
name="pcre-8.37.tar.gz"
md5="6e0cc6d1bdac7a4308151f9b3571b86e"
}
zlib(){
name="zlib-1.2.11.tar.gz"
md5="1c9f62f0778697a09d36121ead88e08e"
}
cpp(){
name="cpp-4.8.5-39.el7.x86_64.rpm"
md5="bf43634586db8586de76fec3fd461896"
}
glibc(){
name="glibc-2.17-307.el7.1.x86_64.rpm"
md5="362ddb43b1f72b5728da02a1ae069f34"
}
glibc-common(){
name="glibc-common-2.17-307.el7.1.x86_64.rpm"
md5="911f8a79802d2628a7c8f0e5cc6d6b4b"
}
glibc-devel(){
name="glibc-devel-2.17-307.el7.1.x86_64.rpm"
md5="d58c15cc1467436f6a28ff2d028f56e8"
}
glibc-headers(){
name="glibc-headers-2.17-307.el7.1.x86_64.rpm"
md5="03dd81294c2b69ceca97d10cdc12883c"
}
kernel-headers(){
name="kernel-headers-3.10.0-1127.el7.x86_64.rpm"
md5="d30648dd8c6ca8b68c1d85254fcf012c"
}
libgcc(){
name="libgcc-4.8.5-39.el7.x86_64.rpm"
md5="707afe937af4519d31a5955ac1d0dc48"
}
libmpc(){
name="libmpc-1.0.1-3.el7.x86_64.rpm"
md5="d828a8cfe6b71d68b97dfdb377e18f0c"
}
mpfr(){
name="mpfr-3.1.1-4.el7.x86_64.rpm"
md5="fc9e39143a34eb3b7c2c0cedb7f62521"
}

fhz(){
if [ $1 == 0 ];then
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
head=`echo ${release}|awk '{print $4}'|awk -F"." '{print $1}'`
if [ $head != 7 ]
then
	echo -e "\033[31m 当前系统不是Centos7.5+系列可能会出现问题! \033[0m"
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
for v in ${command[*]}
do
	which ${v}
	if [ ${?} -eq 0 ]
	then
		echo -e "\033[36m ${v}命令存在，继续。 \033[0m"
	else
		echo -e "\033[31m ${v}命令不存在，是否继续:(y/n) \033[0m"
		if [ ${silent} == "yes" ]
		then
			echo -e "\033[31m 是 \033[0m"
			${v}="Not found"
		else
			while true
			do
				read select
				case $select in
				y|yes|Y)        echo -e "\033[36m 好 \033[0m"
					select='ok'
					${v}="Not found"
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
	${package[19]}
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
		install-rpm 0 9
		${package[10]}
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
		make -j ${make}
		fhz $? ${name}编译
	fi
}

install-nginx(){
        echo -e "\033[36m 安装nginx \033[0m"
        test nginx
        if [ $? == 1 ]
        then
                echo -e "\033[36m nginx已经安装跳过此步 \033[0m"
        else
		install-rpm 0 9
		install-rpm 11 13

		install-tar 14 ./configure
		install-tar 15 "./Configure -des -Dprefix=$HOME/localperl"
		install-tar 16 "./config" && ln -s /usr/local/lib64/libssl.so.1.1 /usr/lib64/libssl.so.1.1 && ln -s /usr/local/lib64/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
		install-tar 17 ./configure
		${package[18]}
		mkdir ${prefix}
        install-tar 18 "./configure --prefix=${prefix} --with-openssl=../openssl-1.1.1h  --with-http_ssl_module --with-http_gzip_static_module --with-pcre --with-stream"
	fi
}

install-tar(){
echo -e "\033[36m 安装tar包\033[0m"
cd ${dir}/package
${package[$1]}
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

install-rpm(){
echo -e "\033[36m 安装rpm包\033[0m"
cd $dir/package
int=$1
num=$2
while (( $int<=$num ))
do
	value=${package[$int]}
	$value
	r_name=`echo ${name} | awk -F".rpm" '{print $1}'`
	this_name=`rpm -qa ${value}`
	if [ "${r_name}" == "${this_name}" ]
	then
		echo -e "\033[36m 你当前已经安装了${name},跳过此步 \033[0m"
	else
		if [ -z ${this_name} ]
		then
			echo -e "\033[36m 正在安装${name} \033[0m"
			rpm -ivh ${name} --nodeps
			fhz $? ${name}安装
		else
			echo -e "\033[31m ${value}已经安装但是版本不对，当前:${this_name},要求:${name}是否强制安装或升级指定版本？(y/n) \033[0m"
			if [ ${silent} == "yes" ]
			then
				echo -e "\033[31m 是 \033[0m"
				rpm -Uv --oldpackage --replacepkgs ${name} --nodeps
				fhz $? ${name}安装
			else
			while true
			do
				read select
				case $select in
				y|yes|Y)        echo -e "\033[36m 好 \033[0m"
					rpm -Uv --oldpackage --replacepkgs ${name} --nodeps
					fhz $? ${name}安装
					break
				;;
				n|no|N)         echo -e "\033[36m 跳过此步。如果不安装指定版本可能会出现未知错误! \033[0m"
					break
				;;
				*)              echo -e "\033[31m 请输入正确的选择(y/n) \033[0m"
				esac
			done
			fi
		fi
	fi
let "int++"
done
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
