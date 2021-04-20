classdef BreathingEstimator < handle
    %Breathing Estimator class
    %developed by Jesus Albany Armenta Garcia
    %April 15, 2021
    
    properties
        csiData;
        classifier;
        lowCutFrequency;
        highCutFrequency;
        estimation; 
        b;
        a;
        observation; 
        z;
        sensitiveSC; 
        mafSensitive; 
        mu;
        sigma; 
        featureExtractor; 
    end
    
    methods
        function obj = BreathingEstimator(classifier,lowCutFrequency,highCutFrequency)
            %Class Constructor
            obj.classifier = classifier;
            obj.lowCutFrequency = lowCutFrequency;
            obj.highCutFrequency = highCutFrequency;
            obj.z = [];
            obj.sensitiveSC = [];
            filtroPBBreath= designfilt('bandpassiir','FilterOrder',6, ...
                'HalfPowerFrequency1',lowCutFrequency,'HalfPowerFrequency2',highCutFrequency,  ...
                'SampleRate',100);
            [obj.b,obj.a] = sos2tf(filtroPBBreath.Coefficients);
            obj.featureExtractor = FeatureExtractor(100); 
            obj.mu = mean(obj.classifier.trainedModel.ClassificationSVM.X{:,:}); 
            obj.sigma = std(obj.classifier.trainedModel.ClassificationSVM.X{:,:});
%             obj.lfSize = 5;
%             obj.lfIndex = 1; 
%             obj.lastF = NaN; 
        end
        
        function setCSIData(obj,csiData)
            obj.csiData = csiData; 
        end 
        
        function [y,dataCalibrated] = classify (obj) 
            %This function returns the class prediction from the current
            %csiData in the estimator
            dataCalibrated = obj.calibrate(); 
            obj.observation = obj.featureExtractor.getFeatures(dataCalibrated,obj.mafSensitive);      
            obj.observation = (obj.observation - obj.mu) ./ obj.sigma;
            y = obj.classifier.trainedModel.predictFcn(obj.observation);
            disp(y);
        end 
        
%         function [y,dataCalibrated] = classify(obj)
%             %This function returns the class prediction from the current
%             %csiData in the estimator
%             dataCalibrated = obj.calibrate(); 
%             %TEMPORAL 
%             X = fft(dataCalibrated,1024);
%             X = X./max(X);
%             X = fftshift(X);
%             psd = abs(X);
%             kk = 0:1024-1;
%             F = kk/1024*100-100/2;
%             [~,index] = find(F==0);
%             F = F(index:1024);
%             psd = psd(index:1024,:);
%             %Estimación de HR basado en el espectro
%             [rows,~] = size(psd);
%             meanPSD = zeros(rows,1); 
%             for j=1:rows
%                 meanPSD(j) = mean(psd(j,:)); 
%             end 
%             [~,indexMaxFrequencies] = maxk(meanPSD,5);
%             frequency = F(indexMaxFrequencies); 
%              if isnan(obj.lastF) == 1
%                 obj.lastF = frequency(1); %Se parte de la frecuencia mas alta 
%                 obj.nearestF = obj.lastF;   
%                 obj.lastFive(1) = obj.lastF; 
%                 obj.lfIndex = obj.lfIndex + 1; 
%              else
%                  if obj.lfIndex < obj.lfSize
%                   obj.lastFive(obj.lfIndex) = (sum(obj.lastFive) + frequency(1))/(numel(obj.lastFive)+1); 
%                   obj.nearestF = obj.lastFive(obj.lfIndex);
%                   obj.lfIndex = obj.lfIndex + 1; 
%                   else                           
%                       obj.lfIndex = 1; 
%                       obj.lastFive(obj.lfIndex) = (sum(obj.lastFive) + frequency(1))/obj.lfSize;
%                       obj.nearestF = obj.lastFive(obj.lfIndex);
%                   end
%              end 
%              y = round(obj.nearestF * 60); 
%         end 
        
        function calibratedData = calibrate(obj)
            %This function calibrates the current csiData in the estimator
            [calibratedData,obj.z,obj.sensitiveSC,obj.mafSensitive] = Calibrator.calibrate(obj.csiData,5,...
                                                                10,obj.b,obj.a,obj.z,obj.sensitiveSC);
        end 
        
    end
end
