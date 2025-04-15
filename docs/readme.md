## 初始安装

pip3 install -r ./requirements.txt

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

## 在线编辑预览

sphinx-autobuild source build/html

## 编译文档

make html

## 启动服务

python3 -m http.server --directory build/html

## 文档部署

1 自动发布到  https://readthedocs.org

2 将html 目录下文件拷贝到部署服务环境即可。 

如nginx  



