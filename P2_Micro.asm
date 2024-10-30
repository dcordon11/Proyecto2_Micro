#Proyecto 2 Microprogramación - Diego Cordón - 1094021
   
    .data
filename: .asciz "test.txt"  # Nombre del archivo de entrada
buffer:     .space 100                   # Buffer para almacenar datos leídos
output_file: .asciz "Salida_Laberinto.txt" # Nombre del archivo de salida

# Mensaje de éxito
success_msg: .asciz "Salida exitosa\n"
failure_msg: .asciz "Salida inaccesible\n"

# Variables para almacenar información del laberinto
rows:       .word 0                      # Filas del laberinto
cols:       .word 0                      # Columnas del laberinto
entry_cell: .word 0                      # Celda de entrada
entry_wall: .word 0                      # Pared de entrada
exit_cell:  .word 0                      # Celda de salida
exit_wall:  .word 0                      # Pared de salida

# Representación de celdas y paredes abiertas (en una implementación completa se podrían usar arrays)
cell_walls: .space 400                   # Espacio para almacenar 100 celdas y sus paredes

    .text
    .globl _start
_start:
	# Abrir el archivo de entrada
li a7, 56                            # Syscall para abrir archivo
la a0, filename                      # Nombre del archivo de entrada
li a1, 0                             # Modo de lectura (O_RDONLY)
ecall
bltz a0, error                       # Si a0 es negativo, hubo un error al abrir el archivo
mv s0, a0                            # Guardar el descriptor de archivo en s0



error:
# Puedes agregar código aquí para manejar el error, o simplemente finalizar el programa.
li a7, 93
li a0, 1                             # Código de salida de error
ecall
    
            
    # Leer el contenido del archivo en el buffer
li a7, 63                            # Syscall para leer
mv a0, s0                            # Descriptor de archivo
la a1, buffer                        # Buffer donde almacenar los datos
li a2, 100                           # Tamaño de datos a leer
ecall

# Confirmación de lectura de archivo
li a7, 64                # Syscall para escribir en la consola
li a0, 1                 # Descriptor de archivo para stdout (consola)
la a1, success_msg       # Dirección del mensaje a imprimir
li a2, 15                # Longitud del mensaje
ecall


    # Extraer filas y columnas desde el buffer
    la t0, buffer                        # Apuntar al inicio del buffer
    li t1, 0                             # Inicializar filas en 0
    li t2, 0                             # Inicializar columnas en 0

    # Convertir primer número (filas)
parse_rows:
    lb t3, 0(t0)                         # Leer un byte del buffer
    
    # Usamos un registro temporal para el valor ASCII de espacio (0x20)
    li t4, 32                            # 0x20 en decimal
    beq t3, t4, parse_columns            # Si es espacio, pasar a columnas
    
    # Convertimos de ASCII a entero restando 48 (ASCII '0' es 0x30 o 48)
    li t4, 48                            # 0x30 en decimal
    sub t3, t3, t4                       # Convertir de ASCII a entero
    
    # Multiplicación por 10 mediante sumas
    slli t1, t1, 3                       # t1 * 8
    add t1, t1, t1                       # t1 * 2 -> ahora es t1 * 10
    add t1, t1, t3                       # Agregar dígito actual

    addi t0, t0, 1                       # Avanzar al siguiente byte
    j parse_rows                         # Repetir para siguiente dígito

parse_columns:
    addi t0, t0, 1                       # Avanzar para leer columnas
    lb t3, 0(t0)                         # Leer un byte del buffer
    
    # Usamos el mismo valor de espacio (32)
    li t4, 32
    beq t3, t4, parse_entry_cell         # Si hay un espacio, pasar a entrada
    
    # Convertimos de ASCII a entero
    li t4, 48                            # 0x30 en decimal
    sub t3, t3, t4                       # Convertir de ASCII a entero

    # Multiplicación por 10 mediante sumas
    slli t2, t2, 3                       # t2 * 8
    add t2, t2, t2                       # t2 * 2 -> ahora es t2 * 10
    add t2, t2, t3                       # Agregar dígito actual

    addi t0, t0, 1                       # Avanzar al siguiente byte
    j parse_columns                      # Repetir para siguiente dígito

# Leer número de celda de entrada
parse_entry_cell:
    li t4, 0                             # Inicializar celda de entrada en 0

parse_entry_num:
    lb t3, 0(t0)                         # Leer un byte del buffer
    
    # Usamos un registro temporal para verificar si es 'A' o superior (0x41)
    li t5, 65                            # 0x41 en decimal
    bge t3, t5, parse_entry_wall         # Si es 'A' o siguiente, leer pared

    # Convertimos de ASCII a entero
    li t5, 48                            # 0x30 en decimal
    sub t3, t3, t5                       # Convertir de ASCII a entero

    # Multiplicación por 10 mediante sumas
    slli t4, t4, 3                       # t4 * 8
    add t4, t4, t4                       # t4 * 2 -> ahora es t4 * 10
    add t4, t4, t3                       # Agregar dígito actual

    addi t0, t0, 1                       # Avanzar al siguiente byte
    j parse_entry_num                    # Repetir para siguiente dígito

