clear;
close all;
clc;

%% Učitavanje izgovorene cifre od strane korisnika
fs = 10000; 
T = 1/fs; 
length = 5; 
N = length*fs; 
nbits = 16; 
nchans = 1; 

x = audiorecorder(fs, nbits, nchans); 
disp('Izgovorite jednu od cifara 1, 4 ili 9:'); 
recordblocking(x, length);
disp('Kraj snimanja.'); 

y = getaudiodata(x); 
sound(y, fs); 
audiowrite('test_sekv.wav', y, fs);

%% Grafički prikaz izgovorene cifre
[y, fs] = audioread('test_sekv.wav'); 
% y = 0.6*y;
% figure
% plot(0:1/fs:(length(y)-1)/fs, y); 
% title('Ulazna govorna sekvenca'); xlabel('t [s]'); ylabel('y(t)'); 

%% Inicijalizacija 

digits = {'cetiri - 4', 'jedan - 1', 'devet - 9'};
Y = [-2.51444114306622	3.90704587725796	-3.34167963564677	1.16866001260086	-3.68860421029450	0.632404339548963	1.02963286902527	-0.119150981915400;
     -9.26325183118899	0.381977704286410	-4.03343156112307	4.00937556819434	-2.47239123543243	0.956571080980710	0.688884421112079	1.20943841417582;
     -11.1342825854367	3.49268836024348	-4.03482212749274	3.51528843867927	-4.31852477457077	3.11725168425641	1.04927444340239	-0.617619021061406]/10;
% Y predstavlja srednju vrednost obeležja po klasama ---> dobijeno na trening skupu.
% Za više detalja pogledati fajl conf_matrica.m

%% Predikcija

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

test
[m, indeks] = min(test);

if ~any(isnan(test)) && all(alfa ~= 0) 
    digit = digits{indeks};
    createCustomMsgBox([ 'Izgovorili ste cifru: ' digit], 'Predikcija', 'green', 600, 400, 20);
else
    disp('Došlo je do problema pri snimanju. Pokušajte ponovo.');
end

function createCustomMsgBox(message, title, color, width, height, fontSize)
    % Dobijanje rezolucije ekrana
    screenSize = get(0, 'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);

    % Izračunavanje početnih koordinata tako da je figura centrirana
    posX = (screenWidth - width) / 2;
    posY = (screenHeight - height) / 2;

    % Kreiranje figure
    fig = figure('Name', title, 'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', 'Color', color, 'Position', [posX, posY, width, height]);
    % Dodavanje teksta
    uicontrol('Style', 'text', 'String', message, 'Position', [50, height/2-20, width-100, 40], 'FontSize', fontSize, 'BackgroundColor', color);
    % Dodavanje dugmeta za zatvaranje
    uicontrol('Style', 'pushbutton', 'String', 'OK', 'Position', [width/2-50, 20, 100, 40], 'Callback', @(src, event)close(fig));
end

