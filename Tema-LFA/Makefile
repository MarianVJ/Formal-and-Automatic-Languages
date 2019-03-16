#JORASCU MARIAN VLADUT 335CC
build: program

program: program.l
	lex -o program.c program.l
	gcc -o program program.c

run:
	./program $(fisier)

clean:
	rm a.out
