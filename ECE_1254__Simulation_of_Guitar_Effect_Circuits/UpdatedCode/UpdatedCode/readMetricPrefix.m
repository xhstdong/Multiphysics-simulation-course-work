function [ val ] = readMetricPrefix( valStr )
% Reads the metric prefix from a value string for a netlist value and
% returns the value as a double

% INPUTS:
%   - valStr: value string that may or may not contain a metric prefix

% OUTPUTS:
%   - val: double precision value

mult = 1; % default: no metric multiplier

if strfind(valStr,'f') % femto
    valStr = valStr(1:end-1);
    mult = 1e-15;
elseif strfind(valStr,'p') % pico
    valStr = valStr(1:end-1);
    mult = 1e-12;
elseif strfind(valStr,'n') % nano
    valStr = valStr(1:end-1);
    mult = 1e-9;
elseif strfind(valStr,'u') % micro
    valStr = valStr(1:end-1);
    mult = 1e-6;
elseif strfind(valStr,'m') % milli
    valStr = valStr(1:end-1);
    mult = 1e-3;
elseif strfind(valStr,'k') % kilo
    valStr = valStr(1:end-1);
    mult = 1e3;
elseif strfind(valStr,'M') % mega
    valStr = valStr(1:end-1);
    mult = 1e6;
elseif strfind(valStr,'G') % giga
    valStr = valStr(1:end-1);
    mult = 1e9;
elseif strfind(valStr,'T') % tera
    valStr = valStr(1:end-1);
    mult = 1e12;
end

val = str2double(valStr)*mult;

end

