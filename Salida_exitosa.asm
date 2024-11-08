#Recorrido Con filas y columnas, pero con salida

.global programa
.data
    buffer: .space 100
    ruta: .string "test2.txt"
    salida_path: .string "Salida_Laberinto.txt"  
    errorlectura: .string "No se ha podido abrir el archivo correctamente\n"
    filas_msg: .string "\nFilas: "
    columnas_msg: .string "Columnas: "
    valor_posicion_msg: .string "\nPosición: "
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
    # Iniciar buffer y límite de bytes
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
    
# Leer número de filas
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
    lb t3, 0(t0)                   # Leer posición de la celda
    beq t3, zero, iniciar_recorrido # Finalizar si se alcanza el valor 00

    # Convertir primer dígito de la celda a un número
    li t4, 48                       # Cargar el valor ASCII '0' en t4
    sub t3, t3, t4                  # Restar para obtener el valor numérico
    li t5, 10                       # Cargar 10 en t5 para multiplicación
    mul t3, t3, t5                  # Multiplicar el primer dígito por 10

    addi t0, t0, 1                  # Avanzar al siguiente byte
    lb t4, 0(t0)                    # Leer el segundo dígito de la celda
    li t6, 48                       # Cargar 48 en t6 para convertir ASCII a número
    sub t4, t4, t6                  # Convertir ASCII a valor numérico
    add t3, t3, t4                  # Sumar el segundo dígito para formar el índice de la celda

    # Leer y convertir la letra de la pared
    addi t0, t0, 1                  # Avanzar al siguiente byte para leer la pared
    lb t4, 0(t0)                    # Leer la pared
    li t5, 65                       # Cargar ASCII 'A' en t5
    sub t4, t4, t5                  # Convertir 'A', 'B', 'C', o 'D' a 0, 1, 2, 3

    # Almacenar el valor de la pared en la matriz
    la t5, matriz                   # Cargar dirección base de la matriz
    li t6, 4                        # Tamaño de cada celda en bytes
    mul t4, t3, t6                  # Calcular desplazamiento en la matriz usando t4
    add t5, t5, t4                  # Calcular dirección de la celda
    sw t4, 0(t5)                    # Guardar el valor de la pared en la celda

    addi t0, t0, 2                  # Avanzar dos posiciones en el buffer
    j parse_paredes                 # Repetir el proceso para la siguiente pared o celda

# Iniciar recorrido
iniciar_recorrido:
    li t3, 6
    li t6, 0
    li t0, 0

    la a0, recorrido_msg
    li a7, 4
    ecall
    
    j guardar_recorrido
    
guardar_recorrido:
    la t5, recorrido
    add t5, t5, t0
    sw t3, 0(t5)
    addi t0, t0, 4

    la a0, valor_posicion_msg
    li a7, 4
    ecall
    mv a0, t3
    li a7, 1
    ecall

    j mover_celda

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

exito:
    la a0, exito_msg
    li a7, 4
    ecall
    j finalizar

fin_recorrido:
    la a0, inaccesible_msg
    li a7, 4
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