# Leer pared de celda de entrada
parse_entry_wall:
    lb t5, 0(t0)                         # Leer pared (A, B, C, D)
    addi t0, t0, 2                       # Avanzar dos posiciones (siguiente celda)

# Leer número de celda de salida
parse_exit_cell:
    li t6, 0                             # Inicializar celda de salida en 0

parse_exit_num:
    lb t3, 0(t0)                         # Leer un byte del buffer
    
    # Usamos el mismo valor de 'A' para verificar si es pared
    li s1, 65                            # 0x41 en decimal
    bge t3, s1, parse_exit_wall          # Si es 'A' o siguiente, leer pared

    # Convertimos de ASCII a entero
    li s1, 48                            # 0x30 en decimal
    sub t3, t3, s1                       # Convertir de ASCII a entero

    # Multiplicación por 10 mediante sumas
    slli t6, t6, 3                       # t6 * 8
    add t6, t6, t6                       # t6 * 2 -> ahora es t6 * 10
    add t6, t6, t3                       # Agregar dígito actual

    addi t0, t0, 1                       # Avanzar al siguiente byte
    j parse_exit_num                     # Repetir para siguiente dígito


# Leer pared de celda de salida
parse_exit_wall:
    lb s1, 0(t0)                         # Leer pared de salida (A, B, C, D)


# Guardar filas, columnas, entrada y salida
store_labyrinth_data:
    la t0, rows                          # Cargar dirección de filas en t0
    sw t1, 0(t0)                         # Guardar filas

    la t0, cols                          # Cargar dirección de columnas en t0
    sw t2, 0(t0)                         # Guardar columnas

    la t0, entry_cell                    # Cargar dirección de celda de entrada en t0
    sw t4, 0(t0)                         # Guardar celda de entrada

    la t0, entry_wall                    # Cargar dirección de pared de entrada en t0
    sw t5, 0(t0)                         # Guardar pared de entrada

    la t0, exit_cell                     # Cargar dirección de celda de salida en t0
    sw t6, 0(t0)                         # Guardar celda de salida

    la t0, exit_wall                     # Cargar dirección de pared de salida en t0
    sw s1, 0(t0)                         # Guardar pared de salida (usamos s1 en lugar de t7)

# Leer celdas individuales y sus paredes
parse_cells:
    li s3, 0                             # Índice en `cell_walls` para cada celda

parse_cell:
    li s2, 0                             # Inicializar número de celda a 0

#Corrección
parse_cell_num:
    lb t3, 0(t0)                         # Leer un byte del buffer
    
    # Verificar si el byte leído es '0' (fin de celdas) o es una letra (A o superior)
    li t4, 48                            # Cargar 0x30 en decimal (ASCII de '0')
    beq t3, t4, end_parsing              # Si es '0', fin de celdas
    
    li t4, 65                            # Cargar 0x41 en decimal (ASCII de 'A')
    bge t3, t4, parse_cell_walls         # Si es una letra, es pared

    # Convertir de ASCII a entero
    li t4, 48                            # 0x30 en decimal
    sub t3, t3, t4                       # Convertir de ASCII a entero

    # Multiplicación por 10 usando desplazamientos y sumas
    slli s2, s2, 3                       # s2 * 8 (equivalente a multiplicación por 10)
    add s2, s2, s2                       # s2 * 2, ahora s2 es s2 * 10
    add s2, s2, t3                       # Agregar dígito actual

    addi t0, t0, 1                       # Avanzar al siguiente byte
    j parse_cell_num                     # Repetir para número completo

# Leer y almacenar paredes abiertas de la celda
parse_cell_walls:
    la t4, cell_walls                    # Cargar la dirección base de `cell_walls` en t4
    add t4, t4, s3                       # Añadir el índice en `s3` al offset de `cell_walls`
    sw s2, 0(t4)                         # Almacenar número de celda en `cell_walls`
    addi s3, s3, 4                       # Avanzar en espacio para paredes

parse_wall:
    lb t3, 0(t0)                         # Leer una pared (letra A, B, C, D)
    
    # Convertir 0x41 a decimal y usarlo en la comparación
    li t5, 65                            # 0x41 en decimal
    blt t3, t5, next_cell                # Si es un número, pasar a la siguiente celda
    
    # Convertir de letra a número (A=0, B=1, etc.)
    sub t3, t3, t5                       # t3 = t3 - 65 (A=0, B=1, etc.)
    
    # Almacenar pared abierta en cell_walls usando la dirección base t4 y offset s3
    add t4, t4, s3                       # Actualizar dirección de almacenamiento
    sw t3, 0(t4)                         # Guardar pared en `cell_walls`
    
    addi s3, s3, 4                       # Avanzar en el espacio de `cell_walls`
    addi t0, t0, 1                       # Avanzar al siguiente byte en el buffer
    j parse_wall                         # Repetir para más paredes de la celda

