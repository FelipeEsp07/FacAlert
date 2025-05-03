from django.db import models

from django.db import models
from django.contrib.auth.hashers import make_password

class Rol(models.Model):
    nombre = models.CharField(max_length=50, unique=True)

    def __str__(self):
        return self.nombre
    

class Usuario(models.Model):
    nombre = models.CharField(max_length=150)
    cedula = models.CharField(max_length=20, unique=True)
    telefono = models.CharField(max_length=20)
    direccion = models.CharField(max_length=255)
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=128)

    rol = models.ForeignKey(
        Rol,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='usuarios'
    )

    latitud = models.FloatField(null=True, blank=True)
    longitud = models.FloatField(null=True, blank=True)
    fecha_registro = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)

    def save(self, *args, **kwargs):
        if not self.password.startswith('pbkdf2_'):
            self.password = make_password(self.password)
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.nombre} <{self.email}> ({self.rol})"
    

class ClasificacionDenuncia(models.Model):
    nombre = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.nombre


class Denuncia(models.Model):
    descripcion = models.TextField()
    ubicacion_latitud = models.FloatField()
    ubicacion_longitud = models.FloatField()
    fecha = models.DateField()
    hora = models.TimeField(null=True, blank=True) 
    
    clasificacion = models.ForeignKey(
        ClasificacionDenuncia, 
        related_name='denuncias_principal',
        on_delete=models.PROTECT,
        null=True, 
        blank=True
    )
    otra_clasificacion = models.ForeignKey(
        ClasificacionDenuncia, 
        related_name='denuncias_secundaria',
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True
    )
    
    def __str__(self):
        return f'Denuncia {self.id} - {self.clasificacion.nombre}'


class ImagenDenuncia(models.Model):
    denuncia = models.ForeignKey(Denuncia, on_delete=models.CASCADE, related_name='imagenes')
    imagen = models.ImageField(upload_to='denuncias/imagenes/')

    def __str__(self):
        return f'Imagen para Denuncia {self.denuncia.id}'