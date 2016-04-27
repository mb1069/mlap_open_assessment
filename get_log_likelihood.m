function log_lik = get_log_likelihood(raw_data, probs, graph)

% The log likelihood
log_lik = 0;
for row_num = 1:size(raw_data,1)
    sum2 = 0;
    % If observation contains an unknown value, sum over possible values of
    % the variables
    if sum(isnan(raw_data(row_num,:)))>0
        % Find all nan values
        nanIndeces = find(isnan(raw_data(row_num,:)));
        numNans = size(nanIndeces,2);
        
        % Generate combinations of NaN values
        for perm = 0:pow2(numNans)-1
            raw_data(row_num,nanIndeces) = de2bi(perm, numNans);
            num = 1;
            
            % Probability of complete observation = Product of
            % probabilities of each variable in observation
            for var = 1:size(raw_data,2)
                num = num * getProb(var, probs, graph, raw_data(row_num,:));
            end
            sum2 = sum2 + num;
        end
    else
        % Otherwise calculate the probability of each variable
        sum2 = 1;
        for var = 1:size(raw_data,2)
            sum2 = sum2 * getProb(var, probs, graph, raw_data(row_num,:));
        end
    end
    if sum2==0
        error('Error: observation %i had a probability of 0', row_num);
    else    
        log_lik = log_lik + log(sum2);
    end    
end
