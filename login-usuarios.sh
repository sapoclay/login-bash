#!/bin/bash

# Hacer un login en bash que permita al usuario escribir el usuario y la contraseña.
# Los datos de logueo se deben guardar dentro de un archivo llamado loginusuarios.txt
# Si el usuario no existe en el programa, el programa debe dar la posibilidad de crear al usuario.
# En caso de que la contraseña no sea correcta, el programa devolverá un error. Solo debe permitir 3 intentos de login cuando el usuario falla con la contraseña. 
# Estos intentos de login deben mostrarse en pantalla con un mensaje que diga "Te quedan x intentos".
# También daremos la posibilidad de que un usuario pueda eliminar su cuenta de usuario utilizando su nombre de usuario y su contraseña
# Las contraseñas se deben encriptar en el archivo de texto.
# Si no se pasan parámetros desde la terminal, se mostrará un menú para loguearse, crear al usuario o eliminar la cuenta.
# Si el usuario existe, debe aparecer un mensaje que diga "Hola, estás logueado como ... y el nombre de usuario"
# También debe de permitir el script enviar los datos de logueo desde la terminal como parámetros al script, donde se realizarán las comprobaciones descritas.
# Además también debe de crearse una sección de ayuda para mostrar los parámetros que se pueden utilizar desde la terminal

# Archivo para login de usuarios
ARCHIVO_LOGIN="loginusuarios.txt"

# PBKDF2_SALT para ser utilizado como salt para la función PBKDF2
PBKDF2_SALT="entreunosyceros.net"

# Función para encriptar un password
encriptar_password() {
    # Utiliza OpenSSL para encriptar la contraseña:
    #  - Se toma la contraseña proporcionada como argumento ($1).
    #  - Se utiliza el algoritmo AES-256 en modo CBC para encriptar.
    #  - Se aplica el algoritmo de derivación de clave PBKDF2 usando el salt definido.
    #  - El resultado encriptado se codifica en base64 para que sea legible.
    password_encriptado=$(echo "$1" | openssl enc -aes-256-cbc -a -salt -pbkdf2 -pass pass:$PBKDF2_SALT)
    echo "$password_encriptado"  # Devuelve la contraseña encriptada
}

# Función para desencriptar un password
desencriptar_password() {
    # Se añade la opción -d para desencriptar
    password_desencriptado=$(echo "$1" | openssl enc -aes-256-cbc -a -d -salt -pbkdf2 -pass pass:$PBKDF2_SALT)
    echo "$password_desencriptado"
}

# Función para mostrar la cabecera
cabecera() {
    clear
    echo ""
    echo "===================================="
    echo "       Opción | $1                  "
    echo "===================================="
    echo ""
}

# Crear el archivo en el que guardar los usuarios si no existe
if [ ! -f "$ARCHIVO_LOGIN" ]; then
    touch "$ARCHIVO_LOGIN"
fi

# Función para mostrar la ayuda
ayuda() {
    echo "============================================================="
    echo "Uso: $0 [opciones]"
    echo "-------------------------------------------------------------"
    echo "Opciones:"
    echo ""
    echo "  -l, --login      Iniciar sesión con el usuario y contraseña" 
    echo "  Uso: $0 -u NOMBRE_USUARIO PASSWORD"
    echo ""
    echo "  -c, --crear      Crear un nuevo usuario" 
    echo "  Uso: $0 -c NOMBRE_USUARIO"
    echo ""
    echo "  -d, --eliminar   Elimina la cuenta del usuario" 
    echo "  Uso: $0 -c NOMBRE_USUARIO"
    echo ""
    echo "  -h, --ayuda      Mostrar esta ayuda"
    echo "============================================================="
    echo ""
    exit 1
}

# Función para verificar si el usuario existe en el archivo loginusuarios.txt
usuario_existe() {
    # Utiliza el comando grep para buscar la presencia de una línea que comience con el nombre de usuario proporcionado ($1)
    # seguido de dos puntos (:), lo que indicaría la presencia de un usuario en el archivo.
    # El modificador -q hace que grep opere en modo silencioso, sin mostrar resultados en pantalla.
    grep -q "^$1:" $ARCHIVO_LOGIN
}

