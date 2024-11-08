
.global programa
.data
    buffer: .space 100
    ruta: .string "test.txt"
    salida_path: .string "Salida_Laberinto.txt"  
    errorlectura: .string "No se ha podido abrir el archivo correctamente\n"
    filas_msg: .string "\nFilas: "
    columnas_msg: .string "Columnas: "
    valor_posicion_msg: .string "\nPosici�n: "
    valor_elemento_msg: .string " Valor: "
    recorrido_msg: .string "\nRecorrido: "
    exito_msg: .string "\nSalida exitosa\n"
    inaccesible_msg: .string "\nSalida inaccesible\n"
    newline: .string "\n"
    
    filas: .word 0
    columnas: .word 0
    matriz: .space 400
    recorrido: .space 200   

.text
programa: 
    # Iniciar buffer y l�mite de bytes
    la s0, buffer
    li s1, 100

# Leer archivo y llenar buffer
abrirarchivo:
    li a1, 0
    la a0, ruta
    li a7, 1024
    ecall

    blt a0, zero, imprimeerrorlectura
    mv s2, a0

ciclolectura:
    mv a0, s2
    mv a1, s0
    mv a2, s1
    li a7, 63
    ecall

    bltz a0, cerrararchivo
    mv t0, a0
    add t1, s0, a0
    sb zero, 0(t1)

    la a0, buffer
    li a7, 4
    ecall

    beq t0, s1, ciclolectura

cerrararchivo:
    mv a0, s2
    li a7, 57
    ecall

    la t0, buffer
    li t1, 0
    li t2, 0
    li t5, 10
    
# Leer n�mero de filas
parse_filas:
    lb t3, 0(t0)
    li t4, 32
    beq t3, t4, salto_a_columnas

    li t4, 48
    li t6, 57
    blt t3, t4, salto_a_columnas
    bgt t3, t6, salto_a_columnas
    sub t3, t3, t4
    mul t1, t1, t5
    add t1, t1, t3

    addi t0, t0, 1
    j parse_filas

# Leer columnas
salto_a_columnas:
    addi t0, t0, 1
    j parse_columnas

parse_columnas:
    lb t3, 0(t0)
    li t4, 32
    beq t3, t4, almacenar_columnas

    li t4, 48
    li t6, 57
    blt t3, t4, almacenar_columnas
    bgt t3, t6, almacenar_columnas
    sub t3, t3, t4
    mul t2, t2, t5
    add t2, t2, t3

    addi t0, t0, 1
    j parse_columnas

almacenar_columnas:
    la t0, filas
    sw t1, 0(t0)
    la t0, columnas
    sw t2, 0(t0)

    # Imprimir los valores de filas y columnas
    la a0, filas_msg
    li a7, 4
    ecall
    mv a0, t1
    li a7, 1
    ecall

    la a0, newline
    li a7, 4
    ecall

    la a0, columnas_msg
    li a7, 4
    ecall
    mv a0, t2
    li a7, 1
    ecall

    la a0, newline
    li a7, 4
    ecall

    j cargar_paredes

# Procedimiento para cargar paredes en la matriz
cargar_paredes:
    addi t0, t0, 1                 # Ignorar espacio tras columnas
parse_paredes:
    lb t3, 0(t0)                   # Leer posici�n de la celda
    beq t3, zero, iniciar_recorrido # Finalizar si se alcanza el valor 00

    # Convertir primer d�gito de la celda a un n�mero
    li t4, 48                       # Cargar el valor ASCII '0' en t4
    sub t3, t3, t4                  # Restar para obtener el valor num�rico
    li t5, 10                       # Cargar 10 en t5 para multiplicaci�n
    mul t3, t3, t5                  # Multiplicar el primer d�gito por 10

    addi t0, t0, 1                  # Avanzar al siguiente byte
    lb t4, 0(t0)                    # Leer el segundo d�gito de la celda
    li t6, 48                       # Cargar 48 en t6 para convertir ASCII a n�mero
    sub t4, t4, t6                  # Convertir ASCII a valor num�rico
    add t3, t3, t4                  # Sumar el segundo d�gito para formar el �ndice de la celda

    # Leer y convertir la letra de la pared
    addi t0, t0, 1                  # Avanzar al siguiente byte para leer la pared
    lb t4, 0(t0)                    # Leer la pared
    li t5, 65                       # Cargar ASCII 'A' en t5
    sub t4, t4, t5                  # Convertir 'A', 'B', 'C', o 'D' a 0, 1, 2, 3

    # Almacenar el valor de la pared en la matriz
    la t5, matriz                   # Cargar direcci�n base de la matriz
    li t6, 4                        # Tama�o de cada celda en bytes
    mul t4, t3, t6                  # Calcular desplazamiento en la matriz usando t4
    add t5, t5, t4                  # Calcular direcci�n de la celda
    sw t4, 0(t5)                    # Guardar el valor de la pared en la celda

    addi t0, t0, 2                  # Avanzar dos posiciones en el buffer
    j parse_paredes                 # Repetir el proceso para la siguiente pared o celda

