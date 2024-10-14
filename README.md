# CompilerProject COSC 4785

### Greg Saul

### Taylor LaForce

Language: C++

### Lexer Assignment:
<strong>Greg's work</strong> - makefile, part of lexer.l

<strong>Taylor's work</strong> - example_tg.f24, part of lexer.l

<strong>Required files:</strong> makefile , lexer.l , example_tg.f24


<strong>compile instructions:</strong>

make </br>
./lexer < filename

## Parser assignment

compile directions below. I haven't finished the makefile and we should go back through and cleaan up the code a bit later.

bison -d parser.y

flex smallLexer.l

gcc parser.tab.c lex.yy.c -o parser -ll

./parser < filename




