// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get btn_search => 'Buscar';

  @override
  String get btn_save => 'Guardar';

  @override
  String get btn_close => 'Cerrar';

  @override
  String get btn_clear => 'Limpiar';

  @override
  String get btn_exit => 'Salir';

  @override
  String get btn_reload => 'Recargar';

  @override
  String get btn_history => 'Historial';

  @override
  String get btn_sidebar_timelines => 'Cronologías';

  @override
  String get btn_sidebar_lists => 'Listas';

  @override
  String get btn_sidebar_trendings => 'Tendencias';

  @override
  String get btn_sidebar_notifications => 'Notificaciones';

  @override
  String get btn_sidebar_management => 'Gestión';

  @override
  String get btn_sidebar_post => 'Toot';

  @override
  String get btn_sidebar_sign_in => 'Iniciar sesión';

  @override
  String get btn_drawer_switch_server => 'Cambiar servidor';

  @override
  String get btn_drawer_directory => 'Explorar cuentas';

  @override
  String get btn_drawer_preference => 'Preferencias';

  @override
  String get btn_drawer_logout => 'Cerrar sesión';

  @override
  String get btn_trends_links => 'Enlaces';

  @override
  String get btn_trends_toots => 'Toots';

  @override
  String get btn_trends_users => 'Usuarios';

  @override
  String get btn_trends_tags => 'Etiquetas';

  @override
  String get btn_timeline_home => 'Inicio';

  @override
  String get btn_timeline_local => 'Local';

  @override
  String get btn_timeline_federal => 'Federal';

  @override
  String get btn_timeline_public => 'Público';

  @override
  String get btn_timeline_favourites => 'Favoritos';

  @override
  String get btn_timeline_bookmarks => 'Marcadores';

  @override
  String get btn_timeline_list => 'Listas';

  @override
  String get btn_timeline_vote => 'Votar';

  @override
  String btn_timeline_unread(Object count) {
    return '#$count toots sin leer';
  }

  @override
  String get btn_preference_theme => 'Tema';

  @override
  String get btn_preference_engineer => 'Configuración de ingeniero';

  @override
  String get btn_preference_about => 'Acerca de';

  @override
  String get btn_preference_engineer_clear_cache => 'Borrar todo el caché';

  @override
  String get btn_preference_engineer_reset => 'Restablecer sistema';

  @override
  String get btn_preference_engineer_test_notifier => 'Probar notificación';

  @override
  String get btn_interaction_reply => 'Responder';

  @override
  String get btn_interaction_reblog => 'Reblog';

  @override
  String get btn_interaction_favourite => 'Favorito';

  @override
  String get btn_interaction_bookmark => 'Marcador';

  @override
  String get btn_interaction_share => 'Compartir';

  @override
  String get btn_interaction_mute => 'Silenciar';

  @override
  String get btn_interaction_block => 'Bloquear';

  @override
  String get btn_interaction_report => 'Denunciar';

  @override
  String get btn_interaction_edit => 'Editar';

  @override
  String get btn_interaction_delete => 'Eliminar';

  @override
  String get btn_profile_core => 'Perfil';

  @override
  String get btn_profile_post => 'Toots';

  @override
  String get btn_profile_pin => 'Fijados';

  @override
  String get btn_profile_followers => 'Seguidores';

  @override
  String get btn_profile_following => 'Siguiendo';

  @override
  String get btn_profile_scheduled => 'Toots programados';

  @override
  String get btn_profile_hashtag => 'Etiquetas seguidas';

  @override
  String get btn_profile_filter => 'Filtros';

  @override
  String get btn_profile_mute => 'Usuarios silenciados';

  @override
  String get btn_profile_block => 'Usuarios bloqueados';

  @override
  String get btn_profile_general_info => 'Información general';

  @override
  String get btn_profile_privacy => 'Configuración de privacidad';

  @override
  String get btn_status_toot => 'Toot';

  @override
  String get btn_status_edit => 'Editar';

  @override
  String get btn_status_scheduled => 'Toot programado';

  @override
  String get btn_relationship_following => 'Siguiendo';

  @override
  String get btn_relationship_followed_by => 'Seguido por';

  @override
  String get btn_relationship_follow_each_other => 'Amigos';

  @override
  String get btn_relationship_follow_request =>
      'Solicitud enviada, pendiente de aprobación';

  @override
  String get btn_relationship_stranger => 'Desconocido';

  @override
  String get btn_relationship_blocked_by => 'Bloqueado por';

  @override
  String btn_relationship_mute(Object acct) {
    return 'Silenciar $acct';
  }

  @override
  String btn_relationship_unmute(Object acct) {
    return 'Quitar silencio a $acct';
  }

  @override
  String btn_relationship_block(Object acct) {
    return 'Bloquear $acct';
  }

  @override
  String btn_relationship_unblock(Object acct) {
    return 'Desbloquear $acct';
  }

  @override
  String btn_relationship_report(Object acct) {
    return 'Reportar $acct';
  }

  @override
  String get btn_notification_mention => 'Mencionado';

  @override
  String get btn_notification_status => 'Notificación';

  @override
  String get btn_notification_reblog => 'Reblog';

  @override
  String get btn_notification_follow => 'Seguido';

  @override
  String get btn_notification_follow_request => 'Solicitud de seguimiento';

  @override
  String get btn_notification_favourite => 'Favorito';

  @override
  String get btn_notification_poll => 'Encuesta';

  @override
  String get btn_notification_update => 'Actualizar';

  @override
  String get btn_notification_admin_sign_up => 'Nuevo registro';

  @override
  String get btn_notification_admin_report => 'Nuevo informe';

  @override
  String get btn_notification_unknown => 'Desconocido';

  @override
  String get btn_follow_request_accept => 'Aceptar';

  @override
  String get btn_follow_request_reject => 'Rechazar';

  @override
  String get btn_report_back => 'Atrás';

  @override
  String get btn_report_next => 'Siguiente';

  @override
  String get btn_report_file => 'Presentar informe';

  @override
  String get btn_report_statuses => 'Toots';

  @override
  String get btn_report_rules => 'Reglas';

  @override
  String get btn_filter_warn => 'Avisar';

  @override
  String get btn_filter_hide => 'Ocultar';

  @override
  String get btn_filter_blur => 'Difuminar';

  @override
  String get btn_filter_context_home => 'Cronología principal';

  @override
  String get btn_filter_context_notification => 'Notificaciones';

  @override
  String get btn_filter_context_public => 'Cronología pública';

  @override
  String get btn_filter_context_thread => 'El toot y sus respuestas';

  @override
  String get btn_filter_context_account => 'Página de perfil';

  @override
  String get btn_filter_whole_match => 'Palabra completa';

  @override
  String get btn_filter_partial_match => 'Coincidencia parcial';

  @override
  String get desc_preference_engineer_clear_cache =>
      'Borrar todos los datos en caché';

  @override
  String get desc_preference_engineer_reset =>
      'Borrar todas las configuraciones y reiniciar la app';

  @override
  String get desc_preference_engineer_test_notifier =>
      'Probar el envío de notificación en el dispositivo local';

  @override
  String get txt_spoiler => 'Spoiler';

  @override
  String get txt_search_history => 'Historial de búsqueda';

  @override
  String get txt_helper_server_explorer => 'Buscar un servidor Mastodon';

  @override
  String get txt_hint_server_explorer => 'mastodon.social o palabra clave';

  @override
  String get txt_desc_preference_system_theme => 'Tema del sistema';

  @override
  String get txt_visibility_public => 'Público';

  @override
  String get txt_visibility_unlisted => 'No listado';

  @override
  String get txt_visibility_private => 'Privado';

  @override
  String get txt_visibility_direct => 'Directo';

  @override
  String get txt_suggestion_staff => 'Recomendado por el personal';

  @override
  String get txt_suggestion_past_interactions => 'Interacciones previas';

  @override
  String get txt_suggestion_global => 'Popularidad global';

  @override
  String get txt_poll_show_total => 'Mostrar total';

  @override
  String get txt_poll_hide_total => 'Ocultar total';

  @override
  String get txt_poll_single => 'Opción única';

  @override
  String get txt_poll_multiple => 'Múltiples opciones';

  @override
  String get txt_preference_status => 'Configuración de estado';

  @override
  String get txt_preference_visibiliby => 'Visibilidad';

  @override
  String get txt_preference_sensitive => 'Contenido sensible';

  @override
  String get txt_preference_refresh_interval => 'Intervalo de actualización';

  @override
  String get txt_preference_loaded_top => 'Alinear al cargar lo más reciente';

  @override
  String get txt_preference_reply_all => 'Todos mencionados';

  @override
  String get txt_preference_reply_only => 'Solo el autor';

  @override
  String get txt_preference_reply_none => 'No etiquetar a nadie';

  @override
  String get txt_show_less => 'Mostrar menos';

  @override
  String get txt_show_more => 'Mostrar más';

  @override
  String get txt_no_result => 'No se encontraron resultados';

  @override
  String get txt_profile_bot => 'Cuenta bot';

  @override
  String get txt_profile_locked => 'Cuenta bloqueada';

  @override
  String get txt_profile_discoverable => 'Cuenta visible públicamente';

  @override
  String get txt_profile_post_indexable =>
      'Privacidad de publicaciones públicas';

  @override
  String get txt_profile_hide_collections => 'Mostrar seguidores y seguidos';

  @override
  String get txt_profile_general_name => 'Nombre visible';

  @override
  String get txt_profile_general_bio => 'Biografía';

  @override
  String get txt_list_policy_followed =>
      'Mostrar respuestas de cualquier usuario seguido';

  @override
  String get txt_list_policy_list =>
      'Mostrar respuestas solo de miembros de la lista';

  @override
  String get txt_list_policy_none => 'No mostrar respuestas';

  @override
  String get txt_list_exclusive => 'Eliminar del feed principal';

  @override
  String get txt_list_inclusive => 'Mantener en el feed principal';

  @override
  String get txt_report_spam => 'Spam';

  @override
  String get txt_report_legal => 'Contenido ilegal';

  @override
  String get txt_report_violation => 'Infracción de reglas';

  @override
  String get txt_report_other => 'Otro';

  @override
  String get txt_filter_title => 'Selecciona un filtro para aplicar';

  @override
  String get txt_filter_applied => 'Filtro ya aplicado';

  @override
  String get txt_filter_name => 'Nombre del filtro';

  @override
  String get txt_filter_expired => 'Expirado';

  @override
  String get txt_filter_never => 'Nunca';

  @override
  String get desc_preference_status =>
      'Configura y controla el comportamiento predeterminado de tus publicaciones';

  @override
  String get desc_poll_show_hide_total =>
      'Mostrar/ocultar recuento de votos hasta que termine la encuesta';

  @override
  String get desc_preference_visibility =>
      'Controla quién puede ver y listar la publicación';

  @override
  String get desc_preference_sensitive =>
      'Mostrar/ocultar contenido sensible por defecto';

  @override
  String get desc_visibility_public => 'Cualquiera puede ver esta publicación';

  @override
  String get desc_visibility_unlisted =>
      'Público pero no listado en la cronología';

  @override
  String get desc_visibility_private =>
      'Solo seguidores y usuarios mencionados';

  @override
  String get desc_visibility_direct => 'Solo usuarios mencionados';

  @override
  String get desc_preference_refresh_interval =>
      'Intervalo para actualizar los datos de la app';

  @override
  String get desc_preference_loaded_top =>
      'Cargar los datos más recientes y saltar arriba al tocar el ícono';

  @override
  String get desc_preference_locale =>
      'Se usará la configuración regional del sistema';

  @override
  String get desc_profile_bot =>
      'La cuenta puede realizar acciones automatizadas sin supervisión humana';

  @override
  String get desc_profile_locked =>
      'Aprueba manualmente solicitudes de seguimiento';

  @override
  String get desc_profile_discoverable =>
      'La cuenta puede encontrarse en el directorio público';

  @override
  String get desc_profile_post_indexable =>
      'Las publicaciones públicas no son buscables';

  @override
  String get desc_profile_hide_collections =>
      'Todos pueden ver tus seguidores y seguidos en tu perfil';

  @override
  String get desc_preference_reply_all =>
      'Etiquetar a todos mencionados en la publicación';

  @override
  String get desc_preference_reply_only => 'Etiquetar solo al autor';

  @override
  String get desc_preference_reply_none => 'No etiquetar a nadie';

  @override
  String get desc_create_list => 'Crear nueva lista';

  @override
  String get desc_list_search_following =>
      'Buscar cuentas seguidas para agregar a la lista';

  @override
  String get desc_report_spam =>
      'La cuenta está publicando anuncios no solicitados.';

  @override
  String get desc_report_legal =>
      'La cuenta está publicando contenido ilegal o solicitando acciones ilegales.';

  @override
  String get desc_report_violation =>
      'La cuenta está publicando contenido que viola las reglas de la instancia.';

  @override
  String get desc_report_other => 'Otras razones no listadas.';

  @override
  String get desc_report_comment =>
      'Agregue un comentario opcional para dar más contexto a su informe.';

  @override
  String get desc_filter_warn => 'Muestra un aviso con el título del filtro.';

  @override
  String get desc_filter_hide => 'No mostrar este estado si se recibe.';

  @override
  String get desc_filter_blur =>
      'Oculta el contenido tras la etiqueta de sensible.';

  @override
  String get desc_filter_context_home =>
      'Cualquier toot coincidente en la cronología principal';

  @override
  String get desc_filter_context_notification =>
      'Cualquier notificación coincidente';

  @override
  String get desc_filter_context_public =>
      'Cualquier toot coincidente en la cronología pública';

  @override
  String get desc_filter_context_thread =>
      'Cualquier toot y sus respuestas coincidentes';

  @override
  String get desc_filter_context_account => 'Cualquier perfil coincidente';

  @override
  String get desc_filter_expiration => 'Cuándo caducará el filtro';

  @override
  String get desc_filter_context => 'Dónde se aplica el filtro';

  @override
  String err_invalid_instance(Object domain) {
    return 'Dominio de servidor Mastodon inválido: $domain';
  }

  @override
  String get msg_preference_engineer_clear_cache =>
      'Caché borrada correctamente';

  @override
  String get msg_preference_engineer_reset => 'Restablecido correctamente';

  @override
  String get msg_copied_to_clipboard => 'Copiado al portapapeles';

  @override
  String get msg_notification_title => 'Nuevas notificaciones';

  @override
  String msg_notification_body(Object count) {
    return 'Tienes $count notificaciones sin leer';
  }

  @override
  String msg_follow_request(Object name) {
    return 'Solicitud de seguimiento de $name';
  }

  @override
  String get dots => '...';
}
