function ParseStim_AudVid
%% Set Up RX6 and ActiveX Control

% set location of RCXfile
<<<<<<< HEAD
RCXFile = fullfile('AudVis_Circuit.rcx');
=======
RCXFile = fullfile('C:', 'Users', 'Brianna', 'Documents', 'MATLAB',...
    'AudVis_Task', 'AudVis_Circuit.rcx');
>>>>>>> e38de4dc52cf2ea046e10fe76dd5728f52ae1fd1

% setup connection with TDT
RP = actxcontrol('RPco.x',[5 5 26 26]);
set(gcf, 'Visible', 'off');

% attempt to connect to the RX6
if RP.ConnectRX6('GB', 1)
    disp('Connected to RX6!');
else
    disp('Unable to connect to RX6');
end

% load rcx file
if RP.LoadCOF(RCXFile)
    disp('Circuit loaded!');
else
    disp('Failed to load circuit.')
end

% begin running circuit
if RP.Run
    disp('Circuit running.');
else
    disp('Error running circuit.');
end

%% Initialize Serial Port to Receive Data

delete(instrfindall);
s = serial('COM1', 'BaudRate', 9600, 'DataBits', 8, 'Parity', 'None',...
    'StopBits',1,'FlowControl','None','Terminator', 'LF');%, 'TimeOut', .5);
fopen(s);

% set up data structures to store stimulus info
nTrials = str2double(input('Number of trials: ', 's'));
waveforms = cell(nTrials,1);
maskers = cell(nTrials,1);
freq = cell(nTrials,1);
isH = zeros(nTrials,1);
counter = 1;

%% Begin session

sessionRun = 1;
quitNow = 0;
<<<<<<< HEAD
=======
paramFlag = 0;
>>>>>>> e38de4dc52cf2ea046e10fe76dd5728f52ae1fd1

disp('===================== Start of Session ========================');
while sessionRun == 1
    %% Wait for data from serial port
    disp(['========================== Trial ' num2str(counter) ' ============================']);
    
    checkingForStim = true;
    
    while checkingForStim
        data = fscanf(s, '%s');
        disp(['data received: ' data]);
        
        if length(data) >= 6
            try
                [l, h, c, v, spk] = parse(data);
                disp('parsed!')
            catch
                disp('Stimulus string formatted incorrectly.')
                continue
            end
            if paramFlag==1
                checkingForStim = false;
            end
        end
        
        if strcmp(data, 'done')
            sessionRun = 0;
            quitNow = 3;
            break;
        end
    end
    
    if quitNow == 3
        break;
    end
    
    %% Construct and upload stimulus to RX6
    [target_auditory, target_stimulus, frequencies, isHigh,...
        masker_auditory, masker_stimulus] = CreateStimulus(l, h, c, v);
    
    disp('Stimuli created!')
    
    [new_target, new_masker] = AddSpeakerCue(target_stimulus, masker_stimulus);
     
    % save stimulus info
    waveforms{counter} = target_auditory;
    maskers{counter} = masker_auditory;
    freq{counter} = frequencies;
    isH(counter) = isHigh;
    
    %% Trigger stimulus start
    
    % LOAD stimuli to speakers/LEDs
    % if the first speaker is the target
    if strcmp(spk, 'ONE')
        RP.WriteTagVEX('datain1', 0, 'F32', new_target(1,:));
        RP.WriteTagVEX('lightin1', 0, 'F32', new_target(2,:));
        RP.WriteTagVEX('datain2', 0, 'F32', new_masker(1,:));
        RP.WriteTagVEX('lightin2', 0, 'F32', new_masker(2,:));
        drawnow;
    end
    % if the second speaker is the target
    if strcmp(spk, 'TWO')
        RP.WriteTagVEX('datain1', 0, 'F32', new_masker(1,:));
        RP.WriteTagVEX('lightin1', 0, 'F32', new_masker(2,:));
        RP.WriteTagVEX('datain2', 0, 'F32', new_target(1,:));
        RP.WriteTagVEX('lightin2', 0, 'F32', new_target(2,:));
        drawnow;
    end
    
    %tell Mac when loading is done
    fprintf(s, '%s\n', '1');
    disp('Stimuli loaded!');
    
    abortFlag = findTrialStart;
    if abortFlag == 2
        disp('Playing');
        % Play the stimulus
        RP.SoftTrg(1); %Ch1
        RP.SoftTrg(3); %Ch2
<<<<<<< HEAD
        drawnow;
=======
>>>>>>> e38de4dc52cf2ea046e10fe76dd5728f52ae1fd1
    end
    
    % If you receive the stop stimulus
    abortFlag = findTrialStart;
    if abortFlag == 1
        % break out of trial and begin while loop over again
        disp('Aborting Trial');
        RP.SoftTrg(2); %Ch1
        RP.SoftTrg(4); %Ch2
<<<<<<< HEAD
        drawnow;
=======
>>>>>>> e38de4dc52cf2ea046e10fe76dd5728f52ae1fd1
        counter = counter + 1;
        continue;
    end
end

% Close serial port and RX6
RP.Halt;
RP.ClearCOF;
fclose(s);

%% Save stimulus information to file

stim_table = table((1:nTrials)', waveforms, maskers, freq, isH, 'VariableNames',...
    {'trial', 'waveform','masker','tone_frequencies','isHigh'});
data_folder = fullfile('C:', 'Users', 'Brianna', 'Documents', 'MATLAB', 'StimData');
<<<<<<< HEAD
c = clock;
save_filename = ['Stimulus_Data_', num2str(c(1)), num2str(c(2)), ...
    num2str(c(3)), '_', num2str(c(4)), num2str(c(5))];
=======

save_filename = ['Stimulus_Data_', datestr(now, 'yyyymmdd'), '_', ...
    datestr(now, 'HHMM')];
>>>>>>> e38de4dc52cf2ea046e10fe76dd5728f52ae1fd1
save([data_folder filesep save_filename '_table.mat'], 'stim_table');

%% Helper function for parsing data

    function [low, high, coh, vis, spk] = parse(d)
        % Suppose string has form:
        % START.LLLL.HHHH.C.CC.VVV(V).SSS.STOP
        
        % Initialize values
        low = '';
        high = '';
        coh = '';
        vis = '';
        spk = '';
        paramFlag = 0;
        
        % Parse string
        alldat = strsplit(d,'.');
        low = str2double(alldat{2});
        high = str2double(alldat{3});
        coh = str2double(alldat{4})/100;
        vis = alldat{5};
        spk = alldat{6};
        paramFlag = 1;
    end

%% Monitor start signal
    function abortFlag = findTrialStart
        checkAbortFlag = 1;
        while checkAbortFlag == 1
            abortFlag = [];
            
            dat2 = fscanf(s, '%s');
            if strcmp(dat2, 'no')
                abortFlag = 1;
                checkAbortFlag = 0;
            end
            if strcmp(dat2, 'go')
                abortFlag = 2;
                checkAbortFlag = 0;
            end
        end
    end
<<<<<<< HEAD
end
=======
end
>>>>>>> e38de4dc52cf2ea046e10fe76dd5728f52ae1fd1
