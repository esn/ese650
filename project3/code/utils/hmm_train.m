function [ Ag, Bg, logPs ] = hmm_train(Os, Ag, Bg, verbose)
% HMM_TRAIN a simpler version of matlab hmmtrain
if nargin < 4, verbose = false; end
tol = 1e-6;
A_tol = tol;
B_tol = tol;
max_iter = 500;
N = size(Ag,1);
M = size(Bg,2);
assert(N == size(Ag,2), 'Transition matrix should be square');
assert(N == size(Bg,1), 'Emission matrix size mismatch');

nO = numel(Os);
% Initialization
A = zeros(size(Ag));
B = zeros(size(Bg));

converged = false;
logP = 1;
logPs = zeros(1, max_iter);

for iter = 1:max_iter
  old_logP = logP;
  logP = 0;
  old_Ag = Ag;
  old_Bg = Bg;
  % For each observation sequence
  for iO = 1:nO
    O = Os{iO};
    T = length(O);
    % Forward backword
    [~, logPO, a, b, s] = hmm_decode(O, Ag, Bg);
    logP = logP + logPO;
    loga = log(a);
    logb = log(b);
    logAg = log(Ag);
    logBg = log(Bg);
    O = [0 O];
    
    % Update A
    for i = 1:N
      for j = 1:N
        for t = 1:T
          A(i,j) = ...
            A(i,j) + ...
            exp(loga(i,t) + logAg(i,j) + logBg(j,O(t+1)) + logb(j,t+1)) ...
            ./ s(t+1);
        end
      end
    end
    
    % Update B
    for j = 1:N
      for k = 1:M
        ind = find(O == k);
        B(j,k) = B(j,k) + sum(exp(loga(j,ind)+logb(j,ind)));
      end
    end
  end
  total_A = sum(A,2);
  total_B = sum(B,2);
  Ag = A./(repmat(total_A, 1, N));
  Bg = B./(repmat(total_B, 1, M));
  if any(total_A == 0)
    zero_transition_rows = find(total_A == 0);
    Ag(zero_transition_rows,:) = 0;
    Ag(sub2ind(size(Ag), zero_transition_rows, zero_transition_rows)) = 1;
  end
  Ag(isnan(Ag)) = 0;
  Bg(isnan(Bg)) = 0;
  
  if verbose
    if iter == 1
      fprintf('   Iteration       Log Lik    Transition     Emmission\n');
    else
      fprintf('  %6d      %12g  %12g  %12g\n', iter, ...
        (abs(logP - old_logP)./(1+abs(old_logP))), ...
        norm(Ag - old_Ag,inf)./N, ...
        norm(Bg - old_Bg,inf)./M);
    end
  end
  
  logPs(iter) = logP;
  if (abs(logP - old_logP)/(1 + abs(old_logP))) < tol
    if norm(Ag - old_Ag,inf)/N < A_tol
      if norm(Bg - old_Bg,inf)/M < B_tol
        if verbose
          fprintf('Converged after %d iterations\n', iter);
        end
        converged = true;
        break
      end
    end
  end
end

logPs(logPs == 0) = [];
if ~converged
  fprintf('Not converged after %d iterations\n', max_iter);
end

end