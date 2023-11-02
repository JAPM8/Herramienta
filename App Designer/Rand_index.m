% Rand_pr2.m
% Calculates the Rand index
% Inputs:
%   LC - Labels obtained from clustering algorithm
%   LP - External labels
% Outputs:
%   R  - Rand statistic
function R = Rand_index(LC,LP)
a = 0; b = 0; c = 0; d = 0;
N = length(LC);
for n = 1:(N-1)
    for m = (n+1):N
        if (LC(n) == LC(m)) % points in the same cluster, Clustering alg.
            if (LP(n) == LP(m)) % points in the same cluster, external
                a = a + 1;
            else    % points in different clusters, external
                b = b + 1;
            end
        else    % points in different clusters, Clustering alg.
            if (LP(n) == LP(m)) % points in the same cluster, external
                c = c + 1;
            else    % points in different clusters, external
                d = d + 1;
            end
        end
    end
end

R = (a+d)/(a+b+c+d);

end