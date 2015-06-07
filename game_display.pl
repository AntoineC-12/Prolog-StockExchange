use_module(stock_exchange).

%% This file contains the rules to display the gaming board.
% A game state will define as State = [Marchandises, Bourse, PositionTrader, ReserveJoueur1,ReserveJoueur2].

print_u(X) :- write(X).

%% This predicate will display the stacks of merchandise.
display_stack([],_).
display_stack([[H|T]|Tt],1) :- tab(1), write('-->'), tab(1), print_u([H|T]), nl, !, display_stack(Tt,0).
display_stack([[H|T]|Tt],P) :- P \= 1, Psub is P - 1, tab(5), print_u([H|T]), nl, display_stack(Tt,Psub).

%% This rule gets the template associated with the name given in argument.
get_objTemplate(_,[],[]) :- !.
get_objTemplate(Name,[[Name,Temp]|_],Temp) :- !. 
get_objTemplate(Name,[[H|_]|T],Temp) :- H \= Name, get_objTemplate(Name,T,Temp).

%% This function generates the board from the Stock values.
generate_board_from_stock([],[]).
generate_board_from_stock([H|T],Board) :-
	Template = [[wheat,['wheat ',7,6,5,4,3,2,1]],[corn,['corn  ',6,5,4,3,2,1,0]],[rice,['rice  ',6,5,4,3,2,1,0]],[sugar,['sugar ',6,5,4,3,2,1,0]],[coffee,['coffee',6,5,4,3,2,1,0]],[cocoa,['cocoa ',6,5,4,3,2,1,0]]],
	[Name,Value] = H,
	get_objTemplate(Name,Template,Temp),
	update_e(Temp,Value,'XXX',Temp_with_pawn),
	generate_board_from_stock(T,NB),
	concat([Temp_with_pawn],NB,Board).

%% The following predicate displays a line of the Board.
display_line([]).
display_line(['XXX'|T]) :- tab(1), print('XXX'), tab(1), write('|'), !, display_line(T).
display_line([H|T]) :- H \= 'XXX', tab(2),print(H), tab(2), write('|'),display_line(T).

%% This predictate print the Chicago Stock Exchange board on the screen.
display_board([]).
display_board([H|T]) :- tab(5), display_line(H),nl,display_board(T).

%% This rule will display the players stocks.
display_players([]).
display_players([[Name|T]|Tt]) :- 
		tab(5),
		write(Name), 
		write(' : '), 
		print_u(T),
		tab(10),
		display_players(Tt).


%% The following predicate displays a game state.
display_game(State) :-
		write('\33\[2J'),
		[Stacks,S,TP,RJ1,RJ2] = State,
		generate_board_from_stock(S,Board),
		display_board(Board),
		nl, nl, nl,
		display_stack(Stacks,TP),
		nl, nl,
		display_players([RJ1,RJ2]).