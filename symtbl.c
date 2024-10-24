#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SYMBOLS 50

typedef struct Symbol {
    char *key;
    char *type;
    char *value;
    struct Symbol *next;
} Symbol;

typedef struct SymbolTable {
    Symbol *table[MAX_SYMBOLS];
} SymbolTable;

SymbolTable symbol_table;

unsigned int hash(const char *key) {
    unsigned int hash = 0;
    while (*key) {
        hash = (hash << 5) + *key++;
    }
    return hash % MAX_SYMBOLS;
}

Symbol* create_symbol(char *key, char *type, char *value) {
    Symbol *new_symbol = (Symbol*)malloc(sizeof(Symbol));
    new_symbol->key = strdup(key);
    new_symbol->type = strdup(type);
    new_symbol->value = strdup(value);
    new_symbol->next = NULL;
    return new_symbol;
}

void add_symbol(char *key, char *type, char *value) {
    unsigned int index = hash(key);
    Symbol *new_symbol = create_symbol(key, type, value);

    if (symbol_table.table[index] == NULL) {
        symbol_table.table[index] = new_symbol;
    } else {
        Symbol *current = symbol_table.table[index];
        while (current->next != NULL) {
            if (strcmp(current->key, key) == 0) {
                printf("Symbol '%s' already exists.\n", key);
                free(new_symbol->key);
                free(new_symbol->type);
                free(new_symbol->value);
                free(new_symbol);
                return;
            }
            current = current->next;
        }
        if (strcmp(current->key, key) == 0) {
            printf("Symbol '%s' already exists.\n", key);
            free(new_symbol->key);
            free(new_symbol->type);
            free(new_symbol->value);
            free(new_symbol);
            return;
        }
        current->next = new_symbol;
    }
}

void update_symbol_value(char *key, char *new_value) {
    unsigned int index = hash(key);
    Symbol *symbol = symbol_table.table[index];

    // Search for the symbol by key
    while (symbol != NULL) {
        if (strcmp(symbol->key, key) == 0) {
            // Update the value of the symbol
            free(symbol->value);
            symbol->value = strdup(new_value);
            return;
        }
        symbol = symbol->next;
    }
}

void print_symbol_table() {
    for (int i = 0; i < MAX_SYMBOLS; i++) {
        Symbol *current = symbol_table.table[i];
        while (current != NULL) {
            printf("Key: %s, Type: %s, Value: %s\n", current->key, current->type, current->value);
            current = current->next;
        }
    }
}

void free_symbol_table() {
    for (int i = 0; i < MAX_SYMBOLS; i++) {
        Symbol *current = symbol_table.table[i];
        while (current != NULL) {
            Symbol *temp = current;
            current = current->next;
            free(temp->key);
            free(temp->type);
            free(temp->value);
            free(temp);
        }
        symbol_table.table[i] = NULL;
    }
}
