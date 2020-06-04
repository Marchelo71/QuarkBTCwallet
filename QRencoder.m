function z=QRencoder(msg,plot_it)

% QRencoder(msg)
%
% Displays the QR code containing the message 'msg', up to 58 characters long
% 
% Applies maximum redundancy 'H', mask 4, and versions (size) of QR 4 and 6,
% which are respectivelly optimal for bitcoin address and secret key


%%%%% Preparing the list of bits associated with the mesage %%%%%%%%%%%%
mode_='0100';%bytes mode
n_=dec2bin(length(msg));Os='00000000';Os(9-length(n_):8)=n_;n_=Os;
L_block=9;er_wrd=16;N=33;if length(msg)>34;L_block=15;er_wrd=28;N=41;end
padd_=[''];adpad=['11101100';'00010001'];c=0;
for i=length(msg)+3:4*L_block
  padd_=[padd_ adpad(c+1,:)];c=mod(c+1,2); 
end
x_bin8=[mode_ n_ str2bin(msg) '0000' padd_];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%% Obtaining error code words (Reed Solomon) and interleaving %%%%%%%%
for i=1:length(x_bin8)/8;x_dec(i)=bin2dec(x_bin8(8*(i-1)+1:8*i));end
for i=1:4;
    kk=x_dec(L_block*(i-1)+1:L_block*i);   bloc_i(i,:)=kk;
    kk=reedsolomon(bloc_i(i,:),er_wrd);  err_code(i,:)=kk;
end;all_=[bloc_i';(err_code.*1)']';
x_bin8=dec2bin8(all_(:));               
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%   Drawing the mask. Mask 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[x,y]=meshgrid(1:N+1,1:N+1);z=x.*0;n=N-7;
zmask4=z;Hi=1-[0 0 0 0 1 1 1 0 1 1 0 0 0 1 0];%H4 String format H mask 4
for i=1:N;for j=1:N;
     if xor((mod(-i+3,6)<3),(mod(j,4)<2));zmask4(i,j)=1;
     end
end;end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%% ZIG-ZAGGING: placing bit by bit %%%%%%%%%%%%%%%%%%%%%%
bottom=0;top=N-9;tops=0;up_down=1;zizag=2;c=1;i=N-1;j=0;gromenawer=0;
while i>=0;    
    j=j+up_down;
           
    % Rebounding in top and bottom of the writting area
    if tops==2;top=N;end
    if j>top;    up_down=-up_down;i=i-2;j=j-1;tops=tops+1;end
    if j==bottom;up_down=-up_down;i=i-2;j=j+1;end
    if (i<9)*(j<9);j=j+8;top=N-9;bottom=8;end
    
    % Jumping the intermitent linear patterns
    if i==6;i=i-1;end
    if j==N-6;j=j+up_down;end       

    % Jumping small square botton right
    if (j>4)*(j<10)*(i>n-1)*(i<n+3);j=j+5*up_down;end
    if (j>4)*(j<9)*(i==n-2)*(up_down>0);zizag=1;i=n-2;
       for k=1:4;% Vertical stretch without zigzagging
         c=c+1;z(i,j+k-1)=1-str2num(x_bin8(c-1));
       end;j=j+4;i=i+1;gromenawer=1;
    else;zizag=2;
    end

    % Writting in zigzag with gromenawer effect after small square
    for k=1:zizag;
        c=c+1;signo=(-1)^(c+gromenawer);    i=i+signo;    
        try;z(i,j)=1-str2num(x_bin8(c-1));catch;try;z(i,j)=1-0;end;
        end
    end
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% XOR in matrix mode Matrix z and matriz zmask4
z=1-(zmask4==(1-z));


%%% Drawing the mask and format strings %%%%%%%%%%%%%%%%%%    
z([1:6 8],n-1)=Hi(1:7);         z(9,1:7)=Hi(1:7);
z(9,[n-1 n n+2:N])=Hi(8:15);    z(n+(0:7),n-1)=Hi(8:15);

%%% Drawing the reference patterns %%%%%%%%%%%%%%%%%%%%%%%
% Intermitent lines
z(:,N-6)=1;for i=1:2:N;z(i,N-6)=0;end
z(1+6,:)=1;for i=1:2:N;z(1+6,i)=0;end;z(9,8)=0;
% Small square bottom right
z(n-2+(1:5),4+(1:5))=0;z(n-1+(1:3),5+(1:3))=1;z(n+1,7)=0;
% Three main squares
z(1:8,1:8)=1;z(1:8,n+(0:8))=1;z(n+(0:8),n+(0:8))=1;
n1i=[0 0 n];n2i=[0 n n];
for i=1:3;for j=0:2
 z(n1i(i)+(1+j:7-j),n2i(i)+(1+j:7-j))=mod(j,2);
