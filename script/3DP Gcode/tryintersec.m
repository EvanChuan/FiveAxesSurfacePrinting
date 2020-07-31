clc
clear all
%%
strLoadFile = 'shell.txt';
f = fopen(strLoadFile,'r');
cellFile = textread(strLoadFile,'%s');
intMaxLayer = 0;
LayerIndex = zeros(1);
for i = 1:length(cellFile)
   if(~isempty(findstr(cellFile{i},'LAYER')))
       intMaxLayer = intMaxLayer+1;
       LayerIndex(intMaxLayer) = i;
   end
end
fclose('all');
XYZGcode = zeros(1,3,1);
XYZGcodeIndex = zeros(1);
for i = 1:intMaxLayer
    gn0 = 0;
    jstart = LayerIndex(i);
    if i<intMaxLayer
        jend = LayerIndex(i+1)-1;
    else
        jend = length(cellFile);
    end
    j = jstart+1;
    while(j<=jend)
        gn0 = gn0+1;
        XYZGcode(gn0,1:3,i) = [str2num(cellFile{j+1}(2:length(cellFile{j+1}))),str2num(cellFile{j+2}(2:length(cellFile{j+2}))),str2num(cellFile{j+3}(2:length(cellFile{j+3})))];
        j = j+4;   
    end
    XYZGcodeIndex(i) = gn0;
end
figure(1),
set(gca,'FontWeight','bold','fontsize',14)
for i = 1:intMaxLayer
    plot3(XYZGcode(1: XYZGcodeIndex(i),1,i),XYZGcode(1:XYZGcodeIndex(i),2,i),XYZGcode(1:XYZGcodeIndex(i),3,i))
    hold on
end
xlabel('x','fontsize',14);
ylabel('y','fontsize',14);
zlabel('z','fontsize',14);
LayerHeight = 0.5;
%LayerHeight = XYZGcode(1,3,2) -  XYZGcode(1,3,1);
LayerWidth = 0.4; % equal layer height
%%
dim1 = 2
interval = LayerWidth;
MinY = min(XYZGcode(1:XYZGcodeIndex(1),dim1,1));
MaxY = max(XYZGcode(1:XYZGcodeIndex(1),dim1,1));
Sp = MinY:interval:MaxY;
intPointsG = zeros(1,3,length(Sp));
intPointsNumG = zeros(1,length(Sp));

for j = 1:length(Sp)
    Y = Sp(j);   % y value
    intPoints = zeros(1,3);
    intPointsNum = 0;
    for i = 1:intMaxLayer
        MAX_ch = max(XYZGcode(1:XYZGcodeIndex(i),dim1,i))
        MIN_ch = min(XYZGcode(1:XYZGcodeIndex(i),dim1,i))
        if((max(XYZGcode(1:XYZGcodeIndex(i),dim1,i))>=Y)&&(min(XYZGcode(1:XYZGcodeIndex(i),dim1,i))<=Y))
            %resPoints = findintersection(XYZGcode(1:XYZGcodeIndex(i),1:2,i),Y,dim1);
            printedPoints = XYZGcode(1:XYZGcodeIndex(i),1:2,i)
            intPoint = Y
            dim = dim1
            
            originalPoints = [printedPoints; printedPoints(1,:)];
            intState = 0;
            intnumber = 0;
            intSecPointNum = 0;
            intSecPoints = zeros(1,2);
            for t = 1:size(originalPoints,1)
                k = originalPoints(t,dim) - intPoint;
                if (intState==0)
                    if(k<0)
                        intState = -1;
                    elseif(k>0)
                        intState = 1;
                    else
                        intState = 0;
                        intSecPointNum = intSecPointNum + 1;
                        intSecPoints(intSecPointNum,:)  = originalPoints(t,:);
                    end
                else
                    if(k*intState<0)
                        intSecPointNum = intSecPointNum + 1;
                        intState = intState*-1;
                        if(dim == 1)
                            x = intPoint;
                            y = ((originalPoints(t,2)-originalPoints(t-1,2))*x + (originalPoints(t-1,2)*originalPoints(t,1)-originalPoints(t-1,1)*originalPoints(t,2)))/(originalPoints(t,1)-originalPoints(t-1,1));
                            intSecPoints(intSecPointNum,:) = [x,y];
                        else
                            y = intPoint;
                            x = ((originalPoints(t,1)-originalPoints(t-1,1))*y - (originalPoints(t-1,2)*originalPoints(t,1)-originalPoints(t-1,1)*originalPoints(t,2)))/(originalPoints(t,2)-originalPoints(t-1,2));
                            intSecPoints(intSecPointNum,:) = [x,y];
                        end
                    elseif(k==0) && (t ~= size(originalPoints,1))
                        intSecPointNum = intSecPointNum + 1;
                        intSecPoints(intSecPointNum,:)  = originalPoints(t,:);
                    end
                end
                intnumber = k;
            end
            
            resPoints = [intSecPoints, ones(size(intSecPoints,1),1)*XYZGcode(1,3,i)];
            intPoints((intPointsNum+1):(intPointsNum+size(resPoints,1)),:) = resPoints;
            intPointsNum = intPointsNum + size(resPoints,1);
        end
    end
    temPoints = zeros(size(intPoints));
    subPoint = pdist2(intPoints,intPoints);
    temPoints(1,:) = intPoints(1,:);
    subPoint(:,1) = -1;
    n1 = 1;
    k1 = 1;
    for k = 2:1:intPointsNum
        A = find(subPoint(k1,:)>0);
        [a b] = min(subPoint(k1,A));
        k2 = A(b);
        subPoint(:,k2) = -1;
        n1 = n1+1;
        k1 = k2;
        temPoints(n1,:) = intPoints(k2,:);
    end
    intPointsG(1:intPointsNum,1:3,j) = temPoints;
    intPointsNumG(j) = intPointsNum;
end
% figure(2),
% for i = 1:length(Sp)
%     plot3(intPointsG(1: intPointsNumG(i),1,i),intPointsG(1:intPointsNumG(i),2,i),intPointsG(1:intPointsNumG(i),3,i))
%     hold on
% end