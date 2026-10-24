function plot_payload_graphs(varargin)
% PLOT_PAYLOAD_GRAPHS
% Displays Payload Disturbance graphs in separate, individual figure windows.
% Usage:
%   plot_payload_graphs       % Uses current workspace mass (or default 30 kg)
%   plot_payload_graphs(15)   % Runs with custom payload mass (e.g., 15 kg)

    % Allow passing payload mass directly as an argument
    if nargin >= 1 && isnumeric(varargin{1})
        assignin('base', 'm_payload_val', varargin{1});
        assignin('base', 'm_load', varargin{1});
    end

    if ~evalin('base', 'exist(''m_payload_val'', ''var'')')
        evalin('base', 'setup;');
    end
    out = evalin('base', 'sim(''KFFA_LADRC_Quadrotor.slx'');');

    time   = out.tout;
    ref    = squeeze(out.Reference);
    alt    = squeeze(out.Altitude);
    thrust = squeeze(out.Control_Effort);

    M_drone   = evalin('base', 'M');
    g_acc     = evalin('base', 'g');
    m_payload = evalin('base', 'm_payload_val');

    %% WINDOW 1: Altitude Tracking (Full Headroom: ylim up to 8.5 m)
    fig1 = figure('Name', 'Figure 1: Altitude Response', ...
                  'Color', 'white', 'Position', [80, 220, 880, 540], 'NumberTitle', 'off');
    ax1 = axes('Parent', fig1, 'Position', [0.12, 0.12, 0.80, 0.72]);
    hold(ax1, 'on'); grid(ax1, 'on');
    set(ax1, 'FontSize', 11, 'LineWidth', 1.1);

    plot(ax1, time, ref, 'k--', 'LineWidth', 2.0, 'DisplayName', 'Target Height (5.0 m)');
    plot(ax1, time, alt, 'Color', [0.0, 0.45, 0.85], 'LineWidth', 2.4, 'DisplayName', 'Actual Altitude (LADRC)');
    xline(ax1, 5.0, 'Color', [0.85, 0.2, 0.2], 'LineWidth', 2.0, 'DisplayName', 'Payload Attachment (t = 5s)');

    xlabel(ax1, 'Time (seconds)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel(ax1, 'Altitude Z (meters)', 'FontSize', 12, 'FontWeight', 'bold');
    title(ax1, 'Altitude Tracking: Takeoff & Disturbance Rejection', ...
          'FontSize', 13, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1]);
    legend(ax1, 'Location', 'northeast', 'FontSize', 11);
    xlim(ax1, [0, 15]);
    ylim(ax1, [0, 8.5]); % Ample headroom for 6.77m peak!

    saveas(fig1, 'graph_payload_altitude.png');

    %% WINDOW 2: Motor Thrust Effort (Full Headroom: ylim up to 620 N)
    fig2 = figure('Name', 'Figure 2: Control Effort (Thrust)', ...
                  'Color', 'white', 'Position', [980, 220, 880, 540], 'NumberTitle', 'off');
    ax2 = axes('Parent', fig2, 'Position', [0.12, 0.12, 0.80, 0.72]);
    hold(ax2, 'on'); grid(ax2, 'on');
    set(ax2, 'FontSize', 11, 'LineWidth', 1.1);

    plot(ax2, time, thrust, 'Color', [0.85, 0.35, 0.0], 'LineWidth', 2.2, 'DisplayName', 'Motor Thrust U_1');
    yline(ax2, M_drone * g_acc, 'Color', [0.2, 0.5, 0.8], 'LineStyle', '--', 'LineWidth', 1.6, ...
          'DisplayName', 'Dry Hover Baseline');
    yline(ax2, (M_drone + m_payload) * g_acc, 'Color', [0.85, 0.2, 0.2], 'LineStyle', '--', 'LineWidth', 1.6, ...
          'DisplayName', 'Loaded Hover Baseline');
    xline(ax2, 5.0, 'Color', [0.85, 0.2, 0.2], 'LineWidth', 2.0, 'HandleVisibility', 'off');

    xlabel(ax2, 'Time (seconds)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel(ax2, 'Motor Thrust U_1 (Newtons)', 'FontSize', 12, 'FontWeight', 'bold');
    title(ax2, 'Control Effort: Active Thrust Surge & Load Compensation', ...
          'FontSize', 13, 'FontWeight', 'bold', 'Color', [0.1, 0.1, 0.1]);
    legend(ax2, 'Location', 'northwest', 'FontSize', 11);
    xlim(ax2, [0, 15]);
    ylim(ax2, [0, 620]); % Ample headroom for thrust surge!

    saveas(fig2, 'graph_payload_thrust.png');

    fprintf('Payload graphs displayed in 2 separate windows and saved successfully.\n');
end