next_cell:
    j parse_cell                         # Volver para leer la siguiente celda

end_parsing:
    # A partir de aquí, cada celda y sus paredes están almacenadas en `cell_walls`

# Mensaje antes de comenzar la navegación
li a7, 64                # Syscall para escribir en la consola
li a0, 1                 # Descriptor de archivo para stdout (consola)
la a1, success_msg       # Dirección del mensaje a imprimir
li a2, 15                # Longitud del mensaje
ecall


navigate:
    # Revisar si estamos en la celda de salida
    lw t3, exit_cell
    beq t4, t3, found_exit

    # Aplicar la regla de la mano derecha
    addi s4, t5, 1                       # Intentar girar a la derecha
    andi s4, s4, 3                       # Modulo 4 para mantener dirección en rango
    jal check_wall                       # Comprobar pared derecha
    beqz a0, move_forward                # Si está abierta, moverse a la derecha

    # Si no es posible, intenta avanzar recto
    jal check_wall                       # Comprobar pared en dirección actual
    beqz a0, move_forward                # Si está abierta, avanzar recto

    # Si no es posible, intentar girar a la izquierda
    addi s4, t5, -1
    andi s4, s4, 3
    jal check_wall                       # Comprobar pared izquierda
    beqz a0, move_forward                # Si está abierta, moverse a la izquierda

    # Si no es posible, retroceder
    addi t5, t5, 2                       # Cambiar dirección a opuesta
    andi t5, t5, 3                       # Mantener dirección en rango

move_forward:
    # Actualizar posición según la dirección
    jal update_position                  # Cambiar celda en la dirección de t5
    addi t5, s4, 0                       # Actualizar dirección a la última movida
    j navigate                           # Continuar navegación

# Comprobar pared de la celda en la dirección especificada en s4
check_wall:
    li a0, 1                             # Valor predeterminado (cerrada)
    
    # Multiplicar t4 por 16 usando un desplazamiento de 4 bits
    slli s5, t4, 4                       # Multiplicar t4 por 16 y guardar en s5
    
    # Cargar la dirección base de cell_walls en t6 y sumar s5
    la t6, cell_walls                    # Cargar la dirección base de cell_walls en t6
    add s5, s5, t6                       # Base de la celda en cell_walls
    
    # Sumar s4 para direccionar pared específica
    add s5, s5, s4                       # Ajustar dirección para pared específica
    lw a0, 0(s5)                         # Leer estado de la pared (0 abierta, 1 cerrada)
    ret


# Actualizar posición en la dirección t5
update_position:
    la t6, rows                          # Cargar dirección de rows en t6
    lw s5, 0(t6)                         # Cargar cantidad de filas en s5

    la t6, cols                          # Cargar dirección de cols en t6
    lw s6, 0(t6)                         # Cargar cantidad de columnas en s6

# Comparaciones para las direcciones
    li s7, 0                             # Cargar 0 en s7
    beq t5, s7, move_left                # Si es 0, mover a la izquierda
    
    li s7, 1                             # Cargar 1 en s7
    beq t5, s7, move_up                  # Si es 1, mover hacia arriba
    
    li s7, 2                             # Cargar 2 en s7
    beq t5, s7, move_right               # Si es 2, mover a la derecha
    
    li s7, 3                             # Cargar 3 en s7
    beq t5, s7, move_down                # Si es 3, mover hacia abajo
    ret


move_left:
    addi t4, t4, -1                      # Disminuir celda en 1
    ret

move_up:
    sub t4, t4, s6                       # Disminuir celda en una fila (s6 almacena columnas)
    ret

move_right:
    addi t4, t4, 1                       # Aumentar celda en 1
    ret

move_down:
    add t4, t4, s6                       # Aumentar celda en una fila (s6 almacena columnas)
    ret


found_exit:
    # Abrir archivo de salida para escribir
    li a7, 64
    la a0, output_file
    li a1, 1
    li a2, 0x180
    ecall
    mv s0, a0
    
    

    # Escribir mensaje de éxito
    la a1, success_msg                   # Cargar la dirección del mensaje de éxito
    li a2, 15                            # Longitud del mensaje (ajusta según la longitud real del mensaje)
    ecall

# Mensaje de salida exitosa o inaccesible
found_exit:
    li a7, 64                # Syscall para escribir en la consola
    li a0, 1                 # Descriptor de archivo para stdout (consola)
    la a1, success_msg       # Dirección del mensaje a imprimir
    li a2, 15                # Longitud del mensaje
    ecall


    # Cerrar el archivo
    li a7, 57                            # Syscall para cerrar archivo
    mv a0, s0                            # Descriptor de archivo
    ecall

    # Finalizar el programa
    li a7, 93                            # Syscall para salir del programa
    li a0, 0                             # Código de salida
    ecall
    

    
