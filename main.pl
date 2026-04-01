:- consult('loader.pl').
:- consult('fordFulkerson.pl')

run :-
    read_terms('graph.pl',T),
    write(T),nl.
