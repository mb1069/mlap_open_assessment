function probs = m_step(data, graph, weights)
% M step of EM algorithm, used to estimate parameters of a BN from data
% that has been imputed and weighted in the E-step

% Initialise matrix of probabilities as in main function
probs = zeros(size(data,2), pow2(max(sum(graph))));
for variable = 1:size(data,2)
    parents = find(graph(:,variable));
    
    % If variable has no parent
    if size(parents, 1)==0
        posCount = 0;
        totalCount = 0;
        % Count probability as E(V=1) / (E(V=0) + E(V=1))
        for rownum = 1:size(data,1)
            row = data(rownum,:);
            rowval = weights(rownum);
            if row(variable)==1
                posCount = posCount + rowval;
            end
            totalCount = totalCount + rowval;
        end
        % Store probability in matrix
        probs(variable, 1) = posCount/totalCount;

    else
        % If variable has parent, store probabilities for V=1 given all
        % permutation of parent values
        % Iterate through every combination of parent values
        for comb = 0:pow2(size(parents,1))-1
            % Generate parent values
            parent_vals = de2bi(comb, size(parents, 1));
            posCount = 0;
            totalCount = 0;
            % Count occurances of variable=1 where the values of parents
            % are equal to generate values
            for rownum = 1:size(data,1)
                row = data(rownum,:);
                % Check parent condition is correct
                if prod(row(parents)==parent_vals)==1
                    if row(variable)==1
                        posCount = posCount + weights(rownum);
                    end
                    totalCount = totalCount + weights(rownum);
                end
            end
            % Store in appropriate column according to decimal
            % representation of array of parent values
            if totalCount~=0
                probs(variable, comb+1) = posCount/totalCount;
            else
                probs(variable, comb+1) = 0;
            end
        end
    end
end