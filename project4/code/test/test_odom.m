% Encoders: 360 counts/revolution
% Encoder Order: FR FL RR RL
% Encoder Direction: Forward motion = positive

data_id = 20;
data = load_data(data_id);


%%
enc_fr = data.enc.counts(1,:);
enc_fl = data.enc.counts(2,:);
enc_rr = data.enc.counts(3,:);
enc_rl = data.enc.counts(4,:);
