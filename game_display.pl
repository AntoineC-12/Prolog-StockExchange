use_module(stock_exchange).

%% This file contains the rules to display the gaming board.

print_u(X) :- write(X).

%% This predicate will display the stacks of merchandise.
display_stack([]).
display_stack([[H|T]|Tt]) :- print_u([H|T]), nl, display_stack(Tt).

%% The following predicate displays a line of the Board.
display_line([]).
display_line(['XXX'|T]) :- tab(1), print('XXX'), tab(1), write('|'), !, display_line(T).
display_line([H|T]) :- H \= 'XXX', tab(2),print(H), tab(2), write('|'),display_line(T).

display_board([]).
display_board([H|T]) :- tab(5), display_line(H),nl,display_board(T).