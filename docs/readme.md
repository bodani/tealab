## 初始安装

pip3 install ./requirements.txt

## 目录结构
```
.
├── Makefile
├── build # 文档成果物 html 目录下
├── make.bat
└── source # 编辑文档
    ├── _static
    ├── _templates
    ├── conf.py
    └── index.rst
```

## 编译文档

make html

## 启动服务

cd build/html

python3 -m http.server 

## 文档部署

将html 目录下文件拷贝到部署服务环境即可。 

如nginx  
