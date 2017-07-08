function [ u_time,u_val ] = clk_wave_gen( delta, t_start, t_end )
%clk_wave_gen generates the clock voltage source as seen in assignment 5
%   Input: delta is the size of the time step
%   Input: t_start and t_end defines the interval of time
%   Output: u_time is the list of simulated time values
%   Output: u_val is the voltage value over time


N=int16((t_end-t_start)/delta);
period=2; %2 ns period
u_time=zeros([1 N]);
u_val=u_time;
for t=delta:delta:0.1
    u_time(uint64(t/delta))=t;
    %u val is 0
end
for cycle=1:floor((t_end-t_start)/period)
    for t=((cycle-1)*period+0.1+delta):delta:((cycle-1)*period+0.2)
        u_time(uint64(t/delta))=t; %increasing signal
        u_val(uint64(t/delta))=(t-0.1-(cycle-1)*period)*(1-0)/(0.2-0.1);
    end
    for t=((cycle-1)*period+0.2+delta):delta:((cycle-1)*period+1.1)
        u_time(uint64(t/delta))=t;
        u_val(uint64(t/delta))=1; %constant v=1
    end
    for t=((cycle-1)*period+1.1+delta):delta:((cycle-1)*period+1.2)
        u_time(uint64(t/delta))=t; %decreasing signal
        u_val(uint64(t/delta))=1+(t-1.1-(cycle-1)*period)*(0-1)/(1.2-1.1);
    end
    for t=((cycle-1)*period+1.2+delta):delta:((cycle-1)*period+2.1)
        u_time(uint64(t/delta))=t;
        u_val(uint64(t/delta))=0; %constant v=0
    end
end
%completed only up to the number of cycles that is floor to the input

end

