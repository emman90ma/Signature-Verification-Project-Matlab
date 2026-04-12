function [val,im_pro] = SignatureProjectFuntion(I)
I2=imresize(I,[512 ,512]);
I3=rgb2gray(I2);
I3=im2double(I3);
I3 = imbinarize(I3,'adaptive','ForegroundPolarity','dark','Sensitivity',0.40);                    
I3 = bwmorph(~I3, 'thin', inf);                 
I3=~I3;
I3=~bwareaopen(~I3,4);
im1 = I3;

%extracting the black pixels
k=1;
for i=1:512
    for j=1:512
        if(I3(i,j)==0)
            u(k)=i;
            v(k)=j;
            k=k+1;
            I3(i,j)=1;
        end
    end
end

C=[u;v];
N=k-1;%the number of pixels in the signature

oub=sum(C(1,:))/N;   
ovb=sum(C(2,:))/N;  


%%****ROTATE****%%
for i=1:N
    u(i)=u(i)-oub+1;
    v(i)=v(i)-ovb+1;
end
% new curve
C=[u;v];
ub=sum(C(1,:))/N;
vb=sum(C(2,:))/N;
ubSq=sum((C(1,:)-ub).^2)/N;
vbSq=sum((C(2,:)-vb).^2)/N;
 
for i=1:N
    uv(i)=u(i)*v(i);
end
uvb=sum(uv)/N;
M=[ubSq uvb;uvb vbSq];

minIgen=min(abs(eig(M)));

MI=[ubSq-minIgen uvb;uvb vbSq-minIgen];
theta=(atan((-MI(1))/MI(2))*180)/pi;
thetaRad=(theta*pi)/180;
rotMat=[cos(thetaRad) -sin(thetaRad);sin(thetaRad) cos(thetaRad)];

%% rotating the signature passing the new coordinates
for i=1:N
    v(i)=(C(2,i)*cos(thetaRad))-(C(1,i)*sin(thetaRad));
    u(i)=(C(2,i)*sin(thetaRad))+(C(1,i)*cos(thetaRad));
end
C=[u;v];

for i=1:N
    u(i)=round(u(i)+oub-1);
    v(i)=round(v(i)+ovb-1);
end
%boundry 128x128 and move signature curve  
mx=0;
my=0;
if (min(u)<0)
    mx=-min(u);
    for i=1:N
        u(i)=u(i)+mx+1;
    end
end
if (min(v)<0)
    my=-min(v);
    for i=1:N
        v(i)=v(i)+my+1;
    end
end
C=[u;v];
for i=1:N
    I3((u(i)),(v(i)))=0;
end


% removing white space
xstart=512;
xend=1;
ystart=512;
yend=1;
for r=1:512
    for c=1:512
        if((I3(r,c)==0))
            if (r<ystart)
                ystart=r;
            end
            if((r>yend))
                yend=r; 
            end
            if (c<xstart)
                xstart=c;
            end
            if (c>xend)
                xend=c;
            end     
       end  
    end
end


for i=ystart:yend
    for j=xstart:xend
        im((i-ystart+1),(j-xstart+1))=I3(i,j);
    end
end
im_pro = im;



PixelB = 0;
PixelA = 0;
for i=ystart:yend
    for j=xstart:xend
        if (im(i-ystart+1,j-xstart+1)== 0)
            PixelB = PixelB + 1;
        end
        PixelA = PixelA + 1;
    end
end

NSA = PixelB/PixelA;

% Aspect Ratio 

height_sign = yend-ystart;
length_sign = xend-xstart;
aspect_ratio = length_sign/height_sign;

% Maximum Horizontal and Vertical Projection

max=0;

for i=ystart:yend
    summ=0;
    for j=xstart:xend
        if(im((i-ystart+1),(j-xstart+1))==0)
            summ=summ+1;
        end
    end
    if (summ>max)
        max=summ;
    end
end
max;
max1=0;
for i=xstart:xend
    summ=0;
    for j=ystart:yend
        if(im((j-ystart+1),(i-xstart+1))==0)
            summ=summ+1;
        end
    end
    if (summ>max1)
        max1=summ;
    end
end
max1;
xdiff=xend-xstart;
ydiff=yend-ystart;

Hor_Proj = max/xdiff;
Ver_Proj = max1/ydiff;



i1 = im1;
[row, col, depth] = size(i1);

addrow = ones(1, col);
i1 = [addrow; addrow; i1; addrow];
[row, col, depth] = size(i1);

addcol = ones(row, 1);
i1 = horzcat(addcol, i1, addcol, addcol);
[row, col, depth] = size(i1);
i1=~i1;
crosspoints=0;
 for r = 3:row-1
        for c = 2:col-2
            if(i1(r,c)==1)
                if (i1(r-1,c-1)+i1(r-1,c)+i1(r-1,c+1)+i1(r,c-1)+i1(r,c+1)+i1(r+1,c-1)+i1(r+1,c)+i1(r+1,c+1)==1)
                    crosspoints=crosspoints+1;
                  
                end
            end
        end
 end


n1 = im(:, 1: xdiff/2);    %splitting images
n2 = im(:,  xdiff/2+1:xdiff);


sum1=0;
pix_total=0;

for i=1:ydiff
    pix_sum=0;
    for j=1:xdiff/2
       if(n1(i,j)==0)
           pix_sum=pix_sum+1;
           pix_total=pix_total+1;
       end
    end
    sum1=sum1+(pix_sum*i);
end
Y1=sum1/pix_total;
RY1=Y1/ydiff;
sum1=0;
for i=1:xdiff/2
    pix_sum=0;
    for j=1:ydiff
       if(n1(j,i)==0)
           pix_sum=pix_sum+1;
       end
    end
    sum1=sum1+(pix_sum*i);
end
X1=sum1/pix_total;
RX1=2*X1/xdiff;

sum1=0;
pix_total=0;
for i=1:ydiff
    pix_sum=0;
    for j=1:xdiff/2
       if(n2(i,j)==0)
           pix_sum=pix_sum+1;
           pix_total=pix_total+1;
       end
    end
    sum1=sum1+(pix_sum*i);
end
Y2=sum1/pix_total;
RY2=Y2/ydiff;
sum1=0;
for i=1:xdiff/2
    pix_sum=0;
    for j=1:ydiff
       if(n2(j,i)==0)
           pix_sum=pix_sum+1;
       end
    end
    sum1=sum1+(pix_sum*i);
end
X2=sum1/pix_total;
RX2=2*X2/xdiff;

centroid = [ [RX1 RY1] [RX2 RY2] ];
% Slope 

m=xdiff;
m=m/2;
k=m+X2;
slope=(Y2-Y1)/(k-X1);

val = [ NSA aspect_ratio Hor_Proj crosspoints centroid slope];

end
