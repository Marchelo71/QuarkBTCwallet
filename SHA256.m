function HASH_hex=SHA56(messag,hex_bin)

% HASH_hex=SHA56(messag,hex_bin)
%
% Example:
%         HASH_hex=SHA56('12589F2EA7',16)
%
%         messag    is the message to be digested by the SHA256
%         hex_bin   can be 2 or 16, by default is 16:   HASH_hex=SHA56('12589F2EA7')
%
%         HASH_hex  The output, the HASH SHA256 of the message, is provided in hex
%
% All the algorithm is performed in native Matlab operations. No java or
% python libraries imported. It should work in any Matlab version (out of
% date or actual)


%Default input message is introduced in hex
if nargin==1;hex_bin=16;
end 


% Adapting the input (hex or bin) to bin to start the HASH256
if hex_bin==16; %% Change to bin (if entry is hex)
    messag=hex2bin(messag);
elseif hex_bin==2% Add initial zeros so that length is multiple to 8  bits
    Nzeros(1:8.*ceil(length(messag)/8)-length(messag))='0';messag=[Nzeros messag];
end


%%% Custom function to read H1 to H8 and Kj (at the end of this file)
[H,Kj]=read_HKj;
%%% Custom function to prepare the N*512 bits message blocks (at the end of this file)
[M,Nblocks]=prepare_message(messag);


for i=1:Nblocks%%%%%%%%%%%%%%%%% SO LET'S START HASHING  %%%%%%%%%%%%%
a=H(1,:);      b=H(2,:);    c=H(3,:);      d=H(4,:);
e=H(5,:);      f=H(6,:);    g=H(7,:);      h=H(8,:);
    
 for j=1:64%%% Hasheamos cada bloque de 512bits obteniendo su Hash de 256bits
   
    if j<17
        W(j,:)=M(j,:);   
    else;   S7 =circshift(W(j-15,:),[0 7 ]);
            S18=circshift(W(j-15,:),[0 18]);
            R3 =circshift(W(j-15,:),[0 3 ]); R3(1:3)=0;
        sig0=xor(xor(S7,S18),R3);  %Wj-15
        
            S17=circshift(W(j-2,:),[0 17]);
            S19=circshift(W(j-2,:),[0 19]);
            R10=circshift(W(j-2,:),[0 10]); R10(1:10)=0;
        sig1=xor(xor(S17,S19),R10);%Wj-2
        
        W(j,:)=sum32(sum32(sig1,W(j-7,:)),sum32(sig0,W(j-16,:)));
    end
    
    chefg =xor(  e.*f,  (1-e).*g  );
    Majabc=xor(xor(a.*b,a.*c),b.*c);
         
         S2 =circshift(a,[0 2]);
         S13=circshift(a,[0 13]);
         S22=circshift(a,[0 22]);
    SIG0=xor(xor(S2,S13),S22);
     
         S6 =circshift(e,[0 6]);
         S11=circshift(e,[0 11]);
         S25=circshift(e,[0 25]);
    SIG1=xor(xor(S6,S11),S25);
    
    T1=sum32(sum32(sum32(h,SIG1),sum32(chefg,Kj(j,:))),W(j,:));
    T2=sum32(SIG0,Majabc);
    
    h=g;    g=f;    f=e;    e=sum32(d,T1);
    d=c;    c=b;    b=a;    a=sum32(T1,T2);
 end
 
 H(1,:)=sum32(H(1,:),a);     H(2,:)=sum32(H(2,:),b);   
 H(3,:)=sum32(H(3,:),c);     H(4,:)=sum32(H(4,:),d);   
 H(5,:)=sum32(H(5,:),e);     H(6,:)=sum32(H(6,:),f);   
 H(7,:)=sum32(H(7,:),g);     H(8,:)=sum32(H(8,:),h);   
end%%%%%%%%%%%%%%%%% Next 512 bits block (if any)

