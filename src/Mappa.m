%% 
%% 1. CARICAMENTO DEL FILE DI LOG GLOBALE
nomeFile = 'MappaAeroporto.txt';
if ~exist(nomeFile, 'file'), error('File %s non trovato.', nomeFile); end

righeTesto = readlines(nomeFile);
righeTesto(righeTesto == "") = []; 
numStrutture = length(righeTesto);

ostacoli = cell(numStrutture, 1);
for i = 1:numStrutture
    matriceNumerica = str2num(righeTesto(i)); 
    if ~isempty(matriceNumerica), ostacoli{i} = matriceNumerica; end
end

%% 2. FILTRO SPAZIALE DI RITAGLIO & SCALATURA ADATTIVA
X_edifici = cell(0, 1); Y_edifici = cell(0, 1); 
is_hangar_ispezione = []; 
contatore_edifici = 0;

punti_strada_X = []; punti_strada_Y = [];

for i = 1:numStrutture
    if isempty(ostacoli{i}), continue; end
    X_grezzo = ostacoli{i}(1, :); Y_grezzo = ostacoli{i}(2, :);
    cx = mean(X_grezzo); cy = mean(Y_grezzo);
    
    % Limiti di ritaglio spaziale richiesti (I tuoi confini sacrosanti)
    if (cx > 14440) || (cx < 14100) || (cy > 16400) || (cy < 16150), continue; end
    
    intervallo_X = max(X_grezzo) - min(X_grezzo);
    intervallo_Y = max(Y_grezzo) - min(Y_grezzo);
    
    if (intervallo_X < 1.5 && intervallo_Y < 1.5)
        punti_strada_X = [punti_strada_X; cx]; punti_strada_Y = [punti_strada_Y; cy];
    else
        diagonale = sqrt(intervallo_X^2 + intervallo_Y^2);
        if diagonale > 30,         fattoreScala = 0.95; 
        elseif diagonale > 12,     fattoreScala = 0.80; 
        else,                      fattoreScala = 0.50; 
        end
        
        contatore_edifici = contatore_edifici + 1;
        X_edifici{contatore_edifici, 1} = cx + (X_grezzo - cx) * fattoreScala;
        Y_edifici{contatore_edifici, 1} = cy + (Y_grezzo - cy) * fattoreScala;
        
        % --- IDENTIFICAZIONE ESATTA DEGLI HANGAR DI ISPEZIONE (VERDI) ---
        Hangar1 = (cx > 14210 && cx < 14250 && cy > 16290 && cy < 16330);
        Hangar2 = (cx > 14240 && cx < 14280 && cy > 16310 && cy < 16350);
        Hangar3 = (cx > 14390 && cx < 14430 && cy > 16320 && cy < 16360);
        Hangar4 = (cx > 14380 && cx < 14420 && cy > 16200 && cy < 16250);
        
        if Hangar1 || Hangar2 || Hangar3 || Hangar4
            is_hangar_ispezione(contatore_edifici) = true;
        else
            is_hangar_ispezione(contatore_edifici) = false;
        end
    end
end

%% 3. DEFINIZIONE DELLE COORDINATE DI MISSIONE
uav_home  = [14330, 16186]; % Drone Home
ugv_start = [14347, 16341]; % Rover Partenza
ugv_hq    = [14205, 16290]; % Area Refuel Piazzale Giallo

%% 4. PLOT DELLO SCENARIO ULTRA-PULITO FINALE
figure('Name', 'Digital Twin - Scenario di Missione', 'NumberTitle', 'off');
hold on;

% A. Nuvola di punti della strada
if ~isempty(punti_strada_X)
    plot(punti_strada_X, punti_strada_Y, 'k.', 'MarkerSize', 5);
end

% B. Disegno Edifici (Rosso o Verde) - SENZA NUMERI, SOLO GEOMETRIA
for i = 1:contatore_edifici
    if is_hangar_ispezione(i)
        colore = [0.20, 0.65, 0.20]; % Verde per gli obiettivi
    else
        colore = [0.85, 0.15, 0.15]; % Rosso per gli ostacoli
    end
    
    fill(X_edifici{i}, Y_edifici{i}, colore, ...
         'EdgeColor', [0.15, 0.15, 0.15], 'LineWidth', 1.1, 'FaceAlpha', 0.6); 
end

% C. Punti Missione Nativi Minimali
h_uav   = plot(uav_home(1), uav_home(2), 'c.', 'MarkerSize', 25);   
h_start = plot(ugv_start(1), ugv_start(2), 'g.', 'MarkerSize', 25); 
h_hq    = plot(ugv_hq(1), ugv_hq(2), 'y.', 'MarkerSize', 25);       

%% 5. AGGIUNTA DELLA LEGENDA OPERATIVA DEI TASK
legend([h_uav, h_start, h_hq], ...
       {'HOME UAV', ...
        'START/REENTRY UGV', ...
        'HQ REFUEL'}, ...
       'Location', 'southwest', 'FontSize', 9, 'FontWeight', 'bold');

