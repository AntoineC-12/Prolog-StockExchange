% This is the file containing the engine of the StockExchange Game
% Author: Frédéric Rouffineau et Antoine Pouillaude.

use_module(stock_exchange).
%:- include(game_ai).
%:- include(game_display).
%:- include(list_library).

% A game state will define as State = [Marchandises, Bourse, PositionTrader, ReserveJoueur1,ReserveJoueur2].

%%%% error_message(+Value_Returned_By_A_Predicate)
%% This rule takes the value returned by a predicate and print the right error_message on the screen.
error_message(1) :- write('Elements given were not found on top of the adjacent stacks.').
error_message(2) :- write('Position not possible.').
error_message(3) :- write('The game is over. No move possible').

%%%% starting_state(?State_To_Be_Generated,+Player_1's_Name,+Player_1's_Name)
%% This predicate generates the initial state of the game. 
starting_state(State,NameJ1,NameJ2) :-
		generating_stacks([[wheat,6],[corn,6],[rice,6],[sugar,6],[coffee,6],[cocoa,6]],Stacks,9),
		Bourse = [[wheat,7],[corn,6],[rice,6],[sugar,6],[coffee,6],[cocoa,6]],
		random(0,8,TP),
		State = [Stacks,Bourse,TP,[NameJ1],[NameJ2]].

%%%% is_possible(+List_Of_Stacks,+Current_Trader_Position,+Move_The_Player_Wants_To_Make,?Return_Value)
%%% Return_Value = 0 if the move is possible, 1 if the two given element are not on the two stacks adjacent ot the Trader position, 2 if the move applied to the Trader is not in [1,2,3].
%% This predicate will check if a move is possible in the current game configuration.
is_possible(Stacks,TP,[_,Pos,Keep,Sell],ReturnValue):- Pos < 4, Pos >0, !,
		get_indexes(Stacks,TP,Pos,[_,ISup,IInf]),
		nth0(ISup,Stacks,E1),
		nth0(IInf,Stacks,E2),
		test_comb(Keep,Sell,E1,E2,ReturnValue).
is_possible(_,_,_,2).

%%%% test_comb(+The_Element_The_Player_Wants_To_Keep,+The_Element_The_Player_Wants_To_Sell,+One_Of_The_Adjacent_Stack,+The_Other_Adjacent_Stack,?The_Return_Value)
%%% Return_Value = 0 if the two products are on top of the two stacks adjacent to the Trader's position, = 1 otherwise.
%% This rule test if the two elements given in the move are on top of the two adjacent stacks of the Trader stack.
test_comb(Keep,Sell,[Keep|_],[Sell|_],0) :- !.
test_comb(Keep,Sell,[Sell|_],[Keep|_],0) :- !.
test_comb(_,_,_,_,1).

%%%% get_indexes(+List_Of_The_Stacks,+Current_Position_Of_The_Trader,+Move_To_Apply_To_The_Trader,?List_Containing_The_Position_Of_The_Trader_And_The_Position_After_The_Position_Before).
%% This predicate will calculate the indexes of Trader after a move as well as the indexes of the position before and after. 
%% The result is returned in Res.
get_indexes(Stacks,CP,Pos,Res) :-
		length(Stacks,Length), 
		TempTp is CP + Pos,
		my_mod(TempTp,Length,NTP),
		TempISup is NTP+1, my_mod(TempISup,Length,ISup),
		TempIInf is NTP-1, my_mod(TempIInf,Length,IInf),
		Res = [NTP,ISup,IInf].

%%%% my_mod(+Number_To_Be_Mod,+Modulo,?Result)
%% I use this to avoid the zero division exception when the stack is empty.
my_mod(_,0,0) :-!.
my_mod(Nb,Mod,Res) :- Mod \=0, Res is mod(Nb,Mod).

%%%% add_to_player(+Name_Of_The_Player_To_Whom_To_Add_The_Product,+Product_To_Add,+Reserve_Of_Player1,+Reserve_Of_Player2,?New_Reserve_Of_Player1,?New_Reserve_Of_Player2)
%% This rule will add the product the player decided to keep in their own stock
add_to_player(Player,Keep,[Player|T],[Player2|T2],NRJ1,NRJ2) :- Player2 \= Player, !,
		concat([Keep],T,NT), NRJ1 = [Player|NT], NRJ2 = [Player2|T2].
add_to_player(Player,Keep,[Player1|T1],[Player|T],NRJ1,NRJ2) :- Player1 \= Player, !,
		concat([Keep],T,NT), NRJ2 = [Player|NT], NRJ1 = [Player1|T1].

%%%% play(+Game_State,+Move_To_Apply,?New_State,-Return_Value)
%% This predicate will update the game state according to the move provided to the function.
play([Stacks,_,_,_,_],_,_,3) :- length(Stacks,Le),Le =< 2, !.
play([Stacks,S,TP,RJ1,RJ2],[Player,Pos,Keep,Sell],NewState,RetValue) :- length(Stacks,Le),Le > 2,is_possible(Stacks,TP,[Player,Pos,Keep,Sell],ExitStatus),
		play_ret([Stacks,S,TP,RJ1,RJ2],[Player,Pos,Keep,Sell],NewState,RetValue,ExitStatus).

