#cython: language_level=3, boundscheck=False, wraparound=False, nonecheck=False
'''
    SIMULADOR DE ORBITAS PLANETARIAS
    Autor: Luis Alejandro Vejarano Gutierrez
    Clase: Computación Paralela y Distribuida
    Universidad Sergio Arboleda 14/05/2021
    Referencia: 2012, A.M. Kuchling https://fiftyexamples.readthedocs.io/en/latest/gravity.html
'''
cimport cython

# Extract functions from math.h
cdef extern from "math.h":
    long double pow(double x, double y) nogil
    long double sqrt(double x) nogil
    long double cos(double x) nogil
    long double sin(double x) nogil
    long double atan2(double x, double y) nogil

# The gravitational constant G
cdef public float G = 6.67428e-11

# Assumed scale: 100 pixels = 1AU.
AU = (149.6e6 * 1000)  # 149.6 million km, in meters.
cdef long double SCALE = 250 / AU

cdef class Body():
    """
    Extra attributes:
    mass : mass in kg
    vx, vy: x, y velocities in m/s
    px, py: x, y positions in m
    """
    # Initialize variables
    cdef public long double mass, vx, vy, px , py
    cdef public str name
    cdef public long double sx, sy, ox, oy, dx, dy, d, f, theta, fx, fy

    # Use a constructor for the object
    def __cinit__(self, str name='', long double mass = 0, long double vx = 0, long double vy = 0, long double px = 0, long double py = 0):
        self.name = name
        self.mass = mass
        self.vx = vx
        self.vy = vy
        self.px = px
        self.py = py

    @cython.cdivision(True)
    cdef tuple attraction(self, Body other):
        """(Body): (fx, fy)

        Returns the force exerted upon this body by the other body.
        """
        # Report an error if the other object is the same as this one.
        if self is other:
            raise ValueError(f"Attraction of object {self.name} to itself requested")

        # Compute the distance of the other body.
        sx = self.px
        sy = self.py
        ox = other.px
        oy = other.py
        dx = (ox-sx)
        dy = (oy-sy)
        d = sqrt(pow(dx,2) + pow(dy,2))

        # Report an error if the distance is zero; otherwise we'll
        # get a ZeroDivisionError exception further down.
        if d == 0:
            raise ValueError(f"Attraction of object {self.name} to itself requested")

        # Compute the force of attraction
        f = G * self.mass * other.mass / (pow(d,2))

        # Compute the direction of the force.
        theta = atan2(dy, dx)
        fx = cos(theta) * f
        fy = sin(theta) * f
        return (fx,fy)

def loop(list bodies):
    """([Body])

    Never returns; loops through the simulation, updating the
    positions of all the provided bodies.
    """
    cdef int timestep = 24*3600  # One day

    cdef int step = 1
    cdef dict force = {}
    cdef long double total_fx, total_fy, fx, fy
    cdef int size = len(bodies)
    cdef Body body, other
    """" 365 steps in order to complete earth's cycle """
    while step <= 365*1000:
        step += 1
        for i in range(size):
            # Add up all of the forces exerted on 'body'.
            body = bodies[i]
            total_fx = 0.0
            total_fy = 0.0
            for j in range(size):
                # Don't calculate the body's attraction to itself
                other = bodies[j]
                if body is other:
                    continue

                fx, fy = body.attraction(other)
                total_fx += fx
                total_fy += fy

            # Record the total force exerted.
            force[body] = (total_fx, total_fy)

        # Update velocities based upon on the force.
        for i in range(size):
            body = bodies[i]
            fx, fy = force[body]
            body.vx += fx / body.mass * timestep
            body.vy += fy / body.mass * timestep

            # Update positions
            body.px += body.vx * timestep
            body.py += body.vy * timestep
