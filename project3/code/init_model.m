function [ A, B ] = init_model( n_state, n_cluster, T )
%INIT_MODEL Initialize HMM parameters
% [ A, B ] = init_model( n_state, n_cluster, T )

d = T/n_state;
a_ii = 1 - 1/d;
A = eye(n_state) * a_ii;
for m = 1:n_state
  for n = 1:n_state
    if (n - m) == 1
      A(m,n) = 1 - a_ii;
    end
  end
end
A(n_state,1) = 1 - a_ii;
B = ones(n_state, n_cluster)/n_cluster;

end