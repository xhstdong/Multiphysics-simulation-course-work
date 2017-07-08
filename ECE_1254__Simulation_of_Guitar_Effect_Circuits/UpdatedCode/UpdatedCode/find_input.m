function u = find_input( time_temp, u_time, input )
%Find an input value u at desired point time_temp based on the data set
%u_time, input
%   input: time_temp is the desired time at which a value is calculated
%   Input: u_time is a list of time corresponding to input signal
%   Input: input signal is matrix of values
%   Dependent function: interpolate_signal
%   This function is used in adaptive stepping implementation

%find the nearest time point in u_time
[~, index]=min(abs(u_time-time_temp));
if u_time(index)==time_temp
    %an exact input is matched in time
    u=input(:,index);
else% no exact input exist at this time, interpolation needed.
    %linear interpolation for bdf1 methods
    if u_time(index)>time_temp
        if index==1
            time_points=[u_time(index), u_time(index+1)];
            node_vals=[input(:,index),input(:,index+1)];
        else
            time_points=[u_time(index-1),u_time(index)];
            node_vals=[input(:,index-1),input(:,index)];
        end
    elseif u_time(index)<time_temp
        if index==length(u_time)
            time_points=[u_time(index-1),u_time(index)];
            node_vals=[input(:,index-1),input(:,index)];
        else
            time_points=[u_time(index), u_time(index+1)];
            node_vals=[input(:,index),input(:,index+1)];
        end
    end
    u=interpolate_signal(time_points, node_vals,time_temp);
end
end

