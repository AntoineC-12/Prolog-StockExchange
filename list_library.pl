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


%% This predicate pops the first element of the list.
pop([],[]) :- !, fail.
pop([H|T],T) :- write(H).



push(X,L,[X|L]).

member([H|_],H,0) :- !.
member([H|T],K,I) :- K \= T, member(T,K,M), I is M+1.

% update(L,C,X,R).
update_i([_|T], 0, X, [X|T]).
update_i([H|T], I, X, [H|R]):- I > -1, NI is I-1, update_i(T, NI, X, R), !.
update_i(L, _, _, L).

update_e([O|T], O, X, [X|T]) :- !.
update_e([H|T], O, X, [H|R]):- H \= O, H \= X, update_e(T, O, X, R), !.
update_e(L, _, _, L).


%% This predicate will remove the empty stacks of the list of stacks.
clean_list([],[]).
clean_list([[]|T],L) :- !, clean_list(T,L).
clean_list([H|T],[H|T2]) :- H \= [], clean_list(T,T2).

%% This predicate will remove the empty stacks of the list of stacks. It also updates the Trader position so that it does not point to the wrong position or that it is not out of bound.
clean_list_and_update_TP([],[],_,_).
clean_list_and_update_TP([[]|T],L,1,1) :- !, clean_list(T,L,1,1).
clean_list_and_update_TP([H|T],[H|T2],1,1) :- H \= [],!, clean_list(T,T2,1,1).
clean_list_and_update_TP([[]|T],L,CP,NP) :- CP > 1, !, Cps is CP - 1, clean_list(T,L,Cps,NP).
clean_list_and_update_TP([H|T],[H|T2],CP,NP) :- H \= [], CP > 1, Cps is CP - 1, clean_list(T,T2,Cps,Nps), NP is Nps + 1.

%% This predicate will remove the empty stacks of the list of stacks.
remove_zero([],[]).
remove_zero([[_|[0]]|T],L) :- !, remove_zero(T,L).
remove_zero([[H|Tt]|T],[[H|Tt]|T2]) :- Tt \= [0], remove_zero(T,T2).

[[wheat,cocoa,corn,rice],[sugar,sugar,wheat,sugar],[],[corn,corn,rice,coffee],[],[rice,corn,sugar,wheat],[corn,wheat,sugar,wheat],[],[cocoa,rice,coffee,coffee]]