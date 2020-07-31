# -*- coding: utf-8 -*-
"""
Created on Fri Aug 30 20:24:23 2019

@author: kofour
"""

import sys

input = sys.argv[1]
output = sys.argv[2]

file = open(input , "r",encoding="utf-8")  #改寫法
f = open(output , "w")
rawstring = file.read()
line = rawstring.split()

indices_layer = [i for i, x in enumerate(line) if x[0:7] == ";LAYER:"]
indices_wallout = [i for i, x in enumerate(line) if x == ";TYPE:WALL-OUTER"]
needpoint = []
for i in range(len(indices_wallout)):
    needpoint.append(line[indices_layer[i]]) #將層資訊放入
    line_id = indices_wallout[i]        #找出在line_store中的TYPE:WALL-OUTER位置
    low_height = line_id + 4
    if float(line[low_height][1:]) >= 40:  # 調整高度
        for j in range(line_id,len(line)):  #從TYPE:WALL-OUTER開始抓點
            if line[j] == 'G0':
                break
            else:
                needpoint.append(line[j])

# write in file
'''
shell = []
while len(needpoint) != 0:
    item = needpoint.pop(0)
    if item[0] == 'X' or item[0] == 'Y' or item[0] == 'Z':
        shell.append(item)
'''

for i in range(len(needpoint)):
    if needpoint[i][0] =='Z':
        #new_Z = float(needpoint[i][1:])+25
        #f.write('Z'+str(new_Z)+'\n')
        f.write(needpoint[i]+'\n')
    elif needpoint[i][1:6] == 'LAYER':
        f.write(needpoint[i]+'\n')
    elif needpoint[i][1:5] == 'TYPE':
        continue
    else:
        f.write(needpoint[i]+' ')  
f.close() 
