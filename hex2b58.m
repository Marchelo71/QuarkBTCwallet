function str58=hex2b58(str16,al_reves)
%
% str58=hex2b58(str16)           str16=hex2b58(str58,-1)          
%
% 
% Converts hexadecimal strings into base 58 strings, like bitcoin addresses
%
% Additionally, prompting a second input (whatever) performs the inverse
% operation.
% 
% The length of the hexadecimal input is not limited by the precission,
% as the string is converted into a vector of numeric values with the
% original string length. The product, quotient and sum operations for
% these numerical vectors are defined, in local functions.
%
% By means of these redefined operations, the conversion to a vector of values
% in base 58 is carried out and, finally, the string in base 58 is obtained
% without errors associated to limited precission 
%
% All the algorithm is written in native Matlab. No java or python 
% libraries imported. It should work in any Matlab version (out of
% date or actual)

% Initializing 
code1= '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
code2='0123456789ABCDEF';
if nargin==1;       for i=1:length(str16);v16(i)=hex2dec(str16(i));
                    end
elseif nargin==2;   for i=1:length(str16);[~,pos]=max(code1==str16(i));v16(i)=pos-1;
                    end
end



%%%%%%%%% Change to base 10 (vector v10) %%%%%%%%%%%%%%%%%%%%
if nargin==1;base=[1 6];else;base=[5 8];end
v10=0;b16i=1;
for i=1:length(v16);
 v10=sum_(v10,prod_(b16i,v16(end+1-i)));
 b16i=prod_(b16i,base);
end;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%% Change to base 58, Shatoshi'style (vector v58) %%%%%%
if nargin==1;       base=[5 8];
else;               base=[1 6];
end        
res_=v10;b58i=1;
i=0;[k,sign_]=sum_(res_,-b58i);
 while sign_>=0;%Find the order n in base 58 (58^n)  
 i=i+1;eval(['F.sub' num2str(i) '=b58i;']);
 b58i=prod_(b58i,base);
 [k,sign_]=sum_(res_,-b58i);
 end
 
 for ii=1:i;%% Solve the conversion to base 58, in the vector v58
 eval(['f=F.sub' num2str(i+1-ii) ';']);
 [y,res_]=div_(res_,f);
  try;y(end)=10*y(end-1)+y(end);end;
 v58(ii)=y(end);
 end
 
 % Output
 if nargin ==1;      str58=code1(v58+1);
 else;               str58=code2(v58+1);   
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end



%%% ADDITIONAL FUNCTIONS    div_   prod_   sum_   


function [y,res_]=div_(vi,vj)
%%%%%%%% Exact division %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
base=10;
vdiv=[vj zeros(1,length(vi)-length(vj)) ];% cajetin actualizado
res_=vi;                  % resto actualizado
paso=0;
 while length(vdiv)>=length(vj);% va avanzando cifras
 i=base;paso=paso+1;
  while i>0% va ensayando divisiones de base-1 a cero
  i=i-1;yy=prod_(vdiv,i);
  [k,sign_]=sum_(res_,-yy);
    if sign_>=0;
    y(paso)=i;i=-5;
    res_=sum_(res_,-yy);%% nuevo resto
    vdiv=vdiv(1:end-1); %% nuevo cajetin
    end
  end
 end%% Finish division
end


function y=prod_(vi,vj)
%%%%%%%%%%%%%%%%%%%%%% Exact product %%%%%%%%%%%%%%%%%%%%%%%%%%%%
base=10;
vi=fliplr(vi);vj=fliplr(vj);
%%% First the product, digit by digit, like in the primary school
for i=1:length(vi);for j=1:length(vj);
 yy(j,i+(j-1))=vi(i)*vj(j);
end;end

%%% Now let's add "with carryover" the columns (in base 10 by default)
carry=0; s=sum(yy,1);
for i=1:size(yy,2)
 r=s(i)+carry;
 y(i)=r-floor(r/base)*base;
 carry=floor(r/base);
end
if carry==0;else;y(i+1)=carry;;end
y=fliplr(y);
end


function [y,sign_]=sum_(vi,vj)
%%%%%%% Exact addition (substraction and comparison) of two inputs %%%%
%
% sign_ returns 1 0 -1 for results of a substractio (comparison) positive,
% zero or negative. Example [y, sign_]=sum_(x3,-x3) returns sign_=0
% y returns the addition 
base=10;
vi=fliplr(vi);        vj=fliplr(vj);
yy(1,1:length(vi))=vi;yy(2,1:length(vj))=vj;

%Let's add "with carryover" (in base 10 by default)
carry=0;s=sum(yy,1);
for i=1:size(yy,2)
 r=s(i)+carry;
 y(i)=r-floor(r/base)*base;
 carry=floor(r/base);
end
if carry==0;else;y(i+1)=carry;
end

%%%% Evaluating the exact sign of the result 1 0 -1
sign_=sum(y.*base.^(0:length(y)-1));
  sign_=sign(y(end));% substraction result has a small flag which is applied to obtain the sign
if sign_==0;sign_=sign(sum(y));
end
y=fliplr(y);
end
