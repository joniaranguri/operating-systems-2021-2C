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
#include <time.h>
#include <algorithm>

using namespace std;
int parentPid;
string respuesta;
string archivo = "definiciones.txt";
vector<int> elegidas;
sem_t *semaforo;
sem_t *semLeeCliente;
sem_t *semLeeServidor;
#define MEMORIA_RES "MEMORIA_RES_4"
#define MEMORIA_DEF "MEMORIA_DEF_4"
#define SEM_LEE_CLIENTE "SEM_LEE_CLIENTE_4"
#define SEM_LEE_SERVIDOR "SEM_LEE_SERVIDOR_4"
#define SEM_SERVIDOR "SEM_SERVIDOR_4"
#define USER_SKIP_QUESTION "user_skip_question"
#define MEMORIA_PID "MEMORIA_PID_4"
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

void cerrarRecursos(int signal)
{

    shm_unlink(MEMORIA_RES);
    shm_unlink(MEMORIA_DEF);
    shm_unlink(MEMORIA_PID);
    sem_close(semLeeCliente);
    sem_close(semLeeServidor);
    sem_unlink(SEM_LEE_CLIENTE);
    sem_unlink(SEM_LEE_SERVIDOR);
    sem_post(semaforo);
    sem_close(semaforo);
    sem_unlink(SEM_SERVIDOR);
    cout << "Apagando servidor" << endl;
    exit(0);
}

void clienteFinaliza(int signal)
{
    cout << "Partida cancelada" << endl;
    cerrarRecursos(signal);
}

void mostrarAyuda()
{
    cout << "Ejemplo de ejecucion: \n ./servidor" << endl;
}

int validarParametros(int argc, char const *argv[])
{
    if (argc > 1)
    {
        if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0 || strcmp(argv[1], "-?") == 0)
        {
            mostrarAyuda();
        }
        else
        {
            printf("\n Cantidad de parametros incorrecta, verifique la ayuda\n");
        }
        return 1;
    }
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

void elegirAleatorias(int cant)
{
    elegidas.clear();
    srand(time(NULL));

    while (elegidas.size() < cant)
    {
        int randomNum = rand() % registros.size();
        if (find(elegidas.begin(), elegidas.end(), randomNum) == elegidas.end())
        {
            elegidas.push_back(randomNum);
        }
    }
}

int main(int argc, char const *argv[])
{

    semaforo = sem_open(SEM_SERVIDOR, O_CREAT, 0600, 1);

    if (sem_trywait(semaforo) != 0)
    {
        cout << "No se puede ejecutar mas de una instancia del proceso" << endl;
        return 1;
    }
    if (validarParametros(argc, argv))
    {
        cerrarRecursos(0);
    }

    signal(SIGINT, SIG_IGN);
    signal(SIGUSR1, cerrarRecursos);
    signal(SIGUSR2, clienteFinaliza);
    if (leerArchivo() != 0)
    {
        cout << "No se puede leer el archivo de definiciones" << endl;
        cerrarRecursos(0);
    }
    int idMemoriaPid = shm_open(MEMORIA_PID, O_CREAT | O_RDWR, 0600);
    int idMemoriaDefinicion = shm_open(MEMORIA_DEF, O_CREAT | O_RDWR, 0600);
    int idMemoriaRespuesta = shm_open(MEMORIA_RES, O_CREAT | O_RDWR, 0600);
    size_t tamRespuesta = sizeof(char) * 100;
    size_t tamDefinicion = sizeof(char) * 4096;
    ftruncate(idMemoriaPid, sizeof(int));
    ftruncate(idMemoriaDefinicion, sizeof(tamDefinicion));
    ftrunc