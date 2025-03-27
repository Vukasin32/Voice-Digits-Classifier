function [a,s] = estimate_LPC(rxx)
  p = (length(rxx)-1)/2;
  R = toeplitz(rxx(p+1:2*p),rxx((p+1):-1:2));
  a = -R\rxx(p+2:end); % deljenje matrica, mnozenje sa -1
  s = rxx(p+1) + sum(a.*rxx(p:-1:1));
  a = [1 transpose(a)];
end

