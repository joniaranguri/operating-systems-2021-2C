/*  APL N3 Ejercicio 4 (Segunda entrega)
    Script: servidor.cpp
    Integrantes:
    ARANGURI JONATHAN ENRIQUE                  40.672.991	
*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <semaphore.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdarg.h>
#include <signal.h>
#include <string.h>
#include <iostream>
#include <fstream>
#include <thread>
#include <vector>
#include <mutex>
#include <sstream>

/*
✓ Se ejecutará y quedará a la espera de que un cliente se conecte.
✓ Al finalizar una partida, quedará a la espera de una nueva conexión.
✓ Finalizará su ejecución al recibir la señal SIGUSR1, siempre y cuando no haya ninguna partida
en curso.
✓ Deberá configurar una nueva partida al recibir la conexión de un nuevo cliente.
✓ Seleccionará N definiciones con sus respectivas palabras de manera aleatoria (al comenzar cada
nueva partida), elegidas de un conjunto de definiciones y palabras posibles almacenadas en un
archivo de texto plano.
✓ Al recibir una respuesta ya sea correcta o incorrecta, se pasará a la siguiente definición.
✓ Al recibir como respuesta una cadena vacía, se pasará a la siguiente definición.
✓ Deberá contabilizar +1 punto por palabra correcta, -1 punto por palabra incorrecta y 0 por pasar
la palabra.
✓ Al completarse la lista de definiciones, enviará al cliente la siguiente información:
✓ Puntuación final.
✓ Lista de palabras incorrectas o no contestadas y su respectiva definición
*/

using namespace std;
char respuestaCliente[100];
int parentPid;
string respuesta;
string archivo = "definiciones.txt";
bool isPlaying = false;
#define MEMORIA_RES "aranggueri-mem"
#define MEMORIA_DEF "DFFDF-gemem"
#define SEM_LEE_CLIENTE "sem-legfe-cliente"
#define SEM_LEE_SERVIDOR "sem-legef-servidor"
#define SEM_SERVIDOR "sem-DDDgDem"
class AutoDef
{
public:
    string definition;

public:
    string result;

    void init(string definition, string result)
    {
        (*this).definition = definition;
        (*this).result = result;
    }
};
vector<AutoDef> registros;

void handlerSigInt(int signal)
{
    //Nothing to do
}
void handlerSigFin(int signal)
{
    if (!isPlaying)
    {
        exit(0);
    }
}
/*
void getSumForChofer(string nombre)
{
    int kmsSum = 0;
    int gasoilSum = 0;
    int valorSum = 0;
    bool encontro = false;
    for (int i = 0; i < registros.size(); i++)
    {
        Registro registro = registros.at(i);
        if (strcmp(&(registro.chofer)[0], &nombre[0]) == 0)
        {
            kmsSum += registro.kms;
            gasoilSum += registro.gasoil;
            valorSum += registro.valor;
            encontro = true;
        }
    }

    std::stringstream ss;
    if (encontro)
    {
        ss << "Km: " << kmsSum << endl
           << "Gasoil: " << gasoilSum << "Litros" << endl
           << "Valor: $" << valorSum << endl;
    }
    else
    {
        ss << "No se encontró al chofer de nombre " << nombre << endl;
    }
    respuesta = ss.str();
}

void getListForChofer(string nombre)
{
    std::stringstream ss;
    bool encontro = false;

    for (int i = 0; i < registros.size(); i++)
    {
        Registro registro = registros.at(i);
        if (strcmp(&(registro.chofer)[0], &nombre[0]) == 0)
        {
            string guion = "-";
            string customRuta = registro.ruta.replace(registro.ruta.find(guion), guion.length(), " -> ");
            ss << registro.id << " - " << customRuta << " ( " << registro.kms << " Km )"
               << " - " << registro.gasoil << " Lt - $ " << registro.valor << endl;
            encontro = true;
        }
    }
    if (!encontro)
    {
        ss << "No se encontró al chofer de nombre " << nombre << endl;
    }
    respuesta = ss.str();
}

void maxGasoil()
{
    std::stringstream ss;

    sort(registros.begin(), registros.end(), greater<Registro>());
    Registro registro = registros.at(0);
    ss << "ID: " << registro.id << endl
       << "Chofer: " << registro.chofer << endl
       << "Trayecto: " << registro.ruta << " ( " << registro.kms << " Km ) " << endl
       << "Gasoil: " << registro.gasoil << "Lt" << endl;
    respuesta = ss.str();
}

void avgValor()
{
    int total = 0;
    for (int i = 0; i < registros.size(); i++)
    {
        total += registros.at(i).valor;
    }
    std::stringstream ss;
    ss << "$ " << total / registros.size() << endl;
    respuesta = ss.str();
}

int procesarConsulta()
{
    if (registros.size() < 1)
    {
        respuesta = "No hay registros en el archivo";
    }
    istringstream ss(respuestaCliente);
    string comando;
    getline(ss, comando, ' ');

    if (strcmp(&comando[0], "SUM") == 0)
    {
        string nombre;
        getline(ss, nombre, ' ');
        getSumForChofer(nombre);
    }
    else if (strcmp(&comando[0], "MAX_GASOIL") == 0)
    {
        maxGasoil();
    }
    else if (strcmp(&comando[0], "AVG_VALOR") == 0)
    {
        avgValor();
    }
    else if (strcmp(&comando[0], "LIST") == 0)
    {
        string nombre;
        getline(ss, nombre, ' ');
        getListForChofer(nombre);
    }
    else
    {
        return 1;
    }

    return 0;
}
*/
void mostrarAyuda()
{
    printf("\n Ejemplo de ejecucion: \n ./servidor 2021.viajes\n");
}

