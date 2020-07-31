clc
clear all
close all


home = input('1.只歸HOME 2.執行： 3.修改變數(ex. M81=-43):')

while(home ~=1 && home ~= 2 && home ~= 3)
    home = input('1.只歸HOME 2.執行： 3.修改變數(ex. M81=-43):')    
end

if(home == 1)
    comNum = input('COM:','s')
    com = ['COM' num2str(comNum)]
    s = serial(com); %assigns the object s to serial port

    set(s, 'InputBufferSize', 1024); %number of bytes in inout buffer
    set(s, 'FlowControl', 'none');
    set(s, 'BaudRate', 38400);
    set(s, 'Parity', 'none');
    set(s, 'DataBits', 8);
    set(s, 'StopBit', 1);
    set(s, 'Timeout', 1);    
    
    fopen(s);           %opens the serial port
    
    fprintf(s,'resplc6');
    disp('resplc6')
    pause(5);
    while(1)
        fprintf(s,'M180');
        data = -1;
        warning('off','MATLAB:serial:fscanf:unsuccessfulRead');
        data = str2num(fscanf(s))
        warning('on','MATLAB:serial:fscanf:unsuccessfulRead'); 
        pause(0.5);
        if (data == 0)
            break;
        end
    end
    pause(5);
    fclose(s);
    
elseif(home==2)

    DNC_start_Flag = true;
    

    %%
    comNum = input('COM:','s')
    com = ['COM' num2str(comNum)]
    s = serial(com); %assigns the object s to serial port
    
    set(s, 'InputBufferSize', 1024); %number of bytes in inout buffer
    set(s, 'FlowControl', 'none');
    set(s, 'BaudRate', 38400);
    set(s, 'Parity', 'none');
    set(s, 'DataBits', 8);
    set(s, 'StopBit', 1);
    set(s, 'Timeout', 1);

    fopen(s);           %opens the serial port
   fprintf(s,'M81=100');
    disp('M81=100')
    
    fprintf(s,'P97=2');
    disp('P97=2')

    pause(5)

    %%

    fid = fopen('rot.txt','r');
    i = 2;
    rotline{1} = fgetl(fid);
    fprintf(s,rotline{1});
    while ischar(rotline{i-1})
        rotline{i} = fgetl(fid);
        disp(rotline{i});
        fprintf(s,rotline{i});
        i = i + 1;
        pause(0.01)
    end


    %%
    fid = fopen('test.txt','r');
    i = 2;
    tline{1} = fgetl(fid);
    while ischar(tline{i-1})
        tline{i} = fgetl(fid);
        i = i + 1;
    end

    num_line = i - 1
    y = num_line;

    fprintf(s,'&1B0R');
    disp('&1B0R')
    pause(5)

    DNCTog_Flag = 1;
    ExeRotEnd = false;
    endoffile_flag = false;

    rem_exe_num = 0;
    m_min_rot_buffer_line = 300;
    m_add_rot_buffer_line = 100;

    cnt = 1;  % total lines 

    while(DNC_start_Flag==true)

        fprintf(s,'M180');
        disp('M180')
        warning('off','MATLAB:serial:fscanf:unsuccessfulRead');
        RunningProgramFlag = str2num(fscanf(s));
        warning('on','MATLAB:serial:fscanf:unsuccessfulRead');
        disp(RunningProgramFlag)
        pause(0.2)

        if(RunningProgramFlag~=0) 
             if((DNCTog_Flag==1) && (ExeRotEnd==false))  
                rem_exe_num = 0;
                fprintf(s,'PR');
                disp('PR')
                warning('off','MATLAB:serial:fscanf:unsuccessfulRead');
                rem_exe_num = str2num(fscanf(s));
                warning('on','MATLAB:serial:fscanf:unsuccessfulRead');
                disp(rem_exe_num)
                %pause(0.2)
                if((rem_exe_num < m_min_rot_buffer_line) && (endoffile_flag==false))
                    fprintf(s,'OPEN ROT');
                    disp('OPEN ROT')
                    motion_prog_line = 0;    
                    while(motion_prog_line < m_add_rot_buffer_line) 
                        if(cnt < num_line)
                            motion_prog_line = motion_prog_line + 1;
                            fprintf(s,tline{cnt}); 
                            disp(cnt)
                            disp(tline{cnt})
                            cnt = cnt + 1;
                            pause(0.01)
                        else           
                            endoffile_flag = true;
                            break;
                        end
                    end
                    fprintf(s,'CLOSE');
                    disp('CLOSE')
                    pause(0.5)            
                end
                pause(0.2) 
            end
        end
        if(endoffile_flag==true && rem_exe_num <= 0)
            ExeRotEnd=true;
            fprintf(s,'CLOSE');
            fprintf(s,'DEL ROT');
            disp('CLOSE')
            disp('DEL ROT')
            break;
        end
    end
    fclose(s);
    
else
    comNum = input('COM:','s')
    com = ['COM' num2str(comNum)]
    s = serial(com); %assigns the object s to serial port

    set(s, 'InputBufferSize', 1024); %number of bytes in inout buffer
    set(s, 'FlowControl', 'none');
    set(s, 'BaudRate', 38400);
    set(s, 'Parity', 'none');
    set(s, 'DataBits', 8);
    set(s, 'StopBit', 1);
    set(s, 'Timeout', 1);    
    
    fopen(s);           %opens the serial port
    
    variable = input('輸入:','s')
    fprintf(s,variable);
    disp(variable)    
    
    fclose(s);
end
