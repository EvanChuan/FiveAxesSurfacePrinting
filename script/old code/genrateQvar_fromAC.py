# -*- coding: utf-8 -*-
"""
Created on Tue Sep  3 15:08:57 2019

@author: kofou
"""

import sys

input = sys.argv[1]
output = sys.argv[2]

file = open(input , "r",encoding="utf-8")  #改寫法
f = open(output , "w")
rawstring = file.read()
line = rawstring.split()

needpoint = []
count = 1
while len(line) != 0:
    item = line.pop(0)
    if count == 1:
        new_X = 347.750 + float(item)
        new_X1 = round(new_X, 3)
        needpoint.append(str(new_X1))
        #needpoint.append('X'+str(new_X1))
        count = count + 1
    elif count == 2:
        new_Y = 470.109 + float(item)
        new_Y1 = round(new_Y, 3)
        needpoint.append(str(new_Y1))
        #needpoint.append('Y'+str(new_Y1))
        count = count + 1
    elif count == 3:
        new_Z = -148.300 + float(item) + 25   # 102.500  ,扣掉增高部分
        new_Z1 = round(new_Z, 3)
        needpoint.append(str(new_Z1))
        #needpoint.append('Z'+str(new_Z1))
        count = count + 1
    elif count == 4:   # add A axis
        needpoint.append(str(item))  
        count = count + 1
    elif count ==5:   # add C axis
        needpoint.append(str(item))
        #needpoint.append('C'+str(item))
        count = 1

for i in range(len(needpoint)):
    item = needpoint[i]
    f.write(str(item) + '\n')
                      
f.close()
