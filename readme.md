# Score Program
Raiix

本项目使用masm汇编语言编写，使用资源编辑器构建UI界面

## 需求
随机生成0~100之间的分数，并根据分数进行等级划分，最后统计每个等级总分所占的百分比

等级划分依据：
- 90 ~ 100 为 A
- 80 ~ 90 为 B
- 70 ~ 80 为 C
- 60 ~ 70 为 D

## 构建
本项目须在masm32 sdk环境中进行编译，并且需要用到vc++的nmake

修改`compile.bat`中的`vc_dev_bat_path`的值以适应需求

运行`compile.bat`进行构建

运行`setup.bat`进入masm32 sdk开发命令行环境

`.res`文件最好使用vs的资源编辑器来编辑，直接保存为res格式，无需保存为rc格式