function plot_wind_disturbance
% PLOT_WIND_DISTURBANCE
% Clean, easy-to-understand graph for faculty review:
% Shows Crosswind Profile, Drone Pitch Tilt, and Station Drift (LADRC vs PID).
% Zero clutter, clean layout with ample top margin.

    sim_res = simulate_wind_disturbance;

    time      = sim_res.time;
    v_wind    = sim_res.V_wind;
    x_ladrc   = sim_res.X_ladrc(:, 1);
    pitch_deg = rad2deg(sim_res.X_ladrc(:, 8));
    x_pid     = sim_res.X_pid(:, 1);

    % Setup figure with generous headroom (no top cutoff!)
    fig = figure('Name', 'Wind Disturbance: Wind, Tilt & Station Drift', ...
                 'Color', 'white', 'Position', [140, 80, 1000, 780], 'NumberTitle', 'off');

    tiled = tiledlayout(fig, 3, 1, 'Padding', 'loose', 'TileSpacing', 'compact');
    title(tiled, 'Autonomous Quadrotor Wind Disturbance Operation', ...
          'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1]);

    %% 1. Wind Speed
    nexttile;
    plot(time, v_wind, 'Color', [0.0, 0.55, 0.85], 'LineWidth', 2.2, 'DisplayName', 'Crosswind Speed (m/s)');
    grid on;
    ylabel('Wind (m/s)', 'FontSize', 11, 'FontWeight', 'bold');
    title('1. Crosswind Gust Profile (10 m/s from t = 2.0s to 7.0s)', 'FontSize', 11.5, 'FontWeight', 'bold');
    xlim([0, 10]); ylim([0, 12]);
    legend('Location', 'northeast', 'FontSize', 9.5);

    %% 2. Pitch Angle Tilt
    nexttile;
    plot(time, pitch_deg, 'Color', [0.0, 0.65, 0.25], 'LineWidth', 2.2, 'DisplayName', 'Drone Pitch Tilt \theta(t)'); hold on;
    yline(0, 'k:', 'LineWidth', 1.2, 'DisplayName', 'Level Horizon (0°)');
    grid on;
    ylabel('Pitch (°)', 'FontSize', 11, 'FontWeight', 'bold');
    title('2. Autonomous Attitude Adaptation: Tilting into Wind to Counter Drag', 'FontSize', 11.5, 'FontWeight', 'bold');
    xlim([0, 10]); ylim([-10, 2]);
    legend('Location', 'southeast', 'FontSize', 9.5);

    %% 3. Station Keeping (LADRC vs PID)
    nexttile;
    plot(time, x_ladrc, 'Color', [0.0, 0.65, 0.25], 'LineWidth', 2.4, 'DisplayName', 'LADRC Drift (Locked < 0.05 m)'); hold on;
    plot(time, x_pid, 'Color', [0.85, 0.15, 0.15], 'LineStyle', '--', 'LineWidth', 1.8, 'DisplayName', 'Conventional PID Drift');
    yline(0, 'Color', [0.4, 0.4, 0.4], 'LineStyle', ':', 'LineWidth', 1.2, 'DisplayName', 'Target Position (0 m)');
    grid on;
    xlabel('Time (seconds)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Drift X (m)', 'FontSize', 11, 'FontWeight', 'bold');
    title('3. Horizontal Drift: LADRC Holds Station vs PID Drifting Off-Course', 'FontSize', 11.5, 'FontWeight', 'bold');
    xlim([0, 10]); ylim([-0.2, 2.5]);
    legend('Location', 'northwest', 'FontSize', 9.5);

    saveas(fig, 'graph_wind_disturbance.png');
    fprintf('Saved graph_wind_disturbance.png successfully.\n');
end
