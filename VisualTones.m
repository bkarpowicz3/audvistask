function [totalBurst, stimulus, frequencies, isHigh, bursts] = VisualTones(loFreq, hiFreq, c, mode)
%VISUALTONES uses frequency boundaries of the form [loFreq, hiFreq]
%and a coherence factor (c) to produce a sound stimulus of 2 seconds.  The
%coherence is a value between 0 and 1, where 0 means all frequencies are low
%and 1 means all frequencies are high; 0.5 represents 50% low sound bursts
%and 50% high sound bursts.  Mode is a string input that takes the form
%"None", "Low", "High", "Random", or "All" and corresponds to the sounds during which
%the LED should be on (1) versus off (0). No visual stimulus will be
%produced if another string is entered for this value.

timeCounter = 0;
totalBurst = [];
visualBurst = [];
frequencies = [];
bursts = [];

while timeCounter < 4000
    %determine frequency from coherence 
    n = rand;
    if n <= c
        freq = hiFreq;
    else 
        freq = loFreq;
    end 

    %create sine wave from established frequency
    %duration in ms
    duration = 50;
    %sampling frequency in samples/sec
    samplingFreq = 44100; %Hz
    %number of samples needed 
    samples = duration / 1000 * samplingFreq;
    %time vector 
    t = linspace(0, duration, samples);
    %sine vector for one sound burst
    x = sin((2 * pi * (freq/1000)) .* t);

    %gate the sine wave 
    %since 5ms up, 50ms total -> need 1/10 of samples 
    gatedSine = zeros(1, samples);
    %add 0.5 to make whole number of samples
    numRise = (5 / 1000 * samplingFreq);
    numRiseR = numRise + 0.5;
    %ramp up
    gatedSine (1 : numRiseR)= x(1 : numRiseR) ...
        .* (0.2 .* t(1 : numRiseR));
    %flat
    gatedSine(numRiseR + 1 : samples - numRiseR) = ...
        x(numRiseR + 1 : samples - numRiseR);
    %ramp down
    gatedSine(samples - numRiseR + 1: end) = ...
        x(samples - numRiseR + 1 : end) .* ...
        (-0.2 .* t(samples - numRiseR + 1 : end) + 10);
    
    %add time between bursts 
    interval = poissrnd(10);
    pauseBurst = zeros(1, round((interval / 1000 * samplingFreq)));
    
    totalBurst = [totalBurst, gatedSine, pauseBurst];
    timeCounter = timeCounter + duration + interval;
    
    frequencies(end+1) = freq;
    bursts(end+1) = 50;
    bursts(end+1) = interval;
    
    %create visual stimulus 
    %if input string is None
    if strcmp(mode, 'None') 
        visual = zeros(1, length(gatedSine));
    end
    
    %if input string is Low
    if strcmp(mode, 'Low')
        if freq == loFreq
            visual = ones(1, length(gatedSine));
        else 
            visual = zeros(1, length(gatedSine));
        end
    end
    
    %if input string is High
    if strcmp(mode, 'High')
        if freq == hiFreq 
            visual = ones(1, length(gatedSine));
        else
            visual = zeros(1, length(gatedSine));
        end
    end
    
    %if input string is All
    if strcmp(mode, 'All')
        visual = ones(1, length(gatedSine));
    end
    
    %if input string is Random
    if strcmp(mode, 'Random')
        visual2 = ones(1, length(gatedSine));
        interval2 = poissrnd(10);
        interval3 = poissrnd(10);
        pauseBurst2 = zeros(1, round((interval2 / 1000 * samplingFreq)));
        pauseBurst3 = zeros(1, round((interval3 / 1000 * samplingFreq)));
        if isempty(visualBurst)
            visualBurst = pauseBurst2;
        end
        visualBurst = [visualBurst, visual2, pauseBurst3];
    else
        %add onto visual stimulus vector
        visualBurst = [visualBurst, visual, pauseBurst];
    end
        
end

% time = linspace(0, 4000, 2205*4);
% plot(time, visualBurst(1:2205*4));
% hold on; 
% plot(time, totalBurst(1:2205*4));
% ylim([-1.5 1.5])

numLo = sum(frequencies == loFreq);
numHi = sum(frequencies == hiFreq);

isHigh = numHi > numLo;

%if visual vector is shorter than tone vector, add zeros to the end
if length(visualBurst) < length(totalBurst)
    diff = length(totalBurst) - length(visualBurst);
    z = zeros(1, diff);
    visualBurst = [visualBurst, z];
end
%if vector exceeds length of tone vector, cut it off 
visualBurst = visualBurst(1:length(totalBurst));

%concatenate and play
stimulus = cat(1, totalBurst,  visualBurst);
%sound(stimulus, 44100);

end