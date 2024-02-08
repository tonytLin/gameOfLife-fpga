import tkinter as tk

class Cell():
    def __init__(self, canvas, row, col, cell_size):
        self.canvas = canvas
        self.row = row
        self.col = col
        self.cell_size = cell_size
        self.filled = False

    def draw(self):
        if self.filled:
            bg_colour = "purple"
            bg_active = "purple"
        else:
            bg_colour = "white"
            bg_active = "orchid1"

        self.canvas.create_rectangle(self.col*cell_size, self.row*cell_size, (self.col+1)*cell_size, (self.row+1)*cell_size, fill = bg_colour, outline = "black", activefill=bg_active)

    def on_click(self):
        self.filled = not self.filled

def run():
    n_row=int(row_input.get())
    n_col=int(col_input.get())

    # resize canvas
    main.config(width=n_col*cell_size, height=n_row*cell_size)
    
    # initialize grid
    for row in range(n_row):
        r = []
        for col in range(n_col):
            cell = Cell(main, row, col, cell_size)
            cell.draw()
            r.append(cell)
        grid.append(r)

    # bind canvas events
    main.bind("<Button-1>", click)
    main.bind("<B1-Motion>", hold)
    main.bind("<ButtonRelease-1>", release)

def click(event):
    x = int(event.x/cell_size)
    y = int(event.y/cell_size)
    if 0 <= x < int(col_input.get()) and 0 <= y < int(row_input.get()):
        cell = grid[y][x]
        cells_filled.append(cell)
        cell.on_click()
        cell.draw()

def hold(event):
    x = int(event.x/cell_size)
    y = int(event.y/cell_size)
    if 0 <= x < int(col_input.get()) and 0 <= y < int(row_input.get()):
        cell = grid[y][x]
        if cell not in cells_filled:
            cells_filled.append(cell)
            cell.on_click()
            cell.draw()

def release(event):
    cells_filled.clear()

def export():
    with open("initialState.txt", "w") as txt_file:
        for row in grid:
            for cell in row:
                txt_file.write(str(int(cell.filled==True)))
                txt_file.write("\n")

if __name__ == '__main__':
    root = tk.Tk()
    root.title('Initial State Generator')
    main = tk.Canvas(root, width=0, height=0)
    main.grid(row=0, rowspan=100, column=2)

    grid = []
    cells_filled = []
    cell_size = 12

    # Take inputs for number of rows/columns
    tk.Label(root, text='Row').grid(row=0)
    row_input = tk.Entry(root)
    row_input.grid(row=0, column=1)
    row_input.insert(0, 60)

    tk.Label(root, text='Column').grid(row=1)
    col_input = tk.Entry(root)
    col_input.grid(row=1, column=1)
    col_input.insert(0, 80)

    # Run/export button
    run_button = tk.Button(root, text='Run', width=10, command=run)
    run_button.grid(row=2, column=0)

    export_button = tk.Button(root, text='Export', width=10, command=export)
    export_button.grid(row=2, column=1)
    root.mainloop()

