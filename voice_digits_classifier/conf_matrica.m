clear;
close all;
clc;

%% Direktorijumi
baseDir = 'C:\Users\HP PC\Desktop\OUS_FAJLOVI\OPG_DOMACI\zadatak3';
subDirs = {'jedan\', 'cetiri\', 'devet\'};
class_names = {'jedan_', 'cetiri_', 'devet_'};

%% Prozorovanje i procena LPC koeficijenata ---> Baza podataka 
Y = [];
for j = 1:3
    class = class_names{j}; X = [];
    for t = [1:10]
        file_name = sprintf('%s%d.wav', class, t);  
        fullPath = fullfile(baseDir, subDirs{j}, file_name);
        
        [y, fs] = audioread(fullPath);
        t = 0:1/fs:(length(y)-1)/fs;
        x = preprocessing(y,fs); 
        t1 = 0:1/fs:(length(x)-1)/fs;
        if file_name == "jedan_2.wav" % Grafički prikaz cifre 1 pre i nakon predobrade
            figure()
            plot(t,y)
            xlabel('t[s]')
            ylabel('x(t)')
            title('Prikaz izgovorene cifre jedan pre predobrade')
            figure()
            plot(t1,x)
            xlabel('t[s]')
            ylabel('x(t)')
            title('Prikaz izgovorene cifre jedan nakon predobrade')
        end
        win = 20e-3*fs;
        p = 14;
        LPC_kor = feature_extraction(x,p,win); % Ekstrakcija obeležja - LPC koeficijenata
        X = [X; [mean(LPC_kor(2,:)) mean(LPC_kor(3,:)) mean(LPC_kor(4,:)) ...
                 mean(LPC_kor(5,:)) mean(LPC_kor(6,:)) mean(LPC_kor(7,:)) mean(LPC_kor(8,:)) mean(LPC_kor(9,:))]]; ...
            % X predstavlja bazu podataka svih primeraka pojedinačnih klasa. 
            % Uzima se 8 obeležja (LPC koef.) i za svaku sekvencu se čuva srednja vrednost obeležja.
    end
    X = X(~isnan(X));
    X = reshape(X,floorDiv(length(X),8),8);
    Y = [Y; [mean(X(:,1)), mean(X(:,2)), mean(X(:,3)), mean(X(:,4)), ... 
             mean(X(:,5)), mean(X(:,6)), mean(X(:,7)), mean(X(:,8))]];
            % Y predstavlja bazu podataka sa srednjim vrednostima obeležja
            % za svaku klasu pojedinačno.
end

%% Predikcija za trening skup
M_conf = zeros(3,3); problem_files = {}; minimums = [];
for j = 1:3
    class = class_names{j}; X = [];
    for t = 1:10
        file_name = sprintf('%s%d.wav', class, t);
        fullPath = fullfile(baseDir, subDirs{j}, file_name);
        
        [y, fs] = audioread(fullPath); 
        x = preprocessing(y,fs); 
        win = 20e-3*fs;
        p = 14;
        LPC_kor = feature_extraction(x,p,win);

        alfa = [mean(LPC_kor(2,:)) mean(LPC_kor(3,:)) mean(LPC_kor(4,:)) mean(LPC_kor(5,:)) mean(LPC_kor(6,:)) mean(LPC_kor(7,:)) mean(LPC_kor(8,:)) mean(LPC_kor(9,:))];
        test = zeros(1,3); 
        for k = 1:3
            for p = 1:8
                test(k) = test(k) + (Y(k,p) - alfa(1,p)).^2;
            end
        end
        [m, indeks] = min(test);
        if ~any(isnan(test)) && all(alfa ~= 0) 
            if indeks == 1 
               M_conf(j,1) = M_conf(j,1) + 1;
            end
            if indeks == 2     
               M_conf(j,2) = M_conf(j,2) + 1;
            end
            if indeks == 3
               M_conf(j,3) = M_conf(j,3) + 1;
            end  
            minimums = [minimums; m];
        else
            problem_files{end+1} = file_name;
        end
    end
end
fprintf('Odbaceno je %d elemenata iz trening skupa koji nisu prosli proveru.\n', length(problem_files))
disp('Matrica konfuzije za trening:')
M_conf

%% Predikcija za test skup
M_conf = zeros(3,3); problem_files = {}; minimums = [];
for j = 1:3
    class = class_names{j}; X = [];
    for t = 11:15
        file_name = sprintf('%s%d.wav', class, t);
        fullPath = fullfile(baseDir, subDirs{j}, file_name);
        
        [y, fs] = audioread(fullPath); 
        x = preprocessing(y,fs); 
        win = 20e-3*fs;
        p = 14;
        LPC_kor = feature_extraction(x,p,win);

        alfa = [mean(LPC_kor(2,:)) mean(LPC_kor(3,:)) mean(LPC_kor(4,:)) mean(LPC_kor(5,:)) mean(LPC_kor(6,:)) mean(LPC_kor(7,:)) mean(LPC_kor(8,:)) mean(LPC_kor(9,:))];
        test = zeros(1,3);
        for k = 1:3
            for p = 1:8
                test(k) = test(k) + (Y(k,p) - alfa(1,p)).^2;
            end
        end
        [m, indeks] = min(test);
        if ~any(isnan(test)) && all(alfa ~= 0) 
            if indeks == 1 
               M_conf(j,1) = M_conf(j,1) + 1;
            end
            if indeks == 2     
               M_conf(j,2) = M_conf(j,2) + 1;
            end
            if indeks == 3
               M_conf(j,3) = M_conf(j,3) + 1;
            end  
            minimums = [minimums; m];
        else
            problem_files{end+1} = file_name;
        end
    end
end
fprintf('Odbaceno je %d elemenata iz test skupa koji nisu prosli proveru.\n', length(problem_files))
disp('Matrica konfuzije za test:')
M_conf