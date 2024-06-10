from studentA import print_board, is_game_over, new_board, announce_outcome
#from studentB import  ai_move, get_user_move, is_player_starting

board=new_board()
players_move=is_player_starting()
while not is_game_over(board):
    print_board(board)
    board.cells=players_move and get_user_move(board.cells) or ai_move(board.cells,3,3)
    players_move=not players_move

announce_outcome(board)