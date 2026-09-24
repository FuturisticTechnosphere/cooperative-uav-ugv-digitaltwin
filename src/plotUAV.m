%% Plot_UAV_SlideTheme.m - Grafici UAV coordinati con lo stile della Slide
clearvars -except UAV_x_d UAV_x_r UAV_y_d UAV_y_r UAV_z_d UAV_z_r ...
                  UAV_phi_d UAV_phi_r UAV_theta_d UAV_theta_r A_fov tout;
clc;
close all;

% 1. Funzione interna per estrazione sicura dei dati
function [val, t] = extract_data(sig, default_t)
    if isa(sig, 'timeseries')
        val = double(squeeze(sig.Data));
        t   = double(sig.Time(:));
    elseif isstruct(sig) && isfield(sig, 'signals')
        val = double(squeeze(sig.signals.values));
        t   = double(sig.time(:));
    else
        val = double(squeeze(sig));
        t   = double(default_t(:));
    end
    val = val(:);
    if length(val) ~= length(t)
        t = linspace(0, default_t(end), length(val))';
    end
end

t_base = tout(:);
t_uav_max = 200; % [s] Finestra attiva dell'UAV
t_eval = linspace(0, t_uav_max, 2000)';

function t = extract_time(sig, t_base)
    [~, t] = extract_data(sig, t_base);
    [t, ~] = unique(t, 'stable');
end

function v = extract_val(sig, t_base)
    [val, t] = extract_data(sig, t_base);
    [~, idx] = unique(t, 'stable');
    v = val(idx);
end

eval_signal = @(sig) interp1(extract_time(sig, t_base), extract_val(sig, t_base), t_eval, 'linear', 'extrap');

% Campionamento variabili UAV
x_d = eval_signal(UAV_x_d); x_r = eval_signal(UAV_x_r);
y_d = eval_signal(UAV_y_d); y_r = eval_signal(UAV_y_r);
z_d = eval_signal(UAV_z_d); z_r = eval_signal(UAV_z_r);

phi_d   = rad2deg(eval_signal(UAV_phi_d));
phi_r   = rad2deg(eval_signal(UAV_phi_r));
theta_d = rad2deg(eval_signal(UAV_theta_d));
theta_r = rad2deg(eval_signal(UAV_theta_r));

if exist('A_fov', 'var') && ~isempty(A_fov)
    afov = eval_signal(A_fov);
else
    afov = [];
end

% 2. Funzione di Plotting con Palette Cromatiche della Slide
function export_slide_plot(t, ref, real, nome_var, unita, nome_file)
    % Colori estratti dalla slide
    c_bg_fig   = [0.145, 0.208, 0.184]; % Sfondo scuro principale slide (#25352F)
    c_bg_ax    = [0.106, 0.149, 0.133]; % Sfondo interno grafico
    c_cyan_bar = [0.330, 0.770, 0.820]; % Ciano della linea divisoria laterale (#55C5D1)
    c_green_br = [0.520, 0.840, 0.380]; % Verde brillante della fascia laterale (#85D661)
    
    f = figure('Position', [100, 100, 950, 520], 'Color', c_bg_fig);
    ax = gca;
    
    plot(t, ref, '--', 'Color', c_cyan_bar, 'LineWidth', 2.4, 'DisplayName', [nome_var, ' Desiderato']); hold on;
    plot(t, real, '-',  'Color', c_green_br, 'LineWidth', 2.0, 'DisplayName', [nome_var, ' Reale']);
    
    set(ax, 'Color', c_bg_ax, ...
            'XColor', [0.9 0.9 0.9], ...
            'YColor', [0.9 0.9 0.9], ...
            'GridColor', [0.7 0.8 0.75], ...
            'GridAlpha', 0.25, ...
            'FontSize', 11, ...
            'LineWidth', 1.2);
        
    grid on; box on;
    xlim([0, max(t)]);
    xlabel('Tempo [s]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
    ylabel([nome_var, ' [', unita, ']'], 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
    title(['UAV: Inseguimento ', nome_var, ' (Fase di Volo 0-200s)'], ...
          'FontSize', 14, 'FontWeight', 'bold', 'Color', 'w');
      
    leg = legend('Location', 'best', 'FontSize', 11);
    set(leg, 'TextColor', 'w', 'Color', [0.106, 0.149, 0.133], 'EdgeColor', [0.33, 0.77, 0.82]);
    
    drawnow;
    print(f, nome_file, '-dpng', '-r300');
    close(f);
    fprintf('Salvato con successo: %s\n', nome_file);
end

% 3. Esportazione Grafici UAV
export_slide_plot(t_eval, x_d, x_r, 'Posizione X', 'm', 'UAV_Posizione_X.png');
export_slide_plot(t_eval, y_d, y_r, 'Posizione Y', 'm', 'UAV_Posizione_Y.png');
export_slide_plot(t_eval, z_d, z_r, 'Quota Z', 'm', 'UAV_Quota_Z.png');
export_slide_plot(t_eval, phi_d, phi_r, 'Roll \phi', 'deg', 'UAV_Roll_Phi.png');
export_slide_plot(t_eval, theta_d, theta_r, 'Pitch \theta', 'deg', 'UAV_Pitch_Theta.png');

% Grafico Area FOV nello stesso stile
if ~isempty(afov)
    c_bg_fig   = [0.145, 0.208, 0.184];
    c_bg_ax    = [0.106, 0.149, 0.133];
    c_cyan_bar = [0.330, 0.770, 0.820];
    
    f = figure('Position', [100, 100, 950, 520], 'Color', c_bg_fig);
    ax = gca;
    plot(t_eval, afov, '-', 'Color', c_cyan_bar, 'LineWidth', 2.4, 'DisplayName', 'Area Copertura FOV');
    set(ax, 'Color', c_bg_ax, 'XColor', 'w', 'YColor', 'w', 'GridColor', [0.7 0.8 0.75], 'GridAlpha', 0.25, 'FontSize', 11, 'LineWidth', 1.2);
    grid on; box on;
    xlim([0, max(t_eval)]);
    xlabel('Tempo [s]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
    ylabel('Area FOV [m^2]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
    title('UAV: Impronta a Terra della Telecamera (FOV)', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'w');
    leg = legend('Location', 'best', 'FontSize', 11);
    set(leg, 'TextColor', 'w', 'Color', c_bg_ax, 'EdgeColor', c_cyan_bar);
    
    drawnow;
    print(f, 'UAV_Area_FOV.png', '-dpng', '-r300');
    close(f);
    fprintf('Salvato con successo: UAV_Area_FOV.png\n');
end

disp('Tutti i grafici UAV con stile slide sono stati generati!');