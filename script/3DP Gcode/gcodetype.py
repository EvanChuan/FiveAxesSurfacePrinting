# -*- coding: utf-8 -*-
"""
Created on Wed Oct  9 16:06:31 2019

@author: kofou
"""

file = open("w半球_shell.txt", "r", encoding="utf-8")
print("文件名稱: ", file.name)
line_5D = file.readlines()
file.close()

point =[]
count = 1
while len(line_5D) != 0:
    item = line_5D.pop(0)
    item = float(item)
    if count == 1:
        point.append('X'+str(item))
        count += 1
    elif count == 2:
        point.append('Y'+str(item))
        count += 1
    elif count == 3:
        point.append('Z'+str(item))
        count += 1
    elif count == 4:
        point.append('A'+str(item))
        count += 1
    elif count == 5:
        point.append('C'+str(item))
        count = 1
        
with open("半球5axis.txt", 'w') as f:
    count = 1
    for i in range(len(point)):
        if count == 5:
            f.write(str(point[i])+'\n')
            count =1
        else:
            f.write(str(point[i])+' ')
            count +=1