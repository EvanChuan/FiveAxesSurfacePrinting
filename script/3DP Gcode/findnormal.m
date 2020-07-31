function [newpoint,angleroll,angleyaw ] = findnormal(a,b,c,dim,height)
Avector = b-a;
Bvector = c-a;
if(dim==1)
    Cvector = cross(Bvector,Avector)';
else
    Cvector = cross(Avector,Bvector)';
end
Cvector = Cvector./norm(Cvector);
% normalvector = Cvector;

newpoint = a + height*Cvector';
angle2 = asin(abs(Cvector(1))/sqrt(Cvector(1)^2+Cvector(2)^2));
if isnan(angle2)
    angle2 = 0;
elseif(Cvector(1)*Cvector(2)<0)
    angle2 = -angle2;
elseif(Cvector(2)==0)
    angle2 = abs(angle2);
end
angleyaw = angle2/pi*180;

Cvector = [cos(angle2) -sin(angle2) 0;sin(angle2) cos(angle2) 0;0 0 1]*Cvector;
angle1 = asin(Cvector(2)/sqrt(Cvector(2)^2+Cvector(3)^2));
if isnan(angle1)
    angle1 = 0;
end
angleroll = angle1/pi*180;


