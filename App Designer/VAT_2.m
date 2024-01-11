%% IE3042 - Temas Especiales de Electrónica y Mecatrónica 2
%  Algoritmo Visual Assessment of (cluster) Tendency
%  Código original por: Alina Zare
%  Modificado y comentado por: Luis Alberto Rivera

% Entrada: X - matriz con las muestras como vectores fila (Nxd)
%        fig - número de figura en la que se desea mostrar el resultado. 0 para no mostrar
%              la gráfica.
% Salidas: D - Matriz con todas las distancias a pares (NxN), correspondiente a los
%              vectores ya ordenados.
%          P - Vector con los índices permutados de los vectores, según el
%              ordenamiento que se hace de X
function [D, P] = VAT_2(X, fig)
D = pdist2(X,X);    % Calcula las distancias a pares entre los vectores de X
[row,~] = find(D == max(max(D)));   % Busca dónde está la mayor distancia
N = size(X,1);
d = size(X,2);
P = zeros(N,1); % Tendrá los índices ordenados
P(1) = row(1);  % Dada la simetría de D, row tiene al menos 2 valores. Se toma el primero.

for n = 2:N
    I = X(P(1:(n-1)),:);
    J = setdiff(X, I, 'rows');
    temp = pdist2(I,J);
    [~,col] = find(temp == min(min(temp)));
    [rowA,~] = find(X(:,1) == J(col(1),1));
    [rowB,~] = find(X(:,min([2,d])) == J(col(1),min([2,d])));
    [rowC,~] = find(X(:,floor(d/2)) == J(col(1),floor(d/2)));
    [rowD,~] = find(X(:,max([1,d-1])) == J(col(1),max([1,d-1])));
    [rowE,~] = find(X(:,d) == J(col(1),d));
    next = intersect(intersect(rowA,rowB),intersect(rowC,rowD));
    next = intersect(next,rowE);
    P(n) = next(1);
%     fprintf('n = %d\n',n);
end

D = pdist2(X(P,:),X(P,:));
if fig > 0
    figure(fig); clf;
    imagesc(D);
    colorbar;
end

end
