function [data, weights] = e_step(raw_data, probs, graph)
% E step of EM algorithm where missing data is imputed using current
% beliefs over the parameters

% Initialise output data matrices/vectors
data = [];
weights = [];

% For every row in dataset
for row_num = 1:size(raw_data,1)
    % If row contains an unknown value
    if sum(isnan(raw_data(row_num,:)))>0
        nanIndeces = find(isnan(raw_data(row_num,:)));
        numNans = size(nanIndeces,2);
        perm_weights = [];
        for perm = 0:pow2(numNans)-1
            % Generate permutations of unknown variables
            raw_data(row_num,nanIndeces) = de2bi(perm, numNans);
            prob = 1;
            for var = 1:size(raw_data,2)
                prob = prob * getProb(var, probs, graph, raw_data(row_num,:));
            end
            data = [data; raw_data(row_num,:)];
            perm_weights = [perm_weights; prob];
        end
        % Weigh rows relative to each other
        perm_weights = perm_weights/sum(perm_weights);
        weights = [weights; perm_weights];
    else
        % Append row to data and weight as one since no other permutations
        data = [data; raw_data(row_num,:)];
        weights = [weights; 1];
    end
end
