# -*- coding: utf-8 -*-
"""
Created on Thu Oct  3 15:39:03 2019

@author: kofou
"""

file = open("wshell.txt", "r", encoding="utf-8")
print("文件名稱: ", file.name)
point = file.readlines()
file.close()

subsetpoint = []
for i in range(0,len(point),5):
    subsetpoint.append(point[i:i+5])

lowh = 26.3
highh = 69.9
midd = [] 
Aangle = 0
Cangle = 0
flag = 1
while len(subsetpoint) != 0:
    item = subsetpoint.pop(0)
    if float(item[4]) == 0 and float(item[3]) != 0:
        midd.append(item)
    if float(item[4]) == 180 and float(item[3]) != 0:
        midd.append(item)
    elif float(item[4]) == 90 or float(item[3]) == 0:
        if float(item [2]) == lowh:    #底部的高
            Aangle = float(item[3])
            Cangle = float(item[4])
            midd.append(item)
        elif float(item[2]) == highh and flag%2 == 1:
            item1 = item[:]    # copy value 
            item1[3] = str(Aangle) + '\n'
            item1[4] = str('90\n')
            midd.append(item1)
            item2 = item[:]
            item2[2] = str('70.5\n')
            item2[3] = str('0\n')
            item2[4] = str('90\n')
            midd.append(item2)
            #midd.append(item2)
            flag += 1
        elif float(item[2]) == highh and flag%2 == 0:
            item3 = item[:]
            item3[2] = str('70.5\n')
            item3[3] = str('0\n')
            item3[4] = str('90\n')
            midd.append(item3)
            item4 = item[:]
            item4[3] = str(Aangle*(-1)) + '\n'
            item4[4] = str('90\n')
            midd.append(item4)
            #midd.append(item4)
            flag += 1

final = []
while len(midd) != 0:
    item = midd.pop(0)
    for i in range(len(item)):
        final.append(float(item[i]))

with open("5DQ.txt", 'w') as f:
    for item in final:
        f.write(str(item))
        f.write('\n')
