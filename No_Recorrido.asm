
.global programa
.data
    buffer: .space 100                     
    ruta: .string "test.txt"               
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


abrirarchivo:
    li a1, 0                               # Modo de lectura
    la a0, ruta                            # Ruta
    li a7, 1024                            # Syscall para abrir archivo
    ecall
    
    # Validar apertura
    blt a0, zero, imprimeerrorlectura
    mv s2, a0                              # Guardar descriptor

    mv a0, s2                         # Imprimir el descriptor para depuración
    li a7, 1
    ecall

ciclolectura:
    mv a0, s2
    mv a1, s0
    mv a2, s1
    li a7, 63                              # Syscall para leer
    ecall
    
    # Validar lectura
    bltz a0, cerrararchivo
    mv t0, a0
    add t1, s0, a0
    sb zero, 0(t1)                         # Añadir terminador nulo al final
    
    # Imprimir contenido completo del buffer después de la lectura
    la a0, buffer           # Cargar la dirección del buffer
    li a7, 4                # Syscall para imprimir cadena
    ecall
    
    beq t0, s1, ciclolectura               # Repetir si se alcanzó el límite

cerrararchivo:
    mv a0, s2                               # Descriptor del archivo
    li a7, 57                               # Syscall para cerrar archivo
    ecall

    # Leer filas y columnas
    la t0, buffer                          # Apuntar al buffer
    li t1, 0                               # Resetear filas
    li t2, 0                               # Resetear columnas
    li t5, 10                              # Valor 10 en t5 para multiplicación
    
# Leer el número de filas
parse_filas:
    lb t3, 0(t0)                           # Leer un byte
    li t4, 32                              # ASCII para espacio
    beq t3, t4, salto_a_columnas           # Saltar si es espacio (debe pasar a columnas)

    li t4, 48                              # ASCII '0'
    li t6, 57                              # ASCII '9'
    blt t3, t4, salto_a_columnas           # Saltar si t3 < '0'
    bgt t3, t6, salto_a_columnas           # Saltar si t3 > '9'
    sub t3, t3, t4                         # Convertir a valor numérico
    mul t1, t1, t5                         # Multiplicación por 10 usando t5
    add t1, t1, t3                         # Añadir dígito

    addi t0, t0, 1                         # Avanzar al siguiente byte
    j parse_filas

# Salto específico para ignorar el espacio antes de leer columnas
salto_a_columnas:
    addi t0, t0, 1                         # Avanzar al siguiente byte para ignorar espacio
    j parse_columnas

# Leer el número de columnas
parse_columnas:
    lb t3, 0(t0)                           # Leer byte para columnas
    li t4, 32                              # ASCII para espacio
    beq t3, t4, almacenar_columnas         # Saltar si es otro espacio

    li t4, 48
    li t6, 57                              # ASCII '9'
    blt t3, t4, almacenar_columnas         # Saltar si t3 < '0'
    bgt t3, t6, almacenar_columnas         # Saltar si t3 > '9'
    sub t3, t3, t4                         # Convertir ASCII a valor numérico
    mul t2, t2, t5                         # Multiplicar t2 por 10 usando t5
    add t2, t2, t3                         # Añadir dígito

    addi t0, t0, 1
    j parse_columnas

# Almacenar y imprimir filas y columnas finales
almacenar_columnas:
    # Guardar filas y columnas en memoria
    la t0, filas
    sw t1, 0(t0)                        # Guardar el valor de filas

    la t0, columnas
    sw t2, 0(t0)                        # Guardar el valor de columnas
    

# Imprimir solo los valores finales de filas y columnas
imprimir_filas:
    la a0, filas_msg        # Imprimir "Filas: "
    li a7, 4
    ecall

    mv a0, t1               # Imprimir valor de `filas` en t1
    li a7, 1
    ecall

    la a0, newline          # Imprimir nueva línea
    li a7, 4
    ecall

imprimir_columnas:
    la a0, columnas_msg     # Imprimir "Columnas: "
    li a7, 4
    ecall

    mv a0, t2               # Imprimir valor de `columnas` en t2
    li a7, 1
    ecall

    la a0, newline          # Imprimir nueva línea
    li a7, 4
    ecall

# Crear y llenar la matriz lógica
crear_matriz:
    mul t3, t1, t2                         # Calcular tamaño de la matriz (filas * columnas)
    la t4, matriz                          # Apuntar al inicio de la matriz
    li t5, 0                               # Valor para inicializar (0)
    li t6, 0                               # Índice de la matriz

llenar_matriz:
    bge t6, t3, imprimir_matriz            # Terminar si índice es mayor o igual a tamaño
    sw t5, 0(t4)                           # Inicializar con 0
    addi t4, t4, 4                         # Siguiente posición en matriz
    addi t6, t6, 1                         # Incrementar índice
    j llenar_matriz

imprimir_matriz:
    la t4, matriz                          # Apuntar al inicio de la matriz
    li t6, 0                               # Contador de elementos impresos
    mul t3, t1, t2                         # Total de elementos en la matriz (para comparación)

imprimir_fila:
    la a0, valor_posicion_msg
    li a7, 4
    ecall
    mv a0, t6
    li a7, 1
    ecall

    la a0, valor_elemento_msg
    li a7, 4
    ecall

    lw a0, 0(t4)
    li a7, 1
    ecall

    addi t6, t6, 1
    addi t4, t4, 4
    rem a1, t6, t2
    beq a1, zero, nueva_linea
    blt t6, t3, imprimir_fila
    j iniciar_recorrido                     # Inicia el recorrido después de imprimir

# Inicializar posición de entrada
iniciar_recorrido:
    li t3, 6                     # Posición inicial de la celda de entrada (celda 6)
    li t6, 0                     # Pared A como punto de entrada (izquierda)
    li t0, 0                     # Índice para el recorrido

    la a0, recorrido_msg         # Mensaje de inicio
    li a7, 4
    ecall
    j guardar_recorrido

guardar_recorrido:
    la t5, recorrido
    add t5, t5, t0
    sw t3, 0(t5)
    addi t0, t0, 4

    la a0, valor_posicion_msg    # Imprimir posición guardada
    li a7, 4
    ecall
    mv a0, t3
    li a7, 1
    ecall

    j mover_celda

mover_celda:
    la a0, newline               # Depuración de entrada a mover_celda
    li a7, 4
    ecall

    la t5, matriz
    li t4, 4
    mul t4, t3, t4
    add t5, t5, t4
    lw t6, 0(t5)

    la a0, valor_elemento_msg    # Imprimir valor de pared actual
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

nueva_linea:
    la a0, newline
    li a7, 4
    ecall
    blt t6, t3, imprimir_fila

finalizar:
    li a7, 10
    ecall

imprimeerrorlectura:
    la a0, errorlectura
    li a7, 4
    ecall
    j finalizar
