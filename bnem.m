function [loglikehood, numsteps, maxlikehood] = bnem(graphraw, dataraw, probs)
% Executes parameter estimation for a baye's net given a graph structure
% and datafile, using the EM-algorithm

% Load .csv files
graph = load(graphraw);
raw_data = load(dataraw);

if nargin == 2
    % Initialise the matrix of prior probabilities:
    % Each row corresponds to a variable/node in the graph
    % p(V=1) where V has no parents is found in probs(V, 1)
    % Variables with values have probabilities stored according
    % to the decimal value of the concatenated parent values (ordered by
    % variable name). Hence p(V=1|X=0,Y=0) where X, Y are independent parents
    % of V is found in probs(V,0 + 1)
    probs = zeros(size(raw_data,2), pow2(max(sum(graph))));

    % Initialise all prior beliefs to 0.5
    probs(:)= 0.5;
else
    if size(probs) ~= [size(raw_data,2), pow2(max(sum(graph)))]
        error('Invalid probability matrix dimensions, check code comments for further detail.');
        return;
    end;
end    
    

% Initialise ending condition
diff = Inf;
iterations = 0;

% Calculate log-likelihood
log_lik = get_log_likelihood(raw_data, probs, graph);
fprintf('log-likelihood is currently: %1.10f \r', log_lik)
prevloglike = log_lik;

% Check convergence
while (diff>0.0001)
    % E-step: Estimate values of the missing data
    [data, weights] = e_step(raw_data, probs, graph);
    
    % M-step: Estimate the model's parameters based on the missing data
    probs = m_step(data, graph, weights);
    
    % Calculate log-likelihood and convergence criteria
    log_lik = get_log_likelihood(raw_data, probs, graph);
    diff = log_lik-prevloglike;
    prevloglike = log_lik;
    iterations = iterations+1;
    fprintf('log-likelihood is currently: %1.10f \r', log_lik)
end

fprintf('Convergence in %d steps \r', iterations+1);

% Log parameters of the graph given parent values
for v = 1:size(data,2)
    parents = find(graph(:,v));
    fprintf('Variable %i has these parents (', v-1);
    for p = 1:size(parents,1)
        fprintf('%i', parents(p)-1);
        if p ~= size(parents,1)
            fprintf(', ');
        end
    end
    fprintf(') \r');
    if size(parents,1)==0
        fprintf('P(%i=1|()) = %.9f \n \r', v-1, probs(v,1));
    else
        for comb = 0:pow2(size(parents,1))-1
            parent_vals = de2bi(comb, size(parents, 1));
            prob = probs(v, comb+1);
            fprintf('P(%i=1|(', v-1);
            for p = 1:size(parents,1)
                fprintf('''%i''', parent_vals(p));
                if p ~= size(parents,1)
                    fprintf(', ');
                end
            end
            fprintf(')) = %.9f \r', prob);
        end
        fprintf('\n');
    end
end
end