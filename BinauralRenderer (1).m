function BinauralRenderer()
    % Load HRIR dataset
    data = load('ReferenceHRTF.mat');  % Ensure this file exists
    hrtfData = data.hrtfData;  
    sourcePosition = data.sourcePosition;
    
    % Load sound file
    [audio, fs] = audioread('white-noise.wav');  % Ensure 'audio.wav' exists
    
    % Convert to mono if stereo
    if size(audio, 2) > 1
        audio = mean(audio, 2);
    end
    
    % Create GUI
    fig = uifigure('Name', 'Binaural Renderer', 'Position', [100, 100, 600, 500]);
    
    % Axes for selecting speaker position
    ax = uiaxes(fig, 'Position', [50, 250, 300, 200]);
    title(ax, 'Select Speaker Position');
    xlabel(ax, 'X meters (Left \leftrightarrow Right)'); 
    ylabel(ax, 'Y meters (Back \leftrightarrow Front)');
    xlim(ax, [-1,1]); ylim(ax, [-1,1]);  
    grid(ax, 'on'); hold(ax, 'on');
    
    % Plot listener (origin)
    plot(ax, 0, 0, 'ro', 'MarkerSize', 10, 'DisplayName', 'Listener');
    speakerMarker = plot(ax, NaN, NaN, 'bx', 'MarkerSize', 10, 'DisplayName', 'Speaker');

    % User input for elevation (phi)
    uilabel(fig, 'Text', 'Elevation (φ in °):', 'Position', [400, 350, 100, 20]);
    phiField = uieditfield(fig, 'numeric', 'Position', [500, 350, 80, 20]);

    % Buttons
    renderBtn = uibutton(fig, 'Text', 'Render & Play', 'Position', [450, 300, 120, 30], ...
        'ButtonPushedFcn', @(btn, event) processBinauralAudio());
    
    stopBtn = uibutton(fig, 'Text', 'Stop', 'Position', [450, 250, 120, 30], ...
        'ButtonPushedFcn', @(btn, event) stopAudio(), 'Enable', 'off');

    % Axes for waveform visualization
    axWaveform = uiaxes(fig, 'Position', [50, 50, 500, 150]);
    title(axWaveform, 'Rendered Audio Waveform');
    xlabel(axWaveform, 'Time (samples)'); ylabel(axWaveform, 'Amplitude');

    % Audio placeholders
    binauralAudio = [];
    speakerPos = [0, 0];
    audioPlayer = [];

    % Select speaker position in 4 quadrants
    ax.ButtonDownFcn = @selectSpeaker;
    
    function selectSpeaker(~, event)
        if isempty(event.IntersectionPoint)
            return;
        end
        pos = event.IntersectionPoint(1:2);
        set(speakerMarker, 'XData', pos(1), 'YData', pos(2));
        speakerPos = pos;
    end

    % Function to process binaural rendering
    function processBinauralAudio()
        % Calculate azimuth (θ) and distance (r)
        [theta, r] = cart2pol(speakerPos(2), speakerPos(1));  % Swap X and Y
        theta = mod(rad2deg(theta), 360);  % Ensure 0° to 360° range


        theta = mod(theta + 360, 360); % Ensure theta is in [0, 360] range
        phi = phiField.Value;     % Elevation

        % Find closest HRIR index using Euclidean distance
        distances = sqrt(sum((sourcePosition(:,1:2) - [theta, phi]).^2, 2));
        [~, index] = min(distances);
        
        % Extract HRIR for left and right ears
        hrirLeft = squeeze(hrtfData(:, index, 1));
        hrirRight = squeeze(hrtfData(:, index, 2));
        
        % Convolve input sound with HRIRs
        leftEar = conv(audio, hrirLeft, 'same');
        rightEar = conv(audio, hrirRight, 'same');
        
        % Apply distance-based attenuation
        attenuation = 1 / (1 + 0.05 * r);  % More gradual scaling
        binauralAudio = attenuation * [rightEar, leftEar];

        % Normalize audio
        binauralAudio = binauralAudio / max(abs(binauralAudio(:)));

        % Save and enable buttons
        audiowrite('rendered_binaural.wav', binauralAudio, fs);
        set(stopBtn, 'Enable', 'on');

        % Plot the waveform
        plot(axWaveform, binauralAudio(:,1));  
        hold(axWaveform, 'on');
        plot(axWaveform, binauralAudio(:,2));  
        hold(axWaveform, 'off');
        legend(axWaveform, 'Left Ear', 'Right Ear');

        % Play the audio immediately
        audioPlayer = audioplayer(binauralAudio, fs);
        play(audioPlayer);
    end

    % Function to stop audio
    function stopAudio()
        if ~isempty(audioPlayer)
            stop(audioPlayer);
        end
    end
end
