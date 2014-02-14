function real_val = raw2real( raw_val, type )
% RAW2REAL convert raw ADC values to real values
if nargin < 2, type = 'all'; end
switch type
    case 'acc'
        real_val = acc2real(raw_val);
    case 'omg'
        real_val = omg2real(raw_val);
    case 'all'
        real_val(1:3,:) = acc2real(raw_val(1:3,:));
        real_val(4:6,:) = omg2real(raw_val(4:6,:));
end

end

function acc_real = acc2real( acc_raw )
acc_scale = 0.0106*[-1; -1; 1]; % [sax, say, saz]
% -1 to flip ax and ay as stated in the imu reference
acc_bias  = 1023/2;
acc_real = bsxfun(@times, acc_raw - acc_bias, acc_scale);
end

function omg_real = omg2real( omg_raw )
omg_scale = 0.0172;
% omg_bias  = [374; 375; 370]; % [bwx, bwy, bwz]
omg_bias = [373.63; 375.20; 369.66];
omg_real = bsxfun(@minus, omg_raw, omg_bias) * omg_scale;
end
