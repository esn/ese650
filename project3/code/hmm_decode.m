function [p_Q, p_O, a, b, s] = hmm_decode(O, A, B)

% Check input
N = size(A,1);
assert(N == size(A,2), 'Transition matrix should be square');
assert(N == size(B,1), 'Emission matrix size mismatch');
M = size(B,2);
assert(~(any(O(:)<1) || any(O(:)~=round(O(:))) || any(O(:)>M)), ...
  'Bad observation sequence');

% Add extra symbols to start
O = [M+1, O];
T = length(O);

% Scaling factor and forward 
s = zeros(1,T); s(1) = 1; % Scaling factors
a = zeros(N,T); a(1) = 1; % Forward alpha
for t = 2:T
  for i = 1:N
    a(i,t) = B(i,O(t)) .* (sum(a(:,t-1) .* A(:,i)));
  end
  s(t) = sum(a(:,t));
  a(:,t) = a(:,t)./s(t);
end

% backward
b = ones(N,T);
for t = T-1:-1:1
  for i = 1:N
    b(i,t) = (1/s(t+1)) * sum(A(i,:)'.* b(:,t+1) .* B(:,O(t+1)));
  end
end

% Output
p_O = sum(log(s));
p_Q = a.*b;
p_Q(:,1) = [];

end