%% --- ANIMAZIONE DIGITAL TWIN & ESPORTAZIONE VIDEO MP4 ---


nome_file_video = 'Missione_UAV_UGV_Altis.mp4';

%% 1. ESTRAZIONE E ALLINEAMENTO TEMPORALE ROBUSTO
function v_clean = get_full_signal(sig, t_grid)
    if isa(sig, 'timeseries')
        d = double(squeeze(sig.Data));
        t = double(sig.Time(:));
    elseif isstruct(sig) && isfield(sig, 'signals')
        d = double(squeeze(sig.signals.values));
        t = double(sig.time(:));
    else
        d = double(squeeze(sig));
        t = [];
    end
    d = d(:);
    
    if length(d) == 1
        v_clean = repmat(d, size(t_grid));
    elseif ~isempty(t) && length(t) == length(d) && length(t) > 1
        [t_u, idx_u] = unique(t, 'stable');
        v_clean = interp1(t_u, d(idx_u), t_grid, 'linear', 'extrap');
    else
        t_synth = linspace(t_grid(1), t_grid(end), length(d))';
        [t_u, idx_u] = unique(t_synth, 'stable');
        v_clean = interp1(t_u, d(idx_u), t_grid, 'linear', 'extrap');
    end
end

% Base temporale globale di campionamento (dt = 0.5s => 1300 passi totali)
dt_sim = 0.5; 
t_anim = (0 : dt_sim : 650)';
N_frames = length(t_anim);

uav_home  = [14330, 16186];
ugv_start = [14347, 16341];
ugv_hq    = [14205, 16290];

% 1. Segnali Reali UAV
xu_r = get_full_signal(UAV_x_r, t_anim);
yu_r = get_full_signal(UAV_y_r, t_anim);
zu_r = get_full_signal(UAV_z_r, t_anim);
zu_r(zu_r < 0) = 0;

X_uav_r_glob = xu_r + uav_home(1);
Y_uav_r_glob = yu_r + uav_home(2);

% 2. Segnali Desiderati UAV
if exist('UAV_x_d', 'var') && exist('UAV_y_d', 'var')
    xu_d = get_full_signal(UAV_x_d, t_anim);
    yu_d = get_full_signal(UAV_y_d, t_anim);
    X_uav_d_glob = xu_d + uav_home(1);
    Y_uav_d_glob = yu_d + uav_home(2);
else
    X_uav_d_glob = X_uav_r_glob;
    Y_uav_d_glob = Y_uav_r_glob;
end

% 3. Segnali Reali UGV
xg_r  = get_full_signal(UGV_x_r, t_anim);
yg_r  = get_full_signal(UGV_y_r, t_anim);
thg_r = get_full_signal(UGV_theta, t_anim);

X_ugv_r_glob = xg_r + uav_home(1);
Y_ugv_r_glob = yg_r + uav_home(2);

% 4. Traiettoria Pianificata UGV
if exist('percorso_UGV', 'var') && ~isempty(percorso_UGV)
    if isa(percorso_UGV, 'timeseries') || isfield(percorso_UGV, 'Data')
        p_raw = double(squeeze(percorso_UGV.Data));
    else
        p_raw = double(percorso_UGV);
    end
    valid_pts = ~(p_raw(:, 1) == 0 & p_raw(:, 2) == 0);
    X_ugv_d_glob = p_raw(valid_pts, 1) + uav_home(1);
    Y_ugv_d_glob = p_raw(valid_pts, 2) + uav_home(2);
else
    X_ugv_d_glob = X_ugv_r_glob;
    Y_ugv_d_glob = Y_ugv_r_glob;
end

% Calcolo Dinamico FOV (Apertura 60 deg)
fov_rad = 60 * (pi / 180);
L_fov_anim = 2 * max(zu_r, 0) * tan(fov_rad / 2);

%% 2. INIZIALIZZAZIONE GRAFICA DIGITAL TWIN (Fix getframe)
if exist('Mappa.m', 'file')
    run('Mappa.m');
    hold on;
else
    figure('Name', 'Digital Twin Missione UAV-UGV', 'Color', 'w');
end

fig = gcf;

% --- RESET GRAFICO FISSO ---
set(fig, 'Units', 'pixels', ...
         'Position', [100, 100, 1280, 720], ... % Risoluzione standard 720p pari
         'PaperPositionMode', 'auto', ...
         'Color', 'w', ...
         'Renderer', 'opengl', ...
         'Resize', 'off'); % Blocca il ridimensionamento accidentale della finestra
drawnow;

hold on; grid on; box on; axis equal;

% Landmark
h_uav_home = plot(uav_home(1), uav_home(2), 'co', 'MarkerSize', 9, 'MarkerFaceColor', 'c', 'DisplayName', 'HOME UAV');
h_ugv_home = plot(ugv_start(1), ugv_start(2), 'go', 'MarkerSize', 9, 'MarkerFaceColor', 'g', 'DisplayName', 'HOME UGV');
h_ugv_hq   = plot(ugv_hq(1), ugv_hq(2), 'yo', 'MarkerSize', 9, 'MarkerFaceColor', 'y', 'DisplayName', 'HQ REFUEL');

% Tracce UAV
h_uav_ideal = plot(X_uav_d_glob, Y_uav_d_glob, '--', 'Color', [0.35 0.75 1.0], 'LineWidth', 1.8, 'DisplayName', 'UAV Ideale');
h_uav_real  = plot(nan, nan, '-', 'Color', [0.0 0.15 0.75], 'LineWidth', 2.2, 'DisplayName', 'UAV Reale');
h_uav_body  = plot(nan, nan, 'p', 'MarkerSize', 11, 'MarkerFaceColor', [0.0 0.2 0.8], 'MarkerEdgeColor', 'k', 'DisplayName', 'UAV Pose');

