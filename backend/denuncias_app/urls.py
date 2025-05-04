# urls.py

from django.urls import path
from django.conf.urls.static import static
from django.conf import settings

from . import views

urlpatterns = [
    # Roles
    path('api/roles', views.RolesView.as_view(), name='roles-list-create'),
    path('api/roles/<int:role_id>', views.RolDetailView.as_view(), name='roles-detail'),

    # Asignación de rol a usuario
    path('api/usuarios/<int:usuario_id>/rol', views.AsignarRolView.as_view(), name='asignar-rol-usuario'),

    # Gestión de usuarios
    path('api/usuarios', views.UsuariosView.as_view(), name='usuarios-list-create'),
    path('api/usuarios/<int:usuario_id>', views.UsuarioDetailView.as_view(), name='usuarios-detail'),

    # Registro público y autenticación
    path('api/register', views.RegistroUsuarioView.as_view(), name='registro-usuario'),
    path('api/login', views.LoginUsuarioView.as_view(), name='login-usuario'),
    path('api/profile', views.ProfileUsuarioView.as_view(), name='profile-usuario'),
    path('api/profile/edit', views.EditProfileUsuarioView.as_view(), name='edit-profile-usuario'),

    # Clasificaciones
    path('api/clasificaciones', views.ClasificacionesView.as_view(), name='clasificaciones-list-create'),
    path('api/clasificaciones/<int:pk>', views.ClasificacionDetailView.as_view(), name='clasificaciones-detail'),

    # Denuncias
    path('api/denuncias', views.DenunciasView.as_view(), name='denuncias-list-create'),
    path('api/denuncias/<int:pk>', views.DenunciaDetailView.as_view(), name='denuncias-detail'),

    # Clusters de zonas de riesgo
    path('api/denuncias/clusters/', views.ClustersView.as_view(), name='denuncias-clusters'),

]

urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)