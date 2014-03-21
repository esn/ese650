function [real_val] = raw2real(raw_val, type)
% RAW2REAL convert raw ADC values to real values
if nargin < 2, type = 'all'; end

switch type
    case 'acc'
        real_val = acc2real(raw_val);
    case 'omg'
        raw_val = raw_val([2 3 1],:);
        real_val = omg2real(raw_val);
    case 'all'
        raw_val(4:6,:) = raw_val([5 6 4],:);
        real_val(1:3,:) = acc2real(raw_val(1:3,:));
        real_val(4:6,:) = omg2real(raw_val(4:6,:));
end

end

function acc_real = acc2real( acc_raw )
acc_scale = 0.01051*[-1; -1; 1]; % [sax, say, saz]
% -1 to flip ax and ay as stated in the imu reference
% acc_bias  = 1023/2;
acc_bias = [511.78; 501.97; 511.5];
acc_real = bsxfun(@times, bsxfun(@minus, acc_raw, acc_bias), acc_scale);
end

function omg_real = omg2real(omg_raw)
omg_scale = 0.0171;
% omg_scale = 0.0131;
omg_bias = [373.86; 375.67; 369.75]; % [bwx, bwy, bwz]
omg_real = bsxfun(@minus, omg_raw, omg_bias) * omg_scale;
end
