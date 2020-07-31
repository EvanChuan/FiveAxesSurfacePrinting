clc
clear all
%% Load File
%strLoadFile = 'shell_1.txt';
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
%% Calculate Intersection Points
dim1 = 2;   % dim1 = 1 X director ; dim1 = 2 y director
if (dim1==1)
    dim2 = 2;
else
    dim2 = 1;
end
interval = LayerWidth;
% MinY = min(XYZGcode(1:XYZGcodeIndex(1),dim,1))+interval;
MinY = min(XYZGcode(1:XYZGcodeIndex(1),dim1,1));
%MinY = -43.861
% MaxY = max(XYZGcode(1:XYZGcodeIndex(1),dim,1))-interval;
MaxY = max(XYZGcode(1:XYZGcodeIndex(1),dim1,1));
Sp = MinY:interval:MaxY;
intPointsG = zeros(1,3,length(Sp));
intPointsNumG = zeros(1,length(Sp));
for j = 1:length(Sp)
    Y = Sp(j);   % y value
    intPoints = zeros(1,3);
    intPointsNum = 0;
    for i = 1:intMaxLayer
        if((max(XYZGcode(1:XYZGcodeIndex(i),dim1,i))>=Y)&&(min(XYZGcode(1:XYZGcodeIndex(i),dim1,i))<=Y))
            resPoints = findintersection(XYZGcode(1:XYZGcodeIndex(i),1:2,i),Y,dim1);
            resPoints = [resPoints, ones(size(resPoints,1),1)*XYZGcode(1,3,i)];
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
figure(2),
for i = 1:length(Sp)
    plot3(intPointsG(1: intPointsNumG(i),1,i),intPointsG(1:intPointsNumG(i),2,i),intPointsG(1:intPointsNumG(i),3,i))
    hold on
end
% plane = [0 0 0; 50 0 0; 50 0 50; 0 0 50]
% mesh(plane)
xlabel('x','fontsize',14);
ylabel('y','fontsize',14);
zlabel('z','fontsize',14);
%% Trajectory 逼瓂格
[a mini] = min(XYZGcode(1:XYZGcodeIndex(1),dim1,1));
[a maxi] = max(XYZGcode(1:XYZGcodeIndex(1),dim1,1));
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
endpoint_ID = k;
figure(3),
plot3(trajectory(:,1),trajectory(:,2),trajectory(:,3));
%axis equal  %糴ゑㄒぃ跑ㄢ禸ㄨ璓
hold on
xlabel('x','fontsize',14);
ylabel('y','fontsize',14);
zlabel('z','fontsize',14);
%% Normal Direction
angleRoll= zeros(size(intPointsG,1),size(intPointsG,3));
angleYaw = zeros(size(intPointsG,1),size(intPointsG,3));
newPoint = zeros(size(intPointsG,1),3,j);
%-----------------Edge1
j = 1;
if(intPointsNumG(j)==1)
    i = 1;
    if(dim1==1)
        newPoint(i,:,j) = intPointsG(i,:,j) + [LayerWidth 0 0];
        angleRoll(i,j) = -90;
        angleYaw(i,j) = 90;
    else
        newPoint(i,:,j) = intPointsG(i,:,j) + [0 LayerWidth 0]; 
        angleRoll(i,j) = -90;
        angleYaw(i,j) = 0;
    end
else
    for i = 1:(intPointsNumG(j)-1)
        p1 = intPointsG(i,:,j);
        p2 = intPointsG(i+1,:,j);
        [a b] = min(pdist2(intPointsG(1:intPointsNumG(j+1),:,j+1),intPointsG(i,:,j)));
        p3 = intPointsG(b,:,j+1);
        [newPoint(i,:,j),angleRoll(i,j),angleYaw(i,j)] = findnormal(p1,p2,p3,dim1,LayerHeight);
    end
    i = intPointsNumG(j);
    p1 = intPointsG(i,:,j);
    p2 = intPointsG(i-1,:,j);
    [a b] = min(pdist2(intPointsG(1:intPointsNumG(j+1),:,j+1),intPointsG(i,:,j)));
    p3 = intPointsG(b,:,j+1);
    [newPoint(i,:,j),angleRoll(i,j),angleYaw(i,j)] = findnormal(p1,p2,p3,dim2,LayerHeight);
