clc
clear all
%% Load File
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
for i = 1:intMaxLayer
    plot3(XYZGcode(1: XYZGcodeIndex(i),1,i),XYZGcode(1:XYZGcodeIndex(i),2,i),XYZGcode(1:XYZGcodeIndex(i),3,i))
    hold on
end
LayerHeight = XYZGcode(1,3,2) -  XYZGcode(1,3,1);
LayerWidth = 0.5;
%% Calculate Intersection Points
dim1 = 2;
if (dim==1)
    dim2 = 2;
else
    dim2 = 1;
end
interval = LayerWidth;
% MinY = min(XYZGcode(1:XYZGcodeIndex(1),dim,1))+interval;
MinY = min(XYZGcode(1:XYZGcodeIndex(1),dim1,1));
% MaxY = max(XYZGcode(1:XYZGcodeIndex(1),dim,1))-interval;
MaxY = max(XYZGcode(1:XYZGcodeIndex(1),dim1,1));
Sp = MinY:interval:MaxY;
intPointsG = zeros(1,3,length(Sp));
intPointsNumG = zeros(1,length(Sp));
for j = 1:length(Sp)
% for j = 188:188
    Y = Sp(j);
    intPoints = zeros(1,3);
    intPointsNum = 0;
    for i = 1:intMaxLayer
%     for i = 1:1
        if((max(XYZGcode(1:XYZGcodeIndex(i),dim1,i))>=Y)&&(min(XYZGcode(1:XYZGcodeIndex(i),dim1,i))<=Y))
            resPoints = findintersection(XYZGcode(1:XYZGcodeIndex(i),1:2,i),Y,dim1);
            resPoints = [resPoints, ones(size(resPoints,1),1)*XYZGcode(1,3,i)];
            intPoints((intPointsNum+1):(intPointsNum+size(resPoints,1)),:) = resPoints;
            intPointsNum = intPointsNum + size(resPoints,1);
        end
    end
%     if(dim==1)
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
%         [a b] = sort(intPoints(:,2));
%     else
%         [a b] = sort(intPoints(:,1));
%     end
    intPointsG(1:intPointsNum,1:3,j) = temPoints;
    intPointsNumG(j) = intPointsNum;
end

for i = 1:length(Sp)
    plot3(intPointsG(1: intPointsNumG(i),1,i),intPointsG(1:intPointsNumG(i),2,i),intPointsG(1:intPointsNumG(i),3,i))
    hold on
end
xlabel('x');
ylabel('y');
%% Trajectory
[a mini] = min(XYZGcode(1:XYZGcodeIndex(1),dim1,1));
[a maxi] = max(XYZGcode(1:XYZGcodeIndex(1),dim1,1));
% totalPointsNum = sum(intPointsNumG) + 2;
% trajectory = zeros(totalPointsNum,3);
% trajectory(1,:) = XYZGcode(mini,:,1);
% trajectory(totalPointsNum,:) = XYZGcode(maxi,:,1);
totalPointsNum = sum(intPointsNumG);
trajectory = zeros(totalPointsNum,3);
k = 1;
n = 1;
for j = 1:length(Sp)
    if(k==1)
        trajectory(n:(n+intPointsNumG(j)-1),:) = intPointsG(1:intPointsNumG(j),:,j);
        k=-1;
        n = n + intPointsNumG(j);
    else
        trajectory(n:(n+intPointsNumG(j)-1),:) = intPointsG(intPointsNumG(j):-1:1,:,j);
        k=1;
        n = n + intPointsNumG(j);
    end
end
figure,
plot3(trajectory(:,1),trajectory(:,2),trajectory(:,3));
hold on
xlabel('x');
ylabel('y');
%% Normal Direction
angleRoll= zeros(size(intPointsG,1),size(intPointsG,3));
angleYaw = zeros(size(intPointsG,1),size(intPointsG,3));
newPoint = zeros(size(intPointsG,1),3,j);
%Edge1
j = 1;
if(intPointsNumG(j)==1)
    i = 1;
    if(dim1==1)
        newPoint(i,:,j) = intPointsG(i,:,j) + [LayerWidth 0 0];
        angleRoll(i,j) = 90;
        angleYaw(i,j) = -90;
    else
        newPoint(i,:,j) = intPointsG(i,:,j) + [0 LayerWidth 0]; 
        angleRoll(i,j) = -90;
        angleYaw(i,j) = -90;
    end
else
    for i = 1:(intPointsNumG(j)-1)
        p1 = intPointsG(i,:,j);
        p2 = intPointsG(i+1,:,j);
        [a b] = min(pdist2(intPointsG(1:intPointsNumG(j),:,j+1),intPointsG(i,:,j)));
        p3 = intPointsG(b,:,j+1);
        [newPoint(i,:,j),angleRoll(i,j),angleYaw(i,j)] = findnormal(p1,p2,p3,dim1,LayerHeight);
    end
    i = intPointsNumG(j);
    p1 = intPointsG(i,:,j);
    p2 = intPointsG(i-1,:,j);
    [a b] = min(pdist2(intPointsG(1:intPointsNumG(j),:,j+1),intPointsG(i,:,j)));
    p3 = intPointsG(b,:,j+1);
    [newPoint(i,:,j),angleRoll(i,j),angleYaw(i,j)] = findnormal(p1,p2,p3,dim2,LayerHeight);
