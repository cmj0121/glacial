// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get txt_app_name => 'glacial';

  @override
  String get txt_search_mastodon => 'mastodon.social';

  @override
  String get txt_search_hint => 'Presiona Enter para buscar...';

  @override
  String get txt_search_helper => 'Busca algo interesante';

  @override
  String get txt_search_history => 'Historial de búsqueda';

  @override
  String get txt_invalid_instance => 'Servidor de Mastodon no válido';

  @override
  String get txt_server_contact => 'Información de contacto';

  @override
  String get txt_server_rules => 'Reglas del servidor';

  @override
  String get txt_public => 'Público';

  @override
  String get txt_unlisted => 'No listado';

  @override
  String get txt_private => 'Privado (seguidores)';

  @override
  String get txt_direct => 'Directo';

  @override
  String get txt_copied_to_clipboard => 'Copiado al portapapeles';

  @override
  String txt_trends_uses(Object uses) {
    return '$uses veces en los últimos días';
  }

  @override
  String get btn_clean_all => 'Borrar todo';

  @override
  String get btn_back_to_explorer => 'Volver al explorador';

  @override
  String get btn_sign_in => 'Iniciar sesión';

  @override
  String get btn_timeline => 'Línea de tiempo';

  @override
  String get btn_trending => 'Tendencias';

  @override
  String get btn_notifications => 'Notificaciones';

  @override
  String get btn_explore => 'Explorar';

  @override
  String get btn_settings => 'Configuración';

  @override
  String get btn_post => 'Publicar';

  @override
  String get btn_home_timeline => 'Inicio';

  @override
  String get btn_local_timeline => 'Local';

  @override
  String get btn_federal_timeline => 'Federal';

  @override
  String get btn_public_timeline => 'Público';

  @override
  String get btn_bookmarks_timeline => 'Marcadores';

  @override
  String get btn_favourites_timeline => 'Favoritos';

  @override
  String get btn_hashtag_timeline => 'Hashtag';

  @override
  String get btn_reply => 'Responder';

  @override
  String get btn_reblog => 'Rebloguear';

  @override
  String get btn_favourite => 'Favorito';

  @override
  String get btn_bookmark => 'Marcador';

  @override
  String get btn_share => 'Compartir';

  @override
  String get btn_mute => 'Silenciar';

  @override
  String get btn_block => 'Bloquear';

  @override
  String get btn_delete => 'Eliminar';

  @override
  String get dots => '...';
}