%%%% play_ret(+Game_State,+Move_To_Apply,?New_State,-Return_Value,+Value_Returned_By_The_is_possible_Predicate)
play_ret([Stacks,S,TP,RJ1,RJ2],[Player,Pos,Keep,Sell],NewState,0,0) :- !,
		get_indexes(Stacks,TP,Pos,[NTP,ISup,IInf]),
		nth0(ISup,Stacks,E1),
		nth0(IInf,Stacks,E2),
		pop(E1,NE1), pop(E2,NE2),
		update_i(Stacks,ISup,NE1,NTempStacks), update_i(NTempStacks,IInf,NE2,NStacks),
		clean_list_and_update_TP(NStacks,NewStacks,NTP,NTPmod), 
		length(NewStacks,Length), my_mod(NTPmod,Length,NewTP), 
		add_to_player(Player,Keep,RJ1,RJ2,NRJ1,NRJ2),
		member_sec_order_e(S,Sell,Elt), [Name,Value] = Elt, NValue is Value - 1,
		NElt = [Name,NValue], update_e(S,Elt,NElt,NS), 
		NewState = [NewStacks,NS,NewTP,NRJ1,NRJ2].
play_ret([Stacks,S,TP,RJ1,RJ2],_,NewState,ExitStatus,ExitStatus) :- NewState =[Stacks,S,TP,RJ1,RJ2].


%%%% choose(+List_Of_Element_From_Which_To_Pick,?Picked_Element)
%% The choose rule will pseudo-randomly choose an element of a list given in the predicate parameters.
choose([], []).
choose(List, Elt) :-
        length(List, Length),
        random(0, Length, Index),
        nth0(Index, List, Elt).
        
%%%% generating_stacks(+Product_Pieces_To_Place,?List_Of_Generated_Stacks,+Number_Of_Stacks_To_Generate)
%% This predicate is used to generate the list of stacks during the game initialisation process.
generating_stacks(_,[],0) :- !.
generating_stacks(S,Stacks,Nb) :- Nb > 0,
		generating_a_stack(S,Stack,4,SAfter),
		M is Nb - 1,
		generating_stacks(SAfter,Sts,M),
		concat([Stack],Sts,Stacks).


%%%% generating_a_stack(+Product_Pieces_To_Place,?Generated_Stack,+Number_Of_Pieces_In_AS_tack,-Product_Pieces_Left_After_Generation)
%% The following piece of code generates one of the nine stack of the game.
generating_a_stack(S,[],0,S) :- !.
generating_a_stack(S,Stack,Nb,SAfter) :- Nb > 0, 
		choose(S,Elt),
		[H,Stock] = Elt, 
		NStock is Stock - 1,
		update_e(S,Elt,[H,NStock],Ssub),
		remove_zero(Ssub,Ssub_no_zero),
		M is Nb -1,
		generating_a_stack(Ssub_no_zero,St,M,SAfter),
		concat([H],St,Stack).


%%%% evalState(+GameState,?Players'Earnings).
%% This predicate evaluates the current state of the game and returns the current earnings of the two players according to the stock exchange state.
evalState(State,Earnings) :- 
		[_,S,_,RJ1,RJ2] = State,
		[Player1|Reserve1] = RJ1,
		[Player2|Reserve2] = RJ2,
		eval_player_earning(S,Reserve1,J1Earnings),
		eval_player_earning(S,Reserve2,J2Earnings),
		Earn1 = [Player1,J1Earnings],Earn2 = [Player2,J2Earnings],
		Earnings = [Earn1,Earn2].


%%%% eval_player_earning(+Stock,+PlayerReserve,?Player'sEarning).
%% This predicate computes the earnings of one player according to the current state of the stock exchange.
eval_player_earning(_,[],0) :- !.
eval_player_earning(Stock,[H|T],JEarning) :-
		eval_player_earning(Stock,T,SJearning),
		member_sec_order_e(Stock,H,Elt),
		[_,Value] = Elt, JEarning is SJearning + Value.

%%%% ai_vs_ai(+GameState,+Player_Who_Will_Make_The_Move).
%% This rule is the ai_vs_ai part of the game.
ai_vs_ai([Stacks,S,TP,RJ1,RJ2],_) :- length(Stacks,Le),Le=<2,!,
		display_game([Stacks,S,TP,RJ1,RJ2]),nl,nl,tab(20),write('The Game is Over'),nl,
		tab(20),evalState([[],S,TP,RJ1,RJ2],Earnings),display_earnings(Earnings),nl,nl.
ai_vs_ai([Stacks,S,TP,RJ1,RJ2],Player) :- length(Stacks,Le),Le>2, State = [Stacks,S,TP,RJ1,RJ2], 
		display_game(State),best_move(State,2,Player,BestMove),
		play(State,BestMove,NewState,_),
		opponent(State,Player,Opponent),
		ai_vs_ai(NewState,Opponent).