Hash=[H(1,:) H(2,:) H(3,:) H(4,:) H(5,:) H(6,:) H(7,:) H(8,:)];
HASH_hex=bin2hex(Hash);% function bin2hex for big numbers defined in this file
end


%       ADDITIONAL FUNCTIONS


function [H,Kj]=read_HKj
K=['428A2F98';'71374491';'B5C0FBCF';'E9B5DBA5';'3956C25B';'59F111F1';'923F82A4';'AB1C5ED5';
'D807AA98';'12835B01';'243185BE';'550C7DC3';'72BE5D74';'80DEB1FE';'9BDC06A7';'C19BF174';
'E49B69C1';'EFBE4786';'0FC19DC6';'240CA1CC';'2DE92C6F';'4A7484AA';'5CB0A9DC';'76F988DA';
'983E5152';'A831C66D';'B00327C8';'BF597FC7';'C6E00BF3';'D5A79147';'06CA6351';'14292967';
'27B70A85';'2E1B2138';'4D2C6DFC';'53380D13';'650A7354';'766A0ABB';'81C2C92E';'92722C85';
'A2BFE8A1';'A81A664B';'C24B8B70';'C76C51A3';'D192E819';'D6990624';'F40E3585';'106AA070';
'19A4C116';'1E376C08';'2748774C';'34B0BCB5';'391C0CB3';'4ED8AA4A';'5B9CCA4F';'682E6FF3';
'748F82EE';'78A5636F';'84C87814';'8CC70208';'90BEFFFA';'A4506CEB';'BEF9A3F7';'C67178F2'];

H_1_8=['6A09E667';
'BB67AE85';
'3C6EF372';
'A54FF53A';
'510E527F';
'9B05688C';
'1F83D9AB';
'5BE0CD19'];
for j=1:8
  H_j=dec2bin(hex2dec(H_1_8(j,:)));for i=33-length(H_j):32; H(j,i)=str2num(H_j(i-32+length(H_j)));end
end
for j=1:64
  K_j=dec2bin(hex2dec    (K(j,:)));for i=33-length(K_j):32;Kj(j,i)=str2num(K_j(i-32+length(K_j)));end
end
end


function [M,Nblocks]=prepare_message(messag);
%%%% Preparing the N*512 bits initial binary string m512
l=length(messag);lbin=dec2bin(l);
long_(1:64-length(lbin))='0';
long_=[long_ lbin];

Nzeros=512-(l+65-floor((l+64)/512)*512);
zeros_(1,1:Nzeros)='0';

m512=[messag '1' zeros_ long_];for i=1:length(m512);m_512(i)=str2num(m512(i));end
Nblocks=length(m512)/512;

for i=1:16
 for k=1;Nblocks;
  M(i,:,k)=m_512(32*(i-1)+1:32*i);
 end
end
end

 
function [y]=sum32(vi,vj)
base=2;    
s=vi+vj;s=fliplr(s);
%Let's add "with carryover" (in base 2)
carry=0;
for i=1:length(s)
 r=s(i)+carry;  
 y(i)=r-floor(r/base)*base;
 carry=floor(r/base);
end
y=fliplr(y);
end


function HASH_hex=bin2hex(Hash);
    for i=1:256;HH(i)=num2str(Hash(i));
    end
    for k=1:16;HASH_hex=[''];for i=1:16;
      hex_=dec2hex(bin2dec((HH(16*(i-1)+1:16*i))));
      Hashi='0000';Hashi(5-length(hex_):4)=hex_;
      HASH_hex=[HASH_hex Hashi];  
    end;end
end


function y=hex2bin(x);
    if length(x)/2==round(length(x)/2);else;x=['0' x];disp('Hexadecimal string should have an even number of digits')
     disp('It has been completed with a 0 at the beggining');
    end;y=[''];
    for i=1:2:length(x);
        bin_=dec2bin(hex2dec(x(i:i+1)));
        addbin='00000000';addbin(9-length(bin_):8)=bin_;
        y=[y addbin];
    end
end