int validarParametros(int argc, char const *argv[])
{
    if (argc != 2 || argc > 2)
    {
        printf("\n Cantidad de parametros incorrecta, verifique la ayuda\n");
        return 1;
    }

    if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "-help") == 0 || strcmp(argv[1], "-?") == 0)
    {
        mostrarAyuda();
        return 1;
    }
    struct stat info;
    if (stat(argv[1], &info) != 0)
    {
        printf("\nNo se se econtró el archivo %s\n", argv[2]);
        return 1;
    }
    archivo = argv[1];

    return 0;
}

int leerArchivo()
{
    string line;
    try
    {
        ifstream miArchivo(archivo);
        string definition;
        while (getline(miArchivo, definition, '\t'))
        {
            string result;
            getline(miArchivo, result, '\t');
            AutoDef registro;
            registro.init(definition, result);
            registros.push_back(registro);
        }
        miArchivo.close();
    }
    catch (const std::exception &e)
    {
        std::cerr << "Ocurrió un error al leer el archivo" << endl;
        return 1;
    }
    return 0;
}
void cerrarAlmATAR(int signal)
{
    sem_unlink(SEM_SERVIDOR);
    sem_unlink(SEM_LEE_CLIENTE);
    sem_unlink(SEM_LEE_SERVIDOR);
    return;
}

int main(int argc, char const *argv[])
{

    sem_t *semaforo = sem_open(SEM_SERVIDOR, O_CREAT, 0600, 1);

    if (sem_trywait(semaforo) != 0)
    {
        cout << "No se puede ejecutar mas de una instancia del proceso" << endl;
        // return 1;
    }
    /* if (validarParametros(argc, argv))
    {
        sem_post(semaforo);
        sem_close(semaforo);
        sem_unlink(SEM_SERVIDOR);
        return 1;
    }*/
    signal(SIGINT, SIG_IGN);
    signal(SIGUSR1, handlerSigFin);
    signal(SIGKILL, cerrarAlmATAR);
    if (leerArchivo() != 0)
    {
        cout << "No se puede leer el archivo de definiciones" << endl;

        return 0;
    }
    cout << registros.size() << endl;

    int idMemoriaDefinicion = shm_open(MEMORIA_DEF, O_CREAT | O_RDWR, 0600);
    int idMemoriaRespuesta = shm_open(MEMORIA_RES, O_CREAT | O_RDWR, 0600);
    size_t tamRespuesta = sizeof(char) * 100;
    size_t tamDefinicion = sizeof(char) * 4096;
    ftruncate(idMemoriaDefinicion, sizeof(tamDefinicion));
    ftruncate(idMemoriaRespuesta, sizeof(tamRespuesta));
    char *memoriaRes = (char *)mmap(NULL, tamRespuesta,
                                    PROT_READ | PROT_WRITE, MAP_SHARED, idMemoriaRespuesta, 0);
    char *memoriaDef = (char *)mmap(NULL, tamDefinicion,
                                    PROT_READ | PROT_WRITE, MAP_SHARED, idMemoriaDefinicion, 0);
    close(idMemoriaDefinicion);
    close(idMemoriaRespuesta);
    sem_t *semLeeCliente = sem_open(SEM_LEE_CLIENTE, O_CREAT, 0600, 0);
    sem_t *semLeeServidor = sem_open(SEM_LEE_SERVIDOR, O_CREAT, 0600, 0);









    while (true)
    {
        sem_wait(semLeeServidor); // servidor: quiero leerMemoria

        //configurarPartida
        int a[] = {4, 0, 2};

        int sizeOfPartida = atoi(memoriaRes);

        for (int i = 0; i < sizeOfPartida; i++)
        {
            strcpy(memoriaDef, &(registros.at(i).definition)[0]);

            cout << memoriaDef << endl;
            sem_post(semLeeCliente); 

            sem_wait(semLeeServidor);
            string respuesta = memoriaRes;
           // cout << "La respuesta es" << respuesta << endl;
        }
        strcpy(memoriaDef, "Resultado final: 10");
        sem_post(semLeeCliente); //4 dame
        cout << "Termino la partida, reiniciando" << endl;
    }
    sem_post(semaforo);
    sem_close(semaforo);
    sem_unlink(SEM_SERVIDOR);
    sem_close(semLeeCliente);
    sem_unlink(SEM_LEE_CLIENTE);
    sem_close(semLeeServidor);
    sem_unlink(SEM_LEE_SERVIDOR);
    return 0;
}
