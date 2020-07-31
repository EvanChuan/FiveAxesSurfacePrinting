# -*- coding: utf-8 -*-
"""
Created on Sun Sep  1 16:46:30 2019

@author: kofour
"""

# read file and flit
file = open("CFFFP_彈頭1.gcode", "r", encoding="utf-8")
print("文件名稱: ", file.name)
line = file.readlines()

# catch out the needed gcode
Z_height = 0
line_store = []
for i in range(len(line)):
    if line[i][1:6] == "LAYER" or line[i][1:6] == "TYPE:":
        line_store.append(line[i])
    elif line[i][0:2] == "G0":
        z_index = line[i].find('Z')
        if z_index == -1:
            line_store.append(line[i][:-1]+" "+str(Z_height)+"\n")
        else: #儲存Z高度
            Z_height = line[i][int(z_index):-1]
            line_store.append(line[i])
    elif line[i][0:2] == "G1":
        if Z_height != 0:
            try:
                E_index = line[i].find('E')
                line_store.append(line[i][0:int(E_index)]++" "+str(Z_height)+" "+line[i][int(E_index):])
            except:
                line_store.append(line[i]+" "+str(Z_height)+"\n")
file.close()


# transfer to DNC
need_point = []

while len(line_store) != 0:
    process_line = line_store.pop(0)     # 每行自行處理
    if process_line[1:6] == "LAYER" or process_line[1:6] == "TYPE:":
        need_point.append(process_line)
    elif process_line[0] == "G":
        linesplit = process_line.split()
        for i in range(len(linesplit)):
            if linesplit[i][0] == 'G':
                need_point.append(linesplit[i])
            elif linesplit[i][0] == 'X' or linesplit[i][0] == 'Y' or linesplit[i][0] == 'Z':
                need_point.append(linesplit[i])
            #elif linesplit[i][0] == 'F':    噴嘴數度調整
       
# write to file
with open("DNCcode.txt", 'w') as f:
    for item in need_point:
        if item[0] == 'G' or item[0] == 'X' or item[0] == 'Y':
            f.write(item+' ')
        elif item[0] == 'Z':
            f.write(item+'\n')
        else:
            f.write(item)
f.close() 