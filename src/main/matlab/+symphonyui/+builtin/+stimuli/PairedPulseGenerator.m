classdef PairedPulseGenerator < symphonyui.core.StimulusGenerator
    % Generates a single rectangular pulse stimulus.
    
    properties
        preTime			% Leading duration (ms)
        stimTime1		% First pulse duration (ms)
		inTime		    % Between paired pulses duration (ms)
		stimTime2		% Second pulse duration (ms)
        tailTime	    % Trailing duration (ms)
        amplitude		% Pulse amplitude (units)
        mean			% Mean amplitude (units)
        sampleRate		% Sample rate of generated stimulus (Hz)
        units			% Units of generated stimulus
    end
    
    methods
        
        function obj = PairedPulseGenerator(map)
            if nargin < 1
                map = containers.Map();
            end
            obj@symphonyui.core.StimulusGenerator(map);
        end
        
    end
    
    methods (Access = protected)
        
        function s = generateStimulus(obj)
            import Symphony.Core.*;
            
            timeToPts = @(t)(round(t / 1e3 * obj.sampleRate));
            
			% First pulse
            prePts = timeToPts(obj.preTime);
            stimPts = timeToPts(obj.stimTime1);
            tailPts = timeToPts(0);
            data1 = ones(1, prePts + stimPts + tailPts) * obj.mean;
            data1(prePts + 1:prePts + stimPts) = obj.amplitude + obj.mean;

			% Second pulse
			prePts = timeToPts(obj.inTime);
            stimPts = timeToPts(obj.stimTime2);
            tailPts = timeToPts(obj.tailTime);
            data2 = ones(1, prePts + stimPts + tailPts) * obj.mean;
            data2(prePts + 1:prePts + stimPts) = obj.amplitude + obj.mean;

			data = [data1, data2];
            
            parameters = obj.dictionaryFromMap(obj.propertyMap);
            measurements = Measurement.FromArray(data, obj.units);
            rate = Measurement(obj.sampleRate, 'Hz');
            output = OutputData(measurements, rate);
            
            cobj = RenderedStimulus(class(obj), parameters, output);
            s = symphonyui.core.Stimulus(cobj);
        end
        
    end
    
end

