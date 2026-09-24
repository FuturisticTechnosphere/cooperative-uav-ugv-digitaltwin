%% SCRIPT VISUALIZZAZIONE MAPPA SCOPERTA DALL'UAV (simout)

% --- 1. ESTRAZIONE DELLA MAPPA E DEL PERCORSO ---
dati_grezzi = mappa_fissa;
grid_scoperta = dati_grezzi.Data(:, :, end);

percorso_grezzo = percorso_UGV;
percorso = percorso_grezzo.Data(:, :, end);
% Pulizia zeri del buffer statico (3000x2)
valid_idx = ~(percorso(:, 1) == 0 & percorso(:, 2) == 0);
path_ugv = percorso(valid_idx, :);

% Gestione dei diversi formati possibili (Array, Timeseries o Structure)


% --- 2. PARAMETRI SPATIALI SCENARIO ALTIS ---
x_min = -230; x_max = 110; % [m] Coordinate X locali rispetto a Home UAV
y_min = -36; y_max = 214; % [m] Coordinate Y locali rispetto a Home UAV

% Punti strategici della missione in coordinate locali
uav_home_loc = [14330, 16186] - [14330, 16186]; % [0, 0] Home UAV
ugv_start_loc = [14347, 16341] - [14330, 16186]; % [17, 155] Partenza UGV
ugv_hq_loc = [14205, 16290] - [14330, 16186]; % [-125, 104] Refuel UGV
% --- 3. CREAZIONE GRAFICO ---
figure('Name', 'Occupancy Grid - Ricognizione Aerea completata', ...
'NumberTitle', 'off', 'Color', 'w');


% Plot della griglia con corretto orientamento cartesiano
imagesc([x_min, x_max], [y_min, y_max], grid_scoperta);
axis xy equal; grid on; box on;
colormap(flipud(gray)); % Bianco = Libero (0), Nero = Edificio Rilevato (1)
c = colorbar;
c.Label.String = 'Stato Cella (0 = Libero/Non visibile, 1 = Ostacolo)';
hold on;
% Plot del percorso dell'UGV
h_path = plot(path_ugv(:, 1), path_ugv(:, 2), 'b-', 'LineWidth', 2.5);
%legend({'HOME UAV (0,0)', 'START UGV (Hangar Logistico)', 'HQ REFUEL UGV', 'Percorso UGV'}, ...
%    'Location', 'southwest', 'FontSize', 10);

% Sovrapposizione Punti Tattici
% Punti strategici (assegnazione degli handle h1, h2, h3)
h1 = plot(uav_home_loc(1),  uav_home_loc(2),  'co', 'MarkerSize', 10, 'MarkerFaceColor', 'c', 'LineWidth', 1.5);
h2 = plot(ugv_start_loc(1), ugv_start_loc(2), 'go', 'MarkerSize', 11, 'MarkerFaceColor', 'g', 'LineWidth', 1.5);
h3 = plot(ugv_hq_loc(1),    ugv_hq_loc(2),    'yo', 'MarkerSize', 11, 'MarkerFaceColor', 'y', 'LineWidth', 1.5);
title('Mappa di Occupazione generata dal FOV dell''UAV', 'FontSize', 13);
xlabel('Coordinata Est Locale X [metri]', 'FontSize', 11);
ylabel('Coordinata Nord Locale Y [metri]', 'FontSize', 11);
legend({'Percorso UGV (0,0)', 'START UGV (Hangar Logistico)', 'HQ REFUEL UGV'}, ...
'Location', 'southwest', 'FontSize', 10);

% Plot del percorso dell'UGV


% Assegna la variabile 'map_ugv' al Workspace di MATLAB
disp('>>> Mappa generata con successo e visualizzata! <<<');
