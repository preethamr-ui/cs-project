function plot_wind_graphs
% PLOT_WIND_GRAPHS
% Displays Wind Disturbance graphs in separate, individual figure windows.
% - Scaled for 16 m/s strong crosswind gust (~58 km/h)
% - Full headroom: No clipped peaks, ample margins!
% - Zero clutter, clean layout with visible titles.

    sim_res = simulate_wind_disturbance;

    time      = sim_res.time;
    v_wind    = sim_res.V_wind;
    x_ladrc   = sim_res.X_ladrc(:, 1);
    pitch_deg = rad2deg(sim_res.X_ladrc(:, 8));
    x_pid     = sim_res.X_pid(:, 1);

    %% WINDOW 1: Crosswind Speed Profile (Full Headroom: ylim up to 20 m/s)
    fig1 = figure('Name', 'Figure 1: Crosswind Speed Profile', ...
                  'Color', 'white', 'Position', [80, 480, 850, 480], 'NumberTitle', 'off');
    ax1 = axes('Parent', fig1, 'Position', [0.12, 0.12, 0.80, 0.72]);
    hold(ax1, 'on'); grid(ax1, 'on');
    set(ax1, 'FontSize', 11, 'LineWidth', 1.1);

    plot(ax1, time, v_wind, 'Color', [0.0, 0.55, 0.85], 'LineWidth', 2.4, 'DisplayName', 'Crosswind Speed (m/s)');
    xline(ax1, 2.0, 'Color', [0.5, 0.5, 0.5], 'LineStyle', ':', 'LineWidth', 1.4);
    xline(ax1, 7.0, 'Color', [0.5, 0.5, 0.5], 'LineStyle', ':', 'LineWidth', 1.4);

    xlabel(ax1, 'Time (seconds)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel(ax1, 'Wind Velocity (m/s)', 'FontSize', 12, 'FontWeight', 'bold');
    title(ax1, 'Crosswind Speed Profile (t = 2s to 7s)', ...
          'FontSize', 13, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1]);
    legend(ax1, 'Location', 'northeast', 'FontSize', 11);
    xlim(ax1, [0, 15]); ylim(ax1, [0, 20]);
    saveas(fig1, 'graph_wind_profile.png');

    %% WINDOW 2: Drone Pitch Tilt Adaptation (Full Headroom: ylim down to -20 deg)
    fig2 = figure('Name', 'Figure 2: Autonomous Pitch Tilt Adaptation', ...
                  'Color', 'white', 'Position', [950, 480, 850, 480], 'NumberTitle', 'off');
    ax2 = axes('Parent', fig2, 'Position', [0.12, 0.12, 0.80, 0.72]);
    hold(ax2, 'on'); grid(ax2, 'on');
    set(ax2, 'FontSize', 11, 'LineWidth', 1.1);

    plot(ax2, time, pitch_deg, 'Color', [0.0, 0.65, 0.25], 'LineWidth', 2.4, 'DisplayName', 'Pitch Tilt \theta(t)');
    yline(ax2, 0, 'k:', 'LineWidth', 1.4, 'DisplayName', 'Level Horizon (0°)');
    xline(ax2, 2.0, 'Color', [0.5, 0.5, 0.5], 'LineStyle', ':', 'LineWidth', 1.4);
    xline(ax2, 7.0, 'Color', [0.5, 0.5, 0.5], 'LineStyle', ':', 'LineWidth', 1.4);

    xlabel(ax2, 'Time (seconds)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel(ax2, 'Pitch Angle \theta (°)', 'FontSize', 12, 'FontWeight', 'bold');
    title(ax2, 'Autonomous Pitch Tilt Adaptation into Strong Wind', ...
          'FontSize', 13, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1]);
    legend(ax2, 'Location', 'southeast', 'FontSize', 11);
    xlim(ax2, [0, 15]); ylim(ax2, [-20, 4]);
    saveas(fig2, 'graph_wind_tilt.png');

    %% WINDOW 3: Station Keeping Comparison (LADRC vs PID)
    fig3 = figure('Name', 'Figure 3: Station Keeping Drift Comparison', ...
                  'Color', 'white', 'Position', [500, 40, 880, 500], 'NumberTitle', 'off');
    ax3 = axes('Parent', fig3, 'Position', [0.12, 0.12, 0.80, 0.72]);
    hold(ax3, 'on'); grid(ax3, 'on');
    set(ax3, 'FontSize', 11, 'LineWidth', 1.1);

    plot(ax3, time, x_ladrc, 'Color', [0.0, 0.65, 0.25], 'LineWidth', 2.5, 'DisplayName', 'KF-FA-LADRC (Locked < 0.05 m)');
    plot(ax3, time, x_pid, 'Color', [0.85, 0.15, 0.15], 'LineStyle', '--', 'LineWidth', 2.0, 'DisplayName', 'Conventional PID (Drifting Off-Course)');
    yline(ax3, 0, 'Color', [0.4, 0.4, 0.4], 'LineStyle', ':', 'LineWidth', 1.4, 'DisplayName', 'Target Station (0 m)');
    xline(ax3, 2.0, 'Color', [0.5, 0.5, 0.5], 'LineStyle', ':', 'LineWidth', 1.4);

    xlabel(ax3, 'Time (seconds)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel(ax3, 'Horizontal Drift X (meters)', 'FontSize', 12, 'FontWeight', 'bold');
    title(ax3, 'Station Keeping: Active Disturbance Rejection vs Conventional PID', ...
          'FontSize', 13, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1]);
    legend(ax3, 'Location', 'northwest', 'FontSize', 11);
    xlim(ax3, [0, 15]); ylim(ax3, [-0.2, 3.5]);
    saveas(fig3, 'graph_wind_drift.png');

    fprintf('Wind graphs displayed in 3 separate windows and saved successfully.\n');
end