# Abrir o crear el archivo de salida
abrir_salida:
    la a0, salida_path           # Ruta del archivo de salida
    li a1, 1                     # Modo de escritura
    li a2, 420                   # Permisos del archivo
    li a7, 1024                  # Syscall para abrir/crear archivo
    ecall
    mv s2, a0                    # Guardar descriptor del archivo

    # Verificar si el archivo se abri� correctamente
    bltz s2, error_escritura     # Si el descriptor es negativo, mostrar error y finalizar

    j iniciar_recorrido          # Continuar con el recorrido una vez abierto el archivo

# Iniciar recorrido
iniciar_recorrido:
    li t3, 6
    li t6, 0
    li t0, 0

    la a0, recorrido_msg
    li a7, 4
    ecall
    
    j guardar_recorrido
    
# Guardar cada paso en el recorrido y escribir en el archivo de salida
guardar_recorrido:
    la t5, recorrido
    add t5, t5, t0
    sw t3, 0(t5)
    addi t0, t0, 4

    # Convertir el valor de t3 a texto para el archivo de salida
    la a0, buffer               # Direcci�n del buffer
    li t1, 48                   # ASCII '0'
    li t4, 10                   # Usar t4 para el valor 10

    # Divisi�n manual para obtener decenas y unidades
    div t6, t3, t4              # Obtener decena en t6
    mul a2, t6, t4              # Multiplicar decena por 10 para calcular el resto
    sub a2, t3, a2              # Resto, que es la unidad

    # Convertir decenas y unidades a ASCII
    add t6, t6, t1              # Convertir decena a ASCII
    add a2, a2, t1              # Convertir unidad a ASCII

    # Guardar decena y unidad en el buffer
    sb t6, 0(a0)                # Guardar decena en buffer
    sb a2, 1(a0)                # Guardar unidad en buffer

    # Usar t6 para espacio ASCII
    li t6, 32                   # Espacio en ASCII
    sb t6, 2(a0)                # Espacio despu�s del n�mero
    sb zero, 3(a0)              # Terminador nulo

    # Escribir el paso en el archivo
    la a0, buffer               # Direcci�n del buffer
    mv a1, s2                   # Descriptor del archivo
    li a2, 3                    # Longitud de 3 caracteres ("XX ")
    li a7, 64                   # Syscall para escribir en archivo
    ecall

    # Verificar errores en la escritura
    bltz a0, error_escritura     # Manejar error de escritura si ocurre

    j mover_celda                # Proceder al siguiente movimiento 

# Manejo de error de escritura
error_escritura:
    la a0, errorlectura          # Mensaje de error
    li a7, 4                     # Imprimir mensaje de error en pantalla
    ecall
    j finalizar                  # Terminar el programa si hay un error


mover_celda:
    la a0, newline
    li a7, 4
    ecall

    la t5, matriz
    li t4, 4
    mul t4, t3, t4
    add t5, t5, t4
    lw t6, 0(t5)

    la a0, valor_elemento_msg
    li a7, 4
    ecall
    mv a0, t6
    li a7, 1
    ecall

    li t4, 0
    beq t6, t4, mover_derecha

    li t4, 1
    beq t6, t4, mover_arriba

    li t4, 2
    beq t6, t4, mover_izquierda

    li t4, 3
    beq t6, t4, mover_abajo

# Movimiento hacia la derecha
mover_derecha:
    addi t3, t3, 1
    j verificar_salida

mover_arriba:
    sub t3, t3, t2
    j verificar_salida

mover_izquierda:
    addi t3, t3, -1
    j verificar_salida

mover_abajo:
    add t3, t3, t2
    j verificar_salida

verificar_salida:
    la a0, newline
    li a7, 4
    ecall

    li t4, 20
    beq t3, t4, exito

    li t4, 6
    beq t3, t4, fin_recorrido
    j guardar_recorrido

# Mensaje de �xito en archivo de salida
exito:
    la a0, exito_msg
    mv a1, s2
    li a2, 16                       # Longitud del mensaje
    li a7, 64
    ecall
    j cerrar_salida

# Mensaje de inaccesibilidad en archivo de salida
fin_recorrido:
    la a0, inaccesible_msg
    mv a1, s2
    li a2, 19                       # Longitud del mensaje
    li a7, 64
    ecall
    j cerrar_salida

# Cerrar archivo de salida
cerrar_salida:
    mv a0, s2
    li a7, 57
    ecall
    j finalizar

finalizar:
    li a7, 10
    ecall

imprimeerrorlectura:
    la a0, errorlectura
    li a7, 4
    ecall
    j finalizar 
