function prob = getProb(var, probs, graph, observation)
% Method to retrieve the probability of a variable given the variable's
% values and values of parent variables in observation
parents = find(graph(:,var));
% If no parents retrieve value in first column
if size(parents,1)==0
    prob = probs(var,1);
else
    % If parents calculate the column index using the binary array of parent
    % values converted to a decimal value
    parents = find(graph(:,var));
    prob_col = b2d(observation(parents));
    % Add 1 to column to match matlab's indexing from 1.. rather than 0..
    prob = probs(var,prob_col+1);
end
% As stored probability is of V=1, if observation is 0 return 1 -
% probability of V=1
if observation(var)==0
    prob = 1 - prob;
end