%% Initialize dataset for this project
% if both train and valid are already in workspace
if exist('train', 'var') && exist('valid', 'var')
    disp('Train and valid are in workspace.')
else
    cd_list = what(pwd);
    mat_exist = 0;

    if ~isempty(cd_list.mat)
        for i = 1:length(cd_list)
            if strcmp(cd_list.mat{i}, 'train.mat')
                mat_exist = 1;
                break
            end
        end
        % Load mat files if they exist
        disp('train.mat and valid.mat in current dir. Loading...')
        load('train.mat')
        load('valid.mat')
    else
        % Regenerating data if no mat file exists
        disp('train.mat and valid.mat not in current dir. Generating...')
        [train, valid] = split_train();
        save('train.mat', 'train')
        save('valid.mat', 'valid')
    end
end
clearvars -except train valid
