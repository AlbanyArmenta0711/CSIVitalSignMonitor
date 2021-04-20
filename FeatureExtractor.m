classdef FeatureExtractor
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fs
        lastFive;
        lfIndex; 
        lastF;
        lfSize;
        features;
    end
    
    methods
        function obj = FeatureExtractor(fs)
            %Class constructor
            obj.fs = fs;
            obj.lfSize = 5;
            obj.lfIndex = 1; 
            obj.lastF = NaN; 
        end
        
        function features = getFeatures(obj,dataCalibrated,mafSensitive)
            %This method obtains the time and frequency domain features,
            %plus some DWT features
            
            %%%%%%%%%%%%%%%%%%   TIME DOMAIN FEATURES %%%%%%%%%%%%%%%%%%%%%
            [numEntries,~] = size(dataCalibrated);
            %MEAN ABSOLUTE VALUE
            MAV = mean(abs(dataCalibrated));
            %SIMPLE SIGN INTEGRAL
            SSI = sum(abs(dataCalibrated).^2);
            %ROOT MEAN SQUARE
            RMS = sqrt(SSI./numEntries);
            %MEAN
            AVG = mean(dataCalibrated); 
            %VARIANCE
            VAR = var(dataCalibrated); 
            %SKEWNESS
            SKW = skewness(dataCalibrated);
            %KURTOSIS
            KRT = kurtosis(dataCalibrated);
            
            %%%%%%%%%%%%%%%%%%         DWT            %%%%%%%%%%%%%%%%%%%%%
            for currentsc=1:10
                [c,l] = wavedec(mafSensitive(:,currentsc),4,'db2');
                approx = appcoef(c,l,'db2');
                [cd1,cd2,cd3,cd4] = detcoef(c,l,[1 2 3 4]);
                AproxSTD(1,currentsc) = std(approx);
                CD1STD(1,currentsc) = std(cd1); 
                CD1VAR(1,currentsc) = var(cd1);
                CD1SKW(1,currentsc) = skewness(cd1);
                CD1KRT(1,currentsc) = kurtosis(cd1);
                CD2STD(1,currentsc) = std(cd2);
                CD2VAR(1,currentsc) = var(cd2);
                CD2SKW(1,currentsc) = skewness(cd2);
                CD2KRT(1,currentsc) = kurtosis(cd2);
                CD3STD(1,currentsc) = std(cd3); 
                CD3VAR(1,currentsc) = var(cd3);
                CD3SKW(1,currentsc) = skewness(cd3);
                CD3KRT(1,currentsc) = kurtosis(cd3);
                CD4STD(1,currentsc) = std(cd4); 
                CD4VAR(1,currentsc) = var(cd4);
                CD4SKW(1,currentsc) = skewness(cd4);
                CD4KRT(1,currentsc) = kurtosis(cd4);
            end
            
            %%%%%%%%%%%%%%%%%%   FREQ DOMAIN FEATURES %%%%%%%%%%%%%%%%%%%%%
            X = fft(dataCalibrated,1024);
            X = X./max(X);
            X = fftshift(X);
            psd = abs(X);
            kk = 0:1024-1;
            F = kk/1024* obj.fs - obj.fs/2;
            [~,index] = find(F==0);
            F = F(index:1024);
            psd = psd(index:1024,:);
            [rows,~] = size(psd);
            meanPSD = zeros(rows,1); 
            for j=1:rows
                meanPSD(j) = mean(psd(j,:)); 
            end 
            [~,indexMaxFrequency] = max(meanPSD);
            frequency = F(indexMaxFrequency); 
            if isnan(obj.lastF) == 1
                obj.lastF = frequency; 
                nearestF = obj.lastF;   
                obj.lastFive(1) = obj.lastF; 
                obj.lfIndex = obj.lfIndex + 1; 
            else 
              if obj.lfIndex < obj.lfSize
                  obj.lastFive(obj.lfIndex) = (sum(obj.lastFive) + frequency(1))/(numel(obj.lastFive)+1); 
                  nearestF = obj.lastFive(obj.lfIndex);
                  obj.lfIndex = obj.lfIndex + 1; 
              else                           
                  obj.lfIndex = 1; 
                  obj.lastFive(obj.lfIndex) = (sum(obj.lastFive) + frequency(1))/obj.lfSize;
                  nearestF = obj.lastFive(obj.lfIndex);
              end
            end 
            %HR/BR RATE FIRST ESTIMATION
            firstEstimation = round(60*nearestF); 
            [~,maxPos] = max(psd);
            %MAX FREQUENCY IN POWER SPECTRUM
            MaxFreq = F(maxPos);
            %MEAN OF POWER SPECTRUM
            SpectrumMean = mean(psd);
            %VARIANCE OF POWER SPECTRUM
            SpectrumVar = var(psd);
            %STANDARD DEVIATION OF POWER SPECTRUM
            SpectrumSTD= std(psd);
            
            %Dominio del Tiempo
            obj.features = [MAV SSI RMS AVG];
            obj.features = [obj.features VAR SKW KRT];
            %DWT
            obj.features = [obj.features AproxSTD CD1STD CD1VAR];
            obj.features = [obj.features CD1SKW CD1KRT]; 
            obj.features = [obj.features CD2STD CD2VAR];
            obj.features = [obj.features CD2SKW CD2KRT]; 
            obj.features = [obj.features CD3STD CD3VAR];
            obj.features = [obj.features CD3SKW CD3KRT]; 
            obj.features = [obj.features CD4STD CD4VAR];
            obj.features = [obj.features CD4SKW CD4KRT]; 
            %Dominio de la Frecuencia
            obj.features = [obj.features MaxFreq];
            obj.features = [obj.features SpectrumMean SpectrumVar SpectrumSTD];
            %Primera Estimacion
            obj.features = [obj.features firstEstimation];
            features = obj.features;
        end
        
        
    end
end

