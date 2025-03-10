%% IE3042 - Temas Especiales de Electrónica y Mecatrónica 2
%  Algoritmo VAT
%  Implementación del algoritmo presentado en el paper
%  "VAT: A Tool for Visual Assessment of (Cluster) Tendency", de Bezdek y Hathaway

%  Código original por: Alina Zare
%  Modificado y comentado por: Luis Alberto Rivera

% Entrada: X - matriz con las muestras como vectores fila (Nxd)

% Salidas: D - Matriz con todas las distancias a pares (NxN), correspondiente a los
%              vectores ya ordenados. Corresponde a R~ en el paper.
%          P - Vector con los índices permutados de los vectores, según el
%              ordenamiento que se hace de X.
function [D, P] = VAT(X)
% Inicializaciones
N = size(X,1);
J = 1:N;    % se pudo definir K = 1:N, y abajo hacer J = setdiff(J, P(1)); Es innecesario.
P = zeros(N,1); % Para los índices permutados (ordenados).

% Matriz con todas las distancias entre pares de muestras (R, en el paper)
D = pdist2(X,X);    % Se pueden usar distintas métricas (aquí se usa la Euclidiana)

% Paso 2: Encontrar el índice del punto cuya distancia a otro punto sea la máxima
[fila,~] = find(D == max(max(D)));
P(1) = fila(1); % Dada la simetría de D, fila tiene al menos 2 valores. Se toma el primero.
J = setdiff(J, P(1));  % En el paper: J = K-{1}

% Paso 3
for n = 2:N
    Dsub = D(P(1:(n-1)),J); % Distancias entre los elementos del conjunto I y el J
                            % El conjunto I (del paper) está implícito en los índices
                            % del vector P (los puntos que ya fueron ordenados).
    % Encontrar el índice del punto cuya distancia sea la mínima
    [~, col] = find(Dsub == min(min(Dsub)));
    P(n) = J(col(1));   % Pueden haber varios, por lo que se toma el primero
    J = setdiff(J, J(col(1)));  % En el paper: J = J-{j}
end

% Paso 4: R -> R~
D = D(P,P); % Reordenar la matriz de distancias, según el vector de índices permutados.

% Paso 5: Se muestran las distancias como intensidades en una imagen.
imagesc(D);
colorbar; % El colormap se puede cambiar a escala de grises (colormap gray), u otros colores.

end
