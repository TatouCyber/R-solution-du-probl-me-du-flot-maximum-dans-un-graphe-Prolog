/* 
=========================================================
   GÉNÉRATION ou CONSTRUCTION DU GRAPHE AUXILIAIRE
========================================================= */

/*
search(+ListeAretes, +AreteRecherchee)

Vrai si l’arête recherchée apparaît dans la liste.
*/
search([edge(X,Y,_)|T], edge(X,Y,_)).
search([edge(U,V,_)|T], edge(X,Y,_)) :-
    search(T, edge(X,Y,_)).

/*
------------------------------------------------------------
auxiliary_graph(+TotalGraph, +GraphInitial, -AuxiliaryGraph)

Construit le graphe auxiliaire (ou résiduel simplifié) à partir du graphe total (i.e rajoute des arêtes de retour, de 
capacité nulle, au graphe initial si cette même arête n'est pas présente dans graphe totale)

Paramètre : 
+TotalGraph : 
+GraphInitial : 
-AuxiliaryGraph : 
*/

/* 
Cas 1 : Si la liste d’arêtes à traiter est vide, résultat vide 
*/
auxiliary_graph(_, [], []).

/*
Cas 2 : Si l’arête inverse (Y,X) existe déjà dans le graphe total, on conserve simplement edge(X,Y,Capacity).
*/
auxiliary_graph(TotalGraph, [edge(X,Y,Capacity)|T], [edge(X,Y,Capacity)|AuxiliaryGraph]) :-
    search(TotalGraph, edge(Y,X,_)),
    auxiliary_graph(TotalGraph, T, AuxiliaryGraph).

/*
Cas 3 : Si l’arête inverse (Y,X) n’existe pas dans le graphe total, on ajoute une arête retour edge(Y,X,0).
*/
auxiliary_graph(TotalGraph, [edge(X,Y,Capacity)|T], [edge(X,Y,Capacity), edge(Y,X,0)|AuxiliaryGraph]) :-
    \+ search(TotalGraph, edge(Y,X,_)),
    auxiliary_graph(TotalGraph, T, AuxiliaryGraph).


/* 
=========================================================
   PARCOURS EN LARGEUR (BFS)
========================================================= */

/*
neighbors(+Graph, +Sommet, -Neighbors)

Construit la liste des voisins accessibles depuis le sommet en paramètre, en ne gardant que les arêtes de capacité 
strictement positive.
*/

/* 
Cas 1 : Si plus d’arêtes à inspecter, pas de voisins 
*/
neighbors([], X, []).

/*
Cas 2 : Si l’arête part de X et a une capacité > 0, alors Y est un voisin atteignable.
*/
neighbors([edge(X,Y,Capacity)|T], X, [[Y,X]|Neighbors]) :-
    0 < Capacity,
    neighbors(T, X, Neighbors).

/*
Cas 3 : Si l’arête courante ne part pas de X, on l’ignore et on continue.
*/
neighbors([edge(Z,Y,Capacity)|T], X, Neighbors) :-
    neighbors(T, X, Neighbors).


/*
------------------------------------------------------------
bfs(+Graph, +Queue, +Objective, +Visited, +Path, -Result)

Recherche un chemin de la source vers Objective par parcours en largeur.

Paramètres :
- Graph    : graphe résiduel
- Queue    : file des sommets à explorer
- Objective: sommet cible (puits)
- Visited  : sommets déjà visités
- Path     : accumulation des couples [Sommet, Père]
- Result   : résultat final du BFS

La structure [[H,P]|T] signifie :
- H = sommet courant
- P = son père dans le parcours
- T = reste de la file
*/

/* Cas d’échec : plus rien à explorer => pas de chemin */
bfs(Graph, [], _, _, _, _) :- false.

/*
Cas de succès :
si le sommet courant H est l’objectif,
on reconstruit le résultat à partir du chemin accumulé.
*/
bfs(Graph, [[H,P]|T], H, _, Path, Result) :-
    reverse([[H,P]|Path], Result).

/*
Si H a déjà été visité, on l’ignore et on continue avec la file T.
*/
bfs(Graph, [[H|P]|T], Objective, Visited, Path, Result) :-
    member(H, Visited),
    bfs(Graph, T, Objective, Visited, Path, Result).

/*
Si H n’a pas encore été visité :
- on récupère ses voisins atteignables,
- on les ajoute en fin de file (append),
- on marque H comme visité,
- on mémorise [H,P] dans le chemin.
*/
bfs(Graph, [[H,P]|T], Objective, Visited, Path, Result) :-
    \+ member(H, Visited),
    neighbors(Graph, H, Neighbors),
    append(T, Neighbors, Queue),
    bfs(Graph, Queue, Objective, [H|Visited], [[H,P]|Path], Result).


/* 
=========================================================
   RECONSTRUCTION DU CHEMIN
========================================================= */

/*
path(+ListeParents, +SommetCourant, -Path)

Reconstruit le chemin à partir des couples [V,U]
où U est le père de V.

Paramètre : 
...

Idée :
on part du terminal, puis on remonte les pères
jusqu’à la source.
*/

/* Cas de base */
path([], _, []).

/*
Si on trouve [V,U] et qu’on cherche justement V,
alors on ajoute V au chemin et on remonte vers U.
*/
path([[V,U]|T], V, [V|Path]) :-
    path(T, U, Path).

/*
Sinon, on ignore cet élément et on continue à chercher.
*/
path([[V,U]|T], X, Path) :-
    path(T, X, Path).


