%% Plot_UGV_SlideTheme.m - Grafici UGV coordinati con lo stile della Slide
clearvars -except UGV_x_d UGV_x_r UGV_y_d UGV_y_r UGV_theta UGV_psi tout;
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
t_ugv_min = 199; % [s]
t_ugv_max = 650; % [s]
t_eval = linspace(t_ugv_min, t_ugv_max, 3000)';

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

% Campionamento variabili
x_d = eval_signal(UGV_x_d); x_r = eval_signal(UGV_x_r);
y_d = eval_signal(UGV_y_d); y_r = eval_signal(UGV_y_r);
theta_r = rad2deg(eval_signal(UGV_theta));
psi_r   = rad2deg(eval_signal(UGV_psi));

% 2. Funzione di Plotting Tema Slide
function export_slide_ugv_plot(t, ref, real, nome_var, unita, nome_file)
    c_bg_fig   = [0.145, 0.208, 0.184];
    c_bg_ax    = [0.106, 0.149, 0.133];
    c_cyan_bar = [0.330, 0.770, 0.820];
    c_green_br = [0.520, 0.840, 0.380];
    
    f = figure('Position', [100, 100, 950, 520], 'Color', c_bg_fig);
    ax = gca;
    
    plot(t, ref, '--', 'Color', c_cyan_bar, 'LineWidth', 2.4, 'DisplayName', [nome_var, ' Pianificato']); hold on;
    plot(t, real, '-',  'Color', c_green_br, 'LineWidth', 2.0, 'DisplayName', [nome_var, ' Reale']);
    
    set(ax, 'Color', c_bg_ax, 'XColor', 'w', 'YColor', 'w', 'GridColor', [0.7 0.8 0.75], 'GridAlpha', 0.25, 'FontSize', 11, 'LineWidth', 1.2);
    grid on; box on;
    xlim([min(t), max(t)]);
    xlabel('Tempo [s]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
    ylabel([nome_var, ' [', unita, ']'], 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
    title(['UGV: Inseguimento ', nome_var, ' (Fase di Ispezione 200-650s)'], 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'w');
    
    leg = legend('Location', 'best', 'FontSize', 11);
    set(leg, 'TextColor', 'w', 'Color', c_bg_ax, 'EdgeColor', c_cyan_bar);
    
    drawnow;
    print(f, nome_file, '-dpng', '-r300');
    close(f);
    fprintf('Salvato con successo: %s\n', nome_file);
end

% 3. Esportazione Posizione X e Y
export_slide_ugv_plot(t_eval, x_d, x_r, 'Posizione X', 'm', 'UGV_Posizione_X.png');
export_slide_ugv_plot(t_eval, y_d, y_r, 'Posizione Y', 'm', 'UGV_Posizione_Y.png');

% 4. Heading (\theta) e Sterzo (\psi)
c_bg_fig   = [0.145, 0.208, 0.184];
c_bg_ax    = [0.106, 0.149, 0.133];
c_green_br = [0.520, 0.840, 0.380];
c_cyan_bar = [0.330, 0.770, 0.820];

% Heading
f_th = figure('Position', [100, 100, 950, 520], 'Color', c_bg_fig);
plot(t_eval, theta_r, 'Color', c_green_br, 'LineWidth', 2.2, 'DisplayName', 'Heading \theta Reale');
set(gca, 'Color', c_bg_ax, 'XColor', 'w', 'YColor', 'w', 'GridColor', [0.7 0.8 0.75], 'GridAlpha', 0.25, 'FontSize', 11, 'LineWidth', 1.2);
grid on; box on; xlim([t_ugv_min, t_ugv_max]);
xlabel('Tempo [s]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
ylabel('Heading \theta [deg]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
title('UGV: Orientamento sul Piano (\theta) nel Tempo', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'w');
leg = legend('Location', 'best', 'FontSize', 11);
set(leg, 'TextColor', 'w', 'Color', c_bg_ax, 'EdgeColor', c_cyan_bar);
drawnow;
print(f_th, 'UGV_Heading_Theta.png', '-dpng', '-r300');
close(f_th);

% Sterzo
f_psi = figure('Position', [100, 100, 950, 520], 'Color', c_bg_fig);
plot(t_eval, psi_r, 'Color', c_cyan_bar, 'LineWidth', 2.0, 'DisplayName', 'Sterzo \psi Reale');
set(gca, 'Color', c_bg_ax, 'XColor', 'w', 'YColor', 'w', 'GridColor', [0.7 0.8 0.75], 'GridAlpha', 0.25, 'FontSize', 11, 'LineWidth', 1.2);
grid on; box on; xlim([t_ugv_min, t_ugv_max]);
xlabel('Tempo [s]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
ylabel('Angolo di Sterzo \psi [deg]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
title('UGV: Angolo di Sterzatura Ruote Anteriori (\psi)', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'w');
leg = legend('Location', 'best', 'FontSize', 11);
set(leg, 'TextColor', 'w', 'Color', c_bg_ax, 'EdgeColor', c_cyan_bar);
drawnow;
print(f_psi, 'UGV_Steering_Psi.png', '-dpng', '-r300');
close(f_psi);

% 5. Traiettoria nel Piano X-Y
f_xy = figure('Position', [100, 100, 850, 700], 'Color', c_bg_fig);
plot(x_d, y_d, '--', 'Color', c_cyan_bar, 'LineWidth', 2.4, 'DisplayName', 'Percorso Pianificato'); hold on;
plot(x_r, y_r, '-',  'Color', c_green_br, 'LineWidth', 2.0, 'DisplayName', 'Traccia Reale UGV');
plot(x_r(1), y_r(1), 'o', 'MarkerSize', 10, 'MarkerFaceColor', c_green_br, 'MarkerEdgeColor', 'w', 'DisplayName', 'Inizio Ispezione');
plot(x_r(end), y_r(end), 's', 'MarkerSize', 10, 'MarkerFaceColor', [0.9 0.3 0.3], 'MarkerEdgeColor', 'w', 'DisplayName', 'Fine Ispezione');
set(gca, 'Color', c_bg_ax, 'XColor', 'w', 'YColor', 'w', 'GridColor', [0.7 0.8 0.75], 'GridAlpha', 0.25, 'FontSize', 11, 'LineWidth', 1.2);
grid on; box on; axis equal;
xlabel('Coordinata X Locale [m]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
ylabel('Coordinata Y Locale [m]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'w');
title('UGV: Confronto Traiettoria nel Piano X-Y', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'w');
leg = legend('Location', 'best', 'FontSize', 11);
set(leg, 'TextColor', 'w', 'Color', c_bg_ax, 'EdgeColor', c_cyan_bar);
drawnow;
print(f_xy, 'UGV_Traiettoria_Piano_XY.png', '-dpng', '-r300');
close(f_xy);

disp('Tutti i grafici UGV con stile slide sono stati generati!');