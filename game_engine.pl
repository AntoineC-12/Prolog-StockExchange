% This is the file containing the engine of the StockExchange Game
% Author: Antoine Pouillaude.

use_module(stock_exchange).


myVar(board,[['wheat ',7,6,5,4,3,2,1],['corn  ',6,5,4,3,2,1,0],['rice  ',6,5,4,3,2,1,0],['sugar ',6,5,4,3,2,1,0],['coffee',6,5,4,3,2,1,0],['cocoa ',6,5,4,3,2,1,0]]).
myVar(stocks,[[wheat,6],[corn,6],[rice,6],[sugar,6],[coffee,6],[cocoa,6]]).

% A game state will define as State = [Marchandises, Bourse, PositionTrader, ReserveJoueur1,ReserveJoueur2].

%% This predicate generates the initial state of the game. 
starting_state(State,NameJ1,NameJ2) :-
		generating_stacks([[wheat,6],[corn,6],[rice,6],[sugar,6],[coffee,6],[cocoa,6]],Stacks,9),
		Bourse = [[wheat,7],[corn,6],[rice,6],[sugar,6],[coffee,6],[cocoa,6]],
		random(0,8,TP),
		State = [Stacks,Bourse,TP,[NameJ1],[NameJ2]].

%% This predicate will check if a move is possible in the current game configuration.
is_possible(Stacks,TP,[Player,Pos,Keep,Sell],ReturnValue):- Pos < 4, Pos >0, !,
		get_indexes(Stacks,TP,Pos,[NTP,ISup,IInf]),
		nth0(ISup,Stacks,E1),
		nth0(IInf,Stacks,E2),
		test_comb(Keep,Sell,E1,E2,ReturnValue).
is_possible(Stacks,TP,[Player,Pos,Keep,Sell],2).

%% This rule test if the two elements given in the move are on top of the two adjacent stacks of the Trader stack.
test_comb(Keep,Sell,[Keep|_],[Sell|_],0) :- !.
test_comb(Keep,Sell,[Sell|_],[Keep|_],0) :- !.
test_comb(Keep,Sell,[H1|_],[H2|_],1).

%% This predicate will calculate the indexes of Trader after a move as well as the indexes of the position before and after. 
%% The result is returned in Res.
get_indexes(Stacks,CP,Pos,Res) :-
		length(Stacks,Length), 
		TempTp is CP + Pos,
		NTP is mod(TempTp,Length),
		TempISup is NTP+1, ISup is mod(TempISup,Length),
		TempIInf is NTP-1, IInf is mod(TempIInf,Length),
		Res = [NTP,ISup,IInf].

%% This rule will add the product the player decided to keep in their own stock
add_to_player(Player,Keep,[Player|T],[Player2|T2],NRJ1,NRJ2) :- Player2 \= Player, !,
		concat([Keep],T,NT), NRJ1 = [Player|NT], NRJ2 = [Player2|T2].
add_to_player(Player,Keep,[Player1|T1],[Player|T],NRJ1,NRJ2) :- Player1 \= Player, !,
		concat([Keep],T,NT), NRJ2 = [Player|NT], NRJ1 = [Player1|T1].


%% This predicate will update the game state according to the move provided to the function.
play([Stacks,S,TP,RJ1,RJ2],[Player,Pos,Keep,Sell],NewState,RetValue) :- is_possible(Stacks,TP,[Player,Pos,Keep,Sell],ExitStatus),
		play([Stacks,S,TP,RJ1,RJ2],[Player,Pos,Keep,Sell],NewState,RetValue,ExitStatus).
play([Stacks,S,TP,RJ1,RJ2],[Player,Pos,Keep,Sell],NewState,0,0) :- !,
		get_indexes(Stacks,TP,Pos,[NTP,ISup,IInf]),
		nth0(ISup,Stacks,E1),
		nth0(IInf,Stacks,E2),
		pop(E1,NE1), pop(E2,NE2),
		update_i(Stacks,ISup,NE1,NTempStacks), update_i(NTempStacks,IInf,NE2,NStacks),
		clean_list_and_update_TP(NStacks,NewStacks,NTP,NTPmod), 
		length(NewStacks,Length), NewTP is mod(NTPmod,Length), 
		add_to_player(Player,Keep,RJ1,RJ2,NRJ1,NRJ2),
		member_sec_order_e(S,Sell,Elt), [Name,Value] = Elt, NValue is Value - 1,
		NElt = [Name,NValue], update_e(S,Elt,NElt,NS), 
		NewState = [NewStacks,NS,NewTP,NRJ1,NRJ2].

play([Stacks,S,TP,RJ1,RJ2],[Player,Pos,Keep,Sell],NewState,2,2) :- !,write('Position not possible.'), NewState =[Stacks,S,TP,RJ1,RJ2].
play([Stacks,S,TP,RJ1,RJ2],[Player,Pos,Keep,Sell],NewState,1,1) :- write('Elements given were not found on top of the adjacent stacks.'),NewState =[Stacks,S,TP,RJ1,RJ2].



%% The choose rule will pseudo-randomly choose an element of a list given in the predicate parameters.
choose([], []).
choose(List, Elt) :-
        length(List, Length),
        random(0, Length, Index),
        nth0(Index, List, Elt).
        

%% This predicate is used to generate the list of stacks during the game initialisation process.
generating_stacks(_,[],0) :- !.
generating_stacks(S,Stacks,Nb) :- Nb > 0,
		generating_a_stack(S,Stack,4,SAfter),
		M is Nb - 1,
		generating_stacks(SAfter,Sts,M),
		concat([Stack],Sts,Stacks).


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

evalState(State,Earnings) :- 
		[Stacks,S,TP,RJ1,RJ2] = State,
		[Player1|Reserve1] = RJ1,
		[Player2|Reserve2] = RJ2,
		eval_player_earning(S,Reserve1,J1Earnings),
		eval_player_earning(S,Reserve2,J2Earnings),
		Earn1 = [Player1,J1Earnings],Earn2 = [Player2,J2Earnings],
		Earnings = [Earn1,Earn2].


eval_player_earning(Stock,[],0) :- !.
eval_player_earning(Stock,[H|T],JEarning) :-
		eval_player_earning(Stock,T,SJearning),
		member_sec_order_e(Stock,H,Elt),
		[Name,Value] = Elt, JEarning is SJearning + Value.