end;end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%% And FINALLY DIAPLAYING QR!!  %%%%%%%%%%%%%%%%%%%%%%%%
if nargin==1;
    figure;pcolor(x,y,z');axis equal;colormap gray;
    shading flat;try;set(gca,'xtick',[],'ytick',[]);end
end
end




%%%%%%%%%%%%%%%% Additional functions %%%%%%%%%%%%%%%%%%%%
function x_bin=str2bin(x)
% Obtains binary from string with length of the binary 8*
    x=double(x);x_bin=[''];
    for i=1:length(x)
        byt=dec2bin(x(i));Os='';for i=1:8-length(byt);Os(i)='0';end;byt=[Os byt];
        x_bin=[x_bin byt];
    end
end


function x_bin8=dec2bin8(x)
% Obtains binary from hex with length of the binary 8*
    x_bin8=[''];
    for i=1:length(x)
        byt=dec2bin(x(i));x_bin='00000000';x_bin(9-length(byt):8)=byt;
        x_bin8=[x_bin8 x_bin];
    end
end


function [error_code]=reedsolomon(msg,QRversion)

% [error_code]=reedsolomon(msg,QRversion)
%
% Provides the error code words (decimal vector) associated with a message 'msg' (decimal vector)
% shorter than 60 characters . The length of the error_code equals the value of the input QRversion
% The algorithm works with the QR versions 4 (QRversion=16) and 6 (QRversion=28)
%
% To perform the error coding of different QR versions, you can find the associated polynomials
% here https://www.thonky.com/qr-code-tutorial/generator-polynomial-tool

% Choosing the polynomial associated to QR version 4 (16 terms) or 6 (28 terms)
if QRversion==16;%Polynomial in linear form
  x=[1 59 13 104 189 68 209 30 8 163 65 41 229 98 50 36 59];
else;
  x=[1 252 9 28 13 18 251 208 150 103 174 100 41 167 12 247 56 117 119 233 127 181 100 121 147 176 74 58 197];
end


% Adapting the inputs to perform the polynomial long division y/x (msg/polynomial)
x_exp=tlog(2,x);L=length(x);
y=[msg zeros(1,length(x))];

% Performing polynomial long division to obtain the remainder (the error code)
re_i=y;re_expi=tlog(2,y(1));i=0;
while i<length(y)-L;i=i+1;
    x_expi=mod(re_expi+x_exp,255);  x_i=tlog(1,x_expi);
    xor_it=bitxor(re_i(1:L),x_i);
    re_i=[xor_it(2:end) y(L+i)];    re_expi=tlog(2,re_i(1));
    if (re_i(1)==0)*(i<length(y)-L);i=i+1;
      re_i=[re_i(2:end) y(L+i)];    re_expi=tlog(2,re_i(1));
    end
end
error_code=re_i(1:L-1);
end


function  lg_antlg=tlog(i,x);
%%%%%% Table log antilog, and correction exception for index 0 -->(index 255) %%%%
x=x+(x==0).*255; 
% First row is 2 to the power of the index (antilog) (Galois field mod 285)
tabla_log=[2 4 8 16 32 64 128 29 58 116 232 205 135 19 38 76 152 45 90 180 117 234 201 143 3 6 12 24 48 96 192 157 39 78 156 37 74 148 53 106 212 181 ...
119 238 193 159 35 70 140 5 10 20 40 80 160 93 186 105 210 185 111 222 161 95 190 97 194 153 47 94 188 101 202 137 15 30 60 120 240 253 231 ...
211 187 107 214 177 127 254 225 223 163 91 182 113 226 217 175 67 134 17 34 68 136 13 26 52 104 208 189 103 206 129 31 62 124 248 237 199 ... 
147 59 118 236 197 151 51 102 204 133 23 46 92 184 109 218 169 79 158 33 66 132 21 42 84 168 77 154 41 82 164 85 170 73 146 57 114 228 213 ... 
183 115 230 209 191 99 198 145 63 126 252 229 215 179 123 246 241 255 227 219 171 75 150 49 98 196 149 55 110 220 165 87 174 65 130 25 50 ... 
100 200 141 7 14 28 56 112 224 221 167 83 166 81 162 89 178 121 242 249 239 195 155 43 86 172 69 138 9 18 36 72 144 61 122 244 245 247 243 ...
251 235 203 139 11 22 44 88 176 125 250 233 207 131 27 54 108 216 173 71 142 1];
% Second row is log(base2) of the index  (Galois field mod 285)
tabla_log(2,:)=[0 1 25 2 50 26 198 3 223 51 238 27 104 199 75 4 100 224 14 52 141 239 129 28 193 105 248 200 8 76 113 5 138 101 47 225 36 15 33 53 147 142 ...
218 240 18 130 69 29 181 194 125 106 39 249 185 201 154 9 120 77 228 114 166 6 191 139 98 102 221 48 253 226 152 37 179 16 145 34 136 54 208 148 ... 
206 143 150 219 189 241 210 19 92 131 56 70 64 30 66 182 163 195 72 126 110 107 58 40 84 250 133 186 61 202 94 155 159 10 21 121 43 78 212 229 172 ...
115 243 167 87 7 112 192 247 140 128 99 13 103 74 222 237 49 197 254 24 227 165 153 119 38 184 180 124 17 68 146 217 35 32 137 46 55 63 209 91 149 ...
188 207 205 144 135 151 178 220 252 190 97 242 86 211 171 20 42 93 158 132 60 57 83 71 109 65 162 31 45 67 216 183 123 164 118 196 23 73 236 127 ...
12 111 246 108 161 59 82 41 157 85 170 251 96 134 177 187 204 62 90 203 89 95 176 156 169 160 81 11 245 22 235 122 117 44 215 79 174 213 233 230 ...
231 173 232 116 214 244 234 168 80 88 175];

lg_antlg=tabla_log(i,x);
end
