use_module(stock_exchange).

[list_library].
%% This file contains the rules to display the gaming board.

print_u(X) :- write(X).

display_stack([]).
display_stack([[H|T]|Tt]) :- print_u([H|T]), nl, display_stack(Tt).

Board is [['wheat ',7,6,5,4,3,2,1],['corn  ',6,5,4,3,2,1,0],['rice  ',6,5,4,3,2,1,0],['sugar ',6,5,4,3,2,1,0],['coffee',6,5,4,3,2,1,0],['cocoa ',6,5,4,3,2,1,0]].

%% This rule does not work.
max_length([],0).
max_length([[H|_]|T],M) :- L = atom_length(H), L > M, M is L, max_length(T,M).
max_length([[H|_]|T],M) :- L = atom_length(H), L < M, max_length(T,M).

%% The following predicate displays a line of the Board.
display_line([]).
display_line(['XXX'|T]) :- tab(1), print('XXX'), tab(1), write('|'), !, display_line(T).
display_line([H|T]) :- H \= 'XXX', tab(2),print(H), tab(2), write('|'),display_line(T).

display_board([]).
display_board([H|T]) :- tab(5), display_line(H),nl,display_board(T).