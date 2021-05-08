#!/usr/bin/python3
'''
    SIMULADOR DE ORBITAS PLANETARIAS
    Autor: Luis Alejandro Vejarano Gutierrez
    Clase: Computación Paralela y Distribuida
    Universidad Sergio Arboleda 14/05/2021
'''
import CySimulator as cy
import simulator as py
import time

''' Inicialización objetos Cython '''
CySun = cy.Body(name = 'Sun',mass = 1.98892 * 10**30)

CyEarth = cy.Body(name = 'Earth',
                  mass = 5.9742 * 10 ** 24,
                  px = -1 * cy.AU,
                  vy = 29.783 * 1000)  # 29.783 km/sec

CyVenus = cy.Body(name = 'Venus',
                  mass = 4.8685 * 10 ** 24,
                  px = 0.723 * cy.AU,
                  vy = -35.02 * 1000)

''' Inicialización objetos Python '''

PySun = py.Body()
PySun.name = 'Sun'
PySun.mass = 1.98892 * 10 ** 30

PyEarth = py.Body()
PyEarth.name = 'Earth'
PyEarth.mass = 5.9742 * 10 ** 24
PyEarth.px = -1 * py.AU
PyEarth.vy = 29.783 * 1000  # 29.783 km/sec

PyVenus = py.Body()
PyVenus.name = 'Venus'
PyVenus.mass = 4.8685 * 10 ** 24
PyVenus.px = 0.723 * py.AU
PyVenus.vy = -35.02 * 1000

'''Listas de Ejecuciones'''
pTiempoPy, pTiempoCy, pSpeedUp = [], [], []

'''Para el test se repetirá n veces la toma de tiempos'''
n = 30
for i in range(n):
    inicio = time.time()
    py.loop([PySun, PyEarth, PyVenus])
    tiempoPy = time.time() - inicio
    pTiempoPy.append(tiempoPy)

    inicio = time.time()
    cy.loop([CySun, CyEarth, CyVenus])
    tiempoCy = time.time() - inicio
    pTiempoCy.append(tiempoCy)

    speedUp = round(tiempoPy/tiempoCy,3)
    pSpeedUp.append(speedUp)

promPy = round(sum(pTiempoPy)/len(pTiempoPy),3)
promCy = round(sum(pTiempoCy)/len(pTiempoCy),3)
promSpeedUp = round(sum(pSpeedUp)/len(pSpeedUp),3)

print("SIMULADOR DE ÓRBITAS PLANETARIAS: 1000 años\n")
print(f"Al ejecutar {n} veces:\n")
print(f"Tiempo promedio Python: {promPy}")
print(f"Tiempo promedio Cython: {promCy}")
print(f"Promedio SpeedUp: {promSpeedUp}")