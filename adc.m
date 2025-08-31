% Comunicaciones Digitales UMNG / jose.rugeles@Unimilitar.edu.co
% Programa: muestreo
M = readmatrix('/MATLAB Drive/adc_capture_patron50Hz.csv');  %Cargar datos del archivo Señal.CSV
tiempo = M(:,2) * 1e-6; 
voltaje = M(:,6);
phi=5;        % angulo de desfase
f = 50;        % frecuencia de la señal (Hz)
T = 1/f;       % periodo (s)
DC= 1.6;       % 
A = 1.65;      % amplitud (V)
NT = 2;        % nº de periodos a capturar
N = 40;        % nº de muestras por periodo
ts = T/N;      % periodo de muestreo (s)

% Vector de tiempo para las muestras (N*NT puntos exactos)
t = 0:ts:(NT*T - ts);
V = DC + A * sin(2*pi*f*t+phi);  % señal muestreada

% Señal continua para comparación
t_cont = 0:ts/20:NT*T;
V_cont = DC + A * sin(2*pi*f*t_cont+phi);

% ===== Gráfica =====
figure('Position',[100 100 900 400]);  % tamaño ventana
plot(t_cont, V_cont, 'b-', 'LineWidth',2); hold on;
stem(t, V, 'r','filled','LineWidth',1.5);
plot(tiempo, voltaje, 'g--o','LineWidth',1.2, ...
     'MarkerSize',4,'MarkerFaceColor','g');
stem(tiempo, voltaje, 'g','filled','LineWidth',1.2);

xlabel('Tiempo (s)','FontSize',20,'FontWeight','bold');
ylabel('Voltaje (V)','FontSize',20,'FontWeight','bold');
title(sprintf('Muestreo de un seno f=%d Hz, N=%d muestras/periodo', f, N), ...
      'FontSize',20,'FontWeight','bold');

legend({'Señal continua','Muestras teóricas','Muestras reales (CSV)'},'FontSize',14,'Location','best');
grid on;
set(gca,'FontSize',16,'LineWidth',1.2); 
