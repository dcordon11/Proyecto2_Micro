#Proyecto 2 Microprogramaci�n - Diego Cord�n - 1094021

.data
file_name: .string "test.txt"

error_message: .string "Error al abrir el archivo.\n"
message: .string "Syscall test successful.\n"

buffer: .space 100                   # Espacio de buffer para lectura
filas: .word 0                       # N�mero de filas del laberinto
columnas: .word 0                    # N�mero de columnas del laberinto
entrada_celda: .word 0               # N�mero de celda de entrada
entrada_pared: .byte 0               # Pared de entrada
salida_celda: .word 0                # N�mero de celda de salida
salida_pared: .byte 0                # Pared de salida


  .text
    .globl main
main:
    li a0, 0                    # Modo de lectura (0)
    la a1, file_name            # Cargar la direcci�n de file_name en a1
    li a7, 1024                 # C�digo de syscall para abrir archivo
    ecall                       # Llamada al sistema para abrir archivo

    bltz a0, error              # Si falla, ir a la etiqueta error
    mv s0, a0                   # Guardar descriptor del archivo en s0 para futuras operaciones
    
    # Leer datos desde el archivo al buffer
    mv a0, s0                   # Coloca el descriptor de archivo en a0
    la a1, buffer               # Cargar la direcci�n de buffer en a1
    li a2, 20                   # Tama�o de lectura (ejemplo: 20 bytes)
    li a7, 63                   # C�digo de syscall para leer
    ecall                       # Llamada al sistema para leer el archivo
    bltz a0, error              # Si falla, ir a la etiqueta error

    # Leer dimensiones (filas y columnas)
    mv a0, s0                   # Descriptor de archivo
    la a1, buffer               # Direcci�n del buffer
    li a2, 20                   # Leer 20 bytes (por ejemplo)
    li a7, 63                   # syscall de lectura
    ecall

    # Parsear filas y columnas
    la t0, buffer               # Direcci�n del buffer
    lb t1, 0(t0)                # Cargar primer byte (filas)
    addi t1, t1, -48            # Convertir a n�mero
    la t2, filas                # Cargar la direcci�n de 'filas'
    sw t1, 0(t2)                # Guardar en 'filas'
    lb t3, 2(t0)                # Cargar segundo n�mero (columnas)
    addi t3, t3, -48            # Convertir a n�mero
    la t4, columnas             # Cargar la direcci�n de 'columnas'
    sw t3, 0(t4)                # Guardar en 'columnas'

    # Leer celda de entrada
    mv a0, s0
    la a1, buffer
    li a2, 20
    li a7, 63
    ecall
    la t0, buffer
    lb t1, 0(t0)                # Leer n�mero de celda de entrada
    addi t1, t1, -48
    la t2, entrada_celda        # Cargar la direcci�n de 'entrada_celda'
    sw t1, 0(t2)                # Guardar en 'entrada_celda'
    lb t3, 2(t0)                # Leer pared de entrada
    la t4, entrada_pared        # Cargar la direcci�n de 'entrada_pared'
    sb t3, 0(t4)                # Guardar en 'entrada_pared'

    # Leer celda de salida
    mv a0, s0
    la a1, buffer
    li a2, 20
    li a7, 63
    ecall
    la t0, buffer
    lb t1, 0(t0)                # Leer n�mero de celda de salida
    addi t1, t1, -48
    la t2, salida_celda         # Cargar la direcci�n de 'salida_celda'
    sw t1, 0(t2)                # Guardar en 'salida_celda'
    lb t3, 2(t0)                # Leer pared de salida
    la t4, salida_pared         # Cargar la direcci�n de 'salida_pared'
    sb t3, 0(t4)                # Guardar en 'salida_pared'

    # Leer celdas del laberinto y sus aberturas (ejemplo simple)
leer_celdas:
    mv a0, s0
    la a1, buffer
    li a2, 20
    li a7, 63
    ecall
    la t0, buffer       # Carga la direcci�n de `buffer` en el registro `t0`
    lb t1, 0(t0)        # Accede al contenido de `buffer` a trav�s de `t0`
    li t1, 48
    beq t0, t1, imprimir_matriz # Si es '0', termina de leer

    # Procesar celda y abrir pared
    # (L�gica para interpretar las celdas y paredes abierta seg�n el formato)

    j leer_celdas               # Leer siguiente celda

imprimir_matriz:
    # Ejemplo de impresi�n en consola
    li a7, 10                   # Salir del programa
    ecall


finalizar:
    li a7, 10                   # Salir del programa
    ecall
    
error:
    # Mostrar mensaje de error si no se puede abrir el archivo
    la a0, error_message
    li a7, 4                    # C�digo de syscall para imprimir string
    ecall
    li a7, 10                   # C�digo de syscall para salir
    ecall
