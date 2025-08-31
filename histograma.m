% === Lectura del archivo CSV ===
% Formato esperado: columna 1 = voltaje, columna 2 = frecuencia
M = readmatrix('/MATLAB Drive/histograma/histograma2.2Vpp.txt');  

voltaje_bin = M(:,1);   % valores de voltaje
frecuencia = M(:,2);   % frecuencia asociada a cada valor
voltaje= 2+ ((voltaje_bin*3.3)/4095);
% === Cálculos estadísticos ===
N_total  = sum(frecuencia);                         
media    = sum(voltaje .* frecuencia) / N_total;    % media ponderada
varianza = sum(frecuencia .* (voltaje - media).^2) / N_total;
desv_est = sqrt(varianza);                          % desviación estándar

% === Mostrar resultados en consola ===
fprintf('Media = %.4f V\n', media);
fprintf('Desviacion estandar = %.4f V\n', desv_est);

% === Gráfica ===
figure('Position',[100 100 900 450]);

% Gráfico de barras de la distribución
bar(voltaje, frecuencia, 'FaceColor',[0.2 0.6 0.8], 'EdgeColor','k'); 
hold on;

% Línea vertical en la media
h1 = xline(media, 'r', 'LineWidth',2, 'Label','Media', 'LabelOrientation','horizontal', 'LabelVerticalAlignment','bottom');

% Líneas en media ± desviación estándar
h2 = xline(media - desv_est, '--g', 'LineWidth',2, 'Label','Media - σ', 'LabelVerticalAlignment','bottom');
h3 = xline(media + desv_est, '--g', 'LineWidth',2, 'Label','Media + σ', 'LabelVerticalAlignment','bottom');

% Añadir texto en la gráfica con los valores
yl = ylim; % límites del eje Y
text(media, yl(2)*0.9, sprintf('\\mu = %.3f V', media), 'Color','r','FontSize',12,'FontWeight','bold','HorizontalAlignment','center');
text(media+desv_est, yl(2)*0.8, sprintf('\\sigma = %.3f V', desv_est), 'Color','g','FontSize',12,'FontWeight','bold','HorizontalAlignment','left');

xlabel('Voltaje (V)','FontSize',14,'FontWeight','bold');
ylabel('Frecuencia','FontSize',14,'FontWeight','bold');
title('histograma señal con 2.7 voltios pico','FontSize',16,'FontWeight','bold');

legend([h1 h2 h3], {'Media','Media - σ','Media + σ'}, 'FontSize',12,'Location','best');
grid on;
set(gca,'FontSize',12,'LineWidth',1.2);
