%in_liste([],_) :- !,fail.
in_liste([T|Q],T) :- !. % Red cut. Change la sémantique de la règle.
in_liste([T|Q],X) :- in_liste(Q,X),!.


concat([T|Q],B,[T|Q2]) :- concat(Q,B,Q2).
concat([],B,B).

length([],0).
length([T|Q],L) :- length(Q,SL), L is SL + 1.

element([],I,'Index out of bounds').
element([T|Q],0,T) :- !.
element([T|Q],I,X) :- I \= 0, SI is I - 1, element(Q,SI,X).