% !!!!!You need to choose at least 2 files(.dat)!!!!!
% Datfile_convert script
%[FileName,PathName,FilterIndex] = uigetfile('*.dat','MultiSelect','on');
clc;
clear;
%[FileName,~,] = uigetfile('*.dat','MultiSelect','on');

PathName='';

%FileName=dir(strcat(PathName,'*.dat'));
FileName(1).name='wifitestAlbany.dat';
fprintf('Processing %d files\n',length(FileName));
for i = 1:length(FileName)
    csi_trace = read_bf_file(strcat(PathName,FileName(i).name));
    %csi_trace = read_bf_file(strcat(FileName,'.dat'));

    % Extract CSI information for each packet
    fprintf('File: %s, have CSI for %d packets', strcat(PathName,FileName(i).name),length(csi_trace))

    % Scaled into linear
    csi = zeros(length(csi_trace),3,30);
    timestamp = zeros(1,length(csi_trace));
    temp = [];
    for packet_index = 1:length(csi_trace)
        csi(packet_index,:,:) = get_scaled_csi(csi_trace{packet_index});
        timestamp(packet_index) = csi_trace{packet_index}.timestamp_low * 1.0e-6;
    end
    timestamp = timestamp';

    % File export
    csi_amp_matrix = permute(db(abs(squeeze(csi))), [2 3 1]); 
    csi_phase_matrix = permute(angle(squeeze(csi)), [2 3 1]); 
    
    for k=1:size(csi_phase_matrix,1)
        for j=1:size(csi_phase_matrix,3)
            csi_phase_matrix2(k,:,j) = phase_calibration(csi_phase_matrix(k,:,j))';
        end
    end
    
    for packet_index = 1:length(csi_trace)
        temp = [temp;horzcat(reshape(csi_amp_matrix(:,:,packet_index)',[1,90]),...
                             reshape(csi_phase_matrix2(:,:,packet_index)',[1,90]))];
    end
    %csvwrite([char(FileName),'.csv'],horzcat(timestamp,temp));
    
    %Export to CSV
    fprintf('. Saving CSV...');  
    FileName(i).name = strrep(FileName(i).name, '.dat', '.csv');
    csvwrite(strcat(PathName,FileName(i).name),horzcat(timestamp,temp));
    
    
%      fprintf('. Saving MAT...');
%      %Save matlab file
%      FileName(i).name = strrep(FileName(i).name,'.csv','.mat');
%      eval(strcat(strrep(FileName(i).name,'.mat',''),'=temp;'));
%      save(FileName(i).name,strrep(FileName(i).name,'.mat',''));
%      fprintf('\n');
    
    %Some cleaning
    clear(FileName(i).name);
end
fprintf('done\n');
