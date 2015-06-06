use_module(stock_exchange).

%in_liste([],_) :- !,fail.
in_liste([H|T],H) :- !. % Red cut. Change la sémantique de la règle.
in_liste([H|T],X) :- in_liste(T,X),!.


concat([H|T],B,[H|T2]) :- concat(T,B,T2).
concat([],B,B).

length_u([],0).
length_u([H|T],L) :- length(T,SL), L is SL + 1.

element([],I,'Index out of bounds').
element([H|T],0,H) :- !.
element([H|T],I,X) :- I \= 0, SI is I - 1, element(T,SI,X).

display_L([]).
display_L([H|T]) :- write(H), display(T).

pop([],[]) :- !, fail.
pop([H|T],T) :- write(H).

push(X,L,[X|L]).

in(K,K).
in([K|_],K) :- !.
in([[K|_]|_],K) :- !.
in([[H|T]|_],K) :- H \= K, in(T,K).
in([H|T],K,C) :- H \= K, in(T,K,C).

member([H|_],H,0) :- !.
member([H|T],K,I) :- K \= T, member(T,K,M), I is M+1.

% update(L,C,X,R).
update([_|T], 0, X, [X|T]).
update([H|T], I, X, [H|R]):- I > -1, NI is I-1, update(T, NI, X, R), !.
update(L, _, _, L).

%% This predicate will remove the empty stacks of the list of stacks.
clean_list([],[]).
clean_list([[]|T],L) :- !, clean_list(T,L).
clean_list([H|T],[H|T2]) :- H \= [], clean_list(T,T2).