/* 
=========================================================
   CAPACITÉ D’UNE ARÊTE ET GOULOT D’ÉTRANGLEMENT
========================================================= */

/*
capacity(+X, +Y, +Graph, -Capacity)

Récupère la capacité de l’arête X -> Y dans le graphe.

Paramètre : 
...
*/

/* Si l’arête courante est la bonne, on renvoie sa capacité */
capacity(X, Y, [edge(X,Y,Capacity)|T], Capacity).

/* Sinon, on continue dans le reste de la liste */
capacity(X, Y, [edge(Z,W,Capacity)|T], Result) :-
    capacity(X, Y, T, Result).


/*
------------------------------------------------------------
bottle_neck(+Graph, +Path, +MinimumCourant, -BottleNeck)

Calcule le goulot d’étranglement d’un chemin :
c’est la plus petite capacité résiduelle sur ce chemin.

Paramètre : 
...

Exemple :
si les capacités du chemin sont 8, 3, 5
alors le bottleneck vaut 3.
*/

/*
Cas où le chemin est constitué d’une seule arête [X,Y].
On compare sa capacité avec le minimum courant.
*/
bottle_neck(Graph, [X,Y], Minimum, BottleNeck) :-
    capacity(X, Y, Graph, Capacity),
    BottleNeck is min(Minimum, Capacity).

/*
Cas récursif :
- on prend la capacité de X -> Y,
- on met à jour le minimum courant,
- on continue sur le reste du chemin.
*/
bottle_neck(Graph, [X,Y|T], Minimum, BottleNeck) :-
    capacity(X, Y, Graph, Capacity),
    Min is min(Minimum, Capacity),
    bottle_neck(Graph, [Y|T], Min, BottleNeck).


/* 
=========================================================
   MISE À JOUR DU GRAPHE RÉSIDUEL
========================================================= */

/*
update_edge(+X, +Y, +BottleNeck, +InputGraph, -OutputGraph)

Met à jour la capacité de l’arête X -> Y :
nouvelle capacité = ancienne capacité - BottleNeck

Paramètre : 
...

Remarque :
si BottleNeck est positif, on diminue la capacité avant ;
si on passe -BottleNeck, cela revient à augmenter la capacité.
*/

/* Cas où on a trouvé l’arête à mettre à jour */
update_edge(X, Y, BottleNeck, [edge(X,Y,Capacity)|T], [edge(X,Y,NewCapacity)|T]) :-
    NewCapacity is Capacity - BottleNeck.

/* Sinon, on garde la tête telle quelle et on continue */
update_edge(X, Y, BottleNeck, [edge(Z,W,Capacity)|T], [edge(Z,W,Capacity)|OutputGraph]) :-
    update_edge(X, Y, BottleNeck, T, OutputGraph).


/*
update_grafo(+Path, +BottleNeck, +InputGraph, -OutputGraph)

Met à jour tout le chemin augmentant :
- on enlève BottleNeck sur chaque arête avant X -> Y
- on ajoute BottleNeck sur chaque arête retour Y -> X
  (grâce à l’appel avec -BottleNeck)

Paramètre : 
...
*/

/* Si plus rien à mettre à jour, le graphe reste inchangé */
update_grafo([], BottleNeck, InputGraph, InputGraph).

/* Un chemin réduit à un seul sommet ne change rien */
update_grafo([X], BottleNeck, InputGraph, InputGraph).

/*
Pour chaque paire consécutive X,Y du chemin :
1. on réduit la capacité de X -> Y ;
2. on augmente la capacité de Y -> X ;
3. on continue sur le reste du chemin.
*/
update_grafo([X,Y|T], BottleNeck, InputGraph, OutputGraph) :-
    update_edge(X, Y, BottleNeck, InputGraph, GoingGraph),
    update_edge(Y, X, -BottleNeck, GoingGraph, BackingGraph),
    update_grafo([Y|T], BottleNeck, BackingGraph, OutputGraph).


/* 
=========================================================
   FORD-FULKERSON
========================================================= */

/*
fordfurkeson(+AuxiliaryGraph, +Source, +Terminal, -FinalGraph)

Algorithme principal.

Paramètre : 
...

Idée :
tant qu’il existe un chemin augmentant de Source à Terminal
dans le graphe résiduel :
1. on trouve ce chemin avec BFS ;
2. on calcule son goulot d’étranglement ;
3. on met à jour le graphe résiduel ;
4. on recommence.

Quand il n’existe plus de chemin augmentant,
le graphe courant est le graphe final.
*/

/*
Cas terminal :
si BFS échoue, alors il n’existe plus de chemin augmentant.
On a atteint un flot maximum.
*/
fordfurkeson(AuxiliaryGraph, Source, Terminal, AuxiliaryGraph) :-
    \+ bfs(AuxiliaryGraph, [[Source,Source]], Terminal, [], [], Result).

/*
Cas récursif :
- on trouve un chemin augmentant ;
- on le reconstruit ;
- on calcule son goulot ;
- on met à jour le graphe ;
- on recommence.
*/
fordfurkeson(AuxiliaryGraph, Source, Terminal, FinalGraph) :-
    bfs(AuxiliaryGraph, [[Source,Source]], Terminal, [], [], Result),
    reverse(Result, ParentPath),
    path(ParentPath, Terminal, Path),
    reverse(Path, InversedPath),
    bottle_neck(AuxiliaryGraph, InversedPath, 1000, BottleNeck),
    update_grafo(InversedPath, BottleNeck, AuxiliaryGraph, NewGraph),
    fordfurkeson(NewGraph, Source, Terminal, FinalGraph).