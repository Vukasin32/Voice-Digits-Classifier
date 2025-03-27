function rxx = autocorrelation(x,p)
  N = length(x);
  rxx = zeros(2*p+1,1);
  for k = (p+1):(2*p+1)
    rxx(k) = sum(conj(x(1:(N-k+p+1))).*x((1+k-(p+1)):N))/N;
  end
  
  rxx(p:-1:1) = conj(rxx(p+2:end)); 
end
