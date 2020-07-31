# -*- coding: utf-8 -*-
"""
Created on Mon Sep  2 15:52:18 2019

@author: kofour
"""

import sys

input = sys.argv[1]
output = sys.argv[2]

file = open(input , "r",encoding="utf-8")  #改寫法
f = open(output , "w")
rawstring = file.read()
line = rawstring.split()

needpoint = []
count = 0
for i in range(len(line)):
    if line[i][0] == 'X' and count == 0:
        if line[i-1] == 'G1':
            orig_X = line[i][1:]    # X value
            new_X = 347.750 + float(orig_X)
            new_X1 = round(new_X, 3)
            needpoint.append('X2030' + str(new_X1))   # m81=40
            count = count + 1
        elif line[i-1] == 'G0':
            orig_X = line[i][1:]    # X value
            new_X = 347.750 + float(orig_X)
            new_X1 = round(new_X, 3)
            needpoint.append('X2000' + str(new_X1))   # m81=-100
            count = count + 1
    elif line[i][0] == 'Y'and count == 1:
        orig_Y = line[i][1:]
        new_Y = 470.109 + float(orig_Y)
        new_Y1 = round(new_Y, 3)
        needpoint.append('Y'+str(new_Y1))
        count = count + 1
    elif line[i][0] == 'Z'and count == 2:
        orig_Z = line[i][1:]
        new_Z = -148.300 + float(orig_Z)
        new_Z1 = round(new_Z, 3)
        needpoint.append('Z'+str(new_Z1))
        count = count + 1
    elif count == 3:
        needpoint.append('A0')
        needpoint.append('C0')
        count = 0

for i in range(len(needpoint)):
    item = needpoint[i]
    f.write(str(item[1:]) + '\n')

#f.write('0'+'\n'+'0'+'\n')
f.close()
