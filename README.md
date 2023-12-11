# auto_install  
一个离线自动部署环境的简单脚本  
部署Nginx,Redis,JDK包括其依赖  

**由于github无法上传100MB以上的文件，所以软件包资源将会使用外部链接。**
## Centos6.5
https://file.ahaly.cc:85/share/zGLFDYfx

## Centos7.5
https://file.ahaly.cc:85/share/DcnBJVoO

## CentosStream 9
https://file.ahaly.cc:85/share/GNdtuYt1

## OpenEuler22
https://file.ahaly.cc:85/share/KlfkkorX

编辑脚本文件设置:
```
#编译使用的线程数，一般为CPU数量x2-1
make=4
nginx(){
#软件安装的位置:
prefix="/opt/nginx"
}
