function Hash = ripemd160(str_hex)

% Hash = ripemd160(str_hex)
% 
% Performs the ripemd160 hashing of the input 'str_hex', that must be 
% a hexadecimal strings, 64 digits long. Output also in hexadecimal


% Shaping the input before start hashing 
str_hex=[str_hex,'8000000000000000000000000000000000000000000000000001000000000000'];
X=hex2dec(fliplr(reshape((fliplr(reshape(str_hex,2,[])')'),8,[])'));

% Reading all the constants, saved in local function read_zsHy
[zl,zr,sl,sr,H,yl,yr]=read_zsHy;
fghkl='fghkl';

% Please don't stop the hash... all hash long...
for i=1:1
    Al=H(1);Bl=H(2);Cl=H(3);Dl=H(4);El=H(5);
    Ar=H(1);Br=H(2);Cr=H(3);Dr=H(4);Er=H(5);
    for jj=1:5
        for j=1:16
            % string 'fghkl' and 'eval' function allow to calculate functions f g h k l attending to the value of jj for 1 to 5
            eval(['Z=mod(El+roll(mod(mod(mod(Al+' fghkl( jj ) '(Bl,Cl,Dl),2^32)+X(zl(jj,j)),2^32)+yl(jj),2^32),sl(jj,j)),2^32);']);
            Al=El;El=Dl;Dl=roll(Cl,10);Cl=Bl;Bl=Z;
            eval(['Z=mod(Er+roll(mod(mod(mod(Ar+' fghkl(6-jj) '(Br,Cr,Dr),2^32)+X(zr(jj,j)),2^32)+yr(jj),2^32),sr(jj,j)),2^32);']);
            Ar=Er;Er=Dr;Dr=roll(Cr,10);Cr=Br;Br=Z;
        end
    end
    Z=H(1);
    H(1)=mod(mod(H(2)+Cl,2^32)+Dr,2^32);H(2)=mod(mod(H(3)+Dl,2^32)+Er,2^32);
    H(3)=mod(mod(H(4)+El,2^32)+Ar,2^32);H(4)=mod(mod(H(5)+Al,2^32)+Br,2^32);
    H(5)=mod(mod(Z+Bl,2^32)+Cr,2^32);
end
Hash=dec2hex(swapbytes(uint32(H)))';
Hash=Hash(:)';
end



function y = roll(y,x)
y=dec2bin(y,32);
y=circshift(y,[0 -x]);
y=bin2dec(y);
end

function y=f(x,y,z)
y=double(bitxor(bitxor(uint32(x),uint32(y)),uint32(z)));
end

function y=g(x,y,z)
y=double(bitor(bitand(uint32(x),uint32(y)),bitand(bitcmp(uint32(x)),uint32(z))));
end

function y=h(x,y,z)
y=double(bitxor(bitor(uint32(x),bitcmp(uint32(y))),uint32(z)));
end

function y=k(x,y,z)
y=double(bitor(bitand(uint32(x),uint32(z)),bitand(uint32(y),bitcmp(uint32(z)))));
end

function y=l(x,y,z)
y=double(bitxor(uint32(x),bitor(uint32(y),bitcmp(uint32(z)))));
end

function [zl,zr,sl,sr,H,yl,yr]=read_zsHy;
zl=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15;...
    7, 4, 13, 1, 10, 6, 15, 3, 12, 0, 9, 5, 2, 14, 11, 8;...
    3, 10, 14, 4, 9, 15, 8, 1, 2, 7, 0, 6, 13, 11, 5, 12;...
    1, 9, 11, 10, 0, 8, 12, 4, 13, 3, 7, 15, 14, 5, 6, 2;...
    4, 0, 5, 9, 7, 12, 2, 10, 14, 1, 3, 8, 11, 6, 15, 13]+1;
zr=[5, 14, 7, 0, 9, 2, 11, 4, 13, 6, 15, 8, 1, 10, 3, 12;...
    6, 11, 3, 7, 0, 13, 5, 10, 14, 15, 8, 12, 4, 9, 1, 2;...
    15, 5, 1, 3, 7, 14, 6, 9, 11, 8, 12, 2, 10, 0, 4, 13;...
    8, 6, 4, 1, 3, 11, 15, 0, 5, 12, 2, 13, 9, 7, 10, 14;...
    12, 15, 10, 4, 1, 5, 8, 7, 6, 2, 13, 14, 0, 3, 9, 11]+1;
sl=[11, 14, 15, 12, 5, 8, 7, 9, 11, 13, 14, 15, 6, 7, 9, 8;...
    7, 6, 8, 13, 11, 9, 7, 15, 7, 12, 15, 9, 11, 7, 13, 12;...
    11, 13, 6, 7, 14, 9, 13, 15, 14, 8, 13, 6, 5, 12, 7, 5;...
    11, 12, 14, 15, 14, 15, 9, 8, 9, 14, 5, 6, 8, 6, 5, 12;...
    9, 15, 5, 11, 6, 8, 13, 12, 5, 12, 13, 14, 11, 8, 5, 6];
sr=[8, 9, 9, 11, 13, 15, 15, 5, 7, 7, 8, 11, 14, 14, 12, 6;...
    9, 13, 15, 7, 12, 8, 9, 11, 7, 7, 12, 7, 6, 15, 13, 11;...
    9, 7, 15, 11, 8, 6, 6, 14, 12, 13, 5, 14, 13, 13, 7, 5;...
    15, 5, 8, 11, 14, 14, 6, 14, 6, 9, 12, 9, 12, 5, 15, 8;...
    8, 5, 12, 9, 12, 5, 14, 6, 8, 13, 6, 5, 15, 13, 11, 11];
H=hex2dec({'67452301','efcdab89','98badcfe','10325476','c3d2e1f0'});

yl=hex2dec({'0','5a827999','6ed9eba1','8f1bbcdc','a953fd4e'});
yr=hex2dec({'50a28be6','5c4dd124','6d703ef3','7a6d76e9','0'});
end
