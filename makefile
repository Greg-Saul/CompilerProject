# Variables
LEX = flex
CC = gcc
# Name of your .l file
LEX_SRC = lexer.l
LEX_OUT = lex.yy.c
EXEC = lexer

# Targets
all: $(EXEC)

$(LEX_OUT): $(LEX_SRC)
	$(LEX) $(LEX_SRC)

$(EXEC): $(LEX_OUT)
	$(CC) -o $(EXEC) $(LEX_OUT)

clean:
	rm -f $(LEX_OUT) $(EXEC)
