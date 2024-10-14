# Compiler and flags
CC = gcc

# Bison and Flex
BISON = bison
FLEX = flex

# Source files
BISON_SRC = parser.y
FLEX_SRC = lexer.l

# Generated files
BISON_C = parser.tab.c
BISON_H = parser.tab.h
FLEX_C = lex.yy.c

# Output executable
TARGET = parser

# Default target
all: $(TARGET)

# Bison rule
$(BISON_C) $(BISON_H): $(BISON_SRC)
	$(BISON) -d $(BISON_SRC)

# Flex rule
$(FLEX_C): $(FLEX_SRC)
	$(FLEX) $(FLEX_SRC)

# Compilation and linking
$(TARGET): $(BISON_C) $(FLEX_C)
	$(CC) $^ -o $@ 

# Clean up
clean:
	rm -f $(TARGET) $(BISON_C) $(BISON_H) $(FLEX_C)