%% 6. IMPOSTAZIONI GRAFICHE FINALI
axis equal; grid on; box on;
xlabel('Coordinata Est (X) [metri]'); ylabel('Coordinata Nord (Y) [metri]');
title('Digital Twin Aeroporto - Scenario per Simulazione UAV/UGV');
xlim([14100, 14440]); ylim([16150, 16400]);
set(gca, 'Color', [0.96, 0.96, 0.96]);
set(gca, 'FontSize', 12);

disp('Scenario finale pronto! Pulito, minimale e privo di scritte superflue.');

%% 6bis. IMPOSTAZIONE DIMENSIONI FIGURA (prima di esportare)
figura = gcf;

% Calcola il rapporto larghezza/altezza in base ai limiti reali della mappa
rangeX = 14440 - 14100;  % 340
rangeY = 16400 - 16150;  % 250
rapporto = rangeX / rangeY;

% Larghezza "grande" in pollici, con margine extra per titolo/griglia/etichette/legenda
larghezza_pollici = 14;
altezza_pollici = larghezza_pollici / rapporto;

figura.Units = 'inches';
figura.Position = [1, 1, larghezza_pollici + 1, altezza_pollici + 1.5];

%% 7. ESPORTAZIONE IN PDF
% Verifica che la cartella corrente sia scrivibile, altrimenti usa Documenti
try
    fid = fopen('test_scrittura_tmp.txt', 'w');
    fclose(fid);
    delete('test_scrittura_tmp.txt');
    cartellaOutput = pwd;
catch
    if ispc
        cartellaOutput = fullfile(getenv('USERPROFILE'), 'Documents');
    else
        cartellaOutput = fullfile(getenv('HOME'), 'Documents');
    end
    warning('Cartella corrente non scrivibile, salvo in: %s', cartellaOutput);
end

nomeOutput = fullfile(cartellaOutput, 'ScenarioMissione.pdf');
exportgraphics(figura, nomeOutput, 'ContentType', 'vector', 'BackgroundColor', 'white');
fprintf('PDF salvato come: %s (dimensioni %.1fx%.1f pollici)\n', ...
        nomeOutput, larghezza_pollici + 1, altezza_pollici + 1.5);

%% --- ESTRAZIONE AUTOMATICA E SALVATAGGIO MATRICE PER SIMULINK ---
num_edifici = contatore_edifici;
MAPPA_EDIFICI = zeros(num_edifici, 3);

% Coordinate di origine del drone (Home)
x_home = uav_home(1); % 14330
y_home = uav_home(2); % 16186

for i = 1:num_edifici
    vx = X_edifici{i};
    vy = Y_edifici{i};
    
    % 1. Centro dell'edificio TRASLATO rispetto all'Home del drone (Coordinate Locali)
    x_center_locale = ((max(vx) + min(vx)) / 2) - x_home;
    y_center_locale = ((max(vy) + min(vy)) / 2) - y_home;
    
    % 2. Ingombro massimo reale
    dim_max_reale = max(max(vx) - min(vx), max(vy) - min(vy));
    
    MAPPA_EDIFICI(i, :) = [x_center_locale, y_center_locale, dim_max_reale];
end

% 1. Invia comunque la matrice al Workspace corrente per sicurezza
assignin('base', 'MAPPA_EDIFICI', MAPPA_EDIFICI);

% 2. SALVATAGGIO DEL FILE .MAT NELLA CARTELLA DI PROGETTO
nome_file_mat = 'MappaEdifici.mat';
save(nome_file_mat, 'MAPPA_EDIFICI');

fprintf('>>> File "%s" salvato con successo nella cartella di lavoro! <<<\n', nome_file_mat);
disp('La matrice MAPPA_EDIFICI è ora pronta per essere collegata direttamente a Simulink.');
%% --- GENERAZIONE DIGITAL TWIN REALE (MAPPA_GROUND_TRUTH) ---
x_min = -230; x_max = 110; % Limiti X locali [m]
y_min = -36;  y_max = 214; % Limiti Y locali [m]
res   = 1.0;               % Risoluzione: 1 metro a cella

num_rows = round((y_max - y_min) / res) + 1; % 251 righe
num_cols = round((x_max - x_min) / res) + 1; % 341 colonne

MAPPA_GROUND_TRUTH = zeros(num_rows, num_cols);

% Griglia di coordinate locali
x_vec = linspace(x_min, x_max, num_cols);
y_vec = linspace(y_min, y_max, num_rows);
[X_grid, Y_grid] = meshgrid(x_vec, y_vec);

% Rasterizzazione esatta dei poligoni reali degli edifici
for k = 1:contatore_edifici
    % Converti vertici reali dell'edificio in coordinate locali rispetto a Home UAV
    vx_loc = X_edifici{k} - uav_home(1);
    vy_loc = Y_edifici{k} - uav_home(2);

    % Determina le celle interne al poligono esatto dell'edificio
    in = inpolygon(X_grid, Y_grid, vx_loc, vy_loc);
    MAPPA_GROUND_TRUTH(in) = 1; % 1 = Edificio Reale
end

% Salvataggio per Simulink
assignin('base', 'MAPPA_GROUND_TRUTH', MAPPA_GROUND_TRUTH);
save('MappaGroundTruth.mat', 'MAPPA_GROUND_TRUTH');

fprintf('>>> MAPPA_GROUND_TRUTH generata con successo! Griglia %dx%d celle. <<<\n', ...
    num_rows, num_cols);