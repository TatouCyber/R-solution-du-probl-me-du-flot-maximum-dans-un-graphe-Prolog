solution_table([], _, []).
solution_table([edge(X,Y,Cap)|T], Residual, [flow(X,Y,Cap,Flow)|Rest]) :-
    capacity(X, Y, Residual, ResidualCap),
    Flow is Cap - ResidualCap,
    solution_table(T, Residual, Rest).

flow_value(Source, Table, Value) :-
    findall(F, member(flow(Source,_,_,F), Table), Flows),
    sum_list(Flows, Value).

print_solution(Value, Table) :-
    format("Valeur du flot maximal : ~w~n", [Value]),
    writeln("Origine\tDestination\tCapacite\tFlot"),
    forall(
        member(flow(X,Y,C,F), Table),
        format("~w\t~w\t~w\t~w~n", [X,Y,C,F])
    ).