end
%-----------------
for j = 2:(length(Sp)-1)
% for j = 2:2
    for i = 1:(intPointsNumG(j)-1)
        p1 = intPointsG(i,:,j);
        p2 = intPointsG(i+1,:,j);
        [a b] = min(pdist2(intPointsG(1:intPointsNumG(j+1),:,j+1),intPointsG(i,:,j)));
        p3 = intPointsG(b,:,j+1);
        [newPoint(i,:,j),angleRoll(i,j),angleYaw(i,j)] = findnormal(p1,p2,p3,dim1,LayerHeight);
    end
    i = intPointsNumG(j);
    p1 = intPointsG(i,:,j);
    p2 = intPointsG(i-1,:,j);
    [a b] = min(pdist2(intPointsG(1:intPointsNumG(j+1),:,j+1),intPointsG(i,:,j)));
    p3 = intPointsG(b,:,j+1);
    [newPoint(i,:,j),angleRoll(i,j),angleYaw(i,j)] = findnormal(p1,p2,p3,dim2,LayerHeight);
end
%-----------------Edge 2
j = length(Sp);
if(intPointsNumG(j)==1)
    i = 1;
    if(dim1==1)
        newPoint(i,:,j) = intPointsG(i,:,j) + [LayerWidth 0 0];
        angleRoll(i,j) = 90;
        angleYaw(i,j) = 90;
    else
        newPoint(i,:,j) = intPointsG(i,:,j) + [0 LayerWidth 0]; 
        angleRoll(i,j) = 90;
        angleYaw(i,j) = 0;
    end
else
    for i = 1:(intPointsNumG(j)-1)
        p1 = intPointsG(i,:,j);
        p2 = intPointsG(i+1,:,j);
        [a b] = min(pdist2(intPointsG(1:intPointsNumG(j-1),:,j-1),intPointsG(i,:,j)));
        p3 = intPointsG(b,:,j-1);
        [newPoint(i,:,j),angleRoll(i,j),angleYaw(i,j)] = findnormal(p1,p2,p3,dim2,LayerHeight);
    end
    i = intPointsNumG(j);
    p1 = intPointsG(i,:,j);
    p2 = intPointsG(i-1,:,j);
    [a b] = min(pdist2(intPointsG(1:intPointsNumG(j-1),:,j-1),intPointsG(i,:,j)));
    p3 = intPointsG(b,:,j-1);
    [newPoint(i,:,j),angleRoll(i,j),angleYaw(i,j)] = findnormal(p1,p2,p3,dim1,LayerHeight);
end
%--------------------------瓂格part
TN = size(trajectory,1);
trajectory2 = zeros(TN,5);
k = 1;
n = 1;
for j = 1:length(Sp)
    if(k==1)
        trajectory2(n:(n+intPointsNumG(j)-1),:) = [intPointsG(1:intPointsNumG(j),:,j),angleRoll(1:intPointsNumG(j),j),angleYaw(1:intPointsNumG(j),j)];
        k=-1;
        n = n + intPointsNumG(j);
    else
        trajectory2(n:(n+intPointsNumG(j)-1),:) = [intPointsG(intPointsNumG(j):-1:1,:,j),angleRoll(intPointsNumG(j):-1:1,j),angleYaw(intPointsNumG(j):-1:1,j)];
        k=1;
        n = n + intPointsNumG(j);
    end
