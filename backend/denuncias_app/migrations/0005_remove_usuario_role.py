# Generated by Django 5.2 on 2025-04-27 18:09

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('denuncias_app', '0004_usuario_role'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='usuario',
            name='role',
        ),
    ]
