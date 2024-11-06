#Proyecto 2 Microprogramación - Diego Cordón - 1094021

.data
file_name: .string "test.txt"

error_message: .string "Error al abrir el archivo.\n"
message: .string "Syscall test successful.\n"

buffer: .space 100                   # Espacio de buffer para lectura
filas: .word 0                       # Número de filas del laberinto
columnas: .word 0                    # Número de columnas del laberinto
entrada_celda: .word 0               # Número de celda de entrada
entrada_pared: .byte 0               # Pared de entrada
salida_celda: .word 0                # Número de celda de salida
salida_pared: .byte 0                # Pared de salida


  .text
    .globl main
main:
    li a0, 0                    # Modo de lectura (0)
    la a1, file_name            # Cargar la dirección de file_name en a1
    li a7, 1024                 # Código de syscall para abrir archivo
    ecall                       # Llamada al sistema para abrir archivo

    bltz a0, error              # Si falla, ir a la etiqueta error
    mv s0, a0                   # Guardar descriptor del archivo en s0 para futuras operaciones
    
    # Leer datos desde el archivo al buffer
    mv a0, s0                   # Coloca el descriptor de archivo en a0
    la a1, buffer               # Cargar la dirección de buffer en a1
    li a2, 20                   # Tamaño de lectura (ejemplo: 20 bytes)
    li a7, 63                   # Código de syscall para leer
    ecall                       # Llamada al sistema para leer el archivo
    bltz a0, error              # Si falla, ir a la etiqueta error

    # Leer dimensiones (filas y columnas)
    mv a0, s0                   # Descriptor de archivo
    la a1, buffer               # Dirección del buffer
    li a2, 20                   # Leer 20 bytes (por ejemplo)
    li a7, 63                   # syscall de lectura
    ecall

    # Parsear filas y columnas
    la t0, buffer               # Dirección del buffer
    lb t1, 0(t0)                # Cargar primer byte (filas)
    addi t1, t1, -48            # Convertir a número
    la t2, filas                # Cargar la dirección de 'filas'
    sw t1, 0(t2)                # Guardar en 'filas'
    lb t3, 2(t0)                # Cargar segundo número (columnas)
    addi t3, t3, -48            # Convertir a número
    la t4, columnas             # Cargar la dirección de 'columnas'
    sw t3, 0(t4)                # Guardar en 'columnas'

    # Leer celda de entrada
    mv a0, s0
    la a1, buffer
    li a2, 20
    li a7, 63
    ecall
    la t0, buffer
    lb t1, 0(t0)                # Leer número de celda de entrada
    addi t1, t1, -48
    la t2, entrada_celda        # Cargar la dirección de 'entrada_celda'
    sw t1, 0(t2)                # Guardar en 'entrada_celda'
    lb t3, 2(t0)                # Leer pared de entrada
    la t4, entrada_pared        # Cargar la dirección de 'entrada_pared'
    sb t3, 0(t4)                # Guardar en 'entrada_pared'

    # Leer celda de salida
    mv a0, s0
    la a1, buffer
    li a2, 20
    li a7, 63
    ecall
    la t0, buffer
    lb t1, 0(t0)                # Leer número de celda de salida
    addi t1, t1, -48
    la t2, salida_celda         # Cargar la dirección de 'salida_celda'
    sw t1, 0(t2)                # Guardar en 'salida_celda'
    lb t3, 2(t0)                # Leer pared de salida
    la t4, salida_pared         # Cargar la dirección de 'salida_pared'
    sb t3, 0(t4)                # Guardar en 'salida_pared'

    # Leer celdas del laberinto y sus aberturas (ejemplo simple)
leer_celdas:
    mv a0, s0
    la a1, buffer
    li a2, 20
    li a7, 63
    ecall
    la t0, buffer       # Carga la dirección de `buffer` en el registro `t0`
    lb t1, 0(t0)        # Accede al contenido de `buffer` a través de `t0`
    li t1, 48
    beq t0, t1, imprimir_matriz # Si es '0', termina de leer

    # Procesar celda y abrir pared
    # (Lógica para interpretar las celdas y paredes abierta según el formato)

    j leer_celdas               # Leer siguiente celda

imprimir_matriz:
    # Ejemplo de impresión en consola
    li a7, 10                   # Salir del programa
    ecall


finalizar:
    li a7, 10                   # Salir del programa
    ecall
    
error:
    # Mostrar mensaje de error si no se puede abrir el archivo
    la a0, error_message
    li a7, 4                    # Código de syscall para imprimir string
    ecall
    li a7, 10                   # Código de syscall para salir
    ecall
