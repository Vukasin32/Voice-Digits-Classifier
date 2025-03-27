function [LPC_kor] = feature_extraction(x,p,win)
N = length(x);
num = round(length(x)/win); % koliko celih prozora staje
LPC_kor = zeros(p+1,num); k = 1;
for i=1:win:(length(x)-win)
    xw = x(i:(i+win-1)); 
    rxx = autocorrelation(xw,p);
    [a1,s1] = estimate_LPC(rxx); 
    LPC_kor(:,k) = a1';
    k = k+1;
end