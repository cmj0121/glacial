// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get txt_app_name => 'Glacial';

  @override
  String get txt_invalid_instance => 'Servidor de Mastodon no válido';

  @override
  String get txt_server_contact => 'Contacto';

  @override
  String get txt_search_helper => 'Busca algo interesante';

  @override
  String get txt_search_history => 'Historial de búsqueda';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_server_rules => 'Reglas del servidor';

  @override
  String get txt_show_less => 'Mostrar menos';

  @override
  String get txt_show_more => 'Mostrar más';

  @override
  String txt_trends_uses(Object uses) {
    return '$uses veces en los últimos días';
  }

  @override
  String txt_no_results_found(Object keyword) {
    return 'No se encontraron resultados para $keyword';
  }

  @override
  String get txt_copied_to_clipboard => 'Copiado al portapapeles';

  @override
  String get txt_public => 'Público';

  @override
  String get txt_unlisted => 'No listado';

  @override
  String get txt_private => 'Privado (seguidores)';

  @override
  String get txt_direct => 'Directo';

  @override
  String get btn_clean_all => 'Borrar todo';

  @override
  String get btn_timeline => 'Línea de tiempo';

  @override
  String get btn_trending => 'Tendencia ahora';

  @override
  String get btn_notifications => 'Notificaciones';

  @override
  String get btn_settings => 'Ajustes';

  @override
  String get btn_management => 'Administración';

  @override
  String get btn_trends_links => 'Noticias';

  @override
  String get btn_trends_statuses => 'Publicaciones';

  @override
  String get btn_trends_tags => 'Etiquetas';

  @override
  String get btn_home => 'Inicio';

  @override
  String get btn_user => 'usuario';

  @override
  String get btn_local => 'Este servidor';

  @override
  String get btn_federal => 'Otros servidores';

  @override
  String get btn_public => 'Todas';

  @override
  String get btn_bookmarks => 'Marcadores';

  @override
  String get btn_favourites => 'Favoritos';

  @override
  String get btn_post => 'Publicar';

  @override
  String get btn_follow_mutual => 'Mutuo';

  @override
  String get btn_following => 'Siguiendo';

  @override
  String get btn_followed_by => 'Seguido por';

  @override
  String get btn_follow => 'Seguir';

  @override
  String get btn_block => 'Bloquear';

  @override
  String get btn_unblock => 'Desbloquear';

  @override
  String get btn_mute => 'Silenciar';

  @override
  String get btn_unmute => 'Reactivar sonido';

  @override
  String get btn_report => 'Reportar';

  @override
  String get dots => '...';
}