% Riquadro Mobile FOV Camera (Magenta)
h_fov_box = plot(nan, nan, 'm-', 'LineWidth', 1.8, 'DisplayName', 'Copertura FOV');

% Tracce UGV
h_ugv_ideal = plot(X_ugv_d_glob, Y_ugv_d_glob, '--', 'Color', [0.55 0.9 0.4], 'LineWidth', 2.0, 'DisplayName', 'UGV Ideale');
h_ugv_real  = plot(nan, nan, '-', 'Color', [0.05 0.5 0.1], 'LineWidth', 2.5, 'DisplayName', 'UGV Reale');

% Sagoma UGV
L_car = 4.8; W_car = 2.4; 
ugv_box = [-L_car/2, -W_car/2;
            L_car/2, -W_car/2;
            L_car/2,  W_car/2;
           -L_car/2,  W_car/2]';
h_ugv_body = fill(nan, nan, [0.1 0.6 0.2], 'EdgeColor', 'k', 'LineWidth', 1.5, 'DisplayName', 'UGV Body');

xlim([14100, 14440]); ylim([16150, 16400]);
xlabel('Coordinata Est (X) [m]', 'FontWeight', 'bold');
ylabel('Coordinata Nord (Y) [m]', 'FontWeight', 'bold');
set(gca, 'Color', [0.96, 0.96, 0.96], 'FontSize', 10);

legend([h_uav_ideal, h_uav_real, h_fov_box, h_ugv_ideal, h_ugv_real, h_uav_home, h_ugv_home, h_ugv_hq], ...
       'Location', 'northoutside', 'Orientation', 'horizontal', 'NumColumns', 4, 'FontSize', 8, 'FontWeight', 'bold');

%% 3. CONFIGURAZIONE DEL VIDEO WRITER MP4
video_fps = 30; % 30 fps per massima fluidità
video_writer = VideoWriter(nome_file_video, 'MPEG-4');
video_writer.FrameRate = video_fps;
video_writer.Quality = 75; % Compressione ottimizzata (file finale leggerissimo < 5MB)
open(video_writer);

disp('>>> Generazione Video MP4 in corso... <<<');
idx_uav_end = find(t_anim >= 200, 1);
% Assicura che la figura sia in primo piano e stabile
figure(fig);
drawnow;
for k = 1:N_frames
    tk = t_anim(k);
    
    if tk <= 200
        %% FASE 1: Volo UAV + FOV
        set(h_uav_real, 'XData', X_uav_r_glob(1:k), 'YData', Y_uav_r_glob(1:k));
        set(h_uav_body, 'XData', X_uav_r_glob(k), 'YData', Y_uav_r_glob(k));
        
        Lk = L_fov_anim(k);
        x_box = [-Lk/2,  Lk/2, Lk/2, -Lk/2, -Lk/2];
        y_box = [-Lk/2, -Lk/2, Lk/2,  Lk/2, -Lk/2];
        set(h_fov_box, 'XData', X_uav_r_glob(k) + x_box, 'YData', Y_uav_r_glob(k) + y_box);
        
        % UGV fermo alla partenza
        R_init = [cos(thg_r(1)), -sin(thg_r(1)); sin(thg_r(1)), cos(thg_r(1))];
        box_init = R_init * ugv_box;
        set(h_ugv_body, 'XData', box_init(1, :) + X_ugv_r_glob(1), ...
                        'YData', box_init(2, :) + Y_ugv_r_glob(1));
        
        title({sprintf('Digital Twin Altis - Fase 1: Mappatura UAV | Tempo: %.1f s / 650.0 s', tk), ...
               sprintf('UAV Quota: %.1f m | Lato FOV Camera: %.1f m', zu_r(k), Lk)}, ...
               'FontSize', 10, 'FontWeight', 'bold');
    else
        %% FASE 2: Navigazione Terrestre UGV
        set(h_fov_box, 'XData', nan, 'YData', nan);
        set(h_uav_body, 'XData', X_uav_r_glob(idx_uav_end), 'YData', Y_uav_r_glob(idx_uav_end));
        
        set(h_ugv_real, 'XData', X_ugv_r_glob(idx_uav_end:k), 'YData', Y_ugv_r_glob(idx_uav_end:k));
        
        thk = thg_r(k);
        R_k = [cos(thk), -sin(thk); sin(thk), cos(thk)];
        box_k = R_k * ugv_box;
        set(h_ugv_body, 'XData', box_k(1, :) + X_ugv_r_glob(k), ...
                        'YData', box_k(2, :) + Y_ugv_r_glob(k));
        
        title({sprintf('Digital Twin Altis - Fase 2: Ispezione UGV | Tempo: %.1f s / 650.0 s', tk), ...
               sprintf('UGV Heading: %.1f deg | Inseguimento Path Following Pure Pursuit', rad2deg(thk))}, ...
               'FontSize', 10, 'FontWeight', 'bold');
    end
    
    drawnow limitrate;
    
    % Acquisizione e scrittura frame MP4
    frame = getframe(gcf);
    writeVideo(video_writer, frame);
end

close(video_writer);
fprintf('>>> Video MP4 salvato con successo: "%s"! Pronto per la condivisione. <<<\n', nome_file_video);