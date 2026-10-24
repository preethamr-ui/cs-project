function quadrotor_2d_simulation(varargin)
% QUADROTOR_2D_SIMULATION
% Clean 2D Side-Elevation Simulation of Autonomous Quadrotor UAV:
% - Drone ascends and hovers stably at Z = 5.0m
% - Wind gust blows (t=2s to 7s): Drone visibly tilts nose-down into wind
% - Payload attached (t=5s): Drone recovers from 5cm sag, payload swings
% - Clean display: Zero clutter, no giant HUD, no broken legends!

    p = inputParser;
    addParameter(p, 'SpeedUp', 1.0, @isnumeric);
    addParameter(p, 'SaveGif', false, @islogical);
    addParameter(p, 'GifFileName', 'quadrotor_2d_simulation.gif', @ischar);
    addParameter(p, 'MaxFrames', inf, @isnumeric);
    parse(p, varargin{:});

    speed_factor = p.Results.SpeedUp;
    save_gif     = p.Results.SaveGif;
    gif_filename = p.Results.GifFileName;
    max_frames   = p.Results.MaxFrames;

    %% Run verified physics
    sim_res = simulate_wind_disturbance;
    time       = sim_res.time;
    x_ladrc    = sim_res.X_ladrc(:, 1);
    z_ladrc    = sim_res.X_ladrc(:, 3);
    pitch_rad  = sim_res.X_ladrc(:, 8);
    u1_thrust  = sim_res.U_ladrc(:, 1);
    v_wind     = sim_res.V_wind;
    swing_rad  = sim_res.payload_swing;

    % Downsample to 30 FPS
    dt_anim = 1 / 30;
    t_anim  = (0:dt_anim:time(end))';
    x_a     = interp1(time, x_ladrc, t_anim);
    z_a     = interp1(time, z_ladrc, t_anim);
    th_a    = interp1(time, pitch_rad, t_anim);
    u1_a    = interp1(time, u1_thrust, t_anim);
    wind_a  = interp1(time, v_wind, t_anim);
    sw_a    = interp1(time, swing_rad, t_anim);

    n_frames = length(t_anim);
    if isfinite(max_frames); n_frames = min(n_frames, max_frames); end

    %% Setup Figure (Clean, Uncluttered, Max Visual Focus)
    fig = figure('Name', '2D Quadrotor Flight Simulation', ...
                 'Color', [0.08, 0.11, 0.16], 'Position', [100, 80, 1100, 720], 'NumberTitle', 'off');

    ax2d = axes('Parent', fig, 'Position', [0.08, 0.10, 0.86, 0.82]);
    hold(ax2d, 'on'); grid(ax2d, 'on');
    set(ax2d, 'Color', [0.10, 0.13, 0.19], ...
              'XColor', [0.6, 0.7, 0.8], 'YColor', [0.6, 0.7, 0.8], ...
              'GridColor', [0.25, 0.35, 0.45], 'GridAlpha', 0.35, 'FontSize', 11);
    xlabel(ax2d, 'Horizontal Position X (meters)   [\rightarrow Wind Direction]', 'FontWeight', 'bold', 'Color', [0.8, 0.9, 1.0]);
    ylabel(ax2d, 'Altitude Z (meters)', 'FontWeight', 'bold', 'Color', [0.8, 0.9, 1.0]);
    title(ax2d, '2D Side Elevation: Autonomous Drone Adapting to Wind & Payload Disturbances', ...
          'Color', 'white', 'FontSize', 13, 'FontWeight', 'bold');
    xlim(ax2d, [-2.2, 2.2]); ylim(ax2d, [-0.4, 6.2]);

    % Ground line & Launch pad
    plot(ax2d, [-3, 3], [0, 0], 'Color', [0.4, 0.5, 0.6], 'LineWidth', 2.5);
    patch(ax2d, [-0.6, 0.6, 0.6, -0.6], [-0.12, -0.12, 0, 0], [0.2, 0.25, 0.3], 'EdgeColor', [0.3, 0.6, 0.9], 'LineWidth', 1.5);
    text(ax2d, 0, -0.06, 'LAUNCH PAD', 'Color', [0.85, 0.75, 0.2], 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'FontSize', 9);

    % Target Altitude Line (5.0m)
    yline(ax2d, 5.0, 'Color', [0.0, 0.85, 1.0], 'LineStyle', '--', 'LineWidth', 1.6);
    text(ax2d, -2.0, 5.2, 'Target Hover (5.0 m)', 'Color', [0.0, 0.85, 1.0], 'FontWeight', 'bold', 'FontSize', 10);

    % Flight Trail
    h_trail = plot(ax2d, 0, 0, 'Color', [0.2, 1.0, 0.4], 'LineWidth', 2.0);

    % Flowing Wind Arrows
    n_wind = 6;
    h_wind = gobjects(n_wind, 1);
    wind_y = linspace(2.5, 5.5, n_wind);
    for w = 1:n_wind
        h_wind(w) = quiver(ax2d, -1.9, wind_y(w), 0.5, 0, 0, ...
                           'Color', [0.2, 0.85, 1.0, 0.7], 'LineWidth', 2.2, 'MaxHeadSize', 0.8, 'Visible', 'off');
    end

    % Drone Body Elements
    l_arm = 0.44;
    h_bar = plot(ax2d, [-l_arm, l_arm], [0, 0], 'Color', [0.9, 0.95, 1.0], 'LineWidth', 5);
    h_body = plot(ax2d, 0, 0, 's', 'MarkerSize', 16, 'MarkerFaceColor', [0.15, 0.5, 0.9], 'MarkerEdgeColor', 'cyan', 'LineWidth', 2);
    h_nose = plot(ax2d, [0, 0.22], [0, 0], 'Color', [1.0, 0.2, 0.2], 'LineWidth', 3.5);

    % Rotors
    r_span = 0.16;
    h_rot_L = plot(ax2d, [-l_arm-r_span, -l_arm+r_span], [0.04, 0.04], 'Color', [0.3, 0.8, 1.0], 'LineWidth', 3.5);
    h_rot_R = plot(ax2d, [l_arm-r_span, l_arm+r_span], [0.04, 0.04], 'Color', [0.3, 0.8, 1.0], 'LineWidth', 3.5);

    % Downward Thrust Vectors
    h_thr_L = quiver(ax2d, -l_arm, 0, 0, -0.4, 0, 'Color', [1.0, 0.6, 0.1], 'LineWidth', 2.2, 'MaxHeadSize', 0.8);
    h_thr_R = quiver(ax2d, l_arm, 0, 0, -0.4, 0, 'Color', [1.0, 0.6, 0.1], 'LineWidth', 2.2, 'MaxHeadSize', 0.8);

    % Slung Cable & Payload Box
    h_cable = plot(ax2d, [0, 0], [0, -0.5], 'Color', [1.0, 0.85, 0.2], 'LineWidth', 2.5, 'Visible', 'off');
    h_box   = patch(ax2d, [-0.12, 0.12, 0.12, -0.12], [-0.62, -0.62, -0.38, -0.38], ...
                    [1.0, 0.8, 0.1], 'EdgeColor', 'black', 'LineWidth', 1.5, 'Visible', 'off');

    % Minimal clean status bar at the top (unobtrusive!)
    h_status = text(ax2d, 0, 5.9, 'Time: 0.00s | Altitude: 0.00m', ...
                    'Color', 'yellow', 'FontName', 'Consolas', 'FontSize', 11, ...
                    'FontWeight', 'bold', 'HorizontalAlignment', 'center');

    %% Animation Loop
    fprintf('Running clean 2D simulation...\n');
    tic;
    for k = 1:n_frames
        if ~ishandle(fig); break; end

        cur_t   = t_anim(k);
        cur_x   = x_a(k);
        cur_z   = z_a(k);
        cur_th  = th_a(k);
        cur_u1  = u1_a(k);
        cur_w   = wind_a(k);
        cur_sw  = sw_a(k);

        % Rotation in X-Z plane
        c = cos(cur_th); s = sin(cur_th);
        rot = @(dx, dz) [c*dx - s*dz; s*dx + c*dz];

        % Crossbar
        pL = [cur_x; cur_z] + rot(-l_arm, 0);
        pR = [cur_x; cur_z] + rot(l_arm, 0);
        set(h_bar, 'XData', [pL(1), pR(1)], 'YData', [pL(2), pR(2)]);

        % Fuselage & nose
        set(h_body, 'XData', cur_x, 'YData', cur_z);
        pN = [cur_x; cur_z] + rot(0.22, 0);
        set(h_nose, 'XData', [cur_x, pN(1)], 'YData', [cur_z, pN(2)]);

        % Rotors
        rL1 = [cur_x; cur_z] + rot(-l_arm - r_span, 0.04);
        rL2 = [cur_x; cur_z] + rot(-l_arm + r_span, 0.04);
        rR1 = [cur_x; cur_z] + rot(l_arm - r_span, 0.04);
        rR2 = [cur_x; cur_z] + rot(l_arm + r_span, 0.04);
        set(h_rot_L, 'XData', [rL1(1), rL2(1)], 'YData', [rL1(2), rL2(2)]);
        set(h_rot_R, 'XData', [rR1(1), rR2(1)], 'YData', [rR1(2), rR2(2)]);

        % Thrust vectors
        t_len = max(0.15, (cur_u1 / 350.0) * 0.7);
        t_vec = rot(0, -t_len);
        set(h_thr_L, 'XData', pL(1), 'YData', pL(2), 'UData', t_vec(1), 'VData', t_vec(2));
        set(h_thr_R, 'XData', pR(1), 'YData', pR(2), 'UData', t_vec(1), 'VData', t_vec(2));

        % Trail
        set(h_trail, 'XData', x_a(1:k), 'YData', z_a(1:k));

        % Wind arrows
        is_wind = (cur_w > 0.5);
        for w = 1:n_wind
            if is_wind
                set(h_wind(w), 'Visible', 'on', 'UData', min(1.2, cur_w * 0.10));
            else
                set(h_wind(w), 'Visible', 'off');
            end
        end

        % Slung Payload
        is_load = (cur_t >= 5.0);
        if is_load
            cable_L = 0.50;
            p_bx = cur_x + cable_L * sin(cur_sw);
            p_bz = cur_z - cable_L * cos(cur_sw);
            set(h_cable, 'Visible', 'on', 'XData', [cur_x, p_bx], 'YData', [cur_z, p_bz]);
            bw = 0.12; bh = 0.12;
            set(h_box, 'Visible', 'on', ...
                       'XData', [p_bx - bw, p_bx + bw, p_bx + bw, p_bx - bw], ...
                       'YData', [p_bz - bh, p_bz - bh, p_bz + bh, p_bz + bh]);
        else
            set(h_cable, 'Visible', 'off');
            set(h_box, 'Visible', 'off');
        end

        % Clean Status Line
        status_txt = sprintf('Time: %4.2fs | Altitude: %4.2fm | Pitch: %+4.1f° | Wind: %4.1fm/s | %s', ...
                             cur_t, cur_z, rad2deg(cur_th), cur_w, ...
                             ternary(is_load, 'Payload: +10kg Attached', 'Payload: Detached'));
        set(h_status, 'String', status_txt);

        drawnow;

        if save_gif && mod(k, 2) == 0
            frame = getframe(fig);
            im = frame2im(frame);
            [imind, cm] = rgb2ind(im, 256);
            if k == 1 || ~exist(gif_filename, 'file')
                imwrite(imind, cm, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', 2*dt_anim/speed_factor);
            else
                imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', 2*dt_anim/speed_factor);
            end
        end

        expected = cur_t / speed_factor;
        elapsed  = toc;
        if elapsed < expected; pause(expected - elapsed); end
    end
end

function out = ternary(c, t, f)
    if c; out = t; else; out = f; end
end
