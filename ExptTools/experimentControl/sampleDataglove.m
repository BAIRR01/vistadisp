function datagloveValues = sampleDataglove (glovePointer)
% 
% t0 = GetSecs();
% 
% % take dataglove measurements at these time points
% sampleTimes = 0.020:0.020:10;
% 
% sensors = 0:3:12;
% datagloveValues = zeros(length(sampleTimes), 5);
% 
% for ii = 1:length(sampleTimes)
%     disp(sampleTimes(ii)); drawnow();
%     while GetSecs-t0 < sampleTimes(ii)
%         
%     end
%     
%     t1 = GetSecs;
%     datagloveValues(ii,:) = sampleDataglove (glovePointer);
%     t2 = GetSecs - t1; elapsedTime(ii) = t2;
% end


sensors = 0:3:12;
datagloveValues = zeros(1, 5);

for jj = 1:length(sensors)
    % Get the value of the each sensor
    datagloveValues(1,jj) = calllib('glovelib', 'fdGetSensorRaw', glovePointer, sensors(jj));
end
