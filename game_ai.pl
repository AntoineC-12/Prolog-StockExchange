% This is the file containing the AI of the StockExchange Game
% Author: Antoine Pouillaude.


%%%% all_possible_moves(+State_Of_The_Game,+Player_Who_Will_Make_The_Move,?Possible_Moves)
%% The following predicate will get all the possible moves that the ai could make.
all_possible_moves([Stacks,S,TP,RJ1,RJ2],Player,PossibleMoves) :- possible_moves(Stacks,TP,Player,[1,2,3],PossibleMoves).


%%%% possible_moves(+Stacks_Of_The_Game,+Trader_Position,+Player_Who_Will_Make_The_Move,+List_Of_Jumps_To_make,?List_Of_Moves)
%% possible_moves will get the list of the moves possible by applying all the jumps given in the fourth parameter. In that game the list should be [1,2,3].
possible_moves(Stacks,TP,Player,[],[]) :- !.
possible_moves(Stacks,TP,Player,[H|T],ListMoves) :-
		possible_moves(Stacks,TP,Player,T,SListMoves), 
		get_possible_list(Stacks,TP,H,ListProd),
		reverse(ListProd,RevList),
		concat([Player,H],ListProd, TempList),
		concat([Player,H],RevList, TempListRev),
		concat([TempList],[TempListRev],Temp),
		concat(Temp,SListMoves,ListMoves).


%%%% get_possible_list(+List_Of_Stacks_In_The_Game,+Trader_Position,+Number_Of_Jumps_To_Make,?List_Of_Product_The_Player_Can_Have_After_Moving)
%% This predicate will compute the list of products available from the current trader position by applying Pos moves to the pawn.
get_possible_list(Stacks,TP,Pos,ListProd) :-
		get_indexes(Stacks,TP,Pos,[NTP,ISup,IInf]),
		nth0(ISup,Stacks,E1),
		nth0(IInf,Stacks,E2),
		[Prod1|T1] = E1, [Prod2|T2] = E2,
		ListProd = [Prod1,Prod2].


%%%% best_move(+GameState,+Depth_The_Search,+Player_Who_Is_Playing,?Best_Move)
%% This predicate will use Minimax Alpha/Beta algorithm to search for the best solution possible to play. 
%% WARNING: We got a stack-overflow for Depth higher or equal to 5 when using it in standalone. It cannot deeper than 2 in game configurations.
best_move(State,D,Player,BestMove) :- 
		all_possible_moves(State,Player,PossibleMoves), 
		best_move_Loop(State,PossibleMoves,D,Player,Val,BestMove).

%%%% best_move_loop(+GameState,+List_Of_All_The_Moves_Possible,+Player_Who_Is_Making_The_Moves,?Value_Of_The_Move,?BestMove_Possible)
%% This rule will loop over the list of all the possible moves (computed thanks to the all_possible_moves predicate) and choose the best move that maximise 
%% the evaluation of the situation.
best_move_Loop(_,[],_,_,-999,_) :- !. 
best_move_Loop(State,[H|T],D,Player,Val,BestMove) :-
		play(State,H,NewState,_),
		min_Algo(NewState,D,-999,999,Player,CurrVal),
		best_move_Loop(State,T,D,Player,NVal,NBestMove),
		test_best_move(CurrVal,NVal,Val,H,NBestMove,BestMove).

%%%% test_best_move(+Value_Of_The_Current_Best_Move,+Value_Of_The_Newly_Computed_Move,?Max_Value_Of_The_Two_Moves,+Current_Move,?New_Move)
%% This predicate compares the value of the current mximizing move and the one that was just computed. It returns the new max value and the new best move.
test_best_move(CurrVal,NVal,CurrVal,H,NBestMove,H) :- CurrVal >= NVal, !.
test_best_move(CurrVal,NVal,NVal,H,NBestMove,NBestMove) :- NVal > CurrVal.


%%%% min_Algo(+GameState,+Depth,+Alpha,+Beta,+Player_Who_Is_Playing,+Value_Of_The_Minimal_Move)
%% This rule is the Min part of the Minimax Alpha/Beta algorithm, it will compute the move that will minise the opponent's profit.
min_Algo(State,0,_,_,Player,ReturnValue) :- !,evalState(State,Earnings),eval(Earnings,Player,ReturnValue).
min_Algo([[],S,TP,RJ1,RJ2],D,_,_,Player,ReturnValue) :- D > 0, !,evalState([[],S,TP,RJ1,RJ2],Earnings),eval(Earnings,Player,ReturnValue).
min_Algo([Stacks,S,TP,RJ1,RJ2],D,Alpha,Beta,Player,ReturnValue) :- D > 0, Stacks \= [],
		opponent([Stacks,S,TP,RJ1,RJ2],Player,Opponent),
		all_possible_moves([Stacks,S,TP,RJ1,RJ2],Opponent,PossibleMoves),
		min_Algo_Loop([Stacks,S,TP,RJ1,RJ2],PossibleMoves,D,Alpha,Beta,Player,999,ReturnValue).

