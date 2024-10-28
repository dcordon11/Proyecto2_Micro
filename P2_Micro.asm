#Proyecto 2 Microprogramación - Diego Cordón - 1094021
   
    .data
filename:   .asciiz "test.txt"           # Nombre del archivo de entrada
buffer:     .space 100                   # Buffer para almacenar datos leídos
output_file: .asciiz "Salida_Laberinto.txt" # Nombre del archivo de salida

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
    mv s0, a0                            # Guardar el descriptor de archivo en s0

    # Leer el contenido del archivo en el buffer
    li a7, 63                            # Syscall para leer
    mv a0, s0                            # Descriptor de archivo
    la a1, buffer                        # Buffer donde almacenar los datos
    li a2, 100                           # Tamaño de datos a leer
    ecall

    # Extraer filas y columnas desde el buffer
    la t0, buffer                        # Apuntar al inicio del buffer
    li t1, 0                             # Inicializar filas en 0
    li t2, 0                             # Inicializar columnas en 0

    # Convertir primer número (filas)
parse_rows:
    lb t3, 0(t0)                         # Leer un byte del buffer
    beq t3, 0x20, parse_columns          # Si es espacio, pasar a columnas
    sub t3, t3, 0x30                     # Convertir de ASCII a entero
    mul t1, t1, 10                       # Multiplicar filas acumuladas por 10
    add t1, t1, t3                       # Agregar dígito actual
    addi t0, t0, 1                       # Avanzar al siguiente byte
    j parse_rows                         # Repetir para siguiente dígito

parse_columns:
    addi t0, t0, 1                       # Avanzar para leer columnas
    lb t3, 0(t0)                         # Leer un byte del buffer
    beq t3, 0x20, parse_entry_cell       # Si hay un espacio, pasar a entrada
    sub t3, t3, 0x30                     # Convertir de ASCII a entero
    mul t2, t2, 10                       # Multiplicar columnas acumuladas por 10
    add t2, t2, t3                       # Agregar dígito actual
    addi t0, t0, 1                       # Avanzar al siguiente byte
    j parse_columns                      # Repetir para siguiente dígito

# Leer número de celda de entrada
parse_entry_cell:
    li t4, 0                             # Inicializar celda de entrada en 0

parse_entry_num:
    lb t3, 0(t0)                         # Leer un byte del buffer
    beq t3, 0x41, parse_entry_wall       # Si es 'A' o siguiente, leer pared
    sub t3, t3, 0x30                     # Convertir de ASCII a entero
    mul t4, t4, 10                       # Multiplicar celda acumulada por 10
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
    beq t3, 0x41, parse_exit_wall        # Si es 'A' o siguiente, leer pared
    sub t3, t3, 0x30                     # Convertir de ASCII a entero
    mul t6, t6, 10                       # Multiplicar celda acumulada por 10
    add t6, t6, t3                       # Agregar dígito actual
    addi t0, t0, 1                       # Avanzar al siguiente byte
    j parse_exit_num                     # Repetir para siguiente dígito

# Leer pared de celda de salida
parse_exit_wall:
    lb t7, 0(t0)                         # Leer pared de salida (A, B, C, D)

# Guardar filas, columnas, entrada y salida
store_labyrinth_data:
    sw t1, rows                          # Guardar filas
    sw t2, cols                          # Guardar columnas
    sw t4, entry_cell                    # Guardar celda de entrada
    sw t5, entry_wall                    # Guardar pared de entrada
    sw t6, exit_cell                     # Guardar celda de salida
    sw t7, exit_wall                     # Guardar pared de salida

# Leer celdas individuales y sus paredes
parse_cells:
    li t9, 0                             # Índice en `cell_walls` para cada celda

parse_cell:
    li t8, 0                             # Inicializar número de celda a 0

parse_cell_num:
    lb t3, 0(t0)                         # Leer un byte del buffer
    beq t3, 0x30, end_parsing            # Si es '0', fin de celdas
    bge t3, 0x41, parse_cell_walls       # Si es una letra, es pared
    sub t3, t3, 0x30                     # Convertir de ASCII a entero
    mul t8, t8, 10                       # Multiplicar celda acumulada por 10
    add t8, t8, t3                       # Agregar dígito actual
    addi t0, t0, 1                       # Avanzar al siguiente byte
    j parse_cell_num                     # Repetir para número completo

