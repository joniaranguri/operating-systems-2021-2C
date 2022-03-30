# Declaramos los parámetros:

# path va a ser el primer parámetro pero no es obligatorio, validamos que sea de tipo contenedor y 
# si no se pasa el valor, tomamos el path desde donde se ejecutó el script

# results es opcional y tiene el valor por defecto 0.
[CmdletBinding()]
Param (
 [Parameter(Position = 1, Mandatory = $false)]
 [ValidateScript( { Test-Path -PathType Container $_ } )]
 [String] $path,
 [int] $results = 0
)
# Guardo en una variable un listado de los directorios contenidos dentro del path dado por parámetro
$LIST = Get-ChildItem -Path $path -Directory
# Recorro esa lista de directorios
$ITEMS = ForEach ($ITEM in $LIST) {
# Para cada directorio, creo una variable COUNT con la cantidad de "hijos"(directorios y archivos)
 $COUNT = (Get-ChildItem -Path $ITEM).count
# Para cada directorio, creo un hash-table con los valores de el nombre del directorio y la variable count de la linea anterior
 $props = @{
 name = $ITEM
 count = $COUNT
 }
# Instancio un nuevo objeto con el prototipo dado por el hastable props y lo guardo en la posición actual de la lista
 New-Object psobject -Property $props
}
# Creo una nueva lista a partir de la lista de objects, ordenandola por count de mayor a menor, filtrando por los primeros n
# resultados y seleccionando solamente la property name
$CANDIDATES = $ITEMS | Sort-Object -Property count -Descending | Select-Object -First $results | Select-Object -Property name
# Imprimimos un mensaje por pantalla para avisar que vamos a mostrar los resultados
Write-Output "Los $results directorio/s con más contenido son :"
# Mostramos los resultados contenidos dentro de $CANDIDATES pero sin mostrar el header que viene por default
$CANDIDATES | Format-Table -HideTableHeaders


<#
Responda:
1. ¿Cuál es el objetivo de este script? ¿Qué parámetros recibe? Renombre los parámetros con
un nombre adecuado.

Respuesta : El objetivo del script es la de listar los n directorios con más hijos directos en un path dado.
Recibe 2 parametros, el path a procesar y la cantidad de resultados a mostrar.

2. Comentar el código según la funcionalidad (no describa los comandos, indique la lógica).

Realizado.

3. Completar el Write-Output con el mensaje correspondiente.

Realizado.

4. ¿Agregaría alguna otra validación a los parámetros? ¿Existe algún error en el script?

Respuesta: No a los parámetros sino en el código. Si el valor de results es 0 no tiene sentido procesar nada, directamente se podría alertar 
al usuario de que no tiene sentido mostrar 0 resultados.
Hay un problema cuando el alguno de los subdirectorios del path dado solo contiene 1 archivo. El '(Get-ChildItem -Path $ITEM).Length'
devuelve el tamaño del archivo en vez de 1.

5. ¿Para qué se utiliza [CmdletBinding()]?

Respuesta: El agregar el [CmdletBinding()] nos sirve para poder soportar automáticamente los parámetros comunes a los cmdlets como por ejemplo 
-Verbose, -Debug, -ErrorAction, entre otros.

6. Explique las diferencias entre los distintos tipos de comillas que se pueden utilizar en
Powershell.

Respuesta: Existen 3 tipos de comillas a utilizar: las comillas dobles (“), comillas simples (‘) y acento grave (`).
- Las comillas dobles, también denominadas comillas débiles, permiten utilizar texto e interpretar
variables al mismo tiempo.
- Las comillas simples, también denominadas comillas fuertes, generan que el texto delimitado
entre ellas se utilice de forma literal, lo que evita que se interpreten las variables.
- El acento grave, es el carácter de escape para evitar la interpretación de los caracteres especiales,
como por ejemplo el símbolo $.

7. ¿Qué sucede si se ejecuta el script sin ningún parámetro?

Respuesta: Se corre el script tomando el path sobre el cual estamos parados al momento de ejecutar el script y el valor 
por defecto de results osea 0. Por lo cual termina solamente mostrando el mensaje de la anteúltima linea del programa, en este caso:
'Los 0 directorio/s con más contenido son :'
#>