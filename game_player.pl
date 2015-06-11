% This is the file containing the code to allow humans to play to the StockExchange Game
% Author: Antoine Pouillaude.


%%%% player_interface(+GameState,+Player_Who_Will_Enter_Information_To_Play,+Mode)
%%% Mode = 1 if this is a human_vs_ai game, Mode = 0 if this is a human_vs_human game. 
%% The predicate will display a user interface in order to let the player choose their options. One can always type "q" to go back to the 
%% main menu.
player_interface(State,Player,Mode):-write('Now it s '),write(Player),write(' s turn : '),nl,
		write('Number of jumps : '),read(J),nl,
		(J == 3 -> Res is 3;
			(J == 2 -> Res is 2;
				(J == 1 -> Res is 1;
					(J== q ->  stockexchange(_);
						write('Incorrect input'),nl,player_interface(State,Player,Mode)
					)
				)
			)
		),
		[Stacks,_,TP,_,_] = State,
		get_possible_list(Stacks,TP,J,[Prod1,Prod2]),
		write('Which one do you want to keep : '),nl,
		binary_choice(Prod1,Prod2,P),
		KeepIndex is P - 1,
		nth0(KeepIndex,[Prod1,Prod2],Keep),
		get_the_opposite_option([Prod1,Prod2],KeepIndex,Sell),
		write('You are going to play '),write([Player,J,Keep,Sell]),write('. Is that ok ?'),nl,
		binary_choice('Yes','No',Choice),
		(Choice == 2 -> player_interface(State,Player,Mode);
			play(State,[Player,J,Keep,Sell],NewState,Ret),
			(Ret \= 0->error_message(Ret),player_interface(State,Player,Mode);
				opponent(NewState,Player,Opponent),
				(Mode == 0-> human_vs_human(NewState,Opponent);
					human_vs_ai(NewState,Opponent)
				)
			)
		).

%%%% human_vs_human(+GameState,+CurrentPlayer)
%% This predicate will allow two human players to play against each other. It displays the scores if the game is over, otherwise it calls the
%% player_interface rule to let the other player play.
human_vs_human([Stacks,S,TP,RJ1,RJ2],_) :- length(Stacks,Le),Le=<2,!,
		display_game([Stacks,S,TP,RJ1,RJ2]),nl,nl,tab(20),write('The Game is Over'),nl,
		tab(20),evalState([[],S,TP,RJ1,RJ2],Earnings),display_earnings(Earnings),nl,nl.
human_vs_human([Stacks,S,TP,RJ1,RJ2],Player) :- length(Stacks,Le),Le>2, State = [Stacks,S,TP,RJ1,RJ2], 
		display_game(State),player_interface(State,Player,0).

%%%% human_vs_ai(+GameState,+CurrentPlayer)
%% This predicate allows a human player to play against an AI. It displays the scores if the game is over, otherwise it calls the
%% player_interface if this the human's turn or just let the AI play the best move it can find.
human_vs_ai([Stacks,S,TP,RJ1,RJ2],_) :- length(Stacks,Le),Le=<2,!,
		display_game([Stacks,S,TP,RJ1,RJ2]),nl,nl,tab(20),write('The Game is Over'),nl,
		tab(20),evalState([[],S,TP,RJ1,RJ2],Earnings),display_earnings(Earnings),nl,nl.
human_vs_ai([Stacks,S,TP,RJ1,[Player|T]],Player) :- length(Stacks,Le),Le>2,!, State = [Stacks,S,TP,RJ1,[Player|T]], 
		display_game(State),best_move(State,5,Player,BestMove),
		play(State,BestMove,NewState,_),
		opponent(NewState,Player,Opponent),
		human_vs_ai(NewState,Opponent).
human_vs_ai([Stacks,S,TP,RJ1,[AI|T]],Player) :- length(Stacks,Le),Le>2,Player \= AI, State = [Stacks,S,TP,RJ1,[AI|T]], 
		display_game(State),player_interface(State,Player,1).


%%%% binary_choice(+First_Option,+Second_Option,-Choice_Made_By_The_Player)
%% This rule displays two options and let the player type their choice. It checks if what the player typed is correct and return the choice made.
binary_choice(Option1,Option2,Res) :-
		write('1. Option 1 : '),write(Option1),nl,
		write('2. Option 2 : '),write(Option2),nl,
		write('Choice : '),read(P),
		(P == 2 -> Res is 2;
			(P == 1 -> Res is 1;
				(P == q -> stockexchange(_); 
					write('Please choose a valid option.'),nl,
					binary_choice(Option1,Option2,Res)
				)
			)
		).

%%%% get_the_opposite_option(+List_Of_The_Two_Choices,+Index_Of_The_Selected_Choice,-The_Opposite_Of_The_Choice_Made_By_The_User)
%% This rule gets the choice that the player did not choose in a binary menu of choices.
get_the_opposite_option([_,Prod2],0,Prod2).
get_the_opposite_option([Prod1,_],1,Prod1).


