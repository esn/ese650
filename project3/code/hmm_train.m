function [ Ag, Bg, logPs ] = hmm_train(Os, Ag, Bg, verbose)

tol = 1e-6;
A_tol = tol;
B_tol = tol;
max_iter = 500;
verbose = false;
N = size(Ag,1);
M = size(Bg,2);
assert(N == size(Ag,2), 'Transition matrix should be square');
assert(N == size(Bg,1), 'Emission matrix size mismatch');

nO = numel(Os);
% Initialization
A = zeros(size(Ag));
B = zeros(size(Bg));

is_converged = false;
logP = 1;
logPs = zeros(1, max_iter);

for iter = 1:max_iter
  oldLogP = logP;
  logP = 0;
  oldAg = Ag;
  oldBg = Bg;
  for iO = 1:nO
    O = Os{iO};
    T = length(O);
    [~, logPO, a, b, s] = hmm_decode(O, Ag, Bg);
    logP = logP + logPO;
    loga = log(a);
    logb = log(b);
    logAg = log(Ag);
    logBg = log(Bg);
    O = [0 O];
    
    for k = 1:N
      for l = 1:N
        for t = 1:T
          A(k,l) = ...
            A(k,l) + exp(loga(k,t) + logAg(k,l) + logBg(l,O(t+1)) + logb(l,t+1))./s(t+1);
        end
      end
    end
    for k = 1:N
      for l = 1:M
        ind = find(O == l);
        B(k,l) = E(k,l) + sum(exp(loga(k,ind)+logb(k,ind)));
      end
    end
    total_B = sum(B,2);
    total_A = sum(A,2);
  end
end

end