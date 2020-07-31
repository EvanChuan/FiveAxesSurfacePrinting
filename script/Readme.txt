***Describtion of python scripts***

1.gcodeToDNC.py 
	將Cura生成的gcode進行整理，將需要Gcode點filter出來

2.shell_code(orign).py 
	針對gcodeToDNC.py整理的gcode去抽取出外殼的路徑，沒有layer資訊

3.shell_code.py 
	針對gcodeToDNC.py整理的gcode去抽取出外殼的路徑，並保存G和layer

4.genrateQvar.py 
	將gcode整理成Qvariable型式，有加入機台指令與M81速度控制指令，仍是固定的 (已修復bug)

5.genrateQvar_fromAC.py 
	輸入的檔案為已經有AC角度的

6.combine2Q.py
	將兩個部分何在一起進行5軸列印
	修正加入5軸的軌跡，根據長方體的角度過大來判定 <仍需考慮是否通用>

7.Q_Variable.py
	將 genrateQvar.py、genrateQvar_fromAC.py 和 combine2Q.py整合(原先檔案於oldcode file中)，並加入feedrate的變動函數

8.processoffiveaixes.py
	長方柱生成的5軸AC有一點bug，故透過此程式修正，產生5axis檔


***Trajectory Generation Process***
1. 利用gcodeToDNC.py : 將切片的gcode取出需要的部分，產生DNCcode.txt檔
2. 利用shell_code.py : 從DNCcode.txt檔產生外殼shell.txt 要丟入3DPGcode file
3. 3DPGcode file 中生成外殼5軸軌跡 wshell.txt檔

4. 利用genrateQvar.py : 將DNCcode.txt轉成Qvaluable型式的3DQ.txt
5. <長方形特例> 利用processoffiveaixes.py : 將wshell.txt檔整理生成5DQ.txt檔
6. 利用genrateQvar_fromAC.py : 將5DQ.txt檔轉成Qvaluable型式，產生5axisQ.txt
7. 利用combine2Q.py : 生成最終執行的code檔

4~7 可以利用Q_Variable.py直接產生Q_Variable.ini檔，為五軸表面列印軌跡