%%%% min_Algo_Loop(+GameState,+The_List_Of_All_The_Moves_The_Opponent_Can_Make,+Depth,+Alpha,+Beta,+Player,-Value_Of_The_Current_Minimizing_Move,?Value_Of_The_Minimizing_Move)
%% This predicate loops over the list of all the possible moves the opponent can make and return the value of the move that minize the opponent's profit.
min_Algo_Loop(_,[],_,_,_,_,Val,Val) :- !.
min_Algo_Loop(_,_,_,Alpha,_,_,Val,Val) :- Alpha >= Val, !.
min_Algo_Loop(State,[H|T],D,Alpha,Beta,Player,Val,ReturnValue) :- Alpha < Val,
		play(State,H,NewState,_),
		min(Val,Beta,NBeta),
		Dd is D - 1,
		max_Algo(NewState,Dd,Alpha,Beta,Player,RValue),
		min(Val,RValue,NVal),
		min_Algo_Loop(State,T,D,Alpha,NBeta,Player,NVal,ReturnValue).


%%%% max_Algo(+GameState,+Depth,+Alpha,+Beta,+Player_Who_Is_Playing,+Value_Of_The_Maximal_Move)
%% This rule is the Min part of the Minimax Alpha/Beta algorithm, it will compute the move that will maximise the player's profit.
max_Algo(State,0,_,_,Player,ReturnValue) :- !,evalState(State,Earnings),eval(Earnings,Player,ReturnValue).
max_Algo([[],S,TP,RJ1,RJ2],D,_,_,Player,ReturnValue) :- D > 0, !, evalState([[],S,TP,RJ1,RJ2],Earnings),eval(Earnings,Player,ReturnValue).
max_Algo([Stacks,S,TP,RJ1,RJ2],D,Alpha,Beta,Player,ReturnValue) :- D > 0, Stacks \= [],
		all_possible_moves([Stacks,S,TP,RJ1,RJ2],Player,PossibleMoves), 
		max_Algo_Loop([Stacks,S,TP,RJ1,RJ2],PossibleMoves,D,Alpha,Beta,Player,-999,ReturnValue).

%%%% min_Algo_Loop(+GameState,+The_List_Of_All_The_Moves_The_Player_Can_Make,+Depth,+Alpha,+Beta,+Player,-Value_Of_The_Current_Maximizing_Move,?Value_Of_The_Maximizing_Move)
%% This predicate loops over the list of all the possible moves the player can make and return the value of the move that maximize the player's profit.
max_Algo_Loop(_,[],_,_,_,_,Val,Val) :- !.
max_Algo_Loop(_,_,_,_,Beta,_,Val,Val) :- Val >= Beta, !.
max_Algo_Loop(State,[H|T],D,Alpha,Beta,Player,Val,ReturnValue) :- Beta > Val,
		play(State,H,NewState,_),
		max(Val,Alpha,NAlpha),
		Dd is D - 1,
		min_Algo(NewState,Dd,Alpha,Beta,Player,RValue),
		max(Val,RValue,NVal),
		max_Algo_Loop(State,T,D,NAlpha,Beta,Player,NVal,ReturnValue).
		
%%%% eval(+Earnings_Of_The_Players,+Player_Who_Is_Playing,?Difference_Between_The_Two_Players_Profits)
%% This predicate calculates the difference between the two players' profits. 
eval([],_,0) :- !.
eval([[Player,T1]|T2], Player, Result) :- !,
	eval(T2,Player,NR), Result is T1 + NR.
eval([[H,T1]|T2],Player,Result) :- H \= Player, eval(T2,Player,NR), Result is NR - T1.

%%%% opponent(+GameState,+Player,?Opponent_Of_The_Player)
%% This predicate returns the opponent of the player specified in the parameters of the predicate
opponent([_,_,_,[Player|_],[Opponent|_]],Player,Opponent) :- !. 
opponent([_,_,_,[Opponent|_],[Player|_]],Player,Opponent). 
		
%%%% min(+A,+B,?Minimum_Between_A_And_B)
%% This rule returns the minimum value of two numbers.
min(A,B,B) :- A > B,!.
min(A,B,A).

%%%% max(+A,+B,?Maximum_Between_A_And_B)
%% This rule returns the maximum value of two numbers.
max(A,B,B) :- A < B,!.
max(A,B,A).

