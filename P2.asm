


.global programa
.data 
	buffer: .string "100" #Cantidad de bytes a leer
	ruta: .string "test.txt" 
	errorlectura: .string "no se ha podido abrir el archivo correctamente"
.text
programa: 
	#LEA SI, Cadena
	la s0, buffer	#guardamos direcci�n donde empieza la cadena
	li s1, 101	#Control de bytes le�dos
	
abrirarchivo:
	li a1, 0	#0 -> lectura, 1 modo escritura, 2 modo lectura y escritura
	la a0, ruta	#Enviar la direcci�n del archivo que va a leer
	li a7, 1024	#Par�metro que abre el archivo
	ecall
	
#validar que el archivo se haya abierto correctamente

	blt a0, zero, imprimeerrorlectura
	
	mv s2, a0 	#a0 tiene el descriptor del archivo, puede tener un c�digo de error
	

	
ciclolectura:
	#es necesario que el descriptor est� en a0
	
	mv a0, s2
	mv a1, s0	#Mandar una direcci�n de memoria donde guardar lo que va a leer
	mv a2, s1	#Cantidad de bytes que se van a leer
	li a7, 63	#Par�metros para leer por bytes el archivo
	ecall
	#si da error en a0 queda -1
	
	bltz a0, cerrararchivo	#en caso de error, cerrar el archivo
	mv t0, a0
	add t1, s0, a0		#obteniendo la siguiente posici�n para guardar la cadena
	sb zero, 0(t1)
	
	#imprimir lo que se ha le�do
	mv a0, s0		#asignando lo que vamos a imprimir
	li a7, 4		#Par�metro para imprimir
	ecall
	#repetir el ciclo
	beq t0, s1, ciclolectura	#se repite mientras no se pase
	
	

cerrararchivo:
	
	mv a0, s2	#Descriptor del archivo para cerrar
	li a7, 57	#Par�metro para cerrar el archivo
	ecall
	
imprimeerrorlectura:
	la a0, errorlectura
	li a7, 4
	ecall
	
finalizar:
 	li a7, 10
 	ecall
	