%% 1. Traiettorie e Riferimenti UAV (Quadricottero)
UAV_x_d = out.UAV_x_d;
save('UAV_x_d.mat', 'UAV_x_d');

UAV_x_r = out.UAV_x_r;
save('UAV_x_r.mat', 'UAV_x_r');

UAV_y_d = out.UAV_y_d;
save('UAV_y_d.mat', 'UAV_y_d');

UAV_y_r = out.UAV_y_r;
save('UAV_y_r.mat', 'UAV_y_r');

UAV_z_d = out.UAV_z_d;
save('UAV_z_d.mat', 'UAV_z_d');

UAV_z_r = out.UAV_z_r;
save('UAV_z_r.mat', 'UAV_z_r');

%% 2. Assetto UAV (Roll e Pitch)
UAV_phi_d = out.UAV_phi_d;
save('UAV_phi_d.mat', 'UAV_phi_d');

UAV_phi_r = out.UAV_phi_r;
save('UAV_phi_r.mat', 'UAV_phi_r');

UAV_theta_d = out.UAV_theta_d;
save('UAV_theta_d.mat', 'UAV_theta_d');

UAV_theta_r = out.UAV_theta_r;
save('UAV_theta_r.mat', 'UAV_theta_r');

%% 3. Traiettorie e Riferimenti UGV (Rover Terrestre)
UGV_x_d = out.UGV_x_d;
save('UGV_x_d.mat', 'UGV_x_d');

UGV_x_r = out.UGV_x_r;
save('UGV_x_r.mat', 'UGV_x_r');

UGV_y_d = out.UGV_y_d;
save('UGV_y_d.mat', 'UGV_y_d');

UGV_y_r = out.UGV_y_r;
save('UGV_y_r.mat', 'UGV_y_r');

UGV_psi = out.UGV_psi;
save('UGV_psi.mat', 'UGV_psi');

UGV_theta = out.UGV_theta;
save('UGV_theta.mat', 'UGV_theta');

%% 4. FOV e Vettore Temporale
A_fov = out.A_fov;
save('A_fov.mat', 'A_fov');

tout = out.tout;
save('tout.mat', 'tout');

%% 5. Percorso UGV e mappa
percorso_UGV = out.percorso;
% Salva la variabile in un file .mat
save('Percoso_UGV.mat', 'percorso_UGV');
disp('Percorso salvato!');

mappa_fissa = out.mappa;
% Salva la variabile in un file .mat
save('MappaScoperta_Altis.mat', 'mappa_fissa');
disp('Mappa salvata! Ora puoi chiudere il modello Simulink dell UAV.');

disp('Tutti i file .mat sono stati salvati singolarmente con successo!');