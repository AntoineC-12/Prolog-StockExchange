% This is the initilisation file of the StockExchange Game
% Author: Antoine Pouillaude.

use_module(stock_exchange).


myVar(board,[['wheat ',7,6,5,4,3,2,1],['corn  ',6,5,4,3,2,1,0],['rice  ',6,5,4,3,2,1,0],['sugar ',6,5,4,3,2,1,0],['coffee',6,5,4,3,2,1,0],['cocoa ',6,5,4,3,2,1,0]]).
myVar(stocks,[[wheat,6],[corn,6],[rice,6],[sugar,6],[coffee,6],[cocoa,6]]).

choose([], []).
choose(List, Elt) :-
        length(List, Length),
        random(0, Length, Index),
        nth0(Index, List, Elt).


starting_state(State).

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