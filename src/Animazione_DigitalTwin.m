%% --- ANIMAZIONE MISSIONE UAV (COLORI ORIGINALI & VIDEO MP4 A 200s) ---

nome_file_video = 'Missione_UAV_Altis_200s.mp4';
uav_home = [14330, 16186];

%% 1. RECUPERO SEGNALI DA WORKSPACE O CONTENITORE "out"
if exist('out', 'var')
    if isempty(who('UAV_x_r')) && isprop(out, 'UAV_x_r'), UAV_x_r = out.UAV_x_r; end
    if isempty(who('UAV_y_r')) && isprop(out, 'UAV_y_r'), UAV_y_r = out.UAV_y_r; end
    if isempty(who('UAV_z_r')) && isprop(out, 'UAV_z_r'), UAV_z_r = out.UAV_z_r; end
    if isempty(who('UAV_x_d')) && isprop(out, 'UAV_x_d'), UAV_x_d = out.UAV_x_d; end
    if isempty(who('UAV_y_d')) && isprop(out, 'UAV_y_d'), UAV_y_d = out.UAV_y_d; end
    if isempty(who('tout')) && isprop(out, 'tout'),       tout    = out.tout;    end
end

% Fallback da file .mat se non caricati in memoria
if ~exist('UAV_x_r', 'var') && exist('UAV_x_r.mat', 'file'), load('UAV_x_r.mat'); end
if ~exist('UAV_y_r', 'var') && exist('UAV_y_r.mat', 'file'), load('UAV_y_r.mat'); end
if ~exist('UAV_z_r', 'var') && exist('UAV_z_r.mat', 'file'), load('UAV_z_r.mat'); end

% Funzione ausiliaria per estrazione robusta
function [d_vec, t_vec] = extract_sig(v, t_def)
    if isa(v, 'timeseries')
        d_vec = double(squeeze(v.Data));
        t_vec = double(v.Time(:));
    elseif isstruct(v) && isfield(v, 'signals')
        d_vec = double(squeeze(v.signals.values));
        t_vec = double(v.time(:));
    else
        d_vec = double(squeeze(v));
        t_vec = double(t_def(:));
    end
    d_vec = d_vec(:);
    if length(d_vec) ~= length(t_vec)
        t_vec = linspace(0, t_def(end), length(d_vec))';
    end
end

if exist('tout', 'var') && ~isempty(tout)
    t_base = double(tout(:));
else
    t_base = linspace(0, 650, 1301)';
end

[xu_r, t_uav] = extract_sig(UAV_x_r, t_base);
[yu_r, ~]     = extract_sig(UAV_y_r, t_base);
[zu_r, ~]     = extract_sig(UAV_z_r, t_base);

%% 2. GRIGLIA TEMPORALE (BLOCCO ESATTO A 200 SECONDI)
t_max_uav = 200.0;
fps_video = 30;
dt_anim = 0.05; % Campionamento fluido (20 Hz)
t_anim = (0 : dt_anim : t_max_uav)';
N_frames = length(t_anim);

% Interpolazione Reale UAV
[t_u, idx_u] = unique(t_uav, 'stable');
xu_anim = interp1(t_u, xu_r(idx_u), t_anim, 'linear', 'extrap');
yu_anim = interp1(t_u, yu_r(idx_u), t_anim, 'linear', 'extrap');
zu_anim = interp1(t_u, zu_r(idx_u), t_anim, 'linear', 'extrap');
zu_anim(zu_anim < 0) = 0;

X_uav_r_glob = xu_anim + uav_home(1);
Y_uav_r_glob = yu_anim + uav_home(2);

% Ricostruzione Rotta Desiderata / Ideale UAV
if exist('UAV_x_d', 'var') && exist('UAV_y_d', 'var')
    [xu_d, t_d] = extract_sig(UAV_x_d, t_base);
    [yu_d, ~]   = extract_sig(UAV_y_d, t_base);
    [t_ud, iu_d] = unique(t_d, 'stable');
    X_uav_d_glob = interp1(t_ud, xu_d(iu_d), t_anim, 'linear', 'extrap') + uav_home(1);
    Y_uav_d_glob = interp1(t_ud, yu_d(iu_d), t_anim, 'linear', 'extrap') + uav_home(2);
elseif exist('X_wp_reali', 'var') && exist('Y_wp_reali', 'var')
    % Se sono presenti i Waypoint di Waypoint.m
    X_uav_d_glob = X_wp_reali(:);
    Y_uav_d_glob = Y_wp_reali(:);