# Función para crear un nuevo usuario
crear_usuario() {
    usuario="$1"
    password="$2"
    
    password_encriptado=$(encriptar_password $password)

    if usuario_existe $usuario; then
        echo ""
        echo "El usuario $usuario ya existe. No se puede crear."
        echo ""
        read -p "Pulsa Intro para continuar..."
        echo ""
        return 1
    else
        echo "$usuario:$password_encriptado" >> $ARCHIVO_LOGIN
        echo ""
        return 0
    fi
}


# Función para iniciar sesión
login() {
    usuario="$1"
    password="$2"

    if usuario_existe $usuario; then
        password_real_encriptado=$(grep "^$usuario:" $ARCHIVO_LOGIN | cut -d ':' -f 2)
        password_real=$(desencriptar_password $password_real_encriptado)
        
        if [ "$password" = "$password_real" ]; then
            clear
            fecha=$(date +"%d-%m-%Y %H:%M:%S") # Fecha y hora del sistema
            echo ""
            echo "==========================================="
            echo "¡Bienvenid@, te has logueado como $usuario!"
            echo "Fecha y hora: $fecha"
            echo "==========================================="
            echo ""
            exit 0
        else
            echo ""
            echo "Contraseña incorrecta!!"
            echo ""
            return 1
        fi
    else
        echo ""
        echo "El usuario $usuario no existe."
        echo ""
        return 2
    fi
}

# Función para que un usuario elimine su propia cuenta
eliminar_usuario() {
    usuario="$1"

    if usuario_existe $usuario; then
        read -p "¿Estás seguro de que deseas eliminar el usuario $usuario? (s/N): " confirmacion
        if [ "$confirmacion" = "s" ] || [ "$confirmacion" = "S" ]; then
            read -s -p "Contraseña: " password
            echo ""
            password_real_encriptado=$(grep "^$usuario:" $ARCHIVO_LOGIN | cut -d ':' -f 2)
            password_real=$(desencriptar_password $password_real_encriptado)

            if [ "$password" = "$password_real" ]; then
                sed -i "/^$usuario:/d" $ARCHIVO_LOGIN
                echo ""
                echo "El usuario $usuario ha sido eliminado correctamente."
                echo ""
                read -p "Pulsa Intro para continuar..."
                echo ""
                return 0
            else
                echo ""
                echo "Contraseña incorrecta. No se puede eliminar el usuario."
                echo ""
                read -p "Pulsa Intro para continuar..."
                echo ""
                return 1
            fi
        else
            echo ""
            echo "Eliminación cancelada."
            echo ""
            read -p "Pulsa Intro para continuar..."
            echo ""
            return 2
        fi
    else
        echo ""
        echo "El usuario $usuario no existe."
        echo ""
        read -p "Pulsa Intro para continuar..."
        echo ""
        return 3
    fi
}

