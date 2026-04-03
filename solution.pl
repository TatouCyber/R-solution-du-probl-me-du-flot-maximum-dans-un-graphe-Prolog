/* 
=========================================================
   CONSTRUCTION DU TABLEAU DE SOLUTION
=========================================================
*/

/*
------------------------------------------------------------
solution_table(+GraphInitial, +Residual, -Table)

Construit le tableau de solution final à partir :
- du graphe initial, qui contient les capacités d'origine ;
- du graphe résiduel final, obtenu après l'algorithme de Ford-Fulkerson.

Paramètres :
+GraphInitial : liste des arêtes du graphe initial
+Residual : graphe résiduel final
-Table : tableau de solution sous la forme
         flow(Origine, Destination, Capacite, Flot)
*/

/*
Cas 1 : Si le graphe initial ne contient plus d’arêtes, le tableau de solution est vide.
*/
solution_table([], _, []).

/*
Cas 2 : Pour l’arête courante X -> Y :
- on récupère sa capacité résiduelle finale ;
- on en déduit le flot réellement envoyé ;
- on ajoute la ligne correspondante au tableau de solution ;
- on poursuit sur le reste du graphe initial.
*/
solution_table([edge(X,Y,Cap)|T], Residual, [flow(X,Y,Cap,Flow)|Rest]) :-
    capacity(X, Y, Residual, ResidualCap),
    Flow is Cap - ResidualCap,
    solution_table(T, Residual, Rest).


/* 
=========================================================
   CALCUL DE LA VALEUR DU FLOT
=========================================================
*/

/*
------------------------------------------------------------
flow_value(+Source, +Table, -Value)

Calcule la valeur du flot maximal à partir du tableau de solution.

Paramètres :
+Source : sommet source du réseau
+Table : tableau de solution produit par solution_table/3
-Value : valeur du flot maximal
*/
flow_value(Source, Table, Value) :-
    findall(F, member(flow(Source,_,_,F), Table), Flows),
    sum_list(Flows, Value).


/* 
=========================================================
   AFFICHAGE DE LA SOLUTION
=========================================================
*/

/*
------------------------------------------------------------
print_solution(+Value, +Table)

Affiche la solution finale sous une forme textuelle et structurée.

Paramètres :
+Value : valeur du flot maximal
+Table : tableau de solution sous la forme flow(X,Y,C,F)
*/
print_solution(Value, Table) :-
    format("Valeur du flot maximal : ~w~n", [Value]),
    writeln("Origine\tDestination\tCapacite\tFlot"),
    forall(
        member(flow(X,Y,C,F), Table),
        format("~w\t \t ~w\t \t~w\t \t~w~n", [X,Y,C,F])
    ).