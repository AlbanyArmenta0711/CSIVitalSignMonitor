classdef Calibrator
    %Calibrator class which process the signal with static methods
    %developed by Jesus Albany Armenta Garcia
    %April 16, 2021
    
    methods (Static)
        function [dataCalibrated,z,sensitiveSC, mafSensitive] = calibrate(csiData,hampelWindowProp,mavWindowProp,b,a,z,sensitiveSC)
            [rows,cols] = size(csiData);
            %First, it applies hampel filter to remove outliers from
            %csiData
            csiHampel = hampel(csiData,round(rows/hampelWindowProp),2);
            maf = zeros(size(csiHampel)); 
            for j = 1:cols %Se envia columna por columna
                maf(:,j) = filtrarMediaMovil(csiHampel(:,j),round(rows/mavWindowProp)); 
            end 
            if isempty(z)
                [dataCalibrated,z] = filter(b,a,maf);
                [dataCalibrated,sensitiveSC] = subcarrierSelection(dataCalibrated,10);
            else
                [dataCalibrated,z] = filter(b,a,maf,z);
                dataCalibrated = dataCalibrated(:,sensitiveSC);
            end 
            mafSensitive = maf(:,sensitiveSC); 
        end
        
    end
end

