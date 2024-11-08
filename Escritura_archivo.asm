# Abrir o crear el archivo de salida
abrir_salida:
    la a0, salida_path                # Ruta del archivo de salida
    li a1, 1                          # Modo de escritura
    li a2, 420                        # Permisos de archivo (644 en octal es 420 decimal)
    li a7, 1024                       # Syscall para abrir o crear archivo
    ecall
    mv s2, a0                         # Guardar descriptor del archivo de salida

    # Verificar si el archivo se abrió correctamente
    bltz s2, error_creacion           # Si el descriptor es negativo, mostrar error

    # Confirmación de apertura de archivo para depuración
    la a0, recorrido_msg              # Mensaje "Recorrido: "
    mv a1, s2                         # Descriptor de archivo
    li a2, 13                         # Longitud del mensaje
    li a7, 64                         # Syscall para escribir en archivo
    ecall
    j loop_escribir_recorrido         # Proceder a escribir el recorrido

error_creacion:
    la a0, errorlectura               # Mensaje de error si falla la creación
    li a7, 4
    ecall
    j finalizar

# Bucle para escribir cada posición del recorrido en el archivo de salida
loop_escribir_recorrido:
    la t0, recorrido                  # Dirección del recorrido
    li t1, 0                          # Índice para el recorrido
    li t2, 50                         # Máximo número de pasos en el recorrido

escribir_paso:
    bge t1, t2, verificar_estado      # Salir del bucle si se completa el recorrido
    add t3, t0, t1                    # Calcular posición actual en el recorrido
    lw a0, 0(t3)                      # Cargar el valor del paso en a0
    mv a1, s2                         # Descriptor de archivo
    li a2, 4                          # Longitud de cada paso (asumiendo 4 bytes por paso)
    li a7, 64                         # Syscall para escribir en archivo
    ecall
    addi t1, t1, 4                    # Avanzar al siguiente paso
    j escribir_paso

# Verificar el estado final (si es exitoso o inaccesible)
verificar_estado:
    li t4, 20                    # Valor 20 como celda de salida
    beq t3, t4, salida_exitosa   # Si se alcanza la celda 20, ir a salida_exitosa
    j salida_inaccesible         # De lo contrario, salida inaccesible

# Mensaje de éxito
salida_exitosa:
    la a0, exito_msg                  # Mensaje "Salida exitosa"
    mv a1, s2                         # Descriptor de archivo
    li a2, 16                         # Longitud del mensaje
    li a7, 64                         # Syscall para escribir en archivo
    ecall
    j cerrar_archivo                  # Terminar

# Mensaje de inaccesibilidad
salida_inaccesible:
    la a0, inaccesible_msg            # Mensaje "Salida inaccesible"
    mv a1, s2                         # Descriptor de archivo
    li a2, 19                         # Longitud del mensaje
    li a7, 64                         # Syscall para escribir en archivo
    ecall
    j cerrar_archivo

# Cerrar el archivo de salida
cerrar_archivo:
    mv a0, s2                         # Descriptor del archivo de salida
    li a7, 57                         # Syscall para cerrar archivo
    ecall
    j finalizar
    