# Procesar argumentos de línea de comandos. Si no se proporcionan se cargará el menú
if [ $# -gt 0 ]; then
    # Si se proporcionaron argumentos en la línea de comandos
    case $1 in
        -l|--login)
            # Opción: Iniciar sesión con el usuario y contraseña
            if [ $# -lt 3 ]; then
                # Verificar si se proporcionaron suficientes argumentos (nombre de usuario y contraseña)
                echo ""
                echo "Se requieren un nombre de usuario y contraseña válidos."
                echo ""
                exit 1
            fi
            # Llamar a la función "login" para intentar el inicio de sesión con el nombre de usuario y contraseña dados
            login $2 $3 || exit 1
            ;;
        -c|--crear)
            # Opción: Crear un nuevo usuario
            if [ -z "$2" ]; then
                # Verificar si se proporcionó un nombre de usuario válido
                echo ""
                echo "Se requiere un nombre de usuario válido."
                echo ""
                exit 1
            fi
            if usuario_existe $2; then
                # Verificar si el usuario ya existe en los registros
                echo ""
                echo "El usuario $2 ya existe. No se puede crear."
                echo ""
                exit 1
            fi
            # Solicitar al usuario una contraseña segura para el nuevo usuario
            read -s -p "Escribe una contraseña para crear el usuario $2: " new_password
            # Llamar a la función "crear_usuario" para crear al nuevo usuario con el nombre y contraseña dados
            crear_usuario $2 $new_password
            echo ""
            echo "El usuario $2 se ha creado de forma correcta."
            echo ""
            exit 0
            ;;
        -d|--eliminar)
            # Opción: Eliminar usuario
            if [ $# -lt 2 ]; then
                echo ""
                echo "Se requiere un nombre de usuario válido."
                echo ""
                exit 1
            fi
            eliminar_usuario $2
            ;;
        -h|--ayuda)
            # Opción: Mostrar la ayuda
            ayuda
            ;;
        *)
            # Opción: Desconocida
            echo ""
            echo "Opción desconocida: $1"
            echo ""
            ayuda
            ;;
    esac
else
    # Si no se proporcionaron argumentos en la línea de comandos, mostrar el menú interactivo
    clear
    while true; do
        cabecera "Menú"
        echo "  1. Iniciar sesión"
        echo "  2. Crear usuario"
        echo "  3. Eliminar usuario"
        echo "  0. Salir"
        echo ""
        read -p "Selecciona una opción: " menu_choice

        case $menu_choice in
            1)
                # Opción 1: Iniciar sesión
                cabecera "Login"
                read -p "Nombre de usuario: " username
                if usuario_existe $username; then
                    # Si el usuario existe en los registros, intentar iniciar sesión
                    # Número de intentos posibles
                    intentos=3

                    while [ $intentos -gt 0 ]; do
                        read -s -p "Contraseña (intentos restantes: $intentos): " password
                        echo
                        if login $username $password; then
                            break
                        else
                            intentos=$((intentos - 1))
                            if [ $intentos -gt 0 ]; then
                               # echo "Contraseña incorrecta!!!"
                                echo ""
                            else
                                echo ""
                                echo "Has agotado tus intentos de inicio de sesión."
                                echo ""
                                read -p "Pulsa Intro para continuar..."
                                echo ""
                            fi
                        fi
                    done
                else
                    # Si el usuario no existe, mostrar mensaje
                    echo ""
                    echo "No existe el usuario. Puedes crearlo desde el menú principal"
                    echo ""
                    read -p "Pulsa Intro para continuar..."
                    echo ""
                fi
                ;;
            2)
                # Opción 2: Crear usuario
                cabecera "Crear usuario"
                echo ""
                read -p "Nuevo nombre de usuario: " new_username
                echo ""

                if usuario_existe $new_username; then
                    # Verificar si el usuario ya existe en los registros
                    echo "El usuario $new_username ya existe. No se puede crear."
                    echo ""
                    read -p "Pulsa Intro para continuar..."
                    echo ""
                else
                    # Solicitar al usuario una contraseña segura para el nuevo usuario
                    read -s -p "Contraseña: " new_password
                    echo ""
                    # Llamar a la función "crear_usuario" para crear al nuevo usuario con el nombre y contraseña dados
                    crear_usuario $new_username $new_password
                    echo ""
                    echo "El usuario $new_username se ha creado correctamente"
                    echo ""
                    read -p "Pulsa Intro para continuar..."
                fi
                ;;
            3)
                # Eliminar usuario
                cabecera "Eliminar usuario"
                read -p "Nombre de usuario: " delete_username
                eliminar_usuario $delete_username
                ;;
            0)
                # Salir del programa
                echo ""
                echo "Saliendo del programa."
                echo ""
                exit 0
                ;;
            *)
                # Opción inválida
                echo ""
                echo "Opción inválida."
                echo ""
                ;;
        esac
    done
fi
