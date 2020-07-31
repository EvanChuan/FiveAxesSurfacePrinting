# -*- coding: utf-8 -*-
"""
Created on Fri Sep  6 12:52:17 2019

@author: kofour
"""

file = open("3Q.txt", "r", encoding="utf-8")
print("文件名稱: ", file.name)
line_3D = file.readlines()
file.close()

file = open("5Q.txt", "r", encoding="utf-8")
print("文件名稱: ", file.name)
line_5D = file.readlines()
file.close()

subline_5D = []
for i in range(0, len(line_5D), 5):
    subline_5D.append(line_5D[i:i+5])

#
long = len(line_3D)
last_X = line_3D[long-5]
needX = last_X[4:]
stoppoint = '1020'+str(needX)

line_3D.append(stoppoint)
line_3D.append(line_3D[long-4])
line_3D.append('0'+'\n'+'0'+'\n'+'0'+'\n')

# go to home of 5axis
line_3D.append('2000354.00'+'\n'+'470.049'+'\n'+'0'+'\n'+'0'+'\n'+'0'+'\n')

# start 5 axis
for i in range(len(subline_5D)):
    # 長柱特例
    if i > 0:
        Arotate = float(subline_5D[i][3])-float(subline_5D[i-1][3])
        Crotate = float(subline_5D[i][4])-float(subline_5D[i-1][4])
        if abs(Arotate) >= 50 or abs(Crotate) >= 50:
            X = '2000' + subline_5D[i][0]
            line_3D.append(X)
            for j in range(1,len(subline_5D[i])):
                line_3D.append(subline_5D[i][j])
            x = float(subline_5D[i][0]) + 0.001
            X1 = '2000' + str(x) +'\n'
            line_3D.append(X1)
            for j in range(1,len(subline_5D[i])):
                line_3D.append(subline_5D[i][j])
        else:
            for j in range(len(subline_5D[i])):
                if j == 0:
                    X = '2030' + subline_5D[i][0]
                    line_3D.append(X)
                else:
                    line_3D.append(subline_5D[i][j])
            
    elif i ==0:
        for j in range(len(subline_5D[i])):
            if j == 0:
                X = '2030' + subline_5D[i][0]
                line_3D.append(X)
            else:
                line_3D.append(subline_5D[i][j])
    '''
    if i%5 ==0 and i > 4:
        Arotate = float(line_5D[i+3])-float(line_5D[i-2])
        Crotate = float(line_5D[i+4])-float(line_5D[i-1])
        if Arotate >= 50 or Crotate >= 50:
            X = '2000' + line_5D[i]
            line_3D.append(X)
        else:
            X = '2040' + line_5D[i]
            line_3D.append(X)
    elif i == 0:
        X = '2040' + line_5D[i]
        line_3D.append(X)
    else:
        line_3D.append(line_5D[i])
    '''

# add zero at the end
for i in range(10):
    line_3D.append(str(0) +'\n')
    
with open("5axis.txt", 'w') as f:
    for item in line_3D:
        f.write(str(item))
