class Board:
    def __init__(self):
        self.size = 3
        self.cells = [["0" for x in range(3)] for x in range(3)]
        self.winner = "0"


def new_board():
    return Board()


def print_board(board):
    print("|-+-+-|")
    for i in range(board.size):
        str_arr = "|"
        for j in range(board.size):
            if board.cells[i][j] == "0":
                str_arr += str(i * 3 + j + 1)
            else:
                str_arr += board.cells[i][j]
            str_arr += "|"
        print(str_arr)
        print("|-+-+-|")


def is_game_over(board):
    if board.cells[0][0] == board.cells[0][1] == board.cells[0][2]!='0':
        board.winner = board.cells[0][0]
        return True
    if board.cells[1][0] == board.cells[1][1] == board.cells[1][2]!='0':
        board.winner = board.cells[1][0]
        return True
    if board.cells[2][0] == board.cells[2][1] == board.cells[2][2]!='0':
        board.winner = board.cells[2][0]
        return True
    if board.cells[0][0] == board.cells[1][0] == board.cells[2][0]!='0':
        board.winner = board.cells[0][0]
        return True
    if board.cells[0][1] == board.cells[1][1] == board.cells[2][1]!='0':
        board.winner = board.cells[0][1]
        return True
    if board.cells[0][2] == board.cells[1][2] == board.cells[2][2]!='0':
        board.winner = board.cells[0][2]
        return True
    if board.cells[0][0] == board.cells[1][1] == board.cells[2][2]!='0':
        board.winner = board.cells[0][0]
        return True
    if board.cells[0][2] == board.cells[1][1] == board.cells[2][0]!='0':
        board.winner = board.cells[0][2]
        return True
    for i in board.cells:
        for j in i:
            if j =='0':
                return False
    else:
        board.winner = "0"
        return True

    
def announce_outcome(board):
    if board.winner == "0":
        print("Draw")
    else:
        str_arr = board.winner + " won"
        print(str_arr)



