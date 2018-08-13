#coding=utf-8


# prestr = "https://svt.jav101.com/avid5b18ba1ae9d34/ts/avid5b18ba1ae9d34-"
# lastStr = ".ts\n"
# name = ""
# for num in range(0,26):
#         n1 = prestr+str(num)+ lastStr
#         name = name+n1
# fo = open("a.txt","w+")
# fo.write(name)
#
#


import sys
import os

os.popen("touch all.txt")
x = int(26)
i = 0
while i <= x:
    command = "wget " + "https://svt.jav101.com/avid5b18ba1ae9d34/ts/avid5b18ba1ae9d34-" +str(i) + ".ts"
    try:
        os.popen(command)
    except:  # 如果没有当前.ts, 打印出错误并跳过
        print ( "There is no ts")
    i += 1