end
%
for j = 2:(length(Sp)-1)
    for i = 1:(intPointsNumG(j)-1)
        p1 = intPointsG(i,:,j);
        p2 = intPointsG(i+1,:,j);
        [a b] = min(pdist2(intPointsG(1:intPointsNumG(j),:,j+1),intPointsG(i,:,j)));
        p3 = intPointsG(b,:,j+1);
        [newPoint(i,:,j),angleRoll(i,j),angleYaw(i,j)] = findnormal(p1,p2,p3,dim1,LayerHeight);
    end
    i = intPointsNumG(j);
    p1 = intPointsG(i,:,j);
    p2 = intPointsG(i-1,:,j);
    [a b] = min(pdist2(intPointsG(1:intPointsNumG(j),:,j+1),intPointsG(i,:,j)));
    p3 = intPointsG(b,:,j+1);
    [newPoint(i,:,j),angleRoll(i,j),angleYaw(i,j)] = findnormal(p1,p2,p3,dim2,LayerHeight);
end
%Edge 2
if(intPointsNumG(j)==1)
    i = 1;
    if(dim==1)
        newPoint(i,:,j) = intPointsG(i,:,j) + [LayerWidth 0 0];
        angleRoll(i,j) = -90;
        angleYaw(i,j) = 90;
    else
        newPoint(i,:,j) = intPointsG(i,:,j) + [0 LayerWidth 0]; 
        angleRoll(i,j) = 90;
        angleYaw(i,j) = 90;
    end
else
    j = length(Sp);
    for i = 1:(intPointsNumG(j)-1)
        p1 = intPointsG(i,:,j);
        p2 = intPointsG(i+1,:,j);
        [a b] = min(pdist2(intPointsG(1:intPointsNumG(j),:,j-1),intPointsG(i,:,j)));
        p3 = intPointsG(b,:,j-1);
        [newPoint(i,:,j),angleRoll(i,j),angleYaw(i,j)] = findnormal(p1,p2,p3,dim2,LayerHeight);
     end
    i = intPointsNumG(j);
    p1 = intPointsG(i,:,j);
    p2 = intPointsG(i-1,:,j);
    [a b] = min(pdist2(intPointsG(1:intPointsNumG(j),:,j-1),intPointsG(i,:,j)));
    p3 = intPointsG(b,:,j-1);
    [newPoint(i,:,j),angleRoll(i,j),angleYaw(i,j)] = findnormal(p1,p2,p3,dim1,LayerHeight);
end

TN = size(trajectory,1);
trajectory2 = zeros(TN,5);
% trajectory2(1,:) = [trajectory(1,:),-90,-90];
% trajectory2(TN,:) = [trajectory(TN,:),90,90];
k = 1;
n = 1;
for j = 1:length(Sp)
    if(k==1)
%         trajectory2(n:(n+intPointsNumG(j)-1),:) = [intPointsG(1:intPointsNumG(j),:,j),angleRoll(1:intPointsNumG(j),j),angleYaw(1:intPointsNumG(j),j)];
        trajectory2(n:(n+intPointsNumG(j)-1),:) = [newPoint(1:intPointsNumG(j),:,j),angleRoll(1:intPointsNumG(j),j),angleYaw(1:intPointsNumG(j),j)];
        k=-1;
        n = n + intPointsNumG(j);
    else
%         trajectory2(n:(n+intPointsNumG(j)-1),:) = [intPointsG(intPointsNumG(j):-1:1,:,j),angleRoll(intPointsNumG(j):-1:1,j),angleYaw(intPointsNumG(j):-1:1,j)];
        trajectory2(n:(n+intPointsNumG(j)-1),:) = [newPoint(intPointsNumG(j):-1:1,:,j),angleRoll(intPointsNumG(j):-1:1,j),angleYaw(intPointsNumG(j):-1:1,j)];
        k=1;
        n = n + intPointsNumG(j);
    end
end
figure,
plot3(trajectory2(:,1),trajectory2(:,2),trajectory2(:,3));
hold on

%邊緣面加強
edge1traj = zeros(1,3);
if(intPointsNumG(1)>1)
    if(dim1==1)
        minp1 = min(intPointsG(1:intPointsNumG,2,1))-interval;
        minp2 = max(intPointsG(1:intPointsNumG,2,1))+interval;
        Sp2 = minp1:interval:minp2;
        
         Y = Sp(j);
    intPoints = zeros(1,3);
    intPointsNum = 0;
    for i = 1:intMaxLayer
%     for i = 1:1
        if((max(XYZGcode(1:XYZGcodeIndex(i),dim1,i))>=Y)&&(min(XYZGcode(1:XYZGcodeIndex(i),dim1,i))<=Y))
            resPoints = findintersection(XYZGcode(1:XYZGcodeIndex(i),1:2,i),Y,dim1);
            resPoints = [resPoints, ones(size(resPoints,1),1)*XYZGcode(1,3,i)];
            intPoints((intPointsNum+1):(intPointsNum+size(resPoints,1)),:) = resPoints;
            intPointsNum = intPointsNum + size(resPoints,1);
        end
    end
        
        
        for i = 1:length(Sp2)
        end
    else
    end
end




%%
% wFile = ['w',strLoadFile];
% f2 = fopen(wFile,'w');
% for t = 1:TN
%     fprintf(f2,'%g\r\n%g\r\n%g\r\n%g\r\n%g\r\n',trajectory2(t,1),trajectory2(t,2),trajectory2(t,3),trajectory2(t,4),trajectory2(t,5));
% end
% % fclose('all');
%% Movie
% clear M
% for j = 1:length(Yp)
for j = 1:1
    plot3(trajectory(:,1),trajectory(:,2),trajectory(:,3));
    hold on
    for i = 1:intPointsNumG(j)
        test = [intPointsG(i,:,j);newPoint(i,:,j)];
        plot3(test(:,1),test(:,2),test(:,3),'r')
    end
%     M(j) = getframe;
    hold off
end
% movie(M, 5);
% movie2avi(M,'test.avi','FPS',20);