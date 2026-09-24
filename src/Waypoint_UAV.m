%% SCRIPT COMPLETO GENERAZIONE WAYPOINT E RIFERIMENTI UAV

% 1. Coordinate reali di Home UAV
X_home = 14330;
Y_home = 16186;
quota_volo = 0; 

% 2. Coordinate Reali esatte dai Data Cursor (in sequenza)
X_wp_reali = [ ...
    14330.0, ... % 1. HOME UAV / Partenza
    14400.8, ... % 2. Hangar Verde Est
    14418.2, ... % 3. Passaggio Est
    14357.4, ... % 4. Edificio Nord-Est
    14312.2, ... % 5. Complesso Nord 1
    14291.0, ... % 6. Complesso Nord 2
    14257.5, ... % 7. Area Nord-Ovest
    14229.6, ... % 8. Hangar Verde Centrale
    14199.5, ... % 9. Hangar Verde Ovest
    14175.0, ... % 10. Angolo Nord-Ovest
    14129.4, ... % 11. Edificio Ovest
    14141.6, ... % 12. Edificio Sud-Ovest
    14186.3, ... % 13. Area Sud
    14265.9, ... % 14. Area Sud-Est
    14330.0  ... % 15. HOME UAV / Rientro
];

Y_wp_reali = [ ...
    16186.0, ...
    16209.4, ...
    16320.7, ...
    16339.1, ...
    16360.5, ...
    16359.7, ...
    16334.5, ...
    16286.3, ...
    16300.9, ...
    16324.2, ...
    16245.8, ...
    16190.8, ...
    16222.7, ...
    16222.3, ...
    16186.0  ...
];

% -------------------------------------------------------------------------
% 2bis. CORREZIONE AUTOMATICA: SNAP SUI CENTRI DEGLI EDIFICI
% Se il punto presunto spigolo dista meno di 25m dal centro, lo sposta
% esattamente sul centro geometrico dell'edificio!
% -------------------------------------------------------------------------
if exist('MAPPA_EDIFICI', 'var')
    X_centri_reali = MAPPA_EDIFICI(:, 1) + X_home;
    Y_centri_reali = MAPPA_EDIFICI(:, 2) + Y_home;
    
    for w = 2:(length(X_wp_reali)-1)
        distanze = hypot(X_wp_reali(w) - X_centri_reali, Y_wp_reali(w) - Y_centri_reali);
        [min_dist, idx_edificio] = min(distanze);
        
        if min_dist < 25
            X_wp_reali(w) = X_centri_reali(idx_edificio);
            Y_wp_reali(w) = Y_centri_reali(idx_edificio);
            fprintf('Waypoint %d centrato in automatico sull''edificio %d!\n', w, idx_edificio);
        end
    end
else
    warning('MAPPA_EDIFICI non trovata. Esegui prima Mappa.m se vuoi lo Snap sui centri!');
end

% 3. Conversione in Coordinate Locali rispetto a Home
x_loc = X_wp_reali - X_home;
y_loc = Y_wp_reali - Y_home;
z_loc = [0, repmat(quota_volo, 1, length(x_loc)-2), 0]; % Decollo, Volo a 10m, Atterraggio

% 4. Tempi dei Waypoint proporzionali alle distanze per mantenere la velocità costante
num_wp = length(x_loc);
t_wp = linspace(0, 130, num_wp)'; % Distribuisce i 15 waypoint tra 0s e 130s

% 5. Estensione a t_max = 150s (Stazionamento a terra a fine volo)
t_max_simulink = 150; 
if max(t_wp) < t_max_simulink
    t_wp(end+1)  = t_max_simulink;
    x_loc(end+1) = x_loc(end);
    y_loc(end+1) = y_loc(end);
    z_loc(end+1) = 0;
end

% 6. Interpolazione temporale
t_sim = (0:0.05:t_max_simulink)';
x_interp = interp1(t_wp, x_loc, t_sim, 'linear');
y_interp = interp1(t_wp, y_loc, t_sim, 'linear');
z_interp = interp1(t_wp, z_loc, t_sim, 'linear');

z_interp(z_interp < 0) = 0; % Sicurezza a terra

% 7. Salvataggio Matrici Riferimento per Simulink
ref_x = [t_sim, x_interp]';
ref_y = [t_sim, y_interp]';
ref_z = [t_sim, z_interp]';

disp('>>> Nuova Rotta con 15 Waypoint Generata con Successo! <<<');
save('ref_x.mat', 'ref_x');
save('ref_y.mat', 'ref_y');
save('ref_z.mat', 'ref_z');
save('WaypointData.mat', 'ref_x', 'ref_y', 'ref_z');