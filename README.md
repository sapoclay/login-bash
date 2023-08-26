# Pequeño login muy básico con bash

Hacer un login en bash que permita al usuario escribir el usuario y la contraseña. Algunas de las cosas que permite realizar este sencillo script son:

![menu-login](https://github.com/sapoclay/login-bash/assets/6242827/0b8ec390-883d-413b-949f-a1cd991025e1) 

- Funciones de Encriptación y Desencriptación: El script define dos funciones (encriptar_password y desencriptar_password) para encriptar y desencriptar contraseñas utilizando el algoritmo AES-256 en modo CBC y el algoritmo de derivación de clave PBKDF2. Esto garantiza que las contraseñas almacenadas en el archivo sean seguras.

- Función de Cabecera: La función cabecera se encarga de limpiar la pantalla y mostrar una cabecera informativa para diferentes secciones, como el menú y las opciones.

- Creación de Archivo de Usuarios: Si el archivo loginusuarios.txt no existe, se crea. Este archivo contendrá los registros de usuarios y sus contraseñas encriptadas.

- Función de Ayuda: La función ayuda muestra información sobre cómo usar el script desde la terminal, incluyendo las opciones disponibles y sus usos.

- Verificación de Existencia de Usuario: La función usuario_existe utiliza el comando grep para verificar si un usuario existe en el archivo de usuarios.

- Creación de Usuario: La función crear_usuario permite crear un nuevo usuario proporcionando un nombre de usuario y una contraseña. Verifica si el usuario ya existe y, si no existe, agrega el nuevo usuario con la contraseña encriptada al archivo.

![ayuda-login-terminal](https://github.com/sapoclay/login-bash/assets/6242827/fc2df9a3-063e-4281-b12b-dba108e52766)

- Inicio de Sesión: La función login permite a un usuario iniciar sesión proporcionando su nombre de usuario y contraseña. Verifica si el usuario existe y si la contraseña es correcta.

- Eliminación de Usuario: La función eliminar_usuario permite a un usuario eliminar su propia cuenta. Verifica si el usuario existe, solicita una confirmación y una contraseña antes de eliminar la cuenta.

- Procesamiento de Argumentos de Línea de Comandos: El script procesa los argumentos pasados desde la línea de comandos y ejecuta las funciones correspondientes para llevar a cabo las operaciones de autenticación, creación y eliminación de usuarios.

- Menú Interactivo: Si no se proporcionan argumentos desde la línea de comandos, se muestra un menú interactivo que permite al usuario seleccionar entre las opciones de inicio de sesión, creación de usuario, eliminación de usuario y salida del programa.

En resumen, este script de shell proporciona un sistema básico de autenticación de usuarios y administración de cuentas, permitiendo a los usuarios iniciar sesión, crear nuevas cuentas, eliminar sus propias cuentas y obtener ayuda sobre cómo usar el script. Vamos, que no deja de ser una pequeña práctica sobre la elaboración de archivo .sh

## Uso
Para hacer funcionar este sencillo script, basta con descargarlo y guardarlo en el archivo .sh, que debería llamarse (al menos yo lo llamé así) login-usuarios.sh. Para hacerlo funcionar, solo se necesita dar permisos de ejecución con el comando:
''' sudo chmod +x login-usuarios.sh '''