else
    % Fallback: copia il percorso nominale
    X_uav_d_glob = X_uav_r_glob;
    Y_uav_d_glob = Y_uav_r_glob;
end

% FOV Dinamico della telecamera (apertura 60 deg)
fov_rad = 60 * (pi / 180);
L_fov_anim = 2 * zu_anim * tan(fov_rad / 2);

%% 3. INIZIALIZZAZIONE GRAFICA DIGITAL TWIN
if exist('Mappa.m', 'file')
    run('Mappa.m');
    hold on;
else
    figure('Name', 'Digital Twin Missione UAV Altis', 'Color', 'w');
    hold on; grid on; box on; axis equal;
end

fig = gcf;
set(fig, 'Units', 'pixels', ...
         'Position', [100, 100, 1280, 720], ...
         'PaperPositionMode', 'auto', ...
         'Color', 'w', ...
         'Renderer', 'opengl', ...
         'Resize', 'off');
drawnow;

% Punti Noti Fissi
h_uav_home = plot(uav_home(1), uav_home(2), 'co', 'MarkerSize', 9, 'MarkerFaceColor', 'c', 'DisplayName', 'HOME UAV');

% --- ELEMENTI UAV CON LA PALETTE ORIGINALE ---
% 1. Percorso Ideale UAV: Tratteggiato Blu Chiaro / Ciano
h_uav_ideal = plot(X_uav_d_glob, Y_uav_d_glob, '--', 'Color', [0.30 0.75 1.0], 'LineWidth', 1.8, 'DisplayName', 'UAV Ideale');
% 2. Percorso Reale UAV: Continuo Blu Scuro
h_uav_real  = plot(nan, nan, '-', 'Color', [0.0 0.15 0.75], 'LineWidth', 2.2, 'DisplayName', 'UAV Reale');
% 3. Sagoma / Pose Drone
h_uav_body  = plot(nan, nan, 'p', 'MarkerSize', 11, 'MarkerFaceColor', [0.0 0.2 0.8], 'MarkerEdgeColor', 'k', 'DisplayName', 'UAV Pose');
% 4. Riquadro FOV Mobile: Magenta Continuo
h_fov_box   = plot(nan, nan, 'm-', 'LineWidth', 1.8, 'DisplayName', 'Copertura FOV');

xlim([14100, 14440]); 
ylim([16150, 16400]);
xlabel('Coordinata Est (X) [m]', 'FontWeight', 'bold');
ylabel('Coordinata Nord (Y) [m]', 'FontWeight', 'bold');
set(gca, 'Color', [0.96, 0.96, 0.96], 'FontSize', 10);

legend([h_uav_ideal, h_uav_real, h_fov_box, h_uav_home], ...
       'Location', 'northoutside', 'Orientation', 'horizontal', 'NumColumns', 4, 'FontSize', 8, 'FontWeight', 'bold');

%% 4. SCRITTURA FILE VIDEO MP4
vid = VideoWriter(nome_file_video, 'MPEG-4');
vid.FrameRate = fps_video;
vid.Quality = 85;
open(vid);

disp('>>> Avvio Rendering Video UAV (0 - 200 s) ... <<<');

for k = 1:N_frames
    tk = t_anim(k);
    
    % Aggiornamento Traccia Reale e Pose
    set(h_uav_real, 'XData', X_uav_r_glob(1:k), 'YData', Y_uav_r_glob(1:k));
    set(h_uav_body, 'XData', X_uav_r_glob(k),   'YData', Y_uav_r_glob(k));
    
    % Aggiornamento Proiezione FOV a Terra (Magenta)
    Lk = L_fov_anim(k);
    box_x = [-Lk/2,  Lk/2,  Lk/2, -Lk/2, -Lk/2] + X_uav_r_glob(k);
    box_y = [-Lk/2, -Lk/2,  Lk/2,  Lk/2, -Lk/2] + Y_uav_r_glob(k);
    set(h_fov_box, 'XData', box_x, 'YData', box_y);
    
    % Telemetria
    title({sprintf('Digital Twin Altis - Scansione UAV | Tempo: %.1f s / 200.0 s', tk), ...
           sprintf('Quota UAV: %.1f m | Impronta FOV Camera: %.1f m', zu_anim(k), Lk)}, ...
           'FontSize', 10, 'FontWeight', 'bold');
    
    drawnow limitrate;
    writeVideo(vid, getframe(fig));
end

close(vid);
fprintf('>>> Video MP4 generato con successo: "%s" (Terminato esattamente a 200 s)! <<<\n', nome_file_video);