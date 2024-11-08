#.global abrir_archivo_prueba:
.data
    salida_path: .string "salida_prueba.txt" 

.text
abrir_archivo_prueba:
    la a0, salida_path          # Ruta del archivo
    li a1, 1                    # Modo de escritura
    li a2, 420                  # Permisos (644 en octal es 420 decimal)
    li a7, 1024                 # Syscall para abrir o crear archivo
    ecall
    mv s2, a0                   # Guardar descriptor de archivo

    bltz s2, error_creacion     # Si hay error, salta a la etiqueta de error

    # Código para cerrar el archivo inmediatamente después de abrir
    mv a0, s2
    li a7, 57                   # Syscall para cerrar archivo
    ecall
    j finalizar

error_creacion:
    la a0, errorlectura         # Mostrar mensaje de error
    li a7, 4
    ecall
    j finalizar

