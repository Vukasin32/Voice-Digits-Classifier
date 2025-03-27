function [x] = preprocessing(y,fs)

Wn = [50 5000-100]/(fs/2); % normalizovani opseg ucestanosti, od 60Hz da bismo izbacili DC komponentu, moze i od 100Hz, posto detektujemo rec, ali za pitch periodu moze biti problem, gornja granica ne moze biti 1
[B, A] = butter(6, Wn, 'bandpass'); 
yf = filter(B, A, y);

wl = fs*20e-3;
E = zeros(size(yf)); % energija
for i = wl:length(yf)
    rng = (i-wl+1) : i-1;
    E(i) = sum(yf(rng).^2); % suma kvadrata prethodnih wl odbiraka
end

ITU = 0.3*max(E); 
ITL = 0.003*max(E);
pocetak_reci = []; 
kraj_reci = [];

for i=2:length(E)
    if (E(i-1)<ITU)&&(E(i)>=ITU) % bila je ispod, a sad je iznad praga!
        pocetak_reci = [pocetak_reci i];
    end
    if (E(i-1)>ITU)&&(E(i)<=ITU)  % bila je iznad, sad je ispod praga!
        kraj_reci = [kraj_reci i];
    end
end

pocetak = pocetak_reci; 
kraj = kraj_reci;

for i=1:length(pocetak)
    pomeranje = pocetak(i);
    while (E(pomeranje)>ITL)
        pomeranje = pomeranje - 1;
    end
    pocetak(i) = pomeranje;
end

for i=1:length(kraj)
    pomeranje = kraj(i);
    while(E(pomeranje)>ITL)
        pomeranje = pomeranje+1;
    end
    kraj(i) = pomeranje;
end

pocetak1(1) = pocetak(1); 
k = 1;
for i=2:length(pocetak)
    if (pocetak(i) ~= pocetak1(k))
        k = k+1;
        pocetak1(k) = pocetak(i);
    end
end
kraj1(1) = kraj(1); 
k = 1;
for i=2:length(kraj)
    if (kraj(i) ~= kraj1(k))
        k = k+1;
        kraj1(k) = kraj(i);
    end
end

a = pocetak1(1); 
b = kraj1(end); 
x = yf(a:b)';
