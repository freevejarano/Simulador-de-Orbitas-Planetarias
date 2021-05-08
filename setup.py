'''
    SIMULADOR DE ORBITAS PLANETARIAS
    Autor: Luis Alejandro Vejarano Gutierrez
    Clase: Computación Paralela y Distribuida
    Universidad Sergio Arboleda 14/05/2021
'''

from distutils.core import setup, Extension
from Cython.Build import cythonize

ext = Extension(name = 'CySimulator',sources=['CySimulator.pyx'])

setup(ext_modules=cythonize(ext,
        compiler_directives={'language_level': 3}))