Intrucciones para compilar y ejecutar correctamente los ejemplos propuestos como también otros programas.

- Descomprimir el archivo en una carpeta preferentemente vacía.
- Ejecutar los siguientes comandos:
	
	make
	./grammar < ejemplo1.jm > archivo.c
	gcc archivo.c utils.c -lm
	./a.out < productos_ejemplo_1.txt

Estos comandos propuestos sirven para compilar y ejecutar el ejemplo 1. Sin embargo, se puede modificar facilmente para compilar y ejecutar cualquier programa.

	make
	./grammar < programa.jm > salida.c
	gcc salida.c utils.c -lm
	./a.out