end
figure(4),
plot3(trajectory2(:,1),trajectory2(:,2),trajectory2(:,3));
%axis equal  %糴ゑㄒぃ跑ㄢ禸ㄨ璓
hold on
xlabel('x','fontsize',16);
ylabel('y','fontsize',16);
zlabel('z','fontsize',16);
%--------------------------娩絫眏
edge1traj = zeros(1,3);
%edge1
i=1;
if(intPointsNumG(i)>=1)
    minp1 = min(intPointsG(1:intPointsNumG,dim2,i))+interval;
    minp2 = max(intPointsG(1:intPointsNumG,dim2,i))-interval;
    Sp2 = minp1:interval:minp2;
    edge1PointsG = zeros(1,3);
    edge1PointsNumG = 0;
    k=1;
    for j = 1:length(Sp2)
        Y = Sp2(j);
        resPoints = findintersection(intPointsG(1:intPointsNumG(i),[1,3],i),Y,dim2);
        resPoints = [resPoints(:,1), ones(size(resPoints,1),1)*intPointsG(1,2,i), resPoints(:,2)];
        if(k==-1)
            edge1PointsG((edge1PointsNumG+1):(edge1PointsNumG+size(resPoints,1)),:) = resPoints;
            k=1;
        else
            edge1PointsG((edge1PointsNumG+size(resPoints,1)):-1:(edge1PointsNumG+1),:) = resPoints;
            k=-1;
        end
        edge1PointsNumG = edge1PointsNumG + size(resPoints,1);
    end
end

%edge2
i=length(intPointsNumG);
if(intPointsNumG(i)>1)
    minp1 = min(intPointsG(1:intPointsNumG,dim2,i))+interval;
    minp2 = max(intPointsG(1:intPointsNumG,dim2,i))-interval;
    Sp2 = minp1:interval:minp2;
    edge2PointsG = zeros(1,3);
    edge2PointsNumG = 0;
    k=1;
    for j = 1:length(Sp2)
        Y = Sp2(j);
        resPoints = findintersection(intPointsG(1:intPointsNumG(i),[1,3],i),Y,dim2);
        resPoints = [resPoints(:,1), ones(size(resPoints,1),1)*intPointsG(1,2,i), resPoints(:,2)];
        if(k==-1)
            edge2PointsG((edge2PointsNumG+1):(edge2PointsNumG+size(resPoints,1)),:) = resPoints;
            k=1;
        else
            edge2PointsG((edge2PointsNumG+size(resPoints,1)):-1:(edge2PointsNumG+1),:) = resPoints;
            k=-1;
        end
        edge2PointsNumG = edge2PointsNumG + size(resPoints,1);
    end
end

%------------
plot3(edge1PointsG(:,1),edge1PointsG(:,2),edge1PointsG(:,3))
hold on
plot3(edge2PointsG(:,1),edge2PointsG(:,2),edge2PointsG(:,3))
xlabel('x');
ylabel('y');

te1 = [edge1PointsG, ones(size(edge1PointsG,1),1)*-90, zeros(size(edge1PointsG,1),1)];
%te2 = [edge2PointsG, ones(size(edge1PointsG,1),1)*90, zeros(size(edge1PointsG,1),1)];
if(endpoint_ID == 1)
    te2 = [edge2PointsG, ones(size(edge1PointsG,1),1)*-90, ones(size(edge1PointsG,1),1)*180];
else
    te2 = [edge2PointsG, ones(size(edge1PointsG,1),1)*90, zeros(size(edge1PointsG,1),1)];
end
trajectory3 = [te1(edge1PointsNumG:-1:1,:);trajectory2;te2]; 
figure(5),
plot3(trajectory3(:,1),trajectory3(:,2),trajectory3(:,3));
axis equal
hold on
xlabel('x','fontsize',14);
ylabel('y','fontsize',14);
zlabel('z','fontsize',14);
%%
wFile = ['w',strLoadFile];
f2 = fopen(wFile,'w');
TN = size(trajectory3,1);
for t = 1:TN
    fprintf(f2,'%g\r\n%g\r\n%g\r\n%g\r\n%g\r\n',trajectory3(t,1),trajectory3(t,2),trajectory3(t,3),trajectory3(t,4),trajectory3(t,5));
end
fclose('all');
%% Movie
clear M
% for j = 1:length(Yp)
figure(6),
hold
for j = 1:20 % ソ计璶籔intPointsNumG计秖才
    plot3(trajectory(:,1),trajectory(:,2),trajectory(:,3));
    hold on
    %for i = 1:intPointsNumG(j)
    for i = 1:intPointsNumG(j)
        test = [intPointsG(i,:,j);newPoint(i,:,j)];
        plot3(test(:,1),test(:,2),test(:,3),'r')
    end
%     M(j) = getframe;
    hold off
end
xlabel('x');
ylabel('y');
zlabel('z');
movie(M, 5);
movie2avi(M,'test.avi','FPS',20);

