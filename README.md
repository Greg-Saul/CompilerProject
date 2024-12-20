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

<strong>Greg's work</strong> - parser rules, parse tree

<strong>Taylor's work</strong> - makefile, parser integration with lexer

<strong>Required files:</strong> makefile , parser.y, lexer.l 

<strong>compile directions below:</strong>

make </br>
./parser < filename

## Symbol table assignment

We all worked together on the code in the library and contributed equally

our symbol table is just a part of out parser.y file (for now)

run instructions

<strong>compile directions below:</strong>

make

./parser < filename

## Code Generator assignment

Greg did most of the work for te1.f24, Taylor did most of the work for te2.f24, however all work was done working together.

our code generator is just a part of out parser.y file (for now)

run instructions

<strong>compile directions below:</strong>

make

./parser < filename

gcc f24.c -o f24 -lm

./f24

## Complete Parser

Taylor worked on the rules and symbol table while Greg worked on the parse tree

<strong>compile directions below:</strong>

make

./parser < filename

## *Complete code generator

For this assignment, Taylor and Greg split tasks evenly while Cody is still MIA. Greg worked on making the tree usable and Taylor worked on making the symbol table usable. After seemingly endless hours over the last few weeks, we have equally shared code generation responsibilites. Taylor spent the time reworking our symbol table and figuring out what generated code should look like for many different cases. Greg spent the time figuring out effective waays to read the data structures for the code generation functions.

We simply ran out of time to do much more than we provide in this submission. Between finals and other final projects, time was limited for everything and a lack of constructive feedback on our compiler made it extremely difficult to track down where we had made mistakes that were impacting our attempts to complete the code generation.  We figured out many of our problems likely came from the inital construction of our symbol table and an overcomplication of our tree structure. Had these things been brought to our attention earlier in the semester, we could've made the necessary adjustments much sooner and likely had a better final project.

On the mg.f24 file, our code generation does not work. This is due to the complicated nature of our tree and the shear number of different commands we would have the generate code for. We have included a file called <strong>our_example.f24</strong> that when compiled can show how our addition and multiplication works, along with printing strings and integers. This generated code runs and produces output on the f24 virtual machine.


<strong>compile directions below:</strong>

make

./parser < filename

gcc f24.c -o f24 -lm

./f24

make clean

## What works/doesn't work

Our lexer, parser, ast, and symbol table all work. We have some code generation for printing and <strong> very simple </strong> arithmetic. We were unable to effectively read our tree and symbol table to generate more complicated code on the f24 vm.












