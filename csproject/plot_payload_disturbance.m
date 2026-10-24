function plot_payload_disturbance
% PLOT_PAYLOAD_DISTURBANCE
% Clean, easy-to-understand graph for faculty review:
% Shows Altitude Tracking and Motor Thrust under +10kg Payload Drop.
% Zero clutter, clean layout with ample top margin.

    if ~evalin('base', 'exist(''M'', ''var'')')
        evalin('base', 'setup;');
    end
    out = evalin('base', 'sim(''KFFA_LADRC_Quadrotor.slx'');');

    time   = out.tout;
    ref    = squeeze(out.Reference);
    alt    = squeeze(out.Altitude);
    thrust = squeeze(out.Control_Effort);

    M_drone = evalin('base', 'M');
    g_acc   = evalin('base', 'g');

    % Setup figure with generous headroom (no top cutoff!)
    fig = figure('Name', 'Payload Disturbance: Altitude & Thrust', ...
                 'Color', 'white', 'Position', [120, 100, 1000, 680], 'NumberTitle', 'off');

    tiled = tiledlayout(fig, 2, 1, 'Padding', 'loose', 'TileSpacing', 'compact');
    title(tiled, 'Payload Disturbance Adaptation (+10 kg at t = 5.0s)', ...
          'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1]);

    %% 1. Altitude Tracking
    nexttile;
    plot(time, ref, 'k--', 'LineWidth', 1.8, 'DisplayName', 'Target Altitude (5.0 m)'); hold on;
    plot(time, alt, 'Color', [0.0, 0.45, 0.85], 'LineWidth', 2.2, 'DisplayName', 'Actual Altitude (LADRC)');
    xline(5.0, 'Color', [0.85, 0.2, 0.2], 'LineWidth', 1.8, 'DisplayName', 'Payload Drop (+10kg)');
    grid on;
    ylabel('Altitude (m)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Altitude Tracking: 5 cm Momentary Dip & Quick Recovery', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'southeast', 'FontSize', 10);
    xlim([0, 10]); ylim([-0.2, 5.8]);

    %% 2. Control Effort (Thrust)
    nexttile;
    plot(time, thrust, 'Color', [0.85, 0.35, 0.0], 'LineWidth', 2.0, 'DisplayName', 'Total Thrust U_1'); hold on;
    yline(M_drone * g_acc, 'Color', [0.2, 0.5, 0.8], 'LineStyle', '--', 'LineWidth', 1.5, ...
          'DisplayName', 'Dry Hover Weight (98.1 N)');
    yline((M_drone + 10) * g_acc, 'Color', [0.85, 0.2, 0.2], 'LineStyle', '--', 'LineWidth', 1.5, ...
          'DisplayName', 'Loaded Hover Weight (196.0 N)');
    xline(5.0, 'Color', [0.85, 0.2, 0.2], 'LineWidth', 1.8, 'HandleVisibility', 'off');
    grid on;
    xlabel('Time (seconds)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Thrust (N)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Motor Thrust: Automatic Surge & Double Weight Compensation', 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'northwest', 'FontSize', 10);
    xlim([0, 10]); ylim([0, 270]);

    saveas(fig, 'graph_payload_disturbance.png');
    fprintf('Saved graph_payload_disturbance.png successfully.\n');
end
