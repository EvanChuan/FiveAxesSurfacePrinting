function intersectionPoints =  findintersection(printedPoints,intPoint,dim)
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
%         elseif(
        end
    end
    intnumber = k;
end
intersectionPoints = intSecPoints;