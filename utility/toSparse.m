function S = toSparse(A, nCol, nRow)
if nargin == 3
    S = sparse(A(:,1), A(:,2), A(:,3), nRow, nCol);
elseif nargin == 2
    S = sparse(A(:,1), A(:,2), A(:,3), max(A(:,1)), nCol);
else
    S = sparse(A(:,1), A(:,2), A(:,3));
end
end