# Leer y almacenar paredes abiertas de la celda
parse_cell_walls:
    sw t8, cell_walls(t9)                # Almacenar número de celda en `cell_walls`
    addi t9, t9, 4                       # Avanzar en espacio para paredes

parse_wall:
    lb t3, 0(t0)                         # Leer una pared (letra A, B, C, D)
    blt t3, 0x41, next_cell              # Si es un número, pasar a la siguiente celda
    sub t3, t3, 0x41                     # Convertir de letra a número (A=0, B=1, etc.)
    sw t3, cell_walls(t9)                # Almacenar pared abierta
    addi t9, t9, 4                       # Avanzar al siguiente espacio
    addi t0, t0, 1                       # Avanzar al siguiente byte en el buffer
    j parse_wall                         # Repetir para más paredes de la celda

next_cell:
    j parse_cell                         # Volver para leer la siguiente celda

end_parsing:
    # A partir de aquí, cada celda y sus paredes están almacenadas en `cell_walls`

navigate:
    # Revisar si estamos en la celda de salida
    lw t3, exit_cell
    beq t4, t3, found_exit

    # Aplicar la regla de la mano derecha
    addi t7, t5, 1                       # Intentar girar a la derecha
    andi t7, t7, 3                       # Modulo 4 para mantener dirección en rango
    jal check_wall                       # Comprobar pared derecha
    beqz a0, move_forward                # Si está abierta, moverse a la derecha

    # Si no es posible, intenta avanzar recto
    jal check_wall                       # Comprobar pared en dirección actual
    beqz a0, move_forward                # Si está abierta, avanzar recto

    # Si no es posible, intentar girar a la izquierda
    addi t7, t5, -1
    andi t7, t7, 3
    jal check_wall                       # Comprobar pared izquierda
    beqz a0, move_forward                # Si está abierta, moverse a la izquierda

    # Si no es posible, retroceder
    addi t5, t5, 2                       # Cambiar dirección a opuesta
    andi t5, t5, 3                       # Mantener dirección en rango

move_forward:
    # Actualizar posición según la dirección
    jal update_position                  # Cambiar celda en la dirección de t5
    addi t5, t7, 0                       # Actualizar dirección a la última movida
    j navigate                           # Continuar navegación

# Comprobar pared de la celda en la dirección especificada en t7
check_wall:
    li a0, 1                             # Valor predeterminado (cerrada)
    mul t8, t4, 16                       # Dirección en memoria para la celda
    add t8, t8, cell_walls               # Base de la celda en cell_walls
    add t8, t8, t7                       # Direcciona pared específica
    lw a0, 0(t8)                         # Leer estado de la pared (0 abierta, 1 cerrada)
    ret

# Actualizar posición en la dirección t5
update_position:
    lw t8, rows                          # Obtener cantidad de filas
    lw t9, cols                          # Obtener cantidad de columnas
    beq t5, 0, move_left                 # Si es 0, mover a la izquierda
    beq t5, 1, move_up                   # Si es 1, mover hacia arriba
    beq t5, 2, move_right                # Si es 2, mover a la derecha
    beq t5, 3, move_down                 # Si es 3, mover hacia abajo
    ret

move_left:
    addi t4, t4, -1                      # Disminuir celda en 1
    ret

move_up:
    sub t4, t4, t9                       # Disminuir celda en una fila
    ret

move_right:
    addi t4, t4, 1                       # Aumentar celda en 1
    ret

move_down:
    add t4, t4, t9                       # Aumentar celda en una fila
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
    la a1, success_msg
    li a2, 17
    ecall

    # Cerrar el archivo
    li a7, 57                            # Syscall para cerrar archivo
    mv a0, s0                            # Descriptor de archivo
    ecall

    # Finalizar el programa
    li a7, 93                            # Syscall para salir del programa
    li a0, 0                             # Código de salida
    ecall
    

    
