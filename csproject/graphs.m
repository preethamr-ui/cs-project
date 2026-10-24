% Clear old figures and command window to prevent ghost plotting
close all; 
clc;

% Extract data from Simulink 'out' object and flatten arrays
time = out.tout;
ref = squeeze(out.Reference);
alt = squeeze(out.Altitude);
thrust = squeeze(out.Control_Effort);

%% Figure 1: FA-LADRC Altitude Tracking
% Opens a figure explicitly named "Figure 1: Altitude Tracking"
figure('Name', 'Figure 1: Altitude Tracking', 'NumberTitle', 'off');
plot(time, ref, 'k--', 'LineWidth', 1.5); hold on;
plot(time, alt, 'b-', 'LineWidth', 2);
xlabel('Time (s)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Altitude (meters)', 'FontSize', 11, 'FontWeight', 'bold');
title('Figure 1: FA-LADRC Altitude Tracking under Payload Disturbance');
legend('Target Reference', 'Actual Altitude (FA-LADRC)', 'Location', 'southeast');
grid on;
xlim([0 10]);

%% Figure 2: Controller Output (Thrust)
% Opens a figure explicitly named "Figure 2: Control Effort (Thrust)"
figure('Name', 'Figure 2: Control Effort (Thrust)', 'NumberTitle', 'off');
plot(time, thrust, 'r-', 'LineWidth', 1.5);
xlabel('Time (s)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Total Thrust U1 (Newtons)', 'FontSize', 11, 'FontWeight', 'bold');
title('Figure 2: FA-LADRC Control Effort (Motor Thrust)');
grid on;
xlim([0 10]);
ylim([0 360]);