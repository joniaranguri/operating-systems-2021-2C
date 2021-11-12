/*  APL N3 Ejercicio 3 (Segunda entrega)
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

using namespace std;
string FIFO1 = "FIFO1";
string FIFO2 = "FIFO2";
char comandoConsulta[100];
int parentPid;
string respuesta;
string archivo;
class Registro
{
public:
    int id;

public:
    string chofer;

public:
    string ruta;

public:
    int kms;

public:
    int gasoil;

public:
    int valor;

    void init(string id, string chofer, string ruta, string kms, string gasoil, string valor)
    {
        (*this).id = stoi(id);
        (*this).chofer = chofer;
        (*this).ruta = ruta;
        (*this).kms = stoi(kms);
        (*this).gasoil = stoi(gasoil);
        (*this).valor = stoi(valor);
    }
    bool operator<(const Registro &r) const
    {
        if (gasoil != r.gasoil)
        {
            return gasoil < r.gasoil;
        }

        return gasoil < r.gasoil;
    }

    bool operator>(const Registro &r) const
    {
        if (gasoil != r.gasoil)
        {
            return gasoil > r.gasoil;
        }

        return gasoil > r.gasoil;
    }
};
vector<Registro> registros;

void handlerSenial(int signal)
{
    unlink(&FIFO1[0]);
    unlink(&FIFO2[0]);
    exit(0);
}

void handlerSigInt(int signal)
{
    //Nothing to do
}

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
    istringstream ss(comandoConsulta);
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
        getline(miArchivo, line);
        string id;
        while (getline(miArchivo, id, '\t'))
        {
            string chofer;
            string ruta;
            string kms;
            string gasoil;
            string valor;
            getline(miArchivo, chofer, '\t');
            getline(miArchivo, ruta, '\t');
            getline(miArchivo, kms, '\t');
            getline(miArchivo, gasoil, '\t');
            getline(miArchivo, valor, '\t');

            Registro registro;
            registro.init(id, chofer, ruta, kms, gasoil, valor);
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

int main(int argc, char const *argv[])
{
    sem_t *semaforo = sem_open("semServidor", O_CREAT, 0600, 1);

    if (sem_trywait(semaforo) != 0)
    {
        cout << "No se puede ejecutar mas de una instancia del proceso" << endl;
        return 1;
    }

    if (validarParametros(argc, argv))
    {
        sem_post(semaforo);
        sem_close(semaforo);
        sem_unlink("semServidor");
        return 1;
    }
    signal(SIGINT, handlerSigInt);
    signal(SIGCHLD, handlerSenial);
    parentPid = getpid();
    if (leerArchivo() != 0)
    {
        cout << "No se puede leer el archivo" << endl;

        return 0;
    }
    pid_t pid = fork();

    if (pid == 0)
    {
        mkfifo(&FIFO2[0], 0600);
        mkfifo(&FIFO1[0], 0600);

        while (strcmp(comandoConsulta, "QUIT") != 0)
        {
            int fileDescriptorFifo1 = open(&FIFO1[0], O_RDONLY);
            read(fileDescriptorFifo1, comandoConsulta, sizeof(comandoConsulta));
            close(fileDescriptorFifo1);

            if (strcmp(comandoConsulta, "QUIT") != 0)
            {
                if (procesarConsulta() != 0)
                {
                    respuesta = "No se puede procesar su consulta, revise su sintaxis por favor";
                }
                int fileDescriptorFifo2 = open(&FIFO2[0], O_WRONLY);
                write(fileDescriptorFifo2, &respuesta[0], strlen(&respuesta[0]) + 1);
                close(fileDescriptorFifo2);
            }
            else
            {
                unlink(&FIFO1[0]);
                unlink(&FIFO2[0]);
                sem_post(semaforo);
                sem_close(semaforo);
                sem_unlink("semServidor");
                return 0;
            }
        }
    }

    return 0;
}
